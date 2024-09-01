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
    guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else {
      fatalError("Не удалось получить NSManagedObjectContext")
    }
    self.init(context: context)
  }

  init(context: NSManagedObjectContext) {
    self.context = context
  }

  func addNewRecord(from trackerRecord: TrackerRecord) {
    guard let entity = NSEntityDescription.entity(forEntityName: "TrackerRecordCD", in: context) else {
      print("Не удалось найти сущность TrackerRecordCD")
      return
    }
    let newRecord = TrackerRecordCD(entity: entity, insertInto: context)
    newRecord.id = trackerRecord.trackerId
    newRecord.date = trackerRecord.date
    do {
      try context.save()
    } catch {
      print("Failed to save context: \(error)")
    }
  }

  func fetchAllRecords() -> [TrackerRecord] {
    let fetchRequest: NSFetchRequest<TrackerRecordCD> = TrackerRecordCD.fetchRequest()
    do {
      let trackerRecords = try context.fetch(fetchRequest)
      return trackerRecords.map {
        TrackerRecord(trackerId: $0.id ?? UUID(), date: $0.date ?? Date())
      }
    } catch {
      print("Failed to fetch tracker records: \(error)")
      return []
    }
  }

  func deleteRecord(for trackerRecord: TrackerRecord) {
    let fetchRequest: NSFetchRequest<TrackerRecordCD> = TrackerRecordCD.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "id == %@ AND date == %@", trackerRecord.trackerId as CVarArg, trackerRecord.date as CVarArg)
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
}
