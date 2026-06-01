// SpatialSampleData.swift
// VisionOSPrototype — NurseryConnect Spatial Manager Dashboard
//
// Self-contained data models and sample data.
// No dependency on SwiftData or the iPadOS target.

import SwiftUI

// MARK: - Room model

struct SpatialRoom: Identifiable {
    let id          = UUID()
    let name        : String
    let icon        : String
    let accentColor : Color
    let capacity    : Int
    let childrenPresent: Int
    let staffCount  : Int
    let requiredStaff: Int
    let currentActivity: String

    var occupancyFraction: Double {
        capacity > 0 ? min(Double(childrenPresent) / Double(capacity), 1.0) : 0
    }
    var isAdequatelyStaffed: Bool { staffCount >= requiredStaff }
}

// MARK: - Incident models

enum SpatialSeverity: String, CaseIterable, Identifiable {
    case minor    = "Minor"
    case moderate = "Moderate"
    case serious  = "Serious"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .minor:    return "1.circle.fill"
        case .moderate: return "2.circle.fill"
        case .serious:  return "exclamationmark.3"
        }
    }

    var color: Color {
        switch self {
        case .minor:    return .green
        case .moderate: return .orange
        case .serious:  return .red
        }
    }
}

struct SpatialIncident: Identifiable {
    let id                  = UUID()
    let title               : String
    let childName           : String
    let category            : String
    let categoryIcon        : String
    let severity            : SpatialSeverity
    let date                : Date
    let location            : String
    let description         : String
    let immediateAction     : String
    let managerApproved     : Bool
    let managerName         : String
    let parentAcknowledged  : Bool
    let acknowledgementDate : Date?

    var isPendingAcknowledgement: Bool { !parentAcknowledged }
}

// MARK: - Transport models

enum SpatialTransportStatus: String, CaseIterable {
    case atBase    = "At Base"
    case boarding  = "Boarding"
    case inTransit = "In Transit"
    case arriving  = "Arriving"
    case arrived   = "Arrived"

    var icon: String {
        switch self {
        case .atBase:    return "car.fill"
        case .boarding:  return "person.crop.rectangle.badge.plus"
        case .inTransit: return "bus.fill"
        case .arriving:  return "mappin.and.ellipse"
        case .arrived:   return "checkmark.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .atBase:    return .secondary
        case .boarding:  return .orange
        case .inTransit: return .blue
        case .arriving:  return .green
        case .arrived:   return .mint
        }
    }
}

struct SpatialTransportRoute: Identifiable {
    let id           = UUID()
    let routeName    : String
    let driverName   : String
    let vehicleReg   : String
    let status       : SpatialTransportStatus
    let etaMinutes   : Int?
    let boardedCount : Int
    let expectedCount: Int
    let lastUpdated  : Date
    let notes        : String

    var etaDescription: String {
        guard let eta = etaMinutes else { return "—" }
        if eta <= 0 { return "Arriving now" }
        return "~\(eta) min"
    }

    var progressFraction: Double {
        expectedCount > 0 ? min(Double(boardedCount) / Double(expectedCount), 1.0) : 0
    }
}

// MARK: - Alert models

enum SpatialAlertType: String, CaseIterable {
    case allergy      = "Allergy"
    case medical      = "Medical"
    case safeguarding = "Safeguarding"
    case dietary      = "Dietary"

    var icon: String {
        switch self {
        case .allergy:      return "allergens"
        case .medical:      return "cross.case.fill"
        case .safeguarding: return "shield.fill"
        case .dietary:      return "fork.knife.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .allergy:      return .red
        case .medical:      return .blue
        case .safeguarding: return .purple
        case .dietary:      return .orange
        }
    }
}

enum SpatialAlertPriority: String {
    case high   = "HIGH"
    case medium = "MED"
    case low    = "LOW"

    var color: Color {
        switch self {
        case .high:   return .red
        case .medium: return .orange
        case .low:    return .green
        }
    }
}

struct SpatialAlert: Identifiable {
    let id        = UUID()
    let childName : String
    let room      : String
    let alertType : SpatialAlertType
    let detail    : String
    let priority  : SpatialAlertPriority
}

// MARK: - Daily operations summary

struct DailyOperationSummary {
    let date                         : Date
    let totalChildren                : Int
    let staffOnDuty                  : Int
    let staffRequired                : Int
    let mealsScheduled               : Int
    let activeIncidents              : Int
    let pendingParentAcknowledgements: Int
    let nurseryOpenTime              : String
    let nurseryCloseTime             : String
}

// MARK: - SpatialDataProvider

@Observable
final class SpatialDataProvider {

    static let shared = SpatialDataProvider()
    private init() {}

    // ── Rooms ────────────────────────────────────────────────────────────
    let rooms: [SpatialRoom] = [
        SpatialRoom(
            name: "Sunflower Room",
            icon: "sun.max.fill",
            accentColor: .yellow,
            capacity: 12,
            childrenPresent: 10,
            staffCount: 3,
            requiredStaff: 3,
            currentActivity: "Arts & Crafts"
        ),
        SpatialRoom(
            name: "Rainbow Room",
            icon: "rainbow",
            accentColor: .blue,
            capacity: 15,
            childrenPresent: 13,
            staffCount: 4,
            requiredStaff: 4,
            currentActivity: "Story Time"
        ),
        SpatialRoom(
            name: "Baby Room",
            icon: "figure.2.and.child.holdinghands",
            accentColor: .pink,
            capacity: 8,
            childrenPresent: 6,
            staffCount: 3,
            requiredStaff: 3,
            currentActivity: "Sensory Play"
        ),
        SpatialRoom(
            name: "Outdoor Play",
            icon: "tree.fill",
            accentColor: .green,
            capacity: 20,
            childrenPresent: 8,
            staffCount: 2,
            requiredStaff: 2,
            currentActivity: "Supervised Free Play"
        ),
    ]

    // ── Incidents ─────────────────────────────────────────────────────────
    let incidents: [SpatialIncident] = {
        let now = Date()
        let cal = Calendar.current
        return [
            SpatialIncident(
                title: "Allergic Reaction to Snack",
                childName: "Emily Johnson",
                category: "Allergic Reaction",
                categoryIcon: "allergens",
                severity: .serious,
                date: cal.date(byAdding: .hour, value: -3, to: now)!,
                location: "Rainbow Room — Snack Area",
                description: "Emily showed signs of allergic reaction after consuming an oat biscuit. Mild hives observed on forearms and neck.",
                immediateAction: "Antihistamine administered. Parents called. GP notified.",
                managerApproved: true,
                managerName: "Helen Carter",
                parentAcknowledged: false,
                acknowledgementDate: nil
            ),
            SpatialIncident(
                title: "Minor Trip in Outdoor Area",
                childName: "Lucas Brown",
                category: "Fall / Trip",
                categoryIcon: "figure.fall",
                severity: .minor,
                date: cal.date(byAdding: .day, value: -1, to: now)!,
                location: "Outdoor Play Area",
                description: "Lucas tripped near the sandpit and sustained a small graze to the left knee.",
                immediateAction: "Wound cleaned and small plaster applied. Child returned to play.",
                managerApproved: true,
                managerName: "Helen Carter",
                parentAcknowledged: false,
                acknowledgementDate: nil
            ),
            SpatialIncident(
                title: "Behaviour — Biting Incident",
                childName: "Sophie Clark",
                category: "Behaviour",
                categoryIcon: "exclamationmark.bubble.fill",
                severity: .moderate,
                date: cal.date(byAdding: .day, value: -3, to: now)!,
                location: "Sunflower Room",
                description: "Sophie bit another child during free play over a shared toy. No skin broken.",
                immediateAction: "Both children separated and comforted. Both sets of parents notified by phone.",
                managerApproved: true,
                managerName: "Helen Carter",
                parentAcknowledged: true,
                acknowledgementDate: cal.date(byAdding: .day, value: -2, to: now)!
            ),
        ]
    }()

    // ── Transport routes ──────────────────────────────────────────────────
    let transportRoutes: [SpatialTransportRoute] = {
        let now = Date()
        let cal = Calendar.current
        return [
            SpatialTransportRoute(
                routeName: "Morning Run A",
                driverName: "James Wilson",
                vehicleReg: "NX72 ABC",
                status: .arrived,
                etaMinutes: nil,
                boardedCount: 8,
                expectedCount: 8,
                lastUpdated: cal.date(byAdding: .hour, value: -1, to: now)!,
                notes: "All children arrived safely."
            ),
            SpatialTransportRoute(
                routeName: "Morning Run B",
                driverName: "Sarah Davies",
                vehicleReg: "NX72 DEF",
                status: .inTransit,
                etaMinutes: 12,
                boardedCount: 5,
                expectedCount: 6,
                lastUpdated: cal.date(byAdding: .minute, value: -5, to: now)!,
                notes: "One child absent — parent confirmed via app."
            ),
            SpatialTransportRoute(
                routeName: "Afternoon Return",
                driverName: "James Wilson",
                vehicleReg: "NX72 ABC",
                status: .atBase,
                etaMinutes: nil,
                boardedCount: 0,
                expectedCount: 12,
                lastUpdated: now,
                notes: "Departs at 15:45."
            ),
        ]
    }()

    // ── Alerts & safeguarding ─────────────────────────────────────────────
    let alerts: [SpatialAlert] = [
        SpatialAlert(
            childName: "Emily Johnson",
            room: "Rainbow Room",
            alertType: .allergy,
            detail: "Severe nut & oat allergy — EpiPen in medication cabinet. Do NOT serve any nut or oat products.",
            priority: .high
        ),
        SpatialAlert(
            childName: "Noah Williams",
            room: "Sunflower Room",
            alertType: .medical,
            detail: "Requires blue reliever inhaler before any outdoor activity. Inhaler stored in Noah's red bag.",
            priority: .high
        ),
        SpatialAlert(
            childName: "Isla Thompson",
            room: "Baby Room",
            alertType: .safeguarding,
            detail: "Collection restricted to named guardians listed on file. Always verify photo ID before release.",
            priority: .high
        ),
        SpatialAlert(
            childName: "Oliver Martinez",
            room: "Sunflower Room",
            alertType: .dietary,
            detail: "Strictly vegan diet. No dairy, egg, or honey products. Check all snack labels.",
            priority: .medium
        ),
    ]

    // ── Computed summary ──────────────────────────────────────────────────
    var operationSummary: DailyOperationSummary {
        DailyOperationSummary(
            date: Date(),
            totalChildren: rooms.map(\.childrenPresent).reduce(0, +),
            staffOnDuty: rooms.map(\.staffCount).reduce(0, +),
            staffRequired: rooms.map(\.requiredStaff).reduce(0, +),
            mealsScheduled: 3,
            activeIncidents: incidents.count,
            pendingParentAcknowledgements: incidents.filter(\.isPendingAcknowledgement).count,
            nurseryOpenTime: "07:30",
            nurseryCloseTime: "18:00"
        )
    }

    // ── High-priority alerts count ─────────────────────────────────────────
    var highPriorityAlertCount: Int {
        alerts.filter { $0.priority == .high }.count
    }

    var pendingIncidentCount: Int {
        incidents.filter(\.isPendingAcknowledgement).count
    }
}
