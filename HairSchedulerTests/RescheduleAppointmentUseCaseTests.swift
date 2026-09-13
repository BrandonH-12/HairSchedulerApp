//
//  RescheduleAppointmentUseCaseTests.swift
//  HairScheduler
//
//  Created by Brandon Hua on 13/9/2026.
//

import Testing
import Foundation
@testable import HairScheduler

@MainActor
@Suite("RescheduleAppointmentUseCase")
struct RescheduleAppointmentUseCaseTests {

    let repository = InMemoryAppointmentRepository()
    var rescheduleUseCase: RescheduleAppointmentUseCase {
        RescheduleAppointmentUseCase(repository: repository)
    }
    var scheduleUseCase: ScheduleAppointmentUseCase {
        ScheduleAppointmentUseCase(repository: repository)
    }

    @Test
    func rescheduleAppointment_succeeds_toFreeSlot_keepingSameClientAndID() {
        let now = TestFixtures.fixedNow()
        let original = scheduleUseCase.execute(client: Client(name: "Mei"), service: TestFixtures.cutService, scheduledAt: TestFixtures.time(hour: 10, on: now), bookingSource: .walkIn, now: now)
        guard case .success(let appointment) = original else {
            Issue.record("Setup failed: could not create initial appointment")
            return
        }

        let newTime = TestFixtures.time(hour: 15, on: now)
        let result = rescheduleUseCase.execute(appointmentID: appointment.id, newScheduledAt: newTime, now: now)

        guard case .success(let moved) = result else {
            Issue.record("Expected reschedule to succeed")
            return
        }
        #expect(moved.id == appointment.id)
        #expect(moved.client.name == "Mei")
        #expect(moved.scheduledAt == newTime)
    }

    @Test
    func rescheduleAppointment_fails_whenNewTimeClashesWithAnotherAppointment() {
        let now = TestFixtures.fixedNow()
        let firstResult = scheduleUseCase.execute(client: Client(name: "Mei"), service: TestFixtures.cutService, scheduledAt: TestFixtures.time(hour: 10, on: now), bookingSource: .walkIn, now: now)
        let secondResult = scheduleUseCase.execute(client: Client(name: "Linh"), service: TestFixtures.cutService, scheduledAt: TestFixtures.time(hour: 14, on: now), bookingSource: .phoneCall, now: now)
        guard case .success(let mei) = firstResult, case .success(let linh) = secondResult else {
            Issue.record("Setup failed: could not create initial appointments")
            return
        }

        // Try to move Mei's appointment directly onto Linh's slot.
        let result = rescheduleUseCase.execute(appointmentID: mei.id, newScheduledAt: linh.scheduledAt, now: now)

        guard case .failure(let error) = result else {
            Issue.record("Expected timeSlotUnavailable failure")
            return
        }
        #expect(error == .timeSlotUnavailable(conflictingClientName: "Linh"))
    }

    @Test
    func rescheduleAppointment_succeeds_whenMovedIntoItsOwnOriginalSlot() {
        // Moving an appointment to overlap only its own current slot should not
        // be treated as a clash with itself.
        let now = TestFixtures.fixedNow()
        let original = scheduleUseCase.execute(client: Client(name: "Mei"), service: TestFixtures.cutService, scheduledAt: TestFixtures.time(hour: 10, on: now), bookingSource: .walkIn, now: now)
        guard case .success(let appointment) = original else {
            Issue.record("Setup failed: could not create initial appointment")
            return
        }

        let result = rescheduleUseCase.execute(appointmentID: appointment.id, newScheduledAt: appointment.scheduledAt, now: now)

        guard case .success = result else {
            Issue.record("Expected reschedule into the same slot to succeed")
            return
        }
    }

    @Test
    func rescheduleAppointment_fails_whenNewTimeRunsPastClosingTime() {
        let now = TestFixtures.fixedNow()
        let original = scheduleUseCase.execute(client: Client(name: "Mei"), service: TestFixtures.colourService, scheduledAt: TestFixtures.time(hour: 10, on: now), bookingSource: .walkIn, now: now)
        guard case .success(let appointment) = original else {
            Issue.record("Setup failed: could not create initial appointment")
            return
        }

        // colourService is 140 minutes total; 17:00 start would run past 18:00 closing.
        let tooLate = TestFixtures.time(hour: 17, on: now)
        let result = rescheduleUseCase.execute(appointmentID: appointment.id, newScheduledAt: tooLate, now: now)

        guard case .failure(let error) = result else {
            Issue.record("Expected outsideWorkingHours failure")
            return
        }
        #expect(error == .outsideWorkingHours(opening: "09:00", closing: "18:00"))
    }

    @Test
    func rescheduleAppointment_fails_whenAppointmentAlreadyHasAnOutcome() {
        let now = TestFixtures.fixedNow()
        var appointment = Appointment(client: Client(name: "Mei"), service: TestFixtures.cutService, scheduledAt: TestFixtures.time(hour: 8, on: now.addingTimeInterval(-86400)), bookingSource: .walkIn)
        appointment.outcome = .completed
        repository.save(appointment)

        let result = rescheduleUseCase.execute(appointmentID: appointment.id, newScheduledAt: TestFixtures.time(hour: 12, on: now), now: now)

        guard case .failure(let error) = result else {
            Issue.record("Expected outcomeAlreadyRecorded failure")
            return
        }
        #expect(error == .outcomeAlreadyRecorded(existing: .completed))
    }

    @Test
    func rescheduleAppointment_fails_whenAppointmentNotFound() {
        let now = TestFixtures.fixedNow()
        let result = rescheduleUseCase.execute(appointmentID: UUID(), newScheduledAt: TestFixtures.time(hour: 12, on: now), now: now)

        guard case .failure(let error) = result else {
            Issue.record("Expected appointmentNotFound failure")
            return
        }
        #expect(error == .appointmentNotFound)
    }
}
