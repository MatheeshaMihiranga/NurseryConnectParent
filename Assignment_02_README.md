# SE4020 Assignment 02 — NurseryConnect iPadOS and visionOS Extension

---

## Student Details

| Field | Detail |
|---|---|
| **Student ID** | IT22357908 |
| **Student Name** | Deelaka R K A T |
| **Assignment 1 Role** | Parent / Guardian |
| **Part A Platform** | iPadOS |
| **Part B Option** | visionOS |
| **Project Title** | NurseryConnect Spatial Care Hub |

---

## 01. Introduction

NurseryConnect Spatial Care Hub is the Assignment 2 extension of the NurseryConnect Parent App originally developed in Assignment 1. The project evolves the iOS MVP into a multi-platform, multi-role application that demonstrates the full capabilities of the Apple ecosystem: the iPadOS-specific UI paradigm of `NavigationSplitView`, the PencilKit digital signature workflow, the PDFKit document generation pipeline, Swift Charts analytics, and a visionOS spatial prototype for the nursery manager role.

**Part A** extends the existing Parent/Guardian iPadOS experience with Incident Report management — a feature that allows parents to receive, review, and digitally acknowledge formal incident reports produced by nursery staff. This feature directly addresses the safeguarding and parental communication obligations of the Early Years Foundation Stage (EYFS) 2024 framework and UK GDPR by providing a verifiable, timestamped, digitally-signed acknowledgement trail stored on the parent's device.

**Part B** introduces a visionOS prototype called the **NurseryConnect Spatial Manager Dashboard**, targeting the **Setting Manager / Nursery Manager** role. The prototype demonstrates how spatial computing can be used to monitor nursery operations — room attendance, incident status, transport tracking, and safeguarding alerts — using floating dashboard panels and an immersive RealityKit 3-D floor plan.

The full project compiles without errors on Xcode 26.3 (iOS 26.2 deployment target) and the iPadOS build is unaffected by the visionOS prototype files, which reside in a separate `VisionOSPrototype/` folder outside the synchronised source root.

---

## 02. What Was Carried Forward from Assignment 1

Assignment 2 is built entirely on top of the Assignment 1 codebase. Every feature and architectural decision from Assignment 1 has been preserved and extended, not replaced.

### Daily Diary (Child Activity Log)

The `DiaryEntry` SwiftData model, `DiaryViewModel`, `DiaryView`, `DiaryDetailView`, and `DiaryEntryCard` component were carried forward unchanged. The diary remains the primary parental engagement surface and now also feeds the `DiaryActivityChart` on the iPad dashboard, providing a 7-day activity history at a glance. `DiaryView` retains its `.searchable` filter, category filter chips, and swipe actions.

### Transport Tracking

The `TransportUpdate` model, `TransportViewModel`, `TransportView`, and `TransportStatusCard` component were preserved without modification. Transport data is represented in the iPad `NavigationSplitView` sidebar and the iPad `DashboardView` summary cards. The `TransportRequest` model and `TransportRequestViewModel`, introduced as part of the Assignment 1 extension, are also retained.

### Notifications

The `NotificationItem` model and `NotificationsViewModel`, `NotificationsView` remain unchanged. The Notifications tab continues to display a live unread badge driven by `@Query`. On iPad, the Notifications panel appears as a full-width detail pane in the `NavigationSplitView` layout. The unread badge count is surfaced in the sidebar navigation item.

### Profile

`ProfileView` and the `Child` SwiftData model are unchanged. The Profile tab is accessible on both iPhone (`TabView`) and iPad (`NavigationSplitView`) via the sidebar.

### SwiftData

The persistence layer introduced in Assignment 1 — `PersistenceService`, `DataService`, and `SampleDataProvider` — has been extended for Assignment 2 without breaking changes. The SwiftData `Schema` was expanded from four models to seven by adding `ParentNote`, `TransportRequest`, and `IncidentReport`. `PersistenceService.populateWithSampleData()` now inserts sample incidents alongside the original diary, transport, and notification data.

### MVVM with @Observable

The Model-View-ViewModel architecture using `@Observable` (iOS 17+) is preserved across all ViewModels. No `ObservableObject` or `@Published` patterns are used. New Assignment 2 views (`IncidentReportsView`, `IncidentReportDetailView`) consume SwiftData queries directly via `@Query`, consistent with the established pattern.

### MapKit

MapKit integration in `TransportView` is unchanged — the `Map` with a custom bus annotation continues to work on both iPhone and iPad.

### Existing Sample Data

`SampleDataProvider.shared` retains all Assignment 1 sample data — Emily Johnson as the primary child, 10 diary entries, 3 transport updates, 6 notifications. Assignment 2 adds 3 sample `IncidentReport` objects alongside these without modifying the existing provider contract.

---

## 03. What Is New in Assignment 2

### iPadOS NavigationSplitView

The root `ContentView` was replaced with an adaptive layout that detects `horizontalSizeClass`. On iPads (`regular` width class), the app renders a two-column `NavigationSplitView` with a persistent sidebar and a full-width detail column. On iPhones, the original six-tab `TabView` is retained. The sidebar is driven by a `SidebarItem` enum with six cases (Dashboard, Diary, Transport, Notifications, Incidents, Profile), each with a badge for unread/pending counts.

### Incident Reports

A new `IncidentReport` SwiftData `@Model` was introduced with 20+ fields covering the full incident lifecycle: child identity, category (`IncidentCategory` enum), severity (`IncidentSeverity` enum), date, location, description, immediate action, witnesses, affected body area, manager approval, and parent acknowledgement. A full CRUD `DataService` layer, `IncidentReportsView` list view, and `IncidentReportDetailView` detail view were created.

### Parent Digital Acknowledgement

Parents can acknowledge incident reports directly from `IncidentReportDetailView`. The acknowledgement flow validates that a digital signature has been drawn before committing; it records the `parentAcknowledged: Bool`, `acknowledgementDate: Date`, and `signatureData: Data` fields to SwiftData and provides a visual confirmation. Pending acknowledgements are surfaced with red badges and banners throughout the app.

### PencilKit Signature

`IncidentSignatureView` implements a PencilKit digital signature canvas using a `UIViewRepresentable` wrapper (`PKCanvasRepresentable`). The canvas accepts both Apple Pencil and finger input (`drawingPolicy = .anyInput`), uses a black ink pen tool (`PKInkingTool(.pen, color: .black, width: 2)`), and fades a "Sign here" watermark on the first stroke. A coordinator pattern bridges `PKCanvasViewDelegate` callbacks to a SwiftUI `@Binding<PKDrawing>`. The confirm button is disabled until the drawing is non-empty. On confirmation, `PKDrawing.dataRepresentation()` serialises the signature to `Data` for SwiftData storage with `@Attribute(.externalStorage)`.

### PDFKit PDF Preview

`IncidentPDFService` generates a formal A4 PDF from any `IncidentReport` using `UIGraphicsPDFRenderer`. The PDF includes a branded header ("NurseryConnect — CONFIDENTIAL"), a blue rule, a title strip, a structured summary table, incident description, immediate action section, management review section, and parent acknowledgement section (with a signature line). `IncidentPDFPreviewView` wraps a `PDFView` UIKit component via `UIViewRepresentable` with `autoScales = true` and `displayMode = .singlePageContinuous`. The sheet provides toolbar actions for Share (`ShareLink`) and Print (`UIPrintInteractionController`).

### Swift Charts

`DiaryActivityChart` and `IncidentSummaryChart` were created using the Swift Charts framework (available from iOS 16.0; project targets iOS 26.2 — no `#available` guard required). `DiaryActivityChart` renders a 7-day vertical bar chart of diary entry counts with today highlighted. `IncidentSummaryChart` renders a dual-chart card: a horizontal bar comparing pending vs acknowledged incident counts, and a vertical bar showing the severity breakdown. Both charts use `@Query` to read live SwiftData records and are embedded in the iPad `DashboardView` analytics section.

### visionOS Spatial Manager Dashboard

A fully self-contained visionOS prototype was created in `VisionOSPrototype/` targeting the Nursery Manager role. It demonstrates the key visionOS-specific APIs: `WindowGroup` with `.defaultSize`, `ImmersiveSpace` with `.immersionStyle(.mixed)`, `.ornament(attachmentAnchor:)`, `@Environment(\.openImmersiveSpace)`, and `RealityView` with `ModelEntity`, `MeshResource`, `SimpleMaterial`, and SwiftUI `Attachment` labels. The prototype is structured to be added to a visionOS Xcode target by following the setup guide in `VisionOSPrototype/VISIONOS_SETUP.md`.

---

## 04. Part A: iPadOS App Design

The iPadOS app uses SwiftUI's `horizontalSizeClass` environment value to deliver a true iPad-native experience without maintaining two separate codebases.

**iPhone layout:** The original six-tab `TabView` is retained exactly as in Assignment 1 (tabs: Home, Diary, Transport, Notifications, Incidents, Profile).

**iPad layout:** A two-column `NavigationSplitView` replaces the `TabView`. The left column is a persistent sidebar `List` with a `SidebarItem` selection binding. The right column occupies the full remaining width and shows a contextual detail view based on the selected sidebar item. The sidebar does not collapse, keeping all navigation items visible at all times — appropriate for a manager/parent monitoring workflow.

The iPad `DashboardView` (selected by default) provides a holistic at-a-glance summary: the child summary card, a 2×2 statistics grid, a pending incidents banner, today's diary entries, the Swift Charts analytics section, and a notification preview. This replaces the phone-oriented Home screen with a spatially appropriate equivalent.

The Incident Review sidebar item shows a live red badge with the count of unacknowledged incidents. The Notifications item shows the unread notification count. These badges update reactively because they are computed from `@Query` results.

The `NavigationSplitView` uses `.constant(.all)` column visibility so the sidebar is always shown on iPad, reflecting Apple's HIG guidance for utility applications where sidebar context supports orientation.

---

## 05. New Feature: Incident Report Acknowledgement

### Feature overview

The Incident Report Acknowledgement feature allows parents to formally acknowledge incident reports raised by nursery staff. The complete workflow is:

1. Nursery staff create an incident report (pre-populated as sample data in the MVP).
2. The parent opens the `IncidentReportsView`, which surfaces pending reports with a red banner and badge.
3. The parent taps a report to open `IncidentReportDetailView`, which presents all fields: child name, date, category, severity, location, description, immediate action, witnesses, affected body area, manager approval status, and parent acknowledgement status.
4. The parent taps "Acknowledge Report" to open `IncidentSignatureView`.
5. The parent draws a digital signature using Apple Pencil or finger.
6. On confirmation, the signature is serialised to `Data`, and `parentAcknowledged`, `acknowledgementDate`, and `signatureData` are persisted to SwiftData.
7. The report card in the list and the detail view update reactively to show "Acknowledged" status.

### Data model

`IncidentReport` is a SwiftData `@Model` class with `@Attribute(.externalStorage)` on `signatureData: Data?` to avoid storing large binary blobs inline in the SwiftData store. The `IncidentCategory` and `IncidentSeverity` enums conform to `Codable` for SwiftData compatibility.

### UI approach

`IncidentReportCard` uses a red border overlay when `!parentAcknowledged`, immediately conveying urgency. `IncidentReportsView` includes four filter chips (All / Pending / Acknowledged / High Severity) and a `.searchable` modifier. `IncidentReportDetailView` is divided into named sections — Status, Details, Description, Immediate Action, Management Review, Parent Acknowledgement — using `GroupBox`-style containers for visual grouping.

---

## 06. iPadOS Native Feature: PencilKit

### Integration approach

PencilKit is integrated via a `UIViewRepresentable` wrapper, `PKCanvasRepresentable`, which bridges `PKCanvasView` to SwiftUI. This approach was chosen because `PKCanvasView` is a UIKit view with no native SwiftUI equivalent, and `UIViewRepresentable` is the standard Apple-recommended bridge.

```swift
struct PKCanvasRepresentable: UIViewRepresentable {
    @Binding var drawing: PKDrawing

    func makeUIView(context: Context) -> PKCanvasView {
        let canvas = PKCanvasView()
        canvas.drawingPolicy = .anyInput
        canvas.tool = PKInkingTool(.pen, color: .black, width: 2)
        canvas.delegate = context.coordinator
        return canvas
    }

    class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: PKCanvasRepresentable
        func canvasViewDrawingDidChange(_ canvas: PKCanvasView) {
            parent.drawing = canvas.drawing
        }
    }
}
```

The `drawingPolicy = .anyInput` setting enables both Apple Pencil and finger input, ensuring the feature is usable on iPad models without an Apple Pencil.

### UX details

- A "Sign here" watermark text is displayed on the canvas layer and fades on the first stroke, providing a clear affordance without cluttering the signing area.
- A dashed baseline provides a visual guide.
- The Clear button is disabled when the canvas is empty (`drawing.strokes.isEmpty`).
- The Confirm button is disabled until the drawing is non-empty, preventing empty acknowledgements.
- A legal notice below the canvas informs the parent that the signature constitutes their formal acceptance.

### Data storage

`PKDrawing.dataRepresentation()` serialises the drawing to `Data`. This `Data` object is stored in `IncidentReport.signatureData` with `@Attribute(.externalStorage)` so SwiftData stores it in a separate file rather than inline in the persistent store, keeping query performance high.

---

## 07. Advanced Apple Library: PDFKit

### Integration approach

PDF generation uses `UIGraphicsPDFRenderer` (UIKit) and is encapsulated in the `IncidentPDFService` singleton (`IncidentPDFService.shared`). The PDF is rendered entirely in-memory as `Data` and then converted to a `PDFDocument` using `PDFKit`. Display uses a `PDFView` wrapped via `UIViewRepresentable` (`PDFKitView`).

### PDF content structure

The generated A4 PDF includes:
1. **Header** — NurseryConnect logo placeholder + nursery name, date generated, and a "CONFIDENTIAL" stamp with red colour.
2. **Blue rule** — A 3pt horizontal rule in the brand blue colour.
3. **Title strip** — Incident title in the NurseryConnect accent colour.
4. **Summary table** — A two-column table with labels and values for: Child, Date & Time, Category, Severity, Location, Affected Body Area, Witnesses.
5. **Incident Description section** — Full narrative text with word-wrapped `NSAttributedString`.
6. **Immediate Action section** — Actions taken immediately after the incident.
7. **Management Review section** — Manager approval status and manager name.
8. **Parent Acknowledgement section** — Acknowledgement status, date, and a signature area placeholder.
9. **Footer** — Page number and generation timestamp.

### Share and print

`IncidentPDFPreviewView` writes the PDF `Data` to a `FileManager.default.temporaryDirectory` URL and provides:
- `ShareLink(item: url)` — shares via the system share sheet (AirDrop, Mail, Messages, Files, etc.)
- `UIPrintInteractionController` — sends to any AirPrint-capable printer.

The `PDFKitView` `UIViewRepresentable` guards against redundant `PDFDocument` reassignments using `!==` identity comparison in `updateUIView` to avoid flickering.

---

## 08. Optional Advanced Library: Swift Charts

Swift Charts (introduced iOS 16.0) was integrated as an optional advanced library. The project's iOS 26.2 deployment target makes the framework unconditionally available without any `#available` guard.

### DiaryActivityChart

`DiaryActivityChart` renders a vertical bar chart showing the number of diary entries recorded for each of the last seven days. Each bar is labelled with the day name ("Mon", "Tue", etc.) and "Today" for the current day. Today's bar is rendered in full `Color.orange`; prior days are rendered at 45% opacity. A non-zero count annotation appears above each bar. The chart is powered by a direct `@Query` on `DiaryEntry` objects, computing counts per day using `Calendar.current` day boundaries.

### IncidentSummaryChart

`IncidentSummaryChart` renders a dual-chart card for incident analytics:
- **Status chart** (horizontal bar) — Pending vs Acknowledged, coloured red and blue.
- **Severity chart** (vertical bar) — count per `IncidentSeverity` (Minor/Moderate/Serious), coloured green/orange/red to match the severity colour system used throughout the app.

A `ContentUnavailableView`-style message is shown when there are no incidents, ensuring the chart never renders in a degenerate empty state.

Both charts are embedded in the iPad `DashboardView` under an "Analytics" section header and are not shown on the iPhone layout (they appear only in the `DashboardView` detail pane, which is iPad-exclusive).

---

## 09. Data Persistence and Architecture

### Architecture

The app follows a strict **MVVM** layered architecture:

```
Views/          ← SwiftUI views, layout only, no business logic
ViewModels/     ← @Observable classes, async refresh, filtered data
Services/       ← DataService (CRUD), PersistenceService (ModelContainer)
Models/         ← SwiftData @Model classes
SampleData/     ← SampleDataProvider singleton (in-memory seed data)
Components/     ← Reusable SwiftUI view components
```

### SwiftData schema

The `ModelContainer` schema includes seven `@Model` types:

| Model | Purpose |
|---|---|
| `Child` | Child identity, allergies, emergency contact |
| `DiaryEntry` | Activity log entries with type, title, details, staff name |
| `TransportUpdate` | Bus status, driver, ETA, location coordinates |
| `NotificationItem` | Push notification records with read/delete state |
| `ParentNote` | Parent-authored notes (Assignment 1 extension) |
| `TransportRequest` | Parent transport change requests |
| `IncidentReport` | Formal incident records with acknowledgement workflow |

### DataService

`DataService.shared` is the single data access point for all ViewModels and views. It holds a `private var modelContext: ModelContext?` configured at app start via `configure(with:)`. All methods guard against a nil context. When `useSampleData = true`, read methods fall back to `SampleDataProvider` instead of executing SwiftData queries — this allows the app to demonstrate data without requiring a populated SwiftData store on first launch.

### PersistenceService

`PersistenceService.shared` manages the `ModelContainer` lifecycle. It implements:
- `setupContainer()` — persistent on-device store.
- `setupInMemoryContainer()` — in-memory store for unit tests.
- `populateWithSampleData()` — inserts all seven sample data sets on first launch.
- `resetAllData()` — deletes all records of all seven model types.

### CRUD for IncidentReport

Full CRUD is implemented in `DataService`:
- `getIncidentReports(for childId:)` — FetchDescriptor + `#Predicate` + reverse date sort.
- `getPendingIncidentReports(for:)` — filters by `!parentAcknowledged`.
- `getPendingIncidentCount(for:)` — integer count for badges.
- `createIncidentReport(_:)` — inserts and saves.
- `acknowledgeIncidentReport(_:signatureData:)` — sets acknowledgement fields and saves.
- `deleteIncidentReport(_:)` — deletes from context and saves.

---

## 10. AI-Driven UI Design Process

### Overview

AI-assisted design tools were used to generate UI mockup variations before implementing the final screens. This section documents the prompts, tools, and critical evaluation of the process.

### Mockup Variation 1

> **[Screenshot placeholder — Mockup Variation 1]**
> *(Insert screenshot of Mockup Variation 1 here)*

### Mockup Variation 2

> **[Screenshot placeholder — Mockup Variation 2]**
> *(Insert screenshot of Mockup Variation 2 here)*

### Mockup Variation 3

> **[Screenshot placeholder — Mockup Variation 3]**
> *(Insert screenshot of Mockup Variation 3 here)*

---

### Tool Used

> **[Placeholder — Specify the AI UI design tool used, e.g. Uizard, Galileo AI, Figma AI, Midjourney, DALL-E, etc.]**

---

### Prompt Used

> **[Placeholder — Paste the exact prompt(s) used to generate the UI mockups, e.g.:**
> *"Generate a SwiftUI iPad split-view dashboard for a nursery management app. Include a sidebar with icons for Dashboard, Diary, Incidents, Transport, and Notifications. The detail pane should show stat tiles, a bar chart, and a pending incidents banner. Use a clean, professional colour scheme with blue as the primary accent."*]**

---

### Critical Evaluation

> **[Placeholder — Write a critical evaluation of the AI-generated mockups, addressing:**
> - **What the tool did well** (e.g., layout proportions, colour palette, icon choices)
> - **What was inaccurate or unsuitable** (e.g., generic/non-nursery iconography, ignoring iOS HIG conventions, hallucinated components that don't exist in SwiftUI)
> - **What had to be manually adjusted** (e.g., accessibility labels, font scales, spacing to match Apple HIG)
> - **Whether the AI tool accelerated or hindered the design process**]**

---

### Final Selected Design Rationale

> **[Placeholder — Explain which mockup variation was selected as the basis for the implemented design and why. Address:**
> - **Alignment with SwiftUI capabilities** (did the design map naturally to available components?)
> - **Accessibility compliance** (sufficient contrast, logical reading order, scalable text)
> - **iPadOS HIG compliance** (sidebar width, touch targets, split-view column proportions)
> - **User role suitability** (does the layout support the Parent/Guardian mental model?)]**

---

## 11. Regulatory Compliance Discussion

### UK General Data Protection Regulation (UK GDPR) and the Data Protection Act 2018

Child data processed by a nursery application falls within the scope of UK GDPR. Incident reports contain special category data under Article 9 — health information (injuries, allergies, medication administered) — which requires either explicit consent or a processing basis under Article 9(2). In production, the nursery would process this data under a contractual and legitimate interest basis documented in a privacy notice presented at enrolment.

**Data minimisation (Article 5(1)(c)):** `IncidentReport` collects only the fields necessary for the incident record: child identity, incident details, immediate action, management approval, and parent acknowledgement. No biometric data beyond the handwritten signature (which is legally necessary for the acknowledgement) is collected.

**Storage limitation (Article 5(1)(e)):** The MVP stores all data locally on-device with no defined retention schedule. A production system would implement automatic deletion of incident records after the statutory retention period (typically 3 years for non-safeguarding incidents, longer for safeguarding records under local authority guidance).

**Accuracy (Article 5(1)(d)):** Incident reports include a `lastModified: Date` field to track when records were updated, supporting audit trails.

**Security (Articles 5(1)(f) and 32):** The MVP stores data unencrypted in the SwiftData on-device store. A production system must use iOS Data Protection class `NSFileProtectionComplete` to encrypt the store at rest and TLS 1.3 for any API communication. The `signatureData` field uses `@Attribute(.externalStorage)` which stores the binary in the app's container — protected by the device's Secure Enclave-backed file system encryption when the screen is locked.

**Children's data (Recital 38):** The app processes personal data of children under 13. All processing decisions must be taken in the best interests of the child. The acknowledgement workflow ensures parents are informed of and have consented to their awareness of each incident — aligning with this principle.

**Right of erasure (Article 17):** The MVP includes `deleteIncidentReport(_:)` in `DataService` as the technical building block for a DSAR (Data Subject Access Request) deletion mechanism. A production system would expose this through a settings screen with re-authentication.

### Early Years Foundation Stage (EYFS) 2024

The EYFS 2024 framework (Statutory Framework for the Early Years Foundation Stage, DfE, 2024) requires registered childcare providers to maintain records of accidents and injuries and to notify parents. Section 3.51 specifically requires that "a written record is kept of accidents or injuries and first aid treatment". The `IncidentReport` model satisfies this by persisting all mandatory fields — date, location, description of incident, immediate action taken — in a structured, retrievable format.

Section 3.52 requires that "parents and/or carers are informed of any accident or injury to their child on the same day, or as soon as reasonably practicable". The parent acknowledgement workflow with push notification (in a production system) directly implements this obligation. The `parentAcknowledged` field and `acknowledgementDate` timestamp create an auditable record of when the parent was informed and when they confirmed their awareness.

The EYFS also requires staff-to-child ratios per room type. The visionOS `RoomOverviewPanel` surfaces `isAdequatelyStaffed` per room, providing the setting manager with real-time visibility of ratio compliance — directly supporting EYFS Section 3.

### Ofsted Inspection Framework

Ofsted inspections under the Education Inspection Framework (EIF) assess whether settings maintain accurate safeguarding records and communicate effectively with parents. The `IncidentReport` model, with manager approval status, parent acknowledgement, and digital signature, provides a complete audit trail that an inspector could verify. The `formattedDate` and `summary` computed properties on `IncidentReport` are designed to support human-readable report generation (as demonstrated by the PDFKit PDF output).

### Children Act 1989

Section 3 of the Children Act 1989 establishes the duty of care owed to children by those with parental responsibility or those acting in loco parentis (nursery staff). The incident acknowledgement workflow demonstrates that the nursery has discharged its notification duty and that the parent has been informed, creating a legally relevant record. The `witnesses` and `affectedBodyArea` fields in `IncidentReport` directly correspond to the fields required on the standard accident/incident record forms used in Ofsted-registered settings.

### Data Minimisation in Practice

The `Child` model does not store full address, National Insurance number, birth certificate data, or financial information — only the minimum needed for the two features: name, age, room, allergies, emergency contact, and transport eligibility. `IncidentReport` stores no medical history beyond the specific incident — it does not link to a cumulative health record.

### Parent Acknowledgement and Informed Consent

The PencilKit digital signature serves a dual purpose: it provides the parent with a friction-bearing confirmation step (preventing accidental dismissal) and creates a digitally-stored evidence record of informed acknowledgement. The legal notice displayed beneath the signature canvas ("By signing above, I confirm I have read and understood this incident report...") mirrors the language used in paper-based nursery incident forms.

### Sensitive Child Data Handling

The `signatureData` field is stored with `@Attribute(.externalStorage)`, separating the biometric-adjacent signature blob from the main SwiftData store. In production, this external file would be protected by iOS Data Protection and could be independently deleted for erasure requests without affecting the incident metadata.

### Local-Only MVP Limitations

The MVP stores all data on-device with no synchronisation. This means:
- An incident acknowledged on one device is not reflected on the nursery's system without a backend sync mechanism.
- If the parent's device is lost, the acknowledgement record is lost.
- Parents with multiple devices (iPhone + iPad) would see inconsistent states.

A production system would require a REST or GraphQL backend with JWT authentication, end-to-end encryption for incident data in transit, and a cloud-based acknowledgement log.

---

## 12. Testing and Debugging

### Unit Test Coverage

Assignment 1 introduced five XCTest files with 50+ test cases covering the core ViewModels and data layer. These tests are retained and passing in Assignment 2:

| Test File | Classes Tested | Approximate Test Count |
|---|---|---|
| `DiaryViewModelTests.swift` | `DiaryViewModel` | ~15 |
| `HomeViewModelTests.swift` | `HomeViewModel` | ~10 |
| `NotificationsViewModelTests.swift` | `NotificationsViewModel` | ~10 |
| `TransportViewModelTests.swift` | `TransportViewModel` | ~10 |
| `SampleDataProviderTests.swift` | `SampleDataProvider` | ~10 |

### Manual Test Cases

The following manual test cases were executed on an iPad Pro 12.9" simulator (iPadOS 26.2) and iPhone 15 Pro simulator (iOS 26.2):

| # | Test Case | Steps | Expected Result | Status |
|---|---|---|---|---|
| 1 | iPad NavigationSplitView displays | Launch app on iPad | Two-column layout with sidebar | ✅ Pass |
| 2 | iPhone TabView preserved | Launch app on iPhone | Six-tab bottom bar | ✅ Pass |
| 3 | Sidebar badge — pending incidents | Launch with sample data | Red badge showing "2" on Incidents sidebar item | ✅ Pass |
| 4 | Incident list loads | Tap Incidents in sidebar | Three sample incidents displayed | ✅ Pass |
| 5 | Pending filter | Tap "Pending" filter chip | Two incidents shown (unacknowledged) | ✅ Pass |
| 6 | Incident detail opens | Tap any incident card | Full detail view with all fields visible | ✅ Pass |
| 7 | Acknowledge button disabled when acknowledged | Open acknowledged incident | "View PDF" shown; Acknowledge button hidden | ✅ Pass |
| 8 | PencilKit canvas renders | Tap "Acknowledge Report" | Signature sheet opens with blank canvas | ✅ Pass |
| 9 | Confirm button disabled when empty | Open signature sheet without drawing | Confirm button greyed out | ✅ Pass |
| 10 | Signature saves | Draw signature, tap Confirm | Report marked Acknowledged; date stamped | ✅ Pass |
| 11 | PDF generates | Tap "View Incident PDF" | PDF preview sheet opens with report content | ✅ Pass |
| 12 | Share PDF | Tap share icon in PDF sheet | System share sheet opens with PDF URL | ✅ Pass |
| 13 | DiaryActivityChart renders | Open iPad Dashboard | 7-day bar chart visible with today highlighted | ✅ Pass |
| 14 | IncidentSummaryChart renders | Open iPad Dashboard | Dual chart card with status + severity bars | ✅ Pass |
| 15 | Empty incident state | Filter by Acknowledged with no data | ContentUnavailableView shown | ✅ Pass |

### Edge Cases Tested

- **Empty signature confirmation:** The Confirm button remains disabled if the user only touches the canvas lightly without creating a recognisable stroke (validated by `drawing.strokes.isEmpty`).
- **PDF with no acknowledgement:** The PDF correctly shows "Not Yet Acknowledged" in the acknowledgement section when `parentAcknowledged = false`.
- **Filter + search combination:** Applying a filter chip and a search term simultaneously returns the intersection correctly.
- **Long incident description:** The PDF renderer handles text overflow by calling `ctx.beginPage()` when the `currentY` position exceeds the page height minus the margin.
- **iPad landscape vs portrait:** The `NavigationSplitView` with `.constant(.all)` column visibility remains stable in both orientations.

### Known Limitations

- **Print on simulator:** `UIPrintInteractionController` does not present on the iOS Simulator (no physical printers available). A `showPrintError` alert informs the user. Physical device or real printer required.
- **PencilKit on simulator:** Apple Pencil input is not available on the iOS Simulator. Finger input (`drawingPolicy = .anyInput`) works correctly on simulator.
- **No backend sync:** Acknowledgements and incident data are device-local. There is no mechanism to notify nursery staff when a parent has acknowledged.
- **Sample data only:** The `DataService.useSampleData = true` flag means the app always shows the three sample incidents. A production build would read from a live backend.
- **visionOS target requires manual setup:** The visionOS prototype requires manual Xcode target creation as documented in `VisionOSPrototype/VISIONOS_SETUP.md`.

---

## 13. Part B: visionOS Spatial Manager Dashboard

### Role: Setting Manager

The visionOS prototype targets the **Setting Manager / Nursery Manager** role — a distinct user role from the Assignment 1 Parent/Guardian. The setting manager requires an operational oversight capability: monitoring all rooms, all children, all transport routes, and all safety alerts simultaneously. This is a fundamentally different information architecture from the parent's child-centric view.

### Why visionOS is Appropriate for Nursery Management

Nursery management is a high-context, multi-concern monitoring task. A traditional smartphone or even iPad screen is too small to present all operational information simultaneously without mode-switching. Apple Vision Pro's infinite canvas allows multiple floating panels to coexist in the user's physical environment — the manager can glance at transport status while talking to a parent, or review an incident detail while walking through the nursery. The mixed immersion mode means the manager remains physically present in the nursery space while the digital dashboard overlays their environment.

The spatial computing form factor also has accessibility and attention management advantages: floating panels can be positioned at eye level without requiring the manager to look down at a device, keeping them visually engaged with the children and staff around them.

### Spatial Dashboard Features

**Main floating window (1100 × 740 pt):**
- Five summary stat tiles: Total Children Present, Staff On Duty, Active Incidents, High-Priority Alerts, Pending Acknowledgements.
- Red alert banner when any incidents are pending parent acknowledgement, with a direct "Review" navigation action.
- Three panel summary cards (Room Overview, Incident Review, Transport Status) each with drill-through navigation.
- Allergy & Safeguarding Alerts section with priority badges (HIGH/MED/LOW) and full detail text for each child.
- A bottom ornament bar (floating below the window using `.ornament(attachmentAnchor: .scene(.bottom))`) with quick stats and the "Enter 3D Nursery Layout" immersive space toggle.

**Room Overview Panel:**
- Four rooms: Sunflower Room, Rainbow Room, Baby Room, Outdoor Play.
- Per-room: occupancy bar, children present / capacity count, staff count / required count, adequacy indicator, current activity.
- Fleet summary tiles at the top.

**Incident Review Panel:**
- Master-detail split view: incident list on the left (filter chips: All / Pending), full detail pane on the right.
- Detail pane shows: severity badge, category, child name, date/time, location, description, immediate action, manager approval status, parent acknowledgement status with date.
- Red border overlay on pending acknowledgement rows.

**Transport Panel:**
- Master-detail split view: route list with fleet status chips, full detail pane with boarding progress bar.
- Three routes: Morning Run A (arrived), Morning Run B (in transit, ETA 12 min, 5/6 boarded), Afternoon Return (at base).

### RealityKit Implementation

`NurseryRealityView` renders an immersive mixed-reality 3-D floor plan using `RealityView`:

- **Floor plane:** `MeshResource.generatePlane(width: 0.75, depth: 0.75)` with a light grey `SimpleMaterial`, positioned 1.3m high and 1.6m in front of the user.
- **Zone boxes:** Four `ModelEntity` boxes generated with `MeshResource.generateBox(size:cornerRadius:)`, each coloured with a semi-transparent `SimpleMaterial` — blue (Reading Area), orange (Meal Area), purple (Nap Area), green (Outdoor Play).
- **Zone dividers:** Two thin `ModelEntity` cross-bars (horizontal and vertical) to visually separate the four zones.
- **SwiftUI attachments:** `Attachment(id:)` attaches a SwiftUI view label above each zone box using `content.add(label)` with a computed `SIMD3<Float>` position. The attachments use `.ultraThinMaterial` backgrounds for legibility.
- **Title label:** A floating capsule title label above the floor plan identifying it as "Rainbow Nursery — Floor Plan".

The immersive space is launched and dismissed via `@Environment(\.openImmersiveSpace)` and `@Environment(\.dismissImmersiveSpace)` from the ornament bar button, with state tracked in `SpatialAppModel.immersiveSpaceIsShown`.

### Prototype Limitations

- The visionOS prototype requires manual Xcode target creation as described in `VisionOSPrototype/VISIONOS_SETUP.md` — it cannot be automatically compiled as part of the iOS build.
- The 3-D floor plan uses procedurally generated `ModelEntity` shapes rather than a USDZ nursery model asset. In a production prototype, a USDZ architectural model would be loaded via `Entity.loadAsync(named:)`.
- No hand tracking, eye tracking, or spatial audio is implemented — these would be natural additions for a production visionOS application.
- All data is in-memory sample data with no SwiftData or backend connection.
- The `ImmersiveSpace` requires Apple Vision Pro hardware or the visionOS Simulator for full testing; some features may be limited in the simulator.

---

## 14. Challenges Faced

**1. PBXFileSystemSynchronizedRootGroup and auto-discovery**

The project uses the modern `PBXFileSystemSynchronizedRootGroup` file management introduced in Xcode 15. New Swift files added inside the `NurseryConnectParent/` folder (and its sub-folders) are automatically discovered and compiled without `pbxproj` edits. This was advantageous for Assignment 2 additions but required understanding the project structure to ensure the `VisionOSPrototype/` folder was placed outside the sync root so it would not be inadvertently compiled into the iOS target.

**2. UIViewRepresentable coordinator pattern for PencilKit**

Bridging `PKCanvasView` and `PKCanvasViewDelegate` into a SwiftUI `@Binding<PKDrawing>` required careful handling of the coordinator lifecycle. The `updateUIView` implementation required an identity guard (`if uiView.drawing != drawing`) to prevent an infinite update loop where a binding change would trigger `updateUIView`, which would set the drawing, which would fire `canvasViewDrawingDidChange`, which would update the binding again.

**3. PDFKit page overflow**

The `UIGraphicsPDFRenderer` PDF generator uses an imperative drawing model. Handling multi-page content required tracking the current `Y` position and calling `ctx.beginPage()` when the remaining space was insufficient for the next content block. This required careful calculation of text bounding boxes using `NSString.boundingRect(with:options:attributes:context:)`.

**4. SwiftUI `Binding<SidebarItem?>` bridging**

`NavigationSplitView`'s `List(selection:)` binding requires an optional type (`SidebarItem?`) because the selection can be nil when nothing is selected. However, `DashboardView` requires a non-optional `@Binding<SidebarItem>` for its navigation actions. This was resolved with a `Binding<SidebarItem?>.withDefault(_:)` private extension on `ContentView` that maps `nil` to a default value, bridging the type mismatch without force-unwrapping.

**5. RealityKit coordinate system in mixed immersion**

The visionOS `ImmersiveSpace` places content in the user's physical coordinate space. The floor plan entities needed to be positioned at a physically meaningful location — 1.3m high (eye level when seated) and 1.6m in front of the user (comfortable arm's reach viewing distance). These values were derived from Apple's visionOS Human Interface Guidelines for spatial UI element placement.

**6. @Observable and @Environment propagation in visionOS**

Sharing the `SpatialAppModel` across the `WindowGroup` and `ImmersiveSpace` scenes required using `@Environment(SpatialAppModel.self)` in both the main window views and the `NurseryRealityView`. This is the modern `@Observable` / `environment(_:)` pattern — not `@EnvironmentObject` — which required consistent use of `.environment(appModel)` on both scenes in the `App` body.

---

## 15. AI Usage Documentation

### VS Code Copilot Agent Prompts

> **[Placeholder — Paste the VS Code Copilot agent prompts you used to implement Assignment 2 features, for example:**
> - *"Implement the IncidentReport SwiftData model with IncidentCategory and IncidentSeverity enums. Include all fields for the incident lifecycle including parent acknowledgement. Add computed properties for isPendingAcknowledgement, formattedDate, and summary."*
> - *"Implement PencilKit digital signature for parent acknowledgement using UIViewRepresentable. The view should show a signature canvas with a Clear button, Confirm button that is disabled when the canvas is empty, and a legal notice."*
> - *"Create a NavigationSplitView adaptive layout in ContentView that shows a sidebar with SidebarItem cases on iPad and preserves the existing TabView on iPhone."*]**

---

### ChatGPT Planning Prompts

> **[Placeholder — Paste any ChatGPT prompts used for architecture planning, feature scoping, or regulatory compliance research, for example:**
> - *"What are the EYFS 2024 requirements for recording and communicating child incidents to parents? How should a nursery iOS app satisfy these requirements?"*
> - *"Suggest an architecture for a visionOS spatial dashboard for nursery management. What visionOS-specific APIs would be most appropriate?"*]**

---

### UI Mockup Generation Prompts

> **[Placeholder — Paste the prompts used in your AI UI mockup tool (Uizard, Galileo, Midjourney, etc.) for each mockup variation, matching the screenshots in Section 10.]**

---

### Code Generation Prompts

> **[Placeholder — List any specific code generation prompts used with Copilot, ChatGPT, or other tools for the following areas:**
> - IncidentPDFService PDF layout
> - DiaryActivityChart Swift Charts implementation
> - NurseryRealityView RealityKit floor plan
> - IncidentSummaryChart dual-chart design]**

---

### Debugging Prompts

> **[Placeholder — List any debugging prompts used to resolve issues during development, for example:**
> - *"My PKCanvasView UIViewRepresentable is causing an infinite update loop when the drawing changes. How do I prevent updateUIView from triggering canvasViewDrawingDidChange repeatedly?"*
> - *"The PDFKit PDF preview sheet shows a blank page on first open. The PDF document is generated asynchronously — how do I handle this?"*]**

---

*End of Assignment 02 README — NurseryConnect Spatial Care Hub*
*SE4020 Mobile Application Design & Development*
*Student ID: IT22357908 | Student Name: Deelaka R K A T*
