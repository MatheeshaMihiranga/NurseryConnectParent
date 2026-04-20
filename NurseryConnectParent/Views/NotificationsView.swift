//
//  NotificationsView.swift
//  NurseryConnectParent
//
//  Created on April 18, 2026
//

import SwiftUI

struct NotificationsView: View {
    @State private var viewModel = NotificationsViewModel()
    
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
