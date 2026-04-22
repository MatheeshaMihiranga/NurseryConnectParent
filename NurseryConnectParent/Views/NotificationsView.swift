//
//  NotificationsView.swift
//  NurseryConnectParent
//
//  Created on April 18, 2026
//

import SwiftUI
import SwiftData

struct NotificationsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \NotificationItem.timestamp, order: .reverse) private var allNotifications: [NotificationItem]
    @State private var showUnreadOnly = false

    private var filteredNotifications: [NotificationItem] {
        showUnreadOnly ? allNotifications.filter { !$0.isRead } : allNotifications
    }

    private var unreadCount: Int {
        allNotifications.filter { !$0.isRead }.count
    }

    var body: some View {
        NavigationStack {
            Group {
                if filteredNotifications.isEmpty {
                    ContentUnavailableView(
                        showUnreadOnly ? "No Unread Notifications" : "No Notifications",
                        systemImage: "bell.slash.fill",
                        description: Text(showUnreadOnly
                            ? "All caught up! You have no unread notifications."
                            : "You don't have any notifications yet.")
                    )
                } else {
                    List {
                        ForEach(filteredNotifications, id: \.id) { notification in
                            NotificationRow(notification: notification) {
                                markAsRead(notification)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    deleteNotification(notification)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }

                                if !notification.isRead {
                                    Button {
                                        markAsRead(notification)
                                    } label: {
                                        Label("Mark as Read", systemImage: "checkmark")
                                    }
                                    .tint(.blue)
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Notifications")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button(action: { showUnreadOnly.toggle() }) {
                            Label(
                                showUnreadOnly ? "Show All" : "Show Unread Only",
                                systemImage: showUnreadOnly ? "envelope.open.fill" : "envelope.badge.fill"
                            )
                        }

                        Divider()

                        Button(action: markAllAsRead) {
                            Label("Mark All as Read", systemImage: "checkmark.circle.fill")
                        }
                        .disabled(unreadCount == 0)
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .accessibilityLabel("More options")
                    }
                }

                ToolbarItem(placement: .status) {
                    if unreadCount > 0 {
                        Text("\(unreadCount) unread")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    // MARK: - Actions (persisted via SwiftData)

    private func markAsRead(_ notification: NotificationItem) {
        notification.isRead = true
        saveContext()
    }

    private func deleteNotification(_ notification: NotificationItem) {
        modelContext.delete(notification)
        saveContext()
    }

    private func markAllAsRead() {
        for notification in allNotifications {
            notification.isRead = true
        }
        saveContext()
    }

    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            print("❌ Failed to save notification changes: \(error)")
        }
    }
}

#Preview {
    NotificationsView()
        .modelContainer(PersistenceService.shared.container!)
}

    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.filteredNotifications.isEmpty {
                    ContentUnavailableView(
                        viewModel.showUnreadOnly ? "No Unread Notifications" : "No Notifications",
                        systemImage: "bell.slash.fill",
                        description: Text(viewModel.showUnreadOnly ? "All caught up! You have no unread notifications." : "You don't have any notifications yet.")
                    )
                } else {
                    List {
                        ForEach(viewModel.filteredNotifications, id: \.id) { notification in
                            NotificationRow(notification: notification) {
                                viewModel.markAsRead(notification)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    viewModel.deleteNotification(notification)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                
                                if !notification.isRead {
                                    Button {
                                        viewModel.markAsRead(notification)
                                    } label: {
                                        Label("Mark as Read", systemImage: "checkmark")
                                    }
                                    .tint(.blue)
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Notifications")
            .refreshable {
                viewModel.refresh()
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button(action: {
                            viewModel.toggleUnreadFilter()
                        }) {
                            Label(
                                viewModel.showUnreadOnly ? "Show All" : "Show Unread Only",
                                systemImage: viewModel.showUnreadOnly ? "envelope.open.fill" : "envelope.badge.fill"
                            )
                        }
                        
                        Divider()
                        
                        Button(action: {
                            viewModel.markAllAsRead()
                        }) {
                            Label("Mark All as Read", systemImage: "checkmark.circle.fill")
                        }
                        .disabled(viewModel.unreadCount == 0)
                        
                        Button(action: {
                            viewModel.refresh()
                        }) {
                            Label("Refresh", systemImage: "arrow.clockwise")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .accessibilityLabel("More options")
                    }
                }
                
                ToolbarItem(placement: .status) {
                    if viewModel.unreadCount > 0 {
                        Text("\(viewModel.unreadCount) unread")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}

#Preview {
    NotificationsView()
}
