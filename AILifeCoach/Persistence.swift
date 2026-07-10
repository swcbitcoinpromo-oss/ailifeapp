//
//  Persistence.swift
//  AILifeCoach
//
//  Phase 1 — Core Data stack. (SwiftData needs iOS 17 / Xcode 15;
//  this Mac runs Xcode 14.2, so the brief's Core Data option is used.)
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "AILifeCoach")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { _, error in
            if let error {
                fatalError("Core Data store failed to load: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
