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
    
    /// Returns a repository pre-loaded with a mix of past, today, and
    /// upcoming appointments — as if the hairdresser had already been using
    /// the app for a week.
    ///
    /// This bypasses ScheduleAppointmentUseCase deliberately: that Use Case's
    /// whole job is refusing to book anything in the past, but seed data
    /// representing appointments that have already happened is allowed to
    /// start life already-past, the same way a real week of use would leave
    /// the schedule in this state.
    static func seeded() -> InMemoryAppointmentRepository {
        let repository = InMemoryAppointmentRepository()
        let calendar = Calendar.current
        let now = Date()

        func time(daysAgo: Int, hour: Int) -> Date {
            let day = calendar.date(byAdding: .day, value: -daysAgo, to: now)!
            return calendar.date(bySettingHour: hour, minute: 0, second: 0, of: day)!
        }

        var completedYesterday = Appointment(
            client: Client(name: "Mei", phoneNumber: "0412 345 678"),
            service: Service.sampleServices[0],
            scheduledAt: time(daysAgo: 1, hour: 11),
            bookingSource: .phoneCall
        )
        completedYesterday.outcome = .completed
        repository.save(completedYesterday)

        var noShowThreeDaysAgo = Appointment(
            client: Client(name: "Jordan"),
            service: Service.sampleServices[1],
            scheduledAt: time(daysAgo: 3, hour: 14),
            bookingSource: .walkIn
        )
        noShowThreeDaysAgo.outcome = .noShow
        repository.save(noShowThreeDaysAgo)

        var cancelledFiveDaysAgo = Appointment(
            client: Client(name: "Linh"),
            service: Service.sampleServices[2],
            scheduledAt: time(daysAgo: 5, hour: 10),
            bookingSource: .referredByFriend
        )
        cancelledFiveDaysAgo.outcome = .cancelled
        cancelledFiveDaysAgo.cancelledAt = time(daysAgo: 6, hour: 9)
        repository.save(cancelledFiveDaysAgo)

        // An appointment 1 hour before right now, with no outcome recorded
        // yet, so Mark Completed / Mark No-Show can be tested immediately
        // regardless of what time the app happens to be opened.
        let earlierToday = Appointment(
            client: Client(name: "Grace", phoneNumber: "0423 456 789"),
            service: Service.sampleServices[0],
            scheduledAt: now.addingTimeInterval(-3600),
            bookingSource: .walkIn
        )
        repository.save(earlierToday)

        return repository
    }
}
