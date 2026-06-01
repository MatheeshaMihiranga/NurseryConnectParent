// SpatialDashboardView.swift
// VisionOSPrototype — Main floating dashboard window

import SwiftUI

// MARK: - Root content view (embedded in WindowGroup)

struct SpatialDashboardView: View {

    @Environment(SpatialAppModel.self) private var appModel
    @Environment(\.openImmersiveSpace)    var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace

    @State private var navPath = NavigationPath()
    @State private var data    = SpatialDataProvider.shared

    // Real-time clock for the header
    @State private var currentTime = Date()
    private let timer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationStack(path: $navPath) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    dashboardHeader
                    summaryStatsRow
                    alertsBanner
                    mainPanelsRow
                    alertsSection
                }
                .padding(24)
            }
            // ── Navigation destinations ───────────────────────────────────
            .navigationDestination(for: SpatialPanel.self) { panel in
                switch panel {
                case .rooms:     RoomOverviewPanel()
                case .incidents: IncidentReviewPanel()
                case .transport: TransportPanel()
                default:         EmptyView()
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
        // ── Bottom ornament — quick stats + 3-D toggle ───────────────────
        .ornament(attachmentAnchor: .scene(.bottom)) {
            ornamentBar
        }
        .onReceive(timer) { _ in currentTime = Date() }
    }

    // MARK: - Dashboard header

    private var dashboardHeader: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(appModel.nurseryName)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Label("Spatial Manager Dashboard", systemImage: "visionpro")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Label("Manager: \(appModel.managerName)", systemImage: "person.circle")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text(currentTime, style: .time)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .monospacedDigit()
                Text(currentTime, style: .date)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                HStack(spacing: 4) {
                    Circle()
                        .fill(.green)
                        .frame(width: 8, height: 8)
                    Text("Nursery Open · \(data.operationSummary.nurseryOpenTime)–\(data.operationSummary.nurseryCloseTime)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    // MARK: - Summary stats row

    private var summaryStatsRow: some View {
        let summary = data.operationSummary
        return HStack(spacing: 12) {
            SpatialStatTile(
                value: "\(summary.totalChildren)",
                label: "Children\nPresent",
                icon: "figure.2.and.child.holdinghands",
                color: .blue
            )
            SpatialStatTile(
                value: "\(summary.staffOnDuty)",
                label: "Staff\nOn Duty",
                icon: "person.3.fill",
                color: .green
            )
            SpatialStatTile(
                value: "\(summary.activeIncidents)",
                label: "Active\nIncidents",
                icon: "cross.case.fill",
                color: summary.activeIncidents > 0 ? .orange : .green
            )
            SpatialStatTile(
                value: "\(data.highPriorityAlertCount)",
                label: "High-Priority\nAlerts",
                icon: "exclamationmark.shield.fill",
                color: data.highPriorityAlertCount > 0 ? .red : .green
            )
            SpatialStatTile(
                value: "\(data.pendingIncidentCount)",
                label: "Pending\nAcknowledgement",
                icon: "signature",
                color: data.pendingIncidentCount > 0 ? .red : .green
            )
        }
    }

    // MARK: - Alert banner (shown when there are pending items)

    @ViewBuilder
    private var alertsBanner: some View {
        let pending = data.pendingIncidentCount
        if pending > 0 {
            HStack(spacing: 10) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.white)
                Text("\(pending) incident report\(pending == 1 ? "" : "s") awaiting parent acknowledgement")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                Spacer()
                Button("Review") {
                    navPath.append(SpatialPanel.incidents)
                }
                .buttonStyle(.borderedProminent)
                .tint(.white)
                .foregroundStyle(.red)
            }
            .padding(14)
            .background(.red.opacity(0.85), in: RoundedRectangle(cornerRadius: 14))
        }
    }

    // MARK: - Three main panel cards

    private var mainPanelsRow: some View {
        HStack(alignment: .top, spacing: 16) {
            roomsSummaryCard
                .frame(maxWidth: .infinity)
            incidentsSummaryCard
                .frame(maxWidth: .infinity)
            transportSummaryCard
                .frame(maxWidth: .infinity)
        }
    }

    // MARK: – Rooms summary card

    private var roomsSummaryCard: some View {
        SpatialCard(title: "Room Overview", icon: "house.fill", accentColor: .green) {
            VStack(spacing: 10) {
                ForEach(data.rooms) { room in
                    HStack(spacing: 8) {
                        Image(systemName: room.icon)
                            .foregroundStyle(room.accentColor)
                            .frame(width: 20)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(room.name)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            OccupancyBar(
                                present: room.childrenPresent,
                                capacity: room.capacity,
                                color: room.accentColor
                            )
                        }
                        Spacer()
                        Text("\(room.childrenPresent)/\(room.capacity)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .monospacedDigit()
                            .foregroundStyle(.secondary)
                        if !room.isAdequatelyStaffed {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.red)
                                .font(.caption)
                        }
                    }
                }
                Divider()
                Button("View Full Room Overview") {
                    navPath.append(SpatialPanel.rooms)
                }
                .buttonStyle(.borderless)
                .foregroundStyle(.green)
                .font(.subheadline)
                .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: – Incidents summary card

    private var incidentsSummaryCard: some View {
        SpatialCard(title: "Incident Review", icon: "cross.case.fill", accentColor: .orange) {
            VStack(spacing: 10) {
                ForEach(data.incidents.prefix(3)) { incident in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: incident.categoryIcon)
                            .foregroundStyle(incident.severity.color)
                            .frame(width: 20)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(incident.title)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .lineLimit(1)
                            Text(incident.childName)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 3) {
                            SpatialSeverityBadge(severity: incident.severity)
                            if incident.isPendingAcknowledgement {
                                Text("Pending")
                                    .font(.caption2)
                                    .foregroundStyle(.red)
                            } else {
                                Text("Acknowledged")
                                    .font(.caption2)
                                    .foregroundStyle(.green)
                            }
                        }
                    }
                }
                Divider()
                Button("View Incident Review Panel") {
                    navPath.append(SpatialPanel.incidents)
                }
                .buttonStyle(.borderless)
                .foregroundStyle(.orange)
                .font(.subheadline)
                .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: – Transport summary card

    private var transportSummaryCard: some View {
        SpatialCard(title: "Transport Status", icon: "bus.fill", accentColor: .teal) {
            VStack(spacing: 10) {
                ForEach(data.transportRoutes) { route in
                    HStack(spacing: 8) {
                        Image(systemName: route.status.icon)
                            .foregroundStyle(route.status.color)
                            .frame(width: 20)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(route.routeName)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text(route.driverName)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 3) {
                            TransportStatusBadge(status: route.status)
                            if route.status == .inTransit || route.status == .arriving {
                                Text(route.etaDescription)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            } else {
                                Text("\(route.boardedCount)/\(route.expectedCount)")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                Divider()
                Button("View Transport Panel") {
                    navPath.append(SpatialPanel.transport)
                }
                .buttonStyle(.borderless)
                .foregroundStyle(.teal)
                .font(.subheadline)
                .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - Alerts & safeguarding section

    private var alertsSection: some View {
        SpatialCard(title: "Allergy & Safeguarding Alerts", icon: "exclamationmark.shield.fill", accentColor: .red) {
            VStack(spacing: 10) {
                ForEach(data.alerts) { alert in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: alert.alertType.icon)
                            .font(.title3)
                            .foregroundStyle(alert.alertType.color)
                            .frame(width: 28)
                        VStack(alignment: .leading, spacing: 3) {
                            HStack(spacing: 6) {
                                Text(alert.childName)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                Text("·")
                                    .foregroundStyle(.secondary)
                                Text(alert.room)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                AlertPriorityBadge(priority: alert.priority)
                            }
                            Text(alert.detail)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    if alert.id != data.alerts.last?.id {
                        Divider().padding(.leading, 40)
                    }
                }
            }
        }
    }

    // MARK: - Bottom ornament bar

    private var ornamentBar: some View {
        HStack(spacing: 20) {
            // Quick stats
            Label("\(data.operationSummary.totalChildren) children", systemImage: "figure.2.and.child.holdinghands")
                .font(.caption)
                .foregroundStyle(.secondary)
            Divider().frame(height: 20)
            Label("\(data.operationSummary.staffOnDuty) staff", systemImage: "person.3.fill")
                .font(.caption)
                .foregroundStyle(.secondary)
            Divider().frame(height: 20)

            // 3-D immersive space toggle
            Button {
                Task {
                    if appModel.immersiveSpaceIsShown {
                        await dismissImmersiveSpace()
                        appModel.immersiveSpaceIsShown = false
                    } else {
                        let result = await openImmersiveSpace(id: SpatialAppModel.immersiveSpaceID)
                        if case .opened = result {
                            appModel.immersiveSpaceIsShown = true
                        }
                    }
                }
            } label: {
                Label(
                    appModel.immersiveSpaceIsShown ? "Exit 3D Layout" : "Enter 3D Nursery Layout",
                    systemImage: appModel.immersiveSpaceIsShown ? "xmark.circle.fill" : "view.3d"
                )
                .font(.subheadline)
                .fontWeight(.semibold)
            }
            .buttonStyle(.borderedProminent)
            .tint(appModel.immersiveSpaceIsShown ? .red : .blue)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 14)
        .background(.regularMaterial, in: Capsule())
    }
}
