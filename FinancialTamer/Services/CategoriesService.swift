//
//  CategoriesService.swift
//  FinancialTamer
//
//  Created by Михаил Шаговитов on 12.06.2025.
//

import Foundation

final class CategoriesService {
    var categories: [Category] = []
    
    func categories() async throws -> [Category] {
        do {
            let data = try await NetworkClient.shared.request(endpointValue: "api/v1/categories")
            let decoder = JSONDecoder()
            let fetchedCategories = try decoder.decode([Category].self, from: data)
            categories = fetchedCategories
            return categories
        } catch {
            print("Error loading categories: \(error)")
            throw error
        }
    }
    
    func categories(direction: Direction) async throws -> [Category] {
        return categories.filter { $0.direction == direction }
    }
}
