//
//  Epos2Class.swift
//  pos
//
//  Created by khaled on 7/22/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import Foundation
import UIKit

class Epos2Class:NSObject ,Epos2PtrReceiveDelegate,Epos2PtrStatusChangeDelegate
{
    
    var delegate:printer_delegate?
    
    var IP:String?
    
//    override init() {
//    self.init()
//
//    }
    
      init(load_printer:Bool) {
//        self.init()
        
        
        let setting =  settingClass.getSetting()
        self.IP = setting.ip
        self.valuePrinterSeries = EPOS2_TM_T20
        self.valuePrinterModel = EPOS2_MODEL_ANK
        
//       _ = self.initializePrinterObject()
    
    }
    
    init(IP:String?)
    {
       self.IP = IP
       self.valuePrinterSeries = EPOS2_TM_T20
       self.valuePrinterModel = EPOS2_MODEL_ANK
      
        
    }
    
    
    var printer: Epos2Printer?
    var valuePrinterSeries: Epos2PrinterSeries
    var valuePrinterModel: Epos2ModelLang
    var  PrintingNow :Bool? = false
    
    
   public func runPrinterReceiptSequence(html_Details:String) -> Bool {
    
    if PrintingNow == true
    {
        return false
    }
    
        PrintingNow = true
        if !initializePrinterObject() {
            PrintingNow = false
            return false
        }
    
    
        if !createReceiptData(html_Details: html_Details) {
            finalizePrinterObject()
            PrintingNow = false
            return false
        }
        
        if !printData() {
            finalizePrinterObject()
            PrintingNow = false
            return false
        }
        
        return true
    }
    
    func createReceiptData(html_Details:String) -> Bool {
  
        var result = EPOS2_SUCCESS.rawValue
        

        var  logoData :UIImage? = ConvertBase64StringToImage(imageBase64String: html_Details)    // UIImage(name: "receipt.jpg")
        if logoData == nil {
            return false
        }
    
        
        var size : CGSize = logoData!.size
        
        let width: CGFloat = 600
        let ratio =  size.width /  size.height
        
        
        let newHeight = width / ratio
        
        size.width = width
        size.height = newHeight
        
        logoData = logoData?.ResizeImage(targetSize:size)
        
    
 
        
        result = printer!.add(logoData, x: 0, y:0,
                              width:Int(size.width),
                              height:Int(size.height),
                              color:EPOS2_COLOR_1.rawValue,
                              mode:EPOS2_MODE_MONO.rawValue,
                              halftone:EPOS2_HALFTONE_THRESHOLD.rawValue,
                              brightness:Double(1),
                              compress:EPOS2_COMPRESS_NONE.rawValue)
        
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"Print_Receipt")
            return false
        }
        
        
        result = printer!.addCut(EPOS2_CUT_FEED.rawValue)
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addCut")
            return false
        }
        
        return true
    }
    
    func ConvertBase64StringToImage (imageBase64String:String) -> UIImage {
        let imageBase64Stringx = imageBase64String.replacingOccurrences(of: "data:image/png;base64,", with: "")
        let imageData = Data.init(base64Encoded: imageBase64Stringx, options: .init(rawValue: 0))
        let image = UIImage(data: imageData!)
        return image!
    }
    
    
    func printData() -> Bool {
        var status: Epos2PrinterStatusInfo?
        
        if printer == nil {
            return false
        }
        
        if !connectPrinter() {
            return false
        }
        
        status = printer!.getStatus()
        dispPrinterWarnings(status)
        
        if !isPrintable(status) {
            MessageView.show(makeErrorMessage(status))
            printer!.disconnect()
            return false
        }
        
        let result = printer!.sendData(Int(EPOS2_PARAM_DEFAULT))
        
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"sendData")
            printer!.disconnect()
            return false
        }
        
        return true
    }
    
    func initializePrinterObject() -> Bool {
        printer = Epos2Printer(printerSeries: valuePrinterSeries.rawValue,
                               lang: valuePrinterModel.rawValue)
        
        if printer == nil {
            return false
        }
        
        printer!.setReceiveEventDelegate(self)
        printer!.setStatusChangeEventDelegate(self)
        printer!.startMonitor()
        
        return true
    }
    
    func finalizePrinterObject() {
      
        if printer == nil {
            return
        }
        
        printer!.clearCommandBuffer()
        printer!.setReceiveEventDelegate(nil)
        printer!.setStatusChangeEventDelegate(nil)

        printer = nil
    }
    
    func connectPrinter() -> Bool {
        var result: Int32 = EPOS2_SUCCESS.rawValue
        
        if printer == nil {
            return false
        }
        
        result = printer!.connect("TCP:" + IP!, timeout:Int(EPOS2_PARAM_DEFAULT))
        if result != EPOS2_SUCCESS.rawValue
        {
//            if result == EPOS2_ERR_CONNECT.rawValue
//            {
//                printer!.disconnect()
//                finalizePrinterObject()
//
//               _ = initializePrinterObject()
//               _ =  connectPrinter()
//
//            }
//            MessageView.showErrorEpos(result, method:"connect")
            return false
        }
        
        result =  printer!.beginTransaction()
       
        if result != EPOS2_SUCCESS.rawValue {
//            MessageView.showErrorEpos(result, method:"beginTransaction")
            printer!.disconnect()
            return false
            
        }
        return true
    }
    
    func disconnectPrinter() {
        var result: Int32 = EPOS2_SUCCESS.rawValue
        
        if printer == nil {
            return
        }
        
        result = printer!.endTransaction()
        if result != EPOS2_SUCCESS.rawValue {
            DispatchQueue.main.async(execute: {
                MessageView.showErrorEpos(result, method:"endTransaction")
            })
        }
        
        result = printer!.disconnect()
        if result != EPOS2_SUCCESS.rawValue {
            DispatchQueue.main.async(execute: {
                MessageView.showErrorEpos(result, method:"disconnect")
            })
        }
        
        finalizePrinterObject()
    }
    func isPrintable(_ status: Epos2PrinterStatusInfo?) -> Bool {
        if status == nil {
            return false
        }
        
        if status!.connection == EPOS2_FALSE {
            return false
        }
        else if status!.online == EPOS2_FALSE {
            return false
        }
        else {
            // print available
        }
        return true
    }
    
 
    
      func onPtrReceive(_ printerObj: Epos2Printer!, code: Int32, status: Epos2PrinterStatusInfo!, printJobId: String!) {
        
        let errMessage = makeErrorMessage(status)
        
       if !errMessage.isEmpty
       {
           MessageView.showResult(code, errMessage:errMessage )
        }
     
       PrintingNow = false
        
        dispPrinterWarnings(status)
        //updateButtonState(true)
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async(execute: {
            self.disconnectPrinter()
        })
    }
    
    func dispPrinterWarnings(_ status: Epos2PrinterStatusInfo?) {
        if status == nil {
            return
        }
        
 
        if status!.paper == EPOS2_PAPER_NEAR_END.rawValue {
            //   textWarnings.text = NSLocalizedString("warn_receipt_near_end", comment:"")
        }
        
        if status!.batteryLevel == EPOS2_BATTERY_LEVEL_1.rawValue {
            // textWarnings.text = NSLocalizedString("warn_battery_near_end", comment:"")
        }
    }
    
    func makeErrorMessage(_ status: Epos2PrinterStatusInfo?) -> String {
        let errMsg = NSMutableString()
        if status == nil {
            return ""
        }
        
        if status!.online == EPOS2_FALSE {
            errMsg.append(NSLocalizedString("err_offline", comment:""))
        }
        if status!.connection == EPOS2_FALSE {
            errMsg.append(NSLocalizedString("err_no_response", comment:""))
        }
        if status!.coverOpen == EPOS2_TRUE {
            errMsg.append(NSLocalizedString("err_cover_open", comment:""))
        }
        if status!.paper == EPOS2_PAPER_EMPTY.rawValue {
            errMsg.append(NSLocalizedString("err_receipt_end", comment:""))
        }
        if status!.paperFeed == EPOS2_TRUE || status!.panelSwitch == EPOS2_SWITCH_ON.rawValue {
            errMsg.append(NSLocalizedString("err_paper_feed", comment:""))
        }
        if status!.errorStatus == EPOS2_MECHANICAL_ERR.rawValue || status!.errorStatus == EPOS2_AUTOCUTTER_ERR.rawValue {
            errMsg.append(NSLocalizedString("err_autocutter", comment:""))
            errMsg.append(NSLocalizedString("err_need_recover", comment:""))
        }
        if status!.errorStatus == EPOS2_UNRECOVER_ERR.rawValue {
            errMsg.append(NSLocalizedString("err_unrecover", comment:""))
        }
        
        if status!.errorStatus == EPOS2_AUTORECOVER_ERR.rawValue {
            if status!.autoRecoverError == EPOS2_HEAD_OVERHEAT.rawValue {
                errMsg.append(NSLocalizedString("err_overheat", comment:""))
                errMsg.append(NSLocalizedString("err_head", comment:""))
            }
            if status!.autoRecoverError == EPOS2_MOTOR_OVERHEAT.rawValue {
                errMsg.append(NSLocalizedString("err_overheat", comment:""))
                errMsg.append(NSLocalizedString("err_motor", comment:""))
            }
            if status!.autoRecoverError == EPOS2_BATTERY_OVERHEAT.rawValue {
                errMsg.append(NSLocalizedString("err_overheat", comment:""))
                errMsg.append(NSLocalizedString("err_battery", comment:""))
            }
            if status!.autoRecoverError == EPOS2_WRONG_PAPER.rawValue {
                errMsg.append(NSLocalizedString("err_wrong_paper", comment:""))
            }
        }
        if status!.batteryLevel == EPOS2_BATTERY_LEVEL_0.rawValue {
            errMsg.append(NSLocalizedString("err_battery_real_end", comment:""))
        }
        
        return errMsg as String
    }
    
    // check status
    
    func checkStatusPrinter()
    {
        DispatchQueue.global(qos: .background).async
            {
                self.printer = Epos2Printer(printerSeries: self.valuePrinterSeries.rawValue,
                                            lang: self.valuePrinterModel.rawValue)

                if self.printer == nil {
            return
        }
        
                if !self.connectPrinter() {
            return
        }

                self.printer!.setStatusChangeEventDelegate(self)
//                self.printer!.setReceiveEventDelegate(self)
 

            self.printer!.setInterval(3000)
                self.printer!.startMonitor()
        }
    }
    
 
    
    func onPtrStatusChange(_ printerObj: Epos2Printer!, eventType: Int32) {
//        let eventStatus = Epos2StatusEvent(rawValue: eventType)

        if(eventType == EPOS2_EVENT_ONLINE.rawValue) {
//            ...starting reconnection...
            NSLog("%@", " printer ONLINE")
            NotificationCenter.default.post(name: Notification.Name("printer_status"), object: true)

            if delegate != nil
            {
                delegate?.printer_status(online: true)
            }
        }
        if(eventType == EPOS2_EVENT_POWER_OFF.rawValue) {
//            ...reconnection end...
            NSLog("%@", " printer OFFLINE")
            NotificationCenter.default.post(name: Notification.Name("printer_status"), object: false)

//             printer!.stopMonitor()
//            delegate?.printer_status(online: false)

        }
    }
    
}

protocol printer_delegate {
    func printer_status(online:Bool)
}
