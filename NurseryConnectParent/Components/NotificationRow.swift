//
//  NotificationRow.swift
//  NurseryConnectParent
//
//  Created on April 18, 2026
//

import SwiftUI

struct NotificationRow: View {
    let notification: NotificationItem
    let onTap: (() -> Void)?
    
    init(notification: NotificationItem, onTap: (() -> Void)? = nil) {
        self.notification = notification
        self.onTap = onTap
    }
    
    var body: some View {
        Button(action: {
            onTap?()
        }) {
            HStack(alignment: .top, spacing: 12) {
                // Icon
                Image(systemName: notification.type.icon)
                    .font(.title3)
                    .foregroundStyle(iconColor)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(iconColor.opacity(0.1))
                    )
                    .accessibilityHidden(true)
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(notification.title)
                            .font(.headline)
                            .foregroundStyle(.primary)
                        
                        Spacer()
                        
                        if !notification.isRead {
                            Circle()
                                .fill(.blue)
                                .frame(width: 8, height: 8)
                                .accessibilityLabel("Unread")
                        }
                    }
                    
                    Text(notification.message)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                    
                    Text(notification.timestamp, style: .relative)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                
                Spacer()
            }
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(notification.isRead ? "Read" : "Unread") notification: \(notification.title). \(notification.message)")
    }
    
    private var iconColor: Color {
        switch notification.type {
        case .diary: return .orange
        case .transport: return .blue
        case .alert: return .red
        case .announcement: return .purple
        case .reminder: return .green
        }
    }
}

#Preview {
    List {
        ForEach(SampleDataProvider.shared.sampleNotifications, id: \.id) { notification in
            NotificationRow(notification: notification) {
                print("Tapped: \(notification.title)")
            }
        }
    }
}
