//
//  SharedManager + MWQueue.swift
//  pos
//
//  Created by M-Wageh on 12/06/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation
extension SharedManager{
    func MWprintTestPrinter(for printer:restaurant_printer_class){
        var HTMLContent = baseClass.get_file_html(filename: "test_print",showCopyRight: true)
        let id = printer.id
        let IP = printer.printer_ip
        let printer_name = printer.name
        let date = Date().toString(dateFormat: baseClass.date_fromate_satnder_12h, UTC: false)

        HTMLContent = HTMLContent.replacingOccurrences(of: "#PRINTER_NAME#", with: printer_name)
        HTMLContent = HTMLContent.replacingOccurrences(of: "#PRINTER_IP#", with: IP)
        HTMLContent = HTMLContent.replacingOccurrences(of: "#REF_DATE#", with: date)
        HTMLContent = HTMLContent.replacingOccurrences(of: "#POS_NAME#", with: SharedManager.shared.posConfig().name ?? "")
        let cates = printer.getCategoriesNamesArray().joined(separator: "<br>")
        HTMLContent = HTMLContent.replacingOccurrences(of: "#CATEGORIES#", with: cates)
        addToMWPrintersQueue(html:HTMLContent,with: printer,fileType: .test,openDeawer:false,queuePriority:.HIGH)
        
//        let mwPrintersQueue = MWPrintersQueue(queuePriority: .HIGH)
//        let mwQueueForFiles = MWQueueForFiles()
//        let mwFileInQueue = MWFileInQueue(html: HTMLContent, restaurantPrinter: printer,row_type: .test, openDrawer: false)
//        mwQueueForFiles.add(mwFileInQueue)
//        mwPrintersQueue.add(mwQueueForFiles)
//        MWRunQueuePrinter.shared.addMWPrintersQueue(mwPrintersQueue)
    }
    
    func MWPrintByPosPrinters(image:UIImage? = nil,html:String = "",
                              fileType: rowType,openDeawer:Bool,
                              queuePriority:QUEUE_PRIORITY,numberCopies:Int = 1){
        let posPrinters = restaurant_printer_class.get(printer_type:DEVICES_TYPES_ENUM.POS_PRINTER)
        for printerPOS in posPrinters {
            self.addToMWPrintersQueue(image:image,
                         html:html,
                         with:printerPOS,
                         fileType: fileType,openDeawer:openDeawer,queuePriority:queuePriority,numberCopies: numberCopies)
        }
    }
    
    func addToMWPrintersQueue(image:UIImage? = nil,
                 html:String = "",
                 with resturantPrinter:restaurant_printer_class,
                 order:pos_order_class? = nil,
                 fileType: rowType,
                 openDeawer:Bool,
                 queuePriority:QUEUE_PRIORITY,
                              numberCopies:Int = 1,printer_error_id:Int? = nil,printer_error:printer_error_class? = nil,isFromIp:Bool = false){
            let mwPrintersQueue = MWPrintersQueue(queuePriority: .LOW)
            let mwQueueForFiles = MWQueueForFiles()
            for _ in 1...numberCopies{
                let mwFileInQueue = MWFileInQueue(html: html,image:image, restaurantPrinter: resturantPrinter,order: order,row_type: fileType, openDrawer: openDeawer,printer_error_id:printer_error_id,printer_error:printer_error,isFromIp: isFromIp)
                mwQueueForFiles.add(mwFileInQueue)
            }
            mwPrintersQueue.add(mwQueueForFiles)
        MWRunQueuePrinter.shared.addMWPrintersQueue(mwPrintersQueue,printerIP:resturantPrinter.printer_ip)
        
    }


}
