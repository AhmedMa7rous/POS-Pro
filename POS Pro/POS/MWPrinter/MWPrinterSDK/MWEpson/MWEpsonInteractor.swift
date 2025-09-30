//
//  MWEpson.swift
//  pos
//
//  Created by M-Wageh on 07/06/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation
import UIKit

class MWEpsonInteractor:NSObject{
    private var printer:Epos2Printer?
    private var valuePrinterSeries: Epos2PrinterSeries?
    private var valuePrinterModel: Epos2ModelLang?
    private var imageReceipt:UIImage?
    private var openDeawer:Bool = false
    private var sendSuccess: ( () -> Void)?
    private var sendFailure: ((String) -> Void)?
    static let shared = MWEpsonInteractor()
    private override init(){
        super.init()
    }
    func initalize()  {
        self.valuePrinterSeries = EPOS2_TM_T20
        self.valuePrinterModel = EPOS2_MODEL_ANK
        printer = Epos2Printer(printerSeries: valuePrinterSeries?.rawValue ?? 6,
                               lang: valuePrinterModel?.rawValue ?? 0)
        printer?.setReceiveEventDelegate(self)
        printer?.setStatusChangeEventDelegate(self)
        printer?.startMonitor()
    }
    func connectPrinter(with ip:String,success: @escaping () -> Void, failure: @escaping (String) -> Void){
        var result: Int32 = EPOS2_SUCCESS.rawValue
        let timeOutConnection = SharedManager.shared.appSetting().connection_printer_time_out
        result = printer?.connect("TCP:" + ip, timeout:Int(timeOutConnection * 1000)) ?? EPOS2_ERR_FAILURE.rawValue
        getPrinterStatus(success:success, failure: failure)
       

    }

    private func getPrinterStatus(success: @escaping () -> Void, failure: @escaping (String) -> Void) {
        if printer == nil {
            failure("EPSON Printer not found")
        }
        let status: Epos2PrinterStatusInfo  = printer!.getStatus()
        if status.connection != EPOS2_FALSE
        {
            let result =  printer?.beginTransaction() ?? EPOS2_ERR_FAILURE.rawValue
            if result != EPOS2_SUCCESS.rawValue && result != EPOS2_ERR_ILLEGAL.rawValue {
                failure(QUEUE_ENUM_ERROR.BEGIN_TRANSACTION.get_error_info())

            }else{
                success()
            }
        }
        else
        {
            failure("printer_status_connected"  + "\n" + printer_message_class.makeErrorMessage(status))
            return
        }
    }
 
    func createReceiptData(imageData:UIImage?,openDeawer:Bool = false) {
        self.openDeawer = openDeawer
        imageReceipt = imageData
       if imageData != nil {
            var size : CGSize = imageReceipt!.size
            let width: CGFloat = 580
            let ratio =  size.width /  size.height
            let newHeight = width / ratio
            size.width = width
            size.height = newHeight
           imageReceipt = imageReceipt?.ResizeImage(targetSize:size)
        }
    }
    func sendReceipt(){
        guard let imageReceipt = self.imageReceipt else {
            sendFailure?("Receipt is NULL ")
            return
        }
        let size : CGSize = imageReceipt.size
        var result = EPOS2_SUCCESS.rawValue
        result = printer?.add(imageReceipt, x: 0, y:0,
                              width:Int(size.width),
                              height:Int(size.height),
                              color:EPOS2_COLOR_1.rawValue,
                              mode:EPOS2_MODE_MONO.rawValue,
                              halftone:EPOS2_HALFTONE_THRESHOLD.rawValue,
                              brightness:Double(1),
                              compress:EPOS2_COMPRESS_NONE.rawValue) ?? EPOS2_ERR_FAILURE.rawValue
        
        if result != EPOS2_SUCCESS.rawValue {
            sendFailure?(QUEUE_ENUM_ERROR.FAIL_CREATE_DATA_PRINTER_ADD.get_error_info())
            return
            
        }
        if self.openDeawer {
            result = printer!.addPulse(EPOS2_PARAM_DEFAULT, time: EPOS2_PARAM_DEFAULT)
            if result != EPOS2_SUCCESS.rawValue {
                sendFailure?(QUEUE_ENUM_ERROR.FAIL_CREATE_DATA_PRINTER_ADD_PULSE.get_error_info())
                return
            }
            
        }
#if DEBUG
        SharedManager.shared.printLog("Not cut printer")
#else

        result = printer!.addCut(EPOS2_CUT_FEED.rawValue)
#endif

        if result != EPOS2_SUCCESS.rawValue {
            sendFailure?(QUEUE_ENUM_ERROR.FAIL_CREATE_DATA_PRINTER_ADD_CUT.get_error_info())
            return
        }

        
        result = printer?.sendData(Int(EPOS2_PARAM_DEFAULT))  ?? EPOS2_ERR_FAILURE.rawValue
        if result != EPOS2_SUCCESS.rawValue {
            sendFailure?(QUEUE_ENUM_ERROR.FAIL_SEND_DATA.get_error_info())
    }
}
}
extension MWEpsonInteractor:MWPrinterSDKProtocol{
    func connect(with ip: String, success: @escaping () -> Void, failure: @escaping (String) -> Void, receiveData: @escaping (Data?) -> Void) {
        self.connectPrinter(with: ip, success: success, failure: failure)
    }
    
    func statusPrinter(success: @escaping () -> Void, failure: @escaping (String) -> Void) {
        getPrinterStatus(success:success, failure: failure)

    }
    
    func startPrint(image: UIImage?,openDrawer:Bool,sendFailure: ((String) -> Void)? ) {
        createReceiptData(imageData:image,openDeawer: openDrawer)
    }
    
    func handlerSendToPrinter(sendSuccess: @escaping () -> Void, sendFailure: @escaping (String) -> Void, sendProgressUpdate: ((Double?) -> Void)?, receiveData: ((Data?) -> Void)?, printSuccess: @escaping () -> Void) {
        self.sendSuccess = sendSuccess
        self.sendFailure = sendFailure

        sendReceipt()
    }
    
    func disConnect() {
        self.imageReceipt = nil
        self.openDeawer = false
        self.sendFailure = nil
        self.sendSuccess = nil
        printer?.endTransaction()
        printer?.disconnect()
        stop_monitor()
    }
    func openDrawer(completeHandler: @escaping (Bool) -> Void){
        guard let printer = self.printer else{return}
        var result = printer.addPulse(EPOS2_PARAM_DEFAULT, time: EPOS2_PARAM_DEFAULT)
        if result != EPOS2_SUCCESS.rawValue {
            completeHandler(false)
            return
        }
        result = printer.sendData(Int(EPOS2_PARAM_DEFAULT))
        if result != EPOS2_SUCCESS.rawValue {
            completeHandler(false)
            return
        }

        completeHandler(true)
    }

    
    
}
extension MWEpsonInteractor: Epos2PtrReceiveDelegate ,Epos2PtrStatusChangeDelegate{
  
    func onPtrStatusChange(_ printerObj: Epos2Printer!, eventType: Int32) {
        disConnect()
    }
    func onPtrReceive(_ printerObj: Epos2Printer!, code: Int32, status: Epos2PrinterStatusInfo!, printJobId: String!) {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async(execute: {
            let isSuccessPrinting = (status?.errorStatus == EPOS2_SUCCESS.rawValue || status?.errorStatus == -3 )
            let errMessage = printer_message_class.makeErrorMessage(status)
            if !errMessage.isEmpty
            {
                self.sendFailure?("\(code)" + " " + errMessage )
                return
            }else{
                self.sendSuccess?()
                //and go to next queue
            }
            self.printer?.clearCommandBuffer()
         //   self.disConnect()

        })
    }
   private func stop_monitor()
    {
        if printer == nil
        {
            return
        }
        
        printer?.stopMonitor()
        printer?.clearCommandBuffer()
        printer?.setReceiveEventDelegate(nil)
        printer?.setStatusChangeEventDelegate(nil)
        
//        printer = nil
        
    }
    
}
