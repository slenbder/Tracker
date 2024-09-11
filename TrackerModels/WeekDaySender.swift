//
//  WeekDaySender.swift
//  Tracker
//
//  Created by Кирилл Марьясов on 10.09.2024.
//

import Foundation
import UIKit

protocol WeekDaySender: AnyObject {
  func weekDayAppend(_ weekDay: Weekday)
  func weekDayRemove(_ weekDay: Weekday)
}

final class WeekDaysSelectCell: UITableViewCell {
  
  var weekDay: Weekday?
  weak var delegate: WeekDaySender?
  
  private lazy var weekDayTitle: UILabel = {
    let weekDayTitle = UILabel()
    weekDayTitle.translatesAutoresizingMaskIntoConstraints = false
    return weekDayTitle
  }()
  
  private lazy var onOffSwitch: UISwitch = {
    let onOffSwitch = UISwitch()
    onOffSwitch.onTintColor = .ypBlue
    onOffSwitch.translatesAutoresizingMaskIntoConstraints = false
    onOffSwitch.addTarget(self, action: #selector(onOffAction), for: .valueChanged)
    return onOffSwitch
    
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupAppearance()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configureCell(_ weekDayUI: String, _ weekDay: Weekday) {
    backgroundColor = .ypBackground
    weekDayTitle.text = weekDayUI
    self.weekDay = weekDay
  }
  
  @objc private func onOffAction(_ sender: UISwitch) {
    guard let weekDay = weekDay else { return }
    sender.isOn ? delegate?.weekDayAppend(weekDay) : delegate?.weekDayRemove(weekDay)
  }
  
  func setupAppearance() {
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
