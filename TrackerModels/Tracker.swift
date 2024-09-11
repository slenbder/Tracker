//
//  Tracker.swift
//  Tracker
//
//  Created by Кирилл Марьясов on 17.07.2024.
//

import UIKit

struct Tracker {
  let id: UUID
  let title: String
  let color: UIColor
  let emoji: String
  let schedule: [Weekday]
}

