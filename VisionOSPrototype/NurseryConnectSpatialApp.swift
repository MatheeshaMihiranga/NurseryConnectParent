// NurseryConnect Spatial Manager Dashboard
// visionOS Prototype — Assignment 2 Part B
// SE4020 Mobile Application Development
//
// Student ID  : IT22357908
// Student Name: Deelaka R K A T
//
// ROLE: Nursery / Setting Manager
// PURPOSE: Monitor nursery operations in spatial computing using
//          floating dashboard panels and an immersive 3D floor plan.
//
// HOW TO COMPILE:
//   See VISIONOS_SETUP.md in this folder for Xcode target setup.

import SwiftUI
import RealityKit

// MARK: - App-wide observable state

@Observable
final class SpatialAppModel {

    // Scene IDs registered in App body
    static let immersiveSpaceID = "NurseryImmersiveSpace"

    // Navigation
    var selectedPanel: SpatialPanel = .dashboard

    // Immersive space lifecycle
    var immersiveSpaceIsShown = false

    // Nursery identity (could be loaded from settings in production)
    let nurseryName = "Rainbow Nursery"
    let managerName = "Helen Carter"
}

// MARK: - Top-level navigation panels

enum SpatialPanel: String, CaseIterable, Identifiable {
    case dashboard = "Dashboard"
    case rooms     = "Room Overview"
    case incidents = "Incident Review"
    case transport = "Transport"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .dashboard: return "square.grid.2x2.fill"
        case .rooms:     return "house.fill"
        case .incidents: return "cross.case.fill"
        case .transport: return "bus.fill"
        }
    }

    var accentColor: Color {
        switch self {
        case .dashboard: return .blue
        case .rooms:     return .green
        case .incidents: return .orange
        case .transport: return .teal
        }
    }
}

// MARK: - App Entry Point

@main
struct NurseryConnectSpatialApp: App {

    @State private var appModel = SpatialAppModel()

    var body: some Scene {

        // ── Main floating dashboard window ──────────────────────────────
        WindowGroup(id: "main") {
            SpatialDashboardView()
                .environment(appModel)
        }
        .defaultSize(width: 1100, height: 740)

        // ── Immersive 3-D nursery layout ────────────────────────────────
        ImmersiveSpace(id: SpatialAppModel.immersiveSpaceID) {
            NurseryRealityView()
                .environment(appModel)
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
    }
}
