//
//  NurseryConnectParentApp.swift
//  NurseryConnectParent
//
//  Created on April 18, 2026
//

import SwiftUI
import SwiftData

@main
struct NurseryConnectParentApp: App {
    let persistenceService = PersistenceService.shared
    
    init() {
        // Configure data service with persistence
        if let context = persistenceService.mainContext {
            DataService.shared.configure(with: context)
        }
        
        // Populate sample data for MVP
        // In production, this would be removed or conditional
        persistenceService.populateWithSampleData()
        
        // Configure accessibility
        configureAccessibility()
    }
    
    var body: some Scene {
        WindowGroup {
            if let container = persistenceService.container {
                ContentView()
                    .modelContainer(container)
            } else {
                Text("Unable to load app data. Please restart the app.")
                    .multilineTextAlignment(.center)
                    .padding()
            }
        }
    }
    
    // MARK: - Accessibility Configuration
    
    private func configureAccessibility() {
        // Enable accessibility features
        // These would be loaded from user preferences in production
        
        // Support for Dynamic Type
        // Support for VoiceOver
        // Support for Reduce Motion
        // All handled automatically by SwiftUI when using standard components
        
        print("✅ Accessibility features enabled")
    }
}
