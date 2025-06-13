//
//  CategoriesService.swift
//  FinancialTamer
//
//  Created by Михаил Шаговитов on 12.06.2025.
//

import Foundation

final class CategoriesService {
    private let mockCategories: [Category] = [
        Category(
            id: 1,
            name: "Зарплата",
            emoji: "💰",
            direction: .income
        ),
        Category(
            id: 2,
            name: "Продукты",
            emoji: "🛒",
            direction: .outcome
        ),
        Category(
            id: 3,
            name: "Кафе",
            emoji: "🍕",
            direction: .outcome
        ),
        Category(
            id: 4,
            name: "Подарок",
            emoji: "🎁",
            direction: .income
        )
    ]
    
    func categories() async throws -> [Category] {
        try await Task.sleep(nanoseconds: 500_000_000)
        return mockCategories
    }
    
    func categories(direction: Direction) async throws -> [Category] {
        try await Task.sleep(nanoseconds: 500_000_000)
        return mockCategories.filter { $0.direction == direction }
    }
}
