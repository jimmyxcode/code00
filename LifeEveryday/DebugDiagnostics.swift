import Foundation
import SwiftUI
import CoreData
#if canImport(UIKit)
import UIKit
#endif

// MARK: - 可序列化 Dump 型別
struct LEDump: Codable {
    struct Env: Codable {
        let appVersion: String
        let buildNumber: String
        let device: String
        let system: String
        let time: String
        let bundleID: String
        let iCloudAccountStatus: String
        let ubiquityIdentityTokenPresent: Bool
        let persistentStoreType: String
        let storeURL: String?
        let containerIdentifier: String?
        let timeUnitPreference: String
    }

    struct EventDump: Codable {
        let id: UUID
        let title: String
        let unit: String               // min / h / d / mo
        let cycle: Int                 // 你設定嘅目標週期
        let createdAt: Date?
        let totalRecords: Int
        let lastTimestamp: Date?
        // 計算欄位（UI 用到）
        let sinceLast: Double          // 以「目前單位」計（分鐘/小時/日/月）
        let averageInterval: Double?
        let dueIn: Double?             // >0 還有幾多單位、=0 今天、<0 逾期
        let nextDate: Date?
        let recentIntervals: [Double]  // 最近 3 次間隔（同單位）
        // 進度條
        let progress0to1: Double       // 0...1 之間
        let progressLabel: String
    }

    let env: Env
    let events: [EventDump]
}

// MARK: - 計算器（確保與 UI 一致）
// 使用現有的 TimeUnit 定義，不需要重複定義

struct Metrics {
    static func toUnit(_ seconds: Double, unit: TimeUnit) -> Double {
        switch unit {
        case .minutes: return seconds / 60
        case .hours:   return seconds / 3600
        case .days:    return seconds / 86400
        case .months:  return seconds / (86400 * 30) // 近似值，與 UI 用法保持一致
        }
    }

    static func label(passed: Double, total: Double, dueIn: Double?, unit: TimeUnit) -> String {
        let u: String = {
            switch unit {
            case .minutes: return "min"
            case .hours:   return "h"
            case .days:    return "d"
            case .months:  return "mo"
            }
        }()
        let dueText: String = {
            guard let d = dueIn else { return "-" }
            if d < 0 { return "overdue \(abs(Int(round(d)))) \(u)" }
            if d == 0 { return "due today" }
            return "due in \(Int(round(d))) \(u)"
        }()
        return "\(Int(round(passed))) \(u) / \(Int(round(total))) \(u) · \(dueText)"
    }
}

// MARK: - DataStore Debug API
extension DataStore {
    /// 產生完整 Dump（**請用呢個**）
    func makeDebugSnapshot() -> LEDump {
        // 讀使用者單位偏好
        let unit = TimeUnit.days // 預設使用天數，與現有 UI 一致
        let unitEnum = TimeUnit.days

        // 環境
        let env = LEDump.Env(
            appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0",
            buildNumber: Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0",
            device: UIDevice.current.model,
            system: "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)",
            time: ISO8601DateFormatter().string(from: Date()),
            bundleID: Bundle.main.bundleIdentifier ?? "-",
            iCloudAccountStatus: iCloudAccountStatusString(),
            ubiquityIdentityTokenPresent: FileManager.default.ubiquityIdentityToken != nil,
            persistentStoreType: "SQLite",
            storeURL: PersistenceController.shared.persistentStoreDescriptions.first?.url?.path,
            containerIdentifier: "iCloud.com.jimmylo.LifeEveryday",
            timeUnitPreference: unit.rawValue
        )

        // 事件列表
        let eventDumps: [LEDump.EventDump] = self.events.map { ev in
            // 原始資料
            let cycleInUnit = 30 // 預設 30 天週期
            let entries = self.entries(for: ev.id)
            let sorted = entries.sorted { $0.timestamp < $1.timestamp }
            let last = sorted.last?.timestamp
            let secondsSinceLast = last.map { Date().timeIntervalSince($0) } ?? 0
            let passed = Metrics.toUnit(secondsSinceLast, unit: unitEnum)

            // 平均間隔
            let intervalsSec: [TimeInterval] = zip(sorted.dropFirst(), sorted).map { $0.0.timestamp.timeIntervalSince($0.1.timestamp) }
            let avg = intervalsSec.isEmpty ? nil : Metrics.toUnit(intervalsSec.reduce(0,+)/Double(intervalsSec.count), unit: unitEnum)

            // 最近 3 次間隔
            let recent3 = Array(intervalsSec.suffix(3).map { Metrics.toUnit($0, unit: unitEnum) })

            // dueIn：cycle - passed
            let dueIn: Double? = last == nil ? nil : Double(cycleInUnit) - passed

            // nextDate（以 day 單位時才比較準，其他單位大致估算）
            let nextDate: Date? = last.map {
                switch unitEnum {
                case .minutes: return Calendar.current.date(byAdding: .minute, value: cycleInUnit, to: $0) ?? $0
                case .hours:   return Calendar.current.date(byAdding: .hour,   value: cycleInUnit, to: $0) ?? $0
                case .days:    return Calendar.current.date(byAdding: .day,    value: cycleInUnit, to: $0) ?? $0
                case .months:  return Calendar.current.date(byAdding: .month,  value: cycleInUnit, to: $0) ?? $0
                }
            }

            // 進度：passed / cycle
            let prog = min(max(passed / Double(cycleInUnit), 0), 1)
            let label = Metrics.label(passed: passed, total: Double(cycleInUnit), dueIn: dueIn, unit: unitEnum)

            return LEDump.EventDump(
                id: ev.id,
                title: ev.name,
                unit: unit.rawValue,
                cycle: cycleInUnit,
                createdAt: ev.createdAt,
                totalRecords: entries.count,
                lastTimestamp: last,
                sinceLast: passed,
                averageInterval: avg,
                dueIn: dueIn,
                nextDate: nextDate,
                recentIntervals: recent3,
                progress0to1: prog,
                progressLabel: label
            )
        }

        return LEDump(env: env, events: eventDumps)
    }

    /// 將 Dump 寫檔 + 印 Console，回傳檔案 URL
    @discardableResult
    func exportDebugSnapshotToDisk() -> URL? {
        let dump = makeDebugSnapshot()
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        encoder.dateEncodingStrategy = .iso8601

        do {
            let data = try encoder.encode(dump)
            // 印部分重點到 Console
            print("🔎 [LE-DUMP] env=\(dump.env)")
            print("🔎 [LE-DUMP] events.count=\(dump.events.count)")
            dump.events.forEach { e in
                print("🔎 [LE-DUMP] \(e.title) :: progress=\(String(format: "%.3f", e.progress0to1)) :: \(e.progressLabel)")
            }

            // 寫檔
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                .appendingPathComponent("LE-DebugDump-\(Int(Date().timeIntervalSince1970)).json")
            try data.write(to: url, options: .atomic)
            print("✅ [LE-DUMP] file=\(url.path)")
            return url
        } catch {
            print("❌ [LE-DUMP] encode error: \(error)")
            return nil
        }
    }

    // MARK: - iCloud 情況（簡易字串）
    private func iCloudAccountStatusString() -> String {
        if FileManager.default.ubiquityIdentityToken == nil { return "No iCloud Account / Not logged in" }
        return "Available"
    }
}
