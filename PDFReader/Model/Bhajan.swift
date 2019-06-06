//
//  Bhajan.swift
//  PDFReader
//
//  Created by Hitz on 5/21/19.
//  Copyright © 2019 Hitz. All rights reserved.
//

import Foundation

struct Bhajan {
    // MARK:- Properties
    let id: Int
    let name: String
    let fileUrl: URL
    let uploaddate: String
    let index: Int
    var downloaded = false
    
    init(id: Int, name: String, fileUrl: URL, uploaddate: String, index: Int) {
        self.id = id
        self.name = name
        self.fileUrl = fileUrl
        self.uploaddate = uploaddate
        self.index = index
    }
}
