//
//  HairSchedulerApp.swift
//  HairScheduler
//
//  Created by Brandon Hua on 7/9/2026.
//

import SwiftUI

@main
struct HairScheduleApp: App {
    @StateObject private var viewModel = ScheduleViewModel(repository: InMemoryAppointmentRepository.seeded())

    var body: some Scene {
        WindowGroup {
            TodayScheduleView(viewModel: viewModel)
        }
    }
}
