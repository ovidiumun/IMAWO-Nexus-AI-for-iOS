//
//  DataController.swift
//  IMAWO Nexus AI
//
//  Created by Ovidiu Muntean on 05.10.2023.
//

import Foundation
import CoreData

class PersistenceController: ObservableObject {
    
    static let shared = PersistenceController()
    let container = NSPersistentCloudKitContainer(name: "IMAWO_Nexus_AI")
    let context: NSManagedObjectContext
    
    init(){
        guard let description = container.persistentStoreDescriptions.first else{
            fatalError("###\(#function): Failed to retrieve a persistent store description.")
        }
        
        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        
        // Generate NOTIFICATIONS on remote changes
        description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        do {
            // Use the container to initialize the development schema.
            try container.initializeCloudKitSchema(options: [])
            print("iCloudKit schema initialization succeeded")
        } catch {
            print("Core Data error: \(error)")
            print("Failed to initialize iCloudKit: \(error.localizedDescription)")
        }
        
        context = container.viewContext
        
        print("CoreData is initialized")
    }
}
