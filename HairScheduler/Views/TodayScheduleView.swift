//
//  TodayScheduleView.swift
//  HairScheduler
//
//  Created by Brandon Hua on 9/9/2026.
//

import SwiftUI

struct TodayScheduleView: View {
    @ObservedObject var viewModel: ScheduleViewModel
    @State private var showingNewBooking = false
    @State private var selectedAppointment: Appointment?

    var body: some View {
        NavigationStack {
            List {
                Section("Today"){
                    if viewModel.todaysAppointments.isEmpty {
                        ContentUnavailableView(
                            "No Bookings Today",
                            systemImage: "scissors",
                            description: Text("Tap + to add a walk-in, phone booking, or friend.")
                        )
                    } else {
                        ForEach(viewModel.todaysAppointments) { appointment in
                            Button {
                                selectedAppointment = appointment
                            } label: {
                                AppointmentRow(appointment: appointment)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                if !viewModel.upcomingAppointments.isEmpty {
                    Section("Upcoming This Week"){
                        ForEach(viewModel.upcomingAppointments){
                            appointment in Button {
                                selectedAppointment = appointment
                            } label: {
                                AppointmentRow(appointment: appointment, showDate: true)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .navigationTitle("Today's Schedule")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                        NavigationLink {
                            HistoryView(viewModel: viewModel)
                        } label: {
                            Image(systemName: "clock")
                        }
                    }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingNewBooking = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingNewBooking) {
                NewBookingView(viewModel: viewModel)
            }
            .sheet(item: $selectedAppointment) { appointment in
                AppointmentDetailView(viewModel: viewModel, appointment: appointment)
            }
        }
    }
}

struct AppointmentRow: View {
    let appointment: Appointment
    var showDate: Bool = false

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(appointment.client.name)
                    .font(.headline)
                Text(appointment.service.name)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(appointment.bookingSource.rawValue)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text(appointment.scheduledAt.formatted(date: showDate ? .abbreviated: .omitted, time: .shortened))
                    .font(.headline)
                if let outcome = appointment.outcome {
                    Text(outcome.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(badgeColor(for: outcome).opacity(0.2))
                        .foregroundStyle(badgeColor(for: outcome))
                        .clipShape(Capsule())
                }
            }
        }
        .padding(.vertical, 4)
    }

    private func badgeColor(for outcome: AppointmentOutcome) -> Color {
        switch outcome {
        case .completed: return .green
        case .noShow: return .red
        case .cancelled: return .orange
        }
    }
}

#Preview {
    TodayScheduleView(viewModel: ScheduleViewModel())
}
