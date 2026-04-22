//
//  HomeView.swift
//  NurseryConnectParent
//
//  Created on April 18, 2026
//

import SwiftUI

struct HomeView: View {
    @State private var viewModel = HomeViewModel()
    @Binding var selectedTab: Int

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Child Summary Card
                    ChildSummaryCard(child: viewModel.child)
                    
                    // Current Status
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Current Status")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .padding(.horizontal)
                        
                        StatusCard(
                            title: viewModel.currentStatus,
                            icon: viewModel.statusIcon,
                            color: viewModel.statusColor,
                            subtitle: "Updated moments ago"
                        )
                        .padding(.horizontal)
                    }
                    
                    // Quick Actions
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Quick Actions")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .padding(.horizontal)
                        
                        HStack(spacing: 16) {
                            QuickActionButton(
                                title: "View Diary",
                                icon: "book.fill",
                                color: .orange
                            ) {
                                selectedTab = 1
                            }
                            
                            QuickActionButton(
                                title: "Track Transport",
                                icon: "bus.fill",
                                color: .blue
                            ) {
                                selectedTab = 2
                            }
                            
                            QuickActionButton(
                                title: "Notifications",
                                icon: "bell.fill",
                                color: .red
                            ) {
                                selectedTab = 3
                            }
                            
                            QuickActionButton(
                                title: "Profile",
                                icon: "person.fill",
                                color: .purple
                            ) {
                                selectedTab = 4
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Latest Diary Updates
                    if !viewModel.latestDiaryEntries.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Today's Updates")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                
                                Spacer()
                                
                                Button("See All") {
                                    selectedTab = 1
                                }
                                .font(.subheadline)
                            }
                            .padding(.horizontal)
                            
                            ForEach(viewModel.latestDiaryEntries.prefix(3), id: \.id) { entry in
                                NavigationLink(destination: DiaryDetailView(entry: entry)) {
                                    DiaryEntryCard(entry: entry)
                                }
                                .buttonStyle(.plain)
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    // Notification Badge
                    if viewModel.unreadNotificationCount > 0 {
                        Button(action: {
                            selectedTab = 3
                        }) {
                            HStack {
                                Image(systemName: "bell.badge.fill")
                                    .foregroundStyle(.red)
                                
                                Text("You have \(viewModel.unreadNotificationCount) unread notification\(viewModel.unreadNotificationCount == 1 ? "" : "s")")
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.red.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .strokeBorder(.red.opacity(0.3), lineWidth: 1)
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Home")
            .refreshable {
                viewModel.refresh()
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        viewModel.refresh()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .accessibilityLabel("Refresh")
                    }
                }
            }
        }
    }
}

#Preview {
    HomeView(selectedTab: .constant(0))
}
