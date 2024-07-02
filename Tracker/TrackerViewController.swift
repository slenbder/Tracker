//
//  TrackerViewController.swift
//  Tracker
//
//  Created by Кирилл Марьясов on 29.06.2024.
//

import UIKit

final class TrackerViewController: UIViewController {
    
    private lazy var searchBar: UISearchTextField = {
        let textField = UISearchTextField()
        textField.placeholder = "Поиск"
        textField.backgroundColor = .clear
        textField.font = .systemFont(ofSize: 17, weight: .medium)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.textColor = .black
        return textField
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.clipsToBounds = true
        picker.locale = Locale(identifier: "ru_RU")
        picker.calendar.firstWeekday = 2
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    private lazy var errorImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "tracker_error"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        return imageView
    }()
    
    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.font = UIFont(name: "YSDisplay-Regular", size: 12)
        label.textColor = UIColor(named: "ypBlack")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackground()
        configureNavigationBar()
        addSearchTextField()
        addErrorImageViewAndLabel()
        setupTapGesture()
    }
    
    private func configureBackground() {
        view.backgroundColor = UIColor(named: "ypWhite")
    }
    
    private func configureNavigationBar() {
        guard let navigationBar = navigationController?.navigationBar else { return }
        navigationBar.topItem?.title = "Трекеры"
        navigationBar.prefersLargeTitles = true
        navigationBar.topItem?.largeTitleDisplayMode = .always
        
        let plusButton = UIBarButtonItem(image: UIImage(named: "tabbarplusbutton"), style: .plain, target: self, action: #selector(plusButtonTapped))
        plusButton.tintColor = .black
        navigationItem.leftBarButtonItem = plusButton
        
        let rightButton = UIBarButtonItem(customView: datePicker)
        navigationItem.rightBarButtonItem = rightButton
    }
    
    private func addSearchTextField() {
        view.addSubview(searchBar)
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: navigationItem.leftBarButtonItem?.customView?.bottomAnchor ?? view.safeAreaLayoutGuide.topAnchor, constant: 1),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchBar.heightAnchor.constraint(equalToConstant: 36)
        ])
    }
    
    private func addErrorImageViewAndLabel() {
        view.addSubview(errorImageView)
        view.addSubview(errorLabel)
        
        NSLayoutConstraint.activate([
            errorImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorLabel.topAnchor.constraint(equalTo: errorImageView.bottomAnchor, constant: 8),
            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        DispatchQueue.main.async {
            let searchBarBottom = self.searchBar.frame.maxY
            let tabBarTop = self.tabBarController?.tabBar.frame.minY ?? self.view.safeAreaLayoutGuide.layoutFrame.maxY
            let midPoint = (searchBarBottom + tabBarTop) / 2
            
            NSLayoutConstraint.activate([
                self.errorImageView.centerYAnchor.constraint(equalTo: self.view.topAnchor, constant: midPoint)
            ])
        }
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func plusButtonTapped() {
        let createTrackerVC = CreateTrackerViewController()
        createTrackerVC.modalPresentationStyle = .pageSheet
        present(createTrackerVC, animated: true, completion: nil)
    }
}
