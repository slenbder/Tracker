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
    private let trackerStore = TrackerStore()
    
    convenience override init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("AppDelegate is not of type AppDelegate")
        }
        let context = appDelegate.persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
}

extension TrackerCategoryStore {
    private func createCategory( _ category: TrackerCategory) {
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
    
    private func fetchAllCategories() -> [TrackerCategoryCoreData] {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        do {
            return try context.fetch(fetchRequest)
        } catch let error as NSError {
            print("Failed to fetch categories: \(error), \(error.userInfo)")
            return []
        }
    }
    
    private func decodingCategory(from trackerCategoryCoreData: TrackerCategoryCoreData) -> TrackerCategory? {
        guard let title = trackerCategoryCoreData.title else { return nil }
        let trackers = (trackerCategoryCoreData.trackers?.allObjects as? [TrackerCoreData])?.compactMap { trackerStore.decodingTrackersPublic(from: $0) } ?? []
        return TrackerCategory(title: CategoryList(rawValue: title) ?? .usefull, trackers: trackers)
    }
    
    
    private func createCategoryAndTracker(tracker: Tracker, with titleCategory: String) {
        guard let trackerCoreData = trackerStore.addNewTrackerPublic(from: tracker) else { return }
        guard let existingCategory = fetchCategory(with: titleCategory) else { return }
        var existingTrackers = existingCategory.trackers?.allObjects as? [TrackerCoreData] ?? []
        existingTrackers.append(trackerCoreData)
        existingCategory.trackers = NSSet(array: existingTrackers)
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
    
    private func fetchCategory(with title: String) -> TrackerCategoryCoreData? {
        return fetchAllCategories().filter({$0.title == title}).first ?? nil
    }
    
    private func createCategoryAndAddTracker(_ tracker: Tracker, with titleCategory: String) {
        guard let category = fetchCategory(with: titleCategory) ?? createCategory(with: titleCategory) else {
            print("Failed to fetch or create category")
            return
        }
        guard let trackerCoreData = trackerStore.addNewTrackerPublic(from: tracker) else {
            print("Failed to add new tracker")
            return
        }
        category.addToTrackers(trackerCoreData)
        
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
    
    private func createCategory(with title: String) -> TrackerCategoryCoreData? {
        guard let entity = NSEntityDescription.entity(forEntityName: "TrackerCategoryCoreData", in: context) else {
            print("Failed to create entity for TrackerCategoryCoreData")
            return nil
        }
        let newCategory = TrackerCategoryCoreData(entity: entity, insertInto: context)
        newCategory.title = title
        newCategory.trackers = NSSet(array: [])
        return newCategory
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdateData(in: self)
    }
}

// MARK: - Public Accessors (Repite Methods)

extension TrackerCategoryStore {
    func fetchAllCategoriesPublic() -> [TrackerCategoryCoreData] {
        return fetchAllCategories()
    }
    
    func decodeCategoryPublic(from trackerCategoryCoreData: TrackerCategoryCoreData) -> TrackerCategory? {
        return decodingCategory(from: trackerCategoryCoreData)
    }
    
    func createCategoryAndTrackerPublic(tracker: Tracker, with titleCategory: String) {
            createCategoryAndTracker(tracker: tracker, with: titleCategory)
        }
    
}
