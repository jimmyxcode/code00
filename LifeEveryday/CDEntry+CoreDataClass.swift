//
//  CDEntry+CoreDataClass.swift
//  LifeEveryday
//
//  Created by jimmyxcode on 16/10/2025.
//

import Foundation
import CoreData

@objc(CDEntry)
public class CDEntry: NSManagedObject {

}

//
//  CDEntry+CoreDataProperties.swift
//  LifeEveryday
//
//  Created by jimmyxcode on 16/10/2025.
//

import Foundation
import CoreData

extension CDEntry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDEntry> {
        return NSFetchRequest<CDEntry>(entityName: "CDEntry")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var timestamp: Date?
    @NSManaged public var note: String?
    @NSManaged public var event: CDEvent?

}
