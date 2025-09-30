//
//  EposPrint.swift
//  pos
//
//  Created by Khaled on 1/14/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import UIKit



class runner_print_class: NSObject {

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
        
        let order_print = orderPrintBuilderClass(withOrder: order,subOrder: list_sub)
        let setting = SharedManager.shared.appSetting()
        order_print.qr_print = true //setting.qr_enable
        order_print.qr_url = setting.qr_url

        let html = order_print.printOrder_html()
        
//        SharedManager.shared.printLog(html)
        
        
        let jobPrinter = job_printer()
        jobPrinter.type = .image
        jobPrinter.openDeawer = openDeawer
        jobPrinter.html = html
        jobPrinter.order_id = order.id!
        
        if list_sub.count > 0
        {
            jobPrinter.row_type = .return_order

        }
        else
        {
            jobPrinter.row_type = .order

        }

//        let att = html.htmlToAttributedString(font: nil)
//        jobPrinter.image = EposPrint.attributedStringToImage(aString: att)
        
        
        jobPrinter.time = baseClass.getTimeINMS()
        
        return  jobPrinter
    }
    
    func printOrder_items_only_html(openDeawer:Bool = false, printerName:String,printer_type:String = "") -> job_printer {
        let order_print = orderPrintBuilderClass(withOrder: order!,subOrder: [])
        order_print.hidePrice = true
        order_print.hideHeader = true
        order_print.hideFooter = true
          order_print.hideLogo = true
          order_print.hideRef = true
          order_print.hideVat = true
        order_print.hideCalories = true
        order_print.print_new_only = true

        if !printer_type.isEmpty{
            order_print.for_insurance = true
            order_print.hideHeader = true
            order_print.hideLogo = false
            order_print.hidePrice = false
            order_print.hideFooter = false
            order_print.hideRef = false
            order_print.hideVat = false
            order_print.print_new_only = false
        }else{
            order_print.for_kds = true

        }
        order_print.printerName = printerName

//        order_print.printerName = printer_info["name"] as? String ?? ""
        
        let html = order_print.printOrder_html()

        
        let jobPrinter = job_printer()
        jobPrinter.type = .image
        jobPrinter.openDeawer = openDeawer
        jobPrinter.html = html
        jobPrinter.order_id = order.id!
        jobPrinter.row_type = !printer_type.isEmpty ? .insurance : .kds
//         let att = html.htmlToAttributedString(font: nil)
//        jobPrinter.image = EposPrint.attributedStringToImage(aString: att)
//
             
        jobPrinter.time = baseClass.getTimeINMS()

        return  jobPrinter
    }
    
    static func savePhoto(image:UIImage?,prefex:String?)
    {
        if image == nil
        {
            return
        }
        
        let dt_namefile = (prefex ?? "") + "_" + String(   Date.currentDateTimeMillis())
        
         guard let outputURL = try? FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(dt_namefile).appendingPathExtension("png")
                                   else { fatalError("Destination URL not created") }
                               
                    if let data = image!.pngData() {
                               
                               try? data.write(to: outputURL)
                           }
    }
    
    static func attributedStringToImage( aString:NSAttributedString) -> UIImage?
    {
        autoreleasepool { () -> UIImage? in
            let new_atr = aString  //aString.trimmedAttributedString()
            let width =  CGFloat(900)//aString.size().width
            let height =  aString.size().height
            let size = CGSize.init(width: (width <= 1 ? 900 : width)  , height:(height <= 1 ? 2700 : height))
            
            let image = textToImage(drawText: new_atr, size: size, atPoint: CGPoint.init(x: 0, y: 0))
            //MARK: For Test purpose
//            self.saveImageLocally(image: image!, filename: "yourImage.jpg")
            return image
            
        }
    }
    static func saveImageLocally(image: UIImage, filename: String) {
        if let data = image.jpegData(compressionQuality: 1.0) {
            if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let fileURL = documentsDirectory.appendingPathComponent(filename)
                try? data.write(to: fileURL)
            }
        }
    }
    
    static func textToImage(drawText textFontAttributes: NSAttributedString, size: CGSize, atPoint point: CGPoint) -> UIImage? {
        if SharedManager.shared.appSetting().enable_show_new_render_invoice {
            //MARK: Using UIGraphicsImageRenderer
            let renderer = UIGraphicsImageRenderer(size: size)
            let newImage = renderer.image { context in
                let rect = CGRect(origin: point, size: size)
                textFontAttributes.draw(in: rect)
            }
            return newImage
        } else {
            //MARK: Using UIGraphicsBeginImageContextWithOptions
            let scale = UIScreen.main.scale
            UIGraphicsBeginImageContextWithOptions(size, false, scale)
            
            let rect = CGRect(origin: point, size: size)
            textFontAttributes.draw(in: rect)
            
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            guard let _ = UIGraphicsGetCurrentContext() else {
                SharedManager.shared.printLog("graphic context is not available so you can not create an image.")
                UIGraphicsEndImageContext()
                
                return UIImage().getImage(for:textFontAttributes , with: size, at: point)
            }
            UIGraphicsEndImageContext()
            
            return newImage
        }
    }
   static func htmlToImage( html:String) -> UIImage?
    {
//        let htmlData = NSString(string: html).data(using: String.Encoding.utf8.rawValue)
//          let options = [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html ]
//
//          let attributedString = try! NSAttributedString(data: htmlData!,
//          options: options,
//          documentAttributes: nil)
        
//        attributedString.addAttribute(NSBackgroundColorAttributeName, value: UIColor.white, range: NSMakeRange(0, attributedString.length))
//
    autoreleasepool { () -> UIImage? in
//         let cls = txtToImage()
         let att = html.htmlToAttributedString(font: nil)
//        let image = cls.image(from: att , size: CGSize.init(width: 900, height: att.size().height))
//        let image = textToImage(drawText: att, size: CGSize.init(width: att.size().width , height: att.size().height), atPoint: CGPoint.init(x: 0, y: 0))
        var width =  att.size().width
        let height =  att.size().height
        
        
//        let customWidth: CGFloat
        if SharedManager.shared.appSetting().enable_invoice_width {
            let mmWidth = SharedManager.shared.appSetting().width_invoice_to_set_new_dimensions
            // Extract the numeric part from the string
            let numericPart = mmWidth.trimmingCharacters(in: CharacterSet.decimalDigits.inverted)
            if let mmWidthDouble = Double(numericPart) {
                if mmWidthDouble != 8{
                    let mmWidth = CGFloat(mmWidthDouble)
                    width = mmToPixels(mmWidth: mmWidth)
                }
               }
        } 
        
        let size = CGSize(width: (width <= 1 ? 900 : width), height: (height <= 1 ? 2700 : height))
        let image = textToImage(drawText: att, size: size, atPoint: CGPoint(x: 0, y: 0))
        

//        #if DEBUG
//        savePhoto(image: image)
//        #endif
        
        return image
    }
    
    }
    
    static func mmToPixels(mmWidth: CGFloat) -> CGFloat {
        //MARK: Base values: 8mm = 900 pixels, 0.5mm = 50 pixels
        let baseMM: CGFloat = 8.0
        let basePixels: CGFloat = 900.0
        let increment: CGFloat = 50.0

        let difference = mmWidth - baseMM
        return basePixels - (difference * (increment / 0.5))
    }
    
    public static func runPrinterReceipt( logoData:UIImage?,openDeawer:Bool)   {
        if SharedManager.shared.appSetting().enable_support_multi_printer_brands {
        //MWPrintImageByPosPrinters
            SharedManager.shared.MWPrintByPosPrinters(image: logoData, fileType: .report,
                                                      openDeawer:openDeawer, queuePriority: .LOW)
            MWRunQueuePrinter.shared.startMWQueue()

        }else{
        
        let printer = AppDelegate.shared.getDefaultPrinter()
          if printer.IP != nil
          {
                    let job = job_printer()
                    job.type = .image
                    job.image = logoData
                    job.openDeawer = openDeawer
            job.time = baseClass.getTimeINMS()
             
               printer.addToQueue(job: job)
                 
            SharedManager.shared.printers_pson_print[0] = printer
            SharedManager.shared.epson_queue.run()

        }
        }
             
     
         
    }
    
    public static func runPrinterReceipt_image( html:String,openDeawer:Bool,row_type: rowType = rowType.none, order_id:Int = 0 )   {
        if SharedManager.shared.appSetting().enable_support_multi_printer_brands {
            SharedManager.shared.MWPrintByPosPrinters( html: html, fileType: row_type, openDeawer: openDeawer, queuePriority: .LOW)
//            SharedManager.shared.MWPrintHtmlByPosPrinters(html: html, fileType:row_type,openDeawer:openDeawer)
            MWRunQueuePrinter.shared.startMWQueue()
        }else{
        let printer = AppDelegate.shared.getDefaultPrinter()
        if printer.IP != nil
        {
            let job = job_printer()
            job.type = .image
            job.openDeawer = openDeawer
            job.html = html
            job.time = baseClass.getTimeINMS()
            job.row_type = row_type
            job.order_id = order_id
            printer.addToQueue(job: job)
            
            SharedManager.shared.printers_pson_print[0] = printer
            SharedManager.shared.epson_queue.run()
            
        }
        }
        
    }
    
    

 
    
    public static func openDrawer_background()
       {
           DispatchQueue.global(qos: .background).async
               {
                   
                   self.openDrawer()
                   
           }
       }
       
     static  func openDrawer()
       {
          
         let Epos_printer = AppDelegate.shared.getDefaultPrinter()


        if Epos_printer.state == .printingNow
           {
               return
           }

//           Epos_printer.PrintingNow = true
           if !Epos_printer.initializePrinterObject() {
//               Epos_printer.PrintingNow = false
             Epos_printer.state = .none

               return
           }
        Epos_printer.state = .printingNow

 
        if !printer_OpenDrawer(Epos_printer: Epos_printer) {
               Epos_printer.finalizePrinterObject()
//               Epos_printer.PrintingNow = false
            Epos_printer.state = .none

               return
           }

           if !Epos_printer.printData() {
              Epos_printer.finalizePrinterObject()
//               Epos_printer.PrintingNow = false
            Epos_printer.state = .none

               return
           }
       }
       
    
    static func printer_OpenDrawer(Epos_printer:epson_printer_class) -> Bool  {
           
           var result = EPOS2_SUCCESS.rawValue
 
           
           result = Epos_printer.printer!.addPulse(EPOS2_PARAM_DEFAULT, time: EPOS2_PARAM_DEFAULT)
           if result != EPOS2_SUCCESS.rawValue {
//               printer_message_class.showErrorEpos(result, method:"addPulse")
            var msg =   NSLocalizedString(printer_message_class.getEposErrorText(result),comment:"")
            msg = msg + " / " + (Epos_printer.printer_name ?? "") + " - " + Epos_printer.IP!
            
            printer_message_class.show(msg, false)
               return false
           }
           
  
           return true
       }
    
}
