//
//  Child.swift
//  NurseryConnectParent
//
//  Created on April 18, 2026
//

import Foundation
import SwiftData

@Model
final class Child {
    var id: UUID
    var name: String
    var age: Int
    var room: String
    var allergies: String
    var photoName: String
    var isTransportEligible: Bool
    var emergencyContact: String
    
    init(
        id: UUID = UUID(),
        name: String,
        age: Int,
        room: String,
        allergies: String = "None",
        photoName: String = "person.circle.fill",
        isTransportEligible: Bool = false,
        emergencyContact: String = ""
    ) {
        self.id = id
        self.name = name
        self.age = age
        self.room = room
        self.allergies = allergies
        self.photoName = photoName
        self.isTransportEligible = isTransportEligible
        self.emergencyContact = emergencyContact
    }
}
