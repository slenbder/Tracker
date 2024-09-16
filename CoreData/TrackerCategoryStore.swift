//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Кирилл Марьясов on 31.08.2024.
//

import Foundation
import CoreData
import UIKit

protocol TrackerCategoryStoreDelegate: AnyObject {
    func didUpdateData(in store: TrackerCategoryStore)
}

final class TrackerCategoryStore: NSObject {
    weak var delegate: TrackerCategoryStoreDelegate?
    private let context: NSManagedObjectContext
    private let trackerStore: TrackerStore

    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }

    init(context: NSManagedObjectContext) {
            self.context = context
            self.trackerStore = TrackerStore(context: context)
            super.init()
        }
}

// MARK: - Public Methods

extension TrackerCategoryStore {

    func createCategory(_ category: TrackerCategory) {
        guard let entity = NSEntityDescription.entity(forEntityName: "TrackerCategoryCoreData", in: context) else { return }
        let categoryEntity = TrackerCategoryCoreData(entity: entity, insertInto: context)
        categoryEntity.title = category.title.rawValue
        categoryEntity.trackers = NSSet(array: [])
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }

    func fetchAllCategories() -> [TrackerCategory] {
        let fetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        do {
            let categoriesCoreData = try context.fetch(fetchRequest)
            let categories = categoriesCoreData.compactMap { decodingCategory(from: $0) }
            return categories
        } catch {
            print("Failed to fetch categories: \(error)")
            return []
        }
    }


    func createCategoryAndTracker(tracker: Tracker, with titleCategory: String) {
        do {
            let category = fetchOrCreateCategory(with: titleCategory)
            
            try trackerStore.addNewTracker(tracker)
          
            guard let trackerCoreData = trackerStore.fetchTrackerCoreData(by: tracker.id) else { return }
            category.addToTrackers(trackerCoreData)
            try context.save()
        } catch {
            print("Failed to create category and tracker: \(error)")
        }
    }

    func createCategoryAndAddTracker(_ tracker: Tracker, with titleCategory: String) {
        do {
            let category = fetchOrCreateCategory(with: titleCategory)
            try trackerStore.addNewTracker(tracker)
            guard let trackerCoreData = trackerStore.fetchTrackerCoreData(by: tracker.id) else { return }
            category.addToTrackers(trackerCoreData)
            try context.save()
        } catch {
            print("Failed to add tracker to category: \(error)")
        }
    }
}

// MARK: - Private Methods

extension TrackerCategoryStore {

    private func decodingCategory(from trackerCategoryCoreData: TrackerCategoryCoreData) -> TrackerCategory? {
        guard let title = trackerCategoryCoreData.title else { return nil }
        guard let trackersCoreDataSet = trackerCategoryCoreData.trackers as? Set<TrackerCoreData> else { return nil }

        let trackers = trackersCoreDataSet.compactMap { trackerCoreData in
            return trackerStore.decodingTracker(from: trackerCoreData)
        }

        return TrackerCategory(title: CategoryList(rawValue: title) ?? .usefull, trackers: trackers)
    }

    private func fetchOrCreateCategory(with title: String) -> TrackerCategoryCoreData {
        if let existingCategory = fetchCategory(with: title) {
            return existingCategory
        } else {
            return createCategoryEntity(with: title)
        }
    }

    private func fetchCategory(with title: String) -> TrackerCategoryCoreData? {
        let fetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        fetchRequest.predicate = NSPredicate(format: "title == %@", title)
        do {
            let categories = try context.fetch(fetchRequest)
            return categories.first
        } catch {
            print("Failed to fetch category: \(error)")
            return nil
        }
    }

    private func createCategoryEntity(with title: String) -> TrackerCategoryCoreData {
        let entity = NSEntityDescription.entity(forEntityName: "TrackerCategoryCoreData", in: context)!
        let newCategory = TrackerCategoryCoreData(entity: entity, insertInto: context)
        newCategory.title = title
        newCategory.trackers = NSSet(array: [])
        return newCategory
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdateData(in: self)
    }
}
