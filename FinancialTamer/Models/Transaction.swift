//
//  Transaction.swift
//  FinancialTamer
//
//  Created by Михаил Шаговитов on 12.06.2025.
//

import Foundation

struct Transaction {
    let id: Int
    let accountId: Int
    let categoryId: Int
    let amount: Decimal
    let transactionDate: Date
    let comment: String
    let createdAt: Date
    let updatedAt: Date
}

// MARK: - parse


extension Transaction {
    
    static func parse(jsonObject: Any) -> Transaction? {
        guard let json = jsonObject as? [String: Any] else {
            return nil
        }
        
        guard let id = json["id"] as? Int,
              let accountId = json["accountId"] as? Int,
              let categoryId = json["categoryId"] as? Int else {
            return nil
        }
        
        guard let amountString = json["amount"] as? String,
              let amount = Decimal(string: amountString) else {
            return nil
        }
        
        let dateFormatter = ISO8601DateFormatter()
        
        guard let transactionDateString = json["transactionDate"] as? String,
              let transactionDate = dateFormatter.date(from: transactionDateString),
              let createdAtString = json["createdAt"] as? String,
              let createdAt = dateFormatter.date(from: createdAtString),
              let updatedAtString = json["updatedAt"] as? String,
              let updatedAt = dateFormatter.date(from: updatedAtString) else {
            return nil
        }
        
        let comment = json["comment"] as? String ?? ""
        
        return Transaction(
            id: id,
            accountId: accountId,
            categoryId: categoryId,
            amount: amount,
            transactionDate: transactionDate,
            comment: comment,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
    
    var jsonObject: Any {
        let dateFormatter = ISO8601DateFormatter()
        
        let json: [String: Any] = [
            "id": id,
            "accountId": accountId,
            "categoryId": categoryId,
            "amount": amount.description,
            "transactionDate": dateFormatter.string(from: transactionDate),
            "comment": comment,
            "createdAt": dateFormatter.string(from: createdAt),
            "updatedAt": dateFormatter.string(from: updatedAt)
        ]
        
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            return try JSONSerialization.jsonObject(with: data, options: [])
        } catch {
            return json
        }
    }
}

// MARK: - CSV Support


extension Transaction {
    
    private static let csvDateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
    
    private static var csvHeaders: String {
        return [
            "id",
            "accountId",
            "categoryId",
            "amount",
            "transactionDate",
            "comment",
            "createdAt",
            "updatedAt"
        ].joined(separator: ",")
    }
    
    var csvString: String {
        let fields = [
            String(id),
            String(accountId),
            String(categoryId),
            amount.description,
            Self.csvDateFormatter.string(from: transactionDate),
            escapeCSVField(comment),
            Self.csvDateFormatter.string(from: createdAt),
            Self.csvDateFormatter.string(from: updatedAt)
        ]
        
        return fields.joined(separator: ",")
    }
    
    private func escapeCSVField(_ field: String) -> String {
        if field.contains(",") || field.contains("\"") || field.contains("\n") {
            let escaped = field.replacingOccurrences(of: "\"", with: "\"\"")
            return "\"\(escaped)\""
        }
        return field
    }
    
    static func parse(csvString: String) -> Transaction? {
        let scanner = Scanner(string: csvString)
        scanner.charactersToBeSkipped = .whitespaces
        
        var fields = [String]()
        var currentField = ""
        var inQuotes = false
        
        while !scanner.isAtEnd {
            if let text = scanner.scanUpToString("\"") {
                currentField += text
            }
            
            if scanner.scanString("\"") != nil {
                if inQuotes {
                    inQuotes = false
                    if scanner.scanString("\"") != nil {
                        currentField += "\""
                        inQuotes = true
                    }
                } else {
                    inQuotes = true
                }
            }
            
            if !inQuotes && scanner.scanString(",") != nil {
                fields.append(currentField)
                currentField = ""
            }
        }
        
        fields.append(currentField)
        
        guard fields.count >= 8 else { return nil }
        
        guard let id = Int(fields[0]),
              let accountId = Int(fields[1]),
              let categoryId = Int(fields[2]),
              let amount = Decimal(string: fields[3]),
              let transactionDate = csvDateFormatter.date(from: fields[4]),
              let createdAt = csvDateFormatter.date(from: fields[6]),
              let updatedAt = csvDateFormatter.date(from: fields[7]) else {
            return nil
        }
        
        let comment = fields[5]
        
        return Transaction(
            id: id,
            accountId: accountId,
            categoryId: categoryId,
            amount: amount,
            transactionDate: transactionDate,
            comment: comment,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
    
    static func generateCSV(from transactions: [Transaction]) -> String {
        var csvLines = [csvHeaders]
        csvLines += transactions.map { $0.csvString }
        return csvLines.joined(separator: "\n")
    }
    
    static func parseCSVFile(_ csvContent: String) -> [Transaction] {
        let lines = csvContent.components(separatedBy: .newlines)
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        
        guard !lines.isEmpty else { return [] }
        
        let startIndex = lines[0] == csvHeaders ? 1 : 0
        
        return lines[startIndex...].compactMap { line in
            parse(csvString: line)
        }
    }
}
