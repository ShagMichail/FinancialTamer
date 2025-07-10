//
//  AnalysisHeaderCell.swift
//  FinancialTamer
//
//  Created by Михаил Шаговитов on 10.07.2025.
//

import UIKit
import SnapKit

final class AnalysisHeaderCell: UITableViewCell {
    
    private lazy var titleLabel: UILabel = {
        var label = UILabel()
        return label
    }()
    
    private lazy var valueLabel: UILabel = {
        var label = UILabel()
        return label
    }()
    
    private lazy var segmentedControl: UISegmentedControl = {
        var segmentedControl = UISegmentedControl(items: SortType.allCases.map { $0.rawValue })
        segmentedControl.addTarget(self, action: #selector(sortTypeChanged), for: .valueChanged)
        segmentedControl.backgroundColor = UIColor.accent.withAlphaComponent(0.5)
        segmentedControl.layer.cornerRadius = 8
        segmentedControl.clipsToBounds = true
        return segmentedControl
    }()
    
    private lazy var datePicker: UIDatePicker = {
        // пока не смог настроить, чтобы при нажатии на datePicker текст оставался черным
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.accent.withAlphaComponent(0.5)
        backgroundView.layer.cornerRadius = 8
        backgroundView.isUserInteractionEnabled = false
        
        datePicker.addSubview(backgroundView)
        datePicker.sendSubviewToBack(backgroundView)
        backgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        datePicker.addTarget(self, action: #selector(editingDidBegin), for: .editingDidBegin)
        datePicker.addTarget(self, action: #selector(editingDidEnd), for: .editingDidEnd)
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        return datePicker
    }()
    
    private var onDateChanged: ((Date) -> Void)?
    private var onSortChanged: ((SortType) -> Void)?
    
    private var isEdit: Bool = false
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview()
        }
    }
    
    func configure(title: String, date: Date, onDateChanged: @escaping (Date) -> Void) {
        self.onDateChanged = onDateChanged
        titleLabel.text = title
        
        contentView.addSubview(datePicker)
        
        datePicker.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalToSuperview()
        }
        
        datePicker.date = date
        datePicker.isHidden = false
        segmentedControl.isHidden = true
        valueLabel.isHidden = true
    }
    
    func configureWithSortPicker(selectedType: SortType, onSortChanged: @escaping (SortType) -> Void) {
        self.onSortChanged = onSortChanged
        
        titleLabel.text = "Сортировка"
        
        contentView.addSubview(segmentedControl)
        
        segmentedControl.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(150)
        }
        
        segmentedControl.selectedSegmentIndex = SortType.allCases.firstIndex(of: selectedType) ?? 0
        segmentedControl.isHidden = false
        datePicker.isHidden = true
        valueLabel.isHidden = true
    }
    
    func configureStatic(title: String, value: String) {
        titleLabel.text = title
        contentView.addSubview(valueLabel)
        
        valueLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalToSuperview()
        }
        
        valueLabel.text = value
        valueLabel.isHidden = false
        datePicker.isHidden = true
        segmentedControl.isHidden = true
    }
    
    func updateDate(_ date: Date) {
        datePicker.date = date
    }
    
    @objc private func editingDidBegin() {
        isEdit = true
    }
    
    @objc private func editingDidEnd() {
        isEdit = false
    }
    
    @objc private func datePickerValueChanged() {
        if isEdit {
            onDateChanged?(datePicker.date)
        }
    }
    
    @objc private func sortTypeChanged() {
        let selectedIndex = segmentedControl.selectedSegmentIndex
        guard selectedIndex >= 0 && selectedIndex < SortType.allCases.count else { return }
        onSortChanged?(SortType.allCases[selectedIndex])
    }
}
