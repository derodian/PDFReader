//
//  PDFFiles+CoreDataProperties.swift
//  PDFReader
//
//  Created by Hitz on 6/5/19.
//  Copyright © 2019 Hitz. All rights reserved.
//
//

import Foundation
import CoreData


extension PDFFiles {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PDFFiles> {
        return NSFetchRequest<PDFFiles>(entityName: "PDFFiles")
    }

    @NSManaged public var downloaded: Bool
    @NSManaged public var index: Int32
    @NSManaged public var uploaddate: String?
    @NSManaged public var fileurl: String?
    @NSManaged public var name: String?
    @NSManaged public var id: Int32

}
