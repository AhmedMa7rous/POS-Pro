//
//  orderPrintTXTClass.swift
//  pos
//
//  Created by Khaled on 1/13/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import UIKit

class orderPrintTXTClass: NSObject {

    let p = printArabicClass()
    var order:pos_order_class!
    var printer_info:[String:Any]!
    
    func print_order(openDeawer:Bool = false) -> job_printer {
        
        var list_sub:[pos_order_class] = []
        
        if  order.amount_total < 0.0
        {
            let option = ordersListOpetions()
            option.Closed = true
            option.orderID =   order.parent_order_id
            option.parent_product = true
            
            list_sub = pos_order_helper_class.getOrders_status_sorted(options: option)
        }
        
        let order_print = orderPrintClass(withOrder: order,subOrder: list_sub)
        let setting = settingClass.getSettingClass()
        order_print.qr_print = setting.qr_enable
        order_print.qr_url = setting.qr_url

        let html = order_print.printOrder_html()
        
//        print(html)
        
        
        let jobPrinter = job_printer()
        jobPrinter.type = .image
        jobPrinter.openDeawer = openDeawer
        jobPrinter.html = html
        
//        let att = html.htmlToAttributedString(font: nil)
//        jobPrinter.image = EposPrint.attributedStringToImage(aString: att)
        
        
        jobPrinter.time = baseClass.getTimeINMS()
        
        return  jobPrinter
    }
    
    func printOrder_items_only_html(openDeawer:Bool = false) -> job_printer {
        let order_print = orderPrintClass(withOrder: order!,subOrder: [])
        order_print.hidePrice = true
        order_print.hideHeader = true
        order_print.hideFooter = true
          order_print.hideLogo = true
          order_print.hideRef = true
          order_print.hideVat = true
        order_print.hideCalories = true
        order_print.print_new_only = true
        order_print.for_kds = true


        order_print.printerName = printer_info["name"] as? String ?? ""
        
        let html = order_print.printOrder_html()

        
        let jobPrinter = job_printer()
        jobPrinter.type = .image
        jobPrinter.openDeawer = openDeawer
        jobPrinter.html = html
        
//         let att = html.htmlToAttributedString(font: nil)
//        jobPrinter.image = EposPrint.attributedStringToImage(aString: att)
//
             
        jobPrinter.time = baseClass.getTimeINMS()

        return  jobPrinter
    }

    
}
