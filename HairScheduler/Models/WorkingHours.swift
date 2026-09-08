//
//  WorkingHours.swift
//  HairScheduler
//
//  Created by Brandon Hua on 8/9/2026.
//

import Foundation

struct WorkingHours {
    let openingHour: Int
    let closingHour: Int

    static let standard = WorkingHours(openingHour: 9, closingHour: 18)

    /// Returns true if a service starting at `start` and lasting
    /// `serviceDurationMinutes` (including buffer) fits entirely within
    /// working hours on that calendar day.
    func fits(start: Date, serviceDurationMinutes: Int, calendar: Calendar = .current) -> Bool {
        guard
            let opening = calendar.date(bySettingHour: openingHour, minute: 0, second: 0, of: start),
            let closing = calendar.date(bySettingHour: closingHour, minute: 0, second: 0, of: start)
        else {
            return false
        }
        let end = start.addingTimeInterval(TimeInterval(serviceDurationMinutes * 60))
        return start >= opening && end <= closing
    }

    var openingTimeDescription: String { String(format: "%02d:00", openingHour) }
    var closingTimeDescription: String { String(format: "%02d:00", closingHour) }
}
