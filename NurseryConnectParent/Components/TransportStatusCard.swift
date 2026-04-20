//
//  TransportStatusCard.swift
//  NurseryConnectParent
//
//  Created on April 18, 2026
//

import SwiftUI

struct TransportStatusCard: View {
    let transportUpdate: TransportUpdate
    
    var body: some View {
        VStack(spacing: 16) {
            // Status Header
            HStack {
                Image(systemName: transportUpdate.status.icon)
                    .font(.title)
                    .foregroundStyle(statusColor)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(transportUpdate.status.rawValue)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    
                    Text("Last updated \(relativeTime)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            
            Divider()
            
            // Details
            VStack(spacing: 12) {
                if let boardingTime = transportUpdate.boardingTime {
                    DetailRow(
                        icon: "clock.fill",
                        title: "Boarding Time",
                        value: boardingTime.formatted(date: .omitted, time: .shortened)
                    )
                }
                
                if let eta = transportUpdate.estimatedArrival {
                    DetailRow(
                        icon: "location.fill",
                        title: "Estimated Arrival",
                        value: eta.formatted(date: .omitted, time: .shortened)
                    )
                }
                
                if !transportUpdate.currentLocation.isEmpty {
                    DetailRow(
                        icon: "mappin.circle.fill",
                        title: "Current Location",
                        value: transportUpdate.currentLocation
                    )
                }
                
                if !transportUpdate.driverName.isEmpty {
                    DetailRow(
                        icon: "person.fill",
                        title: "Driver",
                        value: transportUpdate.driverName
                    )
                }
                
                if !transportUpdate.vehicleNumber.isEmpty {
                    DetailRow(
                        icon: "bus.fill",
                        title: "Vehicle",
                        value: transportUpdate.vehicleNumber
                    )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.background)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Transport status: \(transportUpdate.status.rawValue)")
    }
    
    private var statusColor: Color {
        switch transportUpdate.status.color {
        case "gray": return .gray
        case "orange": return .orange
        case "blue": return .blue
        case "green": return .green
        case "purple": return .purple
        default: return .blue
        }
    }
    
    private var relativeTime: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: transportUpdate.lastUpdate, relativeTo: Date())
    }
}

struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(.secondary)
                .frame(width: 24)
            
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.primary)
        }
    }
}

#Preview {
    TransportStatusCard(transportUpdate: SampleDataProvider.shared.sampleTransportUpdate)
        .padding()
}
