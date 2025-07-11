//
//  CreateTransactionView.swift
//  FinancialTamer
//
//  Created by Михаил Шаговитов on 11.07.2025.
//

import SwiftUI

struct CreateTransactionView: View {
    @StateObject var viewModel: CreateTransactionViewModel
    let onSave: (() -> Void)?

    @State var amount: String = ""
    @State private var date: Date = Date()
    @State private var selectedCategory: Category? = nil
    @State private var comment: String = ""
    @State private var showAlert = false
    @State private var isLoading = false
    
    @FocusState private var isAmountFocused: Bool
    @State private var showDatePicker = false
    @State private var showTimePicker = false

    var filteredCategories: [Category] {
        viewModel.categories.filter { $0.direction == viewModel.direction }
    }

    var isEdit: Bool { viewModel.transactionToEdit != nil }
    
    var navTitle: String {
        viewModel.direction == .income ? "Мои доходы" : "Мои расходы"
    }
    var deleteButtonTitle: String {
        viewModel.direction == .income ? "Удалить доход" : "Удалить расход"
    }
    
    @FocusState private var isCommentFocused: Bool
    
    var formattedDate: String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "ru_RU")
        df.dateFormat = "d MMMM"
        return df.string(from: date)
    }
    var formattedTime: String {
        let tf = DateFormatter()
        tf.locale = Locale(identifier: "ru_RU")
        tf.dateFormat = "HH:mm"
        return tf.string(from: date)
    }

    var body: some View {
        NavigationView {
            List {
                Section {} header: {
                    Text(navTitle)
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(.black)
                        .padding(.bottom, -8)
                        .textCase(nil)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                }
                
                HStack {
                    Text("Статья")
                        .foregroundColor(.primary)
                    Spacer()
                    ZStack {
                        HStack(spacing: 16) {
                            Text(viewModel.selectedCategory?.name ?? "")
                                .foregroundColor(.gray)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 15))
                                .foregroundColor(.gray)
                        }
                        
                        Picker("", selection: $viewModel.selectedCategory) {
                            ForEach(viewModel.filteredCategories, id: \.name) { category in
                                Text(category.name).tag(Optional(category))
                            }
                        }
                        .labelsHidden()
                        .opacity(0)
                        .contentShape(Rectangle())
                    }
                }
                
                HStack {
                    Text("Сумма")
                    Spacer()
                    ZStack(alignment: .trailing) {
                        if viewModel.amount.isEmpty {
                            Text("0 ₽")
                                .foregroundColor(.gray)
                        } else {
                            Text(viewModel.amount)
                                .foregroundColor(.gray)
                        }
                        TextField("", text: $viewModel.amount)
                            .keyboardType(.decimalPad)
                            .focused($isAmountFocused)
                            .foregroundColor(.clear)
                            .multilineTextAlignment(.trailing)
                            .onChange(of: viewModel.amount) { _, newValue in
                                var filtered = newValue.filter { "0123456789, ".contains($0) }
                                let components = filtered.components(separatedBy: ",")
                                if components.count > 2 {
                                    filtered = components[0] + "," + components[1]
                                }
                                if components.count == 2, let fractional = components.last {
                                    let limitedFractional = String(fractional.prefix(2))
                                    filtered = components[0] + "," + limitedFractional
                                }
                                if filtered != newValue {
                                    viewModel.amount = filtered
                                }
                            }
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture { isAmountFocused = true }
                
                HStack {
                    Text("Дата")
                    Spacer()
                    HStack(spacing: 2) {
                        Text(date.formatted(.dateTime.day().month().year()))
                            .font(.system(size: 17, weight: .regular))
                    }
                    .padding(.horizontal, 12)
                    .foregroundColor(.black)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .foregroundColor(.accent)
                            .opacity(0.5)
                            .padding(.vertical, -7)
                    )
                    .overlay {
                        DatePicker(selection: $date, in: ...Date(), displayedComponents: .date) {}
                            .labelsHidden()
                            .colorMultiply(.clear)
                    }
                }
                
                HStack {
                    Text("Время")
                    Spacer()
                    CustomPickerTimeView(date: $date)
                }
                TextField("Комментарий", text: $viewModel.comment)
                    .foregroundColor(.primary)
                    .keyboardType(.default)
                    .focused($isCommentFocused)
                    .onTapGesture { isCommentFocused = true }
                
                Section {
                    if isEdit {
                        Button(deleteButtonTitle) {
                            viewModel.delete(onDelete: {
                                onSave?()
                            })
                        }
                        .foregroundColor(.red)
                        .disabled(isLoading)
                    }
                }
                .listSectionSpacing(50)
            }
            .scrollDismissesKeyboard(.immediately)
            .listStyle(.insetGrouped)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        onSave?()
                    }
                    .tint(.navigation)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEdit ? "Сохранить" : "Создать") {
                        if isEdit {
                            viewModel.save(onSave: onSave ?? {})
                        } else {
                            viewModel.create(onSave: onSave ?? {})
                        }
                    }
                    .tint(.navigation)
                    .fontWeight(.regular)
                    .disabled(viewModel.isLoading)
                }
            }
            .alert(isPresented: $viewModel.showAlert) {
                Alert(title: Text("Ошибка"), message: Text("Пожалуйста, заполните все поля корректно"), dismissButton: .default(Text("Ок")))
            }
            .onAppear {
                if let transaction = viewModel.transactionToEdit {
                    amount = NumberFormatter.currency.string(from: NSDecimalNumber(decimal: transaction.amount)) ?? ""
                    date = transaction.transactionDate
                    selectedCategory = viewModel.categories.first(where: { $0.id == transaction.categoryId })
                    comment = transaction.comment
                }
            }
        }
    }
}
