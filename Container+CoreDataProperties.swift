//
//  Container+CoreDataProperties.swift
//  Storige
//
//  Created by Максим Сателайт on 03.06.2021.
//
//

import Foundation
import CoreData


extension Container {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Container> {
        return NSFetchRequest<Container>(entityName: "Container")
    }

    @NSManaged public var name: String?
    @NSManaged public var containerid: UUID?
    @NSManaged public var items: NSSet?

    public var itemArray: [Item] {
        let set = items as? Set<Item> ?? []
        return set.sorted {
            $0.journalNum! < $1.journalNum!
        }
    }
    
}

// MARK: Generated accessors for items
extension Container {

    @objc(addItemsObject:)
    @NSManaged public func addToItems(_ value: Item)

    @objc(removeItemsObject:)
    @NSManaged public func removeFromItems(_ value: Item)

    @objc(addItems:)
    @NSManaged public func addToItems(_ values: NSSet)

    @objc(removeItems:)
    @NSManaged public func removeFromItems(_ values: NSSet)

}

extension Container : Identifiable {

}
