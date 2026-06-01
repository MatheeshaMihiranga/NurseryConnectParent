//
//  DiaryActivityChart.swift
//  NurseryConnectParent
//
//  Created on June 1, 2026
//
//  Swift Charts — weekly diary activity bar chart.
//  Requires iOS 16+. Project targets iOS 26.2 — fully compatible.

import SwiftUI
import Charts
import SwiftData

// MARK: - Data point

struct DiaryDayPoint: Identifiable {
    let id = UUID()
    let label: String    // "Mon", "Tue" …
    let date:  Date
    let count: Int
}

// MARK: - DiaryActivityChart

/// Bar chart showing the count of diary entries per day over the last 7 days.
struct DiaryActivityChart: View {

    @Query(sort: \DiaryEntry.timestamp, order: .reverse)
    private var allEntries: [DiaryEntry]

    private var dataPoints: [DiaryDayPoint] {
        let calendar = Calendar.current
        let today    = calendar.startOfDay(for: Date())

        return (0..<7).reversed().map { daysAgo -> DiaryDayPoint in
            let dayStart = calendar.date(byAdding: .day, value: -daysAgo, to: today)!
            let dayEnd   = calendar.date(byAdding: .day, value:  1,       to: dayStart)!

            let count = allEntries.filter {
                $0.timestamp >= dayStart && $0.timestamp < dayEnd
            }.count

            let formatter        = DateFormatter()
            formatter.dateFormat = "EEE"   // "Mon", "Tue" …
            let label = daysAgo == 0
                ? "Today"
                : formatter.string(from: dayStart)

            return DiaryDayPoint(label: label, date: dayStart, count: count)
        }
    }

    private var maxCount: Int { max((dataPoints.map(\.count).max() ?? 0) + 1, 4) }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            // ── Section header ────────────────────────────────────────
            Label("Weekly Diary Activity", systemImage: "chart.bar.fill")
                .font(.headline)
                .foregroundStyle(.orange)

            Text("Diary entries recorded over the last 7 days")
                .font(.caption)
                .foregroundStyle(.secondary)

            // ── Chart ─────────────────────────────────────────────────
            Chart(dataPoints) { point in
                BarMark(
                    x: .value("Day",   point.label),
                    y: .value("Count", point.count)
                )
                .foregroundStyle(
                    point.label == "Today"
                        ? Color.orange
                        : Color.orange.opacity(0.45)
                )
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
            .chartYScale(domain: 0...maxCount)
            .chartYAxis {
                AxisMarks(values: .stride(by: 1)) { value in
                    AxisGridLine()
                    AxisValueLabel()
                }
            }
            .chartXAxis {
                AxisMarks { value in
                    AxisValueLabel()
                }
            }
            .frame(height: 160)
            .accessibilityLabel(accessibilitySummary)
        }
        .padding()
        .background(
            Color(.secondarySystemBackground),
            in: RoundedRectangle(cornerRadius: 16)
        )
    }

    // MARK: - Accessibility

    private var accessibilitySummary: String {
        let total = dataPoints.map(\.count).reduce(0, +)
        return "Weekly diary activity chart. \(total) total entries recorded over the last 7 days."
    }
}

// MARK: - Preview

#Preview {
    DiaryActivityChart()
        .padding()
        .modelContainer(PersistenceService.shared.container!)
}
