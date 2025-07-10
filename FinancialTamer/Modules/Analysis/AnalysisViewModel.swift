//
//  AnalysisViewModel.swift
//  FinancialTamer
//
//  Created by Михаил Шаговитов on 10.07.2025.
//

import UIKit
import os.log

protocol AnalysisViewModelDelegate: AnyObject {
    func dataDidUpdate()
    func shouldUpdateDateCells()
}

final class AnalysisViewModel {
    var selectedDirection: Direction = .outcome {
        didSet {
            filterTransactions()
            delegate?.dataDidUpdate()
        }
    }
    var totalAmount: Decimal = 0
    var allTransactions: [Transaction] = []
    var displayedTransactions: [Transaction] = []
    var categories: [Category] = []
    private(set) var categorySummaries: [CategorySummary] = []
    var isLoading = false
    var error: Error?
    var sortType: SortType = .date
    
    var startDate: Date = {
        let calendar = Calendar.current
        let today = Date()
        let monthAgo = calendar.date(byAdding: .month, value: -1, to: today) ?? today
        let components = calendar.dateComponents([.year, .month, .day], from: monthAgo)
        return calendar.date(from: components) ?? today
    }()
    
    var endDate: Date = {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: Date())
        components.hour = 23
        components.minute = 59
        return calendar.date(from: components) ?? Date()
    }()
    
    weak var delegate: AnalysisViewModelDelegate?
    private let transactionsService: TransactionsService
    private let categoriesService: CategoriesService
    
    init(transactionsService: TransactionsService, categoriesService: CategoriesService, selectedDirection: Direction) {
        self.transactionsService = transactionsService
        self.categoriesService = categoriesService
        self.selectedDirection = selectedDirection
    }
    
    @MainActor
    func loadData() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            async let transactionsTask = transactionsService.getTransactions(for: DateInterval(start: startDate, end: endDate))
            async let categoriesTask = categoriesService.categories()
            
            let (transactions, categories) = try await (transactionsTask, categoriesTask)
            
            self.allTransactions = transactions
            self.categories = categories
            self.displayedTransactions = transactions
            filterTransactions()
            self.totalAmount = calculateTotalAmount()
        } catch {
            self.error = error
            os_log("Ошибка загрузки: %@", log: .default, type: .error, error.localizedDescription)
        }
    }
    
    func category(for transaction: Transaction) -> Category? {
        categories.first { $0.id == transaction.categoryId }
    }
    
    private func filterTransactions() {
        displayedTransactions = allTransactions.filter { transaction in
            guard let category = category(for: transaction) else { return false }
            return category.direction == selectedDirection
        }
        totalAmount = calculateTotalAmount()
        
        let grouped = Dictionary(grouping: displayedTransactions) { $0.categoryId }
            .compactMapValues { transactions -> CategorySummary? in
                guard let categoryId = transactions.first?.categoryId,
                      let category = categories.first(where: { $0.id == categoryId }),
                      !transactions.isEmpty else { return nil }
                
                let categoryTotal = transactions.reduce(0) { $0 + $1.amount }
                let percentage = totalAmount > 0 ?
                Int(Double(truncating: (categoryTotal / totalAmount * 100) as NSNumber).rounded(toPlaces: 0)) : 0
                
                return CategorySummary(
                    category: category,
                    totalAmount: categoryTotal,
                    percentage: percentage,
                    transactions: transactions
                )
            }
        
        categorySummaries = Array(grouped.values)
    }
    
    private func calculateTotalAmount() -> Decimal {
        displayedTransactions.reduce(0) { $0 + $1.amount }
    }
    
    func sortCategories(sortType: SortType) {
        switch sortType {
        case .date:
            // Непонятно как сортировать сумманые категории по времени
            categorySummaries
        case .amount:
            categorySummaries.sort { $0.totalAmount > $1.totalAmount }
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
                delegate?.shouldUpdateDateCells()
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
                delegate?.shouldUpdateDateCells()
            }
        }
        
        delegate?.dataDidUpdate()
    }
}
