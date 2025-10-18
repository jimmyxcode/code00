//
//  GradientTextButton.swift
//  LifeEveryday
//
//  Created by jimmyxcode on 18/10/2025.
//

import SwiftUI
import UIKit

/// 可重用的漸層文字按鈕（透明底）
/// - 樣式：18 / semibold / rounded、粉→淡藍
/// - isAnimating = true 時會做輕微色相動畫（用作「同步中」視覺）
/// - 透明底，僅以文字遮罩呈現漸層，不會影響背景與排版
public struct GradientTextButton: View {
    public let title: String
    public var isAnimating: Bool
    public var action: () -> Void

    @State private var hue: Double = 0

    public init(title: String, isAnimating: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.isAnimating = isAnimating
        self.action = action
    }

    public var body: some View {
        Button {
            // 輕觸回饋
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            action()
        } label: {
            ZStack {
                // 細陰影：在亮底仍清楚（透明底、不改版面）
                Text(title)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(.black.opacity(0.10))
                    .offset(y: 0.5)

                // 漸層文字（粉→淡藍），透明底以 mask 呈現
                LinearGradient(
                    colors: [
                        Color(red: 0.98, green: 0.66, blue: 0.86), // 粉
                        Color(red: 0.72, green: 0.80, blue: 1.00)  // 淡藍
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .hueRotation(.degrees(hue)) // 同步時做輕微色相旋轉
                .mask(
                    Text(title)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                )
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 10)
            .contentShape(Rectangle()) // 透明也好點擊
            .animation(.linear(duration: 1.2).repeatForever(autoreverses: true), value: hue)
            .onChange(of: isAnimating) { _, anim in
                hue = anim ? 15 : 0
            }
        }
        .buttonStyle(.plain)
        .fixedSize()
        .accessibilityLabel(Text(title))
    }
}
