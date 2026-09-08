//
//  Client.swift
//  HairScheduler
//
//  Created by Brandon Hua on 8/9/2026.
//

import Foundation

///Represents a person who books, or has book, a service with the hairdresser.

struct Client: Identifiable, Hashable {
    let id: UUID
    let name : String
    let phoneNumber: String?
    
    init(id: UUID = UUID(), name: String, phoneNumber: String? = nil) {
        self.id = id
        self.name = name
        self.phoneNumber = phoneNumber
    }
}
