//
//  TrackerCollectionViewCell.swift
//  Tracker
//
//  Created by Кирилл Марьясов on 17.07.2024.
//

import UIKit

class TrackerCollectionViewCell: UICollectionViewCell {
    
    let emojiLabel = UILabel()
    let titleLabel = UILabel()
    let daysLabel = UILabel()
    let plusButton = UIButton(type: .system)
    private let backgroundCardView = UIView()
    private let backgroundEmojiView = UIView()
    
    var trackerID: UUID?
    var buttonAction: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        backgroundColor = nil
    }
    
    private func setupView() {
        backgroundCardView.layer.cornerRadius = 10
        backgroundCardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(backgroundCardView)
        
        NSLayoutConstraint.activate([
            backgroundCardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            backgroundCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backgroundCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            backgroundCardView.heightAnchor.constraint(equalToConstant: 90)
        ])
        
        backgroundEmojiView.layer.cornerRadius = 12
        backgroundEmojiView.backgroundColor = .white.withAlphaComponent(0.3)
        backgroundEmojiView.translatesAutoresizingMaskIntoConstraints = false
        backgroundCardView.addSubview(backgroundEmojiView)
        
        NSLayoutConstraint.activate([
            backgroundEmojiView.widthAnchor.constraint(equalToConstant: 24),
            backgroundEmojiView.heightAnchor.constraint(equalToConstant: 24),
            backgroundEmojiView.topAnchor.constraint(equalTo: backgroundCardView.topAnchor, constant: 12),
            backgroundEmojiView.leadingAnchor.constraint(equalTo: backgroundCardView.leadingAnchor, constant: 12)
        ])
        
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        backgroundEmojiView.addSubview(emojiLabel)
        
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: backgroundEmojiView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: backgroundEmojiView.centerYAnchor)
            
        ])
        
        titleLabel.font = UIFont(name: "YSDisplay-Medium", size: 12)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .left
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        backgroundCardView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: backgroundCardView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: backgroundCardView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: backgroundCardView.bottomAnchor, constant: -12)
        ])
        
        daysLabel.font = UIFont(name: "YSDisplay-Medium", size: 12)
        daysLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(daysLabel)
        
        NSLayoutConstraint.activate([
            daysLabel.topAnchor.constraint(equalTo: backgroundCardView.bottomAnchor, constant: 16),
            daysLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12)
        ])
        
        plusButton.setImage(UIImage(systemName: "plus"), for: .normal)
        plusButton.tintColor = .white
        plusButton.layer.cornerRadius = 17
        plusButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(plusButton)
        
        NSLayoutConstraint.activate([
            plusButton.widthAnchor.constraint(equalToConstant: 34),
            plusButton.heightAnchor.constraint(equalToConstant: 34),
            plusButton.topAnchor.constraint(equalTo: backgroundCardView.bottomAnchor, constant: 8),
            plusButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12)
        ])
    }
    
    func configure(with tracker: Tracker, completedDays: Int, isCompleted: Bool) {
        emojiLabel.text = tracker.emoji
        titleLabel.text = tracker.title
        daysLabel.text = "\(completedDays) дней"
        backgroundCardView.backgroundColor = tracker.color
        trackerID = tracker.id
        
        if isCompleted {
            plusButton.setImage(UIImage(named: "doneLabel"), for: .normal)
            plusButton.backgroundColor = tracker.color.withAlphaComponent(0.5)
        } else {
            plusButton.setImage(UIImage(systemName: "plus"), for: .normal)
            plusButton.backgroundColor = tracker.color
        }
    }
    
    @objc private func plusButtonTapped() {
        buttonAction?()
    }
}
