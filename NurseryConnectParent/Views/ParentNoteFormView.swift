//
//  ParentNoteFormView.swift
//  NurseryConnectParent
//
//  Created on April 27, 2026
//

import SwiftUI

struct ParentNoteFormView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var content: String = ""
    @State private var selectedCategory: NoteCategory = .general
    
    let viewModel: ParentNotesViewModel
    let editingNote: ParentNote?
    
    init(viewModel: ParentNotesViewModel, editingNote: ParentNote? = nil) {
        self.viewModel = viewModel
        self.editingNote = editingNote
        
        if let note = editingNote {
            _content = State(initialValue: note.content)
            _selectedCategory = State(initialValue: note.category)
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Category") {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(NoteCategory.allCases, id: \.self) { category in
                            HStack {
                                Image(systemName: category.icon)
                                Text(category.rawValue)
                            }
                            .tag(category)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Note") {
                    TextEditor(text: $content)
                        .frame(minHeight: 150)
                }
                
                Section {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundStyle(.blue)
                        Text("Your note will be sent to the nursery staff.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle(editingNote == nil ? "Add Note" : "Edit Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(editingNote == nil ? "Add" : "Save") {
                        saveNote()
                    }
                    .disabled(content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private func saveNote() {
        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let note = editingNote {
            viewModel.updateNote(note, content: trimmedContent, category: selectedCategory)
        } else {
            viewModel.createNote(content: trimmedContent, category: selectedCategory)
        }
        
        dismiss()
    }
}

#Preview {
    ParentNoteFormView(viewModel: ParentNotesViewModel())
}
