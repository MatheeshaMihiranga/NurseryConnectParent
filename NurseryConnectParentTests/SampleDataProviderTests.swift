//
//  SampleDataProviderTests.swift
//  NurseryConnectParentTests
//
//  Created on April 22, 2026
//

import XCTest
@testable import NurseryConnectParent

final class SampleDataProviderTests: XCTestCase {

    let provider = SampleDataProvider.shared

    // MARK: - Sample Child

    func testSampleChildNameIsCorrect() {
        XCTAssertEqual(provider.sampleChild.name, "Emily Johnson")
    }

    func testSampleChildAgeIsThree() {
        XCTAssertEqual(provider.sampleChild.age, 3)
    }

    func testSampleChildRoomIsCorrect() {
        XCTAssertEqual(provider.sampleChild.room, "Rainbow Room")
    }

    func testSampleChildHasAllergies() {
        XCTAssertNotEqual(provider.sampleChild.allergies, "None", "Sample child should have allergies defined")
    }

    func testSampleChildIsTransportEligible() {
        XCTAssertTrue(provider.sampleChild.isTransportEligible)
    }

    func testSampleChildEmergencyContactIsNonEmpty() {
        XCTAssertFalse(provider.sampleChild.emergencyContact.isEmpty)
    }

    // MARK: - Diary Entries

    func testSampleDiaryEntriesCountIsSix() {
        XCTAssertEqual(provider.sampleDiaryEntries.count, 6, "Exactly 6 sample diary entries expected")
    }

    func testDiaryEntriesAllBelongToSampleChild() {
        let childId = provider.sampleChild.id
        XCTAssertTrue(
            provider.sampleDiaryEntries.allSatisfy { $0.childId == childId },
            "All diary entries should belong to the sample child"
        )
    }

    func testGetDiaryEntriesForKnownChildReturnsAll() {
        let entries = provider.getDiaryEntries(for: provider.sampleChild.id)
        XCTAssertEqual(entries.count, provider.sampleDiaryEntries.count)
    }

    func testGetDiaryEntriesForUnknownChildReturnsEmpty() {
        let entries = provider.getDiaryEntries(for: UUID())
        XCTAssertTrue(entries.isEmpty, "Unknown child ID should return no diary entries")
    }

    func testDiaryEntriesCoverMultipleTypes() {
        let types = Set(provider.sampleDiaryEntries.map { $0.type })
        XCTAssertGreaterThan(types.count, 1, "Sample data should contain multiple diary entry types")
    }

    // MARK: - Transport Updates

    func testGetTransportUpdateForKnownChildIsNotNil() {
        let update = provider.getTransportUpdate(for: provider.sampleChild.id)
        XCTAssertNotNil(update, "Transport update should exist for the sample child")
    }

    func testGetTransportUpdateForUnknownChildIsNil() {
        let update = provider.getTransportUpdate(for: UUID())
        XCTAssertNil(update, "Transport update should be nil for an unknown child")
    }

    func testTransportUpdateHasDriver() {
        let update = provider.getTransportUpdate(for: provider.sampleChild.id)
        XCTAssertFalse(update?.driverName.isEmpty ?? true, "Transport update should have a driver name")
    }

    func testTransportUpdateHasVehicleNumber() {
        let update = provider.getTransportUpdate(for: provider.sampleChild.id)
        XCTAssertFalse(update?.vehicleNumber.isEmpty ?? true, "Transport update should have a vehicle number")
    }

    // MARK: - Notifications

    func testSampleNotificationsCountIsFive() {
        XCTAssertEqual(provider.sampleNotifications.count, 5, "Exactly 5 sample notifications expected")
    }

    func testGetNotificationsForNilChildIdReturnsAll() {
        let all = provider.getNotifications(for: nil)
        XCTAssertEqual(all.count, provider.sampleNotifications.count)
    }

    func testGetNotificationsForKnownChildFiltersCorrectly() {
        let childId = provider.sampleChild.id
        let filtered = provider.getNotifications(for: childId)
        XCTAssertTrue(
            filtered.allSatisfy { $0.childId == childId || $0.childId == nil },
            "Filtered notifications should belong to child or be global"
        )
    }

    func testUnreadNotificationCountIsAccurate() {
        let expected = provider.sampleNotifications.filter { !$0.isRead }.count
        XCTAssertEqual(provider.getUnreadNotificationCount(), expected)
    }

    func testSampleNotificationsHaveMixedReadState() {
        let readCount = provider.sampleNotifications.filter { $0.isRead }.count
        let unreadCount = provider.sampleNotifications.filter { !$0.isRead }.count
        XCTAssertGreaterThan(readCount, 0, "Some notifications should be pre-read")
        XCTAssertGreaterThan(unreadCount, 0, "Some notifications should be unread")
    }

    // MARK: - DiaryEntry Model

    func testDiaryEntryTypeIconIsNonEmpty() {
        for type_ in DiaryEntryType.allCases {
            XCTAssertFalse(type_.icon.isEmpty, "\(type_.rawValue) should have a non-empty icon name")
        }
    }

    func testTransportStatusIconIsNonEmpty() {
        let statuses: [TransportStatus] = [.notInTransit, .boarding, .inTransit, .arriving, .arrived, .atNursery]
        for status in statuses {
            XCTAssertFalse(status.icon.isEmpty, "\(status.rawValue) should have a non-empty icon")
        }
    }

    func testTransportStatusColorIsNonEmpty() {
        let statuses: [TransportStatus] = [.notInTransit, .boarding, .inTransit, .arriving, .arrived, .atNursery]
        for status in statuses {
            XCTAssertFalse(status.color.isEmpty, "\(status.rawValue) should have a non-empty color string")
        }
    }
}
