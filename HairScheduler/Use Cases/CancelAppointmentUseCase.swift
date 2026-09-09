//
//  CancelAppointmentUseCase.swift
//  HairScheduler
//
//  Created by Brandon Hua on 9/9/2026.
//

import Foundation

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
