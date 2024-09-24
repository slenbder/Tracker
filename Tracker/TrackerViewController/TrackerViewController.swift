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
    private let analyticsService = AnalyticsService()
    
    var completedTrackers: [TrackerRecorder] = []
    var categories: [TrackerCategory] = []
    var weekdayFilter: Weekday?
    var visibleCategory: [TrackerCategory] = [] {
        didSet {
            print("Yes")
        }
    }
    
    
    let datePicker = UIDatePicker()
    let stackView = UIStackView()
    let label = UILabel()
    let image = UIImageView()
    let filterButton = UIButton()
    
    var currentDate = Date()
    var isSearch = false
    var filterState: FilterCase = .all
    var tempCategories = [TrackerCategory]()
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        analyticsService.report(event: "open", params: ["screen": "Main"])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backGround()
        setupTrackerView()
        setupDatePicker()
        setupCollectionView()
        loadTrackersFromCoreData()
        mainScreenContent(currentDate)
        setupFilterButton()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        analyticsService.report(event: "close", params: ["screen": "Main"])
    }
    
    // MARK: - Data Loading
    
    private func loadTrackersFromCoreData() {
        let storedTrackers = trackerStore.fetchTracker()
        let storedCategories = trackerCategoryStore.fetchAllCategories()
        let storedRecords = trackerRecordStore.fetchAllRecords()
        
        completedTrackers = storedRecords.map { TrackerRecorder(id: $0.id, date: $0.date) }
        
        if !storedCategories.isEmpty {
            categories = storedCategories.compactMap { trackerCategoryStore.decodingCategory(from: $0) }
        } else {
            if !storedTrackers.isEmpty {
                let newCategory = TrackerCategory(title: "Default Category", trackers: storedTrackers)
                categories.append(newCategory)
            }
        }
        
        visibleCategory = getVisibleCategories(from: categories)
        showTrackersInDate(currentDate)
        reloadHolders()
    }
    
    private func getVisibleCategories(from items: [TrackerCategory]) -> [TrackerCategory] {
        var filteredCategories: [TrackerCategory] = []
        
        if let pinnedCategory = items.first(where: { $0.title == "Закрепленные" }) {
            filteredCategories = items.filter({ $0.title == pinnedCategory.title})
            filteredCategories = items.map({ category in
                TrackerCategory(title: category.title, trackers: category.trackers.filter({ !pinnedCategory.trackers.contains($0) }))
            })
            filteredCategories.insert(pinnedCategory, at: 0)
        } else {
            filteredCategories = items
        }
        
        if let weekdayFilter = weekdayFilter {
            filteredCategories = filteredCategories.map { category in
                let filteredTrackers = category.trackers.filter { $0.schedule.contains(weekdayFilter) }
                return TrackerCategory(title: category.title, trackers: filteredTrackers)
            }
        }
        
        return filteredCategories.filter { !$0.trackers.isEmpty }
    }
    
    
    private func updateVisibleCategories() {
        let originalCategories = visibleCategory
        
        visibleCategory = visibleCategory.filter { !$0.trackers.isEmpty }
        
        if originalCategories.count != visibleCategory.count {
            collectionView.reloadData()
        } else {
            collectionView.performBatchUpdates({
                for (index, category) in visibleCategory.enumerated() {
                    if originalCategories.count > index, originalCategories[index].trackers.count != category.trackers.count {
                        collectionView.reloadSections(IndexSet(integer: index))
                    }
                }
            }, completion: nil)
        }
        
        if let pinnedCategoryIndex = visibleCategory.firstIndex(where: { $0.title == "Закрепленные" }) {
            let pinnedCategory = visibleCategory.remove(at: pinnedCategoryIndex)
            visibleCategory.insert(pinnedCategory, at: 0)
            collectionView.reloadSections(IndexSet(integer: 0))
        }
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
        visibleCategory = getVisibleCategories(from: visibleCategory + [updatedCategory])
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
        let plusButton = UIBarButtonItem(image: UIImage(named: "plus_button"), style: .plain, target: self, action: #selector(plusButtonTapped))
        plusButton.tintColor = .ypBlack
        navigationItem.leftBarButtonItem = plusButton
        
        let searchController = UISearchController()
        navigationItem.searchController = searchController
        searchController.searchBar.placeholder = localizedString(key:"searchTextFieldPlaceholder")
        searchController.searchResultsUpdater = self
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 8
        view.addSubview(stackView)
        
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = UIImage(named: "tracker_stub")
        stackView.addArrangedSubview(image)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localizedString(key:"trackersHolderLabel")
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
    
    private func setupFilterButton() {
        view.addSubview(filterButton)
        
        filterButton.setTitle(localizedString(key:"filterButton"), for: .normal)
        filterButton.translatesAutoresizingMaskIntoConstraints = false
        filterButton.layer.cornerRadius = 16
        filterButton.layer.masksToBounds = true
        filterButton.backgroundColor = .ypBlue
        filterButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        filterButton.setTitleColor(.ypWhite, for: .normal)
        filterButton.setTitleColor(.white, for: .normal)
        filterButton.addTarget(self, action: #selector(filterButtonTap), for: .touchUpInside)
        
        filterButton.widthAnchor.constraint(equalToConstant: 115).isActive = true
        filterButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
    }
    
    private func reloadHolders() {
        let allTrackersEmpty = checkIsTrackerRepoEmpty()
        let visibleTrackersEmpty = checkIsVisibleEmpty()
        
        filterButton.isHidden = visibleTrackersEmpty
        
        if allTrackersEmpty || visibleTrackersEmpty {
            collectionView.isHidden = true
            image.isHidden = false
            label.isHidden = false
            stackView.isHidden = false
        } else {
            collectionView.isHidden = false
            collectionView.isHidden = false
            image.isHidden = true
            label.isHidden = true
            stackView.isHidden = true
        }
    }
    
    // MARK: - Actions
    
    @objc func plusButtonTapped() {
        print("PlusButtonTapped")
        analyticsService.report(event: "click", params: ["screen": "Main", "item": "add_track"])
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
        let weekday = Calendar.current.component(.weekday, from: currentDate)
        
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
        
        weekdayFilter = weekDayCase
        mainScreenContent(currentDate)
    }
    
    
    @objc private func filterButtonTap() {
        analyticsService.report(event: "click", params: ["screen": "Main", "item": "filter"])
        let filterViewController = FilterViewController()
        filterViewController.filterState = self.filterState
        filterViewController.filterDelegate = self
        let filterNavController = UINavigationController(rootViewController: filterViewController)
        present(filterNavController, animated: true)
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
        
        if let weekdayFilter = weekdayFilter {
            visibleCategory = visibleCategory.map { category in
                let filteredTrackers = category.trackers.filter { $0.schedule.contains(weekdayFilter) }
                return TrackerCategory(title: category.title, trackers: filteredTrackers)
            }.filter { !$0.trackers.isEmpty }
        }
        collectionView.reloadData()
        updateVisibleCategories()
    }
    
    func removeAllVisibleCategory() {
        visibleCategory.removeAll()
    }
    
    func createNewTracker(tracker: Tracker) {
        var updatedCategories = [TrackerCategory]()
        
        if let index = categories.firstIndex(where: { $0.title == tracker.trackerCategory }) {
            var category = categories[index]
            var trackers = category.trackers
            trackers.append(tracker)
            category = TrackerCategory(title: category.title, trackers: trackers)
            updatedCategories = categories
            updatedCategories[index] = category
        } else {
            let newCategory = TrackerCategory(title: tracker.trackerCategory, trackers: [tracker])
            updatedCategories = categories + [newCategory]
        }
        
        categories = updatedCategories
        visibleCategory = getVisibleCategories(from: updatedCategories)
        mainScreenContent(currentDate)
        collectionView.reloadData()
    }
    
    func updateTracker(tracker: Tracker) {
        guard
            let indexOfUpdatedCategory = categories.firstIndex(where: { $0.trackers.contains(tracker) }),
            let indexOfUpdatedTracker = categories[indexOfUpdatedCategory].trackers.firstIndex(of: tracker)
        else { return }
        
        if tracker.trackerCategory == categories[indexOfUpdatedCategory].title {
            var updatedTrackers = categories[indexOfUpdatedCategory].trackers
            updatedTrackers[indexOfUpdatedTracker] = tracker
            let updatedCategory = TrackerCategory(title: categories[indexOfUpdatedCategory].title, trackers: updatedTrackers)
            categories[indexOfUpdatedCategory] = updatedCategory
            
            trackerStore.updateTracker(tracker: tracker)
            trackerCategoryStore.deleteTrackerFromCategory(tracker: tracker, with: updatedCategory.title)
            trackerCategoryStore.addTrackerToCategory(tracker: tracker, with: updatedCategory.title)
        } else {
            let updatedTrackers = categories[indexOfUpdatedCategory].trackers.filter({ $0.id != tracker.id })
            let updatedCategory = TrackerCategory(title: categories[indexOfUpdatedCategory].title, trackers: updatedTrackers)
            categories[indexOfUpdatedCategory] = updatedCategory
            
            trackerStore.updateTracker(tracker: tracker)
            trackerCategoryStore.deleteTrackerFromCategory(tracker: tracker, with: updatedCategory.title)
            
            if let newCategoryIndex = categories.firstIndex(where: { $0.title == tracker.trackerCategory }) {
                categories[newCategoryIndex] = TrackerCategory(title: categories[newCategoryIndex].title, trackers: categories[newCategoryIndex].trackers + [tracker])
                trackerCategoryStore.addTrackerToCategory(tracker: tracker, with: categories[newCategoryIndex].title)
            } else {
                let newCategory = TrackerCategory(title: tracker.trackerCategory, trackers: [tracker])
                categories.append(newCategory)
                trackerCategoryStore.addTrackerToCategory(tracker: tracker, with: tracker.trackerCategory)
            }
        }
        
        visibleCategory = getVisibleCategories(from: categories)
        collectionView.reloadData()
    }
    
    
    func createNewCategory(_ category: TrackerCategory) {
        categories.append(category)
        visibleCategory = getVisibleCategories(from: categories)
        showTrackersInDate(currentDate)
        reloadHolders()
    }
    
    
    
    func checkIsCategoryEmpty() -> Bool {
        return categories.isEmpty || categories[0].trackers.isEmpty
    }
    
    func checkIsTrackerRepoEmpty() -> Bool {
        guard !categories.isEmpty else {
            return true
        }
        return !categories.contains(where: { !$0.trackers.isEmpty })
    }
    
    func checkIsVisibleEmpty() -> Bool {
        if visibleCategory.isEmpty {
            return true
        }
        return !visibleCategory.contains(where: { !$0.trackers.isEmpty })
    }
    
    func getTrackerDetails(section: Int, item: Int) -> Tracker {
        visibleCategory[section].trackers[item]
    }
    
    func getTitleForSection(sectionNumber: Int) -> String {
        visibleCategory[sectionNumber].title
    }
}

// MARK: - CreateTrackerDelegate

extension TrackerViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        let sections = visibleCategory.count
        print("numberOfSections: \(sections)")
        return sections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let itemsCount = visibleCategory[section].trackers.count
        return itemsCount
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
    
    func filterTrackers(for searchText: String) {
        guard !searchText.isEmpty else {
            visibleCategory = getVisibleCategories(from: categories)
            collectionView.reloadData()
            return
        }
        
        visibleCategory = getVisibleCategories(from: categories.compactMap { category -> TrackerCategory? in
            let filteredTrackers = category.trackers.filter { tracker in
                return tracker.title.lowercased().contains(searchText.lowercased())
            }
            
            if !filteredTrackers.isEmpty {
                return TrackerCategory(title: category.title, trackers: filteredTrackers)
            } else {
                return nil
            }
        })
        
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfiguration configuration: UIContextMenuConfiguration, highlightPreviewForItemAt indexPath: IndexPath) -> UITargetedPreview? {
        guard let cell = collectionView.cellForItem(at: indexPath) as? TrackerCollectionViewCell else {
            return nil
        }
        let parameters = UIPreviewParameters()
        let previewView = UITargetedPreview(view: cell.bodyView, parameters: parameters)
        return previewView
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        guard indexPaths.count > 0 else {
            return nil
        }
        
        let indexPath = indexPaths[0]
        
        let config = UIContextMenuConfiguration(actionProvider:  { _ in
            
            let pin = UIAction(title: localizedString(key:"pin"),
                               image: UIImage.init(systemName: "pin")) { _ in
                self.pinTracker(indexPath: indexPath)
            }
            
            let unpin = UIAction(title: localizedString(key:"unpin"),
                                 image: UIImage.init(systemName: "pin.slash")) { _ in
                self.unpinTracker(indexPath: indexPath)
            }
            
            let edit = UIAction(title: localizedString(key:"edit"),
                                image: UIImage.init(systemName: "pencil")) { _ in
                self.editTracker(indexPath: indexPath)
            }
            
            let delete = UIAction(title: localizedString(key:"delete"),
                                  image: UIImage.init(systemName: "trash"),
                                  attributes: .destructive) { _ in
                self.deleteTracker(indexPath: indexPath)
            }
            
            if self.visibleCategory[indexPath.section].title == "Закрепленные" {
                return UIMenu(options: UIMenu.Options.displayInline, children: [unpin, edit, delete])
            } else {
                return UIMenu(options: UIMenu.Options.displayInline, children: [pin, edit, delete])
            }
        })
        return config
    }
    
    private func pinTracker(indexPath: IndexPath) {
        let tracker = visibleCategory[indexPath.section].trackers[indexPath.row]
        
        if let pinnedCategoryIndex = categories.firstIndex(where: { $0.title == "Закрепленные" }) {
            var pinnedTrackers = categories[pinnedCategoryIndex].trackers
            pinnedTrackers.append(tracker)
            let newPinnedCategory = TrackerCategory(title: "Закрепленные", trackers: pinnedTrackers)
            categories[pinnedCategoryIndex] = newPinnedCategory
        } else {
            let pinnedCategory = TrackerCategory(title: "Закрепленные", trackers: [tracker])
            categories.insert(pinnedCategory, at: 0)
        }
        
        
        trackerCategoryStore.addTrackerToCategory(tracker: tracker, with: "Закрепленные")
        trackerCategoryStore.saveOriginalCategory(tracker: tracker, originalCategory: tracker.trackerCategory)
        
        visibleCategory = getVisibleCategories(from: categories)
        collectionView.reloadData()
        updateVisibleCategories()
    }
    
    private func unpinTracker(indexPath: IndexPath) {
        let tracker = visibleCategory[indexPath.section].trackers[indexPath.row]
        guard let pinnedCategoryIndex = categories.firstIndex(where: { $0.title == "Закрепленные" }) else { return }
        let oldPinnedCategory = categories[pinnedCategoryIndex]
        let newPinnedCategory = TrackerCategory(title: oldPinnedCategory.title, trackers: oldPinnedCategory.trackers.filter({ $0.id != tracker.id }))
        categories[pinnedCategoryIndex] = newPinnedCategory
        
        trackerCategoryStore.deleteTrackerFromCategory(tracker: tracker, with: "Закрепленные")
        
        visibleCategory = getVisibleCategories(from: categories)
        
        collectionView.reloadData()
        updateVisibleCategories()
    }
    
    private func editTracker(indexPath: IndexPath) {
        analyticsService.report(event: "click", params: ["screen": "Main", "item": "edit"])
        let trackerToEdit = visibleCategory[indexPath.section].trackers[indexPath.row]
        let habitViewController = NewHabitVC()
        habitViewController.trackerToEdit = trackerToEdit
        habitViewController.trackerVC = self
        
        let navigationController = UINavigationController(rootViewController: habitViewController)
        present(navigationController, animated: true)
        reloadHolders()
    }
    
    
    private func deleteTracker(indexPath: IndexPath) {
        analyticsService.report(event: "click", params: ["screen": "Main", "item": "delete"])
        let actionSheet = UIAlertController(title: localizedString(key: "actionSheetTitle"), message: nil, preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: localizedString(key: "deleteButton"), style: .destructive) { _ in
            let trackerForDelete = self.visibleCategory[indexPath.section].trackers[indexPath.row]
            
            self.trackerStore.deleteTracker(tracker: trackerForDelete)
            self.trackerRecordStore.deleteAllRecordFor(tracker: trackerForDelete)
            
            self.updateVisibleCategoryAfterDeletion(tracker: trackerForDelete, at: indexPath)
            
            self.collectionView.performBatchUpdates({
                self.collectionView.deleteItems(at: [indexPath])
                if self.visibleCategory.isEmpty || self.visibleCategory[indexPath.section].trackers.isEmpty {
                    self.collectionView.deleteSections(IndexSet(integer: indexPath.section))
                }
            }, completion: { _ in
                self.reloadHolders()
            })
        }
        
        let cancelAction = UIAlertAction(title: localizedString(key: "cancelButton"), style: .cancel)
        actionSheet.addAction(deleteAction)
        actionSheet.addAction(cancelAction)
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    private func updateVisibleCategoryAfterDeletion(tracker: Tracker, at indexPath: IndexPath) {
        let oldCategory = visibleCategory[indexPath.section]
        
        let updatedTrackers = oldCategory.trackers.filter { $0.id != tracker.id }
        
        if updatedTrackers.isEmpty {
            visibleCategory.remove(at: indexPath.section)
        } else {
            let updatedCategory = TrackerCategory(title: oldCategory.title, trackers: updatedTrackers)
            visibleCategory[indexPath.section] = updatedCategory
        }
    }
    
}

extension TrackerViewController: ReloadCollectionProtocol {
    func reloadCollection() {
        mainScreenContent(datePicker.date)
    }
}

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

extension TrackerViewController: CreateTrackerDelegate {
    func didDelegateNewTracker(_ tracker: Tracker, _ category: String) {
        print("didCreateNewHabit asked")
        createNewTracker(tracker: tracker)
        
        if let _ = trackerStore.addNewTracker(from: tracker) {
            trackerCategoryStore.createCategoryAndTracker(tracker: tracker, with: category)
        } else {
            print("Failed to save tracker")
        }
        loadTrackersFromCoreData()
    }
}

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
        visibleCategory = getVisibleCategories(from: categories)
        showTrackersInDate(currentDate)
        reloadHolders()
    }
}

extension TrackerViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filterTrackers(for: searchText)
        }
    }
}

extension TrackerViewController: FilterDelegate {
    func setFilter(_ filterState: FilterCase) {
        self.filterState = filterState
        
        switch filterState {
        case .all:
            isSearch = false
            visibleCategory = getVisibleCategories(from: categories)
        case .today:
            isSearch = false
            datePicker.date = Date()
            currentDate = datePicker.date
            showTrackersInDate(currentDate)
        case .complete:
            isSearch = true
            filterCompletedTrackers(isCompleted: true)
        case .uncomplete:
            isSearch = true
            filterCompletedTrackers(isCompleted: false)
        }
        
        reloadHolders()
        collectionView.reloadData()
    }
    
    private func filterCompletedTrackers(isCompleted: Bool) {
        var filteredCategories = [TrackerCategory]()
        
        for category in categories {
            let filteredTrackers = category.trackers.filter { tracker in
                let isTrackerCompleted = checkIsTrackerCompletedToday(id: tracker.id)
                return isCompleted ? isTrackerCompleted : !isTrackerCompleted
            }
            
            if !filteredTrackers.isEmpty {
                let newCategory = TrackerCategory(title: category.title, trackers: filteredTrackers)
                filteredCategories.append(newCategory)
            }
        }
        
        visibleCategory = getVisibleCategories(from: filteredCategories)
        collectionView.reloadData()
    }
}
