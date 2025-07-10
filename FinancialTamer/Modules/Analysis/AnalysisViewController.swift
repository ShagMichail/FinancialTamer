//
//  AnalysisViewController.swift
//  FinancialTamer
//
//  Created by Михаил Шаговитов on 09.07.2025.
//

import UIKit
import SnapKit

final class AnalysisViewController: UIViewController {
    private let viewModel: AnalysisViewModel
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.delegate = self
        table.dataSource = self
        table.register(AnalysisHeaderCell.self, forCellReuseIdentifier: "headerCell")
        table.register(CategorySummaryCell.self, forCellReuseIdentifier: "categorySummaryCell")
        table.register(SectionHeaderView.self, forHeaderFooterViewReuseIdentifier: "sectionHeader")
        table.showsVerticalScrollIndicator = false
        return table
    }()
    
    var onDismiss: (() -> Void)?
    
    init(viewModel: AnalysisViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        setupUI()
        setupConstraints()
        Task {
            await viewModel.loadData()
            tableView.reloadData()
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        
        setupBackButton()
    }
    
    private func setupBackButton() {
        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        backButton.setTitle("  Назад", for: .normal)
        backButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        backButton.tintColor = UIColor(named: "navigationColor")

        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    
    private func setupConstraints() {
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func dateFormator(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: date)
    }
    
    @objc private func backButtonTapped() {
        onDismiss?()
    }
}

extension AnalysisViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 4 : viewModel.categorySummaries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "headerCell", for: indexPath) as? AnalysisHeaderCell else { return UITableViewCell() }
            cell.selectionStyle = .none
            switch indexPath.row {
            case 0:
                cell.configure(title: "Начало", date: viewModel.startDate) { [weak self] newDate in
                    self?.viewModel.changeDate(newValue: newDate, typeDate: .start)
                    Task { await self?.viewModel.loadData() }
                }
            case 1:
                cell.configure(title: "Конец", date: viewModel.endDate) { [weak self] newDate in
                    self?.viewModel.changeDate(newValue: newDate, typeDate: .end)
                    Task { await self?.viewModel.loadData() }
                }
            case 2:
                cell.configureWithSortPicker(selectedType: viewModel.sortType) { [weak self] newType in
                    self?.viewModel.sortType = newType
                    self?.viewModel.sortCategories(sortType: newType)
                    self?.tableView.reloadData()
                }
            case 3:
                let amount = NumberFormatter.currency.string(from: NSDecimalNumber(decimal: viewModel.totalAmount)) ?? "0 $"
                cell.configureStatic(title: "Сумма", value: amount)
            default:
                break
            }
            
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "categorySummaryCell", for: indexPath) as? CategorySummaryCell else { return UITableViewCell() }
            cell.selectionStyle = .none
            let summary = viewModel.categorySummaries[indexPath.row]
            
            cell.configure(
                emoji: String(summary.category.emoji),
                categoryName: summary.category.name,
                percent: "\(String(summary.percentage))"+"%",
                amount: NumberFormatter.currency.string(from: NSDecimalNumber(decimal: summary.totalAmount)) ?? ""
            )
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "sectionHeader") as? SectionHeaderView else { return UITableViewHeaderFooterView() }
        
        if section == 0 {
            header.configure(title: "Анализ", font: .systemFont(ofSize: 34, weight: .bold), color: .black, leadingConstraint: 0, bottomConstraint: 16)
        } else {
            header.configure(title: "ОПЕРАЦИИ", font: .systemFont(ofSize: 13), color: .secondaryLabel, leadingConstraint: 20, bottomConstraint: 8)
        }
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 60 : 35
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 60, bottom: 0, right: 0)
        }
    }
}

extension AnalysisViewController: AnalysisViewModelDelegate {
    func dataDidUpdate() {
        Task {
            await viewModel.loadData()
            tableView.reloadData()
        }
    }
    
    func shouldUpdateDateCells() {
        DispatchQueue.main.async {
            if let startCell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? AnalysisHeaderCell {
                startCell.updateDate(self.viewModel.startDate)
            }
            if let endCell = self.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? AnalysisHeaderCell {
                endCell.updateDate(self.viewModel.endDate)
            }
        }
    }
}
