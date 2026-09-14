//
//  RecordAppointmentOutcomeUseCase.swift
//  HairScheduler
//
//  Created by Brandon Hua on 9/9/2026.
//

import Foundation


/// Errors that can occur when recording how a past appointment actually went.
///
/// Who encounters this: the hairdresser, at the end of the day or the next
/// time she opens the app, when she's going back through what happened —
/// not in the moment of booking.

enum RecordAppointmentOutcomeError: LocalizedError, Equatable {
    case appointmentNotFound
    case cannotRecordBeforeAppointmentTime
    case outcomeAlreadyRecorded(existing: AppointmentOutcome)
    case invalidOutcomeForThisUseCase

    var errorDescription: String? {
        switch self {
        case .appointmentNotFound:
            return "Couldn't find that appointment. It may have already been removed."
        case .cannotRecordBeforeAppointmentTime:
            return "This appointment hasn't happened yet, so it can't be marked completed or no-show."
        case .outcomeAlreadyRecorded(let existing):
            return "This appointment is already marked as \(existing.rawValue.lowercased())."
        case .invalidOutcomeForThisUseCase:
            return "Use the cancel option to cancel a booking — this action is only for marking a past appointment as completed or a no-show."
        }
    }
}

/// Records what actually happened to a past appointment --> completed or
/// a no-show.
///
/// Business Rule: an outcome can't be recorded before the appointment's
/// scheduled time has actually passed — the hairdresser can't mark someone
/// a no-show for an appointment that hasn't happened yet.

struct RecordAppointmentOutcomeUseCase {
    let repository: AppointmentRepository

    @discardableResult
    func execute(
        appointmentID: UUID,
        outcome: AppointmentOutcome,
        now: Date = Date()
    ) -> Result<Appointment, RecordAppointmentOutcomeError> {
        guard outcome == .completed || outcome == .noShow else {
            return .failure(.invalidOutcomeForThisUseCase)
        }

        guard var appointment = repository.appointment(withID: appointmentID) else {
            return .failure(.appointmentNotFound)
        }

        guard appointment.outcome == nil else {
            return .failure(.outcomeAlreadyRecorded(existing: appointment.outcome!))
        }

        guard now >= appointment.scheduledAt else {
            return .failure(.cannotRecordBeforeAppointmentTime)
        }

        appointment.outcome = outcome
        repository.update(appointment)
        return .success(appointment)
    }
}
