//
//  HomeTopBar.swift
//  LifeEveryday
//
//  Created by jimmyxcode on 18/10/2025.
//

import SwiftUI

/// 置頂固定的頂部欄（安全區內），左：LifeEveryday（同步）；右：Option（設定）
struct HomeTopBar: View {
    var onTapSync: () -> Void
    var isSyncing: Bool
    var onTapOption: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            // 左側：LifeEveryday 同步按鈕（透明底漸層文字）
            GradientTextButton(title: "LifeEveryday", isAnimating: isSyncing) {
                onTapSync()
            }

            Spacer(minLength: 0)

            // 右側：Option 設定按鈕（透明底漸層文字）
            GradientTextButton(title: "Option") {
                onTapOption()
            }
        }
        .padding(.horizontal, 12) // 與螢幕左右留白
        .padding(.top, 2)         // 與狀態列距離（如需再降可加大）
        .padding(.bottom, 6)
        .background(Color.clear)  // 頂欄本身透明
        .contentShape(Rectangle())
    }
}
