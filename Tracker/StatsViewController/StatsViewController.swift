//
//  StatsViewController.swift
//  Tracker
//
//  Created by Кирилл Марьясов on 17.07.2024.
//

import Foundation
import UIKit

final class StatisticsViewController: UIViewController {
    
    // MARK: - Properties
    
    private let trackerRecordStore = TrackerRecordStore()
    private var trackers: [Tracker] = []
    var completedTrackers: [TrackerRecorder] = []
    
    private let label = TrackerTextLabel(text: "Анализировать пока нечего", fontSize: 12, fontWeight: .medium)
    private let statView = CustomStatisticView(title: "0", subtitle: localizedString(key:"doneTrackersCount"))
    
    private lazy var image: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = UIImage(named: "StatsMainScreenSad")
        return image
    }()
    
    private lazy var emptyHolderStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [image, label])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 8
        return stackView
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        setupAppearance()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateStat()
        mainScreenContent()
    }
    
    // MARK: - Private Methods
    
    private func setupAppearance() {
        view.backgroundColor = .ypWhite
        view.addSubviews(emptyHolderStackView, statView)
        statView.frame = CGRect(x: 16, y: self.view.frame.midY - 45, width: self.view.frame.width - 32, height: 90)
        statView.setupView()
        
        NSLayoutConstraint.activate([
            emptyHolderStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyHolderStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            image.heightAnchor.constraint(equalToConstant: 80),
            image.widthAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    private func updateStat() {
        completedTrackers = trackerRecordStore.fetchRecords()
        statView.configValue(value: calcStatData())
    }
    
    private func mainScreenContent() {
        statView.configValue(value: calcStatData())
        emptyHolderStackView.isHidden = completedTrackers.count != 0
        statView.isHidden = completedTrackers.count == 0
    }
    
    private func calcStatData() -> Int {
        completedTrackers.count
    }
}
