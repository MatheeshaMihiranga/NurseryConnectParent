//
//  IncidentReportDetailView.swift
//  NurseryConnectParent
//
//  Created on June 1, 2026
//

import SwiftUI

struct IncidentReportDetailView: View {
    let report: IncidentReport
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // Navigation destinations (placeholders for Part A implementation)
    @State private var showAcknowledgementSheet = false
    @State private var showPDFPreview = false
    @State private var showAcknowledgedConfirmation = false

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                // ── 1. Header card ───────────────────────────────────────
                headerCard

                // ── 2. Status row ────────────────────────────────────────
                statusRow

                // ── 3. Incident details section ──────────────────────────
                detailSection(
                    title: "Incident Details",
                    systemImage: "doc.text.fill"
                ) {
                    DetailRow(label: "Location", value: report.location,
                              icon: "mappin.circle.fill", color: .red)
                    DetailRow(label: "Affected Area", value: report.affectedBodyArea.isEmpty ? "Not recorded" : report.affectedBodyArea,
                              icon: "figure.stand", color: .indigo)
                    if !report.witnesses.isEmpty {
                        DetailRow(label: "Witnesses", value: report.witnesses,
                                  icon: "person.2.fill", color: .teal)
                    }
                }

                // ── 4. Description section ───────────────────────────────
                textSection(
                    title: "Description",
                    icon: "text.alignleft",
                    color: .blue,
                    text: report.incidentDescription
                )

                // ── 5. Immediate action section ──────────────────────────
                if !report.immediateActionTaken.isEmpty {
                    textSection(
                        title: "Immediate Action Taken",
                        icon: "bolt.heart.fill",
                        color: .green,
                        text: report.immediateActionTaken
                    )
                }

                // ── 6. Management section ────────────────────────────────
                managementSection

                // ── 7. Acknowledgement section ───────────────────────────
                acknowledgementSection

                // ── 8. Action buttons ────────────────────────────────────
                actionButtons
            }
            .padding(.horizontal)
            .padding(.vertical, 20)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Incident Report")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        showPDFPreview = true
                    } label: {
                        Label("View PDF Report", systemImage: "doc.richtext.fill")
                    }

                    Button(action: shareReport) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .accessibilityLabel("More options")
                }
            }
        }
        // ── PencilKit digital signature acknowledgement ─────────────────
        .sheet(isPresented: $showAcknowledgementSheet) {
            IncidentSignatureView(report: report) {
                showAcknowledgedConfirmation = true
            }
        }
        // ── PDFKit preview ───────────────────────────────────────
        .sheet(isPresented: $showPDFPreview) {
            IncidentPDFPreviewView(report: report)
        }
        .alert("Report Acknowledged", isPresented: $showAcknowledgedConfirmation) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("You have successfully acknowledged this incident report. A copy has been saved.")
        }
    }

    // MARK: - Header Card

    private var headerCard: some View {
        VStack(spacing: 16) {
            HStack(alignment: .top, spacing: 14) {
                // Category icon
                Image(systemName: report.category.icon)
                    .font(.system(size: 32))
                    .foregroundStyle(Color(report.category.color))
                    .frame(width: 60, height: 60)
                    .background(
                        Color(report.category.color).opacity(0.12),
                        in: RoundedRectangle(cornerRadius: 14)
                    )
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 6) {
                    Text(report.category.rawValue.uppercased())
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .tracking(0.5)

                    Text(report.title)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)
            }

            Divider()

            // Child + date meta
            HStack {
                metaItem(label: "Child", value: report.childName,
                         icon: "person.fill", color: .blue)
                Spacer()
                metaItem(label: "Date & Time", value: report.formattedDate,
                         icon: "calendar", color: .orange)
            }
        }
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
    }

    private func metaItem(label: String, value: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Label(label, systemImage: icon)
                .font(.caption)
                .foregroundStyle(color)

            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.primary)
        }
    }

    // MARK: - Status Row

    private var statusRow: some View {
        HStack(spacing: 12) {
            // Severity
            VStack(spacing: 6) {
                Image(systemName: report.severity.icon)
                    .font(.title3)
                    .foregroundStyle(Color(report.severity.color))
                Text(report.severity.rawValue)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(report.severity.color))
                Text("Severity")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color(report.severity.color).opacity(0.10),
                        in: RoundedRectangle(cornerRadius: 12))

            // Manager approval
            VStack(spacing: 6) {
                Image(systemName: report.managerApproved ? "checkmark.seal.fill" : "clock.fill")
                    .font(.title3)
                    .foregroundStyle(report.managerApproved ? .green : .orange)
                Text(report.managerApproved ? "Approved" : "Pending")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(report.managerApproved ? .green : .orange)
                Text("Manager")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background((report.managerApproved ? Color.green : Color.orange).opacity(0.10),
                        in: RoundedRectangle(cornerRadius: 12))

            // Parent acknowledgement
            VStack(spacing: 6) {
                Image(systemName: report.parentAcknowledged ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(report.parentAcknowledged ? .blue : .red)
                Text(report.parentAcknowledged ? "Signed" : "Required")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(report.parentAcknowledged ? .blue : .red)
                Text("Your Sign-off")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background((report.parentAcknowledged ? Color.blue : Color.red).opacity(0.10),
                        in: RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Detail Section helper

    private func detailSection<Content: View>(
        title: String,
        systemImage: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Label(title, systemImage: systemImage)
                .font(.headline)
                .foregroundStyle(.primary)

            content()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 6, y: 3)
    }

    // MARK: - Text Section helper

    private func textSection(title: String, icon: String, color: Color, text: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: icon)
                .font(.headline)
                .foregroundStyle(color)

            Text(text)
                .font(.body)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.05), in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(color.opacity(0.2), lineWidth: 1)
        )
    }

    // MARK: - Management Section

    private var managementSection: some View {
        detailSection(title: "Management Review", systemImage: "person.badge.shield.checkmark.fill") {
            DetailRow(
                label: "Reviewed By",
                value: report.managerName.isEmpty ? "Not yet reviewed" : report.managerName,
                icon: "person.fill.checkmark",
                color: .purple
            )
            DetailRow(
                label: "Approval Status",
                value: report.managerApproved ? "Countersigned and approved" : "Awaiting manager countersignature",
                icon: report.managerApproved ? "checkmark.seal.fill" : "clock.badge.fill",
                color: report.managerApproved ? .green : .orange
            )
        }
    }

    // MARK: - Acknowledgement Section

    private var acknowledgementSection: some View {
        detailSection(
            title: "Parent Acknowledgement",
            systemImage: "signature"
        ) {
            if report.parentAcknowledged {
                if let ackDate = report.acknowledgementDate {
                    DetailRow(
                        label: "Acknowledged On",
                        value: ackDate.formatted(date: .long, time: .shortened),
                        icon: "calendar.badge.checkmark",
                        color: .blue
                    )
                }
                if report.signatureData != nil {
                    DetailRow(
                        label: "Signature",
                        value: "Digital signature captured",
                        icon: "pencil.and.scribble",
                        color: .blue
                    )
                } else {
                    DetailRow(
                        label: "Signature",
                        value: "Acknowledged (no digital signature on record)",
                        icon: "checkmark.circle.fill",
                        color: .blue
                    )
                }
            } else {
                InfoBannerRow(
                    message: "This report requires your acknowledgement. Please review all details and sign below.",
                    color: .red
                )
            }
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: 12) {
            if !report.parentAcknowledged {
                Button {
                    showAcknowledgementSheet = true
                } label: {
                    Label("Acknowledge Report", systemImage: "signature")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(.blue.gradient, in: RoundedRectangle(cornerRadius: 14))
                        .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
                .accessibilityHint("Opens the signature screen to formally acknowledge this incident report")
            }

            Button {
                showPDFPreview = true
            } label: {
                Label("View PDF Report", systemImage: "doc.richtext.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(.secondarySystemBackground),
                                in: RoundedRectangle(cornerRadius: 14))
                    .foregroundStyle(.primary)
            }
            .buttonStyle(.plain)
            .accessibilityHint("Opens a PDF preview of this incident report")
        }
        .padding(.top, 4)
    }

    // MARK: - Private actions

    private func shareReport() {
        showPDFPreview = true
    }
}

// MARK: - Detail Row

struct DetailRow: View {
    let label: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(color)
                .frame(width: 20)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
    }
}

// MARK: - Info Banner Row

private struct InfoBannerRow: View {
    let message: String
    let color: Color

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "info.circle.fill")
                .foregroundStyle(color)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .background(color.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        IncidentReportDetailView(report: SampleDataProvider.shared.sampleIncidentReports[0])
    }
}
