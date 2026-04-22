//
//  HomeViewModel.swift
//  NurseryConnectParent
//
//  Created on April 18, 2026
//

import Foundation
import SwiftUI

@Observable
class HomeViewModel {
    var child: Child
    var latestDiaryEntries: [DiaryEntry] = []
    var transportUpdate: TransportUpdate?
    var unreadNotificationCount: Int = 0
    var isLoading = false

    private let dataProvider = SampleDataProvider.shared

    init(child: Child? = nil) {
        self.child = child ?? dataProvider.sampleChild
        loadData()
    }

    func loadData() {
        // Get latest 3 diary entries
        let allEntries = dataProvider.getDiaryEntries(for: child.id)
        latestDiaryEntries = Array(allEntries.sorted(by: { $0.timestamp > $1.timestamp }).prefix(3))

        // Get transport update
        transportUpdate = dataProvider.getTransportUpdate(for: child.id)

        // Get unread notification count
        unreadNotificationCount = dataProvider.getUnreadNotificationCount()
    }

    /// Simulates a network refresh using async/await
    func refresh() {
        Task { @MainActor in
            isLoading = true
            await DataService.shared.refreshData()
            loadData()
            isLoading = false
        }
    }
    
    var currentStatus: String {
        guard let transport = transportUpdate else {
            return "At Nursery"
        }
        return transport.status.rawValue
    }
    
    var statusIcon: String {
        guard let transport = transportUpdate else {
            return "building.2.fill"
        }
        return transport.status.icon
    }
    
    var statusColor: Color {
        guard let transport = transportUpdate else {
            return .purple
        }
        
        switch transport.status.color {
        case "gray": return .gray
        case "orange": return .orange
        case "blue": return .blue
        case "green": return .green
        case "purple": return .purple
        default: return .blue
        }
    }
}
