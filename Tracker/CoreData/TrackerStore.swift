//
//  TrackerStore.swift
//  Tracker
//
//  Created by Кирилл Марьясов on 31.08.2024.
//

import Foundation
import CoreData
import UIKit

// MARK: - TrackerStore

final class TrackerStore {
    
    // MARK: - Properties
    
    private let context: NSManagedObjectContext
    
    // MARK: - Initializers
    
    convenience init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Unable to cast UIApplication.shared.delegate to AppDelegate")
        }
        let context = appDelegate.persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // MARK: - Public Methods
    
    func addNewTracker(from tracker: Tracker) -> TrackerCoreData? {
        guard let trackerCoreData = NSEntityDescription.entity(forEntityName: "TrackerCoreData", in: context) else { return nil }
        let newTracker = TrackerCoreData(entity: trackerCoreData, insertInto: context)
        newTracker.id = tracker.id
        newTracker.title = tracker.title
        newTracker.color = UIColorMarshalling.hexString(from: tracker.color)
        newTracker.emoji = tracker.emoji
        newTracker.schedule = tracker.schedule as NSArray?
        newTracker.trackerCategory = tracker.trackerCategory
        
        do {
            try context.save()
        } catch {
            print("Ошибка сохранения трекера: \(error)")
        }
        
        return newTracker
    }
    
    func fetchTracker() -> [Tracker] {
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        do {
            let trackerCoreDataArray = try context.fetch(fetchRequest)
            let trackers = trackerCoreDataArray.map { trackerCoreData in
                return Tracker(
                    id: trackerCoreData.id ?? UUID(),
                    title: trackerCoreData.title ?? "",
                    color: UIColorMarshalling.color(from: trackerCoreData.color ?? ""),
                    emoji: trackerCoreData.emoji ?? "",
                    schedule: trackerCoreData.schedule as? [Weekday] ?? [],
                    trackerCategory: trackerCoreData.trackerCategory ?? ""
                )
            }
            return trackers
        } catch {
            print("Failed to fetch trackers: \(error)")
            return []
        }
    }
    
    func fetchRawTrackers() -> [TrackerCoreData] {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return [] }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        let trackerCoreDataArray = try! managedContext.fetch(fetchRequest)
        return trackerCoreDataArray
    }
    
    func deleteTracker(tracker: Tracker) {
        let targetTrackers = fetchRawTrackers()
        if let index = targetTrackers.firstIndex(where: {$0.id == tracker.id}) {
            context.delete(targetTrackers[index])
        }
    }
    
    func updateTracker(tracker: Tracker) {
        let targetTrackers = fetchRawTrackers()
        if let index = targetTrackers.firstIndex(where: {$0.id == tracker.id}) {
            targetTrackers[index].title = tracker.title
            targetTrackers[index].color = UIColorMarshalling.hexString(from: tracker.color)
            targetTrackers[index].emoji = tracker.emoji
            targetTrackers[index].schedule = tracker.schedule as NSArray?
            targetTrackers[index].trackerCategory = tracker.trackerCategory
            
            do {
                try context.save()
            } catch {
                print("Failed to update tracker: \(error)")
            }
        }
    }
    
    func decodingTrackers(from trackersCoreData: TrackerCoreData) -> Tracker? {
        guard let id = trackersCoreData.id, let title = trackersCoreData.title,
              let color = trackersCoreData.color, let emoji = trackersCoreData.emoji else { return nil }
        return Tracker(id: id, title: title, color: UIColorMarshalling.color(from: color), emoji: emoji, schedule: trackersCoreData.schedule as? [Weekday] ?? [],trackerCategory: trackersCoreData.trackerCategory ?? "")
    }
}
