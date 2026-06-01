// NurseryRealityView.swift
// VisionOSPrototype — Immersive 3-D nursery floor plan using RealityKit
//
// Displayed inside an ImmersiveSpace (.mixed immersion).
// Shows a floating top-down floor plan with four labelled zone boxes:
//   • Reading Area  (blue)
//   • Meal Area     (orange)
//   • Nap Area      (purple)
//   • Outdoor Play  (green)
//
// SwiftUI labels are attached to each zone entity using RealityView attachments.

import SwiftUI
import RealityKit

// MARK: - Zone descriptor

private struct NurseryZone: Identifiable {
    let id      : Int
    let name    : String
    let subtitle: String
    let icon    : String
    let r, g, b : Float   // base colour components for SimpleMaterial
    let x, z    : Float   // position offset on floor plan (metres)
}

// MARK: - NurseryRealityView

struct NurseryRealityView: View {

    @Environment(SpatialAppModel.self) private var appModel

    // Floor-plan origin: 1.3 m high, 1.6 m in front of user
    private let originPosition = SIMD3<Float>(0, 1.3, -1.6)

    // Zone half-size on the XZ plane (metres)
    private let zoneHalfSize: Float = 0.28

    private let zones: [NurseryZone] = [
        NurseryZone(id: 0, name: "Reading Area",  subtitle: "Story time & books",
                    icon: "book.fill",
                    r: 0.20, g: 0.50, b: 0.95,   // blue
                    x: -0.32, z: -0.32),
        NurseryZone(id: 1, name: "Meal Area",     subtitle: "Snacks & meals",
                    icon: "fork.knife",
                    r: 0.95, g: 0.55, b: 0.10,   // orange
                    x:  0.32, z: -0.32),
        NurseryZone(id: 2, name: "Nap Area",      subtitle: "Rest & sleep",
                    icon: "moon.fill",
                    r: 0.65, g: 0.25, b: 0.90,   // purple
                    x: -0.32, z:  0.32),
        NurseryZone(id: 3, name: "Outdoor Play",  subtitle: "Supervised free play",
                    icon: "tree.fill",
                    r: 0.15, g: 0.75, b: 0.30,   // green
                    x:  0.32, z:  0.32),
    ]

    var body: some View {
        RealityView { content, attachments in
            buildScene(in: content, attachments: attachments)
        } update: { content, attachments in
            // No dynamic updates needed for this prototype
        } attachments: {
            // Title label
            Attachment(id: "title") {
                titleLabel
            }

            // Per-zone labels
            ForEach(zones) { zone in
                Attachment(id: "zone_\(zone.id)") {
                    zoneLabelView(zone)
                }
            }
        }
        .gesture(
            TapGesture()
                .targetedToAnyEntity()
        )
    }

    // MARK: - Scene builder

    private func buildScene(
        in content: RealityViewContent,
        attachments: RealityViewAttachments
    ) {
        // ── Floor plane ────────────────────────────────────────────────────
        let floorMesh  = MeshResource.generatePlane(width: 0.75, depth: 0.75)
        let floorMat   = SimpleMaterial(
            color: UIColor(white: 0.92, alpha: 1.0),
            roughness: 0.9,
            isMetallic: false
        )
        let floorEntity = ModelEntity(mesh: floorMesh, materials: [floorMat])
        floorEntity.position = originPosition
        content.add(floorEntity)

        // ── Room border outline (thin rim) ─────────────────────────────────
        let rimMesh = MeshResource.generatePlane(width: 0.78, depth: 0.78)
        let rimMat  = SimpleMaterial(
            color: UIColor(red: 0.4, green: 0.5, blue: 0.7, alpha: 0.5),
            roughness: 1.0,
            isMetallic: false
        )
        let rimEntity = ModelEntity(mesh: rimMesh, materials: [rimMat])
        rimEntity.position = SIMD3(originPosition.x,
                                   originPosition.y - 0.002,
                                   originPosition.z)
        content.add(rimEntity)

        // ── Zone boxes ─────────────────────────────────────────────────────
        for zone in zones {
            let boxMesh = MeshResource.generateBox(
                size: [zoneHalfSize * 2, 0.018, zoneHalfSize * 2],
                cornerRadius: 0.015
            )
            let boxMat = SimpleMaterial(
                color: UIColor(
                    red  : CGFloat(zone.r),
                    green: CGFloat(zone.g),
                    blue : CGFloat(zone.b),
                    alpha: 0.75
                ),
                roughness: 0.6,
                isMetallic: false
            )
            let boxEntity = ModelEntity(mesh: boxMesh, materials: [boxMat])
            boxEntity.position = SIMD3(
                originPosition.x + zone.x,
                originPosition.y + 0.01,
                originPosition.z + zone.z
            )
            content.add(boxEntity)

            // Attach SwiftUI label above the box
            if let label = attachments.entity(for: "zone_\(zone.id)") {
                label.position = SIMD3(
                    originPosition.x + zone.x,
                    originPosition.y + 0.12,
                    originPosition.z + zone.z
                )
                content.add(label)
            }
        }

        // ── Title label above floor plan ───────────────────────────────────
        if let title = attachments.entity(for: "title") {
            title.position = SIMD3(
                originPosition.x,
                originPosition.y + 0.38,
                originPosition.z
            )
            content.add(title)
        }

        // ── Simple divider lines between zones ────────────────────────────
        let hLine = MeshResource.generateBox(size: [0.76, 0.004, 0.004])
        let vLine = MeshResource.generateBox(size: [0.004, 0.004, 0.76])
        let lineMat = SimpleMaterial(
            color: UIColor(white: 0.6, alpha: 0.6),
            roughness: 1.0,
            isMetallic: false
        )
        let hEntity = ModelEntity(mesh: hLine, materials: [lineMat])
        hEntity.position = SIMD3(originPosition.x, originPosition.y + 0.02, originPosition.z)
        let vEntity = ModelEntity(mesh: vLine, materials: [lineMat])
        vEntity.position = SIMD3(originPosition.x, originPosition.y + 0.02, originPosition.z)
        content.add(hEntity)
        content.add(vEntity)
    }

    // MARK: - Attachment views

    private var titleLabel: some View {
        VStack(spacing: 4) {
            Label("Rainbow Nursery — Floor Plan", systemImage: "building.2.fill")
                .font(.headline)
                .fontWeight(.bold)
            Text("Mixed immersion · tap a zone to explore")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial, in: Capsule())
    }

    private func zoneLabelView(_ zone: NurseryZone) -> some View {
        let color = Color(red: Double(zone.r), green: Double(zone.g), blue: Double(zone.b))
        return VStack(spacing: 3) {
            Image(systemName: zone.icon)
                .font(.subheadline)
            Text(zone.name)
                .font(.caption)
                .fontWeight(.semibold)
            Text(zone.subtitle)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.8))
        }
        .foregroundStyle(.white)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(color.opacity(0.85), in: RoundedRectangle(cornerRadius: 10))
    }
}
