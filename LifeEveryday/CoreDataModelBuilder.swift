//
//  CoreDataModelBuilder.swift
//  LifeEveryday
//
//  Created by jimmyxcode on 16/10/2025.
//

import Foundation
import CoreData

/// 程式化創建 Core Data 模型
class CoreDataModelBuilder {
    static func createModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()
        
        // 創建 CDEvent 實體
        let cdEventEntity = NSEntityDescription()
        cdEventEntity.name = "CDEvent"
        cdEventEntity.managedObjectClassName = "CDEvent"
        
        // CDEvent 屬性
        let idAttribute = NSAttributeDescription()
        idAttribute.name = "id"
        idAttribute.attributeType = .UUIDAttributeType
        idAttribute.isOptional = false
        idAttribute.defaultValue = UUID()
        
        let nameAttribute = NSAttributeDescription()
        nameAttribute.name = "name"
        nameAttribute.attributeType = .stringAttributeType
        nameAttribute.isOptional = false
        nameAttribute.defaultValue = ""
        
        let createdAtAttribute = NSAttributeDescription()
        createdAtAttribute.name = "createdAt"
        createdAtAttribute.attributeType = .dateAttributeType
        createdAtAttribute.isOptional = false
        createdAtAttribute.defaultValue = Date()
        
        let unitRawAttribute = NSAttributeDescription()
        unitRawAttribute.name = "unitRaw"
        unitRawAttribute.attributeType = .stringAttributeType
        unitRawAttribute.isOptional = false
        unitRawAttribute.defaultValue = "days"
        
        let isArchivedAttribute = NSAttributeDescription()
        isArchivedAttribute.name = "isArchived"
        isArchivedAttribute.attributeType = .booleanAttributeType
        isArchivedAttribute.isOptional = true
        isArchivedAttribute.defaultValue = false
        
        cdEventEntity.properties = [idAttribute, nameAttribute, createdAtAttribute, unitRawAttribute, isArchivedAttribute]
        
        // 創建 CDEntry 實體
        let cdEntryEntity = NSEntityDescription()
        cdEntryEntity.name = "CDEntry"
        cdEntryEntity.managedObjectClassName = "CDEntry"
        
        // CDEntry 屬性
        let entryIdAttribute = NSAttributeDescription()
        entryIdAttribute.name = "id"
        entryIdAttribute.attributeType = .UUIDAttributeType
        entryIdAttribute.isOptional = false
        entryIdAttribute.defaultValue = UUID()
        
        let timestampAttribute = NSAttributeDescription()
        timestampAttribute.name = "timestamp"
        timestampAttribute.attributeType = .dateAttributeType
        timestampAttribute.isOptional = false
        timestampAttribute.defaultValue = Date()
        
        let noteAttribute = NSAttributeDescription()
        noteAttribute.name = "note"
        noteAttribute.attributeType = .stringAttributeType
        noteAttribute.isOptional = true
        
        cdEntryEntity.properties = [entryIdAttribute, timestampAttribute, noteAttribute]
        
        // 創建 CDChangeLog 實體
        let cdChangeLogEntity = NSEntityDescription()
        cdChangeLogEntity.name = "CDChangeLog"
        cdChangeLogEntity.managedObjectClassName = "CDChangeLog"
        
        // CDChangeLog 屬性
        let logIdAttribute = NSAttributeDescription()
        logIdAttribute.name = "id"
        logIdAttribute.attributeType = .UUIDAttributeType
        logIdAttribute.isOptional = false
        logIdAttribute.defaultValue = UUID()
        
        let logCreatedAtAttribute = NSAttributeDescription()
        logCreatedAtAttribute.name = "createdAt"
        logCreatedAtAttribute.attributeType = .dateAttributeType
        logCreatedAtAttribute.isOptional = false
        logCreatedAtAttribute.defaultValue = Date()
        
        let entityNameAttribute = NSAttributeDescription()
        entityNameAttribute.name = "entityName"
        entityNameAttribute.attributeType = .stringAttributeType
        entityNameAttribute.isOptional = false
        entityNameAttribute.defaultValue = ""
        
        let entityIdAttribute = NSAttributeDescription()
        entityIdAttribute.name = "entityId"
        entityIdAttribute.attributeType = .UUIDAttributeType
        entityIdAttribute.isOptional = false
        entityIdAttribute.defaultValue = UUID()
        
        let actionAttribute = NSAttributeDescription()
        actionAttribute.name = "action"
        actionAttribute.attributeType = .stringAttributeType
        actionAttribute.isOptional = false
        actionAttribute.defaultValue = ""
        
        let payloadAttribute = NSAttributeDescription()
        payloadAttribute.name = "payload"
        payloadAttribute.attributeType = .stringAttributeType
        payloadAttribute.isOptional = true
        
        cdChangeLogEntity.properties = [logIdAttribute, logCreatedAtAttribute, entityNameAttribute, entityIdAttribute, actionAttribute, payloadAttribute]
        
        // 建立關係
        let entriesRelationship = NSRelationshipDescription()
        entriesRelationship.name = "entries"
        entriesRelationship.destinationEntity = cdEntryEntity
        entriesRelationship.maxCount = 0 // toMany
        entriesRelationship.deleteRule = .cascadeDeleteRule
        
        let eventRelationship = NSRelationshipDescription()
        eventRelationship.name = "event"
        eventRelationship.destinationEntity = cdEventEntity
        eventRelationship.maxCount = 1 // toOne
        eventRelationship.deleteRule = .nullifyDeleteRule
        
        // 設定反向關係
        entriesRelationship.inverseRelationship = eventRelationship
        eventRelationship.inverseRelationship = entriesRelationship
        
        // 將關係添加到實體
        cdEventEntity.properties.append(entriesRelationship)
        cdEntryEntity.properties.append(eventRelationship)
        
        // 將實體添加到模型
        model.entities = [cdEventEntity, cdEntryEntity, cdChangeLogEntity]
        
        return model
    }
}
