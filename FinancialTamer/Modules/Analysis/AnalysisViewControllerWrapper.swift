//
//  File.swift
//  FinancialTamer
//
//  Created by Михаил Шаговитов on 09.07.2025.
//

import SwiftUI

struct AnalysisViewControllerWrapper: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    let viewModel: AnalysisViewModel
    
    func makeUIViewController(context: Context) -> UIViewController {
        let vc = AnalysisViewController(viewModel: viewModel)
        vc.onDismiss = { dismiss() }
        let navController = UINavigationController(rootViewController: vc)
        return navController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        //
    }
}
