//
//  HomeViewModelTests.swift
//  NurseryConnectParentTests
//
//  Created on April 22, 2026
//

import XCTest
@testable import NurseryConnectParent

final class HomeViewModelTests: XCTestCase {

    var sut: HomeViewModel!

    override func setUp() {
        super.setUp()
        sut = HomeViewModel()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Child

    func testChildNameIsEmily() {
        XCTAssertEqual(sut.child.name, "Emily Johnson", "Home view model should load the sample child")
    }

    func testChildRoomIsRainbowRoom() {
        XCTAssertEqual(sut.child.room, "Rainbow Room")
    }

    func testChildAgeIsThree() {
        XCTAssertEqual(sut.child.age, 3)
    }

    // MARK: - Diary Entries

    func testLatestDiaryEntriesAreLoaded() {
        XCTAssertFalse(sut.latestDiaryEntries.isEmpty, "Latest diary entries should load on init")
    }

    func testLatestDiaryEntriesLimitedToThree() {
        XCTAssertLessThanOrEqual(
            sut.latestDiaryEntries.count,
            3,
            "Home view should show a maximum of 3 diary entries"
        )
    }

    func testLatestDiaryEntriesAreSortedNewestFirst() {
        guard sut.latestDiaryEntries.count > 1 else { return }
        let dates = sut.latestDiaryEntries.map { $0.timestamp }
        for i in 0..<dates.count - 1 {
            XCTAssertGreaterThanOrEqual(dates[i], dates[i + 1], "Entries should be newest first")
        }
    }

    // MARK: - Transport

    func testTransportUpdateIsLoadedForEligibleChild() {
        XCTAssertNotNil(sut.transportUpdate, "Sample child is eligible so transport update should load")
    }

    // MARK: - Status

    func testCurrentStatusIsNonEmpty() {
        XCTAssertFalse(sut.currentStatus.isEmpty, "currentStatus should always return a non-empty string")
    }

    func testStatusIconIsNonEmpty() {
        XCTAssertFalse(sut.statusIcon.isEmpty, "statusIcon should always return a non-empty SF Symbol name")
    }

    // MARK: - Unread Notifications

    func testUnreadNotificationCountIsNonNegative() {
        XCTAssertGreaterThanOrEqual(sut.unreadNotificationCount, 0)
    }

    // MARK: - Loading State

    func testInitialLoadingStateIsFalse() {
        XCTAssertFalse(sut.isLoading, "isLoading should be false on init")
    }

    // MARK: - Refresh

    func testRefreshDoesNotCrash() {
        XCTAssertNoThrow(sut.refresh(), "Calling refresh should not throw")
    }

    func testRefreshReloadsChild() {
        let originalName = sut.child.name
        sut.refresh()
        XCTAssertEqual(sut.child.name, originalName, "Refresh should reload the same child")
    }
}
