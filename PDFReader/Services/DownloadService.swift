//
//  DownloadService.swift
//  PDFReader
//
//  Created by Hitz on 5/21/19.
//  Copyright © 2019 Hitz. All rights reserved.
//

import Foundation

// Downloads files and stores in local directory. allows to cancel, pause and resume downloads
class DownloadService {
    
    // Dictionary to maintain mapping between a URL and its active Download
    var activeDownloads: [URL: Download] = [:]
    
    // ViewController creates downloadSession
    var downloadsSession: URLSession!
    
    // MARK:- Download methods called by TableViewCell delegate methods
    func startDownload(_ bhajan: Bhajan) {
        // Initialize download with the file
        let download = Download(bhajan: bhajan)
        
        // Create URLSessionDownloadTask with file's url and set it to task using new session
        download.task = downloadsSession.downloadTask(with: bhajan.fileUrl)
        
        // Start the download task with resume()
        download.task!.resume()
        download.isDownloading = true
        activeDownloads[download.bhajan.fileUrl] = download
    }
    
    func pauseDownload(_ bhajan: Bhajan) {
        // Stop download of the file and save data for resume(if supported) to corresponding Download
        guard let download = activeDownloads[bhajan.fileUrl] else { return }
        if download.isDownloading {
            download.task?.cancel(byProducingResumeData: { (data) in
                download.resumeData = data
            })
            download.isDownloading = false
        }
    }
    
    func cancelDownload(_ bhajan: Bhajan) {
        // Cancel download of the file and remove its entry from activeDownloads
        if let download = activeDownloads[bhajan.fileUrl] {
            download.task?.cancel()
            activeDownloads[bhajan.fileUrl] = nil
        }
    }
    
    func resumeDownload(_ bhajan: Bhajan) {
        // Resume(if supported) or start download of file using resumeData saved for that file
        guard let download = activeDownloads[bhajan.fileUrl] else { return }
        if let resumeData = download.resumeData {
            download.task = downloadsSession.downloadTask(withResumeData: resumeData)
        } else {
            download.task = downloadsSession.downloadTask(with: download.bhajan.fileUrl)
        }
        download.task!.resume()
        download.isDownloading = true
    }
}
