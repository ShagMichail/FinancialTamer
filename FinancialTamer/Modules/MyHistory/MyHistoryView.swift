//
//  MyHistoryView.swift
//  FinancialTamer
//
//  Created by Михаил Шаговитов on 18.06.2025.
//

import SwiftUI

struct MyHistoryView: View {
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject private var viewModel: MyHistoryViewModel
    
    init(viewModel: MyHistoryViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        List {
            Section {
                HStack {
                    Text("Начало")
                    Spacer()
                    CustomPickerView(date: $viewModel.startDate)
                }
                .onChange(of: viewModel.startDate) { _, newValue in
                    viewModel.changeDate(newValue: newValue, typeDate: .start)
                    Task { await viewModel.loadData() }
                }
                
                HStack {
                    Text("Конец")
                    Spacer()
                    CustomPickerView(date: $viewModel.endDate)
                }
                .onChange(of: viewModel.endDate) { _, newValue in
                    viewModel.changeDate(newValue: newValue, typeDate: .end)
                    Task { await viewModel.loadData() }
                }
                
                HStack {
                    Text("Сортировка")
                    Spacer()
                    Picker("", selection: $viewModel.sortType) {
                        ForEach(SortType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 150)
                    .background(Color.accentColor.opacity(0.5))
                    .cornerRadius(8)
                }
                    
                ListRowView(
                    categoryName: "Сумма",
                    transactionAmount: NumberFormatter.currency.string(from: NSDecimalNumber(decimal: viewModel.totalAmount)) ?? "0 $",
                    needChevron: false
                )
            } header: {
                Text("Моя история")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(.black)
                    .padding(.bottom, 16)
                    .textCase(nil)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .listRowBackground(Color.clear)
            }
            
            Section {
                ForEach(Array(viewModel.sortedTransactions.enumerated()), id: \.element.id) { index, transaction in
                    
                    let category = viewModel.category(for: transaction)
                    
                    VStack(spacing: 0) {
                        ListRowView(
                            emoji: category.map { String($0.emoji) } ?? "❓",
                            categoryName: category?.name ?? "Не известно",
                            transactionComment: transaction.comment.count != 0 ? transaction.comment : nil,
                            transactionAmount: NumberFormatter.currency.string(from: NSDecimalNumber(decimal: transaction.amount)) ?? "",
                            transactionDate: dateFormator(date: transaction.transactionDate),
                            needChevron: true
                        )
                    }
                    .listRowInsets(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                    .alignmentGuide(.listRowSeparatorLeading) { viewDimensions in
                        return viewDimensions[.listRowSeparatorLeading] + 46
                    }
                }
                
            } header: {
                Text("ОПЕРАЦИИ")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.secondary)
                    .padding(.top, 16)
                    .padding(.bottom, 8)
            }
        }
        .listSectionSpacing(0)
        .scrollIndicators(.hidden)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack {
                        Image(systemName: "chevron.backward")
                        Text("Назад")
                    }
                    .tint(Color.navigation)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    AnalysisView()
                } label: {
                    Image("document")
                        .resizable()
                        .frame(width: 22, height: 22)
                        .foregroundStyle(Color.navigation)
                }
            }
        }
        .task {
            await viewModel.loadData()
        }
    }

    private func dateFormator(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: date)
    }
}

#Preview {
    MyHistoryView(viewModel: MyHistoryViewModel(transactionsService: TransactionsService(), categoriesService: CategoriesService(), selectedDirection: .outcome))
}
