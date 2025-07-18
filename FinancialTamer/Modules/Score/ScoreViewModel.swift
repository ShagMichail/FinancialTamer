//
//  ScoreViewModel.swift
//  FinancialTamer
//
//  Created by Михаил Шаговитов on 26.06.2025.
//

import Foundation

enum Currency {
    case ruble
    case dollar
    case euro
    
    var symbol: String {
        switch self {
        case .ruble: return "₽"
        case .dollar: return "$"
        case .euro: return "€"
        }
    }
}

@MainActor
final class ScoreViewModel: ObservableObject {
    @Published var displayBalance: String = "0"
    @Published var errorMessage: String? = nil
    @Published var isLoading: Bool = false
    @Published var selectedCurrency: Currency = .ruble {
        didSet {
            updateDisplayBalance()
        }
    }
    
    private let exchangeRates: [Currency: Double] = [
        .ruble: 1.0,
        .dollar: 90.0,
        .euro: 100.0
    ]
    private var bankAccount: BankAccount? = nil
    private var baseBalance: Double = 0
    
    init() {
        Task { await self.loadBalance() }
    }
    
    func loadBalance() async {
        isLoading = true
        do {
            bankAccount = try await BankAccountsService.shared.getAccount()
            guard let baseBalance = Double(bankAccount?.balance ?? "0") else { return }
            self.baseBalance = baseBalance
            self.updateDisplayBalance()
        } catch {
            baseBalance = 0
        }
        
        isLoading = false
    }
    
    private func updateDisplayBalance() {
        let rate = exchangeRates[selectedCurrency] ?? 1.0
        let convertedValue = baseBalance / rate
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        
        displayBalance = formatter.string(from: NSNumber(value: convertedValue)) ?? "\(convertedValue)"
    }
    
    func setBalance(_ newValue: String) async {
        guard var account = bankAccount else {
            errorMessage = "Аккаунт не найден"
            return
        }
        
        let normalizedBalance = newValue
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "\u{00A0}", with: "")
            .replacingOccurrences(of: ",", with: ".")
        
        guard let balance = Decimal(string: normalizedBalance) else {
            errorMessage = "Некорректный баланс"
            return
        }
        
        account.balance = normalizedBalance
        account.currency = selectedCurrency.symbol
        
        do {
            try await BankAccountsService.shared.updateAccount(account)
            let updatedAccount = account
            await MainActor.run {
                self.bankAccount = updatedAccount
            }
            updateDisplayBalance()
        } catch {
            let errorText = error.localizedDescription
            await MainActor.run {
                errorMessage = errorText
            }
        }
    }
}
