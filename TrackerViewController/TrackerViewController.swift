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
    
    private let trackerStore = TrackerStore()
    private let trackerCategoryStore = TrackerCategoryStore()
    private let trackerRecordStore = TrackerRecordStore()
    
    var visibleTrackers: [TrackerCategory] = []
    var categories: [TrackerCategory] = [TrackerCategory(title: "Важное", trackers: [])]
    var completedTrackers: [TrackerRecord] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        loadTrackersFromCoreData()
        filterTrackersForCurrentDay()
    }
    
    private func loadTrackersFromCoreData() {
      let storedTrackers = trackerStore.fetchTracker()
      print("Loaded Trackers: \(storedTrackers)")

      let storedCategories = trackerCategoryStore.fetchAllCategories()
      print("Loaded Categories: \(storedCategories.map { $0.title })")

      let storedRecords = trackerRecordStore.fetchAllRecords()
        completedTrackers = storedRecords.map { TrackerRecord(trackerId: $0.trackerId, date: $0.date) }
      print("Loaded Completed Trackers: \(completedTrackers)")

      if !storedCategories.isEmpty {
          categories = storedCategories.compactMap { trackerCategoryStore.decodingCategory(from: $0) }
          print("Decoded Categories: \(categories)")
      } else {
            
          if let firstCategory = categories.first {
            let updatedCategory = TrackerCategory(title: firstCategory.title, trackers: storedTrackers)
            categories[0] = updatedCategory
            }
        }

        visibleTrackers = categories
        filterTrackersForCurrentDay()

        collectionView.reloadData()
    }
    
    func appendTrackerInVisibleTrackers(weekday: Int) {
        visibleTrackers.removeAll()
        var weekDayCase: DayOfWeek = .monday
        
        switch weekday {
        case 1:
            weekDayCase = .sunday
        case 2:
            weekDayCase = .monday
        case 3:
            weekDayCase = .tuesday
        case 4:
            weekDayCase = .wednesday
        case 5:
            weekDayCase = .thursday
        case 6:
            weekDayCase = .friday
        case 7:
            weekDayCase = .saturday
        default:
            break
        }
        
        guard let firstCategory = categories.first else {
            print("No categories available")
            return
        }
        
        var uniqueTrackers = [UUID: Tracker]()
        for tracker in firstCategory.trackers {
            for day in tracker.schedule {
                if day == weekDayCase {
                    uniqueTrackers[tracker.id] = tracker
                }
            }
        }
        
        let trackers = Array(uniqueTrackers.values)
        if !trackers.isEmpty {
            let category = TrackerCategory(title: "Важное", trackers: trackers)
            visibleTrackers.append(category)
        }
    }
    
    private func filterTrackersForCurrentDay() {
        visibleTrackers.removeAll()
        let calendar = Calendar.current
        let currentDate = Date()
        let dayOfWeek = calendar.component(.weekday, from: currentDate)
        
        appendTrackerInVisibleTrackers(weekday: dayOfWeek)
        
        collectionView.reloadData()
        
        updatePlaceholderVisibility()
    }
    
    @objc private func addButtonTapped() {
        let newVC = CreateNewTrackerViewController()
        newVC.delegate = self
        newVC.modalPresentationStyle = .popover
        present(newVC, animated: true, completion: nil)
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        selectedDate = sender.date
        
        let calendar = Calendar.current
        let dayOfWeek = calendar.component(.weekday, from: sender.date)
        
        visibleTrackers.removeAll()
        appendTrackerInVisibleTrackers(weekday: dayOfWeek)
        
        collectionView.reloadData()
        updatePlaceholderVisibility()
    }
    
    private func updatePlaceholderVisibility() {
        let allTrackersEmpty = checkIsTrackerRepoEmpty()
        let visibleTrackersEmpty = checkIsVisibleEmpty()
        
        if allTrackersEmpty || visibleTrackersEmpty {
            setupImageView()
            descriptionLabel.isHidden = false
            imageMock.isHidden = false
        } else {
            descriptionLabel.isHidden = true
            imageMock.isHidden = true
        }
    }
    
    func checkIsTrackerRepoEmpty() -> Bool {
      categories[0].trackers.isEmpty
    }

    func checkIsVisibleEmpty() -> Bool {
      if visibleTrackers.isEmpty {
        return true
      }
      if visibleTrackers[0].trackers.isEmpty {
        return true
      } else {
        return false
      }
    }
    
    private func toggleTrackerCompletion(for tracker: Tracker) {
        let today = Date()
        let selectedDate = datePicker.date
        
        if Calendar.current.compare(selectedDate, to: today, toGranularity: .day) == .orderedDescending {
            return
        }
        
        if let index = completedTrackers.firstIndex(where: { $0.trackerId == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }) {
            let record = completedTrackers[index]
            completedTrackers.remove(at: index)
            trackerRecordStore.deleteRecord(for: record)
        } else {
            let record = TrackerRecord(trackerId: tracker.id, date: selectedDate)
            completedTrackers.append(record)
            trackerRecordStore.addNewRecord(from: record)
        }
        
        collectionView.reloadData()
    }
//MARK: - SetUpUIView
    private func setUpView() {
        view.backgroundColor = .white
        setUpNavigationBar()
        setupImageView()
        setUpLabels()
        setUpSearchBar()
        setUpCollectionView()
    }
    
    private func setUpNavigationBar() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        addButton.tintColor = .black
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
        trackerLabel.textColor = .black
        trackerLabel.text = "Трекеры"
        trackerLabel.font = UIFont(name: "YSDisplay-Bold", size: 34)
        trackerLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(trackerLabel)
        
        descriptionLabel.textColor = .black
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
        print("didCreateNewHabit asked")
        createNewTracker(tracker: tracker)
        if let _ = trackerStore.addNewTracker(from: tracker) {
          trackerCategoryStore.createCategoryAndTracker(tracker: tracker, with: "Важное")
        } else {
          print("Failed to save tracker")
        }
        filterTrackersForCurrentDay()
    }
    
    func createNewTracker(tracker: Tracker) {
        print("createNewTracker asked")
        var trackers: [Tracker] = []
        guard let list = categories.first else {return}
        for tracker in list.trackers{
            trackers.append(tracker)
        }
        trackers.append(tracker)
        categories = [TrackerCategory(title: "Важное", trackers: trackers)]
    }
}

//MARK: - DataSource & DelegateFlowLayout

extension TrackerViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        let sections = visibleTrackers.count
        print("numberOfSections: \(sections)")
        return sections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let items = visibleTrackers[section].trackers.count
        print("numberOfItemsInSection \(section): \(items)")
        return items
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackerCollectionViewCell", for: indexPath) as? TrackerCollectionViewCell else {
            fatalError("Unable to dequeue TrackerCollectionViewCell")
        }
        let tracker = visibleTrackers[indexPath.section].trackers[indexPath.item]
        print("Configuring cell for tracker: \(tracker)")
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
            view.titleLabel.text = visibleTrackers[indexPath.section].title
            return view
        default: return UICollectionReusableView()
        }
    }
}
    
extension TrackerViewController: UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let tracker = visibleTrackers[indexPath.section].trackers[indexPath.item]
        toggleTrackerCompletion(for: tracker)

        if let cell = collectionView.cellForItem(at: indexPath) as? TrackerCollectionViewCell {
            let completedDays = completedTrackers.filter { $0.trackerId == tracker.id }.count
            let isCompleted = completedTrackers.contains { $0.trackerId == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
            cell.configure(with: tracker, completedDays: completedDays, isCompleted: isCompleted)
        }
    }
}
