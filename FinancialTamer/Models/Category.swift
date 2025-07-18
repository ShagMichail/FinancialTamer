//
//  Category.swift
//  FinancialTamer
//
//  Created by Михаил Шаговитов on 12.06.2025.
//

import Foundation

enum Direction: Codable {
    case income
    case outcome
}

struct Category: Codable, Hashable {
    let id: Int
    let name: String
    let emoji: String
    let isIncome: Bool
    
    var direction: Direction {
        return isIncome ? .income : .outcome
    }
}
