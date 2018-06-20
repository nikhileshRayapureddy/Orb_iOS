//
//  Banner+CoreDataProperties.swift
//  Orb
//
//  Created by Nikhilesh on 22/05/18.
//  Copyright © 2018 Nikhilesh. All rights reserved.
//
//

import Foundation
import CoreData


extension Banner {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Banner> {
        return NSFetchRequest<Banner>(entityName: "Banner")
    }

    @NSManaged public var fileUrl: String?
    @NSManaged public var bannerimage: String?
    @NSManaged public var brandType: String?
    @NSManaged public var button_text: String?
    @NSManaged public var adFileType: String?
    @NSManaged public var latitude: Float
    @NSManaged public var longitude: Float
    @NSManaged public var zipcodes: String?
    @NSManaged public var fileKey: String?
    @NSManaged public var uploaded_by: String?
    @NSManaged public var shareLink: String?
    @NSManaged public var count: Int16
    @NSManaged public var showCount: Int16

}
