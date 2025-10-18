//
//  SyncManager.swift
//  LifeEveryday
//
//  Created by jimmyxcode on 16/10/2025.
//

import UIKit
import CoreData

@MainActor
final class SyncManager: ObservableObject {
    static let shared = SyncManager()
    private init() {}

    private var container: NSPersistentCloudKitContainer { PersistenceController.shared }
    @Published var isSyncing = false

    func syncNow() async {
        guard !isSyncing else { return }
        isSyncing = true

        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        do {
            // 1) 將所有變更寫入本地 store
            let ctx = container.viewContext
            if ctx.hasChanges { try ctx.save() }
            ctx.processPendingChanges()

            // 2) 觸發背景處理（讓 CloudKit adaptor 盡快推送）
            try await Task.sleep(nanoseconds: 150_000_000) // 0.15s 小等候，讓 adaptor 取到變更

            // 3) iOS 17+ 額外優化：讓 adaptor 醒來
            if #available(iOS 17.0, *) {
                try? await container.performBackgroundTask { _ in } // 讓 adaptor 醒來
            }

            // 4) 成功提示
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        } catch {
            print("Sync error:", error)
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }

        isSyncing = false
    }
}
