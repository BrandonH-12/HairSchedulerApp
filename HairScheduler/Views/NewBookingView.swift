//
//  NewBookingView.swift
//  HairScheduler
//
//  Created by Brandon Hua on 9/9/2026.
//

import SwiftUI

struct NewBookingView: View {
    @ObservedObject var viewModel: ScheduleViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var clientName: String = ""
    @State private var phoneNumber: String = ""
    @State private var selectedService: Service = Service.sampleServices[0]
    @State private var scheduledAt: Date = Date().addingTimeInterval(3600)
    @State private var bookingSource: BookingSource = .walkIn
    @State private var showingError = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Client") {
                    TextField("Client name", text: $clientName)
                    TextField("Phone number (optional)", text: $phoneNumber)
                        .keyboardType(.phonePad)
                }

                Section("Service") {
                    Picker("Service", selection: $selectedService) {
                        ForEach(viewModel.availableServices) { service in
                            Text("\(service.name) (\(service.standardDurationMinutes) min)")
                                .tag(service)
                        }
                    }
                }

                Section("Time") {
                    DatePicker("Scheduled at", selection: $scheduledAt)
                }

                Section("How did this booking come in?") {
                    Picker("Booking source", selection: $bookingSource) {
                        ForEach(BookingSource.allCases) { source in
                            Text(source.rawValue).tag(source)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle("New Booking")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.scheduleAppointment(
                            clientName: clientName,
                            phoneNumber: phoneNumber.isEmpty ? nil : phoneNumber,
                            service: selectedService,
                            scheduledAt: scheduledAt,
                            source: bookingSource
                        )
                        if viewModel.errorMessage == nil {
                            dismiss()
                        } else {
                            showingError = true
                        }
                    }
                    .disabled(clientName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .alert("Can't Book This Appointment", isPresented: $showingError, presenting: viewModel.errorMessage) { _ in
                Button("OK", role: .cancel) {}
            } message: { message in
                Text(message)
            }
        }
    }
}

#Preview {
    NewBookingView(viewModel: ScheduleViewModel())
}
