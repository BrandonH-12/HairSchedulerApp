//
//  ScheduleAppointmentUseCaseTests.swift
//  HairScheduler
//
//  Created by Brandon Hua on 13/9/2026.
//

import Testing
import Foundation
@testable import HairScheduler

@MainActor
@Suite("ScheduleAppointmentUseCase")
struct ScheduleAppointmentUseCaseTests {

    let repository = InMemoryAppointmentRepository()
    var useCase: ScheduleAppointmentUseCase {
        ScheduleAppointmentUseCase(repository: repository)
    }

    @Test
    func scheduleAppointment_succeeds_withValidNonOverlappingSlot() {
        let now = TestFixtures.fixedNow()
        let scheduledAt = TestFixtures.time(hour: 11)

        let result = useCase.execute(
            client: Client(name: "Mei"),
            service: TestFixtures.cutService,
            scheduledAt: scheduledAt,
            bookingSource: .walkIn,
            now: now
        )

        switch result {
        case .success(let appointment):
            #expect(appointment.client.name == "Mei")
        case .failure(let error):
            Issue.record("Expected success but got \(error)")
        }
        #expect(repository.allAppointments().count == 1)
    }

    @Test
    func scheduleAppointment_fails_whenTimeSlotOverlapsExistingAppointment() {
        let now = TestFixtures.fixedNow()
        let firstSlot = TestFixtures.time(hour: 11)
        _ = useCase.execute(client: Client(name: "Linh"), service: TestFixtures.colourService, scheduledAt: firstSlot, bookingSource: .phoneCall, now: now)

        // Colour runs 11:00 -> 13:20 including buffer; try to book a cut at 12:00 which overlaps.
        let overlappingSlot = TestFixtures.time(hour: 12)
        let result = useCase.execute(client: Client(name: "Grace"), service: TestFixtures.cutService, scheduledAt: overlappingSlot, bookingSource: .walkIn, now: now)

        guard case .failure(let error) = result else {
            Issue.record("Expected timeSlotUnavailable failure")
            return
        }
        #expect(error == .timeSlotUnavailable(conflictingClientName: "Linh"))
    }

    @Test
    func scheduleAppointment_succeeds_whenBookedImmediatelyAfterBufferEnds() {
        let now = TestFixtures.fixedNow()
        let firstSlot = TestFixtures.time(hour: 10) // cut: 10:00 -> 10:55 (45 + 10 buffer)
        _ = useCase.execute(client: Client(name: "Linh"), service: TestFixtures.cutService, scheduledAt: firstSlot, bookingSource: .phoneCall, now: now)

        let backToBackSlot = TestFixtures.time(hour: 10, minute: 55)
        let result = useCase.execute(client: Client(name: "Grace"), service: TestFixtures.cutService, scheduledAt: backToBackSlot, bookingSource: .walkIn, now: now)

        guard case .success = result else {
            Issue.record("Expected success for a booking that starts exactly when the buffer ends")
            return
        }
    }

    @Test
    func scheduleAppointment_fails_whenScheduledInThePast() {
        let now = TestFixtures.fixedNow()
        let pastSlot = TestFixtures.time(hour: 8) // before the fixed "now" of 9:00

        let result = useCase.execute(client: Client(name: "Grace"), service: TestFixtures.cutService, scheduledAt: pastSlot, bookingSource: .walkIn, now: now)

        guard case .failure(let error) = result else {
            Issue.record("Expected appointmentInThePast failure")
            return
        }
        #expect(error == .appointmentInThePast)
    }

    @Test
    func scheduleAppointment_fails_whenServiceRunsPastClosingTime() {
        let now = TestFixtures.fixedNow()
        // Working hours end at 18:00. A colour (140 min total) starting at 17:00 would end at 19:20.
        let lateSlot = TestFixtures.time(hour: 17)

        let result = useCase.execute(client: Client(name: "Grace"), service: TestFixtures.colourService, scheduledAt: lateSlot, bookingSource: .walkIn, now: now)

        guard case .failure(let error) = result else {
            Issue.record("Expected outsideWorkingHours failure")
            return
        }
        #expect(error == .outsideWorkingHours(opening: "09:00", closing: "18:00"))
    }
}
