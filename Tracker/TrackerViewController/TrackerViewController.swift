//
//  TrackerViewController.swift
//  Tracker
//
//  Created by Кирилл Марьясов on 17.07.2024.
//

import UIKit

final class TrackerViewController: UIViewController{
    
    private var trackerLabel = UILabel()
    private var descriptionLabel = UILabel()
    private var imageMock = UIImageView()
    private var searchBar = UISearchBar()
    private var datePicker = UIDatePicker()
    private var collectionView: UICollectionView!
    
    private var selectedDate = Date()
    
    var trackers: [TrackerCategory] = []
    
    var categories: [TrackerCategory] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var completedTrackers: [TrackerRecord] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        loadMockData()
        filterTrackersForCurrentDay()
    }
    
    private func loadMockData() {
        let tracker1 = Tracker(id: UUID(), title: "Трампу подстрелили ухо", color: .orange, emoji: "😻", schedule: [DayOfWeek.monday])
        let tracker2 = Tracker(id: UUID(), title: "Отец ушел за хлебом", color: .red, emoji: "🌸", schedule: [DayOfWeek.tuesday])
        let tracker3 = Tracker(id: UUID(), title: "Вечеринка у Mr.Beast", color: .purple, emoji: "❤️", schedule: [DayOfWeek.wednesday])
        let tracker4 = Tracker(id: UUID(), title: "Бросить парня", color: .systemGreen
                               , emoji: "❤️", schedule: [DayOfWeek.friday])
        let category1 = TrackerCategory(title: "Семейная жизнь", trackers: [tracker4])
        let category2 = TrackerCategory(title: "Грустные мелочи", trackers: [tracker1, tracker2, tracker3])
        categories.append(category1)
        categories.append(category2)
    }
    
    private func filterTrackers(for day: DayOfWeek) {
        trackers = categories.map { category in
            let filteredTrackers = category.trackers.filter { $0.schedule.contains(day) }
            return TrackerCategory(title: category.title, trackers: filteredTrackers)
        }.filter { !$0.trackers.isEmpty }
        collectionView.reloadData()
    }
    
    private func filterTrackersForCurrentDay() {
        let calendar = Calendar.current
        let currentDate = Date()
        let dayOfWeek = calendar.component(.weekday, from: currentDate)
        
        let dayOfWeekIndex = (dayOfWeek + 5) % 7
        let currentDay = DayOfWeek.allCases[dayOfWeekIndex]
        
        filterTrackers(for: currentDay)
        updatePlaceholderVisibility()
    }
    
    @objc private func addButtonTapped() {
        let newVC = CreateNewTrackerViewController()
        newVC.delegate = self
        newVC.modalPresentationStyle = .popover
        present(newVC, animated: true, completion: nil)
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy"
        selectedDate = sender.date
        
        let calendar = Calendar.current
        let dayOfWeek = calendar.component(.weekday, from: sender.date)
        
        let dayOfWeekIndex = (dayOfWeek + 5) % 7
        
        let selectedDay = DayOfWeek.allCases[dayOfWeekIndex]
        
        filterTrackers(for: selectedDay)
        updatePlaceholderVisibility()
    }
    
    private func updatePlaceholderVisibility() {
        if trackers.isEmpty {
            setupImageView()
            descriptionLabel.isHidden = false
            imageMock.isHidden = false
        } else {
            descriptionLabel.isHidden = true
            imageMock.isHidden = true
        }
    }
    
    private func toggleTrackerCompletion(for tracker: Tracker) {
        let today = Date()
        let selectedDate = datePicker.date
        if Calendar.current.compare(today, to: Date(), toGranularity: .day) == .orderedDescending {
            
            return
        }
        if datePicker.date <= Date() {
            if let index = completedTrackers.firstIndex(where: { $0.trackerId == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }) {
                completedTrackers.remove(at: index)
            } else {
                
                let record = TrackerRecord(trackerId: tracker.id, date: selectedDate)
                completedTrackers.append(record)
            }
            collectionView.reloadData()
        }
    }
    //MARK: - SetUpUIView
    private func setUpView() {
        view.backgroundColor = .ypWhite
        setUpNavigationBar()
        setupImageView()
        setUpLabels()
        setUpSearchBar()
        setUpCollectionView()
    }
    
    private func setUpNavigationBar() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        addButton.tintColor = .ypBlack
        self.navigationItem.leftBarButtonItem = addButton
        
        datePicker.clipsToBounds = true
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.calendar.firstWeekday = 2
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        datePicker.addTarget(self, action:  #selector(datePickerValueChanged(_:)), for: .valueChanged)
        
        NSLayoutConstraint.activate([
            datePicker.heightAnchor.constraint(equalToConstant: 34),
            datePicker.widthAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    private func setupImageView() {
        imageMock.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageMock)
        
        imageMock.image = UIImage(named: "tracker_error")
        imageMock.contentMode = .scaleAspectFill
        
        NSLayoutConstraint.activate([
            imageMock.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageMock.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageMock.widthAnchor.constraint(equalToConstant: 80),
            imageMock.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    private func setUpLabels() {
        trackerLabel.textColor = .ypBlack
        trackerLabel.text = "Трекеры"
        trackerLabel.font = UIFont(name: "YSDisplay-Bold", size: 34)
        trackerLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(trackerLabel)
        
        descriptionLabel.textColor = .ypBlack
        descriptionLabel.text = "Что будем отслеживать?"
        descriptionLabel.textAlignment = .center
        descriptionLabel.font = UIFont(name: "YSDisplay-Medium", size: 12)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: imageMock.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            descriptionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            trackerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 1),
            trackerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
            
        ])
    }
    
    private func setUpSearchBar() {
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)
        
        if let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField {
            if let backgroundView = textFieldInsideSearchBar.superview?.subviews.first {
                backgroundView.layer.cornerRadius = 10
                backgroundView.clipsToBounds = true
            }
        }
        
        searchBar.backgroundImage = UIImage()
        searchBar.backgroundColor = .clear
        searchBar.barTintColor = .clear
        
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: trackerLabel.bottomAnchor, constant: 7),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func setUpCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 9
        layout.headerReferenceSize = .init(width: view.frame.size.width, height: 40)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: "TrackerCollectionViewCell")
        collectionView.register(TrackerHeaderView.self,forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "TrackerHeaderView")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
    }
}

extension TrackerViewController: CreateTrackerDelegate {
    func didCreateNewTracker(_ tracker: Tracker) {
        var updatedCategory: TrackerCategory?
        var index: Int?
        let category = "Тестовые трекеры"
        
        for i in 0..<categories.count {
            if categories[i].title == category {
                updatedCategory = categories[i]
                index = i
            }
        }
        
        if updatedCategory == nil {
            categories.append(TrackerCategory(title: category, trackers: [tracker]))
        } else {
            let newTrackersArray = (updatedCategory?.trackers ?? []) + [tracker]
            let sortedTrackersArray = newTrackersArray.sorted {$0.title < $1.title}
            let newCategory = TrackerCategory(title: category, trackers: sortedTrackersArray)
            categories.remove(at: index ?? 0)
            categories.insert(newCategory, at: index ?? 0)
        }
        
        
        filterTrackersForCurrentDay()
    }
}

//MARK: - DataSource & DelegateFlowLayout

extension TrackerViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return trackers[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackerCollectionViewCell", for: indexPath) as? TrackerCollectionViewCell else {
            fatalError("Unable to dequeue TrackerCollectionViewCell")
        }
        let tracker = trackers[indexPath.section].trackers[indexPath.item]
        
        let completedDays = completedTrackers.filter { $0.trackerId == tracker.id }.count
        let isCompleted = completedTrackers.contains { $0.trackerId == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
        
        cell.configure(with: tracker, completedDays: completedDays, isCompleted: isCompleted)
        cell.buttonAction = { [weak self] in
            self?.toggleTrackerCompletion(for: tracker)
            
            if let cell = collectionView.cellForItem(at: indexPath) as? TrackerCollectionViewCell {
                let completedDays = self?.completedTrackers.filter { $0.trackerId == tracker.id }.count ?? 0
                let isCompleted = self?.completedTrackers.contains { $0.trackerId == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: self?.selectedDate ?? Date()) } ?? false
                cell.configure(with: tracker, completedDays: completedDays, isCompleted: isCompleted)
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 9
        let availableWidth = collectionView.frame.width - padding
        let width = availableWidth / 2
        return CGSize(width: width, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind{
        case UICollectionView.elementKindSectionHeader:
            guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "TrackerHeaderView", for: indexPath) as? TrackerHeaderView else {
                return UICollectionReusableView()
            }
            view.titleLabel.text = trackers[indexPath.section].title
            return view
        default: return UICollectionReusableView()
        }
    }
}

extension TrackerViewController: UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let tracker = trackers[indexPath.section].trackers[indexPath.item]
        toggleTrackerCompletion(for: tracker)
        
        if let cell = collectionView.cellForItem(at: indexPath) as? TrackerCollectionViewCell {
            let completedDays = completedTrackers.filter { $0.trackerId == tracker.id }.count
            let isCompleted = completedTrackers.contains { $0.trackerId == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
            cell.configure(with: tracker, completedDays: completedDays, isCompleted: isCompleted)
        }
    }
}
