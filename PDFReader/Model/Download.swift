//
//  Download.swift
//  PDFReader
//
//  Created by Hitz on 5/21/19.
//  Copyright © 2019 Hitz. All rights reserved.
//

import Foundation

class Download {
    
    var bhajan: Bhajan
    init(bhajan: Bhajan) {
        self.bhajan = bhajan
    }
    
    // Download service sets these values:
    var task: URLSessionDownloadTask?
    var isDownloading = false
    var resumeData: Data?
    
    // Download delegate sets this value:
    var progress: Float = 0
}
