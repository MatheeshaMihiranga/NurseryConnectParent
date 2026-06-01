//
//  IncidentPDFService.swift
//  NurseryConnectParent
//
//  Created on June 1, 2026
//
//  Uses UIGraphicsPDFRenderer (UIKit) to draw a formal A4 incident report
//  and returns the raw Data.  A PDFDocument (PDFKit) can then be constructed
//  from that Data for in-app preview or sharing.
//
//  PDFKit role:
//   - PDFDocument / PDFPage — object model for loading, navigating and
//     rendering the generated PDF (used in IncidentPDFPreviewView).
//   - UIPrintInteractionController integration — PDFKit-backed print jobs.
//
//  UIGraphicsPDFRenderer role (UIKit):
//   - Renders NSAttributedString, fills, strokes and bezier paths into
//     a PDF graphics context.  Each call to ctx.beginPage() starts a new
//     A4 leaf; all drawing helpers operate on the same context.

import UIKit
import PDFKit

// MARK: - IncidentPDFService

final class IncidentPDFService {

    static let shared = IncidentPDFService()
    private init() {}

    // MARK: - Page geometry (A4 @ 72 dpi)
    private let pageW:  CGFloat = 595.2
    private let pageH:  CGFloat = 841.8
    private let margin: CGFloat = 48
    private var bodyW:  CGFloat { pageW - margin * 2 }

    // Minimum Y before we must start a new page
    private var pageBottom: CGFloat { pageH - margin - 24 }

    // MARK: - Public API

    /// Generate a PDF and return raw Data.
    func generateData(for report: IncidentReport) -> Data {
        let pageRect = CGRect(x: 0, y: 0, width: pageW, height: pageH)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)

        return renderer.pdfData { ctx in
            ctx.beginPage()

            var y: CGFloat = margin

            // ── Header ────────────────────────────────────────────────
            y = drawHeader(at: y, pageRect: pageRect)
            y = drawBlueLine(at: y)
            y += 6

            // ── Report title strip ────────────────────────────────────
            y = drawTitleStrip(report.title, at: y)
            y += 10

            // ── Summary fields ────────────────────────────────────────
            y = drawSummaryTable(report: report, at: y, ctx: ctx, pageRect: pageRect)
            y += 14

            // ── Long-text sections ────────────────────────────────────
            let textSections: [(String, String)] = [
                ("DESCRIPTION",
                 report.incidentDescription),
                ("IMMEDIATE ACTION TAKEN",
                 report.immediateActionTaken.isEmpty
                    ? "No immediate action recorded."
                    : report.immediateActionTaken),
            ]
            for (title, body) in textSections {
                y = drawTextSection(title: title, body: body,
                                    at: y, ctx: ctx, pageRect: pageRect)
                y += 10
            }

            // ── Management review ─────────────────────────────────────
            y = drawManagementSection(report: report, at: y, ctx: ctx, pageRect: pageRect)
            y += 10

            // ── Parent acknowledgement ────────────────────────────────
            y = drawAcknowledgementSection(report: report, at: y, ctx: ctx, pageRect: pageRect)

            // ── Footer for the last (possibly only) page ──────────────
            drawFooter(pageRect: pageRect)
        }
    }

    /// Convenience wrapper — returns a PDFDocument ready for PDFView.
    func generateDocument(for report: IncidentReport) -> PDFDocument? {
        PDFDocument(data: generateData(for: report))
    }

    // MARK: - Header

    @discardableResult
    private func drawHeader(at y: CGFloat, pageRect: CGRect) -> CGFloat {
        // Left: app name + subtitle
        let appStr = attributed("NurseryConnect",
                                font: .systemFont(ofSize: 22, weight: .bold),
                                color: .systemBlue)
        let subStr = attributed("Parent Portal — Child Incident Report",
                                font: .systemFont(ofSize: 10),
                                color: .secondaryLabel)
        appStr.draw(at: CGPoint(x: margin, y: y))
        subStr.draw(at: CGPoint(x: margin, y: y + 27))

        // Right: document type + confidential
        let typeStr  = attributed("Incident Report",
                                  font: .systemFont(ofSize: 16, weight: .semibold),
                                  color: .label)
        let confStr  = attributed("CONFIDENTIAL",
                                  font: .systemFont(ofSize: 9, weight: .medium),
                                  color: .systemRed)
        let typeSize = typeStr.size()
        let confSize = confStr.size()
        typeStr.draw(at: CGPoint(x: pageRect.width - margin - typeSize.width, y: y))
        confStr.draw(at: CGPoint(x: pageRect.width - margin - confSize.width, y: y + 21))

        return y + 48
    }

    // MARK: - Blue separator line

    @discardableResult
    private func drawBlueLine(at y: CGFloat) -> CGFloat {
        guard let ctx = UIGraphicsGetCurrentContext() else { return y }
        ctx.saveGState()
        ctx.setStrokeColor(UIColor.systemBlue.cgColor)
        ctx.setLineWidth(1.8)
        ctx.move(to: CGPoint(x: margin,        y: y))
        ctx.addLine(to: CGPoint(x: pageW - margin, y: y))
        ctx.strokePath()
        ctx.restoreGState()
        return y + 10
    }

    // MARK: - Report title strip

    @discardableResult
    private func drawTitleStrip(_ title: String, at y: CGFloat) -> CGFloat {
        guard let ctx = UIGraphicsGetCurrentContext() else { return y }
        let stripRect = CGRect(x: margin - 6, y: y, width: bodyW + 12, height: 26)
        ctx.saveGState()
        ctx.setFillColor(UIColor.systemGray6.cgColor)
        UIBezierPath(roundedRect: stripRect, cornerRadius: 5).fill()
        ctx.restoreGState()
        let str = attributed("  \(title)",
                             font: .systemFont(ofSize: 12, weight: .semibold),
                             color: .label)
        str.draw(at: CGPoint(x: margin, y: y + 5))
        return y + 30
    }

    // MARK: - Summary table (label | value rows)

    @discardableResult
    private func drawSummaryTable(
        report:   IncidentReport,
        at startY: CGFloat,
        ctx:      UIGraphicsPDFRendererContext,
        pageRect: CGRect
    ) -> CGFloat {
        let rows: [(String, String)] = [
            ("CHILD",         report.childName),
            ("DATE & TIME",   report.formattedDate),
            ("CATEGORY",      report.category.rawValue),
            ("SEVERITY",      report.severity.rawValue),
            ("LOCATION",      report.location.isEmpty ? "Not recorded" : report.location),
            ("AFFECTED AREA", report.affectedBodyArea.isEmpty ? "Not recorded" : report.affectedBodyArea),
            ("WITNESSES",     report.witnesses.isEmpty ? "None recorded" : report.witnesses),
        ]

        let labelW: CGFloat = 100
        let valueX: CGFloat = margin + labelW + 10
        let valueW: CGFloat = bodyW - labelW - 10
        var y = startY

        for (label, value) in rows {
            let lStr = attributed(label,
                                  font: .systemFont(ofSize: 9.5, weight: .semibold),
                                  color: .secondaryLabel)
            let vStr = attributed(value,
                                  font: .systemFont(ofSize: 10.5),
                                  color: .label)
            let vHeight = vStr.boundingRect(
                with: CGSize(width: valueW, height: .greatestFiniteMagnitude),
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                context: nil
            ).height
            let rowH = max(vHeight, 13) + 5

            if y + rowH > pageBottom {
                drawFooter(pageRect: pageRect)
                ctx.beginPage()
                y = margin
            }

            lStr.draw(at: CGPoint(x: margin, y: y + 1))
            vStr.draw(in: CGRect(x: valueX, y: y, width: valueW, height: rowH + 4))
            y += rowH + 3
        }
        return y
    }

    // MARK: - Generic text section

    @discardableResult
    private func drawTextSection(
        title:    String,
        body:     String,
        at startY: CGFloat,
        ctx:      UIGraphicsPDFRendererContext,
        pageRect: CGRect
    ) -> CGFloat {
        var y = startY

        // Section title
        let tStr = attributed(title,
                              font: .systemFont(ofSize: 10.5, weight: .bold),
                              color: .systemBlue)
        if y + 30 > pageBottom {
            drawFooter(pageRect: pageRect)
            ctx.beginPage()
            y = margin
        }
        tStr.draw(at: CGPoint(x: margin, y: y))
        y += 15
        y = drawThinLine(at: y, color: .systemBlue.withAlphaComponent(0.35))
        y += 5

        // Body text
        let bStr = attributed(body, font: .systemFont(ofSize: 10.5), color: .label)
        let bH = bStr.boundingRect(
            with: CGSize(width: bodyW, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        ).height + 4

        if y + bH > pageBottom {
            drawFooter(pageRect: pageRect)
            ctx.beginPage()
            y = margin
        }
        bStr.draw(in: CGRect(x: margin, y: y, width: bodyW, height: bH))
        return y + bH
    }

    // MARK: - Management section

    @discardableResult
    private func drawManagementSection(
        report:   IncidentReport,
        at startY: CGFloat,
        ctx:      UIGraphicsPDFRendererContext,
        pageRect: CGRect
    ) -> CGFloat {
        var y = drawSectionTitle("MANAGEMENT REVIEW", at: startY, ctx: ctx, pageRect: pageRect)

        let rows: [(String, String)] = [
            ("MANAGER:", report.managerName.isEmpty ? "Not yet reviewed" : report.managerName),
            ("STATUS:",  report.managerApproved
                            ? "Countersigned and Approved ✓"
                            : "Awaiting Manager Countersignature"),
        ]
        let labelW: CGFloat = 70
        for (lbl, val) in rows {
            let lStr = attributed(lbl, font: .systemFont(ofSize: 10.5, weight: .semibold),
                                  color: .secondaryLabel)
            let vStr = attributed(val,  font: .systemFont(ofSize: 10.5),
                                  color: report.managerApproved ? UIColor.systemGreen : .label)
            if y + 14 > pageBottom {
                drawFooter(pageRect: pageRect)
                ctx.beginPage()
                y = margin
            }
            lStr.draw(at: CGPoint(x: margin, y: y))
            vStr.draw(at: CGPoint(x: margin + labelW, y: y))
            y += 15
        }
        return y
    }

    // MARK: - Acknowledgement section

    @discardableResult
    private func drawAcknowledgementSection(
        report:   IncidentReport,
        at startY: CGFloat,
        ctx:      UIGraphicsPDFRendererContext,
        pageRect: CGRect
    ) -> CGFloat {
        var y = drawSectionTitle("PARENT ACKNOWLEDGEMENT", at: startY, ctx: ctx, pageRect: pageRect)

        // Status badge text
        let statusText  = report.parentAcknowledged
            ? "Acknowledged by Parent ✓"
            : "Awaiting Parent Acknowledgement"
        let statusColor: UIColor = report.parentAcknowledged ? .systemGreen : .systemRed
        attributed(statusText,
                   font: .systemFont(ofSize: 11, weight: .semibold),
                   color: statusColor)
            .draw(at: CGPoint(x: margin, y: y))
        y += 18

        if report.parentAcknowledged, let ackDate = report.acknowledgementDate {
            let dateVal = ackDate.formatted(date: .long, time: .shortened)
            attributed("DATE:  \(dateVal)",
                       font: .systemFont(ofSize: 10.5),
                       color: .label)
                .draw(at: CGPoint(x: margin, y: y))
            y += 15
        }

        let sigText = report.signatureData != nil
            ? "SIGNATURE:  Digital signature captured and on file"
            : "SIGNATURE:  Pending parent signature"
        attributed(sigText, font: .systemFont(ofSize: 10.5), color: .label)
            .draw(at: CGPoint(x: margin, y: y))
        y += 22

        // Signature line
        if let ctx2 = UIGraphicsGetCurrentContext() {
            ctx2.saveGState()
            ctx2.setStrokeColor(UIColor.label.withAlphaComponent(0.5).cgColor)
            ctx2.setLineWidth(0.6)
            ctx2.move(to:    CGPoint(x: margin,       y: y))
            ctx2.addLine(to: CGPoint(x: margin + 200, y: y))
            ctx2.strokePath()
            ctx2.restoreGState()
        }
        attributed("Parent / Guardian Signature",
                   font: .systemFont(ofSize: 8),
                   color: .tertiaryLabel)
            .draw(at: CGPoint(x: margin, y: y + 3))
        return y + 18
    }

    // MARK: - Shared section-title + thin rule

    @discardableResult
    private func drawSectionTitle(
        _ title: String,
        at y:    CGFloat,
        ctx:     UIGraphicsPDFRendererContext,
        pageRect: CGRect
    ) -> CGFloat {
        var y = y
        if y + 30 > pageBottom {
            drawFooter(pageRect: pageRect)
            ctx.beginPage()
            y = margin
        }
        attributed(title, font: .systemFont(ofSize: 10.5, weight: .bold), color: .systemBlue)
            .draw(at: CGPoint(x: margin, y: y))
        y += 15
        return drawThinLine(at: y, color: .systemBlue.withAlphaComponent(0.35)) + 6
    }

    // MARK: - Thin horizontal rule

    @discardableResult
    private func drawThinLine(at y: CGFloat, color: UIColor) -> CGFloat {
        guard let ctx = UIGraphicsGetCurrentContext() else { return y }
        ctx.saveGState()
        ctx.setStrokeColor(color.cgColor)
        ctx.setLineWidth(0.5)
        ctx.move(to:    CGPoint(x: margin,        y: y))
        ctx.addLine(to: CGPoint(x: pageW - margin, y: y))
        ctx.strokePath()
        ctx.restoreGState()
        return y + 1
    }

    // MARK: - Footer (drawn at fixed position, called last on each page)

    private func drawFooter(pageRect: CGRect) {
        let footerY = pageRect.height - margin + 8
        let text = "Generated by NurseryConnect · \(Date().formatted(date: .abbreviated, time: .shortened))"
        let str = attributed(text, font: .systemFont(ofSize: 7.5), color: .tertiaryLabel)
        let sz  = str.size()
        str.draw(at: CGPoint(x: (pageRect.width - sz.width) / 2, y: footerY))
    }

    // MARK: - NSAttributedString factory

    private func attributed(
        _ string: String,
        font:     UIFont,
        color:    UIColor
    ) -> NSAttributedString {
        NSAttributedString(string: string, attributes: [
            .font:            font,
            .foregroundColor: color,
        ])
    }
}
