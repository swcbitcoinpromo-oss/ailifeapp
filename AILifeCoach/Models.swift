//
//  Models.swift
//  AILifeCoach
//
//  Phase 1 stubs of the core data objects (build brief §6), as Core Data
//  NSManagedObject subclasses. Entities are defined in AILifeCoach.xcdatamodeld
//  (codegen: Manual/None — these classes are the source of truth).
//  Raw-text fields become structured data in Phase 2 (Claude parsing).
//

import Foundation
import CoreData

// MARK: - User profile & goals

@objc(UserProfile)
public class UserProfile: NSManagedObject {
    /// e.g. "bulk", "cut", "maintain"
    @NSManaged public var goal: String
    /// e.g. "beginner", "intermediate", "advanced"
    @NSManaged public var level: String
    @NSManaged public var scheduleConstraints: String
    @NSManaged public var dietaryConstraints: String
    @NSManaged public var injuryNotes: String
    @NSManaged public var createdAt: Date
}

extension UserProfile {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserProfile> {
        NSFetchRequest<UserProfile>(entityName: "UserProfile")
    }

    @discardableResult
    static func create(
        in context: NSManagedObjectContext,
        goal: String = "",
        level: String = "",
        scheduleConstraints: String = "",
        dietaryConstraints: String = "",
        injuryNotes: String = ""
    ) -> UserProfile {
        let profile = UserProfile(context: context)
        profile.goal = goal
        profile.level = level
        profile.scheduleConstraints = scheduleConstraints
        profile.dietaryConstraints = dietaryConstraints
        profile.injuryNotes = injuryNotes
        profile.createdAt = .now
        return profile
    }
}

// MARK: - Calendar event

@objc(CalendarEvent)
public class CalendarEvent: NSManagedObject {
    @NSManaged public var title: String
    @NSManaged public var start: Date
    @NSManaged public var end: Date?
    /// e.g. "weekly:monday" — nil means one-off. Structured recurrence lands in Phase 2.
    @NSManaged public var recurrence: String?
    /// "manual" | "parsed" | "coach"
    @NSManaged public var source: String
    /// "general" | "gym" | "nutrition"
    @NSManaged public var domain: String
    /// Auto-detected recurring patterns are never silently committed.
    @NSManaged public var needsConfirmation: Bool
}

extension CalendarEvent {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CalendarEvent> {
        NSFetchRequest<CalendarEvent>(entityName: "CalendarEvent")
    }

    @discardableResult
    static func create(
        in context: NSManagedObjectContext,
        title: String,
        start: Date,
        end: Date? = nil,
        recurrence: String? = nil,
        source: String = "manual",
        domain: String = "general",
        needsConfirmation: Bool = false
    ) -> CalendarEvent {
        let event = CalendarEvent(context: context)
        event.title = title
        event.start = start
        event.end = end
        event.recurrence = recurrence
        event.source = source
        event.domain = domain
        event.needsConfirmation = needsConfirmation
        return event
    }
}

// MARK: - Food log

@objc(FoodLog)
public class FoodLog: NSManagedObject {
    @NSManaged public var date: Date
    /// Raw text for Phase 1; parsed entries/macros come later.
    @NSManaged public var entries: String
    @NSManaged public var notes: String
}

extension FoodLog {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<FoodLog> {
        NSFetchRequest<FoodLog>(entityName: "FoodLog")
    }

    @discardableResult
    static func create(in context: NSManagedObjectContext, entries: String, notes: String = "") -> FoodLog {
        let log = FoodLog(context: context)
        log.date = .now
        log.entries = entries
        log.notes = notes
        return log
    }
}

// MARK: - Workout log

@objc(WorkoutLog)
public class WorkoutLog: NSManagedObject {
    @NSManaged public var date: Date
    /// Raw text for Phase 1; structured exercises/volume come later.
    @NSManaged public var exercises: String
    @NSManaged public var volumeNotes: String
}

extension WorkoutLog {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<WorkoutLog> {
        NSFetchRequest<WorkoutLog>(entityName: "WorkoutLog")
    }

    @discardableResult
    static func create(in context: NSManagedObjectContext, exercises: String, volumeNotes: String = "") -> WorkoutLog {
        let log = WorkoutLog(context: context)
        log.date = .now
        log.exercises = exercises
        log.volumeNotes = volumeNotes
        return log
    }
}

// MARK: - Coach recommendation

@objc(CoachRecommendation)
public class CoachRecommendation: NSManagedObject {
    /// "atlas" | "forge" | "sage" — original characters, defined in the coach prompts doc.
    @NSManaged public var coach: String
    @NSManaged public var date: Date
    @NSManaged public var recommendation: String
    /// "pending" | "applied" | "dismissed"
    @NSManaged public var status: String
}

extension CoachRecommendation {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoachRecommendation> {
        NSFetchRequest<CoachRecommendation>(entityName: "CoachRecommendation")
    }

    @discardableResult
    static func create(
        in context: NSManagedObjectContext,
        coach: String,
        recommendation: String,
        status: String = "pending"
    ) -> CoachRecommendation {
        let rec = CoachRecommendation(context: context)
        rec.coach = coach
        rec.date = .now
        rec.recommendation = recommendation
        rec.status = status
        return rec
    }
}

// MARK: - Briefing record

@objc(BriefingRecord)
public class BriefingRecord: NSManagedObject {
    @NSManaged public var date: Date
    @NSManaged public var script: String
    /// Server URL of the generated briefing video (Phase 5).
    @NSManaged public var videoURL: String?
    @NSManaged public var played: Bool
}

extension BriefingRecord {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<BriefingRecord> {
        NSFetchRequest<BriefingRecord>(entityName: "BriefingRecord")
    }

    @discardableResult
    static func create(in context: NSManagedObjectContext, script: String, videoURL: String? = nil) -> BriefingRecord {
        let briefing = BriefingRecord(context: context)
        briefing.date = .now
        briefing.script = script
        briefing.videoURL = videoURL
        briefing.played = false
        return briefing
    }
}
