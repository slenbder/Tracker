//
//  CreateNewTrackerViewController.swift
//  Tracker
//
//  Created by Кирилл Марьясов on 17.07.2024.
//

import UIKit

// MARK: - CreateTrackerDelegate

protocol CreateTrackerDelegate: AnyObject {
    func didDelegateNewTracker(_ tracker: Tracker, _ category: String)
}

// MARK: - DismissProtocol

protocol DismissProtocol: AnyObject {
    func dismissView()
}

// MARK: - CreateTrackerViewController

final class CreateTrackerViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var delegate: ReloadCollectionProtocol?
    weak var habitDelegate: CreateTrackerDelegate?
    weak var eventDelegate: CreateTrackerDelegate?
    weak var dismissDelegate: DismissProtocol?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Создание трекера"
        backGround()
        addButton()
    }
    
    // MARK: - Setup UI
    
    private func backGround() {
        view.backgroundColor = .ypWhite
    }
    
    private func setupButtons(buttonTitle: String, action: Selector) -> UIButton {
        let button = UIButton()
        button.setTitle(buttonTitle, for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.backgroundColor = .ypBlack
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(button)
        
        button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        button.addTarget(self, action: action, for: .touchUpInside)
        
        return button
    }
    
    private func addButton() {
        let newHabitButton = setupButtons(buttonTitle: "Привычка", action: #selector(habitButtonTapped))
        newHabitButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        let newEventButton = setupButtons(buttonTitle: "Нерегулярное событие", action: #selector(eventButtonTapped))
        newEventButton.topAnchor.constraint(equalTo: newHabitButton.bottomAnchor, constant: 16).isActive = true
    }
    
    // MARK: - Actions
    
    @objc func habitButtonTapped() {
        print("HabitButtonTapped")
        let newTrackerVC = NewHabitVC()
        newTrackerVC.delegate = self
        newTrackerVC.dismissDelegate = self
        let navigationController = UINavigationController(rootViewController: newTrackerVC)
        navigationController.modalPresentationStyle = .popover
        present(navigationController, animated: true, completion: nil)
    }
    
    @objc func eventButtonTapped() {
        print("EventButtonTapped")
        let newTrackerVC = CreateNewIrregularEventViewController()
        newTrackerVC.delegate = self
        newTrackerVC.dismissDelegate = self
        let navigationController = UINavigationController(rootViewController: newTrackerVC)
        navigationController.modalPresentationStyle = .popover
        present(navigationController, animated: true, completion: nil)
    }
}

// MARK: - NewHabitVCDelegate

extension CreateTrackerViewController: NewHabitVCDelegate {
    func didCreateNewHabit(_ tracker: Tracker, _ category: String) {
        habitDelegate?.didDelegateNewTracker(tracker, category)
        dismissDelegate?.dismissView()
    }
}

// MARK: - CreateNewIrregularEventViewControllerDelegate

extension CreateTrackerViewController: CreateNewIrregularEventViewControllerDelegate {
    func didCreateNewEvent(_ tracker: Tracker, _ category: String) {
        eventDelegate?.didDelegateNewTracker(tracker, category)
        dismissDelegate?.dismissView()
    }
}

// MARK: - DismissProtocol

extension CreateTrackerViewController: DismissProtocol {
    func dismissView() {
        dismiss(animated: true) {
            self.delegate?.reloadCollection()
        }
    }
}
