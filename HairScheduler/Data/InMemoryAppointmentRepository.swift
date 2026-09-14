//
//  InMemoryAppointmentRepository.swift
//  HairScheduler
//
//  Created by Brandon Hua on 8/9/2026.
//

import Foundation

/// Stores today's bookings in memory for the lifetime of the app.
///
/// This is a `class`, not a `struct`, because the schedule is genuinely
/// shared, mutable state — every screen that reads or writes an appointment
/// needs to be looking at the same underlying diary, not a copy of it.

final class InMemoryAppointmentRepository: AppointmentRepository {
    private var appointments: [UUID: Appointment] = [:]

    func allAppointments() -> [Appointment] {
        Array(appointments.values).sorted { $0.scheduledAt < $1.scheduledAt }
    }

    func appointments(overlapping day: Date, calendar: Calendar = .current) -> [Appointment] {
        appointments.values.filter {
            calendar.isDate($0.scheduledAt, inSameDayAs: day)
        }.sorted { $0.scheduledAt < $1.scheduledAt }
    }

    func appointment(withID id: UUID) -> Appointment? {
        appointments[id]
    }

    func save(_ appointment: Appointment) {
        appointments[appointment.id] = appointment
    }

    func update(_ appointment: Appointment) {
        appointments[appointment.id] = appointment
    }
}
