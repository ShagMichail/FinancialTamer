//
//  MyHistoryViewModel.swift
//  FinancialTamer
//
//  Created by Михаил Шаговитов on 18.06.2025.
//

import SwiftUI

enum SortType: String, CaseIterable, Identifiable {
    case date = "По дате"
    case amount = "По сумме"
    var id: String { self.rawValue }
}

@MainActor
final class MyHistoryViewModel: ObservableObject {
    @Published var selectedDirection: Direction = .outcome {
        didSet {
            filterTransactions()
        }
    }
    @Published var totalAmount: Decimal = 0
    @Published var allTransactions: [Transaction] = []
    @Published var displayedTransactions: [Transaction] = []
    @Published var categories: [Category] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var sortType: SortType = .date
    
    private let transactionsService: TransactionsService
    private let categoriesService: CategoriesService
    
    var sortedTransactions: [Transaction] {
        switch sortType {
        case .date:
            return displayedTransactions.sorted { $0.transactionDate > $1.transactionDate }
        case .amount:
            return displayedTransactions.sorted { $0.amount > $1.amount }
        }
    }
    
    init(transactionsService: TransactionsService, categoriesService: CategoriesService,  selectedDirection: Direction) {
        self.transactionsService = transactionsService
        self.categoriesService = categoriesService
        self.selectedDirection = selectedDirection
    }
    
    func loadData(from startDate: Date, to endDate: Date) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let period = DateInterval(start: startDate, end: endDate)
            async let transactionsTask = transactionsService.getTransactions(for: period)
            async let categoriesTask = categoriesService.categories()
            
            let (transactions, categories) = await (try transactionsTask, try categoriesTask)
                        
            self.allTransactions = transactions
            self.categories = categories
            self.displayedTransactions = transactions
            filterTransactions()
            self.totalAmount = calculateTotalAmount()
        } catch {
            self.error = error
            print("Ошибка загрузки:", error.localizedDescription)
        }
    }
    
    func category(for transaction: Transaction) -> Category? {
        categories.first { $0.id == transaction.categoryId }
    }
    
    private func calculateTotalAmount() -> Decimal {
        displayedTransactions.reduce(0) { $0 + $1.amount }
    }
    
    private func filterTransactions() {
        displayedTransactions = allTransactions.filter { transaction in
            guard let category = category(for: transaction) else { return false }
            return category.direction == selectedDirection
        }
    }
}
