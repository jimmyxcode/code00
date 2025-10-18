//
//  BackupManager.swift
//  LifeEveryday
//
//  Created by jimmyxcode on 16/10/2025.
//

import Foundation

struct BackupPayload: Codable {
    struct Event: Codable { 
        var id: UUID; var name: String; var createdAt: Date; var unitRaw: String; var isArchived: Bool; var entries: [Entry] 
    }
    struct Entry: Codable { 
        var id: UUID; var timestamp: Date; var note: String? 
    }
    var events: [Event]; var exportedAt: Date
}

enum BackupManager {
    static var url: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("backup.json")
    }

    static func exportJSON() throws {
        let s = DataStore.shared
        let payload = BackupPayload(
            events: s.events.map { e in
                .init(id: e.id, name: e.name, createdAt: e.createdAt, unitRaw: e.unit.rawValue,
                      isArchived: e.isArchived,
                      entries: s.entries(for: e.id).map { .init(id: $0.id, timestamp: $0.timestamp, note: $0.note) })
            },
            exportedAt: .now
        )
        try JSONEncoder().encode(payload).write(to: url, options: .atomic)
    }

    static func importJSON() throws {
        let data = try Data(contentsOf: url)
        let p = try JSONDecoder().decode(BackupPayload.self, from: data)
        let s = DataStore.shared
        p.events.forEach { ev in
            if s.events.first(where: { $0.id == ev.id }) == nil {
                s.addEvent(name: ev.name, unit: TimeUnit(rawValue: ev.unitRaw) ?? .days)
            }
            ev.entries.forEach { s.quickRecord(eventId: ev.id, at: $0.timestamp, note: $0.note) }
        }
    }
}
