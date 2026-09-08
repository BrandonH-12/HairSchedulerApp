//
//  Service.swift
//  HairScheduler
//
//  Created by Brandon Hua on 8/9/2026.
//
import Foundation

struct Service: Identifiable, Hashable {
    let id: UUID
    let name: String
    let standardDurationMinutes: Int
    let bufferMinutesAfter: Int
    
    init(id: UUID = UUID(), name: String, standardDurationMinutes: Int, bufferMinutesAfter: Int) {
        self.id = id
        self.name = name
        self.standardDurationMinutes = standardDurationMinutes
        self.bufferMinutesAfter = bufferMinutesAfter
    }

    /// Total time this service occupies in the schedule, including cleanup buffer.
    var totalBlockMinutes: Int {
        standardDurationMinutes + bufferMinutesAfter
    }

    static let sampleServices: [Service] = [
        Service(name: "Cut & Style", standardDurationMinutes: 45, bufferMinutesAfter: 10),
        Service(name: "Full Colour", standardDurationMinutes: 120, bufferMinutesAfter: 20),
        Service(name: "Colour Touch-Up", standardDurationMinutes: 60, bufferMinutesAfter: 15),
        Service(name: "Blow-Dry", standardDurationMinutes: 30, bufferMinutesAfter: 5)
    ]
}
