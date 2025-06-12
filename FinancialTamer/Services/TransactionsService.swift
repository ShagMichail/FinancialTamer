//
//  TransactionsService.swift
//  FinancialTamer
//
//  Created by Михаил Шаговитов on 12.06.2025.
//

import Foundation

final class TransactionsService {
    private var mockTransactions: [Transaction] = [
        Transaction(
            id: 1,
            accountId: 1,
            categoryId: 1,
            amount: Decimal(50000),
            transactionDate: Date().addingTimeInterval(-86400),
            comment: "Зарплата за месяц",
            createdAt: Date(),
            updatedAt: Date()
        ),
        Transaction(
            id: 2,
            accountId: 1,
            categoryId: 2,
            amount: Decimal(3500),
            transactionDate: Date(),
            comment: "Продукты",
            createdAt: Date(),
            updatedAt: Date()
        )
    ]
    
    func getTransactions(for period: DateInterval) async throws -> [Transaction] {
        try await Task.sleep(nanoseconds: 500_000_000)
        return mockTransactions.filter { transaction in
            period.contains(transaction.transactionDate)
        }
    }
    
    func createTransaction(_ transaction: Transaction) async throws {
        try await Task.sleep(nanoseconds: 500_000_000)
        guard !mockTransactions.contains(where: { $0.id == transaction.id }) else {
            throw MockError.duplicateTransaction
        }
        mockTransactions.append(transaction)
    }
    
    func editTransaction(_ transaction: Transaction) async throws {
        try await Task.sleep(nanoseconds: 500_000_000)
        guard let index = mockTransactions.firstIndex(where: { $0.id == transaction.id }) else {
            throw MockError.transactionNotFound
        }
        mockTransactions[index] = transaction
    }
    
    func deleteTransaction(withId id: Int) async throws {
        try await Task.sleep(nanoseconds: 500_000_000)
        mockTransactions.removeAll { $0.id == id }
    }
    
    enum MockError: Error {
        case transactionNotFound
        case duplicateTransaction
    }
}
