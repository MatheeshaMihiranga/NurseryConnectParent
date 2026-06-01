//
//  InfoBox.swift
//  NurseryConnectParent
//
//  Created on April 27, 2026
//

import SwiftUI

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
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(color.opacity(0.1))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(color)
                
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(color.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

#Preview {
    VStack(spacing: 16) {
        InfoBox(
            icon: "lightbulb.fill",
            title: "Nutrition Tip",
            message: "A balanced diet helps children stay energized and focused throughout the day.",
            color: .orange
        )
        
        InfoBox(
            icon: "heart.fill",
            title: "Health Note",
            message: "Regular outdoor play promotes physical development and well-being.",
            color: .red
        )
    }
    .padding()
}
