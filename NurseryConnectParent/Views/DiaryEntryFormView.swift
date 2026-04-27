//
//  DiaryEntryFormView.swift
//  NurseryConnectParent
//
//  Created on April 27, 2026
//

import SwiftUI

struct DiaryEntryFormView: View {
    @Environment(\.dismiss) private var dismiss
    
    let childId: UUID
    let entry: DiaryEntry?
    let onSave: (DiaryEntry) -> Void
    
    @State private var selectedType: DiaryEntryType = .activity
    @State private var title: String = ""
    @State private var details: String = ""
    @State private var notes: String = ""
    @State private var timestamp: Date = Date()
    @State private var staffName: String = "Staff Member"
    
    private var isEditing: Bool {
        entry != nil
    }
    
    private var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !details.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    init(childId: UUID, entry: DiaryEntry? = nil, onSave: @escaping (DiaryEntry) -> Void) {
        self.childId = childId
        self.entry = entry
        self.onSave = onSave
        
        if let entry = entry {
            _selectedType = State(initialValue: entry.type)
            _title = State(initialValue: entry.title)
            _details = State(initialValue: entry.details)
            _notes = State(initialValue: entry.notes)
            _timestamp = State(initialValue: entry.timestamp)
            _staffName = State(initialValue: entry.staffName)
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Type Selection
                Section("Entry Type") {
                    Picker("Type", selection: $selectedType) {
                        ForEach(DiaryEntryType.allCases, id: \.self) { type in
                            HStack {
                                Image(systemName: type.icon)
                                Text(type.rawValue)
                            }
                            .tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                // Basic Information
                Section("Information") {
                    TextField("Title", text: $title)
                        .textInputAutocapitalization(.sentences)
                    
                    DatePicker("Date & Time", selection: $timestamp)
                    
                    TextField("Staff Name", text: $staffName)
                        .textInputAutocapitalization(.words)
                }
                
                // Details
                Section("Details") {
                    TextEditor(text: $details)
                        .frame(minHeight: 100)
                        .textInputAutocapitalization(.sentences)
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                
                // Notes (Optional)
                Section("Additional Notes (Optional)") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                        .textInputAutocapitalization(.sentences)
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }
            .navigationTitle(isEditing ? "Edit Entry" : "New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveEntry()
                    }
                    .disabled(!isValid)
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func saveEntry() {
        let diaryEntry: DiaryEntry
        
        if let existingEntry = entry {
            // Update existing entry
            existingEntry.type = selectedType
            existingEntry.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
            existingEntry.details = details.trimmingCharacters(in: .whitespacesAndNewlines)
            existingEntry.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
            existingEntry.timestamp = timestamp
            existingEntry.staffName = staffName.trimmingCharacters(in: .whitespacesAndNewlines)
            diaryEntry = existingEntry
        } else {
            // Create new entry
            diaryEntry = DiaryEntry(
                childId: childId,
                type: selectedType,
                timestamp: timestamp,
                title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                details: details.trimmingCharacters(in: .whitespacesAndNewlines),
                notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
                staffName: staffName.trimmingCharacters(in: .whitespacesAndNewlines)
            )
        }
        
        onSave(diaryEntry)
        dismiss()
    }
}

#Preview("New Entry") {
    DiaryEntryFormView(childId: UUID()) { _ in }
}

#Preview("Edit Entry") {
    DiaryEntryFormView(
        childId: UUID(),
        entry: DiaryEntry(
            childId: UUID(),
            type: .meal,
            timestamp: Date(),
            title: "Lunch Time",
            details: "Had spaghetti and meatballs",
            notes: "Ate everything!",
            staffName: "Sarah Johnson"
        )
    ) { _ in }
}
