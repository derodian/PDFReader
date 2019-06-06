//
//  PDFListVC+URLSessionDelegates.swift
//  PDFReader
//
//  Created by Hitz on 5/21/19.
//  Copyright © 2019 Hitz. All rights reserved.
//

import Foundation
import UIKit

extension PDFListVC: URLSessionDownloadDelegate {
    // URLSessionDownloadDelegate protocol method called when a download is finished.
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("Finished downloading to: \(location)")
        
        // Extract original request URL from task and remove corresponding Download from that dictionary
        guard let sourceURL =  downloadTask.originalRequest?.url else { return }
        let download = downloadService.activeDownloads[sourceURL]
        downloadService.activeDownloads[sourceURL] = nil
        
        // Pass sourceURL to localFilepath helper method in VC to generate permanent filepath
        let destinationURL = localFilePath(for: sourceURL)
        print(destinationURL)
        
        // Move downloaded file from temp directory to desired destination directory and set downloaded property to true
        let fileManager = FileManager.default
        try? fileManager.removeItem(at: destinationURL)
        do {
            try fileManager.copyItem(at: location, to: destinationURL)
            download?.bhajan.downloaded = true
        } catch let error {
            print("Could not copy file to disk: \(error.localizedDescription)")
        }
        
        // Reload selected cell using bhajan's index property
        if let index = download?.bhajan.index {
            
            // Set bhajan's downloaded value to true to dismiss download button and make it selectable
            self.bhajans[index].downloaded = true
            DispatchQueue.main.async {
                self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                print("Cell updated...")
            }
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        if totalBytesExpectedToWrite > 0 {
            // Get url of downloadTask and use it to find matching Download
            guard let url = downloadTask.originalRequest?.url, let download = downloadService.activeDownloads[url] else { return }
            
            // Calculate ratio of total bytes written & expected to be written and save result to Download
            download.progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
            
            // Format byte value to human-readable string
            let totalSize = ByteCountFormatter.string(fromByteCount: totalBytesExpectedToWrite, countStyle: .file)
            
            // Find cell responsible for displaying the file and call cell's helper method to update progress
            DispatchQueue.main.async {
                if let pdfListCell = self.tableView.cellForRow(at: IndexPath(row: download.bhajan.index, section: 0)) as? PDFListCell {
                    pdfListCell.updateDisplay(progress: download.progress, totalSize: totalSize)
                }
            }
        }
    }
}

// For Background Transfer
extension PDFListVC: URLSessionDelegate {
    // Standard background session handler
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate, let completionHandler = appDelegate.backgroundSessionCompletionHandler {
                appDelegate.backgroundSessionCompletionHandler = nil
                completionHandler()
            }
        }
    }
}
