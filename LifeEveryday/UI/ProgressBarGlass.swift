// PATH: LifeEveryday/UI/ProgressBarGlass.swift
import SwiftUI

struct ProgressBarGlass: View {
    var ratio: Double        // 0...1
    var label: String        // 如 "3d left" / "Due today" / "Overdue 2d"
    
    var body: some View {
        // 底：玻璃材質 + 邊框高光
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.35), lineWidth: 1)
                }
                .shadow(color: .black.opacity(0.08), radius: 12, y: 6)
            
            // 進度填充：柔和漸層（粉 → 淡藍），帶一點光暈
            GeometryReader { geo in
                let w = max(6, geo.size.width * CGFloat(max(0, min(1, ratio))))
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.98, green: 0.66, blue: 0.86), // 粉
                                Color(red: 0.72, green: 0.80, blue: 1.00)  // 淡藍
                            ],
                            startPoint: .leading, endPoint: .trailing
                        )
                    )
                    .frame(width: w)
                    .overlay(alignment: .topLeading) {
                        LinearGradient(
                            colors: [Color.white.opacity(0.35), .clear],
                            startPoint: .top, endPoint: .bottom
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
            }
        }
        .overlay {
            // 置中資訊（動態字體友好）
            Text(label)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.primary.opacity(0.85))
                .padding(.horizontal, 12)
        }
        .frame(height: 22)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Progress"))
        .accessibilityValue(Text(label))
    }
}
