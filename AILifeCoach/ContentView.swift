//
//  ContentView.swift
//  AILifeCoach
//
//  Phase 1 — three-tab skeleton: Calendar, Coaches, Input.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            CalendarTabView()
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
            CoachesTabView()
                .tabItem {
                    Label("Coaches", systemImage: "person.3.fill")
                }
            InputTabView()
                .tabItem {
                    Label("Input", systemImage: "square.and.pencil")
                }
        }
    }
}
