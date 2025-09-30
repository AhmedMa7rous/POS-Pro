//
//  EposPrint.swift
//  pos
//
//  Created by khaled on 11/5/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit
/*
class EposPrint_old: NSObject {
    
    public static func runPrinterReceipt( logoData:UIImage?,openDeawer:Bool)   {
        
        
        DispatchQueue.global(qos: .background).async
            {
                
                _ =   self.runPrinterReceiptSequence( logoData:logoData,openDeawer: openDeawer)
                
        }
        
    }
    
    public static func runPrinterReceiptSequence( logoData:UIImage?,openDeawer:Bool) -> Bool {
        
        
        if AppDelegate.shared().Epos.PrintingNow == true
        {
            return false
        }
        
        AppDelegate.shared().Epos.PrintingNow = true
        if !AppDelegate.shared().Epos.initializePrinterObject() {
            AppDelegate.shared().Epos.PrintingNow = false
            return false
        }
        
        
        if !createReceiptData( imageData: logoData,openDeawer:openDeawer ) {
            AppDelegate.shared().Epos.finalizePrinterObject()
            AppDelegate.shared().Epos.PrintingNow = false
            return false
        }
        
        if !AppDelegate.shared().Epos.printData() {
            AppDelegate.shared().Epos.finalizePrinterObject()
            AppDelegate.shared().Epos.PrintingNow = false
            return false
        }
        
        return true
    }
    
    
    public static func runPrinterReceipt(header:String ,items:String,total:String , footer:String,logoData:UIImage?,openDeawer:Bool)   {
        
        
        DispatchQueue.global(qos: .background).async
            {
                
                _ =   self.runPrinterReceiptSequence(header: header, items: items, total: total, footer: footer,logoData:logoData,openDeawer: openDeawer)
                
        }
        
    }
    
    public static func runPrinterReceiptSequence(header:String ,items:String,total:String , footer:String,logoData:UIImage?,openDeawer:Bool) -> Bool {
        
        
        if AppDelegate.shared().Epos.PrintingNow == true
        {
            return false
        }
        
        AppDelegate.shared().Epos.PrintingNow = true
        if !AppDelegate.shared().Epos.initializePrinterObject() {
            AppDelegate.shared().Epos.PrintingNow = false
            return false
        }
        
        
        if !createReceiptData(header: header, items: items, total: total, footer: footer,logoData: logoData,openDeawer:openDeawer ) {
            AppDelegate.shared().Epos.finalizePrinterObject()
            AppDelegate.shared().Epos.PrintingNow = false
            return false
        }
        
        if !AppDelegate.shared().Epos.printData() {
            AppDelegate.shared().Epos.finalizePrinterObject()
            AppDelegate.shared().Epos.PrintingNow = false
            return false
        }
        
        return true
    }
    
    static func createReceiptData(header:String ,items:String,total:String , footer:String,logoData:UIImage?,openDeawer:Bool = false) -> Bool {
        
        var result = EPOS2_SUCCESS.rawValue
        
        let textData: NSMutableString = NSMutableString()
        //        let logoData = UIImage(name: "store.png")
        
        result = AppDelegate.shared().Epos.printer!.addTextAlign(EPOS2_ALIGN_CENTER.rawValue)
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addTextAlign")
            return false;
        }
        
        
        if logoData != nil {
            
            var logo = logoData
            
            let width = logoData!.size.width
            if width > 300
            {
                logo = logoData?.ResizeImage(targetWidth: 300)
            }
            
            result = AppDelegate.shared().Epos.printer!.add(logo, x: 0, y:0,
                                                            width:Int(logo!.size.width),
                                                            height:Int(logo!.size.height),
                                                            color:EPOS2_COLOR_1.rawValue,
                                                            mode:EPOS2_MODE_MONO.rawValue,
                                                            halftone:EPOS2_HALFTONE_DITHER.rawValue,
                                                            brightness:Double(EPOS2_PARAM_DEFAULT),
                                                            compress:EPOS2_COMPRESS_AUTO.rawValue)
            
            if result != EPOS2_SUCCESS.rawValue {
                MessageView.showErrorEpos(result, method:"addImage")
                return false
            }
        }
        
        // Section 1 : Store information
        result = AppDelegate.shared().Epos.printer!.addFeedLine(1)
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addFeedLine")
            return false
        }
        
        
        textData.append(header)
        
        
        result = AppDelegate.shared().Epos.printer!.addText(textData as String)
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addText")
            return false;
        }
        textData.setString("")
        
        // Section 2 : Purchaced items
        textData.append(items)
 
        result = AppDelegate.shared().Epos.printer!.addText(textData as String)
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addText")
            return false;
        }
        textData.setString("")
        
        textData.setString("")
        
        result = AppDelegate.shared().Epos.printer!.addTextSize(2, height:2)
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addTextSize")
            return false
        }
        
        result = AppDelegate.shared().Epos.printer!.addText(total)
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addText")
            return false;
        }
        
        result = AppDelegate.shared().Epos.printer!.addTextSize(1, height:1)
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addTextSize")
            return false;
        }
        
        result = AppDelegate.shared().Epos.printer!.addFeedLine(1)
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addFeedLine")
            return false;
        }
        
    
        textData.setString("")
        
        // Section 4 : Advertisement
        textData.append(footer)
        //        textData.append("Sign Up and Save !\n")
        //        textData.append("With Preferred Saving Card\n")
        result = AppDelegate.shared().Epos.printer!.addText(textData as String)
        
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addText")
            return false;
        }
        textData.setString("")
        
        result = AppDelegate.shared().Epos.printer!.addFeedLine(2)
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addFeedLine")
            return false
        }
        
        if openDeawer == true
        {
            result = AppDelegate.shared().Epos.printer!.addPulse(EPOS2_PARAM_DEFAULT, time: EPOS2_PARAM_DEFAULT)
            if result != EPOS2_SUCCESS.rawValue {
                MessageView.showErrorEpos(result, method:"addPulse")
                return false
            }
            
        }
        
        
     
        
        result = AppDelegate.shared().Epos.printer!.addCut(EPOS2_CUT_FEED.rawValue)
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addCut")
            return false
        }
        
        return true
    }
    
    
    static func createReceiptData(imageData:UIImage?,openDeawer:Bool = false) -> Bool {
        
        var result = EPOS2_SUCCESS.rawValue
        
  
        
        if imageData != nil {
            
            var logo = imageData
            
            var size : CGSize = logo!.size
            
            let width: CGFloat = 580
            let ratio =  size.width /  size.height
            
            
            let newHeight = width / ratio
            
            size.width = width
            size.height = newHeight
            
            logo = logo?.ResizeImage(targetSize:size)
            
            
            result = AppDelegate.shared().Epos.printer!.add(logo, x: 0, y:0,
                                                            width:Int(size.width),
                                                            height:Int(size.height),
                                                            color:EPOS2_COLOR_1.rawValue,
                                                            mode:EPOS2_MODE_MONO.rawValue,
                                                            halftone:EPOS2_HALFTONE_THRESHOLD.rawValue,
                                                            brightness:Double(1),
                                                            compress:EPOS2_COMPRESS_NONE.rawValue)
            
            if result != EPOS2_SUCCESS.rawValue {
                MessageView.showErrorEpos(result, method:"addImage")
                return false
            }
        }
        
        
        
        
        if openDeawer == true
        {
            result = AppDelegate.shared().Epos.printer!.addPulse(EPOS2_PARAM_DEFAULT, time: EPOS2_PARAM_DEFAULT)
            if result != EPOS2_SUCCESS.rawValue {
                MessageView.showErrorEpos(result, method:"addPulse")
                return false
            }
            
        }
        
        
        result = AppDelegate.shared().Epos.printer!.addCut(EPOS2_CUT_FEED.rawValue)
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addCut")
            return false
        }
        
        return true
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
        
        if AppDelegate.shared().Epos.PrintingNow == true
        {
            return
        }
        
        AppDelegate.shared().Epos.PrintingNow = true
        if !AppDelegate.shared().Epos.initializePrinterObject() {
            AppDelegate.shared().Epos.PrintingNow = false
            return
        }
        
        
        if !printer_OpenDrawer() {
            AppDelegate.shared().Epos.finalizePrinterObject()
            AppDelegate.shared().Epos.PrintingNow = false
            return
        }
        
        if !AppDelegate.shared().Epos.printData() {
            AppDelegate.shared().Epos.finalizePrinterObject()
            AppDelegate.shared().Epos.PrintingNow = false
            return
        }
    }
    
    
    static func printer_OpenDrawer() -> Bool  {
        
        var result = EPOS2_SUCCESS.rawValue
        
        //        result = AppDelegate.shared().Epos.printer!.addFeedLine(1)
        //        if result != EPOS2_SUCCESS.rawValue {
        //            MessageView.showErrorEpos(result, method:"addFeedLine")
        //            return false
        //        }
        
        result = AppDelegate.shared().Epos.printer!.addPulse(EPOS2_PARAM_DEFAULT, time: EPOS2_PARAM_DEFAULT)
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addPulse")
            return false
        }
        
        //        result = AppDelegate.shared().Epos.printer!.addText("addText")
        //        if result != EPOS2_SUCCESS.rawValue {
        //            MessageView.showErrorEpos(result, method:"addText")
        //            return false;
        //        }
        //
        //        result = AppDelegate.shared().Epos.printer!.addCut(EPOS2_CUT_FEED.rawValue)
        //        if result != EPOS2_SUCCESS.rawValue {
        //            MessageView.showErrorEpos(result, method:"addCut")
        //            return false
        //        }
        
        return true
    }
}
*/
