//
//  PDFListCell.swift
//  PDFReader
//
//  Created by Hitz on 5/15/19.
//  Copyright © 2019 Hitz. All rights reserved.
//

import UIKit

protocol PDFListCellDelegate {
    func pauseTapped(_ cell: PDFListCell)
    func resumeTapped(_ cell: PDFListCell)
    func cancelTapped(_ cell: PDFListCell)
    func downloadTapped(_ cell: PDFListCell)
}

class PDFListCell: UITableViewCell {
    
    // Delegate identifies track for this cell & passes this to a download service method.
    var delegate: PDFListCellDelegate?

    @IBOutlet weak var pdfTitleLabel: UILabel!
    @IBOutlet weak var dateModifiedLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func downloadTapped(_ sender: Any) {
        delegate?.downloadTapped(self)
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        delegate?.cancelTapped(self)
    }
    
    @IBAction func pauseOrResumeTapped(_ sender: Any) {
        if(pauseButton.titleLabel?.text == "Pause") {
            delegate?.pauseTapped(self)
        } else {
            delegate?.resumeTapped(self)
        }
    }
    
    func configure(bhajan: Bhajan, downloaded: Bool, download: Download?) {
        pdfTitleLabel.text = bhajan.name
        dateModifiedLabel.text = bhajan.uploaddate
        
        // Show/hide download controls & progress info
        var showDownloadControls = false
        
        // Non-nil Download object means a download is in progress
        if let download = download {
            showDownloadControls = true
            let title = download.isDownloading ? "Pause" : "Resume"
            pauseButton.setTitle(title, for: .normal)
            // show something on progressLabel before getting update from delegate
            progressLabel.text = download.isDownloading ? "Downloading..." : "Paused"
        }
        
        // Show buttons if download is active
        pauseButton.isHidden = !showDownloadControls
        cancelButton.isHidden = !showDownloadControls
        progressView.isHidden = !showDownloadControls
        progressLabel.isHidden = !showDownloadControls
        
        // If the file is already downloaded, enable cell selection and hide buttons
        selectionStyle = downloaded ? UITableViewCell.SelectionStyle.gray : UITableViewCell.SelectionStyle.none
        downloadButton.isHidden = downloaded || showDownloadControls
    }
    
    func updateDisplay(progress: Float, totalSize: String) {
        progressView.progress = progress
        progressLabel.text = String(format: "%.1f%% of %@", progress * 100, totalSize)
    }

}
