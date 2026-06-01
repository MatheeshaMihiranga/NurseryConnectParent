//
//  EditChildInfoView.swift
//  NurseryConnectParent
//
//  Created on April 27, 2026
//

import SwiftUI

struct EditChildInfoView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var emergencyContact: String
    @State private var allergies: String
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    let child: Child
    let dataService = DataService.shared
    
    init(child: Child) {
        self.child = child
        _emergencyContact = State(initialValue: child.emergencyContact)
        _allergies = State(initialValue: child.allergies)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Emergency Contact") {
                    TextField("Phone Number", text: $emergencyContact)
                        .textContentType(.telephoneNumber)
                        .keyboardType(.phonePad)
                }
                
                Section("Allergies") {
                    TextEditor(text: $allergies)
                        .frame(minHeight: 100)
                }
                .headerProminence(.increased)
                
                Section {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                        Text("Allergy changes require nursery verification before they take effect.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Edit Child Info")
            .navigationBarTitleDisplayMode(.inline)
            .disabled(isLoading)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(isLoading || !isFormValid)
                }
            }
            .overlay {
                if isLoading {
                    ProgressView("Saving…")
                        .padding()
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                }
            }
            .alert("Error", isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }
    
    private var isFormValid: Bool {
        !emergencyContact.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func saveChanges() {
        isLoading = true
        errorMessage = nil
        
        do {
            try dataService.updateChildInfo(
                child: child,
                emergencyContact: emergencyContact,
                allergies: allergies
            )
            dismiss()
        } catch {
            errorMessage = "Failed to save changes: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}

#Preview {
    EditChildInfoView(child: SampleDataProvider.shared.sampleChild)
}
