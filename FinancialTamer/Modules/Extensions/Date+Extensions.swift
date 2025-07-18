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

extension Date {
    func convertToUTC() -> Date {
        let secondsFromGMT = TimeZone.current.secondsFromGMT(for: self)
        return self.addingTimeInterval(-TimeInterval(secondsFromGMT))
    }
    
    func convertFromUTCToLocal() -> Date {
        let timeZone = TimeZone.current
        let secondsFromGMT = timeZone.secondsFromGMT(for: self)
        return self.addingTimeInterval(TimeInterval(-secondsFromGMT))
    }
}

extension DateFormatter {
    static let withFractionalSeconds: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSXXXXX"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
}
