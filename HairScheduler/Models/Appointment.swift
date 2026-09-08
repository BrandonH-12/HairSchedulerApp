//
//  Appointment.swift
//  HairScheduler
//
//  Created by Brandon Hua on 8/9/2026.
//


import Foundation

struct Appointment: Identifiable, DomainAuditable {
    let id: UUID
    let client: Client
    let service: Service
    let scheduledAt: Date
    let bookingSource: BookingSource
    var outcome: AppointmentOutcome?
    var cancelledAt: Date?

    let recordedAt: Date
    let recordedByUserID: String

    init(
        id: UUID = UUID(),
        client: Client,
        service: Service,
        scheduledAt: Date,
        bookingSource: BookingSource,
        outcome: AppointmentOutcome? = nil,
        cancelledAt: Date? = nil,
        recordedAt: Date = Date(),
        recordedByUserID: String = "Auntie"
    ) {
        self.id = id
        self.client = client
        self.service = service
        self.scheduledAt = scheduledAt
        self.bookingSource = bookingSource
        self.outcome = outcome
        self.cancelledAt = cancelledAt
        self.recordedAt = recordedAt
        self.recordedByUserID = recordedByUserID
    }

    /// The moment this appointment's time block ends, including cleanup buffer.
    var scheduledEndTime: Date {
        scheduledAt.addingTimeInterval(TimeInterval(service.totalBlockMinutes * 60))
    }

    /// True if this appointment's time block overlaps another's.
    /// A cancelled appointment never counts as occupying the schedule.
    func overlaps(with other: Appointment) -> Bool {
        guard outcome != .cancelled, other.outcome != .cancelled else { return false }
        return scheduledAt < other.scheduledEndTime && other.scheduledAt < scheduledEndTime
    }

    func auditSummary() -> String {
        "\(client.name) — \(service.name) at \(scheduledAt.formatted(date: .abbreviated, time: .shortened)), booked via \(bookingSource.rawValue), recorded by \(recordedByUserID)"
    }

    /// Returns a copy of this appointment moved to a new time.
    ///
    /// Business Rule: rescheduling is not the same event as a fresh booking —
    /// it's the same client relationship, so the identity (`id`), how the
    /// booking originally came in, and when it was first recorded are all
    /// preserved. Only the time itself changes.
    func rescheduled(to newScheduledAt: Date) -> Appointment {
        Appointment(
            id: id,
            client: client,
            service: service,
            scheduledAt: newScheduledAt,
            bookingSource: bookingSource,
            outcome: outcome,
            cancelledAt: cancelledAt,
            recordedAt: recordedAt,
            recordedByUserID: recordedByUserID
        )
    }
}


