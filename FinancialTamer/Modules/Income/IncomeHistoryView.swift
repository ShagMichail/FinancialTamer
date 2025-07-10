//
//  IncomeHistoryView.swift
//  FinancialTamer
//
//  Created by Михаил Шаговитов on 18.06.2025.
//

import SwiftUI

struct IncomeHistoryView: View {
    @StateObject private var viewModel: MyHistoryViewModel
    private var analysisViewModel: AnalysisViewModel
    
    init() {
        let transactionsService = TransactionsService()
        let categoriesService = CategoriesService()
        _viewModel = StateObject(
            wrappedValue: MyHistoryViewModel(
                transactionsService: transactionsService,
                categoriesService: categoriesService,
                selectedDirection: .income
            )
        )
        analysisViewModel = AnalysisViewModel(transactionsService: transactionsService, categoriesService: categoriesService, selectedDirection: .income)
    }
    
    var body: some View {
        MyHistoryView(viewModel: viewModel, analysisViewModel: analysisViewModel)
    }
}

#Preview {
    IncomeHistoryView()
}
