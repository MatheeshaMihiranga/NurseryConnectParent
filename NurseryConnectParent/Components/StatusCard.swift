//
//  StatusCard.swift
//  NurseryConnectParent
//
//  Created on April 18, 2026
//

import SwiftUI

struct StatusCard: View {
    let title: String
    let icon: String
    let color: Color
    let subtitle: String?
    
    init(title: String, icon: String, color: Color, subtitle: String? = nil) {
        self.title = title
        self.icon = icon
        self.color = color
        self.subtitle = subtitle
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundStyle(color)
                .accessibilityHidden(true)
            
            VStack(spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(color.opacity(0.3), lineWidth: 1)
                )
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Status: \(title)" + (subtitle != nil ? ", \(subtitle!)" : ""))
    }
}

#Preview {
    VStack(spacing: 16) {
        StatusCard(
            title: "At Nursery",
            icon: "building.2.fill",
            color: .purple,
            subtitle: "Since 8:00 AM"
        )
        
        StatusCard(
            title: "In Transit",
            icon: "bus.fill",
            color: .blue,
            subtitle: "ETA 20 minutes"
        )
        
        StatusCard(
            title: "Happy Mood",
            icon: "face.smiling.fill",
            color: .green
        )
    }
    .padding()
}
