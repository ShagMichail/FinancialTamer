//
//  MyHistoryViewModel.swift
//  FinancialTamer
//
//  Created by Михаил Шаговитов on 18.06.2025.
//

import SwiftUI
import OSLog

enum SortType: String, CaseIterable, Identifiable {
    case date = "По дате"
    case amount = "По сумме"
    var id: String { self.rawValue }
}

enum TypeDate {
    case start
    case end
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
    @Published var errorMessage: String? = nil
    @Published var sortType: SortType = .date
    
    @Published var startDate: Date = {
        let calendar = Calendar.current
        let today = Date()
        let monthAgo = calendar.date(byAdding: .month, value: -1, to: today) ?? today
        let components = calendar.dateComponents([.year, .month, .day], from: monthAgo)
        return calendar.date(from: components) ?? today
    }()
    
    @Published var endDate: Date = {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: Date())
        components.hour = 23
        components.minute = 59
        return calendar.date(from: components) ?? Date()
    }()
    
    let transactionsService: TransactionsService
    let categoriesService: CategoriesService
    
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
    
    func loadData() async {
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
            errorMessage = error.localizedDescription
            os_log("Ошибка загрузки: %@", log: .default, type: .error, error.localizedDescription)
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
    
    func changeDate(newValue: Date, typeDate: TypeDate) {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: newValue)
        
        switch typeDate {
        case .start:
            components.hour = 00
            components.minute = 00
            startDate = calendar.date(from: components) ?? newValue
            if startDate > endDate {
                var endComponents = calendar.dateComponents([.year, .month, .day], from: newValue)
                endComponents.hour = 23
                endComponents.minute = 59
                endDate = calendar.date(from: endComponents) ?? newValue
            }
        case .end:
            components.hour = 23
            components.minute = 59
            endDate = calendar.date(from: components) ?? newValue
            if endDate < startDate {
                var startComponents = calendar.dateComponents([.year, .month, .day], from: newValue)
                startComponents.hour = 00
                startComponents.minute = 00
                startDate = calendar.date(from: startComponents) ?? newValue
            }
        }
    }
}
