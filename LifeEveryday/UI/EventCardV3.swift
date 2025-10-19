// MARK: - EventCardV3 - 自動統計版本
import SwiftUI
import CoreData
import Combine

public struct EventCardV3: View {
    let event: NSManagedObject           // 事件 Entity
    @Environment(\.managedObjectContext) private var ctx
    @State private var stats: EventStats?
    @State private var cancellable: AnyCancellable?

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 標題列
            HStack(alignment: .firstTextBaseline) {
                Text(eventName)
                    .font(.system(size: 26, weight: .bold, design: .rounded))

                Spacer()

                // 右上角小膠囊顯示週期
                Text("\(Int(stats?.displayCycleDays ?? 30)) d")
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
                Text(lastText)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary.opacity(0.65))
            }

            // 進度條
            PillProgressBar(progress: stats?.progress ?? 0, label: bottomLine)
                .padding(.horizontal, 4)
                .padding(.top, 6)

            // Quick Record 按鈕
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
            // 卡片玻璃
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
        .onAppear {
            recompute()
            // 🔥 關鍵修復：訂閱 context didSave，有任何儲存就重算
            if cancellable == nil {
                cancellable = ctx.didSavePublisher.sink {
                    recompute()
                }
            }
        }
        .onDisappear {
            cancellable?.cancel()
            cancellable = nil
        }
    }

    private func recompute() {
        let dates = occurrenceDatesFromRelation(event)
        let createdAt = event.value(forKey: "createdAt") as? Date ?? Date()
        stats = StatsEngine.compute(
            createdAt: createdAt,
            entries: dates.sorted(by: >), // 由新到舊
            preferredUnit: .days,
            target: nil,
            now: Date()
        )
    }

    private var eventName: String {
        event.value(forKey: "name") as? String ?? "Untitled"
    }

    private var lastText: String {
        guard let lastDate = stats?.lastDate else { return "No record" }
        let daysAgo = DateMath.daysBetween(lastDate, Date())
        return "Last \(daysAgo) d ago"
    }

    private var bottomLine: String {
        let elapsed = Int(stats?.elapsedDays ?? 0)
        let avg = Int(stats?.displayCycleDays ?? 1)
        let due = Int(stats?.dueInDays ?? 0)
        return "\(elapsed) d / \(avg) d · due in \(max(0, due)) d"
    }
    
    private func onQuickRecord() {
        // 使用 DataStore 的 quickRecord 方法
        if let eventId = event.value(forKey: "id") as? UUID {
            DataStore.shared.quickRecord(eventId: eventId)
        }
    }
}

// MARK: - 從關聯直接取得日期（優先避免漏刷新）
private func occurrenceDatesFromRelation(_ event: NSManagedObject) -> [Date] {
    // 嘗試從關聯取得（優先）
    if let entries = event.value(forKey: "entries") as? Set<NSManagedObject> {
        return entries.compactMap { $0.value(forKey: "timestamp") as? Date }.sorted()
    }
    
    // 關聯取不到時再保險查一次
    guard let ctx = event.managedObjectContext else { return [] }
    let req = NSFetchRequest<NSManagedObject>(entityName: "CDEntry")
    req.predicate = NSPredicate(format: "event == %@", event)
    req.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]
    let rows = (try? ctx.fetch(req)) ?? []
    return rows.compactMap { $0.value(forKey: "timestamp") as? Date }
}
