//
//  DiaryEntry.swift
//  NurseryConnectParent
//
//  Created on April 18, 2026
//

import Foundation
import SwiftData

enum DiaryEntryType: String, Codable, CaseIterable {
    case meal = "Meal"
    case nap = "Nap"
    case activity = "Activity"
    case mood = "Mood"
    case milestone = "Milestone"
    case incident = "Incident"
    
    var icon: String {
        switch self {
        case .meal: return "fork.knife"
        case .nap: return "moon.fill"
        case .activity: return "figure.play"
        case .mood: return "face.smiling"
        case .milestone: return "star.fill"
        case .incident: return "exclamationmark.triangle.fill"
        }
    }
}

@Model
final class DiaryEntry {
    var id: UUID
    var childId: UUID
    var type: DiaryEntryType
    var timestamp: Date
    var title: String
    var details: String
    var notes: String
    var staffName: String
    
    init(
        id: UUID = UUID(),
        childId: UUID,
        type: DiaryEntryType,
        timestamp: Date,
        title: String,
        details: String,
        notes: String = "",
        staffName: String = "Staff Member"
    ) {
        self.id = id
        self.childId = childId
        self.type = type
        self.timestamp = timestamp
        self.title = title
        self.details = details
        self.notes = notes
        self.staffName = staffName
    }
}

