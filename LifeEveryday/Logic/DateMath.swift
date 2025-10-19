import Foundation

/// 安全日期計算工具，避免統計計算中的除零錯誤
enum DateMath {
    static let cal = Calendar.current

    /// 回傳 from -> to 的整數天數差（向下取整），最小為 0
    static func daysBetween(_ from: Date, _ to: Date) -> Int {
        let start = cal.startOfDay(for: from)
        let end   = cal.startOfDay(for: to)
        let comps = cal.dateComponents([.day], from: start, to: end)
        return max(0, comps.day ?? 0)
    }

    /// 今天 00:00
    static var today: Date { cal.startOfDay(for: Date()) }
    
    /// 安全的時間間隔轉天數（避免除零）
    static func safeDaysFrom(_ timeInterval: TimeInterval) -> Double {
        return max(0, timeInterval / 86400)
    }
    
    /// 安全的天數轉時間間隔
    static func safeTimeIntervalFrom(_ days: Double) -> TimeInterval {
        return max(0, days * 86400)
    }
}
