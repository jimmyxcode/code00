//
//  ImportExportManager.swift
//  LifeEveryday
//
//  Created by jimmyxcode on 18/10/2025.
//

import Foundation

class ImportExportManager {
    static func generateBackup() throws -> Data {
        let events = DataStore.shared.events
        let entries = DataStore.shared.entries
        
        let backup = BackupData(
            events: events.map { BackupEvent(from: $0) },
            entries: entries.map { BackupEntry(from: $0) },
            exportedAt: Date()
        )
        
        return try JSONEncoder().encode(backup)
    }
    
    static func importBackup(_ data: Data) throws {
        let backup = try JSONDecoder().decode(BackupData.self, from: data)
        
        // 清空現有資料
        DataStore.shared.deleteAllData()
        
        // 匯入事件
        for backupEvent in backup.events {
            DataStore.shared.addEvent(name: backupEvent.name)
        }
        
        // 匯入條目（簡化版本，實際可能需要更複雜的關聯邏輯）
        for backupEntry in backup.entries {
            // 這裡需要根據實際需求實現
        }
    }
}

struct BackupData: Codable {
    let events: [BackupEvent]
    let entries: [BackupEntry]
    let exportedAt: Date
}

struct BackupEvent: Codable {
    let id: UUID
    let name: String
    let createdAt: Date
    let unitRaw: String
    let isArchived: Bool
    
    init(from event: LEEvent) {
        self.id = event.id
        self.name = event.name
        self.createdAt = event.createdAt
        self.unitRaw = event.unitRaw
        self.isArchived = event.isArchived
    }
}

struct BackupEntry: Codable {
    let id: UUID
    let timestamp: Date
    let note: String?
    
    init(from entry: LEEntry) {
        self.id = entry.id
        self.timestamp = entry.timestamp
        self.note = entry.note
    }
}
