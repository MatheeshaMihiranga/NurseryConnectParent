// IncidentReviewPanel.swift
// VisionOSPrototype — Incident review panel for nursery manager

import SwiftUI

struct IncidentReviewPanel: View {

    private let data = SpatialDataProvider.shared

    @State private var filterPending = false
    @State private var selectedIncident: SpatialIncident?

    private var displayed: [SpatialIncident] {
        filterPending
            ? data.incidents.filter(\.isPendingAcknowledgement)
            : data.incidents
    }

    var body: some View {
        HStack(alignment: .top, spacing: 16) {

            // ── Left: incident list ──────────────────────────────────────
            VStack(alignment: .leading, spacing: 12) {

                // Filter toggle
                HStack(spacing: 10) {
                    filterChip(label: "All (\(data.incidents.count))",
                               active: !filterPending) {
                        filterPending = false
                    }
                    filterChip(label: "Pending (\(data.pendingIncidentCount))",
                               active: filterPending,
                               badgeColor: .red) {
                        filterPending = true
                    }
                    Spacer()
                }

                // Incident cards
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(displayed) { incident in
                            incidentRow(incident)
                                .onTapGesture {
                                    withAnimation { selectedIncident = incident }
                                }
                        }
                        if displayed.isEmpty {
                            ContentUnavailableView(
                                "No Incidents",
                                systemImage: "checkmark.seal.fill",
                                description: Text("All incidents have been acknowledged.")
                            )
                            .padding(.top, 40)
                        }
                    }
                }
            }
            .frame(maxWidth: 380)

            Divider()

            // ── Right: detail pane ───────────────────────────────────────
            Group {
                if let incident = selectedIncident {
                    incidentDetail(incident)
                } else {
                    ContentUnavailableView(
                        "Select an Incident",
                        systemImage: "cross.case",
                        description: Text("Tap an incident to review its details.")
                    )
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(24)
        .navigationTitle("Incident Review")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            if selectedIncident == nil { selectedIncident = data.incidents.first }
        }
    }

    // MARK: - Filter chip

    private func filterChip(
        label: String,
        active: Bool,
        badgeColor: Color = .blue,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(label)
                .font(.subheadline)
                .fontWeight(active ? .semibold : .regular)
                .foregroundStyle(active ? .white : .primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(active ? badgeColor : Color.primary.opacity(0.08),
                            in: Capsule())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Incident list row

    private func incidentRow(_ incident: SpatialIncident) -> some View {
        HStack(spacing: 12) {
            Image(systemName: incident.categoryIcon)
                .font(.title3)
                .foregroundStyle(incident.severity.color)
                .frame(width: 32, height: 32)
                .background(incident.severity.color.opacity(0.1),
                            in: RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 3) {
                Text(incident.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                Text(incident.childName + " · " + incident.location)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
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
        .padding(12)
        .background(
            selectedIncident?.id == incident.id
                ? Color.blue.opacity(0.12)
                : Color.primary.opacity(0.04),
            in: RoundedRectangle(cornerRadius: 12)
        )
        .overlay(
            incident.isPendingAcknowledgement
                ? RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(.red.opacity(0.35), lineWidth: 1)
                : nil
        )
    }

    // MARK: - Incident detail pane

    private func incidentDetail(_ incident: SpatialIncident) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                // ── Header ─────────────────────────────────────────────────
                HStack(alignment: .top, spacing: 14) {
                    Image(systemName: incident.categoryIcon)
                        .font(.largeTitle)
                        .foregroundStyle(incident.severity.color)
                        .padding(14)
                        .background(incident.severity.color.opacity(0.1),
                                    in: RoundedRectangle(cornerRadius: 16))

                    VStack(alignment: .leading, spacing: 6) {
                        Text(incident.title)
                            .font(.title3)
                            .fontWeight(.bold)
                        HStack(spacing: 8) {
                            SpatialSeverityBadge(severity: incident.severity)
                            Label(incident.category, systemImage: "tag.fill")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Text(incident.date, style: .date)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            + Text(" at ")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            + Text(incident.date, style: .time)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Divider()

                // ── Key fields grid ────────────────────────────────────────
                LazyVGrid(
                    columns: [GridItem(.flexible()), GridItem(.flexible())],
                    spacing: 10
                ) {
                    detailTile("Child",    value: incident.childName,    icon: "person.fill")
                    detailTile("Location", value: incident.location,     icon: "mappin.circle.fill")
                    detailTile("Category", value: incident.category,     icon: incident.categoryIcon)
                    detailTile("Severity", value: incident.severity.rawValue, icon: incident.severity.icon)
                }

                // ── Description ────────────────────────────────────────────
                detailSection("Incident Description",
                              text: incident.description,
                              icon: "doc.text.fill",
                              color: .blue)

                // ── Immediate action ───────────────────────────────────────
                detailSection("Immediate Action Taken",
                              text: incident.immediateAction,
                              icon: "staroflife.fill",
                              color: .green)

                // ── Management review ──────────────────────────────────────
                statusRow(
                    title: "Manager Approval",
                    icon: "person.badge.shield.checkmark.fill",
                    approved: incident.managerApproved,
                    name: incident.managerName
                )

                // ── Parent acknowledgement ─────────────────────────────────
                acknowledgedRow(incident)
            }
        }
    }

    // MARK: - Detail helpers

    private func detailTile(_ label: String, value: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 16)
            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                Text(value)
                    .font(.caption)
                    .fontWeight(.medium)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10))
    }

    private func detailSection(
        _ title: String,
        text: String,
        icon: String,
        color: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(title, systemImage: icon)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(color)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private func statusRow(
        title: String,
        icon: String,
        approved: Bool,
        name: String
    ) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(approved ? .green : .orange)
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
            Spacer()
            if approved {
                Label("Approved — \(name)", systemImage: "checkmark.seal.fill")
                    .font(.caption)
                    .foregroundStyle(.green)
            } else {
                Label("Pending Review", systemImage: "clock.fill")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
        }
        .padding(12)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    @ViewBuilder
    private func acknowledgedRow(_ incident: SpatialIncident) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "signature")
                .foregroundStyle(incident.parentAcknowledged ? .green : .red)
            Text("Parent Acknowledgement")
                .font(.subheadline)
                .fontWeight(.medium)
            Spacer()
            if incident.parentAcknowledged,
               let date = incident.acknowledgementDate {
                VStack(alignment: .trailing, spacing: 2) {
                    Label("Acknowledged", systemImage: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.green)
                    Text(date, style: .date)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            } else {
                Label("Awaiting Signature", systemImage: "exclamationmark.circle.fill")
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
        .padding(12)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            incident.isPendingAcknowledgement
                ? RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(.red.opacity(0.4), lineWidth: 1)
                : nil
        )
    }
}
