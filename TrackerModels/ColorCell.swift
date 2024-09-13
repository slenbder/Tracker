//
//  ColorCell.swift
//  Tracker
//
//  Created by Кирилл Марьясов on 17.07.2024.
//

import UIKit

// MARK: - ColorCell

class ColorCell: UICollectionViewCell {
    
    // MARK: - UI Elements
    
    private lazy var colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var borderView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.layer.borderColor = UIColor.clear.cgColor
        view.layer.borderWidth = 4
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
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
        contentView.addSubview(colorView)
        contentView.addSubview(borderView)
        
        NSLayoutConstraint.activate([
            colorView.widthAnchor.constraint(equalToConstant: 40),
            colorView.heightAnchor.constraint(equalToConstant: 40),
            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
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
        borderView.layer.borderColor = isSelected ? color.withAlphaComponent(0.4).cgColor : UIColor.clear.cgColor
    }
}
