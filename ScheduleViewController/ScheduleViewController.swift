//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Кирилл Марьясов on 17.07.2024.
//

import UIKit

// MARK: - SelectedScheduleDelegate

protocol SelectedScheduleDelegate: AnyObject {
    func selectScheduleScreen(_ screen: ScheduleViewController, didSelectedDays schedule: [Weekday])
}

// MARK: - ScheduleViewController

class ScheduleViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var delegate: SelectedScheduleDelegate?
    
    private let daysOfWeek: [Weekday] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
    private let daysOfWeekUI = ["Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота", "Воскресенье"]
    private var selectedDays: [Weekday] = []
    
    private let tableView = UITableView()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Расписание"
        setupView()
        setupTableView()
        setupButton()
    }
    
    // MARK: - Setup UI
    
    private func setupView() {
        view.backgroundColor = .ypWhite
        navigationItem.hidesBackButton = true
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(WeekDaysSelectCell.self, forCellReuseIdentifier: "WeekDaysSelectCell")
        tableView.rowHeight = 76
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.allowsSelection = false
        tableView.layer.cornerRadius = 16
        tableView.isScrollEnabled = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.heightAnchor.constraint(equalToConstant: tableView.rowHeight * CGFloat(daysOfWeek.count))
        ])
    }
    
    private func setupButton() {
        let button = UIButton()
        button.setTitle("Готово", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.backgroundColor = .ypBlack
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.ypWhite, for: .normal)
        
        button.addTarget(self, action: #selector(doneButtonPressed), for: .touchUpInside)
        
        view.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            button.heightAnchor.constraint(equalToConstant: 60),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func doneButtonPressed(_ sender: UIButton) {
        print("Done")
        delegate?.selectScheduleScreen(self, didSelectedDays: selectedDays)
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension ScheduleViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return daysOfWeek.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "WeekDaysSelectCell", for: indexPath) as? WeekDaysSelectCell else {
            return UITableViewCell()
        }
        cell.configureCell(daysOfWeekUI[indexPath.row], daysOfWeek[indexPath.row])
        cell.delegate = self
        return cell
    }
}

// MARK: - WeekDaySender

extension ScheduleViewController: WeekDaySender {
    func weekDayAppend(_ weekDay: Weekday) {
        if !selectedDays.contains(weekDay) {
            selectedDays.append(weekDay)
        }
    }
    
    func weekDayRemove(_ weekDay: Weekday) {
        if let index = selectedDays.firstIndex(of: weekDay) {
            selectedDays.remove(at: index)
        }
    }
}
