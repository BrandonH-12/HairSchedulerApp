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

    var body: some View {
        NavigationStack {
            List {
                if viewModel.todaysAppointments.isEmpty {
                    ContentUnavailableView(
                        "No Bookings Today",
                        systemImage: "scissors",
                        description: Text("Tap + to add a walk-in, phone booking, or friend.")
                    )
                } else {
                    ForEach(viewModel.todaysAppointments) { appointment in
                        AppointmentRow(appointment: appointment)
                    }
                }
            }
            .navigationTitle("Today's Schedule")
            .toolbar {
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
        }
    }
}

struct AppointmentRow: View {
    let appointment: Appointment

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
                Text(appointment.scheduledAt.formatted(date: .omitted, time: .shortened))
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
