//
//  CustomPickerTimeView.swift
//  FinancialTamer
//
//  Created by Михаил Шаговитов on 11.07.2025.
//

import SwiftUI

struct CustomPickerTimeView: View {
    @Binding var date: Date
    
    var body: some View {
        HStack(spacing: 2) {
            Text(date.formatted(.dateTime.hour().minute()))
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
            DatePicker(selection: $date, displayedComponents: .hourAndMinute) {}
                .labelsHidden()
                .colorMultiply(.clear)
        }
    }
}

