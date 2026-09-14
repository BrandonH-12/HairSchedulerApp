//
//  BookingSource.swift
//  HairScheduler
//
//  Created by Brandon Hua on 8/9/2026.
//

import Foundation

/// How a booking first entered the schedule.
///
/// Business Rule: a walk-in or a friend dropping by arrives with zero prior
/// notice — neither was ever written into any calendar before this exact
/// moment, which is precisely what a paper diary can't check against and
/// this app exists to catch.

enum BookingSource: String, CaseIterable, Identifiable {
    case walkIn = "Walk-in"
    case phoneCall = "Phone Booking"
    case referredByFriend = "Friend / Word of Mouth"

    var id: String { rawValue }
}


