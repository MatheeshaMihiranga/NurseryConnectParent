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
    
    // MARK: - Data Refresh
    
    func refreshData() async {
        // In production, this would fetch fresh data from API
        // For MVP with sample data, this is a no-op
        try? await Task.sleep(nanoseconds: 500_000_000) // Simulate network delay
    }
}
