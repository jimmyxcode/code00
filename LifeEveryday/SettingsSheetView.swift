//
//  SettingsSheetView.swift
//  LifeEveryday
//
//  Created by jimmyxcode on 16/10/2025.
//

import SwiftUI
import StoreKit

struct SettingsSheetView: View {
    @ObservedObject private var store = SettingsStore.shared
    @Environment(\.dismiss) private var dismiss

    // 匯入 / 匯出
    @State private var exporting = false
    @State private var exportDocument = JSONDocument(data: Data())
    @State private var importing = false
    @State private var importError: String?
    
    // Debug Snapshot
    @State private var shareURL: ShareableURL?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {

                    // Banner（保留你的設計）
                    banner

                    // ✅ Events：一行快速新增 + 管理
                    groupCard {
                        QuickAddInlineRow(
                            placeholder: "Type a new event name…",
                            buttonTitle: "Add"
                        ) { name in
                            DataStore.shared.addEvent(name: name)
                        }
                        Divider()
                        NavigationLink {
                            ManageEventsView() // 可選；你已有編輯/刪除流程也可指到那裡
                        } label: {
                            SettingNavRow(icon: "list.bullet", title: "Manage events", subtitle: "Rename or delete")
                        }
                    }

                    // 一般設定
                    groupCard {
                        SettingToggleRow(icon: "globe", title: "Use 24 hour time", isOn: $store.use24HourTime)
                        Divider()
                        SettingToggleRow(icon: "power.circle", title: "Screen is always on", isOn: $store.screenAlwaysOn)
                        Divider()
                        SettingToggleRow(icon: "thermometer", title: "Use F° for temperature", isOn: $store.useFahrenheit)
                    }

                    // 行為
                    groupCard {
                        SettingToggleRow(icon: "bolt.fill", title: "Open when charging", isOn: $store.openWhenCharging)
                        Divider()
                        NavigationLink {
                            TimingEditor(value: $store.mobileScreensaverTiming)
                        } label: {
                            SettingNavRow(icon: "clock.badge", title: "Mobile screensaver timing", subtitle: "\(store.mobileScreensaverTiming) min")
                        }
                    }

                    // iCloud
                    groupCard {
                        Toggle(isOn: Binding(
                            get: { store.icloudSyncEnabled },
                            set: { v in
                                store.icloudSyncEnabled = v
                                // 簡化：直接保存設定
                                store.saveSettings()
                            })
                        ) {
                            HStack(spacing: 12) {
                                IconCircle(system: "icloud")
                                VStack(alignment: .leading) {
                                    Text("iCloud Sync").fontWeight(.semibold)
                                    Text(store.icloudSyncEnabled ? "Enabled" : "Disabled")
                                        .font(.subheadline).foregroundStyle(.secondary)
                                }
                            }
                        }
                    }

                    // 匯入 / 匯出
                    groupCard {
                        Button {
                            do {
                                exportDocument = JSONDocument(data: try ImportExportManager.generateBackup())
                                exporting = true
                            } catch { importError = error.localizedDescription }
                        } label: { SettingButtonRow(icon: "square.and.arrow.up", title: "Export data") }

                        Divider()

                        Button { importing = true } label: {
                            SettingButtonRow(icon: "square.and.arrow.down", title: "Import data")
                        }
                        
                        Divider()
                        
                        Button {
                            if let url = DataStore.shared.exportDebugSnapshotToDisk() {
                                shareURL = ShareableURL(url: url)
                            }
                        } label: {
                            SettingButtonRow(icon: "ladybug", title: "Export Debug Snapshot")
                        }
                    }

                    // About
                    groupCard {
                        Button { /* TODO: 實作 About 頁面 */ } label: {
                            SettingButtonRow(icon: "person.text.rectangle", title: "About Me")
                        }
                    }

                    // 其他
                    groupCard {
                        Button { requestReview() } label: {
                            SettingButtonRow(icon: "star.fill", title: "Leave a review")
                        }
                        Divider()
                        Button { openAppStore() } label: {
                            SettingButtonRow(icon: "arrow.triangle.2.circlepath", title: "Check for update")
                        }
                        Divider()
                        Button { /* TODO: 實作 Widgets 教學 */ } label: {
                            SettingButtonRow(icon: "square.grid.2x2", title: "Widgets")
                        }
                        Divider()
                        Button { /* TODO: 實作重設導覽 */ } label: {
                            SettingButtonRow(icon: "arrow.clockwise.circle", title: "Restart onboarding")
                        }
                    }

                    Spacer(minLength: 16)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill").font(.title2)
                    }
                }
            }
        }
        // 匯出
        .fileExporter(isPresented: $exporting, document: exportDocument, contentType: .json, defaultFilename: "LifeEveryday-Backup") { result in
            if case let .failure(error) = result { importError = error.localizedDescription }
        }
        // 匯入
        .fileImporter(isPresented: $importing, allowedContentTypes: [.json]) { result in
            do {
                let url = try result.get()
                let data = try Data(contentsOf: url)
                try ImportExportManager.importBackup(data)
            } catch { importError = error.localizedDescription }
        }
        // Debug Snapshot Share
        .sheet(item: $shareURL) { shareableURL in
            ShareSheet(activityItems: [shareableURL.url])
        }
        .alert("Import/Export", isPresented: Binding(get: { importError != nil }, set: { _ in importError = nil })) {
            Button("OK", role: .cancel) {}
        } message: { Text(importError ?? "") }
    }

    // MARK: - Subviews（樣式保持你的既有風格）
    private var banner: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(LinearGradient(colors: [
                    Color(red: 0.98, green: 0.45, blue: 0.60),
                    Color(red: 0.48, green: 0.35, blue: 0.98),
                    Color(red: 0.31, green: 0.66, blue: 1.00)
                ], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(height: 140)
            Text("Clocks Pro Pack\nMore backgrounds, clocks,\nscreensavers and more.")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .padding(20)
        }
    }

    private func groupCard<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        VStack(spacing: 0) { content() }
            .padding(12)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    // 其他工具與 Row（沿用你既有的）
    private func requestReview() {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
    private func openAppStore() { if let url = URL(string: "https://apps.apple.com") { UIApplication.shared.open(url) } }
}

// MARK: - Reusable Rows
private struct SettingToggleRow: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool
    var body: some View {
        HStack {
            IconCircle(system: icon)
            Text(title).fontWeight(.semibold)
            Spacer()
            Toggle("", isOn: $isOn).labelsHidden()
        }
        .padding(.horizontal, 4)
        .frame(maxWidth: .infinity, minHeight: 44)
    }
}

private struct SettingNavRow: View {
    let icon: String
    let title: String
    let subtitle: String?
    var body: some View {
        HStack {
            IconCircle(system: icon)
            VStack(alignment: .leading) {
                Text(title).fontWeight(.semibold)
                if let s = subtitle {
                    Text(s).font(.subheadline).foregroundStyle(.secondary)
                }
            }
            Spacer()
            Image(systemName: "chevron.right").foregroundStyle(.secondary)
        }
        .padding(.horizontal, 4)
        .frame(maxWidth: .infinity, minHeight: 44)
    }
}

private struct SettingButtonRow: View {
    let icon: String
    let title: String
    var body: some View {
        HStack {
            IconCircle(system: icon)
            Text(title).fontWeight(.semibold)
            Spacer()
        }
        .padding(.horizontal, 4)
        .frame(maxWidth: .infinity, minHeight: 44)
    }
}

private struct IconCircle: View {
    let system: String
    var body: some View {
        Image(systemName: system)
            .font(.system(size: 16, weight: .semibold))
            .frame(width: 28, height: 28)
            .background(Color.gray.opacity(0.15), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private struct TimingEditor: View {
    @Binding var value: Int
    var body: some View {
        Form { Stepper("Minutes: \(value)", value: $value, in: 1...180, step: 1) }
            .navigationTitle("Screensaver Timing")
    }
}

/// 可選的管理頁（之後可放排序、批量刪除）
private struct ManageEventsView: View {
    @ObservedObject var store: DataStore = .shared
    var body: some View {
        List {
            ForEach(store.events) { e in
                Text(e.name)
            }
        }
        .navigationTitle("Manage Events")
    }
}

// MARK: - ShareSheet for Debug Snapshot
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {}
}

// MARK: - ShareableURL wrapper for Identifiable
struct ShareableURL: Identifiable {
    let id = UUID()
    let url: URL
}