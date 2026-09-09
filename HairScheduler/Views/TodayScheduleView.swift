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
