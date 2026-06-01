//
//  IncidentPDFPreviewView.swift
//  NurseryConnectParent
//
//  Created on June 1, 2026
//
//  PDFKit role (Assignment 2 advanced library requirement):
//   - PDFView    — high-fidelity, scrollable, zoomable PDF renderer from Apple.
//                  Handles pagination, search, and thumbnail generation for free.
//   - PDFDocument — object model loaded from the Data produced by IncidentPDFService.
//
//  Architecture:
//   PDFKitView              — UIViewRepresentable wrapping PDFView.
//   IncidentPDFPreviewView  — SwiftUI sheet: generates the PDF on appear,
//                             shows a loading spinner, then embeds PDFKitView.
//                             Provides Share (ShareLink) and Print toolbar items.

import SwiftUI
import PDFKit
import UIKit

// MARK: - PDFKitView (UIViewRepresentable)

/// Wraps `PDFView` from PDFKit for use in SwiftUI.
/// - `autoScales = true`  → page fills available width automatically.
/// - `displayMode = .singlePageContinuous` → vertical scroll through all pages.
/// - `displayDirection = .vertical` → natural reading direction.
struct PDFKitView: UIViewRepresentable {

    let document: PDFDocument

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document         = document
        pdfView.autoScales       = true
        pdfView.displayMode      = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.backgroundColor  = UIColor.systemGroupedBackground
        // Scroll indicator
        pdfView.usePageViewController(false, withViewOptions: nil)
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {
        // Only update when the document identity actually changes
        guard uiView.document !== document else { return }
        uiView.document = document
    }
}

// MARK: - IncidentPDFPreviewView

struct IncidentPDFPreviewView: View {

    let report: IncidentReport
    @Environment(\.dismiss) private var dismiss

    @State private var pdfDocument: PDFDocument?
    @State private var tempURL:     URL?
    @State private var isGenerating = true
    @State private var showPrintError = false

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Group {
                if isGenerating {
                    generatingView
                } else if let doc = pdfDocument {
                    PDFKitView(document: doc)
                        .ignoresSafeArea(edges: .bottom)
                } else {
                    errorView
                }
            }
            .navigationTitle("Incident Report PDF")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
        }
        .task { await buildPDF() }
        .alert("Print Error", isPresented: $showPrintError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Printing is not available on this device or simulator.")
        }
    }

    // MARK: - Generating spinner

    private var generatingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .controlSize(.large)
            Text("Generating PDF report…")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Error state

    private var errorView: some View {
        ContentUnavailableView {
            Label("Could Not Generate PDF", systemImage: "xmark.circle.fill")
        } description: {
            Text("The incident report PDF could not be created. Please try again.")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Close") { dismiss() }
        }

        // Share button — only shown once the PDF temp file is ready
        if let url = tempURL {
            ToolbarItem(placement: .primaryAction) {
                ShareLink(
                    item: url,
                    preview: SharePreview(
                        "Incident Report — \(report.title)",
                        image: Image(systemName: "doc.richtext.fill")
                    )
                ) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
                .accessibilityLabel("Share PDF report")
            }

            ToolbarItem(placement: .secondaryAction) {
                Button {
                    printPDF(url: url)
                } label: {
                    Label("Print", systemImage: "printer")
                }
            }
        }
    }

    // MARK: - PDF generation

    private func buildPDF() async {
        isGenerating = true
        defer { isGenerating = false }

        let service = IncidentPDFService.shared
        let data    = service.generateData(for: report)

        guard let doc = PDFDocument(data: data) else { return }
        pdfDocument = doc

        // Write to temp directory so ShareLink / Print can access a URL
        let filename = "IncidentReport-\(report.childName.replacingOccurrences(of: " ", with: "-"))-\(shortID).pdf"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        try? data.write(to: url, options: .atomic)
        tempURL = url
    }

    private var shortID: String {
        String(report.id.uuidString.prefix(8))
    }

    // MARK: - Print

    private func printPDF(url: URL) {
        guard UIPrintInteractionController.isPrintingAvailable else {
            showPrintError = true
            return
        }

        let printInfo        = UIPrintInfo(dictionary: nil)
        printInfo.jobName    = "Incident Report — \(report.title)"
        printInfo.outputType = .general

        let controller            = UIPrintInteractionController.shared
        controller.printInfo      = printInfo
        controller.printingItem   = url
        controller.present(animated: true, completionHandler: nil)
    }
}

// MARK: - Preview

#Preview("Unacknowledged") {
    IncidentPDFPreviewView(report: SampleDataProvider.shared.sampleIncidentReports[0])
}

#Preview("Acknowledged") {
    IncidentPDFPreviewView(report: SampleDataProvider.shared.sampleIncidentReports[2])
}
