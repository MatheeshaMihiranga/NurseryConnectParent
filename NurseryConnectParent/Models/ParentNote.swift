//
//  ParentNote.swift
//  NurseryConnectParent
//
//  Created on April 27, 2026
//

import Foundation
import SwiftData

enum NoteCategory: String, Codable, CaseIterable {
    case medicine = "Medicine"
    case question = "Question"
    case update = "Update"
    case general = "General"
    
    var icon: String {
        switch self {
        case .medicine: return "pill.fill"
        case .question: return "questionmark.circle.fill"
        case .update: return "info.circle.fill"
        case .general: return "note.text"
        }
    }
    
    var color: String {
        switch self {
        case .medicine: return "red"
        case .question: return "blue"
        case .update: return "orange"
        case .general: return "gray"
        }
    }
}

@Model
final class ParentNote {
    var id: UUID
    var childId: UUID
    var timestamp: Date
    var content: String
    var category: NoteCategory
    var isDraft: Bool
    var createdBy: String
    var lastModified: Date
    
    init(
        id: UUID = UUID(),
        childId: UUID,
        timestamp: Date = Date(),
        content: String,
        category: NoteCategory,
        isDraft: Bool = false,
        createdBy: String = "Parent",
        lastModified: Date = Date()
    ) {
        self.id = id
        self.childId = childId
        self.timestamp = timestamp
        self.content = content
        self.category = category
        self.isDraft = isDraft
        self.createdBy = createdBy
        self.lastModified = lastModified
    }
}
