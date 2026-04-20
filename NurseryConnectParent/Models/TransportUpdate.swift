//
//  TransportUpdate.swift
//  NurseryConnectParent
//
//  Created on April 18, 2026
//

import Foundation
import SwiftData

enum TransportStatus: String, Codable {
    case notInTransit = "Not in Transit"
    case boarding = "Boarding"
    case inTransit = "In Transit"
    case arriving = "Arriving Soon"
    case arrived = "Arrived"
    case atNursery = "At Nursery"
    
    var icon: String {
        switch self {
        case .notInTransit: return "house.fill"
        case .boarding: return "figure.walk.arrival"
        case .inTransit: return "bus.fill"
        case .arriving: return "location.fill"
        case .arrived: return "checkmark.circle.fill"
        case .atNursery: return "building.2.fill"
        }
    }
    
    var color: String {
        switch self {
        case .notInTransit: return "gray"
        case .boarding: return "orange"
        case .inTransit: return "blue"
        case .arriving: return "green"
        case .arrived: return "green"
        case .atNursery: return "purple"
        }
    }
}

@Model
final class TransportUpdate {
    var id: UUID
    var childId: UUID
    var status: TransportStatus
    var boardingTime: Date?
    var estimatedArrival: Date?
    var lastUpdate: Date
    var currentLocation: String
    var driverName: String
    var vehicleNumber: String
    
    init(
        id: UUID = UUID(),
        childId: UUID,
        status: TransportStatus,
        boardingTime: Date? = nil,
        estimatedArrival: Date? = nil,
        lastUpdate: Date = Date(),
        currentLocation: String = "",
        driverName: String = "",
        vehicleNumber: String = ""
    ) {
        self.id = id
        self.childId = childId
        self.status = status
        self.boardingTime = boardingTime
        self.estimatedArrival = estimatedArrival
        self.lastUpdate = lastUpdate
        self.currentLocation = currentLocation
        self.driverName = driverName
        self.vehicleNumber = vehicleNumber
    }
}
