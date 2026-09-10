//
//  HistoryView.swift
//  HairScheduler
//
//  Created by Brandon Hua on 10/9/2026.
//

import SwiftUI

struct HistoryView: View {
    @ObservedObject var viewModel: ScheduleViewModel

    var body: some View {
        List {
            if viewModel.pastAppointments.isEmpty {
                ContentUnavailableView(
                    "No History Yet",
                    systemImage: "clock",
                    description: Text("Completed, no-show, and cancelled bookings will appear here.")
                )
            } else {
                ForEach(viewModel.pastAppointments.sorted(by: { $0.scheduledAt > $1.scheduledAt })) { appointment in
                    AppointmentRow(appointment: appointment)
                }
            }
        }
        .navigationTitle("History")
        .onAppear { viewModel.refresh() }
    }
}

#Preview {
    NavigationStack {
        HistoryView(viewModel: ScheduleViewModel())
    }
}
