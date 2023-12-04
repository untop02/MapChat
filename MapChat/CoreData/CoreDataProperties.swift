//
//  CoreDataProperties.swift
//  MapChat
//
//  Created by niilou on 4.12.2023.
//

import Foundation
import CoreData

extension Messages {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Messages> {
            return NSFetchRequest<Messages>(entityName: "Messages")
        }

        @NSManaged public var title: String?
        @NSManaged public var text: String?
        @NSManaged public var timeAndDate: Date?
        @NSManaged public var cordLat: Double
        @NSManaged public var cordLong: Double
}

