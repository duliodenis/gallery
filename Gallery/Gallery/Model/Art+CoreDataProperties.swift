//
//  Art+CoreDataProperties.swift
//  Gallery
//
//  Created by Dulio Denis on 4/8/16.
//  Copyright © 2016 Dulio Denis. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Art {

    @NSManaged var title: String?
    @NSManaged var imageName: String?
    @NSManaged var purchased: NSNumber?
    @NSManaged var productIdentifier: String?

}
