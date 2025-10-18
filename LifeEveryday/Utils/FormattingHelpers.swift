// MARK: - 5) Formatting helpers (days/minutes/hours – short & "ago")
import Foundation

public enum UnitPref { case minutes, hours, days }

public extension TimeInterval {
    /// e.g. "11 d" / "24 h" / "1440 min"
    func toReadableShort(unitPreference pref: UnitPref) -> String {
        switch pref {
        case .minutes:
            let m = Int((self / 60.0).rounded())
            return "\(m) min"
        case .hours:
            let h = (self / 3600.0)
            // Keep 1 decimal if < 10 hours, otherwise round
            return h < 10 ? String(format: "%.1f h", h) : "\(Int(h.rounded())) h"
        case .days:
            let d = (self / 86400.0)
            return d < 10 ? String(format: "%.0f d", d.rounded()) : "\(Int(d.rounded())) d"
        }
    }

    /// e.g. "Last 10 d ago"
    func toReadableAgo(unitPreference pref: UnitPref) -> String {
        let short = toReadableShort(unitPreference: pref)
        return "\(short) ago"
    }
}

public extension Date {
    static var distantPast: Date { .init(timeIntervalSince1970: 0) }
}
