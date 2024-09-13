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
    func createCategory( _ category: TrackerCategory) {
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
    
    func fetchAllCategories() -> [TrackerCategoryCoreData] {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        do {
            return try context.fetch(fetchRequest)
        } catch let error as NSError {
            print("Failed to fetch categories: \(error), \(error.userInfo)")
            return []
        }
    }
    
    func decodingCategory(from trackerCategoryCoreData: TrackerCategoryCoreData) -> TrackerCategory? {
        guard let title = trackerCategoryCoreData.title else { return nil }
        let trackers = (trackerCategoryCoreData.trackers?.allObjects as? [TrackerCoreData])?.compactMap { trackerStore.decodingTrackers(from: $0) } ?? []
        return TrackerCategory(title: CategoryList(rawValue: title) ?? .usefull, trackers: trackers)
    }
    
    
    func createCategoryAndTracker(tracker: Tracker, with titleCategory: String) {
        guard let trackerCoreData = trackerStore.addNewTracker(from: tracker) else { return }
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
    func createCategoryAndAddTracker(_ tracker: Tracker, with titleCategory: String) {
        let category = fetchCategory(with: titleCategory) ?? createCategory(with: titleCategory)
        guard let trackerCoreData = trackerStore.addNewTracker(from: tracker) else { return }
        category.addToTrackers(trackerCoreData)
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
    
    private func createCategory(with title: String) -> TrackerCategoryCoreData {
        let entity = NSEntityDescription.entity(forEntityName: "TrackerCategoryCoreData", in: context)!
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
