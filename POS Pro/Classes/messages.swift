//
//  messages.swift
//  pos
//
//  Created by khaled on 8/14/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

class  messages: NSObject {

    static func showAlert(_ message:String , title:String = "Alert" , vc:UIViewController? = nil) {
       
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "OK".arabic("موافق"), style: .cancel)
        alert.addAction(cancelAction)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if vc == nil {
            appDelegate.window?.visibleViewController()?.present(alert, animated: true, completion: nil)
        }else{
            vc?.present(alert, animated: true, completion: nil)
        }
        
    }
    
    static func showAlertForApi(message:String = "Please wait..." , title:String = "Alert", hide: Bool, vc:UIViewController? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if vc == nil {
            if hide {
                appDelegate.window?.visibleViewController()?.dismiss(animated: true)
            } else {
                appDelegate.window?.visibleViewController()?.present(alert, animated: true, completion: nil)
            }
        }else{
            if hide {
                vc?.dismiss(animated: true)
            } else {
                vc?.present(alert, animated: true, completion: nil)
            }
        }
    }
    
}
