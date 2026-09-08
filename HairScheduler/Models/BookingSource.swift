//
//  BookingSource.swift
//  HairScheduler
//
//  Created by Brandon Hua on 8/9/2026.
//

import Foundation

enum BookingSource: String, CaseIterable, Identifiable {
    case walkIn = "Walk-in"
    case phoneCall = "Phone Booking"
    case referredByFriend = "Friend / Word of Mouth"

    var id: String { rawValue }
}


