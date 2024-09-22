//
//  AppDelegate.swift
//  Tracker
//
//  Created by Кирилл Марьясов on 28.06.2024.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    // MARK: - Application Lifecycle
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        AnalyticsService.activate()
        return true
    }

    // MARK: - UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Here you can release any resources specific to the discarded scenes
    }

    // MARK: - Core Data Stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Tracker") // Ensure that the model name "Tracker" matches your .xcdatamodeld file
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // This should be logged and reported properly in production apps
                print("🔴 Unresolved error: \(error), \(error.userInfo)")
            } else {
                print("✅ Core Data loaded successfully: \(storeDescription)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving Support
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                // Logging the error and failing gracefully, instead of calling fatalError
                print("🔴 Error saving context: \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
