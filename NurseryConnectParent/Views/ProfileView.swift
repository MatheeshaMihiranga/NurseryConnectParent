//
//  ProfileView.swift
//  NurseryConnectParent
//
//  Created on April 18, 2026
//

import SwiftUI

struct ProfileView: View {
    @State private var child = SampleDataProvider.shared.sampleChild
    @State private var showingSettings = false
    
    var body: some View {
        NavigationStack {
            List {
                // Child Profile Section
                Section {
                    HStack(spacing: 16) {
                        Image(systemName: child.photoName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 80)
                            .foregroundStyle(.white)
                            .background(
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [.blue, .purple],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text(child.name)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("\(child.age) years old")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            Text(child.room)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                // Child Information
                Section("Child Information") {
                    ProfileRow(icon: "person.fill", title: "Full Name", value: child.name)
                    ProfileRow(icon: "birthday.cake.fill", title: "Age", value: "\(child.age) years")
                    ProfileRow(icon: "door.left.hand.open", title: "Room", value: child.room)
                    ProfileRow(
                        icon: "exclamationmark.triangle.fill",
                        title: "Allergies",
                        value: child.allergies,
                        valueColor: child.allergies != "None" ? .orange : .secondary
                    )
                }
                
                // Contact Information
                Section("Emergency Contact") {
                    ProfileRow(icon: "phone.fill", title: "Contact Number", value: child.emergencyContact)
                }
                
                // Transport
                Section("Transport") {
                    HStack {
                        Image(systemName: "bus.fill")
                            .foregroundStyle(.blue)
                            .frame(width: 28)
                        
                        Text("Transport Service")
                        
                        Spacer()
                        
                        if child.isTransportEligible {
                            Label("Enrolled", systemImage: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundStyle(.green)
                        } else {
                            Label("Not Enrolled", systemImage: "xmark.circle.fill")
                                .font(.caption)
                                .foregroundStyle(.gray)
                        }
                    }
                }
                
                // App Settings
                Section("App Settings") {
                    NavigationLink(destination: SettingsView()) {
                        Label("Settings", systemImage: "gear")
                    }
                    
                    NavigationLink(destination: AboutView()) {
                        Label("About", systemImage: "info.circle")
                    }
                    
                    NavigationLink(destination: PrivacyView()) {
                        Label("Privacy Policy", systemImage: "hand.raised.fill")
                    }
                    
                    NavigationLink(destination: HelpView()) {
                        Label("Help & Support", systemImage: "questionmark.circle")
                    }
                }
                
                // Version Info
                Section {
                    HStack {
                        Text("Version")
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        Text("1.0.0 (MVP)")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
            }
            .navigationTitle("Profile")
        }
    }
}

struct ProfileRow: View {
    let icon: String
    let title: String
    let value: String
    var valueColor: Color = .secondary
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(.blue)
                .frame(width: 28)
            
            Text(title)
            
            Spacer()
            
            Text(value)
                .foregroundStyle(valueColor)
                .fontWeight(valueColor != .secondary ? .medium : .regular)
        }
    }
}

// Placeholder views for navigation
struct SettingsView: View {
    var body: some View {
        List {
            Section("Notifications") {
                Toggle("Push Notifications", isOn: .constant(true))
                Toggle("Diary Updates", isOn: .constant(true))
                Toggle("Transport Alerts", isOn: .constant(true))
            }
            
            Section("Display") {
                Toggle("Dark Mode", isOn: .constant(false))
                Picker("Text Size", selection: .constant("Medium")) {
                    Text("Small").tag("Small")
                    Text("Medium").tag("Medium")
                    Text("Large").tag("Large")
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AboutView: View {
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Text("NurseryConnectParent")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Stay connected with your child's day at nursery. View daily updates, track transport, and receive important notifications.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                    
                    Text("Version 1.0.0 (MVP)")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .padding(.top, 8)
                }
                .padding(.vertical, 8)
            }
            
            Section("Features") {
                Label("Daily Diary Updates", systemImage: "book.fill")
                Label("GPS Transport Tracking", systemImage: "bus.fill")
                Label("Push Notifications", systemImage: "bell.fill")
                Label("Child Profile Management", systemImage: "person.fill")
            }
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PrivacyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Privacy Policy")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Last updated: April 18, 2026")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Data Collection")
                        .font(.headline)
                    
                    Text("We collect only essential information needed to provide our services, including child profiles, diary entries, and transport information. All data is stored securely and in compliance with GDPR regulations.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Data Usage")
                        .font(.headline)
                    
                    Text("Your data is used solely for the purpose of providing nursery services and communication between staff and parents. We never share your data with third parties without explicit consent.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Your Rights")
                        .font(.headline)
                    
                    Text("You have the right to access, modify, or delete your data at any time. Please contact the nursery administration for assistance.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
        }
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct HelpView: View {
    var body: some View {
        List {
            Section("Getting Started") {
                NavigationLink("How to view diary entries") {
                    Text("Tap on the Diary tab to view all daily updates about your child.")
                        .padding()
                }
                NavigationLink("How to track transport") {
                    Text("Tap on the Transport tab to see real-time GPS tracking and estimated arrival times.")
                        .padding()
                }
            }
            
            Section("Contact Support") {
                Link(destination: URL(string: "mailto:support@nurseryconnect.com")!) {
                    Label("Email Support", systemImage: "envelope.fill")
                }
                
                Link(destination: URL(string: "tel:+441234567890")!) {
                    Label("Call Support", systemImage: "phone.fill")
                }
            }
            
            Section("FAQ") {
                NavigationLink("How often is the diary updated?") {
                    Text("The diary is updated in real-time throughout the day as activities occur.")
                        .padding()
                }
                NavigationLink("Is GPS tracking always active?") {
                    Text("GPS tracking is only active during scheduled transport times for your child's safety and privacy.")
                        .padding()
                }
            }
        }
        .navigationTitle("Help & Support")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ProfileView()
}
