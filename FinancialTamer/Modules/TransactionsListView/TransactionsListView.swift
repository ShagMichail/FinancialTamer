//
//  TransactionsListView.swift
//  FinancialTamer
//
//  Created by Михаил Шаговитов on 17.06.2025.
//

import SwiftUI

//
struct RockGroup {
    var groupName: String
    var groupNameSubtitle: String?
    var groupImageName: String
    var cost: String
}

struct RockGroupData {
    static let data = [
        RockGroup(groupName: "The Jimi Hendrix", groupNameSubtitle: "sdfsdf", groupImageName: "articlesTab", cost: "100000 %"),
        RockGroup(groupName: "Led Zeppelin", groupImageName: "articlesTab", cost: "100000 %"),
        RockGroup(groupName: "Bob Dylan", groupNameSubtitle: "sdfsdf", groupImageName: "articlesTab", cost: "100000 %")
    ]
}



struct TransactionsListView: View {
    
//    var transactionsService: TransactionsService
//    var rockGroups = RockGroupData.data
    
    @StateObject private var viewModel: TransactionsViewModel
    
//    var transactions: [Transaction] = []
    
    init(service: TransactionsService) {
            _viewModel = StateObject(wrappedValue: TransactionsViewModel(service: service))
        }
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                // Секция "Расходы сегодня"
                VStack(alignment: .leading, spacing: 0) {
                    Text("Расходы сегодня")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(.black)
                        .padding(.bottom, 16)
                        .padding(.horizontal, 16)
                    
                    Spacer()
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Всего")
                                .font(.system(size: 17, weight: .regular))
                        }
                        Spacer()
                        Text(viewModel.totalAmountToday)
                            .font(.system(size: 17, weight: .regular))
                    }
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.white)
                            .padding(.horizontal, 16)
                    )
                }
                
                Spacer()
                
                Text("ОПЕРАЦИИ")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 32)
                    .padding(.top, 16)
                    .padding(.bottom, 8)
                
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(viewModel.transactions.indices, id: \.self) { index in
                        VStack(spacing: 0) {
                            TransactionsListRow(transaction: viewModel.transactions[index])
                            
                            if index != viewModel.transactions.count - 1 {
                                Divider()
                                    .padding(.leading, 72)
                                    .padding(.trailing, 16)
                            }
                        }
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.white)
                        .padding(.horizontal, 16)
                )
            }
        }
        .background(Color(.systemGroupedBackground))
        .task {
            await viewModel.loadTransactions()
        }
        .refreshable {
            await viewModel.loadTransactions()
        }
    }
}

#Preview {
//    TransactionsListView()
}
