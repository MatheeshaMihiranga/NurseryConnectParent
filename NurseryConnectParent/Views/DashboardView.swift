//
//  DashboardView.swift
//  NurseryConnectParent
//
//  Created on June 1, 2026
//
//  iPad-specific dashboard shown in the NavigationSplitView detail column
//  when "Dashboard" is selected in the sidebar.
//
//  It deliberately does NOT depend on `selectedTab: Int` — navigation is
//  achieved by mutating the `selectedSidebarItem` binding instead, which
//  the parent NavigationSplitView uses to drive its detail column.

import SwiftUI
import SwiftData

struct DashboardView: View {

    @Binding var selectedItem: SidebarItem

    @State private var viewModel = HomeViewModel()

    @Query private var allNotifications: [NotificationItem]
    @Query(sort: \IncidentReport.date, order: .reverse)
    private var allIncidents: [IncidentReport]
    @Query(sort: \DiaryEntry.timestamp, order: .reverse)
    private var todayEntries: [DiaryEntry]

    // MARK: - Computed summaries

    private var unreadCount: Int {
        allNotifications.filter { !$0.isRead }.count
    }

    private var pendingIncidentCount: Int {
        allIncidents.filter { !$0.parentAcknowledged }.count
    }

    /// Diary entries created today
    private var todayDiaryEntries: [DiaryEntry] {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        return todayEntries.filter { $0.timestamp >= startOfDay }
    }

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {

                // ── Child summary ────────────────────────────────────────
                ChildSummaryCard(child: viewModel.child)

                // ── Stats grid ───────────────────────────────────────────
                statsGrid

                // ── Pending incidents alert (shown only when needed) ─────
                if pendingIncidentCount > 0 {
                    pendingIncidentsBanner
                }

                // ── Today's diary entries ────────────────────────────────
                diarySection

                // ── Swift Charts analytics ──────────────────────────────
                chartsSection

                // ── Unread notifications alert ───────────────────────────
                if unreadCount > 0 {
                    notificationBanner
                }
            }
            .padding()
        }
        .navigationTitle("Dashboard")
        .refreshable { viewModel.refresh() }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    viewModel.refresh()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .accessibilityLabel("Refresh dashboard")
                }
            }
        }
    }

    // MARK: - Stats grid (2 × 2)

    private var statsGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today at a Glance")
                .font(.title3)
                .fontWeight(.semibold)

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 14),
                    GridItem(.flexible(), spacing: 14),
                ],
                spacing: 14
            ) {
                DashboardStatCard(
                    value: "\(todayDiaryEntries.count)",
                    label: "Diary Entries",
                    icon: "book.fill",
                    color: .orange,
                    action: { selectedItem = .diary }
                )

                DashboardStatCard(
                    value: viewModel.currentStatus,
                    label: "Transport",
                    icon: viewModel.statusIcon,
                    color: viewModel.statusColor,
                    action: { selectedItem = .transport }
                )

                DashboardStatCard(
                    value: pendingIncidentCount == 0 ? "All Clear" : "\(pendingIncidentCount) Pending",
                    label: "Incidents",
                    icon: pendingIncidentCount == 0
                        ? "checkmark.shield.fill"
                        : "exclamationmark.shield.fill",
                    color: pendingIncidentCount == 0 ? .green : .red,
                    action: { selectedItem = .incidents }
                )

                DashboardStatCard(
                    value: unreadCount == 0 ? "All Read" : "\(unreadCount) Unread",
                    label: "Notifications",
                    icon: unreadCount == 0 ? "bell.fill" : "bell.badge.fill",
                    color: unreadCount == 0 ? .gray : .red,
                    action: { selectedItem = .notifications }
                )
            }
        }
    }

    // MARK: - Pending incidents banner

    private var pendingIncidentsBanner: some View {
        Button { selectedItem = .incidents } label: {
            HStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.title3)
                    .foregroundStyle(.white)

                VStack(alignment: .leading, spacing: 3) {
                    Text(pendingIncidentCount == 1
                         ? "1 Incident Requires Your Acknowledgement"
                         : "\(pendingIncidentCount) Incidents Require Your Acknowledgement")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)

                    Text("Tap to review and sign the incident report\(pendingIncidentCount == 1 ? "" : "s").")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.85))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
            }
            .padding(14)
            .background(.red.gradient, in: RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(pendingIncidentCount) incident report\(pendingIncidentCount == 1 ? "" : "s") awaiting acknowledgement")
        .accessibilityHint("Navigates to Incident Reports")
    }

    // MARK: - Diary section

    private var diarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Today's Diary")
                    .font(.title3)
                    .fontWeight(.semibold)

                Spacer()

                Button("See All") { selectedItem = .diary }
                    .font(.subheadline)
            }

            if todayDiaryEntries.isEmpty {
                Text("No diary entries recorded today yet.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.secondarySystemBackground),
                                in: RoundedRectangle(cornerRadius: 12))
            } else {
                ForEach(todayDiaryEntries.prefix(3), id: \.id) { entry in
                    NavigationLink(destination: DiaryDetailView(entry: entry)) {
                        DiaryEntryCard(entry: entry)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Charts section (Swift Charts — iOS 16+)

    private var chartsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Analytics")
                .font(.title3)
                .fontWeight(.semibold)

            DiaryActivityChart()
            IncidentSummaryChart()
        }
    }

    // MARK: - Notification banner

    private var notificationBanner: some View {
        Button { selectedItem = .notifications } label: {
            HStack(spacing: 12) {
                Image(systemName: "bell.badge.fill")
                    .font(.title3)
                    .foregroundStyle(.orange)

                Text("You have \(unreadCount) unread notification\(unreadCount == 1 ? "" : "s")")
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
                    .fill(.orange.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(.orange.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(unreadCount) unread notification\(unreadCount == 1 ? "" : "s")")
        .accessibilityHint("Navigates to Notifications")
    }
}

// MARK: - DashboardStatCard

private struct DashboardStatCard: View {
    let value:  String
    let label:  String
    let icon:   String
    let color:  Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundStyle(color)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption2)
                        .foregroundStyle(color.opacity(0.5))
                }

                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(14)
            .background(color.opacity(0.10), in: RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(color.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(label): \(value)")
        .accessibilityHint("Navigates to \(label)")
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        DashboardView(selectedItem: .constant(.dashboard))
    }
    .modelContainer(PersistenceService.shared.container!)
}
