//
//  Double+Extensions.swift
//  FinancialTamer
//
//  Created by Михаил Шаговитов on 11.07.2025.
//

import Foundation

extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
