//
//  TransportViewModelTests.swift
//  NurseryConnectParentTests
//
//  Created on April 22, 2026
//

import XCTest
@testable import NurseryConnectParent

final class TransportViewModelTests: XCTestCase {

    var sut: TransportViewModel!

    override func setUp() {
        super.setUp()
        sut = TransportViewModel()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Initial State

    func testTransportEligibilityMatchesSampleChild() {
        XCTAssertTrue(sut.isTransportEligible, "Sample child should be transport-eligible")
    }

    func testTransportUpdateLoadsForEligibleChild() {
        XCTAssertNotNil(sut.transportUpdate, "Transport update should be present for eligible child")
    }

    func testInitialLoadingStateIsFalse() {
        XCTAssertFalse(sut.isLoading, "isLoading should be false on init")
    }

    func testInitialErrorMessageIsNil() {
        XCTAssertNil(sut.errorMessage, "errorMessage should be nil on init")
    }

    // MARK: - Status

    func testStatusTitleMatchesTransportStatus() {
        guard let transport = sut.transportUpdate else {
            XCTFail("Expected transport update to be loaded")
            return
        }
        XCTAssertEqual(sut.statusTitle, transport.status.rawValue)
    }

    func testStatusIconIsNonEmpty() {
        XCTAssertFalse(sut.statusIcon.isEmpty, "Status icon should be a non-empty SF Symbol name")
    }

    // MARK: - ETA

    func testETATextIsValidWhenInTransit() {
        guard let status = sut.transportUpdate?.status else { return }
        if status == .inTransit || status == .arriving {
            XCTAssertNotEqual(sut.etaText, "N/A", "ETA should be a valid time when in transit")
        }
    }

    func testETATextIsNAWhenNoArrivalSet() {
        // Create a transport update without an estimated arrival
        let noEtaTransport = TransportUpdate(
            childId: SampleDataProvider.shared.sampleChild.id,
            status: .boarding,
            boardingTime: nil,
            estimatedArrival: nil,
            lastUpdate: Date(),
            currentLocation: "Test",
            driverName: "Test Driver",
            vehicleNumber: "NC-001"
        )
        sut.transportUpdate = noEtaTransport
        XCTAssertEqual(sut.etaText, "N/A", "ETA should be N/A when estimatedArrival is nil")
    }

    // MARK: - Boarding Time

    func testBoardingTimeTextIsNAWhenNoBoardingTime() {
        let noBoardingTransport = TransportUpdate(
            childId: SampleDataProvider.shared.sampleChild.id,
            status: .inTransit,
            boardingTime: nil,
            estimatedArrival: nil,
            lastUpdate: Date(),
            currentLocation: "Test",
            driverName: "Test Driver",
            vehicleNumber: "NC-001"
        )
        sut.transportUpdate = noBoardingTransport
        XCTAssertEqual(sut.boardingTimeText, "N/A", "Boarding time should be N/A when nil")
    }

    func testBoardingTimeTextIsValidWhenSet() {
        let boardingTime = Date()
        let transport = TransportUpdate(
            childId: SampleDataProvider.shared.sampleChild.id,
            status: .inTransit,
            boardingTime: boardingTime,
            estimatedArrival: nil,
            lastUpdate: Date(),
            currentLocation: "Test",
            driverName: "Test Driver",
            vehicleNumber: "NC-001"
        )
        sut.transportUpdate = transport
        XCTAssertNotEqual(sut.boardingTimeText, "N/A", "Boarding time should be formatted when set")
    }

    // MARK: - Show ETA Flag

    func testShowETAIsFalseWhenNotInTransit() {
        let atNurseryTransport = TransportUpdate(
            childId: SampleDataProvider.shared.sampleChild.id,
            status: .atNursery,
            lastUpdate: Date(),
            currentLocation: "Nursery",
            driverName: "",
            vehicleNumber: ""
        )
        sut.transportUpdate = atNurseryTransport
        XCTAssertFalse(sut.showETA, "showETA should be false when status is atNursery")
    }

    func testShowETAIsTrueWhenInTransit() {
        let inTransitTransport = TransportUpdate(
            childId: SampleDataProvider.shared.sampleChild.id,
            status: .inTransit,
            boardingTime: Date(),
            estimatedArrival: Date().addingTimeInterval(1200),
            lastUpdate: Date(),
            currentLocation: "Main Road",
            driverName: "Test Driver",
            vehicleNumber: "NC-001"
        )
        sut.transportUpdate = inTransitTransport
        XCTAssertTrue(sut.showETA, "showETA should be true when status is inTransit")
    }

    // MARK: - Ineligible Child

    func testTransportViewModelForIneligibleChildHasNilUpdate() {
        let ineligibleChildId = UUID() // Unknown ID — no transport data exists
        let ineligibleVM = TransportViewModel(childId: ineligibleChildId)
        XCTAssertNil(ineligibleVM.transportUpdate, "Unknown child should have nil transport update")
    }

    // MARK: - Refresh

    func testRefreshDoesNotCrash() {
        XCTAssertNoThrow(sut.refresh(), "Calling refresh should not throw")
    }
}
