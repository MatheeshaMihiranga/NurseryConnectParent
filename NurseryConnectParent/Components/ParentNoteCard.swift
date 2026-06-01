//
//  ParentNoteCard.swift
//  NurseryConnectParent
//
//  Created on April 27, 2026
//

import SwiftUI

struct ParentNoteCard: View {
    let note: ParentNote
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: note.category.icon)
                    .font(.title3)
                    .foregroundStyle(colorForCategory(note.category))
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(colorForCategory(note.category).opacity(0.1))
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(note.category.rawValue)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Label("Your Note", systemImage: "person.fill")
                            .font(.caption2)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(.blue))
                    }
                    
                    Text(note.timestamp.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Content
            Text(note.content)
                .font(.body)
                .foregroundStyle(.primary)
                .lineLimit(3)
            
            if note.isDraft {
                HStack {
                    Image(systemName: "doc.badge.clock")
                        .font(.caption)
                    Text("Draft")
                        .font(.caption)
                }
                .foregroundStyle(.orange)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.background)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(colorForCategory(note.category).opacity(0.2), lineWidth: 2)
                )
        )
    }
    
    private func colorForCategory(_ category: NoteCategory) -> Color {
        switch category.color {
        case "red": return .red
        case "blue": return .blue
        case "orange": return .orange
        case "gray": return .gray
        default: return .blue
        }
    }
}

#Preview {
    ParentNoteCard(note: ParentNote(
        childId: UUID(),
        content: "Emily had medicine at 8 AM as prescribed.",
        category: .medicine
    ))
    .padding()
}
