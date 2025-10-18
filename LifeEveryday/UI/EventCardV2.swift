// MARK: - 3) EventCardV2
import SwiftUI

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
        CGFloat(min(sinceLast / targetInterval, 1.0))
    }

           private var progressLabel: String {
               // Convert seconds to days for StatsEngine
               let elapsedDays = sinceLast / 86400
               let targetDays = targetInterval / 86400
               let dueInDays = max(targetDays - elapsedDays, 0)
               
               // Format the progress line manually
               let elapsedFormatted = StatsEngine.formatInterval(elapsedDays, unit: StatsUnit.days)
               let targetFormatted = StatsEngine.formatInterval(targetDays, unit: StatsUnit.days)
               let dueFormatted = StatsEngine.formatInterval(dueInDays, unit: StatsUnit.days)
               
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
