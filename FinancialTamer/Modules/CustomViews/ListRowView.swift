//
//  ListRowView.swift
//  FinancialTamer
//
//  Created by Михаил Шаговитов on 18.06.2025.
//

import SwiftUI

struct ListRowView: View {
    private var emoji: String?
    private var categoryName: String
    private var transactionComment: String?
    private var transactionAmount: String?
    private var transactionDate: String?
    private var needChevron: Bool
    
    init(
        emoji: String? = nil,
        categoryName: String,
        transactionComment: String? = nil,
        transactionAmount: String? = nil,
        transactionDate: String? = nil,
        needChevron: Bool
    ) {
        self.emoji = emoji
        self.categoryName = categoryName
        self.transactionComment = transactionComment
        self.transactionAmount = transactionAmount
        self.transactionDate = transactionDate
        self.needChevron = needChevron
    }
    
    var body: some View {
        HStack {
            if let emoji = emoji {
                Circle()
                    .fill(Color.accentColor.opacity(0.2))
                    .frame(width: 22, height: 22)
                    .overlay(Text(String(emoji))
                        .font(.system(size: 12))
                    )
                    .padding(.trailing, 8)
            }
            
            VStack(alignment: .leading) {
                Text(categoryName)
                    .font(.system(size: 17, weight: .regular))
                if let transactionComment = transactionComment {
                    Text(transactionComment)
                        .font(.system(size: 13, weight: .regular))
                        .opacity(0.5)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 10)
            
            VStack(alignment: .trailing) {
                if let transactionAmount = transactionAmount {
                    Text(transactionAmount)
                        .font(.system(size: 17, weight: .regular))
                }
                if let transactionDate = transactionDate {
                    Text(transactionDate)
                        .font(.system(size: 17, weight: .regular))
                }
            }
            if needChevron {
                Image(systemName: "chevron.right")
                    .resizable()
                    .frame(width: 6, height: 10)
                    .foregroundStyle(.gray)
            }
        }
        .frame(maxWidth: .infinity, idealHeight: 35)
    }
}

#Preview {
    ListRowView(emoji: "sdf", categoryName: "sdf", transactionComment: "sdf", transactionAmount: "232323", needChevron: true).background(Color.red)
//    ListRowView(emoji: "sdf", categoryName: "sdf", transactionAmount: "232323", needChevron: true)
//    ListRowView(categoryName: "sdf", transactionAmount: "232323", needChevron: false).background(Color.red)
}
