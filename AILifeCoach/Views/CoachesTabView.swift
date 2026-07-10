//
//  CoachesTabView.swift
//  AILifeCoach
//
//  Phase 1 — placeholder cards for the three coaches.
//  All three are ORIGINAL characters (build brief §2) — archetypes, not real people.
//  The coaching engine (shared state + orchestrator) arrives in Phase 3.
//

import SwiftUI

struct CoachesTabView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    CoachCard(
                        name: "Atlas",
                        role: "Calendar & Life Organisation",
                        blurb: "Calm, sharp, economical with words. Turns your raw notes into a clean, conflict-free schedule and protects your time.",
                        icon: "calendar.badge.clock",
                        color: .blue
                    )
                    CoachCard(
                        name: "Forge",
                        role: "Gym & Physical Performance",
                        blurb: "Intense, high-energy, believes in you completely. Sets the training focus and programs progression — pushes the edge, never breaks it.",
                        icon: "dumbbell.fill",
                        color: .orange
                    )
                    CoachCard(
                        name: "Sage",
                        role: "Health & Nutrition",
                        blurb: "Measured, precise, explains the why. Aligns your fuel with your goal — always sustainable, never extreme.",
                        icon: "leaf.fill",
                        color: .green
                    )
                } footer: {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("All three coaches are original characters. They come online in Phase 3, coordinating through shared state to push one set of goals.")
                        Text("Health guidance is general wellness information, not medical advice.")
                    }
                    .font(.footnote)
                    .padding(.top, 4)
                }
            }
            .navigationTitle("Coaches")
        }
    }
}

// MARK: - Card

private struct CoachCard: View {
    let name: String
    let role: String
    let blurb: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(color.gradient, in: RoundedRectangle(cornerRadius: 10))
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.headline)
                Text(role)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(blurb)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.top, 2)
            }
        }
        .padding(.vertical, 6)
    }
}
