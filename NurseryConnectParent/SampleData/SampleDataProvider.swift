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
    
    // MARK: - Sample Incident Reports

    lazy var sampleIncidentReports: [IncidentReport] = {
        let childId = sampleChild.id
        let childName = sampleChild.name
        let calendar = Calendar.current
        let now = Date()

        return [
            // 1 — Serious, unacknowledged (today — most urgent)
            IncidentReport(
                childId: childId,
                childName: childName,
                title: "Allergic Reaction to Snack",
                category: .allergy,
                severity: .serious,
                date: calendar.date(byAdding: .hour, value: -3, to: now)!,
                location: "Rainbow Room — Snack Area",
                incidentDescription: "Emily showed signs of an allergic reaction approximately 10 minutes after consuming an oat biscuit. Symptoms included facial flushing and mild hives on the forearms. No anaphylaxis observed.",
                immediateActionTaken: "Removed offending food immediately. Administered prescribed antihistamine from Emily's medical bag. Placed in recovery position and monitored continuously. NHS 111 called for advice — advised to monitor for 2 hours and attend A&E if symptoms worsen.",
                witnesses: "Sarah Miller, James Wilson",
                affectedBodyArea: "Face, Forearms",
                managerApproved: true,
                managerName: "Helen Carter",
                parentAcknowledged: false
            ),

            // 2 — Minor, unacknowledged (yesterday)
            IncidentReport(
                childId: childId,
                childName: childName,
                title: "Minor Trip in Outdoor Area",
                category: .fall,
                severity: .minor,
                date: calendar.date(byAdding: .day, value: -1, to: now)!,
                location: "Outdoor Play Area",
                incidentDescription: "Emily tripped over the edge of the sandpit border while running towards the climbing frame. She fell forward onto the grass surface.",
                immediateActionTaken: "Checked for injuries — small graze to left knee. Area cleaned with antiseptic wipe and covered with a plaster. Emily was comforted and returned to play within 5 minutes.",
                witnesses: "Emma Davis",
                affectedBodyArea: "Left Knee",
                managerApproved: true,
                managerName: "Helen Carter",
                parentAcknowledged: false
            ),

            // 3 — Moderate, already acknowledged (last week)
            IncidentReport(
                id: UUID(),
                childId: childId,
                childName: childName,
                title: "Behaviour Incident — Biting",
                category: .behaviour,
                severity: .moderate,
                date: calendar.date(byAdding: .day, value: -7, to: now)!,
                location: "Rainbow Room",
                incidentDescription: "During free play, Emily bit another child on the arm after a dispute over a toy. The affected child was immediately comforted and the bite mark was assessed — skin not broken.",
                immediateActionTaken: "Both children separated calmly. Affected child's arm cleaned and monitored. Emily given age-appropriate explanation of why biting is not acceptable. Incident logged and both sets of parents notified.",
                witnesses: "Sarah Miller",
                affectedBodyArea: "N/A (perpetrating child)",
                managerApproved: true,
                managerName: "Helen Carter",
                parentAcknowledged: true,
                acknowledgementDate: calendar.date(byAdding: .day, value: -6, to: now)!,
                signatureData: nil  // Signature was collected on paper for this historical record
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

    func getIncidentReports(for childId: UUID) -> [IncidentReport] {
        sampleIncidentReports.filter { $0.childId == childId }
    }

    func getPendingIncidentCount(for childId: UUID) -> Int {
        getIncidentReports(for: childId).pendingCount
    }
}
