//
//  TransportViewModel.swift
//  NurseryConnectParent
//
//  Created on April 18, 2026
//

import Foundation
import SwiftUI

@Observable
class TransportViewModel {
    var transportUpdate: TransportUpdate?
    var isTransportEligible: Bool = false
    
    private let dataProvider = SampleDataProvider.shared
    private let childId: UUID
    
    init(childId: UUID? = nil) {
        self.childId = childId ?? SampleDataProvider.shared.sampleChild.id
        self.isTransportEligible = dataProvider.sampleChild.isTransportEligible
        loadTransportUpdate()
    }
    
    func loadTransportUpdate() {
        transportUpdate = dataProvider.getTransportUpdate(for: childId)
    }
    
    func refresh() {
        loadTransportUpdate()
    }
    
    var statusTitle: String {
        transportUpdate?.status.rawValue ?? "No Transport Today"
    }
    
    var statusIcon: String {
        transportUpdate?.status.icon ?? "house.fill"
    }
    
    var statusColor: Color {
        guard let colorString = transportUpdate?.status.color else {
            return .gray
        }
        
        switch colorString {
        case "gray": return .gray
        case "orange": return .orange
        case "blue": return .blue
        case "green": return .green
        case "purple": return .purple
        default: return .blue
        }
    }
    
    var showETA: Bool {
        guard let status = transportUpdate?.status else { return false }
        return status == .inTransit || status == .arriving
    }
    
    var etaText: String {
        guard let eta = transportUpdate?.estimatedArrival else {
            return "N/A"
        }
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: eta)
    }
    
    var boardingTimeText: String {
        guard let boardingTime = transportUpdate?.boardingTime else {
            return "N/A"
        }
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: boardingTime)
    }
    
    var lastUpdateText: String {
        guard let lastUpdate = transportUpdate?.lastUpdate else {
            return "N/A"
        }
        
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: lastUpdate, relativeTo: Date())
    }
}
