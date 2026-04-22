# SE4020 – Mobile Application Design and Development
## Assignment Report – NurseryConnect Parent App

---

## 1. Chosen User Role

**Role: Parent / Guardian**

The Parent/Guardian role was selected because it represents the primary end-user of a consumer-facing nursery communication application. Parents are the audience most likely to benefit from a mobile-first experience, as they need real-time visibility into their child's daily life while they are away at work or engaged in other activities. Building from this perspective also yields a cohesive, self-contained set of features that form a meaningful MVP without requiring backend systems, authentication flows, or staff-side workflows.

---

## 2. Selected Features and Justification

### Feature 1: Daily Diary (Child Activity Log)

The Daily Diary feature enables parents to view structured updates about their child's day, categorised by type: meals, naps, activities, mood, milestones, and incidents. Parents can filter entries by category, search free-text, and tap any entry for full detail.

**Justification:** The Early Years Foundation Stage (EYFS) 2024 framework explicitly requires settings to share children's learning journeys with parents and promote parental engagement. A digital diary directly satisfies this requirement. From a parent's perspective, this is the single highest-value feature because it provides reassurance, reduces anxiety about the child's wellbeing, and fosters the parent-nursery partnership mandated by the EYFS. It also maps cleanly to a 4-week MVP: the data model, filter logic, and detail navigation are well-scoped and completable without a live backend.

### Feature 2: Transport Tracking

The Transport Tracking feature shows parents the live status of their child's nursery bus, including current boarding status, estimated arrival time, driver name, vehicle number, and a map view of the approximate location.

**Justification:** Child safety during transport is a regulatory concern under the Children Act 1989 (section 3 duty of care), and parents have a legitimate and urgent need to know when their child boards and when to expect them home. This feature complements the Diary: together, they cover both the child's time inside the nursery and their journey to and from it. For a 4-week MVP, the feature is appropriate in scope — a status model, a map component (MapKit), and a card-based status display are all achievable without live GPS infrastructure by using representative sample data.

---

## 3. Architecture and Design Decisions

### 3.1 Architectural Pattern – MVVM

The application uses the **Model-View-ViewModel (MVVM)** pattern throughout. This was chosen because:

- SwiftUI's data-binding system (via `@Observable`) is designed around MVVM, making it idiomatic.
- Separation of concerns: Views contain only layout code; all business logic lives in ViewModels.
- Testability: ViewModels can be unit-tested independently of the UI.
- Maintainability: A future developer can read any ViewModel in isolation and understand the feature's logic.

Each screen has a dedicated ViewModel:
- `HomeViewModel` — aggregates child, diary preview, transport, and notification badge data.
- `DiaryViewModel` — loads, filters, searches, and groups diary entries.
- `TransportViewModel` — loads transport status and computes derived display values (ETA text, boarding time).
- `NotificationsViewModel` — manages in-memory notification state for the Home screen badge.

### 3.2 Data Layer

**SwiftData** (Apple's modern ORM, iOS 17+) is used for persistence. The schema includes four models: `Child`, `DiaryEntry`, `TransportUpdate`, and `NotificationItem`.

- `PersistenceService` (singleton) initialises the `ModelContainer` with a persistent store. It falls back to an in-memory container gracefully if setup fails, with a user-visible error shown in the app entry point.
- `SampleDataProvider` supplies rich, realistic sample data for the MVP. It is inserted into the SwiftData store on first launch and is not re-inserted on subsequent launches (guarded by a pre-check).
- **Notifications persistence** is handled directly via `@Query` and `@Environment(\.modelContext)` in `NotificationsView`, allowing mark-as-read and delete operations to be persisted to disk immediately. This demonstrates end-to-end SwiftData persistence — the tab badge count and notification list both update reactively because both are driven by `@Query`.

### 3.3 Navigation

Navigation uses two complementary patterns:
- **`TabView`** for top-level section switching (Home, Diary, Transport, Notifications, Profile).
- **`NavigationStack`** within each tab for push-based drill-down (e.g., Diary list → Diary detail).

The `selectedTab` binding is passed from `ContentView` down to `HomeView`, so the Quick Action buttons on the home screen correctly switch the outer TabView. This was corrected from an initial implementation where `selectedTab` was a local `@State` in `HomeView` (which had no effect on the outer tab).

### 3.4 Concurrency – async/await

All `refresh()` methods in ViewModels use `Task { @MainActor in }` with `await DataService.shared.refreshData()`. The `refreshData()` function simulates a 500ms network round-trip using `Task.sleep`. This demonstrates iOS concurrency best practices:
- Non-blocking UI (refresh is async, not sync).
- `@MainActor` ensures UI updates happen on the main thread.
- `isLoading` flags drive `ProgressView` overlays in DiaryView and TransportView.

### 3.5 Component Architecture

Reusable SwiftUI components are extracted into a dedicated `Components/` folder:
- `DiaryEntryCard` — used in both `HomeView` and `DiaryView`.
- `TransportStatusCard` — rich status display with all transport metadata.
- `ChildSummaryCard` — profile header shown on the home screen.
- `StatusCard`, `QuickActionButton`, `NotificationRow` — utility components.

This reduces code duplication and keeps views lean.

### 3.6 Accessibility

- Every interactive element has `.accessibilityLabel` annotations.
- Cards use `.accessibilityElement(children: .combine)` to present as single accessible elements to VoiceOver.
- Tab items have explicit `.accessibilityLabel` including dynamic unread counts.
- `FilterChip` uses `.accessibilityAddTraits(.isSelected)` for the selected state.
- SwiftUI's Dynamic Type is supported by default — all text uses semantic font styles (`.headline`, `.body`, `.caption`) rather than fixed sizes.

---

## 4. User Interface Design

### 4.1 Visual Design Rationale

The design language targets professional, reassuring, and child-friendly aesthetics appropriate for the sensitive context of early years childcare:

- **Colour palette:** Blue is the primary accent (trust, professionalism), with category-specific colours for diary types (orange for meals, indigo for naps, green for activities, etc.) to help parents scan quickly.
- **Cards with subtle shadows:** `RoundedRectangle` with `.shadow(color: .black.opacity(0.05))` creates visual depth without making the UI feel heavy or cluttered.
- **Iconography:** SF Symbols throughout — universally recognisable, scale-responsive, and aligned with iOS design conventions.
- **Typography:** Semantic font styles ensure the layout adapts to the user's accessibility text size settings.

### 4.2 Usability Decisions

- **Pull-to-refresh:** All list views support `refreshable`, the iOS-native pull-to-refresh gesture.
- **Search:** `DiaryView` uses `.searchable` for in-list full-text search, reducing the need to scroll.
- **Filter chips:** Horizontal scrolling filter chips allow quick category filtering without navigating to a separate filter screen.
- **Empty states:** All views use `ContentUnavailableView` when no data is present, rather than showing a blank screen.
- **Swipe actions:** `NotificationsView` supports swipe-to-delete and swipe-to-mark-as-read — standard iOS gesture patterns.
- **Badge count:** The Notifications tab shows a live badge driven by `@Query`, so it always reflects the true number of unread notifications.

---

## 5. Implementation Decisions and Constraints

### 5.1 Sample Data vs. Live Backend

An MVP without a backend uses `SampleDataProvider` to generate rich, realistic data. The data is inserted into SwiftData on first launch, allowing the app to demonstrate real persistence (notification read status survives app restarts). In a production system, `DataService` would be extended to fetch from a REST API and the `useSampleData` flag would be removed.

### 5.2 MapKit

The Transport view uses MapKit's `Map` view with an `Annotation` marker. In the MVP, the annotation is placed at a static London coordinate representing an approximate bus location. In production, this would receive real GPS coordinates from the fleet management system via a WebSocket or polling API.

### 5.3 No Authentication

Per the assignment requirements, login/authentication is excluded. In a production system, the app would use Sign in with Apple or a nursery-provided SSO, with tokens stored in the iOS Keychain (not UserDefaults, which is not encrypted).

### 5.4 SwiftData Schema Evolution

The schema is designed with versioned future migration in mind. All model properties are non-optional where possible, with default values, to simplify schema migrations as the app evolves.

---

## 6. Testing

### 6.1 Unit Tests

Unit tests cover all four ViewModels and the `SampleDataProvider`:

| Test File | Scenarios Covered |
|-----------|-------------------|
| `DiaryViewModelTests` | Initial load, filter by type, clear filter, search by text, case-insensitive search, sort order, group-by-date |
| `NotificationsViewModelTests` | Unread count, mark as read, mark all as read, toggle filter, filtered list, delete |
| `TransportViewModelTests` | Eligibility, transport update load, status title, ETA text, boarding time, showETA flag, ineligible child |
| `HomeViewModelTests` | Child data, diary entry limit (≤3), sort order, transport load, status string, loading state |
| `SampleDataProviderTests` | Child properties, diary count, diary filtering, transport for known/unknown child, notification count, model enums |

Total: **50+ test cases** across 5 test files.

### 6.2 UI Tests

`NurseryConnectParentUITests` covers:
- App launch and tab bar visibility.
- Navigation to all 5 tabs.
- Home quick action navigating to Diary tab.
- Diary entry tapping opening detail view.
- Back navigation from detail view.
- Search bar presence in Diary view.
- Profile view displaying child name.
- Notifications toolbar menu button.
- Accessibility label presence.

### 6.3 How to Add Test Targets in Xcode

1. Open `NurseryConnectParent.xcodeproj` in Xcode.
2. **File → New → Target → Unit Testing Bundle** → name it `NurseryConnectParentTests` → Finish.
3. **File → New → Target → UI Testing Bundle** → name it `NurseryConnectParentUITests` → Finish.
4. In each target's build settings, confirm the **Host Application** is `NurseryConnectParent`.
5. Add the test Swift files from `NurseryConnectParentTests/` and `NurseryConnectParentUITests/` to their respective targets.
6. Run tests with **⌘U**.

---

## 7. Challenges

### 7.1 Tab Navigation Binding

The initial implementation stored `selectedTab` as `@State` local to `HomeView`. This meant tapping the Quick Action buttons had no effect on the outer `TabView` in `ContentView`. The fix required changing `HomeView` to accept `@Binding var selectedTab: Int` and passing `$selectedTab` from `ContentView`. This was a subtle bug caused by SwiftUI's strict ownership of state — a `@State` variable is local to the view that declares it and cannot propagate upward.

### 7.2 SwiftData and @Query vs. ViewModel Patterns

Integrating SwiftData's `@Query` macro with the MVVM pattern required careful thought. `@Query` must be declared as a property of a `View` struct, not inside a `class` ViewModel. The solution adopted for `NotificationsView` was to move the data fetching directly into the view using `@Query`, while keeping the mutation logic as private methods in the view body. This is idiomatic SwiftData usage but required abandoning the traditional ViewModel for that view's data source.

### 7.3 Real-Time Transport Simulation

MapKit requires real GPS coordinates for accurate live tracking. In the MVP, a static coordinate is used. Attempting to animate the marker along a route during development showed that `@State` coordinate updates inside a `Map` view could trigger excessive re-renders. The decision was made to keep the map static for the MVP and document the production architecture (GPS polling + server-sent events) in comments.

### 7.4 Safe Container Initialisation

The initial code used `persistenceService.container!` (force-unwrap) in the app entry point. This would crash the entire app if SwiftData failed to initialise (e.g., corrupted store). The fix wraps the container in an `if let` and presents a user-friendly error message, preventing a hard crash.

---

*Report prepared as part of SE4020 – Mobile Application Design and Development, Semester 1, 2026.*
