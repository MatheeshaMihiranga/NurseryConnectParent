//
//  DiaryViewModel.swift
//  NurseryConnectParent
//
//  Created on April 18, 2026
//

import Foundation
import SwiftUI

@Observable
class DiaryViewModel {
    var diaryEntries: [DiaryEntry] = []
    var selectedFilter: DiaryEntryType?
    var searchText: String = ""
    var isLoading = false
    var errorMessage: String?
    
    let childId: UUID

    private let dataProvider = SampleDataProvider.shared

    init(childId: UUID? = nil) {
        self.childId = childId ?? SampleDataProvider.shared.sampleChild.id
        loadDiaryEntries()
    }

    func loadDiaryEntries() {
        diaryEntries = dataProvider.getDiaryEntries(for: childId)
            .sorted(by: { $0.timestamp > $1.timestamp })
    }

    /// Simulates a network refresh using async/await
    func refresh() {
        Task { @MainActor in
            isLoading = true
            errorMessage = nil
            await DataService.shared.refreshData()
            loadDiaryEntries()
            isLoading = false
        }
    }
    
    var filteredEntries: [DiaryEntry] {
        var entries = diaryEntries
        
        // Apply type filter
        if let filter = selectedFilter {
            entries = entries.filter { $0.type == filter }
        }
        
        // Apply search filter
        if !searchText.isEmpty {
            entries = entries.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.details.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return entries
    }
    
    func clearFilter() {
        selectedFilter = nil
    }
    
    func setFilter(_ type: DiaryEntryType) {
        selectedFilter = type
    }
    
    func entriesByDate() -> [(Date, [DiaryEntry])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: filteredEntries) { entry in
            calendar.startOfDay(for: entry.timestamp)
        }
        
        return grouped.sorted(by: { $0.key > $1.key }).map { ($0.key, $0.value) }
    }
    
    // MARK: - CRUD Operations
    
    /// Create a new diary entry
    func createEntry(_ entry: DiaryEntry) {
        DataService.shared.createDiaryEntry(entry)
        loadDiaryEntries()
    }
    
    /// Update an existing diary entry
    func updateEntry(_ entry: DiaryEntry) {
        DataService.shared.updateDiaryEntry(entry)
        loadDiaryEntries()
    }
    
    /// Delete a diary entry
    func deleteEntry(_ entry: DiaryEntry) {
        DataService.shared.deleteDiaryEntry(entry)
        loadDiaryEntries()
    }
    
    /// Delete multiple entries at specific offsets
    func deleteEntries(at offsets: IndexSet, from entries: [DiaryEntry]) {
        for index in offsets {
            let entry = entries[index]
            deleteEntry(entry)
        }
    }
}

