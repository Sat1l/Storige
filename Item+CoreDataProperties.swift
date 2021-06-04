//
//  Item+CoreDataProperties.swift
//  Storige
//
//  Created by Максим Сателайт on 03.06.2021.
//
//

import Foundation
import CoreData

extension Item {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Item> {
        return NSFetchRequest<Item>(entityName: "Item")
    }
    @NSManaged public var amount: Int64
    @NSManaged public var creationDate: Date?
    @NSManaged public var isOnDeleted: Bool
    @NSManaged public var itemid: UUID?
    @NSManaged public var journalNum: String?
    @NSManaged public var serialNum: String?
    @NSManaged public var container: Container?
}

extension Item : Identifiable {}
