//
//  ArticlesView.swift
//  FinancialTamer
//
//  Created by Михаил Шаговитов on 17.06.2025.
//

import SwiftUI

struct ArticlesView: View {
    @StateObject private var viewModel: ArticlesViewModel
    
    init() {
        _viewModel = StateObject(
            wrappedValue: ArticlesViewModel()
        )
    }
    
    var body: some View {
        NavigationStack() {
            List {
                Section {
                    SearchBar(text: $viewModel.searchText)
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .listRowBackground(Color.clear)
                        .padding(.bottom, 8)
                } header: {
                    Text("Мои статьи")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(.black)
                        .padding(.bottom, 8)
                        .textCase(nil)
                        .listRowInsets(EdgeInsets(top: 40, leading: 0, bottom: 0, trailing: 0))
                        .listRowBackground(Color.clear)
                }
                
                Section {
                    ForEach(viewModel.filteredCategories, id: \.self) { category in
                        VStack(spacing: 0) {
                            ListRowView(
                                emoji: String(category.emoji),
                                categoryName: category.name,
                                needChevron: false
                            )
                        }
                        .listRowInsets(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                    }
                    
                } header: {
                    Text("Статьи")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.secondary)
                        .padding(.top, 16)
                }
            }
            .listSectionSpacing(-20)
            .scrollIndicators(.hidden)
            .task {
                await viewModel.loadCategories()
            }
            .refreshable {
                await viewModel.loadCategories()
            }
        }
    }
}

#Preview {
    ArticlesView()
}
