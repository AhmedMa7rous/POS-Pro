//
//  printerViewController.swift
//  pos
//
//  Created by khaled on 10/5/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit
/*
class printerViewController_dell: UIViewController {

//    var  Epos  : Epos2Class!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
 
//    func initPrinter()
//    {
//        let setting =  settingClass.getSetting()
//
//        Epos = Epos2Class(IP: setting.ip!)
//    }
    
    public func runPrinterReceiptSequence(header:String ,items:String,total:String , footer:String,logoData:UIImage?,openDeawer:Bool)   {
    
//    self.runPrinterReceipt(header: header, items: items, total: total, footer: footer)
//
//    DispatchQueue.global(qos: .background).async{
//        do {
//
//
//                DispatchQueue.main.async {
//                    //Callback or Update UI in Main thread
//
//
//                }
//
//        }
//        catch {
//            //Callback or Update UI in Main thread
//        }
//    }
    
            DispatchQueue.global(qos: .background).async
                 {
                 

                    _ =   self.runPrinterReceipt(header: header, items: items, total: total, footer: footer,logoData:logoData,openDeawer: openDeawer)

                 }
    
  }
    
    public func openDrawer_background()
    {
        DispatchQueue.global(qos: .background).async
            {
                
                self.openDrawer()
                
        }
    }
    
     func openDrawer()
   {
    
     if AppDelegate.shared.Epos.PrintingNow == true
    {
        return
    }
    
    AppDelegate.shared.Epos.PrintingNow = true
    if !AppDelegate.shared.Epos.initializePrinterObject() {
        AppDelegate.shared.Epos.PrintingNow = false
        return
    }
    
    
    if !printer_OpenDrawer() {
        AppDelegate.shared.Epos.finalizePrinterObject()
        AppDelegate.shared.Epos.PrintingNow = false
        return
    }
    
    if !AppDelegate.shared.Epos.printData() {
        AppDelegate.shared.Epos.finalizePrinterObject()
        AppDelegate.shared.Epos.PrintingNow = false
        return
    }
   }
    
    public func runPrinterReceipt(header:String ,items:String,total:String , footer:String,logoData:UIImage?,openDeawer:Bool) -> Bool {
      
        
        if AppDelegate.shared.Epos.PrintingNow == true
        {
            return false
        }
        
        AppDelegate.shared.Epos.PrintingNow = true
        if !AppDelegate.shared.Epos.initializePrinterObject() {
            AppDelegate.shared.Epos.PrintingNow = false
            return false
        }
        
        
        if !createReceiptData(header: header, items: items, total: total, footer: footer,logoData: logoData,openDeawer:openDeawer ) {
            AppDelegate.shared.Epos.finalizePrinterObject()
            AppDelegate.shared.Epos.PrintingNow = false
            return false
        }
        
        if !AppDelegate.shared.Epos.printData() {
            AppDelegate.shared.Epos.finalizePrinterObject()
            AppDelegate.shared.Epos.PrintingNow = false
            return false
        }
        
        return true
    }
    
    
    func getArabicEncode(str:String) ->String
    {
        
        var tstr    = "بسم" // "\\u0628\\u0633\\u0645"
        
//        let data = tstr.data(using: .ascii)
//        tstr = String(decoding: data!, as: UTF8.self)
        
        
      tstr  = clsfunction.getTextEmoj(tstr)
        
        
//
//        tstr.data(using: .unicode)
//
//        tstr = tstr.replacingOccurrences(of: "\\u", with: "}\\u{")
//        tstr = String(tstr.dropFirst())
//        tstr = tstr + "}"
//
//       tstr = "\u{FEE1}\u{FEB3}\u{FE91}"
        
        return tstr
    }
    
    func createReceiptData_test(header:String ,items:String,total:String , footer:String) -> Bool {
    
        var textData:String =  """

سقطت طائرة عسكرية إسبانية، في مياه البحر المتوسط،
 صباح الإثنين، قبالة سواحل مقاطعة مورسيا،
 جنوب شرقي البلاد، وذلك وفقًا لصحيفة "لا سيكستا" الإسبانية.
ونشرت شبكة "روسيا اليوم"، مقطع فيديو لحظة سقوط طائرة عسكرية
 إسبانية في مياه البحر المتوسط.
ونقلت مصادر عن وزارة الدفاع الإسبانية، تحطم الطائرة من طراز
 "C-101" تابعة لأكاديمية القوات الجوية،
 كانت تقوم بجولة تدريبية، مؤكدة مصرع الطيار.
وأعلنت وزارة"الطوارئ" الإسبانية، أمس الأحد،
 مصرع خمسة أشخاص على الأقل إثر اصطدام مروحية
 بطائرة صغيرة فوق جزيرة مالوركا الإسبانية.

"""
        
//        textData = "سعار"
        
        let p = printArabicClass()
        p.initArabic()
        textData = p.getString(txt: textData)
//        textData = "\u{FEE2}\u{FEB4}\u{FE91}"
   
   
        
        var result = EPOS2_SUCCESS.rawValue
        
       
        // Section 1 : Store information
        result = AppDelegate.shared.Epos.printer!.addFeedLine(1)
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addFeedLine")
            return false
        }
        
        textData = String( textData.reversed())
//        result = Epos.printer!.addTextLang(EPOS2_LANG_VI.rawValue)
        result = AppDelegate.shared.Epos.printer!.addText(textData)
        
        
//                let cfEnc = CFStringEncodings.windowsKoreanJohab
//                let nsEnc = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(cfEnc.rawValue))
//                let encoding = String.Encoding(rawValue: nsEnc)
//
//                let data = textData.data(using: .utf8)
//
//
//                let str = String(data: data!, encoding: encoding)
          // FE91
        
//        result = Epos.printer!.addTextLang(EPOS2_LANG_VI.rawValue)
//
//
//        let textData:String =   clsfunction.getTextEmoj("بسم")  //"\u{FEE1}\u{FEB3}\u{FE91}" // بسم
//        let data = textData.data(using: .utf16)
//        let printed =  data?.hexEncodedString()
//        SharedManager.shared.printLog(textData)
 
 

        
        //
//        var txt:String = "بسم"
//        let test = txt.unicodeScalars
//
//
//
//        SharedManager.shared.printLog(test)
        
//        let u = textData.utf8
        

        
//        result = Epos.printer!.addCommand(data)
 
        
        
        
//        Epos.printer!.addTextAlign(EPOS2_ALIGN_RIGHT.rawValue)

//        let logoData = viewKeyboard.asImage()
//        result = Epos.printer!.add(logoData, x: 0, y:0,
//                                   width:Int(logoData.size.width),
//                                   height:Int(logoData.size.height),
//                                   color:EPOS2_COLOR_1.rawValue,
//                                   mode:EPOS2_MODE_MONO.rawValue,
//                                   halftone:EPOS2_HALFTONE_DITHER.rawValue,
//                                   brightness:Double(0.1),
//                                   compress:EPOS2_COMPRESS_NONE.rawValue)
//
//        result = Epos.printer!.addFeedLine(2)
//        if result != EPOS2_SUCCESS.rawValue {
//            MessageView.showErrorEpos(result, method:"addFeedLine")
//            return false
//        }
        
//        let data = textData.data(using: String.Encoding.utf8)
//        let data = logoData.pngData()
//        result = Epos.printer!.addCommand(data)
//        result = Epos.printer!.addText(textData as String)
        
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addText")
            return false;
        }
 
        
        result = AppDelegate.shared.Epos.printer!.addFeedLine(2)
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addFeedLine")
            return false
        }
        
      
        
        result = AppDelegate.shared.Epos.printer!.addCut(EPOS2_CUT_FEED.rawValue)
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addCut")
            return false
        }
        
        return true
    }
    
    
    func printer_OpenDrawer() -> Bool  {
        
        var result = EPOS2_SUCCESS.rawValue
  
//        result = AppDelegate.shared.Epos.printer!.addFeedLine(1)
//        if result != EPOS2_SUCCESS.rawValue {
//            MessageView.showErrorEpos(result, method:"addFeedLine")
//            return false
//        }
        
            result = AppDelegate.shared.Epos.printer!.addPulse(EPOS2_PARAM_DEFAULT, time: EPOS2_PARAM_DEFAULT)
            if result != EPOS2_SUCCESS.rawValue {
                MessageView.showErrorEpos(result, method:"addPulse")
                return false
            }
        
//        result = AppDelegate.shared.Epos.printer!.addText("addText")
//        if result != EPOS2_SUCCESS.rawValue {
//            MessageView.showErrorEpos(result, method:"addText")
//            return false;
//        }
//
//        result = AppDelegate.shared.Epos.printer!.addCut(EPOS2_CUT_FEED.rawValue)
//        if result != EPOS2_SUCCESS.rawValue {
//            MessageView.showErrorEpos(result, method:"addCut")
//            return false
//        }
        
       return true
    }
    
    
    func createReceiptData(header:String ,items:String,total:String , footer:String,logoData:UIImage?,openDeawer:Bool = false) -> Bool {
     
        var result = EPOS2_SUCCESS.rawValue
        
        let textData: NSMutableString = NSMutableString()
//        let logoData = #imageLiteral(resourceName: "store.png")
        
        result = AppDelegate.shared.Epos.printer!.addTextAlign(EPOS2_ALIGN_CENTER.rawValue)
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
   
        result = AppDelegate.shared.Epos.printer!.add(logo, x: 0, y:0,
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
        result = AppDelegate.shared.Epos.printer!.addFeedLine(1)
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addFeedLine")
            return false
        }
        
        
        textData.append(header)
   
 
        result = AppDelegate.shared.Epos.printer!.addText(textData as String)
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addText")
            return false;
        }
        textData.setString("")
        
        // Section 2 : Purchaced items
        textData.append(items)
//        textData.append("410 3 CUP BLK TEAPOT    9.99 R\n")
//        textData.append("445 EMERIL GRIDDLE/PAN 17.99 R\n")
//        textData.append("438 CANDYMAKER ASSORT   4.99 R\n")
//        textData.append("474 TRIPOD              8.99 R\n")
//        textData.append("433 BLK LOGO PRNTED ZO  7.99 R\n")
//        textData.append("458 AQUA MICROTERRY SC  6.99 R\n")
//        textData.append("493 30L BLK FF DRESS   16.99 R\n")
//        textData.append("407 LEVITATING DESKTOP  7.99 R\n")
//        textData.append("441 **Blue Overprint P  2.99 R\n")
//        textData.append("476 REPOSE 4PCPM CHOC   5.49 R\n")
//        textData.append("461 WESTGATE BLACK 25  59.99 R\n")
//        textData.append("------------------------------\n")
        
        result = AppDelegate.shared.Epos.printer!.addText(textData as String)
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addText")
            return false;
        }
        textData.setString("")
        
        
        // Section 3 : Payment infomation
//        textData.append("SUBTOTAL                160.38\n");
//        textData.append("TAX                      14.43\n");
//        result = Epos.printer!.addText(textData as String)
//        if result != EPOS2_SUCCESS.rawValue {
//            MessageView.showErrorEpos(result, method:"addText")
//            return false
//        }
        textData.setString("")
        
        result = AppDelegate.shared.Epos.printer!.addTextSize(2, height:2)
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addTextSize")
            return false
        }
        
        result = AppDelegate.shared.Epos.printer!.addText(total)
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addText")
            return false;
        }
        
        result = AppDelegate.shared.Epos.printer!.addTextSize(1, height:1)
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addTextSize")
            return false;
        }
        
        result = AppDelegate.shared.Epos.printer!.addFeedLine(1)
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addFeedLine")
            return false;
        }
        
//        textData.append("CASH                    200.00\n")
//        textData.append("CHANGE                   25.19\n")
//        textData.append("------------------------------\n")
//        result = Epos.printer!.addText(textData as String)
//        if result != EPOS2_SUCCESS.rawValue {
//            MessageView.showErrorEpos(result, method:"addText")
//            return false
//        }
        textData.setString("")
        
        // Section 4 : Advertisement
        textData.append(footer)
//        textData.append("Sign Up and Save !\n")
//        textData.append("With Preferred Saving Card\n")
        result = AppDelegate.shared.Epos.printer!.addText(textData as String)
        
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addText")
            return false;
        }
        textData.setString("")
        
        result = AppDelegate.shared.Epos.printer!.addFeedLine(2)
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addFeedLine")
            return false
        }
        
        if openDeawer == true
        {
            result = AppDelegate.shared.Epos.printer!.addPulse(EPOS2_PARAM_DEFAULT, time: EPOS2_PARAM_DEFAULT)
            if result != EPOS2_SUCCESS.rawValue {
                MessageView.showErrorEpos(result, method:"addPulse")
                return false
            }
            
        }
       
        
//        result = Epos.printer!.addBarcode("01209457",
//                                     type:EPOS2_BARCODE_CODE39.rawValue,
//                                     hri:EPOS2_HRI_BELOW.rawValue,
//                                     font:EPOS2_FONT_A.rawValue,
//                                     width:barcodeWidth,
//                                     height:barcodeHeight)
//        if result != EPOS2_SUCCESS.rawValue {
//            MessageView.showErrorEpos(result, method:"addBarcode")
//            return false
//        }
        
        result = AppDelegate.shared.Epos.printer!.addCut(EPOS2_CUT_FEED.rawValue)
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addCut")
            return false
        }
        
        return true
    }
    
    
    func createReceiptData_old() -> Bool {
        let barcodeWidth = 2
        let barcodeHeight = 100
        
        var result = EPOS2_SUCCESS.rawValue
        
        let textData: NSMutableString = NSMutableString()
        let logoData = #imageLiteral(resourceName: "store.png")
        
        if logoData == nil {
            return false
        }
        
        result = AppDelegate.shared.Epos.printer!.addTextAlign(EPOS2_ALIGN_CENTER.rawValue)
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addTextAlign")
            return false;
        }
        
        result = AppDelegate.shared.Epos.printer!.add(logoData, x: 0, y:0,
                                   width:Int(logoData!.size.width),
                                   height:Int(logoData!.size.height),
                                   color:EPOS2_COLOR_1.rawValue,
                                   mode:EPOS2_MODE_MONO.rawValue,
                                   halftone:EPOS2_HALFTONE_DITHER.rawValue,
                                   brightness:Double(EPOS2_PARAM_DEFAULT),
                                   compress:EPOS2_COMPRESS_AUTO.rawValue)
        
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addImage")
            return false
        }
        
        // Section 1 : Store information
        result = AppDelegate.shared.Epos.printer!.addFeedLine(1)
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addFeedLine")
            return false
        }
        
        
        
        
        
        textData.append("THE STORE 123 (555) 555 – 5555\n")
        textData.append("STORE DIRECTOR – John Smith\n")
        textData.append("\n")
        textData.append("7/01/07 16:58 6153 05 0191 134\n")
        textData.append("ST# 21 OP# 001 TE# 01 TR# 747\n")
        textData.append("------------------------------\n")
        result = AppDelegate.shared.Epos.printer!.addText(textData as String)
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addText")
            return false;
        }
        textData.setString("")
        
        // Section 2 : Purchaced items
        textData.append("400 OHEIDA 3PK SPRINGF  9.99 R\n")
        textData.append("410 3 CUP BLK TEAPOT    9.99 R\n")
        textData.append("445 EMERIL GRIDDLE/PAN 17.99 R\n")
        textData.append("438 CANDYMAKER ASSORT   4.99 R\n")
        textData.append("474 TRIPOD              8.99 R\n")
        textData.append("433 BLK LOGO PRNTED ZO  7.99 R\n")
        textData.append("458 AQUA MICROTERRY SC  6.99 R\n")
        textData.append("493 30L BLK FF DRESS   16.99 R\n")
        textData.append("407 LEVITATING DESKTOP  7.99 R\n")
        textData.append("441 **Blue Overprint P  2.99 R\n")
        textData.append("476 REPOSE 4PCPM CHOC   5.49 R\n")
        textData.append("461 WESTGATE BLACK 25  59.99 R\n")
        textData.append("------------------------------\n")
        
        result = AppDelegate.shared.Epos.printer!.addText(textData as String)
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addText")
            return false;
        }
        textData.setString("")
        
        
        // Section 3 : Payment infomation
        textData.append("SUBTOTAL                160.38\n");
        textData.append("TAX                      14.43\n");
        result = AppDelegate.shared.Epos.printer!.addText(textData as String)
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addText")
            return false
        }
        textData.setString("")
        
        result = AppDelegate.shared.Epos.printer!.addTextSize(2, height:2)
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addTextSize")
            return false
        }
        
        result = AppDelegate.shared.Epos.printer!.addText("TOTAL    174.81\n")
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addText")
            return false;
        }
        
        result = AppDelegate.shared.Epos.printer!.addTextSize(1, height:1)
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addTextSize")
            return false;
        }
        
        result = AppDelegate.shared.Epos.printer!.addFeedLine(1)
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addFeedLine")
            return false;
        }
        
        textData.append("CASH                    200.00\n")
        textData.append("CHANGE                   25.19\n")
        textData.append("------------------------------\n")
        result = AppDelegate.shared.Epos.printer!.addText(textData as String)
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addText")
            return false
        }
        textData.setString("")
        
        // Section 4 : Advertisement
        textData.append("Purchased item total number\n")
        textData.append("Sign Up and Save !\n")
        textData.append("With Preferred Saving Card\n")
        result = AppDelegate.shared.Epos.printer!.addText(textData as String)
        
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addText")
            return false;
        }
        textData.setString("")
        
        result = AppDelegate.shared.Epos.printer!.addFeedLine(2)
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addFeedLine")
            return false
        }
        
        result = AppDelegate.shared.Epos.printer!.addBarcode("01209457",
                                          type:EPOS2_BARCODE_CODE39.rawValue,
                                          hri:EPOS2_HRI_BELOW.rawValue,
                                          font:EPOS2_FONT_A.rawValue,
                                          width:barcodeWidth,
                                          height:barcodeHeight)
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addBarcode")
            return false
        }
        
        result = AppDelegate.shared.Epos.printer!.addCut(EPOS2_CUT_FEED.rawValue)
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addCut")
            return false
        }
        
        return true
    }
}

 */
