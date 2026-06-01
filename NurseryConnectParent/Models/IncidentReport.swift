//
//  IncidentReport.swift
//  NurseryConnectParent
//
//  Created on June 1, 2026
//

import Foundation
import SwiftData

// MARK: - Supporting Enums

enum IncidentCategory: String, Codable, CaseIterable {
    case fall = "Fall / Trip"
    case allergy = "Allergic Reaction"
    case behaviour = "Behaviour Incident"
    case medical = "Medical"
    case equipment = "Equipment / Environment"
    case other = "Other"

    var icon: String {
        switch self {
        case .fall:      return "figure.fall"
        case .allergy:   return "allergens"
        case .behaviour: return "exclamationmark.bubble.fill"
        case .medical:   return "cross.case.fill"
        case .equipment: return "wrench.and.screwdriver.fill"
        case .other:     return "questionmark.circle.fill"
        }
    }

    var color: String {
        switch self {
        case .fall:      return "orange"
        case .allergy:   return "red"
        case .behaviour: return "purple"
        case .medical:   return "blue"
        case .equipment: return "brown"
        case .other:     return "gray"
        }
    }
}

enum IncidentSeverity: String, Codable, CaseIterable {
    case minor    = "Minor"
    case moderate = "Moderate"
    case serious  = "Serious"

    var icon: String {
        switch self {
        case .minor:    return "1.circle.fill"
        case .moderate: return "2.circle.fill"
        case .serious:  return "3.circle.fill"
        }
    }

    var color: String {
        switch self {
        case .minor:    return "green"
        case .moderate: return "orange"
        case .serious:  return "red"
        }
    }

    /// Display order for sorting (lower = less severe)
    var sortOrder: Int {
        switch self {
        case .minor:    return 0
        case .moderate: return 1
        case .serious:  return 2
        }
    }
}

// MARK: - IncidentReport Model

@Model
final class IncidentReport {

    // MARK: Identity
    var id: UUID
    var childId: UUID
    var childName: String

    // MARK: Incident Details
    var title: String
    var category: IncidentCategory
    var severity: IncidentSeverity
    var date: Date
    var location: String
    var incidentDescription: String
    var immediateActionTaken: String
    var witnesses: String
    var affectedBodyArea: String

    // MARK: Management
    var managerApproved: Bool
    var managerName: String
    var createdAt: Date
    var lastModified: Date

    // MARK: Parent Acknowledgement
    var parentAcknowledged: Bool
    var acknowledgementDate: Date?

    /// Serialised PKDrawing bytes.
    /// Stored with .externalStorage to keep the main SQLite rows small.
    @Attribute(.externalStorage)
    var signatureData: Data?

    // MARK: - Init

    init(
        id: UUID = UUID(),
        childId: UUID,
        childName: String,
        title: String,
        category: IncidentCategory,
        severity: IncidentSeverity,
        date: Date = Date(),
        location: String,
        incidentDescription: String,
        immediateActionTaken: String = "",
        witnesses: String = "",
        affectedBodyArea: String = "",
        managerApproved: Bool = false,
        managerName: String = "",
        createdAt: Date = Date(),
        lastModified: Date = Date(),
        parentAcknowledged: Bool = false,
        acknowledgementDate: Date? = nil,
        signatureData: Data? = nil
    ) {
        self.id = id
        self.childId = childId
        self.childName = childName
        self.title = title
        self.category = category
        self.severity = severity
        self.date = date
        self.location = location
        self.incidentDescription = incidentDescription
        self.immediateActionTaken = immediateActionTaken
        self.witnesses = witnesses
        self.affectedBodyArea = affectedBodyArea
        self.managerApproved = managerApproved
        self.managerName = managerName
        self.createdAt = createdAt
        self.lastModified = lastModified
        self.parentAcknowledged = parentAcknowledged
        self.acknowledgementDate = acknowledgementDate
        self.signatureData = signatureData
    }
}

// MARK: - Helper Extensions

extension IncidentReport {

    /// Whether this report is waiting for the parent to sign.
    var isPendingAcknowledgement: Bool {
        !parentAcknowledged
    }

    /// Formatted date string used across cards and detail views.
    var formattedDate: String {
        date.formatted(date: .long, time: .shortened)
    }

    /// One-line summary for list rows and notifications.
    var summary: String {
        "\(category.rawValue) — \(severity.rawValue)"
    }
}

// MARK: - Collection Helpers

extension [IncidentReport] {

    /// Reports still awaiting parent acknowledgement.
    var pendingAcknowledgement: [IncidentReport] {
        filter { !$0.parentAcknowledged }
    }

    /// Reports already acknowledged by the parent.
    var acknowledged: [IncidentReport] {
        filter { $0.parentAcknowledged }
    }

    /// Reports matching a specific category.
    func filtered(by category: IncidentCategory) -> [IncidentReport] {
        filter { $0.category == category }
    }

    /// Reports matching a specific severity.
    func filtered(by severity: IncidentSeverity) -> [IncidentReport] {
        filter { $0.severity == severity }
    }

    /// Reports sorted most-severe first, then most-recent.
    var sortedBySeverityThenDate: [IncidentReport] {
        sorted {
            if $0.severity.sortOrder != $1.severity.sortOrder {
                return $0.severity.sortOrder > $1.severity.sortOrder
            }
            return $0.date > $1.date
        }
    }

    /// Count of unacknowledged reports.
    var pendingCount: Int {
        pendingAcknowledgement.count
    }
}
