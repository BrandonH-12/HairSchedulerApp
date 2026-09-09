//
//  ScheduleAppointmentUseCase.swift
//  HairScheduler
//
//  Created by Brandon Hua on 9/9/2026.
//

import Foundation

enum ScheduleAppointmentError: LocalizedError, Equatable {
    case appointmentInThePast
    case outsideWorkingHours(opening: String, closing: String)
    case timeSlotUnavailable(conflictingClientName: String)

    var errorDescription: String? {
        switch self {
        case .appointmentInThePast:
            return "This time has already passed. Choose a time later than right now."
        case .outsideWorkingHours(let opening, let closing):
            return "This booking doesn't fit within working hours (\(opening)–\(closing)). Choose an earlier time or shorten the service."
        case .timeSlotUnavailable(let conflictingClientName):
            return "This time clashes with \(conflictingClientName)'s appointment. Choose a different time, or check if that booking can move."
        }
    }
}

struct ScheduleAppointmentUseCase {
    let repository: AppointmentRepository
    let workingHours: WorkingHours

    init(repository: AppointmentRepository, workingHours: WorkingHours = .standard) {
        self.repository = repository
        self.workingHours = workingHours
    }

    @discardableResult
    func execute(
        client: Client,
        service: Service,
        scheduledAt: Date,
        bookingSource: BookingSource,
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> Result<Appointment, ScheduleAppointmentError> {
        guard scheduledAt > now else {
            return .failure(.appointmentInThePast)
        }

        guard workingHours.fits(start: scheduledAt, serviceDurationMinutes: service.totalBlockMinutes, calendar: calendar) else {
            return .failure(.outsideWorkingHours(opening: workingHours.openingTimeDescription, closing: workingHours.closingTimeDescription))
        }

        let candidate = Appointment(
            client: client,
            service: service,
            scheduledAt: scheduledAt,
            bookingSource: bookingSource,
            recordedAt: now
        )

        let sameDayAppointments = repository.appointments(overlapping: scheduledAt, calendar: calendar)
        if let conflict = sameDayAppointments.first(where: { $0.overlaps(with: candidate) }) {
            return .failure(.timeSlotUnavailable(conflictingClientName: conflict.client.name))
        }

        repository.save(candidate)
        return .success(candidate)
    }
}
