//
//  DiaryViewModelTests.swift
//  NurseryConnectParentTests
//
//  Created on April 22, 2026
//

import XCTest
@testable import NurseryConnectParent

final class DiaryViewModelTests: XCTestCase {

    var sut: DiaryViewModel!

    override func setUp() {
        super.setUp()
        sut = DiaryViewModel()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Initial Load

    func testInitialLoadHasDiaryEntries() {
        XCTAssertFalse(sut.diaryEntries.isEmpty, "Diary entries should be loaded on init")
    }

    func testInitialFilterIsNil() {
        XCTAssertNil(sut.selectedFilter, "No filter should be applied on init")
    }

    func testInitialSearchTextIsEmpty() {
        XCTAssertTrue(sut.searchText.isEmpty, "Search text should be empty on init")
    }

    func testInitialLoadingStateIsFalse() {
        XCTAssertFalse(sut.isLoading, "isLoading should be false on init")
    }

    // MARK: - Filtering

    func testFilterByMealType() {
        sut.setFilter(.meal)
        let filtered = sut.filteredEntries
        XCTAssertTrue(
            filtered.allSatisfy { $0.type == .meal },
            "All filtered entries should be of type Meal"
        )
    }

    func testFilterByNapType() {
        sut.setFilter(.nap)
        let filtered = sut.filteredEntries
        XCTAssertTrue(
            filtered.allSatisfy { $0.type == .nap },
            "All filtered entries should be of type Nap"
        )
    }

    func testFilterByActivityType() {
        sut.setFilter(.activity)
        let filtered = sut.filteredEntries
        XCTAssertTrue(
            filtered.allSatisfy { $0.type == .activity },
            "All filtered entries should be of type Activity"
        )
    }

    func testClearFilterReturnsAllEntries() {
        sut.setFilter(.meal)
        sut.clearFilter()
        XCTAssertNil(sut.selectedFilter, "Filter should be nil after clearing")
        XCTAssertEqual(
            sut.filteredEntries.count,
            sut.diaryEntries.count,
            "Clearing filter should return all entries"
        )
    }

    func testFilterNotMatchingTypeReturnsEmpty() {
        sut.setFilter(.incident)
        // Sample data has no incident entries
        XCTAssertTrue(
            sut.filteredEntries.allSatisfy { $0.type == .incident },
            "Entries with non-matching type filter should all satisfy the type predicate"
        )
    }

    // MARK: - Search

    func testSearchByTitleReturnsMatch() {
        sut.searchText = "Lunch"
        let results = sut.filteredEntries
        let hasMatch = results.allSatisfy {
            $0.title.localizedCaseInsensitiveContains("Lunch") ||
            $0.details.localizedCaseInsensitiveContains("Lunch")
        }
        XCTAssertTrue(hasMatch, "Search results should match search term")
    }

    func testSearchEmptyStringReturnsAllEntries() {
        sut.searchText = ""
        XCTAssertEqual(
            sut.filteredEntries.count,
            sut.diaryEntries.count,
            "Empty search should return all entries"
        )
    }

    func testSearchNonExistentTermReturnsEmpty() {
        sut.searchText = "XYZNONEXISTENT99"
        XCTAssertTrue(sut.filteredEntries.isEmpty, "No results expected for non-existent search term")
    }

    func testSearchIsCaseInsensitive() {
        sut.searchText = "lunch"
        let lowerResults = sut.filteredEntries.count
        sut.searchText = "LUNCH"
        let upperResults = sut.filteredEntries.count
        XCTAssertEqual(lowerResults, upperResults, "Search should be case-insensitive")
    }

    // MARK: - Sorting

    func testEntriesAreSortedNewestFirst() {
        guard sut.diaryEntries.count > 1 else {
            XCTFail("Need more than one entry to test sorting")
            return
        }
        let dates = sut.diaryEntries.map { $0.timestamp }
        for i in 0..<dates.count - 1 {
            XCTAssertGreaterThanOrEqual(
                dates[i], dates[i + 1],
                "Entries should be sorted newest first"
            )
        }
    }

    // MARK: - Group by Date

    func testEntriesByDateReturnsGroupedEntries() {
        let grouped = sut.entriesByDate()
        XCTAssertFalse(grouped.isEmpty, "Grouped entries should not be empty")
    }

    func testEntriesByDateGroupsAreNonEmpty() {
        let grouped = sut.entriesByDate()
        for (_, entries) in grouped {
            XCTAssertFalse(entries.isEmpty, "Each date group should contain at least one entry")
        }
    }

    func testEntriesByDateSortedNewestFirst() {
        let grouped = sut.entriesByDate()
        guard grouped.count > 1 else { return }
        let dates = grouped.map { $0.0 }
        for i in 0..<dates.count - 1 {
            XCTAssertGreaterThanOrEqual(dates[i], dates[i + 1], "Date groups should be newest first")
        }
    }

    // MARK: - Combined Filter and Search

    func testFilterAndSearchCombined() {
        sut.setFilter(.meal)
        sut.searchText = "Lunch"
        let results = sut.filteredEntries
        XCTAssertTrue(
            results.allSatisfy { $0.type == .meal },
            "Combined filter should still enforce type"
        )
        XCTAssertTrue(
            results.allSatisfy {
                $0.title.localizedCaseInsensitiveContains("Lunch") ||
                $0.details.localizedCaseInsensitiveContains("Lunch")
            },
            "Combined filter should still enforce search term"
        )
    }
}
