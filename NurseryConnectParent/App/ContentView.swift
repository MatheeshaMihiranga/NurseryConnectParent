//
//  ContentView.swift
//  NurseryConnectParent
//
//  Created on April 18, 2026
//
//  Adaptive root layout:
//   - Compact width (iPhone, iPhone landscape)  → TabView  (existing A1 layout)
//   - Regular width (iPad, Split View on iPad)  → NavigationSplitView  (A2 iPadOS layout)

import SwiftUI
import SwiftData

// MARK: - Sidebar navigation item

enum SidebarItem: String, CaseIterable, Identifiable, Hashable {
    case dashboard     = "Dashboard"
    case diary         = "Daily Diary"
    case transport     = "Transport"
    case incidents     = "Incident Reports"
    case notifications = "Notifications"
    case profile       = "Profile"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .dashboard:     return "house.fill"
        case .diary:         return "book.fill"
        case .transport:     return "bus.fill"
        case .incidents:     return "shield.lefthalf.filled.badge.checkmark"
        case .notifications: return "bell.fill"
        case .profile:       return "person.fill"
        }
    }
}

// MARK: - ContentView

struct ContentView: View {

    // Used by the iPhone TabView
    @State private var selectedTab = 0
    // Used by the iPad NavigationSplitView
    @State private var selectedSidebarItem: SidebarItem? = .dashboard

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @Query private var allNotifications: [NotificationItem]
    @Query private var allIncidents: [IncidentReport]

    private var unreadCount: Int {
        allNotifications.filter { !$0.isRead }.count
    }

    private var pendingIncidentCount: Int {
        allIncidents.filter { !$0.parentAcknowledged }.count
    }

    // MARK: - Body

    var body: some View {
        if horizontalSizeClass == .regular {
            iPadSplitLayout
        } else {
            iPhoneTabLayout
        }
    }

    // MARK: - iPad: NavigationSplitView

    private var iPadSplitLayout: some View {
        NavigationSplitView(columnVisibility: .constant(.all)) {
            // ── Sidebar ──────────────────────────────────────────────────
            List(SidebarItem.allCases, selection: $selectedSidebarItem) { item in
                NavigationLink(value: item) {
                    Label(item.rawValue, systemImage: item.icon)
                }
                .badge(badgeCount(for: item))
                .accessibilityLabel(accessibilityLabel(for: item))
            }
            .navigationTitle("NurseryConnect")
            .navigationSplitViewColumnWidth(min: 220, ideal: 260, max: 300)
        } detail: {
            // ── Detail column ─────────────────────────────────────────────
            detailView(for: selectedSidebarItem ?? .dashboard)
        }
        .navigationSplitViewStyle(.balanced)
    }

    @ViewBuilder
    private func detailView(for item: SidebarItem) -> some View {
        switch item {
        case .dashboard:
            DashboardView(selectedItem: $selectedSidebarItem.withDefault(.dashboard))
        case .diary:
            DiaryView()
        case .transport:
            TransportView()
        case .incidents:
            IncidentReportsView()
        case .notifications:
            NotificationsView()
        case .profile:
            ProfileView()
        }
    }

    private func badgeCount(for item: SidebarItem) -> Int {
        switch item {
        case .notifications: return unreadCount
        case .incidents:     return pendingIncidentCount
        default:             return 0
        }
    }

    private func accessibilityLabel(for item: SidebarItem) -> String {
        switch item {
        case .notifications:
            return unreadCount > 0
                ? "\(item.rawValue), \(unreadCount) unread"
                : item.rawValue
        case .incidents:
            return pendingIncidentCount > 0
                ? "\(item.rawValue), \(pendingIncidentCount) pending"
                : item.rawValue
        default:
            return item.rawValue
        }
    }

    // MARK: - iPhone: existing TabView

    private var iPhoneTabLayout: some View {
        TabView(selection: $selectedTab) {
            HomeView(selectedTab: $selectedTab)
                .tabItem { Label("Home", systemImage: "house.fill") }
                .tag(0)
                .accessibilityLabel("Home tab")

            DiaryView()
                .tabItem { Label("Diary", systemImage: "book.fill") }
                .tag(1)
                .accessibilityLabel("Daily Diary tab")

            TransportView()
                .tabItem { Label("Transport", systemImage: "bus.fill") }
                .tag(2)
                .accessibilityLabel("Transport Tracking tab")

            NotificationsView()
                .tabItem { Label("Notifications", systemImage: "bell.fill") }
                .badge(unreadCount > 0 ? unreadCount : 0)
                .tag(3)
                .accessibilityLabel("Notifications tab, \(unreadCount) unread")

            IncidentReportsView()
                .tabItem {
                    Label("Incidents",
                          systemImage: "shield.lefthalf.filled.badge.checkmark")
                }
                .badge(pendingIncidentCount > 0 ? pendingIncidentCount : 0)
                .tag(4)
                .accessibilityLabel("Incident Reports tab, \(pendingIncidentCount) pending")

            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.fill") }
                .tag(5)
                .accessibilityLabel("Profile tab")
        }
        .tint(.blue)
        .onAppear { configureTabBarAppearance() }
    }

    // MARK: - Tab bar styling (iPhone only)

    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.shadowColor = UIColor.black.withAlphaComponent(0.1)
        UITabBar.appearance().standardAppearance  = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

// MARK: - Binding helper

private extension Binding where Value == SidebarItem? {
    /// Returns a non-optional Binding with a fallback default value.
    func withDefault(_ defaultValue: SidebarItem) -> Binding<SidebarItem> {
        Binding<SidebarItem>(
            get:  { self.wrappedValue ?? defaultValue },
            set:  { self.wrappedValue = $0 }
        )
    }
}

// MARK: - Preview

#Preview("iPhone") {
    ContentView()
        .modelContainer(PersistenceService.shared.container!)
}

#Preview("iPad") {
    ContentView()
        .environment(\.horizontalSizeClass, .regular)
        .modelContainer(PersistenceService.shared.container!)
}


