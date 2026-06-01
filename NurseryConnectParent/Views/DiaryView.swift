//
//  DiaryView.swift
//  NurseryConnectParent
//
//  Created on April 18, 2026
//

import SwiftUI

struct DiaryView: View {
    @State private var viewModel = DiaryViewModel()
    @State private var parentNotesViewModel = ParentNotesViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Parent Notes Section
                    if !parentNotesViewModel.parentNotes.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Your Notes")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .padding(.horizontal)
                            
                            ForEach(parentNotesViewModel.parentNotes, id: \.id) { note in
                                ParentNoteCard(note: note)
                                    .padding(.horizontal)
                                    .contextMenu {
                                        Button {
                                            parentNotesViewModel.editingNote = note
                                        } label: {
                                            Label("Edit", systemImage: "pencil")
                                        }
                                        
                                        Button(role: .destructive) {
                                            parentNotesViewModel.deleteNote(note)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                        .padding(.top)
                    }
                    
                    // Filter Chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            FilterChip(
                                title: "All",
                                isSelected: viewModel.selectedFilter == nil,
                                action: {
                                    viewModel.clearFilter()
                                }
                            )
                            
                            ForEach(DiaryEntryType.allCases, id: \.self) { type in
                                FilterChip(
                                    title: type.rawValue,
                                    icon: type.icon,
                                    isSelected: viewModel.selectedFilter == type,
                                    action: {
                                        viewModel.setFilter(type)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Diary Entries by Date
                    if viewModel.filteredEntries.isEmpty {
                        ContentUnavailableView(
                            "No Diary Entries",
                            systemImage: "book.closed",
                            description: Text("No entries match your filter criteria.")
                        )
                        .padding(.top, 100)
                    } else {
                        ForEach(viewModel.entriesByDate(), id: \.0) { date, entries in
                            VStack(alignment: .leading, spacing: 12) {
                                // Date Header
                                Text(date, style: .date)
                                    .font(.headline)
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal)
                                    .padding(.top, 8)
                                
                                // Entries for this date
                                ForEach(entries, id: \.id) { entry in
                                    NavigationLink(destination: DiaryDetailView(entry: entry)) {
                                        DiaryEntryCard(entry: entry)
                                    }
                                    .buttonStyle(.plain)
                                    .padding(.horizontal)
                                }
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Daily Diary")
            .searchable(text: $viewModel.searchText, prompt: "Search diary entries")
            .refreshable {
                viewModel.refresh()
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView("Refreshing…")
                        .padding()
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                }
            }
            .alert("Error", isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        viewModel.refresh()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .accessibilityLabel("Refresh")
                    }
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        parentNotesViewModel.showingAddNote = true
                    }) {
                        Label("Add Note", systemImage: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $parentNotesViewModel.showingAddNote) {
                ParentNoteFormView(viewModel: parentNotesViewModel)
            }
            .sheet(item: Binding(
                get: { parentNotesViewModel.editingNote },
                set: { parentNotesViewModel.editingNote = $0 }
            )) { note in
                ParentNoteFormView(viewModel: parentNotesViewModel, editingNote: note)
            }
        }
    }
}

struct FilterChip: View {
    let title: String
    var icon: String?
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.caption)
                }
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? Color.accentColor : Color.gray.opacity(0.2))
            )
            .foregroundStyle(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
}

#Preview {
    DiaryView()
}
