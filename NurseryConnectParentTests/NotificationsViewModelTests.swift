//
//  NotificationsViewModelTests.swift
//  NurseryConnectParentTests
//
//  Created on April 22, 2026
//

import XCTest
@testable import NurseryConnectParent

final class NotificationsViewModelTests: XCTestCase {

    var sut: NotificationsViewModel!

    override func setUp() {
        super.setUp()
        sut = NotificationsViewModel()
        // Reset sample data read state for deterministic tests
        sut.loadNotifications()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Initial State

    func testInitialLoadHasNotifications() {
        XCTAssertFalse(sut.notifications.isEmpty, "Notifications should be loaded on init")
    }

    func testInitialShowUnreadOnlyIsFalse() {
        XCTAssertFalse(sut.showUnreadOnly, "Show unread only should be false on init")
    }

    // MARK: - Unread Count

    func testUnreadCountMatchesActualUnreadNotifications() {
        let expected = sut.notifications.filter { !$0.isRead }.count
        XCTAssertEqual(sut.unreadCount, expected, "Unread count should match actual unread items")
    }

    func testUnreadCountIsNonNegative() {
        XCTAssertGreaterThanOrEqual(sut.unreadCount, 0, "Unread count should never be negative")
    }

    // MARK: - Mark As Read

    func testMarkAsReadDecrementsUnreadCount() {
        guard let unread = sut.notifications.first(where: { !$0.isRead }) else {
            XCTSkip("No unread notification available in sample data")
        }
        let initialCount = sut.unreadCount
        sut.markAsRead(unread)
        XCTAssertEqual(sut.unreadCount, initialCount - 1, "Unread count should decrease by 1")
    }

    func testMarkAsReadSetsIsReadTrue() {
        guard let unread = sut.notifications.first(where: { !$0.isRead }) else {
            XCTSkip("No unread notification available in sample data")
        }
        sut.markAsRead(unread)
        let updated = sut.notifications.first { $0.id == unread.id }
        XCTAssertTrue(updated?.isRead ?? false, "Notification should be marked as read")
    }

    func testMarkingAlreadyReadNotificationDoesNotChangeCount() {
        guard let alreadyRead = sut.notifications.first(where: { $0.isRead }) else {
            XCTSkip("No already-read notification in sample data")
        }
        let countBefore = sut.unreadCount
        sut.markAsRead(alreadyRead)
        XCTAssertEqual(sut.unreadCount, countBefore, "Marking an already-read item should not change the count")
    }

    // MARK: - Mark All As Read

    func testMarkAllAsReadSetsAllNotificationsRead() {
        sut.markAllAsRead()
        XCTAssertTrue(
            sut.notifications.allSatisfy { $0.isRead },
            "All notifications should be read after markAllAsRead"
        )
    }

    func testMarkAllAsReadSetsUnreadCountToZero() {
        sut.markAllAsRead()
        XCTAssertEqual(sut.unreadCount, 0, "Unread count should be zero after markAllAsRead")
    }

    // MARK: - Toggle Unread Filter

    func testToggleUnreadFilterChangesState() {
        let initial = sut.showUnreadOnly
        sut.toggleUnreadFilter()
        XCTAssertNotEqual(sut.showUnreadOnly, initial, "Toggle should change showUnreadOnly state")
    }

    func testToggleUnreadFilterTwiceRestoresOriginalState() {
        sut.toggleUnreadFilter()
        sut.toggleUnreadFilter()
        XCTAssertFalse(sut.showUnreadOnly, "Two toggles should restore the original false state")
    }

    // MARK: - Filtered Notifications

    func testFilteredNotificationsWhenShowAllReturnsAll() {
        sut.showUnreadOnly = false
        XCTAssertEqual(
            sut.filteredNotifications.count,
            sut.notifications.count,
            "When showUnreadOnly is false, all notifications should be returned"
        )
    }

    func testFilteredNotificationsWhenShowUnreadOnlyReturnsOnlyUnread() {
        sut.showUnreadOnly = true
        let result = sut.filteredNotifications
        XCTAssertTrue(
            result.allSatisfy { !$0.isRead },
            "When showUnreadOnly is true, only unread notifications should be returned"
        )
    }

    func testFilteredUnreadCountMatchesUnreadCount() {
        sut.showUnreadOnly = true
        XCTAssertEqual(
            sut.filteredNotifications.count,
            sut.unreadCount,
            "Filtered unread count should equal unreadCount"
        )
    }

    // MARK: - Delete

    func testDeleteNotificationReducesTotalCount() {
        let initialCount = sut.notifications.count
        guard let first = sut.notifications.first else {
            XCTFail("Need at least one notification to test deletion")
            return
        }
        sut.deleteNotification(first)
        XCTAssertEqual(
            sut.notifications.count,
            initialCount - 1,
            "Deleting a notification should reduce count by 1"
        )
    }

    func testDeleteNotificationRemovesFromList() {
        guard let first = sut.notifications.first else {
            XCTFail("Need at least one notification")
            return
        }
        let id = first.id
        sut.deleteNotification(first)
        XCTAssertFalse(
            sut.notifications.contains { $0.id == id },
            "Deleted notification should no longer be in the list"
        )
    }

    // MARK: - Refresh

    func testRefreshReloadsNotifications() {
        let countBefore = sut.notifications.count
        sut.refresh()
        XCTAssertEqual(
            sut.notifications.count,
            countBefore,
            "Refresh should reload the same sample data"
        )
    }
}
