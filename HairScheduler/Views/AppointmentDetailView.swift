//
//  AppointmentDetailView.swift
//  HairScheduler
//
//  Created by Brandon Hua on 9/9/2026.
//

import SwiftUI

struct AppointmentDetailView: View {
    @ObservedObject var viewModel: ScheduleViewModel
    let appointment: Appointment
    @Environment(\.dismiss) private var dismiss
    @State private var showingError = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Client") {
                    LabeledContent("Name", value: appointment.client.name)
                    if let phone = appointment.client.phoneNumber {
                        LabeledContent("Phone", value: phone)
                    }
                    LabeledContent("Booked via", value: appointment.bookingSource.rawValue)
                }

                Section("Service") {
                    LabeledContent("Service", value: appointment.service.name)
                    LabeledContent("Time", value: appointment.scheduledAt.formatted(date: .abbreviated, time: .shortened))
                    LabeledContent("Duration + cleanup", value: "\(appointment.service.totalBlockMinutes) min")
                }

                if let outcome = appointment.outcome {
                    Section("Outcome") {
                        Text(outcome.rawValue)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Section("Actions") {
                        Button("Mark Completed") {
                            viewModel.recordOutcome(appointment, outcome: .completed)
                            finishIfNoError()
                        }
                        Button("Mark No-Show") {
                            viewModel.recordOutcome(appointment, outcome: .noShow)
                            finishIfNoError()
                        }
                        Button("Cancel Appointment", role: .destructive) {
                            viewModel.cancelAppointment(appointment)
                            finishIfNoError()
                        }
                    }
                }
            }
            .navigationTitle("Booking Details")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .alert("Couldn't Update Booking", isPresented: $showingError, presenting: viewModel.errorMessage) { _ in
                Button("OK", role: .cancel) {}
            } message: { message in
                Text(message)
            }
        }
    }

    private func finishIfNoError() {
        if viewModel.errorMessage == nil {
            dismiss()
        } else {
            showingError = true
        }
    }
}

#Preview {
    AppointmentDetailView(
        viewModel: ScheduleViewModel(),
        appointment: Appointment(
            client: Client(name: "Mei"),
            service: Service.sampleServices[0],
            scheduledAt: Date(),
            bookingSource: .walkIn
        )
    )
}
