//
//  CustomStatisticView.swift
//  Tracker
//
//  Created by Кирилл Марьясов on 20.09.2024.
//

import Foundation
import UIKit


final class CustomStatisticView: UIView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
        addGradienBorder(colors: [.red, .green, .blue])
    }
    
    init(title: String, subtitle: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        subLabel.text = subtitle
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypWhite
        view.layer.cornerRadius = 15
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.font = .systemFont(ofSize: 34, weight: .bold)
        title.textColor = .ypBlack
        return title
    }()
    
    private lazy var subLabel: UILabel = {
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.font = .systemFont(ofSize: 12, weight: .bold)
        title.textColor = .ypBlack
        return title
    }()
    
    func configValue(value: Int) {
        titleLabel.text = String(value)
    }
    
    private func setupView() {
        layer.cornerRadius = 15
        containerView.addSubviews(titleLabel, subLabel)
        clipsToBounds = true
        addSubview(containerView)
        
        NSLayoutConstraint.activate([
            containerView.leftAnchor.constraint(equalTo: leftAnchor, constant: 1),
            containerView.rightAnchor.constraint(equalTo: rightAnchor, constant: -1),
            containerView.topAnchor.constraint(equalTo: topAnchor, constant: 1),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            titleLabel.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 12),
            
            subLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            subLabel.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 12),
        ])
    }
}

extension UIView {
    func addGradienBorder(colors: [UIColor], width: CGFloat = 2) {
        let gradient = CAGradientLayer()
        gradient.frame = bounds
        gradient.colors = colors.map { $0.cgColor }
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        
        let shape = CAShapeLayer()
        shape.lineWidth = width
        shape.path = UIBezierPath(roundedRect: bounds, cornerRadius: 15).cgPath
        shape.strokeColor = UIColor.black.cgColor
        shape.fillColor = UIColor.clear.cgColor
        gradient.mask = shape
        
        layer.addSublayer(gradient)
    }
}
