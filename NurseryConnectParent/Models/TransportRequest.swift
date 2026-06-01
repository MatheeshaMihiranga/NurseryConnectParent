//
//  TransportRequest.swift
//  NurseryConnectParent
//
//  Created on April 27, 2026
//

import Foundation
import SwiftData

enum RequestType: String, Codable, CaseIterable {
    case regular = "Regular Pickup"
    case oneTime = "One-Time Change"
    case cancel = "Cancel Request"
    
    var icon: String {
        switch self {
        case .regular: return "calendar.circle.fill"
        case .oneTime: return "calendar.badge.clock"
        case .cancel: return "calendar.badge.minus"
        }
    }
}

enum RequestStatus: String, Codable {
    case pending = "Pending"
    case approved = "Approved"
    case declined = "Declined"
    case cancelled = "Cancelled"
    
    var color: String {
        switch self {
        case .pending: return "orange"
        case .approved: return "green"
        case .declined: return "red"
        case .cancelled: return "gray"
        }
    }
    
    var icon: String {
        switch self {
        case .pending: return "clock.fill"
        case .approved: return "checkmark.circle.fill"
        case .declined: return "xmark.circle.fill"
        case .cancelled: return "minus.circle.fill"
        }
    }
}

@Model
final class TransportRequest {
    var id: UUID
    var childId: UUID
    var requestDate: Date
    var pickupNote: String
    var authorizedCollector: String
    var collectorPhone: String
    var requestType: RequestType
    var status: RequestStatus
    var createdAt: Date
    var lastModified: Date
    var parentName: String
    
    init(
        id: UUID = UUID(),
        childId: UUID,
        requestDate: Date,
        pickupNote: String,
        authorizedCollector: String,
        collectorPhone: String,
        requestType: RequestType,
        status: RequestStatus = .pending,
        createdAt: Date = Date(),
        lastModified: Date = Date(),
        parentName: String = "Parent"
    ) {
        self.id = id
        self.childId = childId
        self.requestDate = requestDate
        self.pickupNote = pickupNote
        self.authorizedCollector = authorizedCollector
        self.collectorPhone = collectorPhone
        self.requestType = requestType
        self.status = status
        self.createdAt = createdAt
        self.lastModified = lastModified
        self.parentName = parentName
    }
}
