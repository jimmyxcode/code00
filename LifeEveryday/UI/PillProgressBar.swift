// MARK: - ➊ 新增檔：UI/PillProgressBar.swift
import SwiftUI

/// 玻璃風膠囊進度條（無中間定位點），支援即時動畫更新
public struct PillProgressBar: View {
    /// 0...1
    public var progress: Double
    /// 內文（例如：`11 d / 31 d · due in 21 d`）
    public var label: String
    public var height: CGFloat = 28

    /// 與卡片相同的漸層色（參考舊版美觀）
    private var fillGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 1.00, green: 0.80, blue: 0.92, opacity: 1.0), // 淡粉
                Color(red: 0.87, green: 0.80, blue: 1.00, opacity: 1.0), // 淡紫
                Color(red: 0.78, green: 0.88, blue: 1.00, opacity: 1.0)  // 淡藍
            ],
            startPoint: .leading, endPoint: .trailing
        )
    }

    /// 背景玻璃質感（極淡白 + 內陰影）
    private var trackBackground: some View {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(.white.opacity(0.10))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(.white.opacity(0.35), lineWidth: 0.5)
            )
            .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
    }

    public init(progress: Double, label: String, height: CGFloat = 28) {
        self.progress = progress.clamped(to: 0...1)
        self.label = label
        self.height = height
    }

    public var body: some View {
        // 進度條高度可微調以接近舊圖
        ZStack {
            // Track
            trackBackground

            // Fill
            GeometryReader { geo in
                let w = max(0, min(1, progress)) * geo.size.width
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(fillGradient)
                        .frame(width: w)

                    // 光澤：讓填充看起來「滑順」
                    LinearGradient(
                        colors: [.white.opacity(0.35), .white.opacity(0.0)],
                        startPoint: .top, endPoint: .bottom
                    )
                    .blendMode(.plusLighter)
                    .mask(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .frame(width: w)
                    )
                }
                .animation(.easeInOut(duration: 0.35), value: progress)
            }

            // 置中資訊：細一點、次要色
            Text(label)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .frame(height: height)
        .compositingGroup()
        .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
        .accessibilityLabel(Text(label))
    }
}

// MARK: - 通用小工具
fileprivate extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
