//
//  RescheduleAppointmentUseCase.swift
//  HairScheduler
//
//  Created by Brandon Hua on 13/9/2026.
//

import Foundation

enum RescheduleAppointmentError: LocalizedError, Equatable {
    case appointmentNotFound
    case outcomeAlreadyRecorded(existing: AppointmentOutcome)
    case newTimeInThePast
    case outsideWorkingHours(opening: String, closing: String)
    case timeSlotUnavailable(conflictingClientName: String)

    var errorDescription: String? {
        switch self {
        case .appointmentNotFound:
            return "Couldn't find that appointment. It may have already been removed."
        case .outcomeAlreadyRecorded(let existing):
            return "This appointment is already marked as \(existing.rawValue.lowercased()) and can't be moved."
        case .newTimeInThePast:
            return "This time has already passed. Choose a time later than right now."
        case .outsideWorkingHours(let opening, let closing):
            return "This booking doesn't fit within working hours (\(opening)–\(closing)). Choose an earlier time or shorten the service."
        case .timeSlotUnavailable(let conflictingClientName):
            return "This time clashes with \(conflictingClientName)'s appointment. Choose a different time, or check if that booking can move instead."
        }
    }
}

/// Moves an existing, still-open appointment to a new time, enforcing the
/// same scheduling rules as a fresh booking.
///
/// Business Rule: rescheduling reuses the clash and working-hours checks
/// from booking, but excludes the appointment's own current slot from the
/// clash check. An appointment that's already cancelled, completed, or
/// marked a no-show is a closed record and can't be moved.
struct RescheduleAppointmentUseCase {
    let repository: AppointmentRepository
    let workingHours: WorkingHours

    init(repository: AppointmentRepository, workingHours: WorkingHours = .standard) {
        self.repository = repository
        self.workingHours = workingHours
    }

    @discardableResult
    func execute(
        appointmentID: UUID,
        newScheduledAt: Date,
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> Result<Appointment, RescheduleAppointmentError> {
        guard let appointment = repository.appointment(withID: appointmentID) else {
            return .failure(.appointmentNotFound)
        }

        guard appointment.outcome == nil else {
            return .failure(.outcomeAlreadyRecorded(existing: appointment.outcome!))
        }

        guard newScheduledAt > now else {
            return .failure(.newTimeInThePast)
        }

        guard workingHours.fits(start: newScheduledAt, serviceDurationMinutes: appointment.service.totalBlockMinutes, calendar: calendar) else {
            return .failure(.outsideWorkingHours(opening: workingHours.openingTimeDescription, closing: workingHours.closingTimeDescription))
        }

        let candidate = appointment.rescheduled(to: newScheduledAt)

        let sameDayAppointments = repository.appointments(overlapping: newScheduledAt, calendar: calendar)
            .filter { $0.id != appointment.id }
        if let conflict = sameDayAppointments.first(where: { $0.overlaps(with: candidate) }) {
            return .failure(.timeSlotUnavailable(conflictingClientName: conflict.client.name))
        }

        repository.update(candidate)
        return .success(candidate)
    }
}
