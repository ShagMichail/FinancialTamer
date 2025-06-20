//
//  TransactionsViewModel.swift
//  FinancialTamer
//
//  Created by Михаил Шаговитов on 18.06.2025.
//

import SwiftUI
import OSLog

@MainActor
final class TransactionsViewModel: ObservableObject {
    @Published var displayedTransactions: [Transaction] = []
    @Published var allTransactions: [Transaction] = []
    @Published var categories: [Category] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var selectedDirection: Direction = .outcome {
        didSet {
            filterTransactions()
        }
    }
    
    private let transactionsService: TransactionsService
    private let categoriesService: CategoriesService
    
    var totalAmountToday: String {
        let todayInterval = Date.todayInterval()
        let todayTransactions = displayedTransactions.filter { todayInterval.contains($0.transactionDate) }
        let total = todayTransactions.reduce(0) { $0 + $1.amount }
        return NumberFormatter.currency.string(from: NSDecimalNumber(decimal: total)) ?? "0 ₽"
    }
    
    init(transactionsService: TransactionsService, categoriesService: CategoriesService, selectedDirection: Direction) {
        self.transactionsService = transactionsService
        self.categoriesService = categoriesService
        self.selectedDirection = selectedDirection
    }
    
    func loadTransactions() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            async let transactionsTask = transactionsService.getTransactions(for: Date.todayInterval())
            async let categoriesTask = categoriesService.categories()
            
            let (loadedTransactions, loadedCategories) = await (try transactionsTask, try categoriesTask)
            
            self.allTransactions = loadedTransactions
            self.categories = loadedCategories
            filterTransactions()
        } catch {
            os_log("Ошибка загрузки: %@", log: .default, type: .error, error.localizedDescription)
        }
    }
    
    func category(for transaction: Transaction) -> Category? {
        return categories.first { $0.id == transaction.categoryId }
    }
    
    func createTransaction(_ transaction: Transaction) async {
        do {
            try await transactionsService.createTransaction(transaction)
            await loadTransactions()
        } catch {
            self.error = error
            os_log("Ошибка создания транзакции: %@", log: .default, type: .error, error.localizedDescription)
        }
    }
    
    func deleteTransaction(withId id: Int) async {
        do {
            try await transactionsService.deleteTransaction(withId: id)
            await loadTransactions()
        } catch {
            self.error = error
            os_log("Ошибка удаления транзакции: %@", log: .default, type: .error, error.localizedDescription)
        }
    }
    
    private func filterTransactions() {
        displayedTransactions = allTransactions.filter { transaction in
            guard let category = category(for: transaction) else { return false }
            return category.direction == selectedDirection
        }
    }
}
