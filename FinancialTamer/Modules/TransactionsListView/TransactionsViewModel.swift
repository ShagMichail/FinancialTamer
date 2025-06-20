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
    @Published var transactions: [Transaction] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let service: TransactionsService
    
    var totalAmountToday: String {
        let todayInterval = Date.todayInterval()
        let todayTransactions = transactions.filter { todayInterval.contains($0.transactionDate) }
        let total = todayTransactions.reduce(0) { $0 + $1.amount }
        return NumberFormatter.currency.string(from: NSDecimalNumber(decimal: total)) ?? "0 ₽"
    }
    
    init(service: TransactionsService) {
        self.service = service
    }
    
    func loadTransactions() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let todayInterval = Date.todayInterval()
            transactions = try await service.getTransactions(for: todayInterval)
        } catch {
            self.error = error
            os_log("Ошибка загрузки транзакций: %@", log: .default, type: .error, error.localizedDescription)
        }
    }
    
    func createTransaction(_ transaction: Transaction) async {
        do {
            try await service.createTransaction(transaction)
            await loadTransactions()
        } catch {
            self.error = error
            os_log("Ошибка создания транзакции: %@", log: .default, type: .error, error.localizedDescription)
        }
    }
    
    func deleteTransaction(withId id: Int) async {
        do {
            try await service.deleteTransaction(withId: id)
            await loadTransactions()
        } catch {
            self.error = error
            os_log("Ошибка удаления транзакции: %@", log: .default, type: .error, error.localizedDescription)
        }
    }
}
