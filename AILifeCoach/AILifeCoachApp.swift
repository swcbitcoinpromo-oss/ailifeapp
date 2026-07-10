//
//  AILifeCoachApp.swift
//  AILifeCoach
//
//  Phase 1 — app entry point with the Core Data stack.
//

import SwiftUI

@main
struct AILifeCoachApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
