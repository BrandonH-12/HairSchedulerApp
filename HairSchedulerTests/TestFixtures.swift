//
//  TestFixtures.swift
//  HairScheduler
//
//  Created by Brandon Hua on 13/9/2026.
//

import Foundation
@testable import HairScheduler

/// Shared fixtures for building consistent test dates and sample data.
enum TestFixtures {
    static var calendar: Calendar { Calendar.current }

    /// A fixed "now" used across tests so scheduling logic is deterministic:
    /// a Wednesday at 9:00 AM.
    static func fixedNow() -> Date {
        var components = DateComponents()
        components.year = 2026
        components.month = 9
        components.day = 9 // a Wednesday
        components.hour = 9
        components.minute = 0
        return calendar.date(from: components)!
    }

    static func time(hour: Int, minute: Int = 0, on date: Date = fixedNow()) -> Date {
        calendar.date(bySettingHour: hour, minute: minute, second: 0, of: date)!
    }

    static let cutService = Service(name: "Cut & Style", standardDurationMinutes: 45, bufferMinutesAfter: 10)
    static let colourService = Service(name: "Full Colour", standardDurationMinutes: 120, bufferMinutesAfter: 20)
}
