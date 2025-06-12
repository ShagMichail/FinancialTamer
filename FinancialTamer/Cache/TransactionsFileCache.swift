//
//  TransactionsFileCache.swift
//  FinancialTamer
//
//  Created by Михаил Шаговитов on 12.06.2025.
//

import Foundation

class TransactionsFileCache {

    private(set) var transactions: [Transaction] = []
    private let fileURL: URL
    private let queue = DispatchQueue(label: "com.transactions.filecache.queue", attributes: .concurrent)

    init(filename: String) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.fileURL = documentsDirectory.appendingPathComponent(filename)
        loadTransactions()
    }
    
    func addTransaction(_ transaction: Transaction) {
        queue.async(flags: .barrier) {
            guard !self.transactions.contains(where: { $0.id == transaction.id }) else {
                print("Transaction with ID \(transaction.id) already exists")
                return
            }
            
            self.transactions.append(transaction)
            self.saveTransactions()
        }
    }
    
    func removeTransaction(withId id: Int) {
        queue.async(flags: .barrier) {
            self.transactions.removeAll { $0.id == id }
            self.saveTransactions()
        }
    }
    
    func saveTransactions() {
        queue.async(flags: .barrier) {
            let transactionsJSON = self.transactions.map { $0.jsonObject }
            
            do {
                let data = try JSONSerialization.data(withJSONObject: transactionsJSON, options: [.prettyPrinted])
                try data.write(to: self.fileURL)
                print("Transactions saved successfully to \(self.fileURL.path)")
            } catch {
                print("Failed to save transactions: \(error.localizedDescription)")
            }
        }
    }
    
    func loadTransactions() {
        queue.async(flags: .barrier) {
            guard FileManager.default.fileExists(atPath: self.fileURL.path) else {
                print("No existing file at \(self.fileURL.path)")
                return
            }
            
            do {
                let data = try Data(contentsOf: self.fileURL)
                let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [Any] ?? []
                
                var loadedTransactions: [Transaction] = []
                for json in jsonArray {
                    if let transaction = Transaction.parse(jsonObject: json) {
                        loadedTransactions.append(transaction)
                    }
                }
                
                var uniqueTransactions: [Int: Transaction] = [:]
                for transaction in loadedTransactions {
                    uniqueTransactions[transaction.id] = transaction
                }
                
                self.transactions = Array(uniqueTransactions.values)
                print("Loaded \(self.transactions.count) transactions from \(self.fileURL.path)")
            } catch {
                print("Failed to load transactions: \(error.localizedDescription)")
            }
        }
    }

    func getTransaction(withId id: Int) -> Transaction? {
        return queue.sync {
            return transactions.first { $0.id == id }
        }
    }
    
    func clearCache() {
        queue.async(flags: .barrier) {
            self.transactions.removeAll()
            try? FileManager.default.removeItem(at: self.fileURL)
        }
    }
}
