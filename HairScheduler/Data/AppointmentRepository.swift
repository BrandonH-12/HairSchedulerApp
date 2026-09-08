//
//  AppointmentRepository.swift
//  HairScheduler
//
//  Created by Brandon Hua on 8/9/2026.
//
import Foundation

protocol AppointmentRepository {
    func allAppointments() -> [Appointment]
    func appointments(overlapping day: Date, calendar: Calendar) -> [Appointment]
    func appointment(withID id: UUID) -> Appointment?
    func save(_ appointment: Appointment)
    func update(_ appointment: Appointment)
}
