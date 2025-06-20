//
//  NumberFormatter+Extensions.swift
//  FinancialTamer
//
//  Created by Михаил Шаговитов on 18.06.2025.
//

import Foundation

extension NumberFormatter {
    static let currency: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "₽"
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        return formatter
    }()
}
