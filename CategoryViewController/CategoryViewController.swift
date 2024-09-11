//
//  CategoryViewController.swift
//  Tracker
//
//  Created by Кирилл Марьясов on 10.09.2024.
//

import Foundation
import UIKit

protocol CategoryViewControllerDelegate: AnyObject {
  func categoryScreen(_ screen: CategoryViewController, didSelectedCategory category: TrackerCategory)
}

class CategoryViewController: UIViewController {
  
  weak var delegate: CategoryViewControllerDelegate?
  var trackerVC = TrackerViewController()
  
  let tableView = UITableView()
  let stackView = UIStackView()
  let button = UIButton()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Категория"
    backGround()
    setupCategoryView()
    addButton()
    mainScreenContent()
  }
  
  private func backGround() {
    view.backgroundColor = .ypWhite
  }
  
  private func setupCategoryView() {
    navigationItem.hidesBackButton = true
    
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.axis = .vertical
    stackView.alignment = .center
    stackView.spacing = 8
    
    view.addSubview(stackView)
    
    let image = UIImageView()
    image.translatesAutoresizingMaskIntoConstraints = false
    image.image = UIImage(named: "tracker_stub")
    
    stackView.addArrangedSubview(image)
    
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "Привычки и события можно \nобъединить по смыслу"
    label.font = .systemFont(ofSize: 12, weight: .medium)
    label.numberOfLines = 0
    label.textAlignment = .center
    
    stackView.addArrangedSubview(label)
    
    stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    
    image.heightAnchor.constraint(equalToConstant: 80).isActive = true
    image.widthAnchor.constraint(equalToConstant: 80).isActive = true
  }
  
  private func addButton() {
    button.setTitle("Добавить категорию", for: .normal)
    button.layer.cornerRadius = 16
    button.layer.masksToBounds = true
    button.backgroundColor = .ypBlack
    button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
    button.setTitleColor(.ypWhite, for: .normal)
    button.translatesAutoresizingMaskIntoConstraints = false
    
    view.addSubview(button)
    
    tableView.delegate = self
    tableView.dataSource = self
    tableView.layer.cornerRadius = 16
    tableView.rowHeight = 75
    tableView.isScrollEnabled = false
    tableView.showsVerticalScrollIndicator = false
    tableView.backgroundColor = .ypBackground
    tableView.translatesAutoresizingMaskIntoConstraints = false
    
    view.addSubview(tableView)
    
    tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
    tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
    tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24).isActive = true
    tableView.heightAnchor.constraint(equalToConstant: 75).isActive = true
    
    button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
    button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
    button.heightAnchor.constraint(equalToConstant: 60).isActive = true
    button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
    
    button.addTarget(self, action: #selector(addCategory), for: .touchUpInside)
  }
  
  private func mainScreenContent() {
    if trackerVC.checkIsCategoryEmpty() {
      tableView.isHidden = true
      stackView.isHidden = false
    } else {
      tableView.isHidden = false
      stackView.isHidden = true
    }
    tableView.reloadData()
  }
  
  @objc func addCategory() {
    print("Add Category")
    let addNewCategory = NewCategoryViewController()
    navigationController?.pushViewController(addNewCategory, animated: true)
  }
}

extension CategoryViewController: UITableViewDelegate {}

extension CategoryViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return trackerVC.categories.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
    cell.textLabel?.text = trackerVC.categories[indexPath.row].title.rawValue
    cell.selectionStyle = .none
    cell.backgroundColor = .ypBackground
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
    delegate?.categoryScreen(self, didSelectedCategory: trackerVC.categories[indexPath.row])
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
      self.dismiss(animated: true)
    }
  }
  
  func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    tableView.cellForRow(at: indexPath)?.accessoryType = .none
  }
}
