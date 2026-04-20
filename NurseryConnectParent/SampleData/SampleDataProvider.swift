//
//  SampleDataProvider.swift
//  NurseryConnectParent
//
//  Created on April 18, 2026
//

import Foundation

class SampleDataProvider {
    static let shared = SampleDataProvider()
    
    private init() {}
    
    // MARK: - Sample Child
    
    let sampleChild = Child(
        id: UUID(uuidString: "A1B2C3D4-E5F6-7890-ABCD-EF1234567890")!,
        name: "Emily Johnson",
        age: 3,
        room: "Rainbow Room",
        allergies: "Peanuts, Dairy",
        photoName: "person.circle.fill",
        isTransportEligible: true,
        emergencyContact: "+44 7700 900123"
    )
    
    // MARK: - Sample Diary Entries
    
    lazy var sampleDiaryEntries: [DiaryEntry] = {
        let childId = sampleChild.id
        let calendar = Calendar.current
        let now = Date()
        
        return [
            DiaryEntry(
                childId: childId,
                type: .meal,
                timestamp: calendar.date(byAdding: .hour, value: -2, to: now)!,
                title: "Lunch Time",
                details: "Enjoyed chicken nuggets, carrots, and apple slices. Ate most of the meal!",
                notes: "Great appetite today. Drank plenty of water.",
                staffName: "Sarah Miller"
            ),
            DiaryEntry(
                childId: childId,
                type: .nap,
                timestamp: calendar.date(byAdding: .hour, value: -4, to: now)!,
                title: "Afternoon Nap",
                details: "Napped for 1 hour and 30 minutes.",
                notes: "Settled quickly and slept peacefully.",
                staffName: "James Wilson"
            ),
            DiaryEntry(
                childId: childId,
                type: .activity,
                timestamp: calendar.date(byAdding: .hour, value: -6, to: now)!,
                title: "Outdoor Play",
                details: "Played in the garden with friends. Used the climbing frame and enjoyed the sandbox.",
                notes: "Very active and engaged. Great social interaction.",
                staffName: "Emma Davis"
            ),
            DiaryEntry(
                childId: childId,
                type: .mood,
                timestamp: calendar.date(byAdding: .hour, value: -1, to: now)!,
                title: "Happy & Energetic",
                details: "Emily has been in a wonderful mood all afternoon!",
                notes: "Lots of smiles and laughter during activities.",
                staffName: "Sarah Miller"
            ),
            DiaryEntry(
                childId: childId,
                type: .milestone,
                timestamp: calendar.date(byAdding: .hour, value: -3, to: now)!,
                title: "Learning Progress",
                details: "Successfully counted to 10 during circle time!",
                notes: "Showing great progress with numbers.",
                staffName: "James Wilson"
            ),
            DiaryEntry(
                childId: childId,
                type: .meal,
                timestamp: calendar.date(byAdding: .hour, value: -8, to: now)!,
                title: "Breakfast",
                details: "Had porridge with banana and a glass of milk.",
                notes: "Finished everything on the plate.",
                staffName: "Emma Davis"
            )
        ]
    }()
    
    // MARK: - Sample Transport Updates
    
    lazy var sampleTransportUpdate: TransportUpdate = {
        let childId = sampleChild.id
        let calendar = Calendar.current
        let now = Date()
        
        return TransportUpdate(
            childId: childId,
            status: .inTransit,
            boardingTime: calendar.date(byAdding: .minute, value: -15, to: now),
            estimatedArrival: calendar.date(byAdding: .minute, value: 20, to: now),
            lastUpdate: calendar.date(byAdding: .minute, value: -2, to: now)!,
            currentLocation: "Main Street, approaching junction",
            driverName: "Michael Brown",
            vehicleNumber: "NCN-001"
        )
    }()
    
    lazy var sampleTransportAtNursery: TransportUpdate = {
        let childId = sampleChild.id
        
        return TransportUpdate(
            childId: childId,
            status: .atNursery,
            boardingTime: nil,
            estimatedArrival: nil,
            lastUpdate: Date(),
            currentLocation: "NurseryConnect Facility",
            driverName: "",
            vehicleNumber: ""
        )
    }()
    
    // MARK: - Sample Notifications
    
    lazy var sampleNotifications: [NotificationItem] = {
        let childId = sampleChild.id
        let calendar = Calendar.current
        let now = Date()
        
        return [
            NotificationItem(
                type: .diary,
                title: "New Diary Entry",
                message: "Emily had a great lunch today!",
                timestamp: calendar.date(byAdding: .hour, value: -2, to: now)!,
                isRead: false,
                childId: childId
            ),
            NotificationItem(
                type: .transport,
                title: "Transport Update",
                message: "Emily is now on the bus, ETA 20 minutes.",
                timestamp: calendar.date(byAdding: .minute, value: -15, to: now)!,
                isRead: false,
                childId: childId
            ),
            NotificationItem(
                type: .announcement,
                title: "Nursery Closed",
                message: "The nursery will be closed on Friday, April 25th for staff training.",
                timestamp: calendar.date(byAdding: .hour, value: -24, to: now)!,
                isRead: true,
                childId: nil
            ),
            NotificationItem(
                type: .reminder,
                title: "Bring Spare Clothes",
                message: "Please remember to bring a spare set of clothes for Emily tomorrow.",
                timestamp: calendar.date(byAdding: .hour, value: -48, to: now)!,
                isRead: true,
                childId: childId
            ),
            NotificationItem(
                type: .alert,
                title: "Allergy Alert",
                message: "We're serving a meal that may contain traces of nuts tomorrow. Alternative meal available.",
                timestamp: calendar.date(byAdding: .hour, value: -5, to: now)!,
                isRead: false,
                childId: childId
            )
        ]
    }()
    
    // MARK: - Helper Methods
    
    func getDiaryEntries(for childId: UUID) -> [DiaryEntry] {
        sampleDiaryEntries.filter { $0.childId == childId }
    }
    
    func getTransportUpdate(for childId: UUID) -> TransportUpdate? {
        childId == sampleChild.id ? sampleTransportUpdate : nil
    }
    
    func getNotifications(for childId: UUID?) -> [NotificationItem] {
        if let childId = childId {
            return sampleNotifications.filter { $0.childId == childId }
        }
        return sampleNotifications
    }
    
    func getUnreadNotificationCount() -> Int {
        sampleNotifications.filter { !$0.isRead }.count
    }
}
