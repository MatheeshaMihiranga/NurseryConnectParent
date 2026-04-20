//
//  TransportView.swift
//  NurseryConnectParent
//
//  Created on April 18, 2026
//

import SwiftUI
import MapKit

struct TransportView: View {
    @State private var viewModel = TransportViewModel()
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    if !viewModel.isTransportEligible {
                        // Not Eligible for Transport
                        ContentUnavailableView(
                            "Transport Not Available",
                            systemImage: "bus.fill",
                            description: Text("Your child is not currently enrolled in the transport service.")
                        )
                        .padding(.top, 100)
                    } else if let transport = viewModel.transportUpdate {
                        // Transport Status Card
                        TransportStatusCard(transportUpdate: transport)
                            .padding(.horizontal)
                        
                        // Map Placeholder
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Live Tracking")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .padding(.horizontal)
                            
                            MapPlaceholder(status: transport.status)
                                .padding(.horizontal)
                        }
                        
                        // Additional Info
                        if transport.status == .inTransit || transport.status == .arriving {
                            VStack(spacing: 16) {
                                InfoCard(
                                    icon: "clock.fill",
                                    title: "Estimated Arrival",
                                    value: viewModel.etaText,
                                    color: .blue
                                )
                                
                                InfoCard(
                                    icon: "figure.walk.arrival",
                                    title: "Boarding Time",
                                    value: viewModel.boardingTimeText,
                                    color: .orange
                                )
                            }
                            .padding(.horizontal)
                        }
                        
                        // Safety Information
                        SafetyInfoSection()
                            .padding(.horizontal)
                        
                    } else {
                        // No Transport Today
                        ContentUnavailableView(
                            "No Transport Scheduled",
                            systemImage: "bus.fill",
                            description: Text("There are no transport updates for today.")
                        )
                        .padding(.top, 100)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Transport Tracking")
            .refreshable {
                viewModel.refresh()
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        viewModel.refresh()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .accessibilityLabel("Refresh")
                    }
                }
            }
        }
    }
}

struct MapPlaceholder: View {
    let status: TransportStatus
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1278),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    var body: some View {
        VStack {
            Map(initialPosition: .region(region)) {
                Annotation("Transport Location", coordinate: region.center) {
                    Image(systemName: "bus.fill")
                        .font(.title)
                        .foregroundStyle(.white)
                        .padding()
                        .background(Circle().fill(.blue))
                }
            }
            .frame(height: 250)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(.gray.opacity(0.2), lineWidth: 1)
            )
            
            Text("Map showing approximate location")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.top, 4)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Map showing transport location")
    }
}

struct InfoCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .frame(width: 50, height: 50)
                .background(
                    Circle()
                        .fill(color.opacity(0.1))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Text(value)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.background)
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
}

struct SafetyInfoSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Safety Information", systemImage: "shield.fill")
                .font(.headline)
                .foregroundStyle(.green)
            
            VStack(alignment: .leading, spacing: 8) {
                SafetyPoint(text: "All vehicles are GPS tracked in real-time")
                SafetyPoint(text: "Qualified and DBS-checked drivers")
                SafetyPoint(text: "Child safety seats provided")
                SafetyPoint(text: "Hand-to-hand transfer protocol")
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.green.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(.green.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct SafetyPoint: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.caption)
                .foregroundStyle(.green)
            
            Text(text)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    TransportView()
}
