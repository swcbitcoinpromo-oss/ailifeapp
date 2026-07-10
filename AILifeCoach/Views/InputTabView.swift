//
//  InputTabView.swift
//  AILifeCoach
//
//  Phase 1 — domain input screens with local storage.
//  Gym and Food entries persist as WorkoutLog / FoodLog records.
//  Schedule notes stay a draft until Phase 2, when Claude parses them into events.
//

import SwiftUI
import UIKit
import CoreData

struct InputTabView: View {
    private enum Domain: String, CaseIterable, Identifiable {
        case schedule = "Schedule"
        case gym = "Gym"
        case food = "Food"

        var id: String { rawValue }
    }

    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: []) private var foodLogs: FetchedResults<FoodLog>
    @FetchRequest(sortDescriptors: []) private var workoutLogs: FetchedResults<WorkoutLog>

    @State private var selectedDomain: Domain = .schedule
    @AppStorage("scheduleNotesDraft") private var scheduleDraft = ""
    @State private var gymText = ""
    @State private var foodText = ""
    @State private var confirmation: String?

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                Picker("Domain", selection: $selectedDomain) {
                    ForEach(Domain.allCases) { domain in
                        Text(domain.rawValue).tag(domain)
                    }
                }
                .pickerStyle(.segmented)

                Text(caption)
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                TextEditor(text: editorBinding)
                    .scrollContentBackground(.hidden)
                    .padding(8)
                    .frame(minHeight: 180, maxHeight: 260)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(12)

                Button(action: save) {
                    Text(saveButtonTitle)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(saveDisabled)

                if let confirmation {
                    Label(confirmation, systemImage: "checkmark.circle.fill")
                        .font(.footnote)
                        .foregroundStyle(.green)
                }

                Spacer()

                Text("\(workoutLogs.count) workout logs · \(foodLogs.count) food logs stored locally")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding()
            .navigationTitle("Input")
            .onChange(of: selectedDomain) { _ in
                confirmation = nil
            }
        }
    }

    // MARK: - Per-domain state

    private var editorBinding: Binding<String> {
        switch selectedDomain {
        case .schedule:
            return $scheduleDraft
        case .gym:
            return $gymText
        case .food:
            return $foodText
        }
    }

    private var caption: String {
        switch selectedDomain {
        case .schedule:
            return "Brain-dump your plans in plain text. In Phase 2 these notes parse into calendar events automatically."
        case .gym:
            return "Log today's training — exercises, sets, weights. Forge reads this in Phase 3."
        case .food:
            return "Log what you ate — meals, snacks, rough portions. Sage reads this in Phase 3."
        }
    }

    private var saveButtonTitle: String {
        switch selectedDomain {
        case .schedule:
            return "Save Draft"
        case .gym:
            return "Log Workout"
        case .food:
            return "Log Food"
        }
    }

    private var saveDisabled: Bool {
        switch selectedDomain {
        case .schedule:
            return scheduleDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .gym:
            return gymText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .food:
            return foodText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }

    // MARK: - Actions

    private func save() {
        switch selectedDomain {
        case .schedule:
            confirmation = "Draft saved. Parsing into events arrives in Phase 2."
        case .gym:
            let trimmed = gymText.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return }
            WorkoutLog.create(in: viewContext, exercises: trimmed)
            try? viewContext.save()
            gymText = ""
            confirmation = "Workout logged."
        case .food:
            let trimmed = foodText.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return }
            FoodLog.create(in: viewContext, entries: trimmed)
            try? viewContext.save()
            foodText = ""
            confirmation = "Food logged."
        }
    }
}
