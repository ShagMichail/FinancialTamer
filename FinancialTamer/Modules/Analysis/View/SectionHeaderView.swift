//
//  SectionHeaderView.swift
//  FinancialTamer
//
//  Created by Михаил Шаговитов on 10.07.2025.
//

import UIKit

final class SectionHeaderView: UITableViewHeaderFooterView {
    private lazy var titleLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private var leadingConstraint: NSLayoutConstraint!
    private var bottomConstraint: NSLayoutConstraint!
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(titleLabel)
        
        leadingConstraint = titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0)
        bottomConstraint = titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0)
        
        // сделал здесь не через SnapKit, так как пока не понял как правильно прихранить констрейты, используя его
        NSLayoutConstraint.activate([
            leadingConstraint,
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            bottomConstraint,
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -20)
        ])
    }
    
    func configure(title: String, font: UIFont, color: UIColor, leadingConstraint: CGFloat, bottomConstraint: CGFloat) {
        titleLabel.text = title
        titleLabel.font = font
        titleLabel.textColor = color
        
        self.leadingConstraint.constant = leadingConstraint
        self.bottomConstraint.constant = -bottomConstraint
        
        contentView.setNeedsLayout()
        contentView.layoutIfNeeded()
    }
}
