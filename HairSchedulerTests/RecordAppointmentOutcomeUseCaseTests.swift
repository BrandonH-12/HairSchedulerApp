//
//  RecordAppointmentOutcomeUseCaseTests.swift
//  HairScheduler
//
//  Created by Brandon Hua on 13/9/2026.
//

import Testing
import Foundation
@testable import HairScheduler

@MainActor
@Suite("RecordAppointmentOutcomeUseCase")
struct RecordAppointmentOutcomeUseCaseTests {

    let repository = InMemoryAppointmentRepository()
    var recordUseCase: RecordAppointmentOutcomeUseCase {
        RecordAppointmentOutcomeUseCase(repository: repository)
    }

    @Test
    func recordOutcome_succeeds_asNoShow_afterAppointmentTime() {
        let pastSlot = TestFixtures.time(hour: 8) // before fixedNow (9:00)
        let appointment = Appointment(client: Client(name: "Grace"), service: TestFixtures.cutService, scheduledAt: pastSlot, bookingSource: .walkIn)
        repository.save(appointment)

        let result = recordUseCase.execute(appointmentID: appointment.id, outcome: .noShow, now: TestFixtures.fixedNow())

        guard case .success(let updated) = result else {
            Issue.record("Expected recording no-show to succeed")
            return
        }
        #expect(updated.outcome == .noShow)
    }

    @Test
    func recordOutcome_succeeds_asCompleted_afterAppointmentTime() {
        let pastSlot = TestFixtures.time(hour: 8)
        let appointment = Appointment(client: Client(name: "Grace"), service: TestFixtures.cutService, scheduledAt: pastSlot, bookingSource: .walkIn)
        repository.save(appointment)

        let result = recordUseCase.execute(appointmentID: appointment.id, outcome: .completed, now: TestFixtures.fixedNow())

        guard case .success(let updated) = result else {
            Issue.record("Expected recording completed to succeed")
            return
        }
        #expect(updated.outcome == .completed)
    }

    @Test
    func recordOutcome_fails_whenRecordedBeforeAppointmentTime() {
        let futureSlot = TestFixtures.time(hour: 15)
        let appointment = Appointment(client: Client(name: "Grace"), service: TestFixtures.cutService, scheduledAt: futureSlot, bookingSource: .walkIn)
        repository.save(appointment)

        let result = recordUseCase.execute(appointmentID: appointment.id, outcome: .noShow, now: TestFixtures.fixedNow())

        guard case .failure(let error) = result else {
            Issue.record("Expected cannotRecordBeforeAppointmentTime failure")
            return
        }
        #expect(error == .cannotRecordBeforeAppointmentTime)
    }

    @Test
    func recordOutcome_fails_whenOutcomeAlreadyRecorded() {
        let pastSlot = TestFixtures.time(hour: 8)
        var appointment = Appointment(client: Client(name: "Grace"), service: TestFixtures.cutService, scheduledAt: pastSlot, bookingSource: .walkIn)
        appointment.outcome = .completed
        repository.save(appointment)

        let result = recordUseCase.execute(appointmentID: appointment.id, outcome: .noShow, now: TestFixtures.fixedNow())

        guard case .failure(let error) = result else {
            Issue.record("Expected outcomeAlreadyRecorded failure")
            return
        }
        #expect(error == .outcomeAlreadyRecorded(existing: .completed))
    }

    @Test
    func recordOutcome_fails_whenAppointmentNotFound() {
        let result = recordUseCase.execute(appointmentID: UUID(), outcome: .completed, now: TestFixtures.fixedNow())

        guard case .failure(let error) = result else {
            Issue.record("Expected appointmentNotFound failure")
            return
        }
        #expect(error == .appointmentNotFound)
    }
}
