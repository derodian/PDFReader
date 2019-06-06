//
//  NetworkingService.swift
//  PDFReader
//
//  Created by Hitz on 5/21/19.
//  Copyright © 2019 Hitz. All rights reserved.
//

import Foundation

class NetworkingService {
    
    // Private init()
    static let instance = NetworkingService()
    
    typealias JSONDictionary = [String: Any]
    var bhajans = [Bhajan]()
    
    func fetchBhajans(fromURL url: String, onComplete: @escaping CompletionHandler) {
        bhajans.removeAll()
        guard let bhajanPdfUrl = URL(string: url) else { return }
        
        let task = URLSession.shared.dataTask(with: bhajanPdfUrl) { (data, response, error) in
            
            if error == nil {
                guard let data = data else { return }
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String: Any]
                    if let jsonBhajans = json["files"] as? [NSDictionary] {
//                        print(jsonBhajans)
                        var index = 0
                        for bhajan in jsonBhajans as [AnyObject] {
                            let id = bhajan["id"] as! Int
                            let name = bhajan["name"] as! String
                            let urlString = bhajan["fileurl"] as! String
                            let fileurl = URL(string: urlString)
                            let uploaddate = bhajan["uploaddate"] as! String
                            self.bhajans.append(Bhajan(id: id, name: name, fileUrl: fileurl!, uploaddate: uploaddate, index: index))
                            
                            index += 1
                        }
                    } else {
                        print("Cannot get Bhajans from json[files]")
                    }
                    onComplete(true)
                } catch let error {
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
        task.resume()
    }
}
