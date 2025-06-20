//
//  ExpensesView.swift
//  FinancialTamer
//
//  Created by Михаил Шаговитов on 17.06.2025.
//

import SwiftUI

struct ExpensesView: View {
    @StateObject private var viewModel: TransactionsViewModel
    
    let transactionsService = TransactionsService()
    let categoriesService = CategoriesService()
    
    init() {
        let transactionsService = TransactionsService()
        let categoriesService = CategoriesService()
        _viewModel = StateObject(
            wrappedValue: TransactionsViewModel(
                transactionsService: transactionsService,
                categoriesService: categoriesService,
                selectedDirection: .outcome
            )
        )
    }

    var body: some View {
        NavigationStack {
            ZStack {
                TransactionsListView(
                    viewModel: viewModel,
                    title: "Расходы сегодня"
                )
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink {
                            ExpensesHistoryView()
                            
                        } label: {
                            Image("time")
                                .resizable()
                                .frame(width: 22, height: 22)
                                .foregroundStyle(Color.navigation)
                        }
                    }
                }
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        NavigationLink {
                            NewExpensesView()
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 28).frame(width: 56, height: 56)
                                    .foregroundStyle(.accent)
                                Image(systemName: "plus")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundStyle(.white)
                            }
                        }.padding(.trailing, 16)
                    }.padding(.bottom, 28)
                }
            }
            
        }
    }
}

#Preview {
    ExpensesView()
}
