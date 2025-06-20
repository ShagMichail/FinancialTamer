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
            transactionDate: Date(),
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
        ),
        
        Transaction(
            id: 3,
            accountId: 1,
            categoryId: 3,
            amount: Decimal(500),
            transactionDate: Date(),
            comment: "",
            createdAt: Date(),
            updatedAt: Date()
        ),
        
        Transaction(
            id: 4,
            accountId: 1,
            categoryId: 3,
            amount: Decimal(499),
            transactionDate: Date(),
            comment: "",
            createdAt: Date(),
            updatedAt: Date()
        ),
        
        Transaction(
            id: 5,
            accountId: 1,
            categoryId: 3,
            amount: Decimal(467),
            transactionDate: Date(),
            comment: "Кофикс",
            createdAt: Date(),
            updatedAt: Date()
        ),
        
        Transaction(
            id: 6,
            accountId: 1,
            categoryId: 3,
            amount: Decimal(3456),
            transactionDate: Date(),
            comment: "Кофикс",
            createdAt: Date(),
            updatedAt: Date()
        ),
        
        Transaction(
            id: 7,
            accountId: 1,
            categoryId: 3,
            amount: Decimal(456),
            transactionDate: Date(),
            comment: "Кофикс",
            createdAt: Date(),
            updatedAt: Date()
        ),
        
        Transaction(
            id: 8,
            accountId: 1,
            categoryId: 3,
            amount: Decimal(345),
            transactionDate: Date(),
            comment: "Кофикс",
            createdAt: Date(),
            updatedAt: Date()
        ),
        
        Transaction(
            id: 9,
            accountId: 1,
            categoryId: 3,
            amount: Decimal(234),
            transactionDate: Date(),
            comment: "Кофикс",
            createdAt: Date(),
            updatedAt: Date()
        ),
        
        Transaction(
            id: 10,
            accountId: 1,
            categoryId: 3,
            amount: Decimal(132),
            transactionDate: Date(),
            comment: "Кофикс",
            createdAt: Date(),
            updatedAt: Date()
        ),
        
        Transaction(
            id: 11,
            accountId: 1,
            categoryId: 3,
            amount: Decimal(756),
            transactionDate: Date(),
            comment: "Кофикс",
            createdAt: Date(),
            updatedAt: Date()
        ),
        
        Transaction(
            id: 12,
            accountId: 1,
            categoryId: 3,
            amount: Decimal(654),
            transactionDate: Date(),
            comment: "Кофикс",
            createdAt: Date(),
            updatedAt: Date()
        ),
        
        Transaction(
            id: 13,
            accountId: 1,
            categoryId: 3,
            amount: Decimal(534),
            transactionDate: Date(),
            comment: "Кофикс",
            createdAt: Date(),
            updatedAt: Date()
        ),
        
        Transaction(
            id: 14,
            accountId: 1,
            categoryId: 3,
            amount: Decimal(4423),
            transactionDate: Date(),
            comment: "Кофикс",
            createdAt: Date(),
            updatedAt: Date()
        ),
        
        Transaction(
            id: 15,
            accountId: 1,
            categoryId: 3,
            amount: Decimal(423),
            transactionDate: Date(),
            comment: "Кофикс",
            createdAt: Date(),
            updatedAt: Date()
        ),
        
        Transaction(
            id: 16,
            accountId: 1,
            categoryId: 3,
            amount: Decimal(4555),
            transactionDate: Date(),
            comment: "Кофикс",
            createdAt: Date(),
            updatedAt: Date()
        ),
        
        Transaction(
            id: 17,
            accountId: 1,
            categoryId: 3,
            amount: Decimal(134),
            transactionDate: Date(),
            comment: "Кофикс",
            createdAt: Date(),
            updatedAt: Date()
        ),
        
        Transaction(
            id: 18,
            accountId: 1,
            categoryId: 3,
            amount: Decimal(654),
            transactionDate: Date(),
            comment: "Кофикс",
            createdAt: Date(),
            updatedAt: Date()
        ),
        
        Transaction(
            id: 19,
            accountId: 1,
            categoryId: 3,
            amount: Decimal(1234),
            transactionDate: Date(),
            comment: "Кофикс",
            createdAt: Date(),
            updatedAt: Date()
        ),
        
        Transaction(
            id: 20,
            accountId: 1,
            categoryId: 3,
            amount: Decimal(534),
            transactionDate: Date(),
            comment: "Кофикс",
            createdAt: Date(),
            updatedAt: Date()
        ),
        
        Transaction(
            id: 21,
            accountId: 1,
            categoryId: 3,
            amount: Decimal(234),
            transactionDate: Date(),
            comment: "Кофикс",
            createdAt: Date(),
            updatedAt: Date()
        ),
        
        Transaction(
            id: 22,
            accountId: 1,
            categoryId: 3,
            amount: Decimal(500),
            transactionDate: Date(),
            comment: "Кофикс",
            createdAt: Date(),
            updatedAt: Date()
        ),
        
        Transaction(
            id: 23,
            accountId: 1,
            categoryId: 3,
            amount: Decimal(500),
            transactionDate: Date(),
            comment: "Кофикс",
            createdAt: Date(),
            updatedAt: Date()
        ),
        
        Transaction(
            id: 24,
            accountId: 1,
            categoryId: 3,
            amount: Decimal(500),
            transactionDate: Date(),
            comment: "Кофикс",
            createdAt: Date(),
            updatedAt: Date()
        ),
        
        Transaction(
            id: 25,
            accountId: 1,
            categoryId: 3,
            amount: Decimal(500),
            transactionDate: Date(),
            comment: "Кофикс",
            createdAt: Date(),
            updatedAt: Date()
        ),
        
        Transaction(
            id: 26,
            accountId: 1,
            categoryId: 3,
            amount: Decimal(500),
            transactionDate: Date(),
            comment: "Кофикс",
            createdAt: Date(),
            updatedAt: Date()
        ),
        
        Transaction(
            id: 27,
            accountId: 1,
            categoryId: 3,
            amount: Decimal(500),
            transactionDate: Date(),
            comment: "sdsdfsdf",
            createdAt: Date(),
            updatedAt: Date()
        ),
        
        Transaction(
            id: 28,
            accountId: 1,
            categoryId: 3,
            amount: Decimal(500),
            transactionDate: Date(),
            comment: "dddddd",
            createdAt: Date(),
            updatedAt: Date()
        ),
        
        Transaction(
            id: 29,
            accountId: 1,
            categoryId: 3,
            amount: Decimal(500),
            transactionDate: Date(),
            comment: "ssssss",
            createdAt: Date(),
            updatedAt: Date()
        ),
        
        Transaction(
            id: 30,
            accountId: 1,
            categoryId: 3,
            amount: Decimal(500),
            transactionDate: Date(),
            comment: "aaaaaaa",
            createdAt: Date(),
            updatedAt: Date()
        ),
        
        Transaction(
            id: 31,
            accountId: 1,
            categoryId: 3,
            amount: Decimal(500),
            transactionDate: Date(),
            comment: "Cnfh,frc",
            createdAt: Date(),
            updatedAt: Date()
        ),
        
        Transaction(
            id: 32,
            accountId: 1,
            categoryId: 3,
            amount: Decimal(500),
            transactionDate: Date(),
            comment: "Кофиксccccccc",
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
