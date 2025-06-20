//
//  MyHistoryView.swift
//  FinancialTamer
//
//  Created by Михаил Шаговитов on 18.06.2025.
//

import SwiftUI

enum TypeDate {
    case start
    case end
}

struct MyHistoryView: View {
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject private var viewModel: MyHistoryViewModel
    
    @State private var startDate: Date = {
        let calendar = Calendar.current
        let today = Date()
        let monthAgo = calendar.date(byAdding: .month, value: -1, to: today) ?? today
        let components = calendar.dateComponents([.year, .month, .day], from: monthAgo)
        return calendar.date(from: components) ?? today
    }()
    
    @State private var endDate: Date = {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: Date())
        components.hour = 23
        components.minute = 59
        return calendar.date(from: components) ?? Date()
    }()
    
    init(viewModel: MyHistoryViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        List {
            Section {
                HStack {
                    Text("Начало")
                    Spacer()
                    CustomPickerView(date: $startDate)
                }
                .onChange(of: startDate) { oldValue, newValue in
                    changeDate(newValue: newValue, typeDate: .start)
                    Task { await viewModel.loadData(from: startDate, to: endDate) }
                }
                
                HStack {
                    Text("Конец")
                    Spacer()
                    CustomPickerView(date: $endDate)
                }
                .onChange(of: endDate) { oldValue, newValue in
                    changeDate(newValue: newValue, typeDate: .end)
                    Task { await viewModel.loadData(from: startDate, to: endDate) }
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
            await viewModel.loadData(from: startDate, to: endDate)
        }
    }
    
    private func changeDate(newValue: Date, typeDate: TypeDate) {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: newValue)
        
        switch typeDate {
        case .start:
            components.hour = 00
            components.minute = 00
            startDate = calendar.date(from: components) ?? newValue
            if startDate > endDate {
                var endComponents = calendar.dateComponents([.year, .month, .day], from: newValue)
                endComponents.hour = 23
                endComponents.minute = 59
                endDate = calendar.date(from: endComponents) ?? newValue
            }
        case .end:
            components.hour = 23
            components.minute = 59
            endDate = calendar.date(from: components) ?? newValue
            if endDate < startDate {
                var startComponents = calendar.dateComponents([.year, .month, .day], from: newValue)
                startComponents.hour = 00
                startComponents.minute = 00
                startDate = calendar.date(from: startComponents) ?? newValue
            }
        }
    }
}

#Preview {
    MyHistoryView(viewModel: MyHistoryViewModel(transactionsService: TransactionsService(), categoriesService: CategoriesService(), selectedDirection: .outcome))
}
