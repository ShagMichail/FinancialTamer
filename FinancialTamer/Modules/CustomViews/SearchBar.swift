//
//  SearchBar.swift
//  FinancialTamer
//
//  Created by Михаил Шаговитов on 05.07.2025.
//

import SwiftUI

struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Color(.systemGray))
            ZStack(alignment: .leading) {
                    if text.isEmpty {
                        Text("Search")
                            .foregroundColor(Color(.systemGray))
                    }
                    TextField("", text: $text)
                        .foregroundColor(.primary)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
        }
        .padding(8)
        .background(Color(.systemGray5))
        .cornerRadius(10)
    }
}
