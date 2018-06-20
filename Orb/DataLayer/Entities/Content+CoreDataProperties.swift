//
//  Content+CoreDataProperties.swift
//  Orb
//
//  Created by Nikhilesh on 07/05/18.
//  Copyright © 2018 Nikhilesh. All rights reserved.
//
//

import Foundation
import CoreData


extension Content {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Content> {
        return NSFetchRequest<Content>(entityName: "Content")
    }

    @NSManaged public var channel: String?
    @NSManaged public var duration: Double
    @NSManaged public var fileKey: String?
    @NSManaged public var fileUrl: String?
    @NSManaged public var language: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var provided_by: String?
    @NSManaged public var thumbnail: String?
    @NSManaged public var title: String?
    @NSManaged public var uploaded_by: String?
    @NSManaged public var isTrending: Bool

}
