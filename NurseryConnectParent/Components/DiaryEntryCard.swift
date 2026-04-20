//
//  DiaryEntryCard.swift
//  NurseryConnectParent
//
//  Created on April 18, 2026
//

import SwiftUI

struct DiaryEntryCard: View {
    let entry: DiaryEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header: Icon, Type, and Time
            HStack {
                Image(systemName: entry.type.icon)
                    .font(.title3)
                    .foregroundStyle(colorForType(entry.type))
                    .accessibilityHidden(true)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    Text(entry.type.rawValue)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Text(entry.timestamp, style: .time)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            // Details
            Text(entry.details)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .lineLimit(3)
            
            // Footer: Staff name
            if !entry.staffName.isEmpty {
                HStack {
                    Image(systemName: "person.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text(entry.staffName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.background)
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(entry.type.rawValue) at \(entry.timestamp.formatted(date: .omitted, time: .shortened)): \(entry.title). \(entry.details)")
    }
    
    private func colorForType(_ type: DiaryEntryType) -> Color {
        switch type {
        case .meal: return .orange
        case .nap: return .indigo
        case .activity: return .green
        case .mood: return .yellow
        case .milestone: return .purple
        case .incident: return .red
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        ForEach(SampleDataProvider.shared.sampleDiaryEntries.prefix(3), id: \.id) { entry in
            DiaryEntryCard(entry: entry)
        }
    }
    .padding()
}

