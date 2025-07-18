//
//  TransactionsService.swift
//  FinancialTamer
//
//  Created by Михаил Шаговитов on 12.06.2025.
//

import Foundation
import Combine

final class TransactionsService {
    private let networkClient: NetworkClientProtocol
    private let storage: TransactionsStorageProtocol
    private let backupStorage: TransactionsStorageProtocol
    private let accountsService: BankAccountsServiceProtocol
    private let syncQueue = DispatchQueue(label: "com.transactions.sync.queue", attributes: .concurrent)
    
    init(
        networkClient: NetworkClientProtocol = NetworkClient.shared,
        storage: TransactionsStorageProtocol = TransactionsSwiftDataStorage(),
        backupStorage: TransactionsStorageProtocol = TransactionsSwiftDataStorage(),
        accountsService: BankAccountsServiceProtocol = BankAccountsService.shared
    ) {
        self.networkClient = networkClient
        self.storage = storage
        self.backupStorage = backupStorage
        self.accountsService = accountsService
    }
    
    // MARK: - Public Methods
    
    func getTransactions(for period: DateInterval) async throws -> [Transaction] {
        try await syncBackupTransactions()
        
        do {
            let networkTransactions = try await fetchNetworkTransactions(for: period)
            
            try await saveTransactionsToStorage(networkTransactions)
            
            try await clearSyncedBackupTransactions()
            
            return networkTransactions
        } catch {
            return try await getLocalTransactions(for: period)
        }
    }
    
    func createTransaction(_ transaction: Transaction) async throws {
        do {
            let request = try createTransactionRequest(from: transaction)
            try await networkClient.request(
                endpointValue: "api/v1/transactions",
                method: "POST",
                body: request
            )
            let account = try await accountsService.getAccount()
            try await storage.createTransaction(transaction)
            
            try await backupStorage.deleteTransaction(byId: transaction.id)
            
            try await accountsService.updateAccount(account)
        } catch {
            try await backupStorage.addToBackup(
                transaction: transaction,
                action: .create(id: transaction.id)
            )
            throw error
        }
    }
    
    func editTransaction(_ transaction: Transaction) async throws {
        do {
            let request = try createTransactionRequest(from: transaction)
            try await networkClient.request(
                endpointValue: "api/v1/transactions/\(transaction.id)",
                method: "PUT",
                body: request
            )
            
            try await storage.updateTransaction(transaction)
            try await backupStorage.deleteTransaction(byId: transaction.id)
        } catch {
            try await backupStorage.addToBackup(
                transaction: transaction,
                action: .update(id: transaction.id)
            )
            throw error
        }
    }
    
    func deleteTransaction(withId id: Int) async throws {
        do {
            try await networkClient.request(
                endpointValue: "api/v1/transactions/\(id)",
                method: "DELETE",
                body: nil
            )
            
            if let transaction = try await storage.getTransaction(byId: id) {
                let account = try await accountsService.getAccount()
                try await accountsService.updateAccount(account)
            }
            
            try await storage.deleteTransaction(byId: id)
            
            try await backupStorage.deleteTransaction(byId: id)
        } catch {
            try await backupStorage.addToBackup(
                transaction: nil,
                action: .delete(id: id)
            )
            throw error
        }
    }
    
    // MARK: - Private Methods
    
    private func syncBackupTransactions() async throws {
        let backupItems = try await backupStorage.getBackupTransactions()
        
        for item in backupItems {
            do {
                switch item.action {
                case .create:
                    guard let transaction = item.transaction else { continue }
                    try await createTransaction(transaction)
                    
                case .update:
                    guard let transaction = item.transaction else { continue }
                    try await editTransaction(transaction)
                    
                case .delete(let id):
                    try await deleteTransaction(withId: id)
                }
                
                try await backupStorage.removeFromBackup(ids: [item.id])
            } catch {
                print("Failed to sync backup transaction \(item.id): \(error)")
                continue
            }
        }
    }
    
    private func fetchNetworkTransactions(for period: DateInterval) async throws -> [Transaction] {
        let account = try await accountsService.getAccount()
        let startDate = formatDate(period.start)
        let endDate = formatDate(period.end)
        
        let endpoint = "api/v1/transactions/account/\(account.id)/period?startDate=\(startDate)&endDate=\(endDate)"
        
        let responses = try await networkClient.fetchDecodeData(
            endpointValue: endpoint,
            dataType: TransactionResponse.self
        )
        
        return responses.compactMap { response in
            let localDate = response.transactionDate.convertFromUTCToLocal()
            return response.toTransaction(with: localDate ?? Date())
        }
    }
    
    private func saveTransactionsToStorage(_ transactions: [Transaction]) async throws {
        for transaction in transactions {
            try await storage.updateTransaction(transaction)
        }
    }
    
    private func clearSyncedBackupTransactions() async throws {
        let syncedIds = try await storage.getAllTransactions()
            .map { $0.id }
        
        try await backupStorage.removeFromBackup(ids: syncedIds)
    }
    
    private func getLocalTransactions(for period: DateInterval) async throws -> [Transaction] {
        let allTransactions = try await storage.getAllTransactions()
        return allTransactions.filter { transaction in
            period.contains(transaction.transactionDate)
        }
    }
    
    private func createTransactionRequest(from transaction: Transaction) throws -> Data {
        let request = TransactionRequest(
            accountId: transaction.accountId,
            categoryId: transaction.categoryId,
            amount: NSDecimalNumber(decimal: transaction.amount).stringValue,
            transactionDate: formatUTCDateToString(date: transaction.transactionDate),
            comment: transaction.comment
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(request)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter.string(from: date)
    }
    
    private func formatUTCDateToString(date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.string(from: date)
    }
}

// MARK: - Supporting Types

extension TransactionsService {
    enum BackupAction {
        case create
        case update
        case delete(id: Int)
    }
    
    struct BackupItem {
        let id: Int
        let action: BackupAction
        let transaction: Transaction?
    }
    
    enum TransactionError: Error {
        case networkError
        case storageError
        case syncError
    }
}
