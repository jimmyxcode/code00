//
//  DataStore.swift
//  LifeEveryday
//
//  Created by jimmyxcode on 16/10/2025.
//

import Foundation
import CoreData

enum TimeUnit: String, CaseIterable { 
    case minutes, hours, days, months 
}

final class DataStore: ObservableObject {
    static let shared = DataStore()
    private init() { refresh() }

    private let container = PersistenceController.shared
    private var ctx: NSManagedObjectContext { container.context }

    @Published private(set) var events: [LEEvent] = []
    @Published private(set) var entries: [LEEntry] = []

    // MARK: 讀
    func refresh() {
        let req: NSFetchRequest<CDEvent> = CDEvent.fetchRequest()
        req.predicate = NSPredicate(format: "isArchived == NO OR isArchived == nil")
        req.sortDescriptors = [NSSortDescriptor(keyPath: \CDEvent.createdAt, ascending: true)]
        do { events = try ctx.fetch(req).map(LEEvent.init) }
        catch { print("Fetch events error:", error) }
        
        let entryReq: NSFetchRequest<CDEntry> = CDEntry.fetchRequest()
        entryReq.sortDescriptors = [NSSortDescriptor(keyPath: \CDEntry.timestamp, ascending: false)]
        do { entries = try ctx.fetch(entryReq).map(LEEntry.init) }
        catch { print("Fetch entries error:", error) }
    }

    // MARK: 寫（Event）
    func addEvent(name: String, unit: TimeUnit = .days) {
        let e = CDEvent(context: ctx)
        e.id = UUID(); e.name = name; e.createdAt = Date(); e.unitRaw = unit.rawValue; e.isArchived = false
        log(.create, entity: "CDEvent", id: e.id!, payload: ["name": name, "unit": unit.rawValue])
        saveAndRefresh()
    }

    func renameEvent(id: UUID, to newName: String) {
        guard let e = fetchEvent(id) else { return }
        e.name = newName
        log(.update, entity: "CDEvent", id: id, payload: ["name": newName])
        saveAndRefresh()
    }

    func setUnit(_ unit: TimeUnit, for id: UUID) {
        guard let e = fetchEvent(id) else { return }
        e.unitRaw = unit.rawValue
        log(.update, entity: "CDEvent", id: id, payload: ["unit": unit.rawValue])
        saveAndRefresh()
    }

    func archiveEvent(id: UUID) {
        guard let e = fetchEvent(id) else { return }
        e.isArchived = true
        log(.update, entity: "CDEvent", id: id, payload: ["isArchived": true])
        saveAndRefresh()
    }

    func deleteEvent(id: UUID) {
        guard let e = fetchEvent(id) else { return }
        ctx.delete(e)
        log(.delete, entity: "CDEvent", id: id, payload: [:])
        saveAndRefresh()
    }
    
    /// 刪除所有資料（用於匯入前清空）
    func deleteAllData() {
        // 刪除所有事件（會自動刪除相關的條目）
        let req: NSFetchRequest<CDEvent> = CDEvent.fetchRequest()
        if let events = try? ctx.fetch(req) {
            for event in events {
                ctx.delete(event)
            }
        }
        
        // 刪除所有變更記錄
        let logReq: NSFetchRequest<CDChangeLog> = CDChangeLog.fetchRequest()
        if let logs = try? ctx.fetch(logReq) {
            for log in logs {
                ctx.delete(log)
            }
        }
        
        saveAndRefresh()
    }

    // MARK: 寫（Entry；每次「按一下」新增一筆）
    func quickRecord(eventId: UUID, at date: Date = .now, note: String? = nil) {
        print("🟦 QuickRecord tapped for event:", eventId.uuidString)
        
        guard let e = fetchEvent(eventId) else { 
            print("🟥 QuickRecord: event not found", eventId)
            return 
        }
        
        let before = e.entries?.count ?? 0
        print("🟦 entries count before:", before)
        
        let r = CDEntry(context: ctx)
        r.id = UUID(); r.timestamp = date; r.note = note; r.event = e
        log(.create, entity: "CDEntry", id: r.id!, payload: [
            "eventId": eventId.uuidString, "timestamp": ISO8601DateFormatter().string(from: date)
        ])
        
        let after = e.entries?.count ?? 0
        print("🟦 entries count after:", after)
        
        do {
            try ctx.save()
            print("🟩 context.save() OK")
        } catch {
            print("🟥 context.save() FAILED:", error)
        }
        
        ctx.refreshAllObjects()
        refresh()
        NotificationCenter.default.post(name: .dataStoreDidChange, object: nil)
        
        print("🟦 QuickRecord completed for event:", eventId.uuidString)
    }
    
    /// 新增條目（別名方法，與 quickRecord 功能相同）
    func addEntry(eventId: UUID, note: String? = nil) {
        quickRecord(eventId: eventId, note: note)
    }

    // MARK: 查詢
    func entries(for eventId: UUID) -> [LEEntry] {
        guard let e = fetchEvent(eventId) else { return [] }
        let list = (e.entries ?? []).compactMap { $0 as? CDEntry }
            .sorted { ($0.timestamp ?? .distantPast) > ($1.timestamp ?? .distantPast) }
        return list.map(LEEntry.init)
    }

    func lastEntry(for eventId: UUID) -> LEEntry? { entries(for: eventId).first }
    
    /// 計算活動的平均間隔天數
    func averageDays(for eventId: UUID) -> Double? {
        let entries = self.entries(for: eventId)
        guard entries.count >= 2 else { return nil }
        
        let sortedEntries = entries.sorted { $0.timestamp > $1.timestamp }
        var intervals: [Double] = []
        
        for i in 0..<(sortedEntries.count - 1) {
            let current = sortedEntries[i].timestamp
            let next = sortedEntries[i + 1].timestamp
            let interval = current.timeIntervalSince(next) / 86400 // 轉換為天數
            intervals.append(interval)
        }
        
        return intervals.reduce(0, +) / Double(intervals.count)
    }

    // MARK: 保存（本地落地 → CloudKit 排程 → 廣播 UI）
    func saveAndRefresh() {
        do {
            try ctx.save()
            ctx.refreshAllObjects()
            refresh()
            NotificationCenter.default.post(name: .dataStoreDidChange, object: nil)
        } catch { print("Save error:", error) }
    }

    // MARK: 私有
    private func fetchEvent(_ id: UUID) -> CDEvent? {
        let req: NSFetchRequest<CDEvent> = CDEvent.fetchRequest()
        req.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        req.fetchLimit = 1
        return try? ctx.fetch(req).first
    }
    
    private func fetchEvents() -> [CDEvent] {
        let req: NSFetchRequest<CDEvent> = CDEvent.fetchRequest()
        return (try? ctx.fetch(req)) ?? []
    }
    
    private func fetchChangeLogs() -> [CDChangeLog] {
        let req: NSFetchRequest<CDChangeLog> = CDChangeLog.fetchRequest()
        return (try? ctx.fetch(req)) ?? []
    }

    // MARK: - 調試方法
    /// 測試：為指定事件馬上新增一筆 Entry 並保存
    func _debug_recordNow(for eventID: UUID) {
        print("🟦 _debug_recordNow called for event:", eventID.uuidString)
        guard let ev = fetchEvent(eventID) else {
            print("🟥 _debug_recordNow: event not found", eventID)
            return
        }
        let context = ctx
        let entry = CDEntry(context: context)
        entry.id = UUID()
        entry.timestamp = Date()
        entry.event = ev

        do {
            try context.save()
            print("🟩 _debug_recordNow saved. entries:", (ev.entries?.count ?? 0))
            ctx.refreshAllObjects()
            refresh()
            NotificationCenter.default.post(name: .dataStoreDidChange, object: nil)
        } catch {
            print("🟥 _debug_recordNow save failed:", error)
        }
    }

    // 審計：所有變更都落 ChangeLog（永久保存）
    private enum Action: String { case create, update, delete }
    private func log(_ a: Action, entity: String, id: UUID, payload: [String: Any]) {
        let log = CDChangeLog(context: ctx)
        log.id = UUID(); log.createdAt = Date(); log.entityName = entity
        log.entityId = id; log.action = a.rawValue
        if let data = try? JSONSerialization.data(withJSONObject: payload, options: []),
           let s = String(data: data, encoding: .utf8) { log.payload = s }
    }
}

// 輕量 UI 模型（供 View 使用）
struct LEEvent: Identifiable {
    let id: UUID; var name: String; var createdAt: Date; var unit: TimeUnit; var isArchived: Bool
    var unitRaw: String { unit.rawValue }
    var lastEntryTimestamp: Date? { DataStore.shared.lastEntry(for: id)?.timestamp }
    
    init(_ cd: CDEvent) {
        id = cd.id ?? UUID()
        name = cd.name ?? "Untitled"
        createdAt = cd.createdAt ?? .now
        unit = TimeUnit(rawValue: cd.unitRaw ?? "") ?? .days
        isArchived = cd.isArchived
    }
}
struct LEEntry: Identifiable {
    let id: UUID; let timestamp: Date; let note: String?
    init(_ cd: CDEntry) { id = cd.id ?? UUID(); timestamp = cd.timestamp ?? .now; note = cd.note }
}

extension Notification.Name { 
    static let dataStoreDidChange = Notification.Name("DataStoreDidChange") 
}
