//
//  epson_printer_class+ext.swift
//  pos
//
//  Created by Khaled on 2/28/21.
//  Copyright © 2021 khaled. All rights reserved.
//

import Foundation
import FirebaseCrashlytics

extension  epson_printer_class
{
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
                if current_job == nil{
                    return false
                }
//                image =  runner_print_class.htmlToImage(html: current_job!.html)
                getImageWithTry(3, success: { screenShot in
                    image = screenShot
                })
                if image == nil {
                    
                    printer_log?.addStatus("Can't create Receipt Data graphic context is not available so you can not create an image.")
                    printer_log?.add_message("Can't create Receipt Data graphic context is not available so you can not create an image.")
                    
                    let error = NSError(domain: "GraphicImage", code: 5003, userInfo:
                        [
                            "error:" :  "graphic context is not available so you can not create an image",
                            "order_id" :  current_job?.order_id ?? 0,
                        ])
                  
                    Crashlytics.crashlytics().record(error: error)
                    SharedManager.shared.report_memory(prefix:"create_receipt")
                    //reportMemory()
                    printer_log?.add_message("Can't create Receipt Data graphic context reportMemory \(SharedManager.shared.reportMemory())")

//                    let _ = image!.toBase64()
                    return false
                }
            }
            if current_job != nil{
         
                #if DEBUG
//                 runner_print_class.savePhoto(image: image,prefex: printer_name)
                #endif

                return createReceiptData(imageData: image,openDeawer: current_job!.openDeawer)
            }else{
                return false
            }
        }
        
        
    }
    
   
    func getImageWithTry(_ times:Int, success: @escaping (UIImage?) -> Void){
       let imageHtml:UIImage? =  runner_print_class.htmlToImage(html: current_job!.html)
      /*
        let htmlServiceConvert = MWHtmlConvertService.shared
        htmlServiceConvert.setHtml(current_job!.html)
        let imageHtml = htmlServiceConvert.getImageHtml()
        */
        if imageHtml == nil && times > 0{
            getImageWithTry(times - 1 , success:success)
        }
        success(imageHtml)
    }
    
    
    func createReceiptData(header:String ,items:String,total:String , footer:String,logoData:UIImage?,openDeawer:Bool = false) -> Bool {
        
        guard (printer == nil) else {
            return false
        }
        
        var result = EPOS2_SUCCESS.rawValue
        
        let textData: NSMutableString = NSMutableString()
        //        let logoData = #imageLiteral(resourceName: "store.png")
        
        //      EPOS2_FONT_A
        
        //           result = printer!.addTextFont(EPOS2_FONT_E.rawValue)
        //           if result != EPOS2_SUCCESS.rawValue {
        //               MessageView.showErrorEpos(result, method:"addTextFont")
        //               return false;
        //           }
        
        
        
        result = printer!.addTextAlign(EPOS2_ALIGN_CENTER.rawValue)
        if result != EPOS2_SUCCESS.rawValue {
            show_msg_error(result, method:"addTextAlign")
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
                show_msg_error(result, method:"addImage")
                return false
            }
        }
        
        // Section 1 : Store information
        result = printer!.addFeedLine(1)
        if result != EPOS2_SUCCESS.rawValue {
            show_msg_error(result, method:"addFeedLine")
            return false
        }
        
        
        textData.append(header)
        
        
        result = printer!.addText(textData as String)
        if result != EPOS2_SUCCESS.rawValue {
            show_msg_error(result, method:"addText")
            return false;
        }
        textData.setString("")
        
        // Section 2 : Purchaced items
        textData.append(items)
        
        result = printer!.addText(textData as String)
        if result != EPOS2_SUCCESS.rawValue {
            show_msg_error(result, method:"addText")
            return false;
        }
        textData.setString("")
        
        textData.setString("")
        
        result = printer!.addTextSize(2, height:2)
        if result != EPOS2_SUCCESS.rawValue {
            show_msg_error(result, method:"addTextSize")
            return false
        }
        
        result = printer!.addText(total)
        if result != EPOS2_SUCCESS.rawValue {
            show_msg_error(result, method:"addText")
            return false;
        }
        
        result = printer!.addTextSize(1, height:1)
        if result != EPOS2_SUCCESS.rawValue {
            show_msg_error(result, method:"addTextSize")
            return false;
        }
        
        result = printer!.addFeedLine(1)
        if result != EPOS2_SUCCESS.rawValue {
            show_msg_error(result, method:"addFeedLine")
            return false;
        }
        
        
        textData.setString("")
        
        // Section 4 : Advertisement
        textData.append(footer)
        //        textData.append("Sign Up and Save !\n")
        //        textData.append("With Preferred Saving Card\n")
        result = printer!.addText(textData as String)
        
        if result != EPOS2_SUCCESS.rawValue {
            show_msg_error(result, method:"addText")
            return false;
        }
        textData.setString("")
        
        result = printer!.addFeedLine(2)
        if result != EPOS2_SUCCESS.rawValue {
            show_msg_error(result, method:"addFeedLine")
            return false
        }
        
        if openDeawer == true
        {
            result = printer!.addPulse(EPOS2_PARAM_DEFAULT, time: EPOS2_PARAM_DEFAULT)
            if result != EPOS2_SUCCESS.rawValue {
                show_msg_error(result, method:"addPulse")
                return false
            }
        }
        
        result = printer!.addCut(EPOS2_CUT_FEED.rawValue)
        if result != EPOS2_SUCCESS.rawValue {
            show_msg_error(result, method:"addCut")
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
            
            guard let printer = printer else {
                self.current_job?.error = "printer null" + QUEUE_ENUM_ERROR.FAIL_CREATE_DATA_PRINTER_ADD.get_error_info()
                return false
            }
            result = printer.add(logo, x: 0, y:0,
                                  width:Int(size.width),
                                  height:Int(size.height),
                                  color:EPOS2_COLOR_1.rawValue,
                                  mode:EPOS2_MODE_MONO.rawValue,
                                  halftone:EPOS2_HALFTONE_THRESHOLD.rawValue,
                                  brightness:Double(1),
                                  compress:EPOS2_COMPRESS_NONE.rawValue)
            
            if result != EPOS2_SUCCESS.rawValue {
                show_msg_error(result, method:"addImage")
                self.current_job?.error = QUEUE_ENUM_ERROR.FAIL_CREATE_DATA_PRINTER_ADD.get_error_info()

                return false
            }
        }
        
        
        
        
        if openDeawer == true
        {
            result = printer!.addPulse(EPOS2_PARAM_DEFAULT, time: EPOS2_PARAM_DEFAULT)
            if result != EPOS2_SUCCESS.rawValue {
                show_msg_error(result, method:"addPulse")
                self.current_job?.error = QUEUE_ENUM_ERROR.FAIL_CREATE_DATA_PRINTER_ADD_PULSE.get_error_info()

                return false
            }
            
        }
        
        
        result = printer!.addCut(EPOS2_CUT_FEED.rawValue)
        if result != EPOS2_SUCCESS.rawValue {
            show_msg_error(result, method:"addCut")
            self.current_job?.error = QUEUE_ENUM_ERROR.FAIL_CREATE_DATA_PRINTER_ADD_CUT.get_error_info()
            return false
        }
        
        
        return true
    }
    func printerLogInitalizeWith(){
        let wifiName =  WiFi.shared.getWiFiName()
        printer_log = printer_log_class(fromDictionary: [:])
        printer_log?.id = 0
        printer_log?.ip =  IP
        printer_log?.printer_name = printer_name
        printer_log?.start_at = printer_log?.get_date_now_formate_datebase()
        printer_log?.order_id = current_job?.order_id ?? 0
        printer_log?.row_type =  current_job?.row_type
        printer_log?.sequence = pos_order_helper_class.get_print_count(order_id: current_job?.order_id ?? 0)
        if current_job?.type == .image && ((current_job?.html.isEmpty ?? true) ){
            let fileName = "\(current_job?.order_id ?? 0)-\(IP ?? "")-\(printer_name ?? "").png"
            printer_log?.html = "FILE_NAME:" + fileName
        }else{
            printer_log?.html = current_job?.html
        }
        printer_log?.wifi_ssid = wifiName
    }
    
    
    public func runPrinterReceiptSequence() -> Bool {
        MWHtmlConvertService.shared.resetService()
        /*
        for index in 1...100 {
        getImageWithTry(3, success: { screenShot in
            MWHtmlConvertService.shared.resetService()
            SharedManager.shared.printLog(index)

          SharedManager.shared.printLog(screenShot != nil)
        })
            
        }*/
             
       SharedManager.shared.printLog("DispatchQueue: \(DispatchQueue.currentLabel)")

        
        printerLogInitalizeWith()
        printer_log?.add_message("Run printer Receipt Sequence")
        if IP == "" {
            printer_log?.add_message("Can't run printer Receipt Sequence as no printer Found")
            self.current_job?.error = QUEUE_ENUM_ERROR.FAIL_STATE_NO_PRINTER_Found.get_error_info()
            self.handel_print_status(is_ptint: false)
            printer_message_class.show(" printer_Queue(\(self.IP ?? "empty ip"): error No printer Found" ,false)
            return false
        }
        if self.state == .printingNow
        {
            printer_log?.addStatus("Can't run printer Receipt Sequence as state is printingNow")

//            printer_log?.status = "Can't run printer Receipt Sequence as state is printingNow"
            printer_log?.add_message("Can't run printer Receipt Sequence as state is printingNow")
            self.current_job?.error = QUEUE_ENUM_ERROR.FAIL_STATE_PRINTING_NOW.get_error_info()
            return false
        }
        
       SharedManager.shared.printLog("printer_Queue(\(IP ?? ""): try to print" )
        
        
        
     
        if !initializePrinterObject() {
            stop()
            return false
        }
        
        
        self.state = .printingNow
        
       

        if !createReceiptData() {
            printer_log?.addStatus("Can't create Receipt Data")
            printer_log?.add_message("Can't create Receipt Data")
            finalizePrinterObject()
            stop()
            
            return false
        }
        printer_log?.addStatus("Create Receipt Data")
        printer_log?.add_message("Create Receipt Data")
        
        if printer_log?.row_type == .kds {
        if printer_log_class.checkExitsJob(printer_log){
            printer_log?.addStatus("Can't create Receipt Data as it printed before")
            printer_log?.add_message("Can't create Receipt Data as it printed before")
            finalizePrinterObject()
            stop(savePrinterError:false)
            return false
        }
        }
        
        if !printData() {
            //            if  SharedManager.shared.appSetting().force_connect_with_printer == false
            //            {
            //                finalizePrinterObject()
            //            }
            
         
            stop()
            
            return false
        }
        
        
        
        printer_log?.add_message("Print Data")
        
        
        printer_log?.stop_at = printer_log?.get_date_now_formate_datebase()
        printer_log?.save()
        
        
        
        return true
    }
    
    func show_msg_error(_ resultCode:Int32, method:String)
    {
        if resultCode != EPOS2_ERR_ILLEGAL.rawValue{
        var msg =   NSLocalizedString(printer_message_class.getEposErrorText(resultCode),comment:"")
        msg = msg + printer_info()
        
        printer_message_class.show(msg, false)
        }
    }
    
    func printer_info() -> String
    {
        return  " / " + (printer_name ?? "") + " - " + (IP ?? "")
    }
    
    func printData() -> Bool {
        var status: Epos2PrinterStatusInfo?
        
        if printer == nil {
            self.current_job?.error = QUEUE_ENUM_ERROR.FAIL_PRINTER_NULL.get_error_info()

            return false
        }
        
        if !connectPrinter() {
            
//            printer_log?.status = "Can't connect to printer"
            printer_log?.addStatus("Can't connect to printer")

            printer_log?.stop_at = printer_log?.get_date_now_formate_datebase()
            printer_log?.add_message("Can't connect to printer")
            
            printer_message_class.show("Can't connect to printer" + printer_info() )
            DispatchQueue.global(qos:  .background).sync(execute: {
                self.arr_job.forEach { job in
                job.error =  job.error + "\n" + QUEUE_ENUM_ERROR.FAIL_PRINTER_CONNECT.get_error_info()
                let printer_error = printer_error_class(job: job , epson_printer: self,id_lg: printer_log?.id)
                printer_error.save()
            }
            // remove from qeue
                self.arr_job.removeAll()
            })
            
            return false
        }
        
        
        status = printer!.getStatus()
        //        dispPrinterWarnings(status)
        
        if !isPrintable(status) {
            self.current_job?.error += "\n" + "status_printer" + (self.current_job?.error ?? "")
                + "\n" + printer_message_class.makeErrorMessage(status)
            printer_message_class.show(printer_message_class.makeErrorMessage(status) + printer_info() )
            printer!.disconnect()
            return false
        }
        
        let result = printer!.sendData(Int(EPOS2_PARAM_DEFAULT))
        
        if result != EPOS2_SUCCESS.rawValue {
            
//            printer_log?.status = "Faild to print"
            printer_log?.addStatus("Faild to print")

            printer_log?.add_message("Faild to print")
            
            show_msg_error(result, method:"sendData")
            printer_message_class.show(printer_message_class.getEposErrorText(result) + printer_info() )
            self.current_job?.error = QUEUE_ENUM_ERROR.FAIL_SEND_DATA.get_error_info() + "\n------------------------\n" + printer_message_class.getEposErrorText(result)
            printer!.disconnect()
            return false
        }
        
        return true
    }
    
    func  printer_status_connected() ->  Bool {
        let status: Epos2PrinterStatusInfo  = printer!.getStatus()
        SharedManager.shared.printLog( printer_message_class.makeErrorMessage(status))
        if status.connection != EPOS2_FALSE
        {
 
            return true
        }
        else
        {
            self.current_job?.error = "printer_status_connected" + (self.current_job?.error ?? "")
                + "\n" + printer_message_class.makeErrorMessage(status)
            return false
        }
    }
    
    func initializePrinterObject() -> Bool {
        if self.state == .readyToPrint
        {
            return true
        }
        
        if self.state != .none
        {
            self.current_job?.error = QUEUE_ENUM_ERROR.FAIL_INITIALIZE_STATE_NONE.get_error_info()

            return false
        }
        
        self.state = .initializePrinter
 
//        self.printer_log = printer_log_class(fromDictionary: [:])

        if printer != nil
        {
          
    
            if printer_status_connected() == true
            {
                printer_log?.add_message("Printer aleardy connect.")

                return true
            }
       
        }
        
        printer = Epos2Printer(printerSeries: valuePrinterSeries.rawValue,
                               lang: valuePrinterModel.rawValue)
        
        if printer == nil {
            
            printer_log?.addStatus("Can't initialize Printer")
            printer_log?.stop_at = printer_log?.get_date_now_formate_datebase()
            printer_log?.add_message("Can't initialize Printer")
            self.current_job?.error = QUEUE_ENUM_ERROR.FAIL_INITIALIZE_PRINTER_NULL.get_error_info()
            return false
        }
        printer_log?.addStatus("Initialize Printer")
        printer_log?.add_message("Initialize Printer")
        
        printer!.setReceiveEventDelegate(self)
        printer!.setStatusChangeEventDelegate(self)
        
        printer!.startMonitor()
        
        self.state = .readyToPrint
        
        return true
    }
    
    func finalizePrinterObject() {
        
        if printer == nil {
            self.state = .none
            return
        }
        
        if   arr_job.count != 0
        {
            self.state = .readyToPrint
            return
        }
        
        printer_log?.stop_at = printer_log?.get_date_now_formate_datebase()
        printer_log?.add_message("Finalize Printer Object")
        
        printer!.clearCommandBuffer()
        printer!.setReceiveEventDelegate(nil)
        printer!.setStatusChangeEventDelegate(nil)
        
        printer = nil
        
//        PrintingNow = false
        self.state = .none
    }
    
    func connectPrinter() -> Bool {
        var result: Int32 = EPOS2_SUCCESS.rawValue
        
        if printer == nil {
            self.current_job?.error = "connect Printer is nil"
            return false
        }
        
        if printer_status_connected() == true
        {
            return true
        }
        
//        let status: Epos2PrinterStatusInfo  = printer!.getStatus()
//        SharedManager.shared.printLog( printer_message_class.makeErrorMessage(status))
//        if status.connection != EPOS2_FALSE
//        {
//            return true
//        }
        
        /*
         timeout
         
         Specifies the maximum time (in milliseconds) to wait for communication with the printer to be established.
         
         Integer from 1000 to 300000   Maximum wait time before an error is returned (in milliseconds).
         EPOS2_PARAM_DEFAULT           Specifies the default value (15000).
         */
        
        printer?.getStatus()
        //        result = printer!.connect("TCP:" + IP!, timeout:Int(EPOS2_PARAM_DEFAULT))
        let timeOutConnection = SharedManager.shared.appSetting().connection_printer_time_out
        result = printer!.connect("TCP:" + IP!, timeout:Int(timeOutConnection * 1000))
        
        if result != EPOS2_SUCCESS.rawValue
        {
            self.current_job?.error += "cann't connect Printer TCP:  \(IP ?? "")"
                + "\n-------------------------------\n" +
                "state printer \(self.state) "
                + "\n-------------------------------\n" +
                 (self.current_job?.error ?? "")
                + "\n-------------------------------\n" +
                printer_message_class.getEposErrorText(result)
           
            NotificationCenter.default.post(name: Notification.Name("printer_status"), object: self)
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
            self.current_job?.error = "disconnect Printer begin Transaction " + (self.current_job?.error ?? "")
                + "\n" + printer_message_class.getEposErrorText(result)
            printer?.disconnect()
            return false
            
        }
        return true
    }
    
    func disconnectPrinter() {
        var result: Int32 = EPOS2_SUCCESS.rawValue
        
        if printer == nil {
            self.state = .none
            return
        }
        
        
        result = printer!.endTransaction()
        if result != EPOS2_SUCCESS.rawValue {
            DispatchQueue.main.async(execute: {
                self.show_msg_error(result, method:"endTransaction")
            })
        }
        
        
        if   arr_job.count != 0
        {
            self.state = .readyToPrint
            return
        }
//        SharedManager.shared.epson_queue.is_run = false
        result = printer?.disconnect() ?? EPOS2_ERR_FAILURE.rawValue
        if result != EPOS2_SUCCESS.rawValue {
            DispatchQueue.main.async(execute: {
                self.show_msg_error(result, method:"disconnect")
            })
        }
        
        
        finalizePrinterObject()
    }
    
    func isPrintable(_ status: Epos2PrinterStatusInfo?) -> Bool {
        if status == nil {
            self.current_job?.error = QUEUE_ENUM_ERROR.FAIL_STATUS_NUL.get_error_info()
            return false
        }
        
        if status!.connection == EPOS2_FALSE {
            
//            printer_log?.status = "Not connected"
            printer_log?.addStatus("Not connected")

            printer_log?.add_message("Not connected")
            self.current_job?.error = QUEUE_ENUM_ERROR.FAIL_STATUS_CONNECTION.get_error_info()

            
            return false
        }
        else if status!.online == EPOS2_FALSE {
//            printer_log?.status = "Printer offline"
            printer_log?.addStatus("Can't Print Receipt Data as printer is Offline")

            printer_log?.add_message("Can't Print Receipt Data as printer is Offline")
            self.current_job?.error = QUEUE_ENUM_ERROR.FAIL_STATUS_ONLINE.get_error_info()
            return false
        }
        else {
            // print available
        }
        return true
    }
    
    
    func onPtrReceive(_ printerObj: Epos2Printer!, code: Int32, status: Epos2PrinterStatusInfo!, printJobId: String!) {
        
//        DispatchQueue.global(qos: .background).async(execute: {
            
           
//            DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + .milliseconds(500)) {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async(execute: {
            self.printer_log?.addStatus("Epos2PrinterStatusInfo is \( status?.errorStatus ?? -1)")
            self.printer_log?.add_message("Epos2PrinterStatusInfo is \(status?.errorStatus ?? -1)")
            
            self.printer!.clearCommandBuffer()
            self.disconnectPrinter()
            self.handel_print_status(is_ptint: (status?.errorStatus == EPOS2_SUCCESS.rawValue || status?.errorStatus == -3 ))
            NotificationCenter.default.post(name: Notification.Name("printer_status"), object: self)
            let errMessage = printer_message_class.makeErrorMessage(status)
            
            if !errMessage.isEmpty
            {
               SharedManager.shared.printLog("printer_Queue(\(self.IP ?? ""): error \(errMessage)")
                
                printer_message_class.showResult(code, errMessage:errMessage )
                self.printer_log?.addStatus(errMessage)

//                self.printer_log?.status = errMessage

                self.is_printer_online = false

            }
            else
            {
                self.is_printer_online = true

            }
            
            if status.errorStatus == 0 && errMessage.isEmpty
            {
                self.printer_log?.printed = true
            
            }
        self.printer_log?.print_job_id = printJobId ?? ""
        self.printer_log?.stop_at = self.printer_log?.get_date_now_formate_datebase()
        self.printer_log?.save()
       SharedManager.shared.printLog("printer_Queue(\(self.IP ?? ""): \("print complete") " )
//            if self.printer != nil
//            {
//                self.state = .readyToPrint
//            }
//            self.PrintingNow = false
            
           // self.delegate?.queue_done(IP: self.IP!)
            })
//        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + .seconds(3)) {
//
//        }


            
//        })
    }
    
    
    
    
}
