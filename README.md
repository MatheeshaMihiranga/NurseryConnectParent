# SE4020 – Mobile Application Design & Development
## Assignment 01 — NurseryConnect iOS MVP

> **Submission Instructions:** Edit this file directly with your report. No separate documentation is required. Commit all your Swift/Xcode project files to this repository alongside this README.

---

## Student Details

| Field | Details |
|---|---|
| **Student ID** | IT22357908 |
| **Student Name** | Deelaka R K A T |
| **Chosen User Role** | Parent / Guardian |
| **Selected Feature 1** | Daily Diary (Child Activity Log) |
| **Selected Feature 2** | Transport Tracking |

---

## 01. Feature Selection & Role Justification

### Chosen User Role

**Parent / Guardian**

The Parent/Guardian role was selected because it represents the primary end-user of a consumer-facing nursery communication application. Parents are the audience most likely to benefit from a mobile-first experience, as they need real-time visibility into their child's daily life while they are away at work or engaged in other activities. Building from this perspective yields a cohesive, self-contained set of features that form a meaningful MVP without requiring backend systems, authentication flows, or staff-side workflows.

### Selected Features

**Feature 1: Daily Diary (Child Activity Log)**

The Daily Diary feature enables parents to view structured updates about their child's day, categorised by type: Meals, Naps, Activities, Mood, Milestones, and Incidents. Parents can filter entries by category, search free-text, and tap any entry to view full details.

**Feature 2: Transport Tracking**

The Transport Tracking feature shows parents the live status of their child's nursery bus, including boarding status, estimated arrival time, driver name, vehicle number, and a map view of the approximate current location.

### Justification

The Early Years Foundation Stage (EYFS) 2024 framework explicitly requires settings to share children's learning journeys with parents and promote parental engagement. The Daily Diary directly satisfies this by giving parents structured, categorised visibility of meals, activities, milestones, and incidents. It maps cleanly to a 4-week MVP: the data model, filter logic, and detail navigation are well-scoped without requiring a live backend.

Child safety during transport is a regulatory concern under the Children Act 1989 (Section 3 duty of care). Parents have an urgent need to know when their child boards and when to expect them home. This feature complements the Diary — together they cover the child's time inside the nursery and their journey to/from it. For a 4-week MVP, a status model, MapKit map component, and card-based display are achievable using representative sample data without live GPS infrastructure.

---

## 02. App Functionality

### Overview

NurseryConnect Parent App is a SwiftUI iOS application built for the Parent/Guardian role. It provides a tabbed interface with five sections: Home, Daily Diary, Transport Tracking, Notifications, and Profile. All data is stored locally using SwiftData (Apple's modern ORM). Sample data is inserted on first launch, and notification read/delete state persists across app restarts.

### Screen Descriptions

**Screen 1 — Home Screen**

The Home screen acts as a dashboard. It displays a child summary card (name, age, room, allergy warning), the current transport status, Quick Action buttons for navigating directly to key features, and a "Today's Updates" preview showing the most recent diary entries. A refresh button in the toolbar triggers an async data refresh.

<img src="Resources/screen01.jpeg" width="300">

**Screen 2 — Daily Diary**

The Diary screen displays all diary entries for the child in reverse-chronological order, grouped by date. A search bar supports full-text search. Scrollable filter chips allow filtering by entry type (All, Meal, Nap, Activity, Mood, Milestone, Incident). Tapping any entry opens a detail view with the full description, staff notes, and metadata.

<img src="Resources/screen02.jpeg" width="300">

**Screen 3 — Transport Tracking**

The Transport screen displays the child's current transport status with a coloured icon, last-update timestamp, boarding time, estimated arrival, current location, driver name, and vehicle number. A MapKit map below shows the approximate bus location with a custom annotation. A safety information section documents the nursery's transport protocols.

<img src="Resources/screen03.jpeg" width="300">

**Screen 4 — Notifications**

The Notifications screen lists all notifications in reverse-chronological order. Unread items are visually distinguished. A toolbar menu allows toggling between "All" and "Unread Only", and "Mark All as Read". Each row supports swipe-to-delete and swipe-to-mark-as-read. Read/delete state is persisted to SwiftData.

<img src="Resources/screen04.jpeg" width="300">

**Screen 5 — Profile**

The Profile screen displays the child's full details (name, age, room, allergies, emergency contact) and account settings.

### Navigation

Navigation uses two complementary SwiftUI patterns:
- **`TabView`** for top-level section switching across the five tabs.
- **`NavigationStack`** within each tab for push-based drill-down (e.g. Diary list → Diary entry detail).

The `selectedTab` binding is passed from `ContentView` down to `HomeView` so that the Quick Action buttons on the home screen correctly switch the outer `TabView`.

### Data Persistence

**SwiftData** (iOS 17+) is used for all persistence. The schema includes four `@Model` classes: `Child`, `DiaryEntry`, `TransportUpdate`, and `NotificationItem`. A `PersistenceService` singleton initialises the `ModelContainer` with a persistent on-device store and falls back to an in-memory container if setup fails. Sample data is inserted on first launch (guarded by a pre-check). Notification read/delete state is written back to SwiftData immediately via `@Environment(\.modelContext)` and `@Query` in `NotificationsView`, so changes survive app restarts.

### Error Handling

- The app entry point uses a safe `if let container` guard instead of a force-unwrap, showing a user-friendly error view if SwiftData fails to initialise.
- `DiaryView` and `TransportView` show an `.alert("Error", ...)` if `viewModel.errorMessage` is set after a failed refresh.
- `saveContext()` in `NotificationsView` wraps `modelContext.save()` in a `do/catch` block and prints a diagnostic message on failure.
- All async `refresh()` calls set `isLoading = true` before the await and `isLoading = false` in a `defer`-style pattern after, ensuring the loading overlay always dismisses.

---

## 03. User Interface Design

### Visual Design

The design targets a professional, reassuring, and child-friendly aesthetic appropriate for early years childcare:

- **Colour palette:** Blue is the primary accent (trust, calm), with category-specific colours for diary types — orange for meals, indigo for naps, green for activities, yellow for mood, purple for milestones, and red for incidents — enabling parents to scan entries at a glance.
- **Cards with shadows:** `RoundedRectangle` with `.shadow(color: .black.opacity(0.05))` creates depth without visual clutter.
- **SF Symbols:** Used throughout for iconography — universally recognisable, scale-responsive, and aligned with iOS design language.
- **Semantic font styles:** `.headline`, `.body`, `.caption` — never fixed sizes — so the layout adapts to the user's accessibility text size settings automatically.

### Usability

- **Pull-to-refresh:** All list views support `refreshable`, the native iOS pull-to-refresh gesture.
- **Search:** `DiaryView` uses `.searchable` for in-list full-text search.
- **Filter chips:** Horizontal scrolling filter chips allow quick category filtering without a separate screen.
- **Empty states:** All views use `ContentUnavailableView` instead of blank screens when no data is present.
- **Swipe actions:** `NotificationsView` supports swipe-to-delete and swipe-to-mark-as-read.
- **Live badge:** The Notifications tab badge is driven by `@Query`, always reflecting the true unread count.

### UI Components Used

```
TabView, NavigationStack, List, ForEach, ScrollView, LazyVStack,
Map (MapKit), Annotation, ContentUnavailableView, ProgressView,
Alert, Menu, ToolbarItem, swipeActions, searchable, refreshable,
RoundedRectangle, GroupBox, Label, AsyncImage, Image (SF Symbols),
Text, HStack, VStack, ZStack, Spacer, Divider, Button, Toggle
```

Custom components in `Components/`:
- `DiaryEntryCard` — reusable diary entry row
- `TransportStatusCard` — rich transport status display
- `ChildSummaryCard` — profile header
- `StatusCard`, `QuickActionButton`, `NotificationRow`

---

## 04. Swift & SwiftUI Knowledge

### Code Quality

The app follows **MVVM (Model-View-ViewModel)** throughout. Views contain only layout code; all business logic lives in `@Observable` ViewModels. Models are SwiftData `@Model` classes. A `Services/` layer separates persistence and data access from the ViewModel layer. A `Components/` folder holds all reusable SwiftUI views. Naming follows Swift API Design Guidelines: types are `UpperCamelCase`, properties and functions are `lowerCamelCase`, and SwiftUI view builders use descriptive computed property names.

### Code Examples — Best Practices

**Example 1 — Async refresh with loading state and error handling**

```swift
// DiaryViewModel.swift
func refresh() {
    Task { @MainActor in
        isLoading = true
        errorMessage = nil
        await DataService.shared.refreshData()
        loadEntries()
        isLoading = false
    }
}
```

This pattern demonstrates async/await concurrency, `@MainActor` isolation for safe UI updates, and separation of loading state from business logic.

**Example 2 — SwiftData @Query with direct modelContext persistence**

```swift
// NotificationsView.swift
@Environment(\.modelContext) private var modelContext
@Query(sort: \NotificationItem.timestamp, order: .reverse)
private var allNotifications: [NotificationItem]

private func markAsRead(_ notification: NotificationItem) {
    notification.isRead = true
    try? modelContext.save()
}
```

This demonstrates idiomatic SwiftData usage — `@Query` drives the view reactively, and mutations are persisted to disk immediately via `modelContext.save()`.

### Advanced Concepts

- **Concurrency (async/await, Task, @MainActor):** All `refresh()` methods in ViewModels use `Task { @MainActor in }` with `await DataService.shared.refreshData()`, which simulates a 500ms network delay via `Task.sleep`.
- **SwiftData (@Model, @Query, ModelContainer, ModelContext):** Full ORM persistence layer with four model types.
- **MapKit (Map, Annotation):** Transport view uses a `Map` with a custom bus annotation marker showing the approximate vehicle location.
- **@Observable macro:** All ViewModels use the modern `@Observable` pattern (iOS 17+) instead of the older `ObservableObject`/`@Published`.
- **Custom SwiftUI components:** Reusable card components with accessibility annotations.
- **Accessibility:** `.accessibilityLabel`, `.accessibilityElement(children: .combine)`, `.accessibilityAddTraits(.isSelected)` throughout.

---

## 05. Testing & Debugging

### Testing

**Unit Tests** (5 files, 50+ test cases):

```swift
// DiaryViewModelTests.swift — example test
func testFilterByMealTypeReturnsOnlyMealEntries() {
    sut.selectedFilter = .meal
    let result = sut.filteredEntries
    XCTAssertTrue(result.allSatisfy { $0.type == .meal },
        "Filtered entries should only contain meal type")
}
```

| Test File | Scenarios Covered |
|---|---|
| `DiaryViewModelTests` | Initial load, filter by type, clear filter, search (case-insensitive, empty, non-existent), sort order, group-by-date, combined filter+search |
| `NotificationsViewModelTests` | Unread count, mark as read, mark all as read, toggle filter, filtered list, delete |
| `TransportViewModelTests` | Eligibility, transport update load, status title/icon, ETA text, boarding time, showETA flag, refresh |
| `HomeViewModelTests` | Child name/room/age, diary entry limit (≤3), sort order, transport load, status string, loading state |
| `SampleDataProviderTests` | Child properties, diary count (6), diary filtering, transport for known/unknown child, notification count (5), `DiaryEntryType` icons, `TransportStatus` icons/colours |

**UI Tests:**

`NurseryConnectParentUITests` covers: app launch, tab bar visibility, navigation to all 5 tabs, Quick Action navigating to Diary tab, diary entry detail open/back navigation, search bar presence in Diary, notifications toolbar menu, profile child name display, and accessibility label presence.

**Manual Testing:**

- Verified tab switching from Quick Actions on Home screen.
- Verified swipe-to-delete and swipe-to-mark-as-read on Notifications.
- Verified diary entries grouped correctly by date.
- Verified filter chips correctly filter diary entries.
- Verified search returns case-insensitive results.
- Verified pull-to-refresh shows loading indicator and dismisses.
- Verified allergy warning shown on Home and Profile screens.
- Tested on iPhone 17 Pro simulator (iOS 26.2).

### Debugging

**Bug 1 — selectedTab had no effect on TabView:**
`HomeView` originally declared `@State private var selectedTab = 0` locally. Since `@State` is owned by the view that declares it, updates had no effect on the outer `TabView` in `ContentView`. Fixed by changing to `@Binding var selectedTab: Int` and passing `$selectedTab` from `ContentView`.

**Bug 2 — Force-unwrap crash at startup:**
`NurseryConnectParentApp` used `container!` (force-unwrap). If SwiftData failed to initialise (e.g., on a device with a corrupted store), the whole app would crash silently. Fixed with `if let container` and a user-visible error screen.

**Bug 3 — Orphaned old ViewModel code appended to NotificationsView:**
After refactoring `NotificationsView` to use `@Query`, the old ViewModel-based `var body` was left appended after the new struct's closing brace, causing 17 "Cannot find 'viewModel' in scope" errors. Fixed by truncating the file at the first `#Preview` block's closing brace.

**Bug 4 — guard body must not fall through in XCTest:**
`XCTSkip(...)` used inside a `guard` body is a discarded call — not a proper exit. Fixed by marking the test functions as `throws` and using `throw XCTSkip(...)`.

---

## 06. Regulatory Compliance Report

### Understanding of Regulations

#### UK GDPR

The app handles personal data of children (name, age, allergies, location during transit) under the UK GDPR and Data Protection Act 2018. The lawful basis for processing is **contractual necessity** (the nursery–parent childcare contract). Key obligations addressed:

- **Data minimisation (Article 5(1)(c)):** The `Child` model stores only the minimum fields needed (name, age, room, allergies, emergency contact, transport eligibility). No biometric data, home address, or photographs of the child are stored.
- **Local-first storage:** All MVP data is stored on-device via SwiftData. No personal data is transmitted to a cloud server, eliminating network-layer GDPR risks for the prototype.
- **Security:** In the MVP, authentication is excluded per assignment requirements. A production system must implement Face ID/Touch ID via `LocalAuthentication`, Keychain token storage, and `NSFileProtectionComplete` for encrypted local storage.
- **Children's data (Article 8):** Processing children's data requires particular care. The production system must have a consent capture flow and a self-service data access/erasure (DSAR) mechanism for parents.

#### EYFS 2024

The Early Years Foundation Stage 2024 framework requires settings to share children's learning journeys with parents and document development. The Daily Diary directly implements this:
- Entries of type `.milestone` surface learning achievements against EYFS learning goals.
- Entries of type `.activity` document EYFS area-of-learning activities.
- Entries of type `.incident` are colour-coded red and displayed prominently — satisfying the EYFS requirement for transparent incident communication.
- The filter chip UI lets parents isolate `.milestone` entries to track developmental progress.

Production gap: The app uses free-text entries. A full EYFS-compliant system would need structured assessment fields linked to specific learning goals, and the statutory Progress Check at Age 2.

#### Ofsted

Ofsted inspects nurseries for evidence of parental engagement and record accuracy. Each `DiaryEntry` records `staffName` and `timestamp`, creating a traceable communication log. All entry categories including incidents are displayed to parents, demonstrating the open communication Ofsted expects. A production system would require a Setting Manager app for generating Ofsted-ready reports and digital parent-acknowledgement of incident entries.

#### Children Act 1989

Section 3 of the Children Act 1989 gives parents with parental responsibility the right to receive information about their child's welfare. This app operationalises that right directly. Incident diary entries are displayed with a red `exclamationmark.triangle.fill` icon — ensuring parents are never inadvertently shielded from safeguarding-relevant records. The Transport Tracking feature supports the nursery's duty of care during transit. In production, incident entries of a safeguarding nature must require the Designated Safeguarding Lead's approval before becoming visible in the parent-facing diary.

#### FSA Guidelines

The FSA requires early years settings to manage allergens and communicate risks to parents. The app addresses this:
- The `Child.allergies` field is displayed on both the Home and Profile screens with an amber warning colour.
- The `NotificationType.alert` category is used for allergen alerts (demonstrated in sample data with a nut allergen notification for Emily).
- `DiaryEntryType.meal` entries show parents exactly what their child ate, enabling allergen cross-referencing.

Production gap: Allergen alerts must require explicit parent acknowledgement (read-receipt), with automatic escalation to staff if not acknowledged before the relevant meal.

### Compliance by Design

| Design Decision | Regulatory Basis |
|---|---|
| SwiftData local-only storage (no cloud) | UK GDPR Article 32 – reduces data breach surface area for MVP |
| Minimum `Child` model fields (no DOB, no photo, no home address) | UK GDPR Article 5(1)(c) – data minimisation |
| Red `.incident` diary type with `exclamationmark.triangle.fill` icon | Children Act 1989 s.3, EYFS 2024 – incident visibility |
| Amber allergy warning on Home and Profile screens | FSA allergen guidelines, UK GDPR Article 5(1)(d) – data accuracy |
| `staffName` + `timestamp` on every diary entry | Ofsted – audit trail of staff-to-parent communication |
| `SafetyInfoSection` in Transport view | Children Act 1989 – duty of care transparency |
| Safe `if let container` guard in app entry point | Operational resilience – no silent crash on DB failure |

### Critical Analysis

**Transparency vs. Privacy:** Detailed diary records (mood, behaviour, meals) are beneficial for EYFS parental engagement but constitute a detailed profile of a minor under UK GDPR Article 8. Mitigation: production systems should implement a rolling 12-month data retention policy and a self-service export/delete mechanism.

**Transport Safety vs. Data Protection:** GPS tracking serves a legitimate Children Act duty of care, but the same data constitutes location data of both children and the driver (sensitive under UK GDPR). Mitigation: display only the nearest named road to parents, not precise coordinates; store driver location only for the journey duration.

**Incident Disclosure vs. Safeguarding Investigation:** Transparency law (EYFS, Children Act) demands parents know about incidents, but premature disclosure could compromise a safeguarding inquiry. Mitigation: safeguarding-category incidents should require DSL approval before appearing in the parent-facing app (a two-stage drafted → approved → visible workflow).

**Allergen Notification vs. Legal Adequacy:** A push notification is not a legally sufficient substitute for a formal allergen acknowledgement process. Mitigation: production allergen alerts must require a parent acknowledgement action, with automatic staff escalation if not completed.

---

## 07. Documentation

### (a) Design Choices

- **MVVM pattern:** Chosen because SwiftUI's `@Observable` is designed around MVVM. ViewModels are independently testable, views stay lean, and the separation of concerns will ease team collaboration in a production project.
- **`TabView` + `NavigationStack`:** `TabView` is the iOS-standard pattern for a role-specific multi-feature app. `NavigationStack` within each tab is correct for push-drill-down flows (list → detail) without interfering with tab state.
- **SwiftData over Core Data:** SwiftData is Apple's modern ORM (iOS 17+), uses Swift macros (`@Model`), integrates natively with SwiftUI's `@Query`, and requires significantly less boilerplate than Core Data. Since the deployment target is iOS 26.2, SwiftData is the appropriate choice.
- **Blue primary accent:** Blue conveys trust and professionalism — appropriate for a safeguarding-sensitive childcare context. Category colours for diary types are chosen for maximum visual distinction (warm vs. cool, light vs. dark) to aid rapid scanning by busy parents.
- **`ContentUnavailableView` for empty states:** Ensures the app never presents a blank screen, which is confusing and unprofessional.

### (b) Implementation Decisions

- **`SampleDataProvider` for MVP data:** A production app would fetch from a REST API. The `DataService.useSampleData = true` flag is the single switch point for transitioning to live data — all async `refresh()` methods call `DataService.shared.refreshData()`, which would be replaced with a real network call.
- **No third-party libraries:** The app uses only Apple-provided frameworks (SwiftUI, SwiftData, MapKit, Foundation). This avoids dependency management complexity and App Store review risk for an academic MVP.
- **MapKit static coordinate:** The MVP places the bus annotation at a fixed London coordinate. Production would receive real GPS coordinates via a WebSocket or polling endpoint from the fleet management system.
- **`SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`:** The Xcode project sets this project-wide flag, meaning all types are `@MainActor`-isolated by default. This eliminates a large class of concurrency bugs but requires test code to be careful about creating and releasing `@Observable` ViewModel instances across thread boundaries.

### (c) Challenges

**Challenge 1 — Tab navigation binding:** `HomeView`'s Quick Action buttons needed to switch the outer `TabView`. The initial `@State private var selectedTab` approach had no effect because state flows downward in SwiftUI, not upward. Solution: changed to `@Binding var selectedTab: Int` passed from `ContentView`.

**Challenge 2 — SwiftData `@Query` in MVVM:** `@Query` must be a property of a `View` struct, not a `class` ViewModel. For `NotificationsView`, the data source was moved directly into the view as `@Query`, while mutation logic remained as private methods. This is idiomatic SwiftData, but required abandoning the traditional ViewModel for that view's data fetching layer.

**Challenge 3 — MapKit re-render performance:** Animating a map annotation along a route during development triggered excessive re-renders when `@State` coordinates changed inside a `Map` view. The decision was made to keep the map static for the MVP and document the production architecture (GPS polling + server-sent events) in code comments.

**Challenge 4 — Test target registration in Xcode:** Test Swift files created on disk were not visible in Xcode because they were not registered in `project.pbxproj`. Since the project uses `PBXFileSystemSynchronizedRootGroup` (Xcode 16+ feature), the fix was to add `PBXFileSystemSynchronizedRootGroup` entries for both test folders, plus the full `PBXNativeTarget`, `PBXTargetDependency`, `PBXContainerItemProxy`, and `XCBuildConfiguration` objects for both test targets.

---

## 08. Reflection

### What went well?

- The MVVM architecture kept each layer cleanly separated, making it straightforward to add async refresh and loading states to all ViewModels without touching the views.
- SwiftData with `@Query` made the notifications persistence seamless — marking a notification as read on `NotificationsView` was immediately reflected in the tab badge in `ContentView` because both are driven by the same underlying SwiftData store.
- The component architecture (`DiaryEntryCard`, `TransportStatusCard`, etc.) made the UI consistent and significantly reduced code duplication between the Home preview and the full Diary/Transport screens.
- MapKit integration worked cleanly with SwiftUI's `Map` view and required minimal boilerplate.

### What would you do differently?

- **Plan the `@Binding` navigation architecture upfront.** The `selectedTab` bug cost debugging time that could have been avoided by designing the state ownership hierarchy before writing any view code.
- **Use `@Query` in views from the start for SwiftData-backed lists.** Initially writing a ViewModel to hold SwiftData results, then refactoring to `@Query` in the view, created unnecessary churn. The rule is simple: if a list is backed by SwiftData, use `@Query` directly in the view.
- **Add test targets in Xcode before writing any test code.** Writing test files without first creating the Xcode test targets meant the files existed on disk but were invisible to the build system, leading to confusion and a manual `project.pbxproj` repair.
- **More time on UI polish.** The Transport map currently shows a static coordinate. Given more time, I would implement a simple animated route simulation using `Timer` to move the annotation along a predetermined path, making the MVP demo more compelling.

### AI Tool Usage

GitHub Copilot (Claude Sonnet 4.6) was used throughout this assignment as a coding assistant. Key uses included:

- Generating initial SwiftData model boilerplate and `@Observable` ViewModel structures.
- Reviewing code for Swift best practices and SwiftUI idiomatic patterns.
- Writing unit test cases for ViewModels and `SampleDataProvider`.
- Diagnosing the `project.pbxproj` test target registration issue and generating the corrected Xcode project file structure.
- Drafting the regulatory compliance analysis for UK GDPR, EYFS, Children Act, and FSA sections.
- Fixing Swift compiler errors (e.g., `guard` body fall-through in XCTest, `@Query` placement constraints).

All generated code was reviewed, understood, and tested before inclusion.

---

*SE4020 — Mobile Application Design & Development | Semester 1, 2026 | SLIIT*

