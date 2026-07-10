//
//  CalendarTabView.swift
//  AILifeCoach
//
//  Phase 1 — manual event CRUD on Core Data.
//  Phase 2 replaces manual entry with Claude-parsed events + pattern detection.
//

import SwiftUI
import CoreData

struct CalendarTabView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \CalendarEvent.start, ascending: true)])
    private var events: FetchedResults<CalendarEvent>
    @State private var showingAddEvent = false

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Calendar")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            showingAddEvent = true
                        } label: {
                            Label("Add Event", systemImage: "plus")
                        }
                    }
                }
                .sheet(isPresented: $showingAddEvent) {
                    AddEventSheet()
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        if events.isEmpty {
            EmptyCalendarView(onAdd: { showingAddEvent = true })
        } else {
            eventList
        }
    }

    private var eventList: some View {
        List {
            ForEach(events, id: \.objectID) { event in
                EventRow(event: event)
            }
            .onDelete(perform: deleteEvents)
        }
    }

    private func deleteEvents(at offsets: IndexSet) {
        for index in offsets {
            viewContext.delete(events[index])
        }
        try? viewContext.save()
    }
}

// MARK: - Empty state

private struct EmptyCalendarView: View {
    let onAdd: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("No events yet")
                .font(.title3.weight(.semibold))
            Text("Add events manually for now. In Phase 2, your notes parse into events automatically.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Button("Add Event", action: onAdd)
                .buttonStyle(.borderedProminent)
                .padding(.top, 4)
        }
    }
}

// MARK: - Row

private struct EventRow: View {
    @ObservedObject var event: CalendarEvent

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE d MMM, HH:mm"
        return formatter
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            titleRow
            Text(Self.dateFormatter.string(from: event.start))
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 2)
    }

    private var titleRow: some View {
        HStack {
            Text(event.title)
                .font(.headline)
            if event.needsConfirmation {
                Text("Confirm?")
                    .font(.caption2.weight(.semibold))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.yellow.opacity(0.25))
                    .clipShape(Capsule())
            }
            Spacer()
            Text(event.domain.capitalized)
                .font(.caption.weight(.medium))
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(domainColor.opacity(0.15))
                .clipShape(Capsule())
                .foregroundColor(domainColor)
        }
    }

    private var domainColor: Color {
        switch event.domain {
        case "gym":
            return .orange
        case "nutrition":
            return .green
        default:
            return .blue
        }
    }
}

// MARK: - Add sheet

private struct AddEventSheet: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var domain = "general"
    @State private var start = Date.now
    @State private var durationMinutes = 60

    private let domains = ["general", "gym", "nutrition"]

    private var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $title)
                Picker("Domain", selection: $domain) {
                    ForEach(domains, id: \.self) { value in
                        Text(value.capitalized).tag(value)
                    }
                }
                DatePicker("Starts", selection: $start)
                Stepper("Duration: \(durationMinutes) min", value: $durationMinutes, in: 15...240, step: 15)
            }
            .navigationTitle("New Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add", action: addEvent)
                        .disabled(trimmedTitle.isEmpty)
                }
            }
        }
    }

    private func addEvent() {
        let end = start.addingTimeInterval(TimeInterval(durationMinutes * 60))
        CalendarEvent.create(
            in: viewContext,
            title: trimmedTitle,
            start: start,
            end: end,
            source: "manual",
            domain: domain
        )
        try? viewContext.save()
        dismiss()
    }
}
