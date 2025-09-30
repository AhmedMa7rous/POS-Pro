//
//  connection_log.swift
//  pos
//
//  Created by khaled on 11/4/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

class connection_log: UIViewController {

    
    @IBOutlet var txtLog: UITextView!
    
    var str:String = ""
//    var header: [String: String] = [:]
//    var response: [String: Any] = [:]
//    var request: [String: Any] = [:]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        SharedManager.shared.printLog(request.jsonString())

        txtLog.text = str
//        url : \(url)
//        ----------------------------------
//        header : \(header.jsonString() ?? "")
//        ----------------------------------
//        request : \(request.jsonString() ?? "")
//        ----------------------------------
//        response : \(response.jsonString() ?? "")
//        """
 
    }


    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
     @IBAction   func share(_ sender: Any) {
       let activityVC = UIActivityViewController(activityItems: [txtLog.text ?? ""], applicationActivities: nil)
               activityVC.modalPresentationStyle = .popover
               activityVC.popoverPresentationController?.sourceView = sender as? UIView
               present(activityVC, animated: true, completion: nil)
               activityVC.completionWithItemsHandler = { (activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
                   
                   if completed  {
                       activityVC.dismiss(animated: true, completion: nil)
                   }
               }
    }
}
