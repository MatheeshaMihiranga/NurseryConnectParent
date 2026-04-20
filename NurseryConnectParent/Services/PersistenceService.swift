//
//  PersistenceService.swift
//  NurseryConnectParent
//
//  Created on April 18, 2026
//

import Foundation
import SwiftData

/// SwiftData persistence manager
/// Handles model container setup and persistence configuration
class PersistenceService {
    static let shared = PersistenceService()
    
    private(set) var container: ModelContainer?
    
    private init() {
        setupContainer()
    }
    
    // MARK: - Setup
    
    private func setupContainer() {
        let schema = Schema([
            Child.self,
            DiaryEntry.self,
            TransportUpdate.self,
            NotificationItem.self
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false, // Set to false for persistent storage
            allowsSave: true
        )
        
        do {
            container = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
            print("✅ SwiftData container initialized successfully")
        } catch {
            print("❌ Failed to create ModelContainer: \(error)")
            // Fallback to in-memory container
            setupInMemoryContainer()
        }
    }
    
    private func setupInMemoryContainer() {
        let schema = Schema([
            Child.self,
            DiaryEntry.self,
            TransportUpdate.self,
            NotificationItem.self
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )
        
        do {
            container = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
            print("⚠️ Using in-memory SwiftData container")
        } catch {
            print("❌ Fatal: Cannot create even in-memory container: \(error)")
        }
    }
    
    // MARK: - Context
    
    var mainContext: ModelContext? {
        container?.mainContext
    }
    
    func createContext() -> ModelContext? {
        guard let container = container else { return nil }
        return ModelContext(container)
    }
    
    // MARK: - Sample Data Population
    
    func populateWithSampleData() {
        guard let context = mainContext else {
            print("❌ No context available for populating sample data")
            return
        }
        
        // Check if data already exists
        let childDescriptor = FetchDescriptor<Child>()
        if let existingChildren = try? context.fetch(childDescriptor),
           !existingChildren.isEmpty {
            print("ℹ️ Sample data already exists, skipping population")
            return
        }
        
        // Insert sample data
        let provider = SampleDataProvider.shared
        
        // Insert child
        context.insert(provider.sampleChild)
        
        // Insert diary entries
        for entry in provider.sampleDiaryEntries {
            context.insert(entry)
        }
        
        // Insert transport update
        context.insert(provider.sampleTransportUpdate)
        
        // Insert notifications
        for notification in provider.sampleNotifications {
            context.insert(notification)
        }
        
        // Save
        do {
            try context.save()
            print("✅ Sample data populated successfully")
        } catch {
            print("❌ Failed to save sample data: \(error)")
        }
    }
    
    // MARK: - Data Operations
    
    func save(context: ModelContext? = nil) throws {
        let contextToSave = context ?? mainContext
        try contextToSave?.save()
    }
    
    func delete<T: PersistentModel>(_ item: T, context: ModelContext? = nil) {
        let contextToUse = context ?? mainContext
        contextToUse?.delete(item)
    }
    
    func deleteAll<T: PersistentModel>(ofType type: T.Type) throws {
        guard let context = mainContext else { return }
        
        let descriptor = FetchDescriptor<T>()
        let items = try context.fetch(descriptor)
        
        for item in items {
            context.delete(item)
        }
        
        try context.save()
    }
    
    // MARK: - Reset
    
    func resetAllData() throws {
        guard let context = mainContext else { return }
        
        try deleteAll(ofType: Child.self)
        try deleteAll(ofType: DiaryEntry.self)
        try deleteAll(ofType: TransportUpdate.self)
        try deleteAll(ofType: NotificationItem.self)
        
        print("✅ All data reset successfully")
    }
}
