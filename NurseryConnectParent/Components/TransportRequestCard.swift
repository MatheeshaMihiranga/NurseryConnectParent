//
//  TransportRequestCard.swift
//  NurseryConnectParent
//
//  Created on April 27, 2026
//

import SwiftUI

struct TransportRequestCard: View {
    let request: TransportRequest
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: request.requestType.icon)
                    .font(.title3)
                    .foregroundStyle(.blue)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(.blue.opacity(0.1))
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(request.requestType.rawValue)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text(request.requestDate.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Status Badge
                HStack(spacing: 4) {
                    Image(systemName: request.status.icon)
                        .font(.caption2)
                    Text(request.status.rawValue)
                        .font(.caption2)
                        .fontWeight(.medium)
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Capsule().fill(statusColor(request.status)))
            }
            
            Divider()
            
            // Collector Info
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Authorized Collector")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text(request.authorizedCollector)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Phone")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text(request.collectorPhone)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            }
            
            // Pickup Note
            if !request.pickupNote.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Note")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text(request.pickupNote)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.background)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
    
    private func statusColor(_ status: RequestStatus) -> Color {
        switch status.color {
        case "orange": return .orange
        case "green": return .green
        case "red": return .red
        case "gray": return .gray
        default: return .blue
        }
    }
}

#Preview {
    TransportRequestCard(request: TransportRequest(
        childId: UUID(),
        requestDate: Date(),
        pickupNote: "Grandmother will collect today",
        authorizedCollector: "Mary Johnson",
        collectorPhone: "+44 7700 900456",
        requestType: .oneTime,
        status: .pending
    ))
    .padding()
}
