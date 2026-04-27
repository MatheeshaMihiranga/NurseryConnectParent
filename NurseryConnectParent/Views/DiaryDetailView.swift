//
//  DiaryDetailView.swift
//  NurseryConnectParent
//
//  Created on April 18, 2026
//

import SwiftUI

struct DiaryDetailView: View {
    let entry: DiaryEntry
    var viewModel: DiaryViewModel?
    
    @Environment(\.dismiss) private var dismiss
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header Card
                VStack(spacing: 16) {
                    // Icon and Type
                    HStack {
                        Image(systemName: entry.type.icon)
                            .font(.system(size: 40))
                            .foregroundStyle(colorForType(entry.type))
                            .frame(width: 60, height: 60)
                            .background(
                                Circle()
                                    .fill(colorForType(entry.type).opacity(0.1))
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(entry.type.rawValue)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .textCase(.uppercase)
                            
                            Text(entry.title)
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        
                        Spacer()
                    }
                    
                    Divider()
                    
                    // Time and Staff
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Time")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            Text(entry.timestamp.formatted(date: .abbreviated, time: .shortened))
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Recorded by")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            HStack(spacing: 6) {
                                Image(systemName: "person.circle.fill")
                                    .font(.caption)
                                
                                Text(entry.staffName)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.background)
                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                )
                
                // Details Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Details")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    Text(entry.details)
                        .font(.body)
                        .foregroundStyle(.primary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.background)
                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                )
                
                // Notes Section
                if !entry.notes.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Additional Notes", systemImage: "note.text")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        
                        Text(entry.notes)
                            .font(.body)
                            .foregroundStyle(.primary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(colorForType(entry.type).opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .strokeBorder(colorForType(entry.type).opacity(0.2), lineWidth: 1)
                            )
                    )
                }
                
                // Tips Section (Optional Enhancement)
                if entry.type == .meal {
                    InfoBox(
                        icon: "lightbulb.fill",
                        title: "Nutrition Tip",
                        message: "A balanced diet helps children stay energized and focused throughout the day.",
                        color: .orange
                    )
                }
            }
            .padding()
        }
        .navigationTitle("Diary Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                HStack(spacing: 16) {
                    if viewModel != nil {
                        Button(action: {
                            showingEditSheet = true
                        }) {
                            Image(systemName: "pencil")
                                .accessibilityLabel("Edit")
                        }
                        
                        Button(role: .destructive, action: {
                            showingDeleteAlert = true
                        }) {
                            Image(systemName: "trash")
                                .accessibilityLabel("Delete")
                        }
                    }
                    
                    Button(action: {
                        // Share functionality could be added here
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .accessibilityLabel("Share")
                    }
                }
            }
        }
        .alert("Delete Entry", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                viewModel?.deleteEntry(entry)
                dismiss()
            }
        } message: {
            Text("Are you sure you want to delete this diary entry? This action cannot be undone.")
        }
        .sheet(isPresented: $showingEditSheet) {
            if let viewModel = viewModel {
                DiaryEntryFormView(childId: entry.childId, entry: entry) { updatedEntry in
                    viewModel.updateEntry(updatedEntry)
                }
            }
        }
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

struct InfoBox: View {
    let icon: String
    let title: String
    let message: String
    let color: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        )
    }
}

#Preview {
    NavigationStack {
        DiaryDetailView(
            entry: SampleDataProvider.shared.sampleDiaryEntries[0],
            viewModel: DiaryViewModel()
        )
    }
}

