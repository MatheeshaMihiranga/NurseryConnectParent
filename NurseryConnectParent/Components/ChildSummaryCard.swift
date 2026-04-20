//
//  ChildSummaryCard.swift
//  NurseryConnectParent
//
//  Created on April 18, 2026
//

import SwiftUI

struct ChildSummaryCard: View {
    let child: Child
    
    var body: some View {
        HStack(spacing: 16) {
            // Child Photo
            Image(systemName: child.photoName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 70, height: 70)
                .foregroundStyle(.white)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .clipShape(Circle())
                .accessibilityLabel("Child profile photo")
            
            // Child Info
            VStack(alignment: .leading, spacing: 6) {
                Text(child.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                
                HStack(spacing: 12) {
                    Label("\(child.age) years", systemImage: "birthday.cake.fill")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Label(child.room, systemImage: "door.left.hand.open")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                if child.allergies != "None" && !child.allergies.isEmpty {
                    Label(child.allergies, systemImage: "exclamationmark.triangle.fill")
                        .font(.caption)
                        .foregroundStyle(.orange)
                        .padding(.top, 2)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.background)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(child.name), \(child.age) years old, in \(child.room)")
    }
}

#Preview {
    ChildSummaryCard(child: SampleDataProvider.shared.sampleChild)
        .padding()
}
