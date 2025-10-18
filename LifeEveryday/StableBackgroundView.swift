//
//  StableBackgroundView.swift
//  LifeEveryday
//
//  Created by jimmyxcode on 16/10/2025.
//

import SwiftUI

/// 穩定、不可滾動的全螢幕背景：
/// - 只裁切不變形（aspectFill）
/// - 不攔截點擊
/// - 可選純背景或帶遮罩背景
public struct StableBackgroundView: View {
    public enum Style: Equatable {
        /// 完全忠實輸出原圖（不加暗角、不加噪點）
        case plain
        /// 加入柔和漸層與噪點以提升前景可讀性（可調整強度）
        case softMask(gradientOpacity: Double = 0.18, noiseOpacity: Double = 0.06)
    }

    private let imageName: String
    private let style: Style

    /// - Parameters:
    ///   - imageName: Assets.xcassets 的圖片名稱
    ///   - style: 顯示風格（預設 .plain 以保持與原圖一致）
    public init(imageName: String = "background", style: Style = .plain) {
        self.imageName = imageName
        self.style = style
    }

    public var body: some View {
        GeometryReader { geo in
            ZStack {
                // 1) 圖片或 fallback
                if UIImage(named: imageName) != nil {
                    Image(imageName)
                        .resizable()
                        .renderingMode(.original)              // ✅ 禁止系統 tint
                        .interpolation(.high)
                        .antialiased(true)
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                } else {
                    // Fallback：安全漸層（若圖片讀不到）
                    LinearGradient(
                        colors: [
                            Color(red: 0.60, green: 0.52, blue: 0.98),
                            Color(red: 0.92, green: 0.72, blue: 0.96)
                        ],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                }

                // 2) 可選遮罩/噪點
                switch style {
                case .plain:
                    EmptyView() // 什麼都不疊，原圖 1:1 呈現
                case .softMask(let gradientOpacity, let noiseOpacity):
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: .black.opacity(gradientOpacity * 0.6), location: 0.0),
                            .init(color: .black.opacity(gradientOpacity), location: 0.45),
                            .init(color: .black.opacity(gradientOpacity * 1.4), location: 1.0)
                        ]),
                        startPoint: .top, endPoint: .bottom
                    )
                    NoiseOverlay()
                        .blendMode(.overlay)
                        .opacity(noiseOpacity)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

/// 輕量噪點：以 SwiftUI Canvas 動態產生（不依賴外部資源）
private struct NoiseOverlay: View {
    var body: some View {
        Canvas { context, size in
            // 以小塊隨機透明度繪製簡單噪點
            let cell: CGFloat = 6
            for x in stride(from: 0, to: size.width, by: cell) {
                for y in stride(from: 0, to: size.height, by: cell) {
                    let opacity = Double.random(in: 0.0...0.35)
                    let gray = Double.random(in: 0.45...0.55)
                    let color = Color(white: gray, opacity: opacity)
                    context.fill(
                        Path(CGRect(x: x, y: y, width: cell, height: cell)),
                        with: .color(color)
                    )
                }
            }
        }
        .drawingGroup(opaque: false, colorMode: .linear)
    }
}
