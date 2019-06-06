//
//  PDFListVC.swift
//  PDFReader
//
//  Created by Hitz on 5/15/19.
//  Copyright © 2019 Hitz. All rights reserved.
//

import UIKit
import PDFKit

class PDFListVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var bhajans: [Bhajan] = []
    let downloadService = DownloadService()
    var downloadedBhajans: [Bhajan] = []
    
    // Get local file path: download task stores files here
    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    func localFilePath(for url: URL) -> URL {
        return documentsPath.appendingPathComponent(url.lastPathComponent)
    }
    
    fileprivate func getData() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        NetworkingService.instance.fetchBhajans(fromURL: fetchUrl) { (success) in
            DispatchQueue.main.async {
                self.downloadedBhajans = NetworkingService.instance.bhajans
                let downloadedFileNames = self.fileCheck()
                // Set downloaded property in Bhajan to true if its downloaded (in Documents directory of App)
                for var bhajan in self.downloadedBhajans {
                    let bhajanFilename = bhajan.fileUrl.lastPathComponent
                    if downloadedFileNames.count > 0 && downloadedFileNames.contains(bhajanFilename) {
                        bhajan.downloaded = true
                    } else {
                        bhajan.downloaded = false
                    }
                    self.bhajans.append(bhajan)
                    print(self.bhajans)
                }
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.tableView.reloadData()
//                print("Data parsing done.")
            }
        }
    }
    
    // Check if the file already exists in documents directory and return array of filenames
    func fileCheck() -> [String] {
        var downloadedFileNames = [String]()
        let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentURL = URL(string: documentPath[0])
        do {
            let directoryContents = try FileManager.default.contentsOfDirectory(at: documentURL!, includingPropertiesForKeys: nil, options: [])
            for file in directoryContents {
                let fname = file.lastPathComponent
                downloadedFileNames.append(fname)
            }
            print("Downloaded Files: \(downloadedFileNames)")
        } catch let error {
            print("Error fetching DocumentDirectory : \(error.localizedDescription)")
        }
        return downloadedFileNames
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        
        // Set downloadsSession property of DownloadService
        downloadService.downloadsSession = downloadsSession
        
        self.title = "BHAJAN"
//        getData()
        NetworkingService.instance.getDataWith { (result) in
            print(result)
            switch result {
            case .Success(let data):
                CoreDataService.instance.saveInCoreDataWith(array: data)
                print(data)
            case .Error(let message):
                DispatchQueue.main.async {
                    self.showAlertWith(title: "Error", message: message)
                }
            }
        }
        
    }
    
    // Show Alert if anything goes wrong
    func showAlertWith(title: String, message: String, style: UIAlertController.Style = .alert) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        let action = UIAlertAction(title: title, style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // Create a lazy session so that it loads after VC is initialized so that self can be passed as delegate parameter of the session
    // Setting delegate queue to nil causes session to create serial operation queue to perform all calls to delegate methods and completion handlers
    lazy var downloadsSession: URLSession = {
        let configuration = URLSessionConfiguration.background(withIdentifier: "bgSessionConfiguration")
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
}

extension PDFListVC : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bhajans.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! PDFListCell
        
        cell.delegate = self
        
        let bhajan = bhajans[indexPath.row]
        print("Downloaded Files: \(downloadedBhajans.count)")
        print("\(bhajan.name) downloaded: \(bhajan.downloaded)")
        cell.configure(bhajan: bhajan, downloaded: bhajan.downloaded, download: downloadService.activeDownloads[bhajan.fileUrl])
        
        return cell
    }
}

extension PDFListVC : UITableViewDelegate {
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedBhajan = bhajans[indexPath.row]
        // PerformSegue when tapped on filename only if file is downloaded
        if selectedBhajan.downloaded {
            print("Selected File: \(selectedBhajan.name) loading from URL: \(selectedBhajan.fileUrl)")
            
            performSegue(withIdentifier: "segueToPDFVC", sender: selectedBhajan)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
        if let pdfVC = segue.destination as? PDFVC {
            let barButton = UIBarButtonItem()
            barButton.title = ""
            navigationItem.backBarButtonItem = barButton
            
            if let bhajan = sender as? Bhajan {
                let pdfDocument = PDFDocument(url: bhajan.fileUrl)
                pdfVC.document = pdfDocument
                pdfVC.title = bhajan.name
            }
            assert(sender as? Bhajan != nil)
            pdfVC.bhajan = sender as? Bhajan
        }
     }
 
}

// MARK:- PDFListCellDelegate
// Called by PDFListCell to identify bhajan for indexpath.row and pass it to download service method
extension PDFListVC : PDFListCellDelegate {
    func pauseTapped(_ cell: PDFListCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            let bhajan = bhajans[indexPath.row]
            downloadService.pauseDownload(bhajan)
            reload(indexPath.row)
        }
    }
    
    func resumeTapped(_ cell: PDFListCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            let bhajan = bhajans[indexPath.row]
            downloadService.resumeDownload(bhajan)
            reload(indexPath.row)
        }
    }
    
    func cancelTapped(_ cell: PDFListCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            let bhajan = bhajans[indexPath.row]
            downloadService.cancelDownload(bhajan)
            reload(indexPath.row)
        }
    }
    
    func downloadTapped(_ cell: PDFListCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            let bhajan = bhajans[indexPath.row]
            downloadService.startDownload(bhajan)
            reload(indexPath.row)
        }
    }
    
    // Update PDFListCell's buttons
    func reload(_ row: Int) {
        tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .none)
    }
}
