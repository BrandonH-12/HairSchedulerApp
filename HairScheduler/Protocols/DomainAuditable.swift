//
//  DomainAuditable.swift
//  HairScheduler
//
//  Created by Brandon Hua on 8/9/2026.
//

import Foundation

/// Represents any domain entity that participates in auditble event
/// Home-based hairdressing requires every booking, cancellation and outcome to be traceable
/// From when it was recorded and by whom
public protocol DomainAuditable {
    var recordedAt: Date { get }
    var recordedByUserID: String { get }
    func auditSummary() -> String
    
}
