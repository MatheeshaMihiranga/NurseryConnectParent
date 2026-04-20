//
//  NotificationItem.swift
//  NurseryConnectParent
//
//  Created on April 18, 2026
//

import Foundation
import SwiftData

enum NotificationType: String, Codable {
    case diary = "Diary Update"
    case transport = "Transport Update"
    case alert = "Alert"
    case announcement = "Announcement"
    case reminder = "Reminder"
    
    var icon: String {
        switch self {
        case .diary: return "book.fill"
        case .transport: return "bus.fill"
        case .alert: return "exclamationmark.circle.fill"
        case .announcement: return "megaphone.fill"
        case .reminder: return "bell.fill"
        }
    }
}

@Model
final class NotificationItem {
    var id: UUID
    var type: NotificationType
    var title: String
    var message: String
    var timestamp: Date
    var isRead: Bool
    var childId: UUID?
    
    init(
        id: UUID = UUID(),
        type: NotificationType,
        title: String,
        message: String,
        timestamp: Date = Date(),
        isRead: Bool = false,
        childId: UUID? = nil
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.message = message
        self.timestamp = timestamp
        self.isRead = isRead
        self.childId = childId
    }
}
