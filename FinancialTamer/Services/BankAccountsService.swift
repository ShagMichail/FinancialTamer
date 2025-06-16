//
//  BankAccountsService.swift
//  FinancialTamer
//
//  Created by Михаил Шаговитов on 12.06.2025.
//

import Foundation

final class BankAccountsService {
    private var mockAccounts: [BankAccount] = [
        BankAccount(
            id: 1,
            userId: 1,
            name: "Основной счет",
            balance: Decimal(10000.00),
            currency: "RUB",
            createdAt: Date(),
            updatedAt: Date()
        )
    ]
    
    func getAccount() async throws -> BankAccount {
        try await Task.sleep(nanoseconds: 500_000_000)
        guard let account = mockAccounts.first else {
            throw MockError.accountNotFound
        }
        return account
    }
    
    func updateAccount(_ account: BankAccount) async throws {
        try await Task.sleep(nanoseconds: 500_000_000)
        guard let index = mockAccounts.firstIndex(where: { $0.id == account.id }) else {
            throw MockError.accountNotFound
        }
        mockAccounts[index] = account
    }
    
    enum MockError: Error {
        case accountNotFound
    }
}
