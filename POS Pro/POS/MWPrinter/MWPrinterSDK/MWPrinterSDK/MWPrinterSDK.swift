//
//  MWPrinterSDK.swift
//  pos
//
//  Created by M-Wageh on 07/06/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation
import FirebaseCrashlytics

class MWPrinterSDK{
    var mwFileInQueue:MWFileInQueue?
    var printerSDK:MWPrinterSDKProtocol?
    var printer_log:printer_log_class?
    private var tryConnectCount:Int?
    static let shared:MWPrinterSDK = MWPrinterSDK()
    private init(){
        if SharedManager.shared.appSetting().enable_reconnect_with_printer_automatic{
            tryConnectCount = 1
        }
        
    }
    func initalize(with mwFileInQueue: MWFileInQueue) {
        if SharedManager.shared.appSetting().enable_reconnect_with_printer_automatic{
            tryConnectCount = 1
        }
        self.printer_log = printer_log_class(fromDictionary: [:])
        self.mwFileInQueue = mwFileInQueue
        setPrinterSDK(from:mwFileInQueue.restaurantPrinter)
        printerLogInitalizeWith()
    }
    func checkConnection(for resturantPrinter:restaurant_printer_class){
        if printerSDK == nil {
            handleError("detect brand and model for printer")
            return
        }
        var ip = resturantPrinter.printer_ip
        if printerSDK is MWEpsonInteractor {
            if let macPrinter = resturantPrinter.mac_address,!macPrinter.isEmpty {
                ip = macPrinter
            }
        }
        
        if printerSDK is MWUsbPrinterInteractor {
            //ip = MWUsbPrinterInteractor.shared.printerIdentifier ?? ""
            SharedManager.shared.printLog("USB Identifier = \(ip)")
        }
        
        printerSDK?.connect(with: ip , success: {
            self.printerSDK?.disConnect()
            self.showFailToastMessage(message:"Connection success".arabic("تم الاتصال بنجاح") ,title:"Connection success".arabic("تم الاتصال بنجاح") ,isSucess: true,image: "icon_done")
            self.printerSDK = nil
            self.postNotification()
        }, failure: { error in
            self.handleError("Connect failed \(error)")
            self.printerSDK = nil
            self.postNotification()
        }, receiveData: { data in
        })

    }
    func postNotification(){
        NotificationCenter.default.post(name: Notification.Name("test_connection_done"), object: nil)
    }
    func setPrinterSDK(from resturantPrinter:restaurant_printer_class?){
        self.printerSDK = nil
        let typeCon = resturantPrinter?.connectionType  ?? .WIFI
        switch typeCon{
        case .BLUETOOTH:
            if  resturantPrinter?.is_ble_con_2 ?? false || resturantPrinter?.connectionType == .BLUETOOTH {
                let printerBle = MWPrinterBluetooth.shared
                if let brand_printer = resturantPrinter?.brand, !brand_printer.isEmpty{
                    if ((brand_printer.lowercased().contains("epson"))){
                        printerBle.setBrand(with:.EPSON )
                        printerBle.mwEpsonBluetooth?.initalize()

                    }else{
                        printerBle.setBrand(with:.HPRT )

                    }
                }
                printerSDK  = printerBle
               return
            }
        case .USB:
            if resturantPrinter?.connectionType == .USB {
                let printerUsb = MWUsbPrinterInteractor.shared
                printerSDK  = printerUsb
            }
        default:
            if let brand_printer = resturantPrinter?.brand, !brand_printer.isEmpty{
                            
                if ((brand_printer.lowercased().contains("epson"))){
                    let EpsonSDK = MWEpsonInteractor.shared
                    EpsonSDK.initalize()
                    printerSDK = EpsonSDK
                }else  if ((brand_printer.lowercased().contains("x_printer"))){
                    printerSDK = XprinterInteractor.shared
                }else{
                    printerSDK = HPRTInteractor.shared

                }
            }else {
                //EPSON
                let EpsonSDK = MWEpsonInteractor.shared
                EpsonSDK.initalize()
                printerSDK = EpsonSDK
                
            }
        
        }
       
        
      


    }
    //MARK: - Printing Receipt Fail
    func handleError(_ error:String){
        //WARING: - show Notification erro
        let errorMsg = "Can't Print :- " + error
        let fileName = "\(Date().timeIntervalSince1970).png"

        self.appendMessageLog(errorMsg)
        self.printerSDK?.disConnect()
        self.printer_log?.printed = false
        self.printer_log?.stop_at = printer_log?.get_date_now_formate_datebase()
        if let _ = mwFileInQueue?.image, (mwFileInQueue?.html ?? "").isEmpty {
            printer_log?.html = "FILE_NAME:" + fileName
        }
        self.printer_log?.save()
        if let mwFileQueue = mwFileInQueue{
            if mwFileQueue.printer_error_id == nil {
                let printer_error = printer_error_class(mwFileInQueue:mwFileQueue,
                                                        fileName:fileName,
                                                        error:errorMsg,
                                                        id_lg:self.printer_log?.id ?? 0)
                printer_error.save()
            }
        }
        if (self.mwFileInQueue?.printer_error?.rePrinting_status ?? PRINTER_ERROR_STATUS.NONE).rawValue != PRINTER_ERROR_STATUS.PRINTING_BY_APP.rawValue{
            self.showFailToastMessage(message:"Can't Print :- " + error)
        }
        self.mwFileInQueue?.stop(with: .FAIL)
        if SharedManager.shared.appSetting().enable_enhance_printer_cyle {
            self.printerSDK?.disConnect()
            self.mwFileInQueue?.goNext()
        }
//        self.printerSDK = nil
//        self.mwFileInQueue = nil
    }
    func checkIntailizeNexFile(complete:()->Void){
        if let nextFile = self.mwFileInQueue?.getNextFile(){
            self.initalize(with: nextFile)
//            self.connectSuccessHandler()
            complete()
        }else{
            self.printerSDK?.disConnect()
            self.mwFileInQueue?.goNext()
        }
    }
    //MARK: - Receipt print Success
    func handleSuccessPrinte(){
        self.appendMessageLog("Success print receipt")
        if !SharedManager.shared.appSetting().enable_enhance_printer_cyle {
            self.printerSDK?.disConnect()
        }
        self.printer_log?.printed = true
        self.printer_log?.stop_at = printer_log?.get_date_now_formate_datebase()
        self.printer_log?.save()
        self.mwFileInQueue?.stop(with: .DONE)
        if SharedManager.shared.appSetting().enable_enhance_printer_cyle {
            if let nextFile = self.mwFileInQueue?.getNextFile(){
                self.initalize(with: nextFile)
                self.connectSuccessHandler()
            }else{
                self.printerSDK?.disConnect()
                self.mwFileInQueue?.goNext()
            }
        }
    
//        self.printerSDK = nil
//        self.mwFileInQueue = nil


    }
    //MARK: - # Life Cycle Printer
    //MARK: - Run Printer
    //MARK: - #.1- Connect Success Handler
    func runPrinter(){
        let macAddressPrinter =  self.mwFileInQueue?.restaurantPrinter?.mac_address ?? ""
        let ipPrinter =  self.mwFileInQueue?.restaurantPrinter?.printer_ip

        self.appendMessageLog("""
        Run Printer brand \(self.mwFileInQueue?.restaurantPrinter?.brand ?? "") with model \(self.mwFileInQueue?.restaurantPrinter?.model ?? "") and ip \(ipPrinter ?? "") and mac \(macAddressPrinter) and name \(self.mwFileInQueue?.restaurantPrinter?.name ?? "")
        """)
        if printerSDK == nil {
            handleError("detect brand and model for printer")
            return
        }
        guard var ip = self.mwFileInQueue?.restaurantPrinter?.printer_ip else  {
            handleError("Empty Ip")
            return
        }
        /*
        if printerSDK is MWEpsonInteractor {
        if  !macAddressPrinter.isEmpty {
            ip = macAddressPrinter
        }
        }
        */
        self.appendMessageLog("[Start] Connect printer")
        printerSDK?.connect(with: ip , success: {
            self.connectSuccessHandler()
            
        }, failure: { error in
            if AppDelegate.shared.enable_debug_mode_code() == true
            {
                FileMangerHelper.shared.saveFile(image: self.createImageReceipt() ?? UIImage() , with: "bill + \(Int(Date().timeIntervalSince1970 * 1000)).png")
            }
            let errorCrashlytics = NSError(domain: "Printer Connection", code: 7000, userInfo:
                                    [
                                        "error:" :  "Printer Connection Failed",
                                        "printer_ip" :  ip,
                                        "printer_mac_address": macAddressPrinter,
                                        "printer_brand": self.mwFileInQueue?.restaurantPrinter?.brand ?? "" ,
                                        "printer_model": self.mwFileInQueue?.restaurantPrinter?.model ?? "",
                                        "printer_name": self.mwFileInQueue?.restaurantPrinter?.name ?? ""
                                    ])
            Crashlytics.crashlytics().record(error: errorCrashlytics)
//            if let tryConnectCount = self.tryConnectCount{
//                if (tryConnectCount ) <= 4{
//                        self.tryConnectCount! += 1
//                        self.runPrinter()
//                        return
//                }
//            }
            self.handleError("Connect fali \(error)")
        }, receiveData: { data in
            self.appendMessageLog("Connect receiveData")
        })
    }
    func connectSuccessHandler(){
        checkStatusPrinter { ready, image in
            self.appendMessageLog("connectSuccessHandler ready \(ready) image \(image != nil) ")

            if let image =  image, ready {
                self.appendMessageLog("connectSuccessHandler2 ready \(ready) image true ")
                self.printerSDK?.startPrint(image: image,openDrawer: self.mwFileInQueue?.openDrawer ??  false,sendFailure: { error in
                    self.handleError("Status Printer fali \(error)")
                })
                self.sendImageCompleteHandler()
            }else{
                //error
                self.appendMessageLog("connect Success Handler Fail with ready \(ready) and image \(image != nil)")

            }
            
        }
    }
    //MARK: - #.2- check Status Printer
    func checkStatusPrinter(ready:@escaping (Bool,UIImage?) -> Void){
        self.appendMessageLog("check Status Printer Start")
        printerSDK?.statusPrinter(success: {
            self.appendMessageLog("check Status Printer Success and ready")
            ready(true,self.createImageReceipt())
        }, failure: { error in
            self.handleError("Status Printer fali \(error)")
            ready(false,nil)
        })
    }
    //MARK: - #.2- send Image to Printer
    func sendImageCompleteHandler(){
        self.appendMessageLog("[Start] Send Image CompleteHandler ")

        self.printerSDK?.handlerSendToPrinter(sendSuccess: {
            self.appendMessageLog("send Success Send Image CompleteHandler ")
            self.handleSuccessPrinte()
        }, sendFailure: { error in
            self.handleError("Send Image fali \(error)")
        }, sendProgressUpdate: { progress in
            self.appendMessageLog("progress Send Image CompleteHandler \(progress ?? 0)")
            if (progress ?? 0) < 100 {
            if (Int((progress ?? 0)).isMultiple(of: 10)) {
                self.appendMessageLog("progress Send Image CompleteHandler \(progress ?? 0)")
            }
            }
        }, receiveData: { data in
            self.appendMessageLog("receiveData Send Image CompleteHandler ")
        }, printSuccess: {
            self.handleSuccessPrinte()
        })
    }
    
    func openDrawer(for resturantPrinter:restaurant_printer_class,completeHandler:@escaping (Bool)->Void){
        self.setPrinterSDK(from:resturantPrinter)
        if printerSDK == nil {
            completeHandler(false)
            return
        }
        var ip = resturantPrinter.printer_ip
        if printerSDK is MWEpsonInteractor {
            if let macPrinter = resturantPrinter.mac_address,!macPrinter.isEmpty {
                ip = macPrinter
            }
        }
        
        printerSDK?.connect(with: ip , success: {
            self.printerSDK?.openDrawer(completeHandler: { isOpen in
                self.printerSDK?.disConnect()
                self.printerSDK = nil
                completeHandler(isOpen)
            })
        }, failure: { error in
            completeHandler(false)
            self.printerSDK = nil
        }, receiveData: { data in
        })

    }
    
}
extension MWPrinterSDK {
    func showFailToastMessage(message:String,title:String = "Fail Printing".arabic("فشل الطباعه"),isSucess:Bool = false,image:String = "icon_error"){
        DispatchQueue.main.async {
        SharedManager.shared.initalBannerNotification(title: title ,
                                                      message: message,
                                                      success: isSucess, icon_name: image)
        SharedManager.shared.banner?.dismissesOnTap = true
        SharedManager.shared.banner?.show(duration: 3.0)
    }
    }
    //MARK: - Helper Method For convert html to Image
    func createImageReceipt() -> UIImage?{
        if let imageFile = mwFileInQueue?.image {
           return imageFile
        }
        if (mwFileInQueue?.image  == nil) && ((mwFileInQueue?.html ?? "").isEmpty) {
            handleError("There is nothing for printing")
            return nil
        }
        var image:UIImage? = nil
        getImageWithTry(3, success: { screenShot in
                image = screenShot
        })
        if image == nil {
            let order_id =  self.mwFileInQueue?.order?.uid ?? ""
            let row_type =  self.mwFileInQueue?.row_type

            let memoryReport = SharedManager.shared.reportMemory()
            self.handleError("create Receipt Data graphic context is not available so you can not create an image. \n \(memoryReport)")
            
            let error = NSError(domain: "GraphicImage", code: 5003, userInfo:
                                    [
                                        "error:" :  "graphic context is not available so you can not create an image",
                                        "order_id" :  order_id,
                                        "memoryReport" : memoryReport
                                    ])
            
            Crashlytics.crashlytics().record(error: error)
            SharedManager.shared.report_memory(prefix:"create_receipt")
            let GraphicContextFailOrderIId = cash_data_class.get(key: "GraphicContextFailOrderUId") ?? ""
            if ((row_type == .order) && (GraphicContextFailOrderIId != order_id))  {
                cash_data_class.set(key: "GraphicContextFailOrderUId", value:order_id)
                let _ = image!.toBase64()
                return image
            }

        }
        cash_data_class.set(key: "GraphicContextFailOrderUId", value:"" )
        return image
    }
    func getImageWithTry(_ times:Int, success: @escaping (UIImage?) -> Void){
        guard let fileQueue = self.mwFileInQueue else {return}
        let image:UIImage? =  runner_print_class.htmlToImage(html: fileQueue.html)
        if image == nil && times > 0{
            getImageWithTry(times - 1 , success:success)
        }
        success(image)
    }
    //MARK: - printer Log
    func appendMessageLog(_ msg:String){
        printer_log?.addStatus(msg)
        printer_log?.add_message(msg)
    }
    func printerLogInitalizeWith(){
        guard let fileQueue = self.mwFileInQueue else {return}
        guard let restaurantPrinter = fileQueue.restaurantPrinter else {return}
        let wifiName =  WiFi.shared.getWiFiName()
        let IP = restaurantPrinter.printer_ip
        let printer_name = restaurantPrinter.name
        let order_id = fileQueue.order?.id ?? 0
        printer_log?.id = 0
        printer_log?.is_from_ip = fileQueue.isFromIp ?? false
        printer_log?.ip = IP
        printer_log?.printer_name = printer_name
        printer_log?.start_at = printer_log?.get_date_now_formate_datebase()
        printer_log?.order_id = order_id
        printer_log?.row_type =  fileQueue.row_type
        printer_log?.sequence = pos_order_helper_class.get_print_count(order_id: order_id)
        //        if current_job?.type == .image && ((current_job?.html.isEmpty ?? true) ){
        //            let fileName = "\(fileQueue.order?.id)-\(IP)-\(printer_name).png"
        //            printer_log?.html = "FILE_NAME:" + fileName
        //        }else{
        printer_log?.html = fileQueue.html
        // }
        printer_log?.wifi_ssid = wifiName
    }
}
