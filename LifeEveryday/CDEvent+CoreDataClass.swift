//
//  CDEvent+CoreDataClass.swift
//  LifeEveryday
//
//  Created by jimmyxcode on 16/10/2025.
//

import Foundation
import CoreData

@objc(CDEvent)
public class CDEvent: NSManagedObject {

}

//
//  CDEvent+CoreDataProperties.swift
//  LifeEveryday
//
//  Created by jimmyxcode on 16/10/2025.
//

import Foundation
import CoreData

extension CDEvent {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDEvent> {
        return NSFetchRequest<CDEvent>(entityName: "CDEvent")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var unitRaw: String?
    @NSManaged public var isArchived: Bool
    @NSManaged public var entries: NSSet?

}

// MARK: Generated accessors for entries
extension CDEvent {

    @objc(addEntriesObject:)
    @NSManaged public func addToEntries(_ value: CDEntry)

    @objc(removeEntriesObject:)
    @NSManaged public func removeFromEntries(_ value: CDEntry)

    @objc(addEntries:)
    @NSManaged public func addToEntries(_ values: NSSet)

    @objc(removeEntries:)
    @NSManaged public func removeFromEntries(_ values: NSSet)

}
