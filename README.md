# HairScheduler
A booking and schedule manager for independent, home-based hairdressers and barbers. Designed to replace pen-paper diary booking with something more accessible.

## Domain Context
Stakeholder: Independent hairdressers and barbers who run their business from home rather than a salon — a genuine and common category of small business, not a one-off setup. They take bookings by phone, from walk-ins, and from friends and existing clients dropping by, and they currently rely on a paper diary and their own judgement for how much time to leave between clients. This project is grounded in one real example within that category — a relative's home hairdressing business — but the problem it solves is shared by any independent stylist working the same way.

The real problem: A paper diary has no way to catch a clash the moment a new booking is written down especially for walk-ins or friends, who were never in any prior calendar to begin with. It also has no memory of patterns over time: which clients reliably no-show, or how much buffer time a colour actually needs versus a cut.

What this app does not try to solve: Online client self-booking, payment processing, or cancellation fees. These are deliberately excluded, not overlooked. Many independent, relationship-based stylists don't charge cancellation fees at all, since a fee is the kind of friction that discourages a new client before they've had one appointment. A platform like Booksy solves a different problem (public discovery, self-service booking, payment handling) than the one this app targets: protecting an existing, informal, trust-based workflow from the one thing paper genuinely can't catch. This is scoped as an MVP for the hairdresser's own use, not a client-facing product.


## Architecture Summary
SwiftUI Views (TodayScheduleView, NewBookingView, AppointmentDetailView, HistoryView, RescheduleAppointmentView)

↓
        
ScheduleViewModel (MVVM)

↓

Use Case Layer
  - ScheduleAppointmentUseCase
  - CancelAppointmentUseCase
  - RecordAppointmentOutcomeUseCase
  - RescheduleAppointmentUseCase
  
↓

Domain Models (Appointment, Client, Service, WorkingHours, AppointmentOutcome, BookingSource) + AppointmentRepository

- Domain Models (Models/) are named after real salon entities, each documented with the business rule it enforces.
- Use Cases (UseCases/) each encapsulate one real business operation, return Result<Success, TypedError>, and never leak Swift/technical error messages. Every error is written for the hairdresser, not a developer.
- Repository (Data/) abstracts storage behind a protocol; the in-memory implementation is a class because the schedule is genuinely shared, mutable state across every screen.
- ViewModel (ViewModels/) is the only thing that talks to Use Cases; Views never call a Use Case directly.

## Key Business Rules
1. No two non-cancelled appointments may occupy overlapping time, including each service's cleanup buffer.
2. A booking must fit entirely within working hours (09:00–18:00).
3. A cancellation and a no-show are recorded as distinct outcomes, even though no fee applies to either — this preserves a pattern the hairdresser can look back on.
4. An appointment's outcome (completed/no-show) can only be recorded after its scheduled time has passed.
5. A cancelled or completed slot cannot be modified again.
6. Rescheduling an appointment reuses the same clash and working-hours rules as booking, excluding the appointment's own current slot from the clash check.

## Setup Instructions

1. Clone the repository.
2. Open `HairScheduler.xcodeproj` in Xcode.
3. Select an iOS Simulator (e.g. iPhone 17 Pro) as the run destination — not "External Display."
4. Build and run — `Cmd+R` for the app, `Cmd+U` for the tests.
