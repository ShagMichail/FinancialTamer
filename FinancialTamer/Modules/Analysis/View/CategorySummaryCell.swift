//
//  TrabsactionCell.swift
//  FinancialTamer
//
//  Created by Михаил Шаговитов on 10.07.2025.
//

import UIKit
import SnapKit

final class CategorySummaryCell: UITableViewCell {
    private var emojiLabel = UILabel()
    private var categoryLabel: UILabel = {
        var label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        return label
    }()
    private var commentLabel: UILabel = {
        var label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        return label
    }()
    private var percentLabel: UILabel = {
        var label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        return label
    }()
    private var amountLabel: UILabel = {
        var label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        return label
    }()
    private var chevronImageView: UIImageView = {
        var imageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        imageView.tintColor = .systemGray
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(emojiLabel)
        contentView.addSubview(categoryLabel)
        contentView.addSubview(commentLabel)
        contentView.addSubview(percentLabel)
        contentView.addSubview(amountLabel)
        contentView.addSubview(chevronImageView)
        
        emojiLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(30)
        }

        categoryLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.leading.equalTo(emojiLabel.snp.trailing).offset(10)
        }

        commentLabel.snp.makeConstraints {
            $0.top.equalTo(categoryLabel.snp.bottom).offset(2)
            $0.leading.equalTo(emojiLabel.snp.trailing).offset(10)
            $0.bottom.equalToSuperview().offset(-10)
        }

        percentLabel.snp.makeConstraints {
            $0.trailing.equalTo(chevronImageView.snp.leading).offset(-8)
            $0.top.equalToSuperview().offset(5)
        }

        amountLabel.snp.makeConstraints {
            $0.trailing.equalTo(chevronImageView.snp.leading).offset(-8)
            $0.top.equalTo(percentLabel.snp.bottom).offset(2)
            $0.bottom.equalToSuperview().offset(-5)
        }

        chevronImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalToSuperview()
        }
    }
    
    func configure(emoji: String, categoryName: String, comment: String? = nil, percent: String, amount: String) {
        emojiLabel.text = emoji
        categoryLabel.text = categoryName
        percentLabel.text = percent
        amountLabel.text = amount
        
        if let comment = comment {
            commentLabel.text = comment
            commentLabel.isHidden = false
        } else {
            commentLabel.isHidden = true
        }
    }
}
