//
//  CancelAppointmentUseCase.swift
//  HairScheduler
//
//  Created by Brandon Hua on 9/9/2026.
//

import Foundation

/// Errors that can occur when cancelling an appointment.
///
/// Who encounters this: the hairdresser, when a client calls or messages to
/// say they can't make it.

enum CancelAppointmentError: LocalizedError, Equatable {
    case appointmentNotFound
    case outcomeAlreadyRecorded (existing: AppointmentOutcome)
    
    var errorDescription: String? {
        switch self {
        case .appointmentNotFound:
            return "Couldn't find that appointment. It may have already been removed."
        case .outcomeAlreadyRecorded(let existing):
            return "This appointment is already marked as \(existing.rawValue.lowercased()) and can't be cancelled."
        }
    }
}

/// Cancels an upcoming appointment, freeing its slot for a new booking.
///
/// Business Rule: cancelling is distinct from recording a no-show, even
/// though no fee applies to either. A cancellation means the client gave
/// notice, a no-show means they didn't, and the difference is a pattern
/// worth preserving even without a fee attached to it.

struct CancelAppointmentUseCase {
    let repository: AppointmentRepository

    @discardableResult
    func execute(appointmentID: UUID, now: Date = Date()) -> Result<Appointment, CancelAppointmentError> {
        guard var appointment = repository.appointment(withID: appointmentID) else {
            return .failure(.appointmentNotFound)
        }

        guard appointment.outcome == nil else {
            return .failure(.outcomeAlreadyRecorded(existing: appointment.outcome!))
        }

        appointment.outcome = .cancelled
        appointment.cancelledAt = now
        repository.update(appointment)
        return .success(appointment)
    }
}
