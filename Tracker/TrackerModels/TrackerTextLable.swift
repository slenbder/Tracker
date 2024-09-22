//
//  TrackerTextLable.swift
//  Tracker
//
//  Created by Кирилл Марьясов on 20.09.2024.
//

import Foundation
import UIKit

final class TrackerTextLabel: UILabel {
  init(text: String,fontSize: CGFloat, fontWeight: UIFont.Weight) {
    super.init(frame: .zero)
    self.translatesAutoresizingMaskIntoConstraints = false
    self.text = text
    self.numberOfLines = 0
    self.textAlignment = .center
    self.font = .systemFont(ofSize: fontSize, weight: fontWeight)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
