//
//  ExpensesHistoryView.swift
//  FinancialTamer
//
//  Created by Михаил Шаговитов on 18.06.2025.
//

import SwiftUI

struct ExpensesHistoryView: View {
    @StateObject private var viewModel: MyHistoryViewModel
    
    init() {
        let transactionsService = TransactionsService()
        let categoriesService = CategoriesService()
        _viewModel = StateObject(
            wrappedValue: MyHistoryViewModel(
                transactionsService: transactionsService,
                categoriesService: categoriesService,
                selectedDirection: .outcome
            )
        )
    }
    
    var body: some View {
        MyHistoryView(viewModel: viewModel)
    }
}

#Preview {
    ExpensesHistoryView()
}
