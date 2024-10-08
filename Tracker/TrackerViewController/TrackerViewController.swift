//
//  TrackerViewController.swift
//  Tracker
//
//  Created by Кирилл Марьясов on 17.07.2024.
//

import UIKit

// MARK: - ReloadCollectionProtocol

protocol ReloadCollectionProtocol: AnyObject {
    func reloadCollection()
}

// MARK: - TrackerViewController

final class TrackerViewController: UIViewController{
    
    // MARK: - Properties
    
    private let trackerStore = TrackerStore()
    private let trackerCategoryStore = TrackerCategoryStore()
    private let trackerRecordStore = TrackerRecordStore()
    
    var completedTrackers: [TrackerRecorder] = []
    var visibleCategory: [TrackerCategory] = []
    var categories: [TrackerCategory] = []
    
    let datePicker = UIDatePicker()
    let stackView = UIStackView()
    let label = UILabel()
    let image = UIImageView()
    var currentDate = Date()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .ypWhite
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        return collectionView
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backGround()
        setupTrackerView()
        setupDatePicker()
        setupCollectionView()
        loadTrackersFromCoreData()
        mainScreenContent(currentDate)
    }
    
    // MARK: - Data Loading
    
    private func loadTrackersFromCoreData() {
        let storedTrackers = trackerStore.fetchTrackers()
        print("Loaded Trackers: \(storedTrackers)")
        
        let storedCategories = trackerCategoryStore.fetchAllCategories()
        print("Loaded Categories: \(storedCategories.map { $0.title })")
        
        let storedRecords = trackerRecordStore.fetchAllRecords()
        completedTrackers = storedRecords.map { TrackerRecorder(id: $0.id, date: $0.date) }
        print("Loaded Completed Trackers: \(completedTrackers)")
        
        if !storedCategories.isEmpty {
            categories = storedCategories
        } else {
            
            if !storedTrackers.isEmpty {
                if let firstCategory = categories.first {
                    let updatedCategory = TrackerCategory(title: firstCategory.title, trackers: storedTrackers)
                    categories[0] = updatedCategory
                } else {
                    let defaultCategory = TrackerCategory(title: "Default Category", trackers: storedTrackers)
                    categories = [defaultCategory]
                }
            } else {
            }
        }
        
        visibleCategory = categories
        showTrackersInDate(currentDate)
        
        collectionView.reloadData()
        
        reloadHolders()
    }
    
    // MARK: - Tracker Management
    
    private func appendTrackers(for category: TrackerCategory, weekday: Int) {
        var weekDayCase: Weekday = .monday
        
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
        
        var uniqueTrackers = [UUID: Tracker]()
        for tracker in category.trackers {
            if tracker.schedule.contains(weekDayCase) {
                uniqueTrackers[tracker.id] = tracker
            }
        }
        
        let trackers = Array(uniqueTrackers.values)
        let updatedCategory = TrackerCategory(title: category.title, trackers: trackers)
        visibleCategory.append(updatedCategory)
    }
    
    private func mainScreenContent(_ date: Date) {
        showTrackersInDate(date)
        reloadHolders()
    }
    
    // MARK: - Setup UI
    
    private func backGround() {
        view.backgroundColor = .ypWhite
    }
    
    private func setupTrackerView() {
        let plusButton = UIBarButtonItem(image: UIImage(named: "HeaderPlusButton"), style: .plain, target: self, action: #selector(plusButtonTapped))
        plusButton.tintColor = .ypBlack
        navigationItem.leftBarButtonItem = plusButton
        
        let searchController = UISearchController()
        navigationItem.searchController = searchController
        searchController.searchBar.placeholder = "Поиск"
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 8
        view.addSubview(stackView)
        
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = UIImage(named: "TrackerMainScreenStar")
        stackView.addArrangedSubview(image)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Что будем отслеживать?"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        stackView.addArrangedSubview(label)
        
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        image.heightAnchor.constraint(equalToConstant: 80).isActive = true
        image.widthAnchor.constraint(equalToConstant: 80).isActive = true
    }
    
    private func setupDatePicker() {
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.tintColor = .ypBlue
        datePicker.addTarget(self, action: #selector(datePickerChanged), for: .valueChanged)
        
        view.addSubview(datePicker)
        
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.widthAnchor.constraint(equalToConstant: 120).isActive = true
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }
    
    private func setupCollectionView() {
        view.addSubview(collectionView)
        
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        collectionView.register(TrackersHeaderReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
    }
    
    private func reloadHolders() {
        let allTrackersEmpty = checkIsTrackerRepoEmpty()
        let visibleTrackersEmpty = checkIsVisibleEmpty()
        
        if allTrackersEmpty || visibleTrackersEmpty {
            collectionView.isHidden = true
            image.isHidden = false
            label.isHidden = false
            stackView.isHidden = false
        } else {
            collectionView.isHidden = false
            image.isHidden = true
            label.isHidden = true
            stackView.isHidden = true
        }
    }
    
    // MARK: - Actions
    
    @objc func plusButtonTapped() {
        print("PlusButtonTapped")
        let newTrackerVC = CreateTrackerViewController()
        newTrackerVC.habitDelegate = self
        newTrackerVC.eventDelegate = self
        let navigationController = UINavigationController(rootViewController: newTrackerVC)
        navigationController.modalPresentationStyle = .popover
        present(navigationController, animated: true, completion: nil)
    }
    
    @objc func datePickerChanged() {
        print("CalendarTapped")
        currentDate = datePicker.date
        mainScreenContent(currentDate)
    }
    
    // MARK: - Tracker Status Check
    
    private func checkIsTrackerCompletedToday(id: UUID) -> Bool {
        completedTrackers.contains { trackerRecord in
            let isSameDay = Calendar.current.isDate(trackerRecord.date, inSameDayAs: currentDate)
            return trackerRecord.id == id && isSameDay
        }
    }
    
    func showTrackersInDate(_ date: Date) {
        removeAllVisibleCategory()
        
        for category in categories {
            let weekday = Calendar.current.component(.weekday, from: date)
            appendTrackers(for: category, weekday: weekday)
        }
        
        collectionView.reloadData()
    }
    
    func removeAllVisibleCategory() {
        visibleCategory.removeAll()
    }
    
    func createNewTracker(tracker: Tracker) {
        var trackers: [Tracker] = []
        guard let list = categories.first else { return }
        for tracker in list.trackers {
            trackers.append(tracker)
        }
        trackers.append(tracker)
        categories = [TrackerCategory(title: list.title, trackers: trackers)]
        mainScreenContent(currentDate)
        collectionView.reloadData()
    }
    
    func createNewCategory(_ category: TrackerCategory) {
        categories.append(category)
        
        visibleCategory = categories
        
        showTrackersInDate(currentDate)
    }
    
    func checkIsCategoryEmpty() -> Bool {
        return categories.isEmpty || categories[0].trackers.isEmpty
    }
    
    func checkIsTrackerRepoEmpty() -> Bool {
        guard !categories.isEmpty else {
            return true
        }
        return categories[0].trackers.isEmpty
    }
    
    func checkIsVisibleEmpty() -> Bool {
        if visibleCategory.isEmpty {
            return true
        }
        if visibleCategory[0].trackers.isEmpty {
            return true
        } else {
            return false
        }
    }
    
    func getTrackerDetails(section: Int, item: Int) -> Tracker {
        visibleCategory[section].trackers[item]
    }
    
    func getTitleForSection(sectionNumber: Int) -> String {
        visibleCategory[sectionNumber].title
    }
}

// MARK: - CreateTrackerDelegate

extension TrackerViewController: CreateTrackerDelegate {
    func didDelegateNewTracker(_ tracker: Tracker, _ category: String) {
        print("didCreateNewHabit asked")
        createNewTracker(tracker: tracker)
        
        do {
            try trackerStore.addNewTracker(tracker)
            try trackerCategoryStore.createCategoryAndTracker(tracker: tracker, with: category)
            loadTrackersFromCoreData()
        } catch {
            print("Failed to save tracker: \(error)")
            
        }
        
        loadTrackersFromCoreData()
    }
}

//MARK: - UICollectionViewDataSource

extension TrackerViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        let sections = visibleCategory.count
        print("numberOfSections: \(sections)")
        return sections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let items = visibleCategory[section].trackers.count
        print("numberOfItemsInSection \(section): \(items)")
        return items
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? TrackerCollectionViewCell else { return UICollectionViewCell() }
        let tracker = getTrackerDetails(section: indexPath.section, item: indexPath.item)
        print("Configuring cell for tracker: \(tracker)")
        cell.delegate = self
        let isCompletedToday = checkIsTrackerCompletedToday(id: tracker.id)
        let completedDays = completedTrackers.filter { $0.id == tracker.id }.count
        cell.configureCell(tracker: tracker,
                           isCompletedToday: isCompletedToday,
                           completedDays: completedDays,
                           indexPath: indexPath)
        if datePicker.date > Date() {
            cell.plusButton.isHidden = true
        }  else {
            cell.plusButton.isHidden = false
        }
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TrackerViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemCount: CGFloat = 2
        let space: CGFloat = 9
        let width: CGFloat = (collectionView.bounds.width - space - 32) / itemCount
        let height: CGFloat = 148
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
    }
}

// MARK: - TrackerDoneDelegate

extension TrackerViewController: TrackerDoneDelegate {
    func completeTracker(id: UUID, indexPath: IndexPath) {
        let trackerRecord = TrackerRecorder(id: id, date: datePicker.date)
        completedTrackers.append(trackerRecord)
        trackerRecordStore.addNewRecord(from: trackerRecord)
        collectionView.reloadItems(at: [indexPath])
    }
    
    func uncompleteTracker(id: UUID, indexPath: IndexPath) {
        if let index = completedTrackers.firstIndex(where: { $0.id == id }) {
            let trackerRecord = completedTrackers[index]
            
            completedTrackers.remove(at: index)
            
            trackerRecordStore.deleteRecord(for: trackerRecord)
            
            collectionView.reloadItems(at: [indexPath])
        }
    }
}

// MARK: - CollectionView

extension TrackerViewController {
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else { return UICollectionReusableView() }
        
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! TrackersHeaderReusableView
        headerView.titleLabel.text = getTitleForSection(sectionNumber: indexPath.section)
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 50)
    }
}

extension TrackerViewController: CategoryViewControllerDelegate {
    func categoryScreen(_ screen: CategoryViewController, didSelectedCategory category: TrackerCategory) {
        
        categories.append(category)
        visibleCategory = categories
        showTrackersInDate(currentDate)
        reloadHolders()
    }
}
