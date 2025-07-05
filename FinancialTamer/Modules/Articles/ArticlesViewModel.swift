//
//  ArticlesViewModel.swift
//  FinancialTamer
//
//  Created by Михаил Шаговитов on 02.07.2025.
//

import SwiftUI
import OSLog

@MainActor
final class ArticlesViewModel: ObservableObject {
    @Published var allCategories: [Category] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var searchText: String = ""
    
    var filteredCategories: [Category] {
        if searchText.isEmpty {
            return allCategories
        } else {
            let threshold = 5
            return allCategories.filter { category in
                let distance = levenshtein(searchText.lowercased(), category.name.lowercased())
                return distance <= threshold || category.name.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    private let categoriesService: CategoriesService
    
    init(categoriesService: CategoriesService = CategoriesService()) {
        self.categoriesService = categoriesService
    }
    
    func loadCategories(direction: Direction? = nil) async {
        isLoading = true
        error = nil
        
        do {
            let categories: [Category]
            if let direction = direction {
                categories = try await categoriesService.categories(direction: direction)
            } else {
                categories = try await categoriesService.categories()
            }
            
            allCategories = categories
            isLoading = false
        } catch {
            self.error = error
            isLoading = false
        }
    }
    
    func levenshtein(_ a: String, _ b: String) -> Int {
        let a = Array(a)
        let b = Array(b)
        var dp = Array(repeating: Array(repeating: 0, count: b.count + 1), count: a.count + 1)
        for i in 0...a.count { dp[i][0] = i }
        for j in 0...b.count { dp[0][j] = j }
        for i in 1...a.count {
            for j in 1...b.count {
                if a[i-1] == b[j-1] {
                    dp[i][j] = dp[i-1][j-1]
                } else {
                    dp[i][j] = min(dp[i-1][j-1], dp[i][j-1], dp[i-1][j]) + 1
                }
            }
        }
        return dp[a.count][b.count]
    }
}
