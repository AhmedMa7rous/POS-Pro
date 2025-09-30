//
//  ReportViewController.swift
//  pos
//
//  Created by Alhaytham Alfeel on 11/20/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

class ReportViewController: UIViewController {
    
    // MARK: - Properties
    
    let con = SharedManager.shared.conAPI()
    var parent_vc:UIViewController?

    
    var activeSessionLast: pos_session_class!
//    var orders:[orderClass]!
//    var list_PaymentMethods:  [Any] = []
    var list_ids_order = ""
    var receipt = ""
    var print_inOpen = false
    var auto_close = false

    var value_dirction_style = "right"
    let style_right = "body,table,tr,td {  direction: rtl;   text-align: right; }"

    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        if LanguageManager.currentLang() == .ar
        {
             value_dirction_style = "left"

        }
    }
 
    
    func show_printer_dialog()
       {
        
           let printer_status_vc = printer_status()
           printer_status_vc.modalPresentationStyle = .overCurrentContext

           parent_vc?.present(printer_status_vc, animated: true, completion: nil)
       }
    
    func is_order_type_enabled() -> Bool
    {
        //let enable_delivery = SharedManager.shared.posConfig().enable_delivery
//        if enable_delivery == true
//        {
            let order_type_enabled = SharedManager.shared.appSetting().enable_OrderType == .disable ? false : true

            return order_type_enabled
//        }
//
//        return enable_delivery
      
    }
    
}
