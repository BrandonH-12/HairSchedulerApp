//
//  CancelAppointmentUseCaseTests.swift
//  HairScheduler
//
//  Created by Brandon Hua on 13/9/2026.
//

import Testing
import Foundation
@testable import HairScheduler

@MainActor
@Suite("CancelAppointmentUseCase")
struct CancelAppointmentUseCaseTests {

    let repository = InMemoryAppointmentRepository()
    var cancelUseCase: CancelAppointmentUseCase {
        CancelAppointmentUseCase(repository: repository)
    }

    @Test
    func cancelAppointment_succeeds_forUpcomingAppointment() {
        let appointment = Appointment(client: Client(name: "Mei"), service: TestFixtures.cutService, scheduledAt: TestFixtures.time(hour: 14), bookingSource: .walkIn)
        repository.save(appointment)

        let result = cancelUseCase.execute(appointmentID: appointment.id, now: TestFixtures.fixedNow())

        guard case .success(let cancelled) = result else {
            Issue.record("Expected cancellation to succeed")
            return
        }
        #expect(cancelled.outcome == .cancelled)
        #expect(cancelled.cancelledAt != nil)
    }

    @Test
    func cancelAppointment_fails_whenAppointmentNotFound() {
        let result = cancelUseCase.execute(appointmentID: UUID(), now: TestFixtures.fixedNow())

        guard case .failure(let error) = result else {
            Issue.record("Expected appointmentNotFound failure")
            return
        }
        #expect(error == .appointmentNotFound)
    }

    @Test
    func cancelAppointment_fails_whenOutcomeAlreadyRecorded() {
        var appointment = Appointment(client: Client(name: "Mei"), service: TestFixtures.cutService, scheduledAt: TestFixtures.time(hour: 8, on: TestFixtures.fixedNow().addingTimeInterval(-86400)), bookingSource: .walkIn)
        appointment.outcome = .completed
        repository.save(appointment)

        let result = cancelUseCase.execute(appointmentID: appointment.id, now: TestFixtures.fixedNow())

        guard case .failure(let error) = result else {
            Issue.record("Expected outcomeAlreadyRecorded failure")
            return
        }
        #expect(error == .outcomeAlreadyRecorded(existing: .completed))
    }

    @Test
    func cancelAppointment_leavesScheduleFreeForNewBooking() {
        // Cancelling a slot should free it up for a new, otherwise-overlapping booking.
        let scheduleUseCase = ScheduleAppointmentUseCase(repository: repository)
        let now = TestFixtures.fixedNow()
        let slot = TestFixtures.time(hour: 11)

        let firstResult = scheduleUseCase.execute(client: Client(name: "Linh"), service: TestFixtures.cutService, scheduledAt: slot, bookingSource: .phoneCall, now: now)
        guard case .success(let firstAppointment) = firstResult else {
            Issue.record("Setup failed: could not create initial appointment")
            return
        }

        _ = cancelUseCase.execute(appointmentID: firstAppointment.id, now: now)

        let secondResult = scheduleUseCase.execute(client: Client(name: "Grace"), service: TestFixtures.cutService, scheduledAt: slot, bookingSource: .walkIn, now: now)
        guard case .success = secondResult else {
            Issue.record("Expected the freed slot to accept a new booking")
            return
        }
    }
}
