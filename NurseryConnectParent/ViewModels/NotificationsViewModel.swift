//
//  NotificationsViewModel.swift
//  NurseryConnectParent
//
//  Created on April 18, 2026
//

import Foundation
import SwiftUI

@Observable
class NotificationsViewModel {
    var notifications: [NotificationItem] = []
    var showUnreadOnly: Bool = false
    
    private let dataProvider = SampleDataProvider.shared
    
    init() {
        loadNotifications()
    }
    
    func loadNotifications() {
        notifications = dataProvider.sampleNotifications
            .sorted(by: { $0.timestamp > $1.timestamp })
    }
    
    func refresh() {
        loadNotifications()
    }
    
    var filteredNotifications: [NotificationItem] {
        if showUnreadOnly {
            return notifications.filter { !$0.isRead }
        }
        return notifications
    }
    
    var unreadCount: Int {
        notifications.filter { !$0.isRead }.count
    }
    
    func markAsRead(_ notification: NotificationItem) {
        if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
            notifications[index].isRead = true
        }
    }
    
    func markAllAsRead() {
        for index in notifications.indices {
            notifications[index].isRead = true
        }
    }
    
    func toggleUnreadFilter() {
        showUnreadOnly.toggle()
    }
    
    func deleteNotification(_ notification: NotificationItem) {
        notifications.removeAll { $0.id == notification.id }
    }
}
