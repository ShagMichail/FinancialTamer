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
    private var baseBalance: Double = 0
    
    init() {
        Task { await self.loadBalance() }
    }
    
    func loadBalance() async {
        isLoading = true
        do {
            try await Task.sleep(nanoseconds: 2_000_000_000)
            let mockBalance = 140000.0
            baseBalance = mockBalance
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
    
    func setBalance(_ newValue: String) {
        if let newBalance = Double(newValue) {
            let rate = exchangeRates[selectedCurrency] ?? 1.0
            baseBalance = newBalance * rate
            updateDisplayBalance()
        }
    }
}
