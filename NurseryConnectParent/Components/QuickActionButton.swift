//
//  QuickActionButton.swift
//  NurseryConnectParent
//
//  Created on April 18, 2026
//

import SwiftUI

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(width: 50, height: 50)
                    .background(
                        Circle()
                            .fill(color)
                            .shadow(color: color.opacity(0.3), radius: 4, x: 0, y: 2)
                    )
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(width: 80)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
        .accessibilityAddTraits(.isButton)
    }
}

#Preview {
    HStack(spacing: 20) {
        QuickActionButton(
            title: "View Diary",
            icon: "book.fill",
            color: .orange
        ) {
            print("View Diary tapped")
        }
        
        QuickActionButton(
            title: "Track Transport",
            icon: "bus.fill",
            color: .blue
        ) {
            print("Track Transport tapped")
        }
        
        QuickActionButton(
            title: "Notifications",
            icon: "bell.fill",
            color: .red
        ) {
            print("Notifications tapped")
        }
        
        QuickActionButton(
            title: "Profile",
            icon: "person.fill",
            color: .purple
        ) {
            print("Profile tapped")
        }
    }
    .padding()
}
