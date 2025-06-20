//
//  NewExpensesView.swift
//  FinancialTamer
//
//  Created by Михаил Шаговитов on 19.06.2025.
//

import SwiftUI

struct NewExpensesView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Text("Hello, NewExpensesView!")
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
                    Button(action: {  }) {
                        Text("Сохранить")
                            .tint(Color.navigation)
                    }
                }
            }
    }
}

#Preview {
    NewExpensesView()
}
