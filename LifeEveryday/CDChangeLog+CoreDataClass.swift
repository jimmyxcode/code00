//
//  CDChangeLog+CoreDataClass.swift
//  LifeEveryday
//
//  Created by jimmyxcode on 16/10/2025.
//

import Foundation
import CoreData

@objc(CDChangeLog)
public class CDChangeLog: NSManagedObject {

}

//
//  CDChangeLog+CoreDataProperties.swift
//  LifeEveryday
//
//  Created by jimmyxcode on 16/10/2025.
//

import Foundation
import CoreData

extension CDChangeLog {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDChangeLog> {
        return NSFetchRequest<CDChangeLog>(entityName: "CDChangeLog")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var createdAt: Date?
    @NSManaged public var entityName: String?
    @NSManaged public var entityId: UUID?
    @NSManaged public var action: String?
    @NSManaged public var payload: String?

}
