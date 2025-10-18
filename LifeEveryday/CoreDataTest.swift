//
//  CoreDataTest.swift
//  LifeEveryday
//
//  Created by jimmyxcode on 16/10/2025.
//

import Foundation
import CoreData

/// 測試 Core Data 模型載入
class CoreDataTest {
    static func testModelLoading() {
        print("🔍 測試 Core Data 模型載入...")
        
        // 嘗試載入模型
        guard let modelURL = Bundle.main.url(forResource: "LifeEveryday", withExtension: "momd") else {
            print("❌ 找不到 LifeEveryday.momd 檔案")
            return
        }
        
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            print("❌ 無法載入 NSManagedObjectModel")
            return
        }
        
        print("✅ 成功載入 NSManagedObjectModel")
        print("📋 載入的實體:", model.entitiesByName.keys.sorted())
        
        // 檢查特定實體
        if let cdEventEntity = model.entitiesByName["CDEvent"] {
            print("✅ CDEvent 實體存在")
            print("   - 屬性:", cdEventEntity.attributesByName.keys.sorted())
            print("   - 關係:", cdEventEntity.relationshipsByName.keys.sorted())
        } else {
            print("❌ CDEvent 實體不存在")
        }
        
        if let cdEntryEntity = model.entitiesByName["CDEntry"] {
            print("✅ CDEntry 實體存在")
        } else {
            print("❌ CDEntry 實體不存在")
        }
        
        if let cdChangeLogEntity = model.entitiesByName["CDChangeLog"] {
            print("✅ CDChangeLog 實體存在")
        } else {
            print("❌ CDChangeLog 實體不存在")
        }
    }
}
