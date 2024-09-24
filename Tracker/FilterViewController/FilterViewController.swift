//
//  FilterViewController.swift
//  Tracker
//
//  Created by Кирилл Марьясов on 22.09.2024.
//

import Foundation
import UIKit

enum FilterCase: Int, CaseIterable {
  case all
  case today
  case complete
  case uncomplete
  
  var title: String {
    switch self {
    case .all:
      return localizedString(key: "allTrackers")
    case .today:
      return localizedString(key: "todayTrackers")
    case .complete:
      return localizedString(key: "doneTrackers")
    case .uncomplete:
      return localizedString(key: "unDoneTrackers")
    }
  }
}

protocol FilterDelegate: AnyObject {
  func setFilter(_ filterState: FilterCase)
}

final class FilterViewController: UIViewController {
  
  private let tableView = UITableView()
  
  weak var filterDelegate: FilterDelegate?
  
  var filterState: FilterCase = .all
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupTableView()
  }
  
  private func setupTableView() {
    tableView.delegate = self
    tableView.dataSource = self
    tableView.layer.cornerRadius = 16
    tableView.rowHeight = 75
    tableView.isScrollEnabled = true
    tableView.showsVerticalScrollIndicator = false
    tableView.backgroundColor = .ypWhite
    tableView.translatesAutoresizingMaskIntoConstraints = false
    
    view.backgroundColor = .ypWhite
    view.addSubview(tableView)
    
    NSLayoutConstraint.activate([
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
      tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
      tableView.heightAnchor.constraint(equalToConstant: CGFloat(FilterCase.allCases.count * 75))
    ])
  }
}

extension FilterViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let selectedFilter = FilterCase(rawValue: indexPath.row) else { return }
    
    filterState = selectedFilter
    filterDelegate?.setFilter(selectedFilter)
    
    tableView.reloadData()
    
    self.dismiss(animated: true)
  }
}

extension FilterViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    FilterCase.allCases.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
    let filterCase = FilterCase(rawValue: indexPath.row)!
    cell.textLabel?.text = filterCase.title
    cell.selectionStyle = .none
    cell.accessoryType = filterCase == filterState ? .checkmark : .none
    cell.backgroundColor = .ypBackground
    return cell
  }
}
