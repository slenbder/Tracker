//
//  TrackerStore.swift
//  Tracker
//
//  Created by Кирилл Марьясов on 31.08.2024.
//

import Foundation
import CoreData
import UIKit

final class TrackerStore {
    
    private let context: NSManagedObjectContext
    
    convenience init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    public func addNewTracker(_ tracker: Tracker) throws {
        guard let trackerEntity = NSEntityDescription.entity(forEntityName: "TrackerCoreData", in: context) else {
            throw NSError(domain: "TrackerStore", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to find entity description"])
        }
        
        let newTracker = TrackerCoreData(entity: trackerEntity, insertInto: context)
        newTracker.id = tracker.id
        newTracker.title = tracker.title
        newTracker.color = UIColorMarshalling.hexString(from: tracker.color)
        newTracker.emoji = tracker.emoji
        newTracker.schedule = tracker.schedule as NSArray?
        
        do {
            try context.save()
        } catch {
            throw error
        }
    }
    
    public func fetchTrackers() -> [Tracker] {
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        do {
            let trackerCoreDataArray = try context.fetch(fetchRequest)
            let trackers = trackerCoreDataArray.compactMap { decodingTracker(from: $0) }
            return trackers
        } catch {
            print("Failed to fetch trackers: \(error)")
            return []
        }
    }
    
    internal func decodingTracker(from trackerCoreData: TrackerCoreData) -> Tracker? {
        guard let id = trackerCoreData.id,
              let title = trackerCoreData.title,
              let colorHex = trackerCoreData.color,
              let emoji = trackerCoreData.emoji else { return nil }
        
        let color = UIColorMarshalling.color(from: colorHex)
        let schedule = trackerCoreData.schedule as? [Weekday] ?? []
        
        return Tracker(id: id, title: title, color: color, emoji: emoji, schedule: schedule)
    }
}

extension TrackerStore {
    
    func fetchTrackerCoreData(by id: UUID) -> TrackerCoreData? {
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        do {
            let trackers = try context.fetch(fetchRequest)
            return trackers.first
        } catch {
            print("Failed to fetch tracker by ID: \(error)")
            return nil
        }
    }
}
