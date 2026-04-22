//
//  ContentView.swift
//  NurseryConnectParent
//
//  Created on April 18, 2026
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab = 0
    @Query private var allNotifications: [NotificationItem]

    private var unreadCount: Int {
        allNotifications.filter { !$0.isRead }.count
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            HomeView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
                .accessibilityLabel("Home tab")
            
            // Diary Tab
            DiaryView()
                .tabItem {
                    Label("Diary", systemImage: "book.fill")
                }
                .tag(1)
                .accessibilityLabel("Daily Diary tab")
            
            // Transport Tab
            TransportView()
                .tabItem {
                    Label("Transport", systemImage: "bus.fill")
                }
                .tag(2)
                .accessibilityLabel("Transport Tracking tab")
            
            // Notifications Tab
            NotificationsView()
                .tabItem {
                    Label("Notifications", systemImage: "bell.fill")
                }
                .badge(unreadCount > 0 ? unreadCount : 0)
                .tag(3)
                .accessibilityLabel("Notifications tab, \(unreadCount) unread")
            
            // Profile Tab
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(4)
                .accessibilityLabel("Profile tab")
        }
        .tint(.blue) // Accent color for selected tab
        .onAppear {
            configureTabBarAppearance()
        }
    }
    
    // MARK: - Tab Bar Configuration
    
    private func configureTabBarAppearance() {
        // Configure tab bar appearance for better accessibility
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        // Use a subtle shadow for depth
        appearance.shadowColor = UIColor.black.withAlphaComponent(0.1)
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

#Preview {
    ContentView()
        .modelContainer(PersistenceService.shared.container!)
}

