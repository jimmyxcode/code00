//
//  PersistenceController.swift
//  LifeEveryday
//
//  Created by jimmyxcode on 16/10/2025.
//

import CoreData

enum PersistenceController {
    static let shared = make()

    static func make(inMemory: Bool = false) -> NSPersistentCloudKitContainer {
        // 使用程式化創建的模型
        let model = CoreDataModelBuilder.createModel()
        print("✅ 成功創建程式化 Core Data 模型")
        
        let container = NSPersistentCloudKitContainer(name: "LifeEveryday", managedObjectModel: model)

        let storeURL = NSPersistentContainer.defaultDirectoryURL()
            .appendingPathComponent("LifeEveryday.sqlite")
        let desc = NSPersistentStoreDescription(url: storeURL)

        // ⚠️ 使用你在 Capabilities 勾選的同一容器
        desc.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(
            containerIdentifier: "iCloud.com.jimmylo.LifeEveryday"
        )

        // 永不丟資料的關鍵：歷史追蹤 + 遠端變更通知 + 輕量遷移
        desc.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        desc.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        desc.shouldMigrateStoreAutomatically = true
        desc.shouldInferMappingModelAutomatically = true

        if inMemory { desc.url = URL(fileURLWithPath: "/dev/null") }

        container.persistentStoreDescriptions = [desc]
        container.loadPersistentStores { _, error in
            if let error = error { fatalError("CoreData load error: \(error)") } // ⚠️ 切勿在此刪庫
        }

        // Debug: 列出載入的實體
        print("Loaded Entities:", container.managedObjectModel.entitiesByName.keys.sorted())

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy // 或 ObjectTrump 馬上換亦可

        // CloudKit 遠端變更 → 通知 UI 重算
        NotificationCenter.default.addObserver(
            forName: .NSPersistentStoreRemoteChange,
            object: container.persistentStoreCoordinator,
            queue: .main
        ) { _ in
            NotificationCenter.default.post(name: .dataStoreDidChange, object: nil)
        }

        return container
    }
}

extension NSPersistentCloudKitContainer {
    var context: NSManagedObjectContext { viewContext }
}
