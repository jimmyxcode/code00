//
//  HomeView.swift
//  LifeEveryday
//
//  Created by jimmyxcode on 16/10/2025.
//

import SwiftUI
import UIKit

/// 主頁：背景固定於 ZStack 最底層；Header / Footer 以 safeAreaInset 固定；
/// ScrollView 只負責中間內容，避免把背景放入 ScrollView 導致擠位。
struct HomeView: View {
    @ObservedObject private var store: DataStore = .shared

    @State private var showSettings = false
    @State private var showAdd = false
    @State private var quickRecordTarget: LEEvent? = nil
    @State private var editingEvent: LEEvent? = nil        // ✅ 新增

    // 同步狀態（用於頂欄動畫）
    @State private var isSyncing = false

    var body: some View {
        ZStack {
            // ✅ 穩定背景：鋪滿、透明不攔截點擊
            StableBackgroundView(imageName: "background", style: .plain)
                .allowsHitTesting(false)

            // ✅ 內容
            content
        }
        // ✅ 把頂欄固定在 Safe Area 內，不受 ScrollView 影響
        .safeAreaInset(edge: .top) {
            HomeTopBar(
                onTapSync: { Task { await syncNow() } },
                isSyncing: isSyncing,
                onTapOption: { showSettings = true }
            )
        }
        // ✅ Footer 固定（不隨 Scroll 滾動）
        .safeAreaInset(edge: .bottom) { footerBar }
        .sheet(isPresented: $showSettings) { SettingsSheetView().presentationDetents([.large]) }
        .sheet(isPresented: $showAdd) { AddSheet().presentationDetents([.medium, .large]) }
        .sheet(item: $quickRecordTarget) { event in
            QuickRecordForEventSheet(event: event).presentationDetents([.medium, .large])
        }
        .sheet(item: $editingEvent) { event in             // ✅ 編輯 Sheet
            EditEventSheet(event: event).presentationDetents([.medium])
        }
    }

    // ✅ 新內容：只顯示「一活動一卡片」
    private var content: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {

                if store.events.isEmpty {
                    // 無資料 Empty State
                    VStack(spacing: 12) {
                        Text("No events yet")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                        Text("Create your first event to start tracking.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Button {
                            showAdd = true
                        } label: {
                            Text("Add Event")
                                .font(.subheadline.weight(.semibold))
                                .padding(.horizontal, 14).padding(.vertical, 8)
                                .background(.thinMaterial, in: Capsule())
                        }
                    }
                    .padding(28)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
                    .padding(.horizontal, 16)
                } else {
                    ForEach(store.events) { ev in
                        // 🔥 使用新的 EventCardV3，自動計算統計並訂閱 context 變化
                        EventCardV3(event: store.fetchEventObject(for: ev.id))
                            .onLongPressGesture(minimumDuration: 0.35) {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                editingEvent = ev
                            }
                            .padding(.horizontal, 16)
                    }
                    Spacer(minLength: 24)
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
    }

    // 手動同步（封裝震動與狀態）
    @MainActor
    private func syncNow() async {
        guard !isSyncing else { return }
        isSyncing = true
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()

        await SyncManager.shared.syncNow()

        UINotificationFeedbackGenerator().notificationOccurred(.success)
        isSyncing = false
    }

    // MARK: - Footer (About Me)
    private var footerBar: some View {
        HStack {
            Button(action: { /* showAbout = true（若已接 AboutUSv2） */ }) {
                Text("About Me")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .padding(.vertical, 12)
                    .padding(.horizontal, 18)
                    .background(.ultraThinMaterial, in: Capsule())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 10)
        .background(.clear)
    }

}

#Preview {
    HomeView()
        .preferredColorScheme(.light)
}
