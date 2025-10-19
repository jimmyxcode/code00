import Foundation

/// 顯示單位（沿用你的 TimeUnit）— 內部一律以「天」為基礎運算
public enum StatsUnit: String { case minutes, hours, days, months }

/// 事件希望的目標間隔（可選，沒填就不當作強制）
public struct TargetInterval {
    public let value: Double   // 例如 30
    public let unit: StatsUnit // 例如 .days
}

public struct EventStats {
    public let createdAt: Date
    public let totalCount: Int
    public let lastDate: Date?

    /// 以「天」為基礎的平均間隔（根據歷史相鄰間隔）
    public let avgIntervalDays: Double?

    /// 最近三次相鄰間隔（天）
    public let intervalsLast3Days: [Double]

    /// 估算的下一次日期（用 avgIntervalDays 或 targetIntervalDays）
    public let nextDate: Date?

    /// >0 表示剩餘天數；<0 表示逾期天數（負數）
    public let dueInDays: Double?

    /// 顯示分母（用於進度條右側 / 卡片右上角）- 永不為 0
    public let displayCycleDays: Double

    /// 顯示分子（距離「上次」到現在的天數）
    public let elapsedDays: Double
    
    /// 進度百分比 (0...1)
    public let progress: Double
}

public enum StatsEngine {

    /// 計算統計值；entries 必須為 **由新到舊**（最新在前）
    /// - parameter target: 若只有 0/1 筆，會拿 target 當 fallback 讓 UI 不會顯示 0/0
    public static func compute(
        createdAt: Date,
        entries newestFirst: [Date],
        preferredUnit: StatsUnit,
        target: TargetInterval? = nil,
        now: Date = .now,
        logger: ((String) -> Void)? = nil
    ) -> EventStats {

        // === 診斷 ===
        logger?("Stats.compute ▶︎ entries(newest→oldest)=\(newestFirst.map { iso8601($0) })")

        let total = newestFirst.count
        let last = newestFirst.first

        // 以天為基礎
        let day: TimeInterval = 24*60*60
        let elapsed: Double = {
            guard let last else { return 0 }
            return max(0, now.timeIntervalSince(last) / day)
        }()

        // 計算相鄰間隔（天）
        var intervalsDays: [Double] = []
        if newestFirst.count >= 2 {
            for i in 0..<(newestFirst.count - 1) {
                let d = newestFirst[i].timeIntervalSince(newestFirst[i + 1]) / day
                if d > 0 { intervalsDays.append(d) }
            }
        }
        let avgDays = intervalsDays.isEmpty ? nil : (intervalsDays.reduce(0, +) / Double(intervalsDays.count))

        // 目標間隔（天）
        let targetDays: Double? = target.map { convertToDays(value: $0.value, unit: $0.unit) }

        // 🔥 關鍵修復：進度條「分母」永不為 0，優先級：avg → target → 預設 30 天
        let cycleDays: Double = {
            if let avg = avgDays, avg > 0 { return avg }
            if let target = targetDays, target > 0 { return target }
            return 30.0 // 預設保底值
        }()

        // 估算「下一次」與 dueIn
        var next: Date? = nil
        var dueIn: Double? = nil
        if let last, cycleDays > 0 {
            next = last.addingTimeInterval(cycleDays * day)
            dueIn = next!.timeIntervalSince(now) / day // 正：剩餘；負：逾期
        }

        // 計算進度百分比 (0...1)
        let progress = min(1.0, max(0.0, elapsed / cycleDays))

        // === 診斷 ===
        logger?("Stats.compute ▶︎ total=\(total) last=\(last.map { iso8601($0) } ?? "nil") avg=\(avgDays?.rounded(to: 2) ?? -1) tgt=\(targetDays?.rounded(to: 2) ?? -1) cycle=\(cycleDays.rounded(to: 2)) elapsed=\(elapsed.rounded(to: 2)) dueIn=\(dueIn?.rounded(to: 2) ?? -999) progress=\(progress.rounded(to: 2))")

        return .init(
            createdAt: createdAt,
            totalCount: total,
            lastDate: last,
            avgIntervalDays: avgDays,
            intervalsLast3Days: Array(intervalsDays.prefix(3)),
            nextDate: next,
            dueInDays: dueIn,
            displayCycleDays: cycleDays,
            elapsedDays: elapsed,
            progress: progress
        )
    }

    /// 百分比 0...1（給進度條）- 已整合到 compute 結果中，此方法保留向後相容
    public static func progressRatio(elapsedDays: Double, cycleDays: Double?) -> Double {
        guard let denom = cycleDays, denom > 0 else { return 0 }
        return max(0, min(1, elapsedDays / denom))
    }

    /// 以使用者偏好單位輸出（四捨五入）
    public static func formatInterval(_ days: Double?, unit: StatsUnit) -> String {
        guard let days else { return "—" }
        switch unit {
        case .minutes: return "\(Int((days * 24 * 60).rounded())) min"
        case .hours:   return "\(Int((days * 24).rounded())) h"
        case .days:    return "\(Int(days.rounded())) d"
        case .months:  return "\(Int((days / 30.0).rounded())) mo"
        }
    }

    // MARK: - Helpers

    private static func convertToDays(value: Double, unit: StatsUnit) -> Double {
        switch unit {
        case .minutes: return value / 60.0 / 24.0
        case .hours:   return value / 24.0
        case .days:    return value
        case .months:  return value * 30.0
        }
    }

    private static func iso8601(_ d: Date) -> String {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f.string(from: d)
    }
}

private extension Double {
    func rounded(to places: Int) -> Double {
        let p = pow(10, Double(places))
        return (self * p).rounded() / p
    }
}