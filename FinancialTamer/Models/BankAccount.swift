//
//  BankAccount.swift
//  FinancialTamer
//
//  Created by Михаил Шаговитов on 12.06.2025.
//

import Foundation

struct BankAccount: Codable {
    let id: Int
    let userId: Int
    let name: String
    var balance: String
    var currency: String
    let createdAt: String
    let updatedAt: String
}

struct AccountBrief: Codable {
    let id: Int
    let name: String
    let balance: String
    let currency: String
}

struct AccountUpdateRequest: Codable {
    let name: String
    let balance: String
    let currency: String
}
