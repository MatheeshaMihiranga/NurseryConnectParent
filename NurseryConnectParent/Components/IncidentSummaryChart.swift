//
//  IncidentSummaryChart.swift
//  NurseryConnectParent
//
//  Created on June 1, 2026
//
//  Swift Charts — incident acknowledgement status bar chart.
//  Requires iOS 16+. Project targets iOS 26.2 — fully compatible.

import SwiftUI
import Charts
import SwiftData

// MARK: - IncidentAckPoint

struct IncidentAckPoint: Identifiable {
    let id       = UUID()
    let label:   String
    let count:   Int
    let color:   Color
}

// MARK: - IncidentSummaryChart

/// Horizontal bar chart comparing pending vs acknowledged incident reports,
/// broken down by severity.
struct IncidentSummaryChart: View {

    @Query private var allIncidents: [IncidentReport]

    // ── Ack status data ──────────────────────────────────────────────────

    private var ackPoints: [IncidentAckPoint] {
        let pending      = allIncidents.filter { !$0.parentAcknowledged }.count
        let acknowledged = allIncidents.filter {  $0.parentAcknowledged }.count
        return [
            IncidentAckPoint(label: "Pending",      count: pending,      color: .red),
            IncidentAckPoint(label: "Acknowledged", count: acknowledged, color: .blue),
        ]
    }

    // ── Severity data ───────────────────────────────────────────────────

    struct SeverityPoint: Identifiable {
        let id       = UUID()
        let severity: IncidentSeverity
        let count:   Int
    }

    private var severityPoints: [SeverityPoint] {
        IncidentSeverity.allCases.map { severity in
            SeverityPoint(
                severity: severity,
                count: allIncidents.filter { $0.severity == severity }.count
            )
        }
    }

    private var totalIncidents: Int { allIncidents.count }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            // ── Section header ────────────────────────────────────────
            Label("Incident Reports Summary", systemImage: "chart.bar.doc.horizontal.fill")
                .font(.headline)
                .foregroundStyle(.red)

            if totalIncidents == 0 {
                Text("No incident reports on record.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 8)
            } else {

                // ── Acknowledgement status chart ───────────────────────
                VStack(alignment: .leading, spacing: 6) {
                    Text("Acknowledgement Status")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)

                    Chart(ackPoints) { point in
                        BarMark(
                            x: .value("Count", point.count),
                            y: .value("Status", point.label)
                        )
                        .foregroundStyle(point.color)
                        .cornerRadius(6)
                        .annotation(position: .trailing) {
                            Text("\(point.count)")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .chartXAxis {
                        AxisMarks(values: .stride(by: 1)) { _ in
                            AxisGridLine()
                            AxisValueLabel()
                        }
                    }
                    .chartXScale(domain: 0...max(totalIncidents, 2))
                    .frame(height: 80)
                }

                Divider()

                // ── Severity breakdown chart ───────────────────────────
                VStack(alignment: .leading, spacing: 6) {
                    Text("By Severity")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)

                    Chart(severityPoints) { point in
                        BarMark(
                            x: .value("Severity", point.severity.rawValue),
                            y: .value("Count",    point.count)
                        )
                        .foregroundStyle(Color(point.severity.color))
                        .cornerRadius(5)
                        .annotation(position: .top) {
                            if point.count > 0 {
                                Text("\(point.count)")
                                    .font(.caption2)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .chartYScale(domain: 0...max(totalIncidents + 1, 3))
                    .chartYAxis {
                        AxisMarks(values: .stride(by: 1)) { _ in
                            AxisGridLine()
                            AxisValueLabel()
                        }
                    }
                    .frame(height: 120)
                }
            }
        }
        .padding()
        .background(
            Color(.secondarySystemBackground),
            in: RoundedRectangle(cornerRadius: 16)
        )
        .accessibilityLabel(accessibilitySummary)
    }

    // MARK: - Accessibility

    private var accessibilitySummary: String {
        let pending = ackPoints.first(where: { $0.label == "Pending" })?.count ?? 0
        let acked   = ackPoints.first(where: { $0.label == "Acknowledged" })?.count ?? 0
        return "Incident reports summary chart. \(pending) pending acknowledgement, \(acked) acknowledged. Total \(totalIncidents) incidents."
    }
}

// MARK: - Preview

#Preview {
    IncidentSummaryChart()
        .padding()
        .modelContainer(PersistenceService.shared.container!)
}
