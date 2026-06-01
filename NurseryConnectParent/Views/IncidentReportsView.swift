//
//  IncidentReportsView.swift
//  NurseryConnectParent
//
//  Created on June 1, 2026
//

import SwiftUI
import SwiftData

// MARK: - Filter enum

enum IncidentFilter: String, CaseIterable, Identifiable {
    case all              = "All"
    case pending          = "Pending"
    case acknowledged     = "Acknowledged"
    case highSeverity     = "High Severity"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .all:          return "list.bullet"
        case .pending:      return "exclamationmark.circle.fill"
        case .acknowledged: return "checkmark.circle.fill"
        case .highSeverity: return "flame.fill"
        }
    }
}

// MARK: - Main View

struct IncidentReportsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \IncidentReport.date, order: .reverse)
    private var allReports: [IncidentReport]

    @State private var selectedFilter: IncidentFilter = .all
    @State private var searchText = ""

    // MARK: - Filtered data

    private var filteredReports: [IncidentReport] {
        let base: [IncidentReport]
        switch selectedFilter {
        case .all:
            base = allReports
        case .pending:
            base = allReports.filter { !$0.parentAcknowledged }
        case .acknowledged:
            base = allReports.filter { $0.parentAcknowledged }
        case .highSeverity:
            base = allReports.filter { $0.severity == .serious || $0.severity == .moderate }
        }

        guard !searchText.isEmpty else { return base }
        let query = searchText.lowercased()
        return base.filter {
            $0.title.lowercased().contains(query) ||
            $0.category.rawValue.lowercased().contains(query) ||
            $0.location.lowercased().contains(query)
        }
    }

    private var pendingCount: Int {
        allReports.filter { !$0.parentAcknowledged }.count
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // ── Filter chips ─────────────────────────────────────────
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(IncidentFilter.allCases) { filter in
                            IncidentFilterChip(
                                filter: filter,
                                isSelected: selectedFilter == filter,
                                badgeCount: filter == .pending ? pendingCount : 0
                            ) {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedFilter = filter
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                }
                .background(.bar)

                Divider()

                // ── Report list ──────────────────────────────────────────
                if filteredReports.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        LazyVStack(spacing: 14) {
                            // Pending acknowledgement header
                            if selectedFilter == .all && pendingCount > 0 {
                                PendingBanner(count: pendingCount)
                                    .padding(.horizontal)
                                    .padding(.top, 16)
                            }

                            ForEach(filteredReports, id: \.id) { report in
                                NavigationLink(value: report) {
                                    IncidentReportCard(report: report)
                                        .padding(.horizontal)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.bottom, 24)
                        .padding(.top, selectedFilter == .all && pendingCount > 0 ? 0 : 16)
                    }
                }
            }
            .navigationTitle("Incident Reports")
            .navigationDestination(for: IncidentReport.self) { report in
                IncidentReportDetailView(report: report)
            }
            .searchable(text: $searchText, prompt: "Search by title, category, or location")
        }
    }

    // MARK: - Empty state

    private var emptyState: some View {
        ContentUnavailableView {
            Label(emptyStateTitle, systemImage: emptyStateIcon)
        } description: {
            Text(emptyStateDescription)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptyStateTitle: String {
        searchText.isEmpty ? "No Incident Reports" : "No Results"
    }

    private var emptyStateIcon: String {
        searchText.isEmpty ? "checkmark.shield.fill" : "magnifyingglass"
    }

    private var emptyStateDescription: String {
        if !searchText.isEmpty {
            return "No reports match \"\(searchText)\". Try a different search."
        }
        switch selectedFilter {
        case .all:          return "No incident reports have been filed."
        case .pending:      return "There are no reports awaiting acknowledgement."
        case .acknowledged: return "No reports have been acknowledged yet."
        case .highSeverity: return "No moderate or serious incidents have been recorded."
        }
    }
}

// MARK: - Supporting Views

private struct IncidentFilterChip: View {
    let filter: IncidentFilter
    let isSelected: Bool
    let badgeCount: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: filter.icon)
                    .font(.caption)
                Text(filter.rawValue)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)

                if badgeCount > 0 && !isSelected {
                    Text("\(badgeCount)")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.red, in: Capsule())
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? Color.accentColor : Color(.secondarySystemBackground),
                        in: Capsule())
            .foregroundStyle(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

private struct PendingBanner: View {
    let count: Int

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.white)
            Text(count == 1
                 ? "1 report requires your acknowledgement"
                 : "\(count) reports require your acknowledgement")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.white)
            Spacer()
        }
        .padding(12)
        .background(.red.gradient, in: RoundedRectangle(cornerRadius: 12))
        .accessibilityLabel("\(count) incident report\(count == 1 ? "" : "s") awaiting parent acknowledgement")
    }
}

// MARK: - Preview

#Preview {
    IncidentReportsView()
        .modelContainer(PersistenceService.shared.container!)
}
