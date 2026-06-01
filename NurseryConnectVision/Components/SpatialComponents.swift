// SpatialComponents.swift
// VisionOSPrototype — Shared UI components used across all panels

import SwiftUI

// MARK: - SpatialCard ─────────────────────────────────────────────────────────
// Generic glass-material card with a header strip.

struct SpatialCard<Content: View>: View {
    let title      : String
    let icon       : String
    let accentColor: Color
    let content    : () -> Content

    init(
        title: String,
        icon: String,
        accentColor: Color = .blue,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title       = title
        self.icon        = icon
        self.accentColor = accentColor
        self.content     = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(accentColor)
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            Divider()
            content()
        }
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18))
    }
}

// MARK: - SpatialStatTile ──────────────────────────────────────────────────────
// A compact value + label tile used in summary rows.

struct SpatialStatTile: View {
    let value: String
    let label: String
    let icon : String
    let color: Color

    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .monospacedDigit()
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(minWidth: 90)
        .padding(12)
        .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - SpatialSeverityBadge ────────────────────────────────────────────────

struct SpatialSeverityBadge: View {
    let severity: SpatialSeverity

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: severity.icon)
                .font(.caption2)
            Text(severity.rawValue)
                .font(.caption)
                .fontWeight(.semibold)
        }
        .foregroundStyle(severity.color)
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(severity.color.opacity(0.15), in: Capsule())
    }
}

// MARK: - TransportStatusBadge ────────────────────────────────────────────────

struct TransportStatusBadge: View {
    let status: SpatialTransportStatus

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: status.icon)
                .font(.caption2)
            Text(status.rawValue)
                .font(.caption)
                .fontWeight(.semibold)
        }
        .foregroundStyle(status.color)
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(status.color.opacity(0.15), in: Capsule())
    }
}

// MARK: - AlertPriorityBadge ──────────────────────────────────────────────────

struct AlertPriorityBadge: View {
    let priority: SpatialAlertPriority

    var body: some View {
        Text(priority.rawValue)
            .font(.caption2)
            .fontWeight(.bold)
            .foregroundStyle(.white)
            .padding(.horizontal, 7)
            .padding(.vertical, 2)
            .background(priority.color, in: Capsule())
    }
}

// MARK: - OccupancyBar ────────────────────────────────────────────────────────

struct OccupancyBar: View {
    let present : Int
    let capacity: Int
    let color   : Color

    private var fraction: Double {
        capacity > 0 ? min(Double(present) / Double(capacity), 1.0) : 0
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(color.opacity(0.2))
                RoundedRectangle(cornerRadius: 4)
                    .fill(color)
                    .frame(width: geo.size.width * fraction)
                    .animation(.easeInOut(duration: 0.4), value: fraction)
            }
        }
        .frame(height: 6)
    }
}

// MARK: - SectionHeaderRow ────────────────────────────────────────────────────

struct SectionHeaderRow: View {
    let title      : String
    let icon       : String
    let accentColor: Color
    let actionLabel: String
    let action     : () -> Void

    var body: some View {
        HStack {
            Label(title, systemImage: icon)
                .font(.headline)
                .foregroundStyle(accentColor)
            Spacer()
            Button(action: action) {
                HStack(spacing: 4) {
                    Text(actionLabel)
                        .font(.subheadline)
                    Image(systemName: "chevron.right")
                        .font(.caption)
                }
                .foregroundStyle(accentColor)
            }
            .buttonStyle(.plain)
        }
    }
}
