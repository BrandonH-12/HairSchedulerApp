//
//  AppointmentOutcome.swift
//  HairScheduler
//
//  Created by Brandon Hua on 8/9/2026.
//

import Foundation


/// What actually happened to a booked appointment, recorded after the fact.
///
/// Business Rule: completed, noShow, and cancelled are three distinct,
/// unranked outcomes, not one generic "ended" state. Many independent,
/// relationship-based stylists don't charge cancellation fees, but the
/// difference between a client who gave notice and one who didn't is still
/// worth remembering — a pattern a paper diary could never preserve.

enum AppointmentOutcome: String, CaseIterable {
    case completed = "Completed"
    case noShow = "No-Show"
    case cancelled = "Cancelled"
}



