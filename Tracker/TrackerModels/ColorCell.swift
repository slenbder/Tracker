//
//  ColorCell.swift
//  Tracker
//
//  Created by Кирилл Марьясов on 17.07.2024.
//

import Foundation
import UIKit

// MARK: - ColorCell

final class ColorCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    var colorView: UIView!
    var borderView: UIView!
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    // MARK: - Setup Views
    
    private func setupViews() {
        colorView = UIView()
        colorView.layer.cornerRadius = 8
        colorView.layer.masksToBounds = true
        contentView.addSubview(colorView)
        
        colorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            colorView.widthAnchor.constraint(equalToConstant: 40),
            colorView.heightAnchor.constraint(equalToConstant: 40),
            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        borderView = UIView()
        borderView.layer.cornerRadius = 12
        borderView.layer.borderColor = UIColor.clear.cgColor
        borderView.layer.borderWidth = 4
        borderView.isHidden = true
        contentView.addSubview(borderView)
        
        borderView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            borderView.leadingAnchor.constraint(equalTo: colorView.leadingAnchor, constant: -8),
            borderView.trailingAnchor.constraint(equalTo: colorView.trailingAnchor, constant: 8),
            borderView.topAnchor.constraint(equalTo: colorView.topAnchor, constant: -8),
            borderView.bottomAnchor.constraint(equalTo: colorView.bottomAnchor, constant: 8)
        ])
    }
    
    // MARK: - Configure Cell
    
    func configure(with color: UIColor, isSelected: Bool) {
        colorView.backgroundColor = color
        borderView.isHidden = !isSelected
        if isSelected {
            borderView.layer.borderColor = color.withAlphaComponent(0.4).cgColor
        } else {
            borderView.layer.borderColor = UIColor.clear.cgColor
        }
    }
}
