//
//  Untitled.swift
//  Tracker
//
//  Created by Кирилл Марьясов on 18.09.2024.
//

import Foundation
import UIKit

final class CategoryTableViewCell: UITableViewCell {
    static let reuseIdentifier = "CategoryTableViewCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        textLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        textLabel?.textColor = .ypBlack
        backgroundColor = .ypBackground
        selectionStyle = .none
    }
    
    func configure(with category: TrackerCategory) {
        textLabel?.text = category.title
    }
}
