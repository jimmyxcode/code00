// MARK: - 3) EventCardV2
import SwiftUI
import CoreData
import Combine

public struct EventCardV2: View {

    // ===== Inputs from your model =====
    // Replace these with your LEEvent/DataStore fields.
    let title: String
    /// last completion date (for "Last Xd ago")
    let lastDate: Date?
    /// target interval (seconds) – e.g. average or preferred interval
    let targetInterval: TimeInterval
    /// time since last (seconds)
    let sinceLast: TimeInterval
    /// quick record action
    var onQuickRecord: () -> Void
    /// long press -> edit sheet
    var onLongPress: () -> Void

    public init(
        title: String,
        lastDate: Date?,
        targetInterval: TimeInterval,
        sinceLast: TimeInterval,
        onQuickRecord: @escaping () -> Void,
        onLongPress: @escaping () -> Void
    ) {
        self.title = title
        self.lastDate = lastDate
        self.targetInterval = max(targetInterval, 1)
        self.sinceLast = max(sinceLast, 0)
        self.onQuickRecord = onQuickRecord
        self.onLongPress = onLongPress
    }

    // ===== Derived UI values =====
    private var progress: CGFloat {
        // 🔥 修復：使用安全的進度計算，避免除零
        let safeTarget = max(targetInterval, 1) // 確保分母不為 0
        return CGFloat(min(sinceLast / safeTarget, 1.0))
    }

    private var progressLabel: String {
        // 🔥 修復：使用安全的統計計算，避免 0/0/0 顯示
        let elapsedDays = DateMath.safeDaysFrom(sinceLast)
        let targetDays = DateMath.safeDaysFrom(targetInterval)
        let dueInDays = max(targetDays - elapsedDays, 0)
        
        // 確保所有值都有合理的保底
        let safeElapsed = max(elapsedDays, 0)
        let safeTarget = max(targetDays, 1) // 最小 1 天
        let safeDueIn = max(dueInDays, 0)
        
        // Format the progress line manually
        let elapsedFormatted = StatsEngine.formatInterval(safeElapsed, unit: StatsUnit.days)
        let targetFormatted = StatsEngine.formatInterval(safeTarget, unit: StatsUnit.days)
        let dueFormatted = StatsEngine.formatInterval(safeDueIn, unit: StatsUnit.days)
        
        return "\(elapsedFormatted) / \(targetFormatted) · due in \(dueFormatted)"
    }

    private var lastLine: String {
        guard let lastDate else { return "No record" }
        let diff = Date().timeIntervalSince(lastDate)
        return "Last \(diff.toReadableAgo(unitPreference: .days))"
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 標題列（維持你原本字型）
            HStack(alignment: .firstTextBaseline) {
                Text(title)
                    .font(.system(size: 26, weight: .bold, design: .rounded))

                Spacer()

                // 右上角小膠囊顯示週期（與你右圖一致）
                Text(targetInterval.toReadableShort(unitPreference: .days))
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary.opacity(0.75))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial, in: Capsule())
            }

            // 「Last … ago」
            HStack(spacing: 8) {
                Image(systemName: "clock.badge")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.primary.opacity(0.6))
                Text(lastLine)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary.opacity(0.65))
            }

            // ✅ 新版漂亮進度條（取代舊的）- 玻璃風無中間圓點
            PillProgressBar(progress: Double(progress), label: progressLabel)
                .padding(.horizontal, 4)
                .padding(.top, 6)

            // 你的「Quick Record」等操作按鈕（保留原樣）
            Button {
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                onQuickRecord()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Quick Record")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial, in: Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(
            // 卡片玻璃：和你右圖一致的柔霧感
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .strokeBorder(.white.opacity(0.20), lineWidth: 1)
                        .blendMode(.overlay)
                )
                .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 12)
        )
        .contentShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .onLongPressGesture(minimumDuration: 0.35) {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            onLongPress()
        }
    }
}
