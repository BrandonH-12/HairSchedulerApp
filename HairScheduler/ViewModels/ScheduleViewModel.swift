//
//  ScheduleViewModel.swift
//  HairScheduler
//
//  Created by Brandon Hua on 9/9/2026.
//

import Foundation
import SwiftUI
import Combine

/// Drives all schedule-related screens. Owns the shared repository and
/// exposes the Use Cases as simple, view-friendly methods, translating
/// their typed errors into a message the UI can display directly.
@MainActor
final class ScheduleViewModel: ObservableObject {
    @Published private(set) var appointments: [Appointment] = []
    @Published var errorMessage: String?

    private let repository: AppointmentRepository
    private let scheduleAppointmentUseCase: ScheduleAppointmentUseCase
    private let cancelAppointmentUseCase: CancelAppointmentUseCase
    private let recordOutcomeUseCase: RecordAppointmentOutcomeUseCase

    let availableServices = Service.sampleServices

    init(repository: AppointmentRepository? = nil) {
        self.repository = repository ?? InMemoryAppointmentRepository()
        self.scheduleAppointmentUseCase = ScheduleAppointmentUseCase(repository: self.repository)
        self.cancelAppointmentUseCase = CancelAppointmentUseCase(repository: self.repository)
        self.recordOutcomeUseCase = RecordAppointmentOutcomeUseCase(repository: self.repository)
        refresh()
    }

    func refresh() {
        appointments = repository.allAppointments()
    }

    var todaysAppointments: [Appointment] {
        appointments.filter { Calendar.current.isDateInToday($0.scheduledAt) }
    }

    var pastAppointments: [Appointment] {
        appointments.filter { $0.outcome != nil }
    }

    /// Appointments scheduled after today but within the next 7 days.
    /// Business Rule: a cancelled appointment no longer occupies a real
    /// slot in the schedule, so it's excluded here the same way it's
    /// excluded from clash-checking in ScheduleAppointmentUseCase.
    var upcomingAppointments: [Appointment] {
        let calendar = Calendar.current
        let now = Date()
        guard let weekFromNow = calendar.date(byAdding: .day, value: 7, to: now) else { return [] }
        return appointments.filter {
            !calendar.isDateInToday($0.scheduledAt) &&
            $0.scheduledAt > now &&
            $0.scheduledAt <= weekFromNow &&
            $0.outcome != .cancelled
        }.sorted { $0.scheduledAt < $1.scheduledAt }
    }

    func scheduleAppointment(clientName: String, phoneNumber: String?, service: Service, scheduledAt: Date, source: BookingSource) {
        let client = Client(name: clientName, phoneNumber: phoneNumber)
        let result = scheduleAppointmentUseCase.execute(client: client, service: service, scheduledAt: scheduledAt, bookingSource: source)
        switch result {
        case .success:
            errorMessage = nil
            refresh()
        case .failure(let error):
            errorMessage = error.errorDescription
        }
    }

    func cancelAppointment(_ appointment: Appointment) {
        let result = cancelAppointmentUseCase.execute(appointmentID: appointment.id)
        switch result {
        case .success:
            errorMessage = nil
            refresh()
        case .failure(let error):
            errorMessage = error.errorDescription
        }
    }

    func recordOutcome(_ appointment: Appointment, outcome: AppointmentOutcome) {
        let result = recordOutcomeUseCase.execute(appointmentID: appointment.id, outcome: outcome)
        switch result {
        case .success:
            errorMessage = nil
            refresh()
        case .failure(let error):
            errorMessage = error.errorDescription
        }
    }
}

