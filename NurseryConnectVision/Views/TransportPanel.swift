// TransportPanel.swift
// VisionOSPrototype — Transport status panel for nursery manager

import SwiftUI

struct TransportPanel: View {

    private let data = SpatialDataProvider.shared

    @State private var selectedRoute: SpatialTransportRoute?

    var body: some View {
        HStack(alignment: .top, spacing: 16) {

            // ── Left: route list ─────────────────────────────────────────
            VStack(alignment: .leading, spacing: 12) {

                // Fleet summary chips
                HStack(spacing: 10) {
                    fleetChip(
                        label: "Active",
                        count: data.transportRoutes.filter { $0.status != .atBase }.count,
                        color: .blue
                    )
                    fleetChip(
                        label: "In Transit",
                        count: data.transportRoutes.filter { $0.status == .inTransit || $0.status == .arriving }.count,
                        color: .orange
                    )
                    fleetChip(
                        label: "At Base",
                        count: data.transportRoutes.filter { $0.status == .atBase }.count,
                        color: .secondary
                    )
                    Spacer()
                }

                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(data.transportRoutes) { route in
                            routeRow(route)
                                .onTapGesture {
                                    withAnimation { selectedRoute = route }
                                }
                        }
                    }
                }
            }
            .frame(maxWidth: 360)

            Divider()

            // ── Right: route detail ──────────────────────────────────────
            Group {
                if let route = selectedRoute {
                    routeDetail(route)
                } else {
                    ContentUnavailableView(
                        "Select a Route",
                        systemImage: "bus",
                        description: Text("Tap a route to see live details.")
                    )
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(24)
        .navigationTitle("Transport Status")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            if selectedRoute == nil { selectedRoute = data.transportRoutes.first }
        }
    }

    // MARK: - Fleet chip

    private func fleetChip(label: String, count: Int, color: Color) -> some View {
        HStack(spacing: 5) {
            Text("\(count)")
                .fontWeight(.bold)
                .foregroundStyle(color)
            Text(label)
                .foregroundStyle(.secondary)
        }
        .font(.subheadline)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(color.opacity(0.1), in: Capsule())
    }

    // MARK: - Route list row

    private func routeRow(_ route: SpatialTransportRoute) -> some View {
        HStack(spacing: 12) {
            Image(systemName: route.status.icon)
                .font(.title3)
                .foregroundStyle(route.status.color)
                .frame(width: 36, height: 36)
                .background(route.status.color.opacity(0.1),
                            in: RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 3) {
                Text(route.routeName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                HStack(spacing: 4) {
                    Image(systemName: "person.fill")
                        .font(.caption2)
                    Text(route.driverName)
                        .font(.caption)
                }
                .foregroundStyle(.secondary)
                Text(route.vehicleReg)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                TransportStatusBadge(status: route.status)
                if route.status == .inTransit || route.status == .arriving {
                    Label(route.etaDescription, systemImage: "clock.fill")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                } else {
                    Text("\(route.boardedCount)/\(route.expectedCount) boarded")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
            }
        }
        .padding(12)
        .background(
            selectedRoute?.id == route.id
                ? Color.teal.opacity(0.12)
                : Color.primary.opacity(0.04),
            in: RoundedRectangle(cornerRadius: 12)
        )
    }

    // MARK: - Route detail pane

    private func routeDetail(_ route: SpatialTransportRoute) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                // ── Header ────────────────────────────────────────────────
                HStack(spacing: 14) {
                    Image(systemName: route.status.icon)
                        .font(.largeTitle)
                        .foregroundStyle(route.status.color)
                        .padding(14)
                        .background(route.status.color.opacity(0.1),
                                    in: RoundedRectangle(cornerRadius: 16))

                    VStack(alignment: .leading, spacing: 6) {
                        Text(route.routeName)
                            .font(.title3)
                            .fontWeight(.bold)
                        TransportStatusBadge(status: route.status)
                        Text("Last updated: " + route.lastUpdated.formatted(date: .omitted, time: .shortened))
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }

                Divider()

                // ── Info grid ─────────────────────────────────────────────
                LazyVGrid(
                    columns: [GridItem(.flexible()), GridItem(.flexible())],
                    spacing: 10
                ) {
                    infoTile("Driver",   value: route.driverName,    icon: "person.fill",    color: .blue)
                    infoTile("Vehicle",  value: route.vehicleReg,    icon: "car.fill",        color: .teal)
                    infoTile("Boarded",  value: "\(route.boardedCount) / \(route.expectedCount)",
                             icon: "person.crop.rectangle.badge.plus", color: .green)
                    infoTile("ETA",      value: route.etaDescription, icon: "clock.fill",      color: .orange)
                }

                // ── Boarding progress ─────────────────────────────────────
                VStack(alignment: .leading, spacing: 6) {
                    Label("Boarding Progress", systemImage: "person.crop.rectangle.badge.plus")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.green)

                    HStack(spacing: 8) {
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.green.opacity(0.2))
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.green)
                                    .frame(width: geo.size.width * route.progressFraction)
                                    .animation(.easeInOut(duration: 0.4), value: route.progressFraction)
                            }
                        }
                        .frame(height: 10)
                        Text("\(Int(route.progressFraction * 100))%")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .monospacedDigit()
                            .frame(width: 36, alignment: .trailing)
                    }
                }
                .padding(12)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))

                // ── Notes ─────────────────────────────────────────────────
                if !route.notes.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Label("Driver Notes", systemImage: "note.text")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.teal)
                        Text(route.notes)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }

    // MARK: - Info tile

    private func infoTile(
        _ label: String,
        value: String,
        icon: String,
        color: Color
    ) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 22)
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .monospacedDigit()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}
