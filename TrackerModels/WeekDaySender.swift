//
//  WeekDaySender.swift
//  Tracker
//
//  Created by Кирилл Марьясов on 10.09.2024.
//

import Foundation
import UIKit

// MARK: - WeekDaySender Protocol

protocol WeekDaySender: AnyObject {
    func weekDayAppend(_ weekDay: Weekday)
    func weekDayRemove(_ weekDay: Weekday)
}

// MARK: - WeekDaysSelectCell

final class WeekDaysSelectCell: UITableViewCell {
    
    // MARK: - Properties
    
    var weekDay: Weekday?
    weak var delegate: WeekDaySender?
    
    // MARK: - UI Elements
    
    private lazy var weekDayTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var onOffSwitch: UISwitch = {
        let switchControl = UISwitch()
        switchControl.onTintColor = .ypBlue
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        switchControl.addTarget(self, action: #selector(onOffAction), for: .valueChanged)
        return switchControl
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupAppearance()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
    
    func configureCell(_ weekDayUI: String, _ weekDay: Weekday) {
        backgroundColor = .ypBackground
        weekDayTitle.text = weekDayUI
        self.weekDay = weekDay
    }
    
    // MARK: - Actions
    
    @objc private func onOffAction(_ sender: UISwitch) {
        guard let weekDay = weekDay else { return }
        sender.isOn ? delegate?.weekDayAppend(weekDay) : delegate?.weekDayRemove(weekDay)
    }
    
    // MARK: - Setup Appearance
    
    private func setupAppearance() {
        contentView.addSubview(weekDayTitle)
        contentView.addSubview(onOffSwitch)
        
        NSLayoutConstraint.activate([
            weekDayTitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            weekDayTitle.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            onOffSwitch.centerYAnchor.constraint(equalTo: centerYAnchor),
            onOffSwitch.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15)
        ])
    }
}
