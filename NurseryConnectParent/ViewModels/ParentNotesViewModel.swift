//
//  ParentNotesViewModel.swift
//  NurseryConnectParent
//
//  Created on April 27, 2026
//

import Foundation
import SwiftUI

@Observable
class ParentNotesViewModel {
    var parentNotes: [ParentNote] = []
    var isLoading = false
    var errorMessage: String?
    var showingAddNote = false
    var editingNote: ParentNote?
    
    private let childId: UUID
    private let dataService = DataService.shared
    
    init(childId: UUID? = nil) {
        self.childId = childId ?? SampleDataProvider.shared.sampleChild.id
        loadParentNotes()
    }
    
    func loadParentNotes() {
        parentNotes = dataService.getParentNotes(for: childId)
    }
    
    func createNote(content: String, category: NoteCategory) {
        isLoading = true
        errorMessage = nil
        
        let note = ParentNote(
            childId: childId,
            content: content,
            category: category
        )
        
        do {
            try dataService.createParentNote(note)
            loadParentNotes()
            showingAddNote = false
        } catch {
            errorMessage = "Failed to create note: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func updateNote(_ note: ParentNote, content: String, category: NoteCategory) {
        isLoading = true
        errorMessage = nil
        
        do {
            try dataService.updateParentNote(note, content: content, category: category)
            loadParentNotes()
            editingNote = nil
        } catch {
            errorMessage = "Failed to update note: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func deleteNote(_ note: ParentNote) {
        isLoading = true
        errorMessage = nil
        
        do {
            try dataService.deleteParentNote(note)
            loadParentNotes()
        } catch {
            errorMessage = "Failed to delete note: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func refresh() {
        loadParentNotes()
    }
}
