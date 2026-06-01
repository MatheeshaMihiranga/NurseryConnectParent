# visionOS Prototype — Setup Guide

**NurseryConnect Spatial Manager Dashboard**
Assignment 2 Part B · SE4020 Mobile Application Development
Student ID: IT22357908 | Student Name: Deelaka R K A T

---

## Folder structure

```
VisionOSPrototype/
├── NurseryConnectSpatialApp.swift   ← @main App entry + SpatialAppModel + SpatialPanel enum
├── SpatialSampleData.swift          ← All data models (rooms, incidents, transport, alerts)
│
├── Components/
│   └── SpatialComponents.swift      ← Shared cards, badges, stat tiles
│
└── Views/
    ├── SpatialDashboardView.swift   ← Main floating window (1100 × 740 pt)
    ├── RoomOverviewPanel.swift      ← Full room occupancy + staff panel
    ├── IncidentReviewPanel.swift    ← Incident list + detail split view
    ├── TransportPanel.swift         ← Transport routes + live status
    └── NurseryRealityView.swift     ← RealityKit 3-D immersive floor plan
```

All files are **self-contained** — no imports from the iPadOS `NurseryConnectParent` target.

---

## How to add a visionOS target in Xcode

### Step 1 — Open the project

Open `NurseryConnectParent.xcodeproj` in Xcode 15 or later (Xcode 16 recommended for
visionOS 1.x / 2.x SDK).

### Step 2 — Add a new visionOS target

1. Menu: **File → New → Target…**
2. Select the **visionOS** platform tab.
3. Choose **App** template → Next.
4. Fill in:
   - Product Name: `NurseryConnectSpatial`
   - Bundle Identifier: `com.nurseryconnect.NurseryConnectSpatial`
   - Team: your Apple Developer team
   - Minimum Deployment: **visionOS 1.0** (or 2.0 for newer SDK features)
5. Click **Finish**.

Xcode creates a `NurseryConnectSpatial/` folder with generated scaffold files.

### Step 3 — Remove generated scaffold files

Delete the auto-generated `ContentView.swift` and `NurseryConnectSpatialApp.swift`
Xcode creates — they will be replaced by the prototype files.

### Step 4 — Copy prototype files into the new target folder

Either drag into Finder, or use Xcode's Add Files dialog:

1. Select the `NurseryConnectSpatial` **group** in the Project Navigator.
2. **File → Add Files to "NurseryConnectParent"…**
3. Navigate to `VisionOSPrototype/` and add:

```
NurseryConnectSpatialApp.swift
SpatialSampleData.swift
Components/SpatialComponents.swift
Views/SpatialDashboardView.swift
Views/RoomOverviewPanel.swift
Views/IncidentReviewPanel.swift
Views/TransportPanel.swift
Views/NurseryRealityView.swift
```

4. In the **Add to targets** sheet: tick **NurseryConnectSpatial** only —
   do NOT tick `NurseryConnectParent`.

### Step 5 — Add required frameworks

In the `NurseryConnectSpatial` target → **Build Phases → Link Binary With Libraries**:

- `SwiftUI.framework` — usually linked automatically
- `RealityKit.framework` — required for `NurseryRealityView.swift`

### Step 6 — Build and run

Select the **NurseryConnectSpatial** scheme and the **visionOS Simulator** destination,
then press **⌘R**.

> **Note:** The RealityKit `ImmersiveSpace` requires a physical Apple Vision Pro
> or the visionOS Simulator (Xcode 15.2+). The 2-D dashboard window runs normally
> in the simulator.

---

## Runtime behaviour

| Feature | Where it runs |
|---------|--------------|
| Floating dashboard window | visionOS Simulator + Vision Pro |
| Room / Incident / Transport panels | visionOS Simulator + Vision Pro |
| Bottom ornament bar | visionOS Simulator + Vision Pro |
| 3-D immersive floor plan (RealityKit) | Vision Pro hardware preferred; simulator in limited form |

---

## Key visionOS APIs used

| API | File | Purpose |
|-----|------|---------|
| `@main App` + `WindowGroup` | `NurseryConnectSpatialApp.swift` | Floating window |
| `ImmersiveSpace` | `NurseryConnectSpatialApp.swift` | 3-D mixed immersion scene |
| `.immersionStyle(.mixed)` | `NurseryConnectSpatialApp.swift` | Pass-through AR overlay |
| `.ornament(attachmentAnchor:)` | `SpatialDashboardView.swift` | Floating bottom bar |
| `@Environment(\.openImmersiveSpace)` | `SpatialDashboardView.swift` | Launch 3-D space |
| `@Environment(\.dismissImmersiveSpace)` | `SpatialDashboardView.swift` | Close 3-D space |
| `RealityView { content, attachments in }` | `NurseryRealityView.swift` | 3-D scene |
| `ModelEntity(mesh:materials:)` | `NurseryRealityView.swift` | Coloured zone boxes |
| `Attachment(id:)` | `NurseryRealityView.swift` | SwiftUI labels on 3-D entities |

---

## Does this break the iPadOS app?

**No.** The `VisionOSPrototype/` folder is at the project root alongside
`NurseryConnectParent.xcodeproj`. It is **not** inside any
`PBXFileSystemSynchronizedRootGroup` registered to the iOS target, so Xcode
never auto-discovers or compiles these files as part of the iPadOS build.

---

## Demonstration checklist (for assessors)

- [x] Spatial dashboard window floats in AR space
- [x] Five summary stat tiles update from in-memory sample data
- [x] Red banner + Review button when incidents are pending acknowledgement
- [x] Room Overview Panel — 4 rooms, occupancy bars, staff adequacy check
- [x] Incident Review Panel — category, severity, manager approval, parent ACK status
- [x] Transport Panel — van status, ETA, driver, boarded/expected counts
- [x] Allergy & Safeguarding Alerts section with priority badges
- [x] "Enter 3D Nursery Layout" ornament button → launches ImmersiveSpace
- [x] 3-D floor plan with 4 colour-coded zones (Reading, Meal, Nap, Outdoor)
- [x] SwiftUI labels attached to each RealityKit zone entity
- [x] No login, no backend, no network calls — fully offline prototype
