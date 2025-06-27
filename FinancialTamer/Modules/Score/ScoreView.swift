//
//  ScoreView.swift
//  FinancialTamer
//
//  Created by Михаил Шаговитов on 17.06.2025.
//

import SwiftUI

enum StateScreen {
    case edit
    case save
}

struct ScoreView: View {
    @StateObject private var viewModel: ScoreViewModel
    @FocusState private var isFocused: Bool

    @State private var stateScreen: StateScreen = .edit
    @State private var isEditing = false
    @State private var tempBalance = ""
    @State private var spoilerVisible = true
    @State private var showCurrencyPicker = false
    
    private var currentState: String {
        switch stateScreen {
        case .edit:
            return "Редактировать"
        case .save:
            return "Сохранить"
        }
    }
    
    init() {
        _viewModel = StateObject(
            wrappedValue: ScoreViewModel()
        )
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button {
                        if stateScreen != .edit {
                            tempBalance = viewModel.displayBalance
                            isEditing = true
                            isFocused = true
                            spoilerVisible = false
                        }
                    } label: {
                        HStack {
                            Text("💰")
                                .frame(width: 22, height: 22)
                                .padding(.trailing, 16)
                            
                            Text("Баланс")
                                .font(.system(size: 17, weight: .regular))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundStyle(.black)
                                .padding(.vertical, 10)
                            
                            if isEditing {
                                TextField("", text: $tempBalance)
                                    .keyboardType(.asciiCapableNumberPad)
                                    .focused($isFocused)
                                    .font(.system(size: 17, weight: .regular))
                                    .multilineTextAlignment(.trailing)
                                
                            } else {
                                Text(viewModel.displayBalance)
                                    .font(.system(size: 17, weight: .regular))
                                    .foregroundStyle(Color.black.opacity(stateScreen == .edit ? 1 : 0.5))
                                    .spoiler(isOn: $spoilerVisible)
                            }
                        }
                        .frame(maxWidth: .infinity, idealHeight: 35)
                    }
                    .disabled(stateScreen == .edit ? true : false)
                    .listRowBackground(stateScreen == .edit ? Color.accentColor : Color.white)
                    .onChange(of: isFocused) { _, focused in
                        if !focused && isEditing {
                            viewModel.setBalance(tempBalance)
                            isEditing = false
                        }
                    }
                } header: {
                    Text("Мой счет")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(.black)
                        .padding(.bottom, 16)
                        .textCase(nil)
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .listRowBackground(Color.clear)
                }
                
                Section {
                    Button {
                        if stateScreen != .edit {
                            showCurrencyPicker = true
                        }
                    } label: {
                        HStack {
                            Text("Валюта")
                                .font(.system(size: 17, weight: .regular))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundStyle(.black)
                                .padding(.vertical, 10)
                            
                            Text(viewModel.selectedCurrency.symbol)
                                .font(.system(size: 17, weight: .regular))
                                .foregroundStyle(Color.black.opacity(stateScreen == .edit ? 1 : 0.5))
                            
                            if stateScreen == .save {
                                Image(systemName: "chevron.right")
                                    .resizable()
                                    .frame(width: 6, height: 10)
                                    .foregroundStyle(.gray)
                            }
                        }
                        .frame(maxWidth: .infinity, idealHeight: 35)
                    }
                    .disabled(stateScreen == .edit ? true : false)
                    .listRowBackground(stateScreen == .edit ? Color.accentColor.opacity(0.3) : Color.white)
                    .confirmationDialog(
                        "Валюта",
                        isPresented: $showCurrencyPicker,
                        titleVisibility: .visible
                    ) {
                        Button("Российский рубль ₽") { viewModel.selectedCurrency = .ruble }
                        Button("Американский доллар $") { viewModel.selectedCurrency = .dollar }
                        Button("Евро €") { viewModel.selectedCurrency = .euro }
                    }
                }
            }
            .scrollDismissesKeyboard(.immediately)
            .listSectionSpacing(20)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        stateScreen = stateScreen == .edit ? .save : .edit
                        if stateScreen == .save {
                            spoilerVisible = false
                        }
                    } label: {
                        Text(currentState)
                            .foregroundStyle(Color.navigation)
                            .animation(nil, value: currentState)
                    }
                }
                
            }
            .refreshable {
                await viewModel.loadBalance()
            }
            .onShake {
                if stateScreen == .edit {
                    spoilerVisible.toggle()
                }
            }
        }
    }
}

#Preview {
    ScoreView()
}
