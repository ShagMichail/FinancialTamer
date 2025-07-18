//
//  View+Extensions.swift
//  FinancialTamer
//
//  Created by Михаил Шаговитов on 26.06.2025.
//

import SwiftUI


extension View {
    func spoiler(isOn: Binding<Bool>) -> some View {
        self
            .opacity(isOn.wrappedValue ? 0 : 1)
            .modifier(SpoilerModifier(isOn: isOn.wrappedValue))
            .animation(.default, value: isOn.wrappedValue)
    }
}

extension View {
    func onShake(perform action: @escaping () -> Void) -> some View {
        self.modifier(ShakeDetector(onShake: action))
    }
}

extension View {
    func errorAlert(errorMessage: Binding<String?>) -> some View {
        alert(isPresented: Binding(
            get: { errorMessage.wrappedValue != nil },
            set: { if !$0 { errorMessage.wrappedValue = nil } }
        )) {
            Alert(
                title: Text("Ошибка"),
                message: Text(errorMessage.wrappedValue ?? ""),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}
