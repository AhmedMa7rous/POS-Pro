//
//  Epos2Class.swift
//  pos
//
//  Created by khaled on 7/22/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import Foundation
import UIKit

enum job_printer_type {
    case txt , image
}
class job_printer
{
    var type:job_printer_type?
    var image:UIImage?
    var openDeawer:Bool = false
    
    var header :String = ""
    var items :String = ""
    var total :String = ""
    var footer :String = ""
    var html :String = ""
    
    var is_printed:Bool = false
    var try_print:Int = 0
    var time:Int64 = 0
}

class EposPrintersClass:NSObject ,Epos2PtrReceiveDelegate,Epos2PtrStatusChangeDelegate
{
    
    var delegate:EposPrintersClass_delegate?
    
    var printer: Epos2Printer?
    var valuePrinterSeries: Epos2PrinterSeries
    var valuePrinterModel: Epos2ModelLang
    var  PrintingNow :Bool? = false
    
    
    var IP:String?
    var arr_job:[job_printer] = []
    var  index_job:Int = 0
    
    var current_job:job_printer?
    var printer_log:printer_log_class?
    
    var tag:String = ""
    
//    var timer:Timer?

    init(IP:String?)
    {
        
        self.IP = IP
        self.valuePrinterSeries = EPOS2_TM_T20
        self.valuePrinterModel = EPOS2_MODEL_ANK
        
//        Epos2Log.setLogSettings(EPOS2_PERIOD_PERMANENT.rawValue, output: EPOS2_OUTPUT_STORAGE.rawValue, ipAddress:  self.IP , port: 0, logSize: 50, logLevel: EPOS2_LOGLEVEL_LOW.rawValue)
         let result = Epos2Log.setLogSettings(EPOS2_PERIOD_TEMPORARY.rawValue, output: EPOS2_OUTPUT_STORAGE.rawValue, ipAddress:nil, port:0, logSize:1, logLevel:EPOS2_LOGLEVEL_LOW.rawValue)
        if result != EPOS2_SUCCESS.rawValue {
           print("Can't set Epos2Log.setLogSettings")
        }
        
 
    
    }
    
    
    public func addToQueue(job:job_printer)
    {
        arr_job.append(job)
    }
    
    public  func runQueue()
    {
//        index_job = 0
//        performSelector(onMainThread: #selector(goRunQueue), with: nil, waitUntilDone: true)

//     DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async(execute: {
              self.goRunQueue()
//           })
       
//        if timer == nil
//         {
//            print("printer_Queue(\(IP ?? "")): ","Start")
//
//             timer = Timer.scheduledTimer(timeInterval:2, target: self, selector: #selector(goRunQueue), userInfo: nil, repeats: true)
//              timer!.fire()
//            RunLoop.main.add(timer!, forMode: RunLoop.Mode.default)

//         }
     
            
         
    }
    
    func get_numbers_inQueue() -> Int
    {
        let count = arr_job.count
        if index_job < count
        {
            return count - index_job
        }
        else
        {
            return 0
        }
    }
    
    @objc private func goRunQueue()
    {
 
        if PrintingNow == true
        {
            print("printer_Queue(\(IP ?? ""): ","printer already Printing ...")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {

                self.runQueue()
            })
            
 
            return
        }
        
        
//        if SharedManager.shared.Epos_printer?.PrintingNow == true
//        {
//            print("printer_Queue: ","printer already Printing in master ...")
//
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
//
//                self.runQueue()
//            })
//
//            return
//        }
        
//        if SharedManager.shared.Epos_printer?.arr_job.count != 0 && self.tag == "master"
//        {
//            print("printer_Queue: ","print frist in master ...")
//
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
//
//                self.runQueue()
//            })
//
//            return
//
//        }
        
        if arr_job.count == 0 {
            PrintingNow = false
            
               print("printer_Queue(\(IP ?? ""):" ,"no job to print ...")
            
            return
        }
        
        
        index_job = 0
        
        current_job = arr_job[index_job]
        
        print("printer_Queue(\(IP ?? ""): job \(index_job)/\(arr_job.count)"   )
        
        let mode = settingClass.getSettingClass().printer_mode
        if mode == 1
        {
            DispatchQueue.global(qos: .background).sync
                {
                    DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async(execute: {
                        
                      let status =  self.runPrinterReceiptSequence()
 
                        self.handel_print_status(is_ptint: status)
                    })
            }
        }
        else if mode == 2
        {
            DispatchQueue.global(qos: .background).sync
                {
                    
                     let status =    self.runPrinterReceiptSequence()
                     self.handel_print_status(is_ptint: status)
            }
        }
        else if mode == 3
        {
            
            let status =   self.runPrinterReceiptSequence()
             self.handel_print_status(is_ptint: status)
        }
        else
        {
            DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async(execute: {
                
                let status =    self.runPrinterReceiptSequence()
                self.handel_print_status(is_ptint: status)
            })
        }

        
        
 
      
        
       
        
    }
    
    func handel_print_status(is_ptint:Bool)
    {
        if   arr_job.count != 0
        {
            arr_job.removeFirst()
                        print("printer_Queue(\(IP ?? ""): " , "try to print next job")
            
//            if is_ptint == true
//            {
//                arr_job.removeFirst()
//                print("printer_Queue(\(IP ?? ""): " , "try to print next job")
//
//            }
//            else
//            {
//                if current_job!.try_print >= 3
//                {
//                    arr_job.removeFirst()
//                    print("printer_Queue(\(IP ?? ""): " , "try to print next job")
//
//                }
//                else
//                {
//
//                    current_job?.is_printed = false
//                    current_job?.try_print += 1
//                    arr_job.removeFirst()
//                    arr_job.append(current_job!)
//
//                    print("printer_Queue(\(IP ?? ""): " , "Re try to print  \( current_job?.try_print ?? 0)")
//
//                }
//
//            }
            
             
            
            if arr_job.count != 0
            {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                              self.runQueue()
                })
                
                return
            }
        }
       
           
            print("printer_Queue(\(IP ?? ""): " , "all done  ")
            print("printer_Queue(\(IP ?? ""): ","End")

            //            arr_job.removeAll()
   
        
    }
    
    func createReceiptData() -> Bool
    {
        
        //    return createReceiptData(imageData: getImageeee(),openDeawer: current_job!.openDeawer)
        
        
        if current_job?.type == .txt
        {
            return createReceiptData(header: current_job!.header, items: current_job!.items, total: current_job!.total, footer: current_job!.footer, logoData: current_job!.image, openDeawer: current_job!.openDeawer)
        }
        else
        {
            var image = current_job?.image
            if image == nil
            {
                image =  EposPrint.htmlToImage(html: current_job!.html)
            }
            
            return createReceiptData(imageData: image,openDeawer: current_job!.openDeawer)
        }
        
        
    }
    
    
    
    func createReceiptData(header:String ,items:String,total:String , footer:String,logoData:UIImage?,openDeawer:Bool = false) -> Bool {
        
        guard (printer == nil) else {
            return false
        }
        
        var result = EPOS2_SUCCESS.rawValue
        
        let textData: NSMutableString = NSMutableString()
        //        let logoData = UIImage(named: "store.png")
        
        //      EPOS2_FONT_A
        
        //           result = printer!.addTextFont(EPOS2_FONT_E.rawValue)
        //           if result != EPOS2_SUCCESS.rawValue {
        //               MessageView.showErrorEpos(result, method:"addTextFont")
        //               return false;
        //           }
        
        
        
        result = printer!.addTextAlign(EPOS2_ALIGN_CENTER.rawValue)
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
            
            result = printer!.add(logo, x: 0, y:0,
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
        result = printer!.addFeedLine(1)
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addFeedLine")
            return false
        }
        
        
        textData.append(header)
        
        
        result = printer!.addText(textData as String)
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addText")
            return false;
        }
        textData.setString("")
        
        // Section 2 : Purchaced items
        textData.append(items)
        
        result = printer!.addText(textData as String)
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addText")
            return false;
        }
        textData.setString("")
        
        textData.setString("")
        
        result = printer!.addTextSize(2, height:2)
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addTextSize")
            return false
        }
        
        result = printer!.addText(total)
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addText")
            return false;
        }
        
        result = printer!.addTextSize(1, height:1)
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addTextSize")
            return false;
        }
        
        result = printer!.addFeedLine(1)
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addFeedLine")
            return false;
        }
        
        
        textData.setString("")
        
        // Section 4 : Advertisement
        textData.append(footer)
        //        textData.append("Sign Up and Save !\n")
        //        textData.append("With Preferred Saving Card\n")
        result = printer!.addText(textData as String)
        
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addText")
            return false;
        }
        textData.setString("")
        
        result = printer!.addFeedLine(2)
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addFeedLine")
            return false
        }
        
        if openDeawer == true
        {
            result = printer!.addPulse(EPOS2_PARAM_DEFAULT, time: EPOS2_PARAM_DEFAULT)
            if result != EPOS2_SUCCESS.rawValue {
                MessageView.showErrorEpos(result, method:"addPulse")
                return false
            }
            
        }
        
        
        
        
        result = printer!.addCut(EPOS2_CUT_FEED.rawValue)
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addCut")
            return false
        }
        
        return true
    }
    
    
    func createReceiptData(imageData:UIImage?,openDeawer:Bool = false) -> Bool {
        
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
            
            
            result = printer!.add(logo, x: 0, y:0,
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
            result = printer!.addPulse(EPOS2_PARAM_DEFAULT, time: EPOS2_PARAM_DEFAULT)
            if result != EPOS2_SUCCESS.rawValue {
                MessageView.showErrorEpos(result, method:"addPulse")
                return false
            }
            
        }
        
        
        result = printer!.addCut(EPOS2_CUT_FEED.rawValue)
        if result != EPOS2_SUCCESS.rawValue {
            MessageView.showErrorEpos(result, method:"addCut")
            return false
        }
        
        return true
    }
    
    
    
    public func runPrinterReceiptSequence() -> Bool {
        
         
        if PrintingNow == true
        {
            return false
        }
        
        print("printer_Queue(\(IP ?? ""): " , "try to print")

        printer_log = printer_log_class(fromDictionary: [:])
        printer_log?.ip = IP
        printer_log?.start_at = printer_log?.get_date_now_formate_datebase()
        printer_log?.save() // to crate new line
        
        PrintingNow = true
        if !initializePrinterObject() {
            PrintingNow = false
             
            return false
        }
        
        
        
        if !createReceiptData() {
            finalizePrinterObject()
            PrintingNow = false
            
            printer_log?.add_message("can't create Receipt Data")

            return false
        }
        
        printer_log?.add_message("create Receipt Data")

        
        if !printData() {
            if  settingClass.getSettingClass().force_connect_with_printer == false
            {
                finalizePrinterObject()
            }
            
            PrintingNow = false
            

            return false
        }
        
        printer_log?.add_message("print Data")

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
            
            printer_log?.stop_at = printer_log?.get_date_now_formate_datebase()
          printer_log?.add_message("can't connect to printer")

            return false
        }
        
 
        status = printer!.getStatus()
        //        dispPrinterWarnings(status)
        
        if !isPrintable(status) {
            MessageView.show(makeErrorMessage(status))
            printer!.disconnect()
            return false
        }
        
        let result = printer!.sendData(Int(EPOS2_PARAM_DEFAULT))
        
        if result != EPOS2_SUCCESS.rawValue {
            
            printer_log?.add_message("faild to print")

            MessageView.showErrorEpos(result, method:"sendData")
            printer!.disconnect()
            return false
        }
        
        return true
    }
    
    func initializePrinterObject() -> Bool {
        
        if printer != nil
        {
            if settingClass.getSettingClass().force_connect_with_printer == true
            {
                let status: Epos2PrinterStatusInfo  = printer!.getStatus()
                print( makeErrorMessage(status))
                if status.connection != EPOS2_FALSE
                {
                    printer_log?.add_message("use force connect with printer mode")

                    return true
                }
            }
        }
        
        printer = Epos2Printer(printerSeries: valuePrinterSeries.rawValue,
                               lang: valuePrinterModel.rawValue)
        
        if printer == nil {
            
            printer_log?.stop_at = printer_log?.get_date_now_formate_datebase()
            printer_log?.add_message("can't initialize Printer")
                
            
            return false
        }
        
       printer_log?.add_message("initialize Printer")

        printer!.setReceiveEventDelegate(self)
        printer!.setStatusChangeEventDelegate(self)
        printer!.startMonitor()
        
        return true
    }
    
    func finalizePrinterObject() {
        
        if printer == nil {
            return
        }
        
        printer_log?.stop_at = printer_log?.get_date_now_formate_datebase()
        printer_log?.add_message("finalize Printer Object")
 
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
        
        
        let status: Epos2PrinterStatusInfo  = printer!.getStatus()
        print( makeErrorMessage(status))
        if status.connection != EPOS2_FALSE
        {
            return true
        }
        
        /*
         timeout
         
         Specifies the maximum time (in milliseconds) to wait for communication with the printer to be established.
         
         Integer from 1000 to 300000   Maximum wait time before an error is returned (in milliseconds).
         EPOS2_PARAM_DEFAULT           Specifies the default value (15000).
         */
        
        
        result = printer!.connect("TCP:" + IP!, timeout:Int(EPOS2_PARAM_DEFAULT))
//        result = printer!.connect("TCP:" + IP!, timeout:Int(60 * 1000))

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
        
        result =  printer?.beginTransaction() ?? EPOS2_ERR_FAILURE.rawValue
        
        if result != EPOS2_SUCCESS.rawValue {
            //            MessageView.showErrorEpos(result, method:"beginTransaction")
            printer?.disconnect()
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
            
            printer_log?.add_message("no connection")

            return false
        }
        else if status!.online == EPOS2_FALSE {
            printer_log?.add_message("offline")

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
            print("printer_Queue(\(IP ?? ""): error " , errMessage)

            MessageView.showResult(code, errMessage:errMessage )
        }
        
        printer_log?.status = errMessage
        printer_log?.print_job_id = printJobId ?? ""
        printer_log?.stop_at = printer_log?.get_date_now_formate_datebase()
        printer_log?.save()
        
        
        print("printer_Queue(\(IP ?? ""): " , "print complete")

        dispPrinterWarnings(status)
        //updateButtonState(true)
        
        printer!.clearCommandBuffer()
        
        if settingClass.getSettingClass().force_connect_with_printer == false
        {
            DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async(execute: {
                if self.arr_job.count == 0
                {
                    self.disconnectPrinter()
                    
                    print("printer_Queue(\(self.IP ?? ""): " , "disconnect Printer")

                }
            })
        }
        
        PrintingNow = false

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
                
                if  self.printer  == nil
                {
                    self.printer = Epos2Printer(printerSeries: self.valuePrinterSeries.rawValue,
                                                lang: self.valuePrinterModel.rawValue)
                    
                    
                    if self.printer == nil {
                        return
                    }
                }
                
                
                if !self.connectPrinter() {
                    
                    if self.delegate != nil
                    {
                        self.delegate?.printer_status(online: false)
                    }
                    NotificationCenter.default.post(name: Notification.Name("printer_status"), object: false)
                    
                    return
                }
                
                
                self.printer?.setStatusChangeEventDelegate(self)
                self.printer?.setReceiveEventDelegate(self)
                //         printer!.setConnectionEventDelegate(self)
                
                //        printer!.setInterval(1000)
                self.printer?.startMonitor()
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
            if delegate != nil
            {
                delegate?.printer_status(online: false)
            }
            
            //             printer!.stopMonitor()
            //            delegate?.printer_status(online: false)
            
        }
    }
    
}

protocol EposPrintersClass_delegate {
    func printer_status(online:Bool)
}
