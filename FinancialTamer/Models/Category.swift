//
//  Category.swift
//  FinancialTamer
//
//  Created by Михаил Шаговитов on 12.06.2025.
//

import Foundation

enum Direction: String, Codable {
    case income
    case outcome
}

struct Category {
    let id: Int
    let name: String
    let emoji: Character
    let direction: Direction
}
