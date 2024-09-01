//
//  CreateNewTrackerViewController.swift
//  Tracker
//
//  Created by Кирилл Марьясов on 17.07.2024.
//

import UIKit

protocol CreateTrackerDelegate: AnyObject{
    func didCreateNewTracker(_ tracker: Tracker)
}

final class CreateTrackerViewController: UIViewController{
    
    weak var delegate: CreateTrackerDelegate?
    
    let habitButton = UIButton()
    let irregularEventButton = UIButton()
    let titleLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
    
    private func setUpView() {
        view.backgroundColor = .white
        setUpLabel()
        setUpButtons()
    }
    
    private func setUpLabel() {
        titleLabel.text = "Создание трекера"
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .black
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.heightAnchor.constraint(equalToConstant: 100),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        ])
    }
    
    private func setUpButtons() {
        habitButton.setTitle("Привычка", for: .normal)
        habitButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        habitButton.titleLabel?.textColor = .white
        habitButton.titleLabel?.textAlignment = .center
        habitButton.backgroundColor = .black
        habitButton.layer.cornerRadius = 15
        habitButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(habitButton)
        
        irregularEventButton.setTitle("Нерегулярное событие", for: .normal)
        irregularEventButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        irregularEventButton.titleLabel?.textColor = .white
        irregularEventButton.titleLabel?.textAlignment = .center
        irregularEventButton.backgroundColor = .black
        irregularEventButton.tintColor = .white
        irregularEventButton.layer.cornerRadius = 15
        irregularEventButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(irregularEventButton)
        
        NSLayoutConstraint.activate([
            habitButton.heightAnchor.constraint(equalToConstant: 60),
            habitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            habitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            habitButton.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: 8),
            irregularEventButton.heightAnchor.constraint(equalToConstant: 60),
            irregularEventButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            irregularEventButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            irregularEventButton.topAnchor.constraint(equalTo: habitButton.bottomAnchor, constant: 16)
            
            
        ])
        
        habitButton.addTarget(self, action: #selector(didTapHabitButton), for: .touchUpInside)
        irregularEventButton.addTarget(self, action: #selector(didTapIrregularEventButton), for: .touchUpInside)
        
    }
    
    @objc  func didTapHabitButton() {
        let newVC = NewHabitVC()
        newVC.delegate = self
        newVC.modalPresentationStyle = .popover
        present(newVC, animated: true, completion: nil)
    }
    
    @objc  func didTapIrregularEventButton() {
        let newVC = CreateNewIrregularEventViewController()
        newVC.modalPresentationStyle = .popover
        present(newVC, animated: true, completion: nil)
    }
}

extension CreateTrackerViewController: NewHabitViewControllerDelegate{
    func didCreateNewHabit(_ tracker: Tracker) {
        delegate?.didCreateNewTracker(tracker)
    }
}
