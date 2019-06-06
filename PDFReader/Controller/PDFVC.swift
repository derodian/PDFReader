//
//  PDFVC.swift
//  PDFReader
//
//  Created by Hitz on 5/22/19.
//  Copyright © 2019 Hitz. All rights reserved.
//

import UIKit
import PDFKit

class PDFVC: UIViewController {
    
    @IBOutlet weak var pdfView: PDFView!
    
    var bhajan: Bhajan!
    var document: PDFDocument!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let document = document {
            pdfView.displayMode = .singlePageContinuous
            pdfView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.25)
            pdfView.autoScales = true
            pdfView.document = document
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
