//
//  DataService.swift
//  NurseryConnectParent
//
//  Created on April 18, 2026
//

import Foundation
import SwiftData

/// Centralized data access service
/// Provides a unified interface for accessing data from sample provider or persistence
class DataService {
    static let shared = DataService()
    
    private let sampleProvider = SampleDataProvider.shared
    private var modelContext: ModelContext?
    
    // For MVP, we use sample data. In production, this would interface with SwiftData/API
    private var useSampleData = true
    
    private init() {}
    
    // MARK: - Configuration
    
    func configure(with context: ModelContext?) {
        self.modelContext = context
    }
    
    func setUseSampleData(_ value: Bool) {
        self.useSampleData = value
    }
    
    // MARK: - Child Data
    
    func getChild() -> Child {
        if useSampleData {
            return sampleProvider.sampleChild
        }
        
        // In production, fetch from SwiftData
        // let descriptor = FetchDescriptor<Child>()
        // return try? modelContext?.fetch(descriptor).first ?? sampleProvider.sampleChild
        
        return sampleProvider.sampleChild
    }
    
    // MARK: - Diary Data
    
    func getDiaryEntries(for childId: UUID) -> [DiaryEntry] {
        if useSampleData {
            return sampleProvider.getDiaryEntries(for: childId)
        }
        
        // In production, fetch from SwiftData with predicate
        // let predicate = #Predicate<DiaryEntry> { $0.childId == childId }
        // let descriptor = FetchDescriptor(predicate: predicate, sortBy: [SortDescriptor(\.timestamp, order: .reverse)])
        // return try? modelContext?.fetch(descriptor) ?? []
        
        return sampleProvider.getDiaryEntries(for: childId)
    }
    
    func getDiaryEntry(by id: UUID) -> DiaryEntry? {
        if useSampleData {
            return sampleProvider.sampleDiaryEntries.first { $0.id == id }
        }
        
        return sampleProvider.sampleDiaryEntries.first { $0.id == id }
    }
    
    // MARK: - Transport Data
    
    func getTransportUpdate(for childId: UUID) -> TransportUpdate? {
        if useSampleData {
            return sampleProvider.getTransportUpdate(for: childId)
        }
        
        // In production, fetch latest transport update from SwiftData
        // let predicate = #Predicate<TransportUpdate> { $0.childId == childId }
        // let descriptor = FetchDescriptor(predicate: predicate, sortBy: [SortDescriptor(\.lastUpdate, order: .reverse)])
        // return try? modelContext?.fetch(descriptor).first
        
        return sampleProvider.getTransportUpdate(for: childId)
    }
    
    // MARK: - Notification Data
    
    func getNotifications(for childId: UUID? = nil) -> [NotificationItem] {
        if useSampleData {
            return sampleProvider.getNotifications(for: childId)
        }
        
        // In production, fetch from SwiftData
        // var descriptor = FetchDescriptor<NotificationItem>(sortBy: [SortDescriptor(\.timestamp, order: .reverse)])
        // if let childId = childId {
        //     descriptor.predicate = #Predicate { notification in
        //         notification.childId == childId || notification.childId == nil
        //     }
        // }
        // return try? modelContext?.fetch(descriptor) ?? []
        
        return sampleProvider.getNotifications(for: childId)
    }
    
    func getUnreadNotificationCount() -> Int {
        if useSampleData {
            return sampleProvider.getUnreadNotificationCount()
        }
        
        // In production, count unread from SwiftData
        // let predicate = #Predicate<NotificationItem> { !$0.isRead }
        // let descriptor = FetchDescriptor(predicate: predicate)
        // return (try? modelContext?.fetchCount(descriptor)) ?? 0
        
        return sampleProvider.getUnreadNotificationCount()
    }
    
    func markNotificationAsRead(_ notificationId: UUID) {
        // In production, update in SwiftData
        // if let context = modelContext,
        //    let notification = try? context.fetch(FetchDescriptor<NotificationItem>()).first(where: { $0.id == notificationId }) {
        //     notification.isRead = true
        //     try? context.save()
        // }
        
        // For sample data, this would need to be handled in the ViewModel
        print("Mark notification \(notificationId) as read")
    }
    
    // MARK: - Parent Notes CRUD
    
    func getParentNotes(for childId: UUID) -> [ParentNote] {
        guard let context = modelContext else { return [] }
        
        let predicate = #Predicate<ParentNote> { $0.childId == childId }
        let descriptor = FetchDescriptor(predicate: predicate, sortBy: [SortDescriptor(\.timestamp, order: .reverse)])
        
        return (try? context.fetch(descriptor)) ?? []
    }
    
    func createParentNote(_ note: ParentNote) throws {
        guard let context = modelContext else { 
            throw NSError(domain: "DataService", code: 1, userInfo: [NSLocalizedDescriptionKey: "No context available"])
        }
        
        context.insert(note)
        try context.save()
    }
    
    func updateParentNote(_ note: ParentNote, content: String, category: NoteCategory) throws {
        guard let context = modelContext else {
            throw NSError(domain: "DataService", code: 1, userInfo: [NSLocalizedDescriptionKey: "No context available"])
        }
        
        note.content = content
        note.category = category
        note.lastModified = Date()
        try context.save()
    }
    
    func deleteParentNote(_ note: ParentNote) throws {
        guard let context = modelContext else {
            throw NSError(domain: "DataService", code: 1, userInfo: [NSLocalizedDescriptionKey: "No context available"])
        }
        
        context.delete(note)
        try context.save()
    }
    
    // MARK: - Transport Requests CRUD
    
    func getTransportRequests(for childId: UUID) -> [TransportRequest] {
        guard let context = modelContext else { return [] }
        
        let predicate = #Predicate<TransportRequest> { $0.childId == childId }
        let descriptor = FetchDescriptor(predicate: predicate, sortBy: [SortDescriptor(\.requestDate, order: .reverse)])
        
        return (try? context.fetch(descriptor)) ?? []
    }
    
    func createTransportRequest(_ request: TransportRequest) throws {
        guard let context = modelContext else {
            throw NSError(domain: "DataService", code: 1, userInfo: [NSLocalizedDescriptionKey: "No context available"])
        }
        
        context.insert(request)
        try context.save()
    }
    
    func updateTransportRequest(_ request: TransportRequest, pickupNote: String, authorizedCollector: String, collectorPhone: String) throws {
        guard let context = modelContext else {
            throw NSError(domain: "DataService", code: 1, userInfo: [NSLocalizedDescriptionKey: "No context available"])
        }
        
        request.pickupNote = pickupNote
        request.authorizedCollector = authorizedCollector
        request.collectorPhone = collectorPhone
        request.lastModified = Date()
        try context.save()
    }
    
    func cancelTransportRequest(_ request: TransportRequest) throws {
        guard let context = modelContext else {
            throw NSError(domain: "DataService", code: 1, userInfo: [NSLocalizedDescriptionKey: "No context available"])
        }
        
        request.status = .cancelled
        request.lastModified = Date()
        try context.save()
    }
    
    func deleteTransportRequest(_ request: TransportRequest) throws {
        guard let context = modelContext else {
            throw NSError(domain: "DataService", code: 1, userInfo: [NSLocalizedDescriptionKey: "No context available"])
        }
        
        context.delete(request)
        try context.save()
    }
    
    // MARK: - Child Update
    
    func updateChildInfo(child: Child, emergencyContact: String, allergies: String) throws {
        guard let context = modelContext else {
            throw NSError(domain: "DataService", code: 1, userInfo: [NSLocalizedDescriptionKey: "No context available"])
        }
        
        child.emergencyContact = emergencyContact
        child.allergies = allergies
        try context.save()
    }
    
    // MARK: - Incident Reports

    func getIncidentReports(for childId: UUID) -> [IncidentReport] {
        if useSampleData {
            return sampleProvider.getIncidentReports(for: childId)
        }

        guard let context = modelContext else { return [] }
        let predicate = #Predicate<IncidentReport> { $0.childId == childId }
        let descriptor = FetchDescriptor(
            predicate: predicate,
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    func getPendingIncidentReports(for childId: UUID) -> [IncidentReport] {
        getIncidentReports(for: childId).pendingAcknowledgement
    }

    func getPendingIncidentCount(for childId: UUID) -> Int {
        getPendingIncidentReports(for: childId).count
    }

    func createIncidentReport(_ report: IncidentReport) throws {
        guard let context = modelContext else {
            throw NSError(domain: "DataService", code: 1,
                userInfo: [NSLocalizedDescriptionKey: "No context available"])
        }
        context.insert(report)
        try context.save()
    }

    func acknowledgeIncidentReport(
        _ report: IncidentReport,
        signatureData: Data?
    ) throws {
        guard let context = modelContext else {
            throw NSError(domain: "DataService", code: 1,
                userInfo: [NSLocalizedDescriptionKey: "No context available"])
        }
        report.parentAcknowledged = true
        report.acknowledgementDate = Date()
        report.signatureData = signatureData
        report.lastModified = Date()
        try context.save()
    }

    func deleteIncidentReport(_ report: IncidentReport) throws {
        guard let context = modelContext else {
            throw NSError(domain: "DataService", code: 1,
                userInfo: [NSLocalizedDescriptionKey: "No context available"])
        }
        context.delete(report)
        try context.save()
    }

    // MARK: - Data Refresh

    func refreshData() async {
        // In production, this would fetch fresh data from API
        // For MVP with sample data, this is a no-op
        try? await Task.sleep(nanoseconds: 500_000_000) // Simulate network delay
    }
}
