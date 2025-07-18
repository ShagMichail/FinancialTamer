//
//  BankAccountsService.swift
//  FinancialTamer
//
//  Created by Михаил Шаговитов on 12.06.2025.
//

import Foundation

protocol BankAccountsServiceProtocol {
    func getAccount() async throws -> BankAccount
    func updateAccount(_ account: BankAccount) async throws
}

final class BankAccountsService: BankAccountsServiceProtocol, ObservableObject {
    static let shared = BankAccountsService()
    
    func getAccount() async throws -> BankAccount {
        let accounts = try await NetworkClient.shared.fetchDecodeData(endpointValue: "api/v1/accounts", dataType: BankAccount.self)
        guard let first = accounts.first else {
            throw AccountError.accountNotFound
        }
        return first
    }
    
    func updateAccount(_ account: BankAccount) async throws {
        let updateRequest = AccountUpdateRequest(name: account.name, balance: account.balance, currency: account.currency)
        let endpoint = "api/v1/accounts/\(account.id)"
        let encoder = JSONEncoder()
        let bodyData = try encoder.encode(updateRequest)
        try await NetworkClient.shared.request(endpointValue: endpoint, method: "PUT", body: bodyData)
    }
    
    enum AccountError: Error {
        case accountNotFound
        var errorDescription: String? {
            switch self {
            case .accountNotFound: return "Account not found"
            }
        }
    }
}
