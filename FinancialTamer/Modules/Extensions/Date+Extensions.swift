//
//  Date+Extensions.swift
//  FinancialTamer
//
//  Created by Михаил Шаговитов on 18.06.2025.
//

import Foundation

extension Date {
    func startOfDay() -> Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    func endOfDay() -> Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay())!
    }
    
    static func todayInterval() -> DateInterval {
        let start = Date().startOfDay()
        let end = Date().endOfDay()
        return DateInterval(start: start, end: end)
    }
}
