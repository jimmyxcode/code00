//
//  LifeEverydayApp.swift
//  LifeEveryday
//
//  Created by jimmyxcode on 16/10/2025.
//

import SwiftUI

@main
struct LifeEverydayApp: App {
    @Environment(\.scenePhase) private var phase
    
    init() {
        // 測試 Core Data 模型載入
        CoreDataTest.testModelLoading()
    }
    
    var body: some Scene {
        WindowGroup { 
            HomeView()
        }
        .onChange(of: phase) { _, newPhase in
            if newPhase == .background {
                DataStore.shared.saveAndRefresh()
                try? BackupManager.exportJSON()
            }
        }
    }
}
