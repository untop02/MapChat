// 
//   CoreData.swift
//   MapChat
// 
//   Created by iosdev on 6.12.2023.
// 

import CoreData

//  Manages the Core Data stack for the application
class CoreDataStack {
    //  Shared instance of the CoreDataStack
    static let shared = CoreDataStack()

    //  Container for the Core Data stack, loads the persistent stores
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Messages")
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()

    //  Managed object context for accessing and manipulating Core Data entities
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    //  Saves changes in the managed object context
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

