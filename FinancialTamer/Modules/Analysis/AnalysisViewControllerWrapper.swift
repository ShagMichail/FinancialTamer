//
//  File.swift
//  FinancialTamer
//
//  Created by Михаил Шаговитов on 09.07.2025.
//

import SwiftUI

struct MyHistoryViewControllerWrapper: UIViewControllerRepresentable {
    let viewModel: MyHistoryViewModel
    
    func makeUIViewController(context: Context) -> AnalysisViewController {
        let vc = AnalysisViewController(viewModel: viewModel)
        return vc
    }
    
//    func makeUIViewController(context: Context) -> AnalysisViewController {
//            let viewController = AnalysisViewController(viewModel: viewModel)
//            viewController.title = title
//            viewController.view.backgroundColor = backgroundColor
//            
//            let navController = UINavigationController(rootViewController: viewController)
            
            // Настройка navigationBar
//            let appearance = UINavigationBarAppearance()
//            appearance.backgroundColor = .systemBlue
//            navController.navigationBar.standardAppearance = appearance
//            navController.navigationBar.scrollEdgeAppearance = appearance
//            navController.navigationBar.tintColor = .white
            
//            return viewController
//        }
    
    func updateUIViewController(_ uiViewController: AnalysisViewController, context: Context) {
        // Обновление контроллера при необходимости
    }
}
