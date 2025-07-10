//
//  File.swift
//  FinancialTamer
//
//  Created by Михаил Шаговитов on 10.07.2025.
//

import Foundation

struct CategorySummary {
    let category: Category
    let totalAmount: Decimal
    let percentage: Int
    let transactions: [Transaction]
}
