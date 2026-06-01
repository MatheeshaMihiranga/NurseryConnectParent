// RoomOverviewPanel.swift
// VisionOSPrototype — Full-screen room overview panel

import SwiftUI

struct RoomOverviewPanel: View {

    private let data = SpatialDataProvider.shared

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // ── Summary tiles ──────────────────────────────────────────
                HStack(spacing: 12) {
                    let total   = data.rooms.map(\.childrenPresent).reduce(0, +)
                    let cap     = data.rooms.map(\.capacity).reduce(0, +)
                    let staffOk = data.rooms.filter(\.isAdequatelyStaffed).count

                    SpatialStatTile(
                        value: "\(total)/\(cap)",
                        label: "Total\nOccupancy",
                        icon: "figure.2.and.child.holdinghands",
                        color: .blue
                    )
                    SpatialStatTile(
                        value: "\(data.rooms.count)",
                        label: "Active\nRooms",
                        icon: "house.fill",
                        color: .green
                    )
                    SpatialStatTile(
                        value: "\(staffOk)/\(data.rooms.count)",
                        label: "Rooms Fully\nStaffed",
                        icon: "person.badge.shield.checkmark.fill",
                        color: staffOk == data.rooms.count ? .green : .red
                    )
                    SpatialStatTile(
                        value: "\(data.rooms.map(\.staffCount).reduce(0, +))",
                        label: "Staff\nOn Duty",
                        icon: "person.3.fill",
                        color: .teal
                    )
                }

                // ── Room cards ─────────────────────────────────────────────
                LazyVGrid(
                    columns: [GridItem(.flexible()), GridItem(.flexible())],
                    spacing: 16
                ) {
                    ForEach(data.rooms) { room in
                        roomCard(room)
                    }
                }
            }
            .padding(24)
        }
        .navigationTitle("Room Overview")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Individual room card

    @ViewBuilder
    private func roomCard(_ room: SpatialRoom) -> some View {
        SpatialCard(title: room.name, icon: room.icon, accentColor: room.accentColor) {
            VStack(alignment: .leading, spacing: 12) {

                // Occupancy row
                HStack {
                    Text("Occupancy")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(room.childrenPresent) / \(room.capacity)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .monospacedDigit()
                }
                OccupancyBar(
                    present: room.childrenPresent,
                    capacity: room.capacity,
                    color: room.accentColor
                )

                // Staff row
                HStack {
                    Label("Staff", systemImage: "person.2.fill")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    HStack(spacing: 4) {
                        Text("\(room.staffCount) / \(room.requiredStaff)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .monospacedDigit()
                        Image(systemName: room.isAdequatelyStaffed
                              ? "checkmark.seal.fill"
                              : "exclamationmark.triangle.fill")
                            .foregroundStyle(room.isAdequatelyStaffed ? .green : .red)
                            .font(.caption)
                    }
                }

                // Current activity
                HStack(alignment: .top, spacing: 6) {
                    Image(systemName: "star.circle.fill")
                        .foregroundStyle(room.accentColor)
                        .font(.caption)
                    Text(room.currentActivity)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                // Occupancy % pill
                let pct = Int(room.occupancyFraction * 100)
                HStack {
                    Spacer()
                    Text("\(pct)% full")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundStyle(room.accentColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(room.accentColor.opacity(0.15), in: Capsule())
                }
            }
        }
    }
}
