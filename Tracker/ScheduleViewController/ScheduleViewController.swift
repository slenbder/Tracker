//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Кирилл Марьясов on 17.07.2024.
//

import Foundation
import UIKit

// MARK: - Enum Weekday

enum Weekday: String {
    case monday = "Пн"
    case tuesday = "Вт"
    case wednesday = "Ср"
    case thursday = "Чт"
    case friday = "Пт"
    case saturday = "Cб"
    case sunday = "Вск"
    
    init(from date: Date) {
        switch date.dayNumberOfWeek() {
        case 1:
            self = .sunday
        case 2:
            self = .monday
        case 3:
            self = .tuesday
        case 4:
            self = .wednesday
        case 5:
            self = .thursday
        case 6:
            self = .friday
        case 7:
            self = .saturday
        default:
            fatalError()
        }
    }
}

// MARK: - Date

extension Date {
    func dayNumberOfWeek() -> Int? {
        return Calendar.current.dateComponents([.weekday], from: self).weekday
    }
}

// MARK: - SelectedScheduleDelegate

protocol SelectedScheduleDelegate: AnyObject {
    func selectScheduleScreen(_ screen: ScheduleViewController, didSelectedDays schedule: [Weekday])
}

// MARK: - ScheduleViewController

class ScheduleViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var delegate: SelectedScheduleDelegate?
    
    let daysOfWeek : [Weekday] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
    let daysOfWeekUI = ["Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота", "Воскресенье"]
    
    var selectedDays: [Weekday] = []
    
    let tableView = UITableView()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Расписание"
        backGround()
        setupCategoryView()
        addButton()
    }
    
    // MARK: - Setup UI
    
    private func backGround() {
        view.backgroundColor = .ypWhite
    }
    
    private func setupCategoryView() {
        navigationItem.hidesBackButton = true
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(WeekDaysSelectCell.self, forCellReuseIdentifier: "WeekDaysSelectCell")
        tableView.rowHeight = 76
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .ypGray
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        let _ : CGFloat = CGFloat(daysOfWeekUI.count)
        tableView.allowsSelection = false
        tableView.layer.cornerRadius = 16
        tableView.isScrollEnabled = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        // Устанавливаем headerView, чтобы убрать верхний сепаратор у первой ячейки
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 1))
        
        view.addSubview(tableView)
        
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24).isActive = true
        tableView.heightAnchor.constraint(equalToConstant: tableView.rowHeight * CGFloat(daysOfWeek.count)).isActive = true
        
    }
    
    private func addButton() {
        let button = UIButton()
        button.setTitle("Готово", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.backgroundColor = .ypBlack
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.ypWhite, for: .normal)
        
        view.addSubview(button)
        
        button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
        
        button.addTarget(self, action: #selector(doneButton), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    @objc func doneButton(_ sender: UIButton) {
        print("Done")
        delegate?.selectScheduleScreen(self, didSelectedDays: self.selectedDays)
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let totalRows = tableView.numberOfRows(inSection: indexPath.section)

        if indexPath.row == 0 {
          
            tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 1))
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        } else if indexPath.row == totalRows - 1 {
            
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }
}

// MARK: - WeekDaySender

extension ScheduleViewController: WeekDaySender {
    func weekDayAppend(_ weekDay: Weekday) {
        selectedDays.append(weekDay)
    }
    
    func weekDayRemove(_ weekDay: Weekday) {
        if let index = selectedDays.firstIndex(of: weekDay) {
            selectedDays.remove(at: index)
        }
    }
}
