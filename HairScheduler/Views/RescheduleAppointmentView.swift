//
//  RescheduleAppointmentView.swift
//  HairScheduler
//
//  Created by Brandon Hua on 13/9/2026.
//

import SwiftUI

struct RescheduleAppointmentView: View {
    @ObservedObject var viewModel: ScheduleViewModel
    let appointment: Appointment
    var onSaved: (() -> Void)?
    @Environment(\.dismiss) private var dismiss

    @State private var newScheduledAt: Date
    @State private var showingError = false

    init(viewModel: ScheduleViewModel, appointment: Appointment, onSaved: (() -> Void)? = nil) {
        self.viewModel = viewModel
        self.appointment = appointment
        self.onSaved = onSaved
        _newScheduledAt = State(initialValue: appointment.scheduledAt)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Currently Booked") {
                    LabeledContent("Client", value: appointment.client.name)
                    LabeledContent("Service", value: appointment.service.name)
                    LabeledContent("Current Time", value: appointment.scheduledAt.formatted(date: .abbreviated, time: .shortened))
                }

                Section("New Time") {
                    DatePicker("New time", selection: $newScheduledAt)
                }
            }
            .navigationTitle("Move Appointment")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.rescheduleAppointment(appointment, to: newScheduledAt)
                        if viewModel.errorMessage == nil {
                            dismiss()
                            onSaved?()
                        } else {
                            showingError = true
                        }
                    }
                }
            }
            .alert("Can't Move This Appointment", isPresented: $showingError, presenting: viewModel.errorMessage) { _ in
                Button("OK", role: .cancel) {}
            } message: { message in
                Text(message)
            }
        }
    }
}

#Preview {
    RescheduleAppointmentView(
        viewModel: ScheduleViewModel(),
        appointment: Appointment(
            client: Client(name: "Mei"),
            service: Service.sampleServices[0],
            scheduledAt: Date().addingTimeInterval(3600),
            bookingSource: .walkIn
        )
    )
}
