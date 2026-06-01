//
//  IncidentReportCard.swift
//  NurseryConnectParent
//
//  Created on June 1, 2026
//

import SwiftUI

/// A compact card used in the Incident Reports list.
struct IncidentReportCard: View {
    let report: IncidentReport

    private var categoryColor: Color { Color(report.category.color) }
    private var severityColor: Color { Color(report.severity.color) }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // ── Top row: category icon + title + severity badge ──────────
            HStack(alignment: .top, spacing: 12) {
                // Category icon
                Image(systemName: report.category.icon)
                    .font(.title2)
                    .foregroundStyle(categoryColor)
                    .frame(width: 44, height: 44)
                    .background(categoryColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 4) {
                    Text(report.title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .lineLimit(2)

                    Text(report.category.rawValue)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 0)

                // Severity badge
                SeverityBadge(severity: report.severity)
            }

            // ── Meta row: date + location ────────────────────────────────
            HStack(spacing: 16) {
                Label(report.date.formatted(date: .abbreviated, time: .shortened),
                      systemImage: "calendar")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if !report.location.isEmpty {
                    Label(report.location, systemImage: "mappin")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Divider()

            // ── Status badges ────────────────────────────────────────────
            HStack(spacing: 8) {
                // Manager approval
                StatusPill(
                    label: report.managerApproved ? "Manager Approved" : "Awaiting Manager",
                    systemImage: report.managerApproved ? "checkmark.seal.fill" : "clock.badge.fill",
                    color: report.managerApproved ? .green : .orange
                )

                // Parent acknowledgement
                StatusPill(
                    label: report.parentAcknowledged ? "Acknowledged" : "Action Required",
                    systemImage: report.parentAcknowledged ? "checkmark.circle.fill" : "exclamationmark.circle.fill",
                    color: report.parentAcknowledged ? .blue : .red
                )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.background)
                .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)
        )
        // Highlight card edge if action is required
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(report.parentAcknowledged ? Color.clear : Color.red.opacity(0.4), lineWidth: 1.5)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
    }

    // MARK: - Accessibility

    private var accessibilityDescription: String {
        let ackStatus = report.parentAcknowledged ? "Acknowledged" : "Action required — awaiting acknowledgement"
        return "\(report.title). \(report.category.rawValue), \(report.severity.rawValue) severity. \(report.formattedDate). \(ackStatus)."
    }
}

// MARK: - Severity Badge

private struct SeverityBadge: View {
    let severity: IncidentSeverity

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: severity.icon)
                .font(.caption2)
            Text(severity.rawValue)
                .font(.caption)
                .fontWeight(.semibold)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(severity.color).opacity(0.15), in: Capsule())
        .foregroundStyle(Color(severity.color))
    }
}

// MARK: - Status Pill

struct StatusPill: View {
    let label: String
    let systemImage: String
    let color: Color

    var body: some View {
        Label(label, systemImage: systemImage)
            .font(.caption2)
            .fontWeight(.medium)
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.12), in: Capsule())
    }
}

// MARK: - Preview

#Preview {
    let provider = SampleDataProvider.shared
    let reports  = provider.sampleIncidentReports
    return ScrollView {
        VStack(spacing: 16) {
            ForEach(reports, id: \.id) { report in
                IncidentReportCard(report: report)
            }
        }
        .padding()
    }
    .background(Color(.systemGroupedBackground))
}
