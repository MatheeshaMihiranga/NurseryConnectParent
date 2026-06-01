//
//  TransportRequestFormView.swift
//  NurseryConnectParent
//
//  Created on April 27, 2026
//

import SwiftUI

struct TransportRequestFormView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var requestDate = Date()
    @State private var pickupNote: String = ""
    @State private var authorizedCollector: String = ""
    @State private var collectorPhone: String = ""
    @State private var requestType: RequestType = .oneTime
    
    let viewModel: TransportRequestViewModel
    let editingRequest: TransportRequest?
    
    init(viewModel: TransportRequestViewModel, editingRequest: TransportRequest? = nil) {
        self.viewModel = viewModel
        self.editingRequest = editingRequest
        
        if let request = editingRequest {
            _requestDate = State(initialValue: request.requestDate)
            _pickupNote = State(initialValue: request.pickupNote)
            _authorizedCollector = State(initialValue: request.authorizedCollector)
            _collectorPhone = State(initialValue: request.collectorPhone)
            _requestType = State(initialValue: request.requestType)
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Request Type") {
                    Picker("Type", selection: $requestType) {
                        ForEach(RequestType.allCases, id: \.self) { type in
                            HStack {
                                Image(systemName: type.icon)
                                Text(type.rawValue)
                            }
                            .tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Date") {
                    DatePicker("Pickup Date", selection: $requestDate, displayedComponents: .date)
                }
                
                Section("Authorized Collector") {
                    TextField("Full Name", text: $authorizedCollector)
                        .textContentType(.name)
                    
                    TextField("Phone Number", text: $collectorPhone)
                        .textContentType(.telephoneNumber)
                        .keyboardType(.phonePad)
                }
                
                Section("Pickup Note") {
                    TextEditor(text: $pickupNote)
                        .frame(minHeight: 100)
                }
                .headerProminence(.increased)
                
                Section {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundStyle(.blue)
                        Text("Requests require nursery approval. You'll be notified of the status.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle(editingRequest == nil ? "New Request" : "Edit Request")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(editingRequest == nil ? "Submit" : "Update") {
                        saveRequest()
                    }
                    .disabled(!isFormValid)
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        !authorizedCollector.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !collectorPhone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func saveRequest() {
        if let request = editingRequest {
            viewModel.updateRequest(
                request,
                pickupNote: pickupNote,
                authorizedCollector: authorizedCollector,
                collectorPhone: collectorPhone
            )
        } else {
            viewModel.createRequest(
                requestDate: requestDate,
                pickupNote: pickupNote,
                authorizedCollector: authorizedCollector,
                collectorPhone: collectorPhone,
                requestType: requestType
            )
        }
        
        dismiss()
    }
}

#Preview {
    TransportRequestFormView(viewModel: TransportRequestViewModel())
}
