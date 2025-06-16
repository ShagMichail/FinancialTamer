//
//  TransactionsFileCache.swift
//  FinancialTamer
//
//  Created by Михаил Шаговитов on 12.06.2025.
//

import Foundation
import os.log

final class TransactionsFileCache {

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
                os_log("Transactions saved successfully to %@", log: .default, type: .info, self.fileURL.path)
            } catch {
                os_log("Failed to save transactions: %@", log: .default, type: .error, error.localizedDescription)
            }
        }
    }
    
    func loadTransactions() {
        queue.async(flags: .barrier) {
            guard FileManager.default.fileExists(atPath: self.fileURL.path) else {
                os_log("No existing file at %@", log: .default, type: .error, self.fileURL.path)
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
                os_log("Loaded %d transactions from %@", log: .default, type: .info, self.transactions.count, self.fileURL.path)
            } catch {
                os_log("Failed to load transactions: %@", log: .default, type: .error, error.localizedDescription)
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
