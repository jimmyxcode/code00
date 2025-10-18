//
//  SettingsStore.swift
//  LifeEveryday
//
//  Created by jimmyxcode on 18/10/2025.
//

import Foundation
import SwiftUI

class SettingsStore: ObservableObject {
    static let shared = SettingsStore()
    
    @Published var use24HourTime: Bool = false
    @Published var screenAlwaysOn: Bool = false
    @Published var useFahrenheit: Bool = false
    @Published var openWhenCharging: Bool = false
    @Published var mobileScreensaverTiming: Int = 5
    @Published var icloudSyncEnabled: Bool = true
    
    private init() {
        loadSettings()
    }
    
    private func loadSettings() {
        // 從 UserDefaults 載入設定
        use24HourTime = UserDefaults.standard.bool(forKey: "use24HourTime")
        screenAlwaysOn = UserDefaults.standard.bool(forKey: "screenAlwaysOn")
        useFahrenheit = UserDefaults.standard.bool(forKey: "useFahrenheit")
        openWhenCharging = UserDefaults.standard.bool(forKey: "openWhenCharging")
        mobileScreensaverTiming = UserDefaults.standard.integer(forKey: "mobileScreensaverTiming")
        if mobileScreensaverTiming == 0 { mobileScreensaverTiming = 5 }
        icloudSyncEnabled = UserDefaults.standard.bool(forKey: "icloudSyncEnabled")
    }
    
    func saveSettings() {
        UserDefaults.standard.set(use24HourTime, forKey: "use24HourTime")
        UserDefaults.standard.set(screenAlwaysOn, forKey: "screenAlwaysOn")
        UserDefaults.standard.set(useFahrenheit, forKey: "useFahrenheit")
        UserDefaults.standard.set(openWhenCharging, forKey: "openWhenCharging")
        UserDefaults.standard.set(mobileScreensaverTiming, forKey: "mobileScreensaverTiming")
        UserDefaults.standard.set(icloudSyncEnabled, forKey: "icloudSyncEnabled")
    }
}
