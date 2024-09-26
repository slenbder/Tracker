//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Кирилл Марьясов on 31.08.2024.
//

import CoreData
import UIKit


final class TrackerRecordStore {
    
    private let context: NSManagedObjectContext
    
    convenience init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("AppDelegate is not of type AppDelegate")
        }
        let context = appDelegate.persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func addNewRecord(from trackerRecord: TrackerRecorder) {
        guard let entity = NSEntityDescription.entity(forEntityName: "TrackerRecordCoreData", in: context) else { return }
        let newRecord = TrackerRecordCoreData(entity: entity, insertInto: context)
        newRecord.id = trackerRecord.id
        newRecord.date = trackerRecord.date
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
    
    func fetchAllRecords() -> [TrackerRecorder] {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        do {
            let trackerRecords = try context.fetch(fetchRequest)
            return trackerRecords.map { TrackerRecorder(id: $0.id ?? UUID(), date: $0.date ?? Date()) }
        } catch {
            print("Failed to fetch tracker records: \(error)")
            return []
        }
    }
    
    func deleteAllRecordFor(tracker: Tracker) {
        let fetchRequest = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        fetchRequest.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
        do {
            let records = try context.fetch(fetchRequest)
            for recordToDelete in records {
                context.delete(recordToDelete)
            }
            try context.save()
        } catch {
            print("Error deleting records: \(error.localizedDescription)")
        }
    }
    
    func deleteRecord(for trackerRecord: TrackerRecorder) {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@ AND date == %@", trackerRecord.id as CVarArg, trackerRecord.date as CVarArg)
        do {
            let results = try context.fetch(fetchRequest)
            if let recordToDelete = results.first {
                context.delete(recordToDelete)
                try context.save()
                print("Record deleted: \(trackerRecord)")
            } else {
                print("Record not found: \(trackerRecord)")
            }
        } catch {
            print("Failed to delete record: \(error)")
        }
    }
    
    func fetchRecords() -> [TrackerRecorder] {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return [] }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        
        do {
            let trackerRecordCoreDataArray = try managedContext.fetch(fetchRequest)
            let trackerRecords = trackerRecordCoreDataArray.map { trackerRecordCoreData in
                return TrackerRecorder(
                    id: trackerRecordCoreData.id ?? UUID(),
                    date: trackerRecordCoreData.date ?? Date()
                )
            }
            return trackerRecords
        } catch {
            print("Failed to fetch records: \(error.localizedDescription)")
            return []
        }
    }
    
}
