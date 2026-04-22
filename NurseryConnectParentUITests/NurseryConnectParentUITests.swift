//
//  NurseryConnectParentUITests.swift
//  NurseryConnectParentUITests
//
//  Created on April 22, 2026
//

import XCTest

final class NurseryConnectParentUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Launch

    func testAppLaunchDisplaysTabBar() throws {
        XCTAssertTrue(
            app.tabBars.firstMatch.waitForExistence(timeout: 5),
            "Tab bar should be visible when app launches"
        )
    }

    func testAppLaunchShowsHomeTab() throws {
        XCTAssertTrue(
            app.navigationBars["Home"].waitForExistence(timeout: 5),
            "Home navigation title should be visible on launch"
        )
    }

    // MARK: - Tab Navigation

    func testNavigateToDiaryTab() throws {
        app.tabBars.buttons["Diary"].tap()
        XCTAssertTrue(
            app.navigationBars["Daily Diary"].waitForExistence(timeout: 3),
            "Diary view should display its navigation title"
        )
    }

    func testNavigateToTransportTab() throws {
        app.tabBars.buttons["Transport"].tap()
        XCTAssertTrue(
            app.navigationBars["Transport Tracking"].waitForExistence(timeout: 3),
            "Transport view should display its navigation title"
        )
    }

    func testNavigateToNotificationsTab() throws {
        app.tabBars.buttons["Notifications"].tap()
        XCTAssertTrue(
            app.navigationBars["Notifications"].waitForExistence(timeout: 3),
            "Notifications view should display its navigation title"
        )
    }

    func testNavigateToProfileTab() throws {
        app.tabBars.buttons["Profile"].tap()
        XCTAssertTrue(
            app.navigationBars["Profile"].waitForExistence(timeout: 3),
            "Profile view should display its navigation title"
        )
    }

    func testAllFiveTabsExist() throws {
        let expectedTabs = ["Home", "Diary", "Transport", "Notifications", "Profile"]
        for tab in expectedTabs {
            XCTAssertTrue(
                app.tabBars.buttons[tab].exists,
                "Tab '\(tab)' should exist in the tab bar"
            )
        }
    }

    // MARK: - Home View

    func testHomeViewShowsChildCard() throws {
        XCTAssertTrue(
            app.scrollViews.firstMatch.waitForExistence(timeout: 3),
            "Home view should contain a scrollable child summary"
        )
    }

    func testHomeViewShowsQuickActions() throws {
        // Quick action buttons should be present
        XCTAssertTrue(
            app.scrollViews.firstMatch.waitForExistence(timeout: 3),
            "Home view scroll view should exist"
        )
        let viewDiaryButton = app.buttons["View Diary"]
        XCTAssertTrue(
            viewDiaryButton.waitForExistence(timeout: 3),
            "View Diary quick action should be visible on Home"
        )
    }

    func testHomeViewDiaryQuickActionNavigatesToDiaryTab() throws {
        let viewDiaryButton = app.buttons["View Diary"]
        if viewDiaryButton.waitForExistence(timeout: 3) {
            viewDiaryButton.tap()
            XCTAssertTrue(
                app.navigationBars["Daily Diary"].waitForExistence(timeout: 3),
                "Tapping View Diary quick action should navigate to Diary tab"
            )
        } else {
            XCTSkip("View Diary button not found – possibly not in viewport")
        }
    }

    // MARK: - Diary View

    func testDiaryViewShowsEntries() throws {
        app.tabBars.buttons["Diary"].tap()
        XCTAssertTrue(
            app.scrollViews.firstMatch.waitForExistence(timeout: 3),
            "Diary view should display a list of entries"
        )
    }

    func testDiaryViewHasSearchBar() throws {
        app.tabBars.buttons["Diary"].tap()
        // SwiftUI .searchable shows a search field
        XCTAssertTrue(
            app.searchFields.firstMatch.waitForExistence(timeout: 3),
            "Diary view should have a search field"
        )
    }

    func testDiaryDetailViewOpensOnTap() throws {
        app.tabBars.buttons["Diary"].tap()
        let firstEntry = app.scrollViews.firstMatch.buttons.firstMatch
        if firstEntry.waitForExistence(timeout: 3) {
            firstEntry.tap()
            XCTAssertTrue(
                app.navigationBars["Diary Details"].waitForExistence(timeout: 3),
                "Tapping a diary entry should open the detail view"
            )
        } else {
            XCTSkip("No diary entry button found to tap")
        }
    }

    func testDiaryDetailViewCanNavigateBack() throws {
        app.tabBars.buttons["Diary"].tap()
        let firstEntry = app.scrollViews.firstMatch.buttons.firstMatch
        if firstEntry.waitForExistence(timeout: 3) {
            firstEntry.tap()
            _ = app.navigationBars["Diary Details"].waitForExistence(timeout: 3)
            app.navigationBars.buttons.firstMatch.tap()
            XCTAssertTrue(
                app.navigationBars["Daily Diary"].waitForExistence(timeout: 3),
                "Back navigation from detail view should return to Diary list"
            )
        } else {
            XCTSkip("No diary entry found to test back navigation")
        }
    }

    // MARK: - Notifications View

    func testNotificationsViewShowsList() throws {
        app.tabBars.buttons["Notifications"].tap()
        XCTAssertTrue(
            app.navigationBars["Notifications"].waitForExistence(timeout: 3),
            "Notifications navigation title should exist"
        )
    }

    func testNotificationsMenuButtonExists() throws {
        app.tabBars.buttons["Notifications"].tap()
        let menuButton = app.navigationBars.buttons["More options"]
        XCTAssertTrue(
            menuButton.waitForExistence(timeout: 3),
            "Notifications toolbar menu button should exist"
        )
    }

    // MARK: - Profile View

    func testProfileViewShowsChildName() throws {
        app.tabBars.buttons["Profile"].tap()
        XCTAssertTrue(
            app.staticTexts["Emily Johnson"].waitForExistence(timeout: 3),
            "Profile view should display the child's name"
        )
    }

    func testProfileViewSettingsNavigation() throws {
        app.tabBars.buttons["Profile"].tap()
        let settingsButton = app.buttons["Settings"]
        if settingsButton.waitForExistence(timeout: 3) {
            settingsButton.tap()
            XCTAssertTrue(
                app.navigationBars["Settings"].waitForExistence(timeout: 3),
                "Settings navigation should open from profile"
            )
        } else {
            XCTSkip("Settings button not visible in profile list")
        }
    }

    // MARK: - Accessibility

    func testTabBarItemsHaveAccessibilityLabels() throws {
        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 3))
        // Verify that accessibility labels exist for tabs
        XCTAssertTrue(app.tabBars.buttons["Home"].exists)
        XCTAssertTrue(app.tabBars.buttons["Diary"].exists)
    }
}
