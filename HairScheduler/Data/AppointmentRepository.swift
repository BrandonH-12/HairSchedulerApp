//
//  AppointmentRepository.swift
//  HairScheduler
//
//  Created by Brandon Hua on 8/9/2026.
//
import Foundation

/// Abstracts where appointments are stored, so every Use Case depends only
/// on this protocol and never on a specific storage implementation.

protocol AppointmentRepository {
    func allAppointments() -> [Appointment]
    func appointments(overlapping day: Date, calendar: Calendar) -> [Appointment]
    func appointment(withID id: UUID) -> Appointment?
    func save(_ appointment: Appointment)
    func update(_ appointment: Appointment)
}
