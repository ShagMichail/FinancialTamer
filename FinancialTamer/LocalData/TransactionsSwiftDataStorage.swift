//
//  TransactionsSwiftDataStorage.swift
//  FinancialTamer
//
//  Created by Михаил Шаговитов on 18.07.2025.
//

import SwiftData
import Foundation

protocol TransactionsStorageProtocol {
    func getAllTransactions() async throws -> [Transaction]
    func getTransaction(byId id: Int) async throws -> Transaction?
    func updateTransaction(_ transaction: Transaction) async throws
    func deleteTransaction(byId id: Int) async throws
    func createTransaction(_ transaction: Transaction) async throws
    func addToBackup(transaction: Transaction?, action: BackupAction) async throws
    func getBackupTransactions() async throws -> [BackupItem]
    func removeFromBackup(ids: [Int]) async throws
}

@Model
final class TransactionModel {
    var id: Int
    var accountId: Int
    var categoryId: Int
    var amount: Decimal
    var transactionDate: Date
    var comment: String?
    var isSynced: Bool
    
    init(from transaction: Transaction) {
        self.id = transaction.id
        self.accountId = transaction.accountId
        self.categoryId = transaction.categoryId
        self.amount = transaction.amount
        self.transactionDate = transaction.transactionDate
        self.comment = transaction.comment
        self.isSynced = true
    }
}

@Model
final class BackupTransaction {
    var id: Int
    var transactionData: Data
    var action: String
    var timestamp: Date
    
    init(id: Int, transaction: Transaction?, action: String) throws {
        self.id = id
        self.action = action
        self.timestamp = Date()
        
        if let transaction = transaction {
            self.transactionData = try JSONEncoder().encode(transaction)
        } else {
            self.transactionData = Data()
        }
    }
}


final class TransactionsSwiftDataStorage: TransactionsStorageProtocol {
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext
    
    init() {
        do {
            let schema = Schema([
                TransactionModel.self,
                BackupTransaction.self
            ])
            let config = ModelConfiguration(schema: schema)
            modelContainer = try ModelContainer(for: schema, configurations: config)
            modelContext = ModelContext(modelContainer)
        } catch {
            fatalError("Failed to initialize SwiftData storage: \(error)")
        }
    }
    
    // MARK: - Основные методы
    
    func getAllTransactions() async throws -> [Transaction] {
        let descriptor = FetchDescriptor<TransactionModel>()
        let models = try modelContext.fetch(descriptor)
        return models.map { $0.toTransaction() }
    }
    
    func getTransaction(byId id: Int) async throws -> Transaction? {
        let predicate = #Predicate<TransactionModel> { $0.id == id }
        let descriptor = FetchDescriptor(predicate: predicate)
        return try modelContext.fetch(descriptor).first?.toTransaction()
    }
    
    func updateTransaction(_ transaction: Transaction) async throws {
        let predicate = #Predicate<TransactionModel> { $0.id == transaction.id }
        let descriptor = FetchDescriptor(predicate: predicate)
        
        if let existing = try modelContext.fetch(descriptor).first {
            existing.update(from: transaction)
        } else {
            let newModel = TransactionModel(from: transaction)
            modelContext.insert(newModel)
        }
        
        try saveContext()
    }
    
    func deleteTransaction(byId id: Int) async throws {
        let predicate = #Predicate<TransactionModel> { $0.id == id }
        let descriptor = FetchDescriptor(predicate: predicate)
        
        for model in try modelContext.fetch(descriptor) {
            modelContext.delete(model)
        }
        
        try saveContext()
    }
    
    func createTransaction(_ transaction: Transaction) async throws {
        let existingPredicate = #Predicate<TransactionModel> { $0.id == transaction.id }
        let existingDescriptor = FetchDescriptor(predicate: existingPredicate)
        guard try modelContext.fetch(existingDescriptor).isEmpty else {
            throw TransactionError.duplicateTransaction
        }
        
        let newModel = TransactionModel(from: transaction)
        modelContext.insert(newModel)
        try saveContext()
    }
    
    // MARK: - Методы для работы с бекапом
    
    func addToBackup(transaction: Transaction?, action: BackupAction) async throws {
        guard let transaction = transaction else {
            let backupItem = try BackupTransaction(
                id: action.id,
                transaction: nil,
                action: action.rawValue
            )
            modelContext.insert(backupItem)
            try saveContext()
            return
        }
        
        let predicate = #Predicate<BackupTransaction> { $0.id == transaction.id }
        let descriptor = FetchDescriptor(predicate: predicate)
        
        if let existing = try modelContext.fetch(descriptor).first {
            existing.action = action.rawValue
            existing.transactionData = try JSONEncoder().encode(transaction)
            existing.timestamp = Date()
        } else {
            let backupItem = try BackupTransaction(
                id: transaction.id,
                transaction: transaction,
                action: action.rawValue
            )
            modelContext.insert(backupItem)
        }
        
        try saveContext()
    }
    
    func getBackupTransactions() async throws -> [BackupItem] {
        let descriptor = FetchDescriptor<BackupTransaction>(
            sortBy: [SortDescriptor(\.timestamp)]
        )
        
        return try modelContext.fetch(descriptor).compactMap {
            guard let action = BackupAction.from(string: $0.action, id: $0.id) else { return nil }
            
            if $0.transactionData.isEmpty {
                return BackupItem(id: $0.id, action: action, transaction: nil)
            }
            
            let transaction = try JSONDecoder().decode(Transaction.self, from: $0.transactionData)
            return BackupItem(id: $0.id, action: action, transaction: transaction)
        }
    }
    
    func removeFromBackup(ids: [Int]) async throws {
        let predicate = #Predicate<BackupTransaction> { ids.contains($0.id) }
        let descriptor = FetchDescriptor(predicate: predicate)
        
        for item in try modelContext.fetch(descriptor) {
            modelContext.delete(item)
        }
        
        try saveContext()
    }
    
    // MARK: - Вспомогательные методы
    
    private func saveContext() throws {
        try modelContext.save()
    }
    
    enum TransactionError: Error {
        case duplicateTransaction
        case notFound
    }
}

// MARK: - Расширения для моделей
struct BackupItem {
    let id: Int
    let action: BackupAction
    let transaction: Transaction?
}

extension TransactionModel {
    func toTransaction() -> Transaction {
        Transaction(
            id: id,
            accountId: accountId,
            categoryId: categoryId,
            amount: amount,
            transactionDate: transactionDate,
            comment: comment ?? "",
            createdAt: transactionDate,
            updatedAt: Date()
        )
    }
    
    func update(from transaction: Transaction) {
        accountId = transaction.accountId
        categoryId = transaction.categoryId
        amount = transaction.amount
        transactionDate = transaction.transactionDate
        comment = transaction.comment
        isSynced = false
    }
}

extension BackupTransaction {
    convenience init(id: Int, transactionData: Data, action: String, timestamp: Date) {
        self.init(
            id: id,
            transactionData: transactionData,
            action: action,
            timestamp: timestamp
        )
    }
}

enum BackupAction {
    case create(id: Int)
    case update(id: Int)
    case delete(id: Int)
    
    var rawValue: String {
        switch self {
        case .create: return "create"
        case .update: return "update"
        case .delete: return "delete"
        }
    }
    
    var id: Int {
        switch self {
        case .create(let id), .update(let id), .delete(let id):
            return id
        }
    }
    
    static func from(string: String, id: Int) -> BackupAction? {
        switch string {
        case "create": return .create(id: id)
        case "update": return .update(id: id)
        case "delete": return .delete(id: id)
        default: return nil
        }
    }
}
