//
//  TransportRequestViewModel.swift
//  NurseryConnectParent
//
//  Created on April 27, 2026
//

import Foundation
import SwiftUI

@Observable
class TransportRequestViewModel {
    var transportRequests: [TransportRequest] = []
    var isLoading = false
    var errorMessage: String?
    var showingAddRequest = false
    var editingRequest: TransportRequest?
    
    private let childId: UUID
    private let dataService = DataService.shared
    
    init(childId: UUID? = nil) {
        self.childId = childId ?? SampleDataProvider.shared.sampleChild.id
        loadTransportRequests()
    }
    
    func loadTransportRequests() {
        transportRequests = dataService.getTransportRequests(for: childId)
    }
    
    func createRequest(
        requestDate: Date,
        pickupNote: String,
        authorizedCollector: String,
        collectorPhone: String,
        requestType: RequestType
    ) {
        isLoading = true
        errorMessage = nil
        
        let request = TransportRequest(
            childId: childId,
            requestDate: requestDate,
            pickupNote: pickupNote,
            authorizedCollector: authorizedCollector,
            collectorPhone: collectorPhone,
            requestType: requestType
        )
        
        do {
            try dataService.createTransportRequest(request)
            loadTransportRequests()
            showingAddRequest = false
        } catch {
            errorMessage = "Failed to create request: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func updateRequest(
        _ request: TransportRequest,
        pickupNote: String,
        authorizedCollector: String,
        collectorPhone: String
    ) {
        isLoading = true
        errorMessage = nil
        
        do {
            try dataService.updateTransportRequest(
                request,
                pickupNote: pickupNote,
                authorizedCollector: authorizedCollector,
                collectorPhone: collectorPhone
            )
            loadTransportRequests()
            editingRequest = nil
        } catch {
            errorMessage = "Failed to update request: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func cancelRequest(_ request: TransportRequest) {
        isLoading = true
        errorMessage = nil
        
        do {
            try dataService.cancelTransportRequest(request)
            loadTransportRequests()
        } catch {
            errorMessage = "Failed to cancel request: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func deleteRequest(_ request: TransportRequest) {
        isLoading = true
        errorMessage = nil
        
        do {
            try dataService.deleteTransportRequest(request)
            loadTransportRequests()
        } catch {
            errorMessage = "Failed to delete request: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func refresh() {
        loadTransportRequests()
    }
    
    var pendingRequests: [TransportRequest] {
        transportRequests.filter { $0.status == .pending }
    }
    
    var approvedRequests: [TransportRequest] {
        transportRequests.filter { $0.status == .approved }
    }
}
