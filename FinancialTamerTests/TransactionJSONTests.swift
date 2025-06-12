//
//  File.swift
//  FinancialTamerTests
//
//  Created by Михаил Шаговитов on 12.06.2025.
//

import XCTest
@testable import FinancialTamer

class TransactionJSONTests: XCTestCase {
    
    // MARK: - Test Data
    
    private let validJSON: [String: Any] = [
        "id": 1,
        "accountId": 5,
        "categoryId": 10,
        "amount": "1250.50",
        "transactionDate": "2023-06-15T12:30:45Z",
        "comment": "Salary for June",
        "createdAt": "2023-06-15T10:00:00Z",
        "updatedAt": "2023-06-15T10:00:00Z"
    ]
    
    private let validTransaction = Transaction(
        id: 1,
        accountId: 5,
        categoryId: 10,
        amount: Decimal(1250.50),
        transactionDate: ISO8601DateFormatter().date(from: "2023-06-15T12:30:45Z")!,
        comment: "Salary for June",
        createdAt: ISO8601DateFormatter().date(from: "2023-06-15T10:00:00Z")!,
        updatedAt: ISO8601DateFormatter().date(from: "2023-06-15T10:00:00Z")!
    )
    
    // MARK: - parse(jsonObject:) Tests
    
    func testParseValidJSON() {
        let result = Transaction.parse(jsonObject: validJSON)
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.id, 1)
        XCTAssertEqual(result?.accountId, 5)
        XCTAssertEqual(result?.amount, Decimal(1250.50))
        XCTAssertEqual(result?.comment, "Salary for June")
    }
    
    func testParseMissingRequiredField() {
        var invalidJSON = validJSON
        invalidJSON.removeValue(forKey: "amount")
        
        let result = Transaction.parse(jsonObject: invalidJSON)
        XCTAssertNil(result)
    }
    
    func testParseInvalidAmountFormat() {
        var invalidJSON = validJSON
        invalidJSON["amount"] = "invalid_amount"
        
        let result = Transaction.parse(jsonObject: invalidJSON)
        XCTAssertNil(result)
    }
    
    func testParseInvalidDate() {
        var invalidJSON = validJSON
        invalidJSON["transactionDate"] = "invalid_date"
        
        let result = Transaction.parse(jsonObject: invalidJSON)
        XCTAssertNil(result)
    }
    
    func testParseEmptyComment() {
        var json = validJSON
        json["comment"] = ""
        
        let result = Transaction.parse(jsonObject: json)
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.comment, "")
    }
    
    func testParseMissingComment() {
        var json = validJSON
        json.removeValue(forKey: "comment")
        
        let result = Transaction.parse(jsonObject: json)
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.comment, "")
    }
    
    // MARK: - jsonObject Tests
    
    func testJsonObjectConversion() {
        let jsonObject = validTransaction.jsonObject
        
        guard let jsonDict = jsonObject as? [String: Any] else {
            XCTFail("Failed to convert to dictionary")
            return
        }
        
        XCTAssertEqual(jsonDict["id"] as? Int, 1)
        XCTAssertEqual(jsonDict["accountId"] as? Int, 5)
        XCTAssertEqual(jsonDict["amount"] as? String, "1250.5")
        XCTAssertEqual(jsonDict["comment"] as? String, "Salary for June")
        
        let dateFormatter = ISO8601DateFormatter()
        XCTAssertNotNil(dateFormatter.date(from: jsonDict["transactionDate"] as! String))
    }
    
    func testJsonObjectRoundTrip() {
        let jsonObject = validTransaction.jsonObject
        let parsedTransaction = Transaction.parse(jsonObject: jsonObject)
        
        XCTAssertNotNil(parsedTransaction)
        XCTAssertEqual(parsedTransaction?.id, validTransaction.id)
        XCTAssertEqual(parsedTransaction?.amount, validTransaction.amount)
        XCTAssertEqual(parsedTransaction?.comment, validTransaction.comment)
        
        if let parsedInterval = parsedTransaction?.transactionDate.timeIntervalSince1970 {
            XCTAssertEqual(
                parsedInterval,
                validTransaction.transactionDate.timeIntervalSince1970,
                accuracy: 1.0
            )
        } else {
            XCTFail("Parsed transaction date is nil")
        }
    }
    
    func testJsonObjectWithEmptyComment() {
        let transaction = Transaction(
            id: 2,
            accountId: 3,
            categoryId: 4,
            amount: Decimal(100),
            transactionDate: Date(),
            comment: "",
            createdAt: Date(),
            updatedAt: Date()
        )
        
        let jsonObject = transaction.jsonObject
        let parsedTransaction = Transaction.parse(jsonObject: jsonObject)
        
        XCTAssertNotNil(parsedTransaction)
        XCTAssertEqual(parsedTransaction?.comment, "")
    }
}
