//
//  get_stock.swift
//  pos
//
//  Created by Khaled on 10/18/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import Foundation

typealias stock = combo_vc
extension stock
{
    /*
    func get_stock(product_id:Int)
    {
    
        if parent_create_order?.stocks.count == 0
        {
            
            let pos = SharedManager.shared.posConfig()
            if pos.stock_location_id  != nil
            {
                loadingClass.show(view: self.view)
                
                con.userCash = .stopCash
                con.get_stock_by_location(loc_id:pos.stock_location_id!) { (result) in
                    if (result.success)
                    {
                        
                        self.parent_create_order?.stocks  = result.response?["result"] as? [String:[String:Any]] ?? [:]
                        self.find_stock(product_id: product_id)
                        
                    }else
                    {
                        printer_message_class.show("Check your internet connection.", vc: self)
                    }
                    
                    loadingClass.hide(view: self.view)
                }
            }
            
            
        }
        else
        {
           find_stock(product_id: product_id)
        }
          
    }
    
    
    func find_stock(product_id:Int)
    {
        let dic = self.parent_create_order?.stocks[String(product_id)]
        if dic != nil
        {
            
            let qty_available:String = dic!["qty_available"]  as? String ?? "0"
            let product_uom:String = dic!["product_uom"] as? String ?? ""
            let msg =  qty_available   + " " + product_uom
            
            messages.showAlert(msg,title: "Stock")
        }
        else
        {
            messages.showAlert("Not found.")

        }
    }
    */
}
