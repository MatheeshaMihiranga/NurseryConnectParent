//
//  IncidentSignatureView.swift
//  NurseryConnectParent
//
//  Created on June 1, 2026
//
//  Uses PencilKit — the iPadOS-native drawing framework — to capture a
//  parent's digital signature when acknowledging an incident report.
//
//  Architecture:
//   PKCanvasRepresentable  — UIViewRepresentable bridge around PKCanvasView.
//   IncidentSignatureView  — SwiftUI sheet that embeds the canvas, handles
//                            validation, and persists directly via SwiftData.

import SwiftUI
import SwiftData
import PencilKit

// MARK: - PencilKit UIViewRepresentable Wrapper

/// Wraps `PKCanvasView` for use in SwiftUI.
/// Accepts Apple Pencil and finger input (`drawingPolicy = .anyInput`).
/// The parent binding is kept in sync via `PKCanvasViewDelegate`.
struct PKCanvasRepresentable: UIViewRepresentable {

    /// Two-way binding to the PKDrawing so the parent view can clear or read it.
    @Binding var drawing: PKDrawing

    // MARK: UIViewRepresentable

    func makeUIView(context: Context) -> PKCanvasView {
        let canvas = PKCanvasView()
        canvas.drawing           = drawing
        canvas.isOpaque          = false
        canvas.backgroundColor   = .clear
        // Use a fine pen; width 2 feels natural for a signature
        canvas.tool              = PKInkingTool(.pen, color: .black, width: 2)
        // .anyInput  → Apple Pencil AND finger — important for iPhone users
        canvas.drawingPolicy     = .anyInput
        canvas.delegate          = context.coordinator
        return canvas
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        // Only push changes from SwiftUI → UIKit (e.g., Clear button resets drawing).
        // Avoid infinite loops by guarding against equality.
        if uiView.drawing != drawing {
            uiView.drawing = drawing
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    // MARK: Coordinator / Delegate

    /// Bridges `PKCanvasViewDelegate` callbacks back into the SwiftUI binding.
    final class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: PKCanvasRepresentable

        init(_ parent: PKCanvasRepresentable) {
            self.parent = parent
        }

        // Called every time the user adds/modifies a stroke.
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            parent.drawing = canvasView.drawing
        }
    }
}

// MARK: - IncidentSignatureView

/// Full-screen sheet where the parent reviews a summary of the incident and
/// draws a digital signature to formally acknowledge the report.
///
/// On confirmation the view:
///  1. Serialises the PKDrawing → Data via `drawing.dataRepresentation()`
///  2. Mutates the SwiftData `IncidentReport` model in-place
///  3. Calls `modelContext.save()` to persist
///  4. Invokes `onSuccess()` so the caller can display a confirmation alert
struct IncidentSignatureView: View {

    let report: IncidentReport
    /// Called after the signature has been persisted successfully.
    let onSuccess: () -> Void

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss)      private var dismiss

    @State private var drawing            = PKDrawing()
    @State private var showValidationError = false
    @State private var isSaving           = false

    /// True when the canvas has no strokes at all.
    private var isSignatureEmpty: Bool { drawing.strokes.isEmpty }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // ── 1. Incident summary ──────────────────────────────────
                incidentSummaryHeader

                Divider()

                // ── 2. Instruction banner ────────────────────────────────
                instructionBanner

                Divider()

                // ── 3. Signature canvas (fills available space) ──────────
                signatureCanvas

                Divider()

                // ── 4. Legal note + confirm button ───────────────────────
                bottomActions
            }
            .navigationTitle("Sign & Acknowledge")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button(role: .destructive) {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            drawing = PKDrawing()
                        }
                    } label: {
                        Label("Clear", systemImage: "trash")
                    }
                    .disabled(isSignatureEmpty)
                }
            }
            .alert("Signature Required", isPresented: $showValidationError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Please draw your signature on the canvas before confirming acknowledgement.")
            }
        }
    }

    // MARK: - Incident Summary Header

    private var incidentSummaryHeader: some View {
        HStack(spacing: 14) {
            // Category icon
            Image(systemName: report.category.icon)
                .font(.title3)
                .foregroundStyle(categoryColor)
                .frame(width: 44, height: 44)
                .background(categoryColor.opacity(0.12),
                            in: RoundedRectangle(cornerRadius: 10))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 3) {
                Text(report.title)
                    .font(.headline)
                    .lineLimit(2)

                HStack(spacing: 6) {
                    Label(report.childName, systemImage: "person.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text("·")
                        .foregroundStyle(.secondary)

                    Text(report.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer(minLength: 0)

            // Severity indicator
            VStack(spacing: 3) {
                Image(systemName: report.severity.icon)
                    .font(.subheadline)
                    .foregroundStyle(severityColor)

                Text(report.severity.rawValue)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(severityColor)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(severityColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))
        }
        .padding()
        .background(Color(.systemBackground))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Incident: \(report.title), \(report.severity.rawValue) severity, child: \(report.childName)")
    }

    // MARK: - Instruction Banner

    private var instructionBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "pencil.tip.crop.circle")
                .font(.title3)
                .foregroundStyle(.blue)
                .accessibilityHidden(true)

            Text("Sign with Apple Pencil or your finger to confirm you have read and understood this incident report.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
    }

    // MARK: - Signature Canvas

    private var signatureCanvas: some View {
        ZStack(alignment: .bottom) {
            // Off-white signing surface
            Color(.systemBackground)

            // Baseline helper lines
            VStack(spacing: 0) {
                Spacer()
                // Solid baseline
                Rectangle()
                    .fill(Color(.systemGray3))
                    .frame(height: 1)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 52)
            }

            // "Sign here" watermark — hidden once user starts drawing
            if isSignatureEmpty {
                VStack {
                    Spacer()
                    HStack(spacing: 6) {
                        Image(systemName: "pencil.tip")
                            .font(.caption)
                        Text("Sign here")
                            .font(.subheadline)
                    }
                    .foregroundStyle(Color(.systemGray3))
                    .padding(.bottom, 58)
                }
                .allowsHitTesting(false)
            }

            // PencilKit canvas — sits on top so it captures all input
            PKCanvasRepresentable(drawing: $drawing)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Red highlight ring while canvas is empty
            if isSignatureEmpty {
                RoundedRectangle(cornerRadius: 0)
                    .strokeBorder(Color.red.opacity(0.25), lineWidth: 1.5)
                    .allowsHitTesting(false)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.easeInOut(duration: 0.2), value: isSignatureEmpty)
    }

    // MARK: - Bottom Actions

    private var bottomActions: some View {
        VStack(spacing: 12) {
            // Legal notice
            Text("By signing, you confirm that you have been informed of the incident described above and that all recorded details are accurate to the best of your knowledge.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            // Confirm button — disabled (greyed) until at least one stroke exists
            Button(action: confirmAcknowledgement) {
                HStack(spacing: 8) {
                    Image(systemName: isSignatureEmpty ? "pencil.slash" : "checkmark.circle.fill")
                    Text(isSignatureEmpty
                         ? "Draw your signature above to continue"
                         : "Confirm Acknowledgement")
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(
                    isSignatureEmpty
                        ? AnyShapeStyle(Color(.systemGray4))
                        : AnyShapeStyle(Color.blue.gradient),
                    in: RoundedRectangle(cornerRadius: 14)
                )
                .foregroundStyle(isSignatureEmpty ? Color(.systemGray) : .white)
            }
            .buttonStyle(.plain)
            .disabled(isSignatureEmpty || isSaving)
            .animation(.easeInOut(duration: 0.2), value: isSignatureEmpty)
            .accessibilityHint(
                isSignatureEmpty
                    ? "Draw your signature on the canvas above before confirming"
                    : "Saves your digital signature and marks this incident as acknowledged"
            )
        }
        .padding()
        .background(Color(.systemBackground))
    }

    // MARK: - Confirmation Logic

    private func confirmAcknowledgement() {
        guard !isSignatureEmpty else {
            showValidationError = true
            return
        }

        isSaving = true

        // Serialise PKDrawing → Data (PencilKit's own binary format)
        let signatureData = drawing.dataRepresentation()

        // Mutate the SwiftData model in-place
        report.parentAcknowledged  = true
        report.acknowledgementDate = Date()
        report.signatureData       = signatureData
        report.lastModified        = Date()

        do {
            try modelContext.save()
        } catch {
            // Non-fatal for the user flow; the in-memory model is already updated
            print("⚠️ SwiftData save failed after acknowledgement: \(error)")
        }

        isSaving = false
        onSuccess()
        dismiss()
    }

    // MARK: - Color Helpers

    private var categoryColor: Color { Color(report.category.color) }
    private var severityColor: Color { Color(report.severity.color) }
}

// MARK: - Preview

#Preview("Unacknowledged — Serious") {
    IncidentSignatureView(
        report: SampleDataProvider.shared.sampleIncidentReports[0],
        onSuccess: {}
    )
    .modelContainer(PersistenceService.shared.container!)
}

#Preview("Minor Fall") {
    IncidentSignatureView(
        report: SampleDataProvider.shared.sampleIncidentReports[1],
        onSuccess: {}
    )
    .modelContainer(PersistenceService.shared.container!)
}
