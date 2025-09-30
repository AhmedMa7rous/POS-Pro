//
//  MWPrinterBluetooth.swift
//  pos
//
//  Created by M-Wageh on 31/01/2024.
//  Copyright © 2024 khaled. All rights reserved.
//

import Foundation
import PrinterSDK
enum MWPrinterBluetooth_SATE{
    case NONE,Loading,Populate,Selected(restaurant_printer_class),Error(String)
}

extension restaurant_printer_class {
    static func intilize(from ptPrinter:PTPrinter ) -> restaurant_printer_class{
        var blePrinter = restaurant_printer_class(fromDictionary: [:])
        blePrinter.name = ptPrinter.name
        blePrinter.printer_ip = ptPrinter.mac
        blePrinter.is_ble_con_2 = true
        blePrinter.connectionType = ConnectionTypes(rawValue: "BLUETOOTH")
        return blePrinter
    }
    static func getBlePrinter() -> restaurant_printer_class?{
        let sql = "select * from restaurant_printer where is_ble_con_2 = 1"
        let result = database_class(connect: .database).get_rows(sql:sql)
        if let printerDic = result.first{
            return restaurant_printer_class(fromDictionary: printerDic)
        }
        return nil
    }
    static func inilaize(from deviceInfo:Epos2DeviceInfo) -> restaurant_printer_class{
        var blePrinter = restaurant_printer_class(fromDictionary: [:])
        blePrinter.name = deviceInfo.deviceName
        blePrinter.printer_ip = deviceInfo.target
        blePrinter.is_ble_con_2 = true
        blePrinter.connectionType = ConnectionTypes(rawValue: "BLUETOOTH")
        return blePrinter

    }
    
}
extension MWPrinterBluetooth{
    func findByHPRT(with reset:Bool = false,mac_ssd:String? = nil){
        if  reset {
            ptDispatcher?.stopScanBluetooth()
            dataSources.removeAll()
            state = .Populate

        }else{
            ptDispatcher?.unconnectBlock = nil

        }
        state = .Loading
        ptDispatcher?.scanBluetooth()
        findAllHPRTBluetooth(blePrinterMac: mac_ssd)
    }
    func getHPRTPrinter(for mac:String) -> PTPrinter?{
        if  self.dataSources.count > 0 {
           return  self.dataSources.first(where: {$0.mac == mac})
        }
        return nil
    }
    func setHPRT(with mac:String){
        if self.selectedPrinter == nil{
            if self.dataSources.count > 0 {
                self.selectedPrinter = self.dataSources.first(where: {$0.mac == mac})
            }}else{
                ptDispatcher?.stopScanBluetooth()
            }
    }
    func connectHPRTBle(success: @escaping () -> Void, failure: @escaping (String) -> Void, receiveData: @escaping (Data?) -> Void){
        if let selectedPrinter = selectedPrinter {
            ptDispatcher?.connect(self.selectedPrinter)
            ptDispatcher?.whenConnectSuccess { [weak self] in
                guard let self = self else { return }
                self.isConnect = true
                success()
//                SVProgressHUD.dismiss()
//                self.showAlert(title: "Select paper size".localized, buttonTitles: ["2\" (384dots)", "3\" (576dots)","3\" (640dots)", "4\" (832dots)","8\" (2360dots)", "12\" (3540dots)"], handler: { (selectedButtonIndex) in
//                    self.didSelectPaperSize(buttonIndex: selectedButtonIndex)
//                })
            }
            
            ptDispatcher?.whenConnectFailureWithErrorBlock { (error) in
                var errorStr: String?
                switch error {
                case .bleTimeout:
                    errorStr = "Connection timeout"
                case .bleValidateTimeout:
                    errorStr = "Vertification timeout"
                case .bleUnknownDevice:
                    errorStr = "Unknown device"
                case .bleSystem:
                    errorStr = "System error"
                case .bleValidateFail:
                    errorStr = "Vertification failed"
                case .bleDisvocerServiceTimeout:
                    errorStr = "Connection failed"
                default:
                    break
                }
                if let temp = errorStr {
                    failure(temp)
                }
            }
            
            ptDispatcher?.whenReceiveData({ (_) in
                
            })
        }
    }
    func findAllHPRTBluetooth(blePrinterMac:String? = nil,completeHandler:(()->())? = nil){
        ptDispatcher?.whenFindAllBluetooth({ [weak self] in
            guard let self = self else { return }
            completeHandler?()
            SharedManager.shared.printLog("ble device = \($0)")
            guard let temp = $0 as? [PTPrinter] else { return }
            self.dataSources = temp.sorted(by: { (pt1, pt2) -> Bool in
                return pt1.distance.floatValue < pt2.distance.floatValue
            })
            if let blePrinter = blePrinterMac {
                self.setSelect(with:blePrinter)
            }
            state = .Populate
        })
    }
    func resetHprtBLE(){
        ptDispatcher?.whenConnectSuccess(nil)
        ptDispatcher?.whenConnectFailureWithErrorBlock(nil)
    }
    func whenUnConnectHandler(){
        ptDispatcher?.whenUnconnect { (_) in
            self.ptDispatcher?.sendSuccessBlock = nil
            self.ptDispatcher?.sendFailureBlock = nil
            self.ptDispatcher?.sendProgressBlock = nil
            self.ptDispatcher?.connectFailBlock = nil
            self.ptDispatcher?.connectSuccessBlock = nil
            self.ptDispatcher?.readRSSIBlock = nil
            self.ptDispatcher?.receiveDataBlock = nil
        }
    }
    
    func initalizeCompeteSend(sendSuccess: @escaping () -> Void, sendFailure: @escaping (String) -> Void, sendProgressUpdate: ((Double?) -> Void)?, receiveData: ((Data?) -> Void)?, printSuccess: @escaping () -> Void){
        ptDispatcher?.whenSendFailure({
            sendFailure("Data send failed")
        })
        
        ptDispatcher?.whenSendProgressUpdate({progress in
            sendProgressUpdate?(Double(progress ?? 0))
        })
        
        ptDispatcher?.whenSendSuccess({ _,_ in
            sendSuccess()
            
//            UIAlertController.showConfirmView("Tips".localized, message: "Data sent successfully".localized + ",  " +  "Total data:".localized + "\($0/1000) kb,  " + "Total time:".localized + String.init(format: "%.1f s,  ", $1) + "Transmission rate:".localized + String.init(format: "%.1f kb/s", Double($0/1000)/$1), confirmHandle: nil)
        })
        
        ptDispatcher?.whenReceiveData({ (data) in
            SharedManager.shared.printLog("Print whenReceiveData")
            receiveData?(data)
            guard let data = data else {return}
            print(#line,data.hexString)
        })
        
        ptDispatcher?.whenESCPrintSuccess { _ in
            printSuccess()

        }
        ptDispatcher?.whenConnectFailureWithErrorBlock{ error in
            var errorStr: String?
            switch error {
            case .bleTimeout:
                errorStr = "Connection timeout"
            case .bleValidateTimeout:
                errorStr = "Vertification timeout"
            case .bleUnknownDevice:
                errorStr = "Unknown device"
            case .bleSystem:
                errorStr = "System error"
            case .bleValidateFail:
                errorStr = "Vertification failed"
            case .bleDisvocerServiceTimeout:
                errorStr = "Connection failed"
            default:
                break
            }
            if let temp = errorStr {
                sendFailure(temp)
            }
            
        }
    }
    
    func competeHandlerPrinter(cmdData:Data){
        ptDispatcher?.send(cmdData)
      
    }
}
class MWPrinterBluetooth {
    private var dataSources = [PTPrinter]()
    private var selectedPrinter:PTPrinter?

    var state:MWPrinterBluetooth_SATE = .NONE{
        didSet {
            self.updateLoadingStatusClosure?()
        }
    }
    var isConnect:Bool?
    var ptDispatcher:PTDispatcher?
    var updateLoadingStatusClosure: (() -> Void)?
    var brandPrinter:PRINTER_BRAND_TYPES?
     var mwEpsonBluetooth:MWEpsonBluetooth?

//    init(dataSources: [PTPrinter] = [PTPrinter](), state: MWPrinterBluetooth_SATE) {
//        self.dataSources = dataSources
//        self.state = state
//    }
    static let shared:MWPrinterBluetooth = MWPrinterBluetooth(brandPrinter: .EPSON)
    
    private init(brandPrinter:PRINTER_BRAND_TYPES?){
        self.brandPrinter = brandPrinter
        if (brandPrinter ?? .HPRT) == .EPSON{
            mwEpsonBluetooth = MWEpsonBluetooth()
           // mwEpsonBluetooth?.initalize()

        }else{
            ptDispatcher = PTDispatcher.share()
        }
    }
    func setBrand(with brandPrinter:PRINTER_BRAND_TYPES,resetVar:Bool = false){
        self.brandPrinter = brandPrinter
        if resetVar{
            mwEpsonBluetooth = nil
            selectedPrinter = nil
            isConnect = false
            dataSources.removeAll()
            mwEpsonBluetooth?.selectDevice = nil
            mwEpsonBluetooth?.printerList.removeAll()
        }
    
    }
    
    func findDevices(with reset:Bool = false,mac_ssd:String? = nil){
        if (brandPrinter ?? .HPRT) == .EPSON{
            self.mwEpsonBluetooth?.findByEpson(with: reset, mac_ssd: mac_ssd)
        }else{
            self.findByHPRT(with: reset, mac_ssd: mac_ssd)
        }
    }
    
    
    func initalizeBLE(){
        
        
        if self.selectedPrinter == nil {
            if let blePrinter = restaurant_printer_class.getBlePrinter(){
                if (brandPrinter ?? .HPRT) == .EPSON{
                    if let ssdPrinter = mwEpsonBluetooth?.getEpson(for: blePrinter.printer_ip) {
                        mwEpsonBluetooth?.selectDevice = ssdPrinter
                        return
                    }
                }else{
                    if let ssdPrinter = self.getHPRTPrinter(for: blePrinter.printer_ip) {
                        self.selectedPrinter = ssdPrinter
                        return
                    }
                }
                self.findDevices(mac_ssd: blePrinter.printer_ip)
                
            }
        }
         

    }
    func loadBLE() {
//        self.tableView.reloadData()
        DispatchQueue.main.async{
            self.findDevices(with: true)
        }
       
       
//        if ptDispatcher?.getBluetoothStatus() == PTBluetoothState.poweredOn {
//
//        }else if ptDispatcher?.getBluetoothStatus() == PTBluetoothState.poweredOff {
//            self.mj_header.endRefreshing()
//            SVProgressHUD.showInfo(withStatus: "Please turn on Bluetooth".localized)
//        }else {
//            self.mj_header.endRefreshing()
//            SVProgressHUD.showInfo(withStatus: "Please go to system Settings to find your APP open bluetooth permissions".localized)
//        }
    }
    func isFetchPrinter() -> Bool{
        if (brandPrinter ?? .HPRT) == .EPSON{
            return !(mwEpsonBluetooth?.selectDevice?.target ?? "").isEmpty
        }else{
            return self.selectedPrinter != nil
        }
    }
   
   
    func setSelect(with mac:String){
        if (brandPrinter ?? .HPRT) == .EPSON{
            mwEpsonBluetooth?.setEpson(with: mac)
        }else{
            self.setHPRT(with: mac)
        }
    }
    func connectBle(success: @escaping () -> Void, failure: @escaping (String) -> Void, receiveData: @escaping (Data?) -> Void){
        if (brandPrinter ?? .HPRT) == .EPSON{
            mwEpsonBluetooth?.connectEpsonBle(success: success, failure: failure, receiveData: receiveData)
        }else{
            self.connectHPRTBle(success: success, failure: failure, receiveData: receiveData)
        }
       

    }
   
    func resetBLE(){
        if (brandPrinter ?? .HPRT) == .EPSON{
            mwEpsonBluetooth?.resetEpsonBLE()
        }else{
            self.resetHprtBLE()
        }
    }
    
    func getPrinterStatus(success: @escaping () -> Void, failure: @escaping (String) -> Void){
        if (brandPrinter ?? .HPRT) == .EPSON{
            mwEpsonBluetooth?.getPrinterStatus(success:success,failure:failure)
        }else{
            if self.isConnect ?? false {
                success()
            }else{
                failure("Connection BLE error")
            }
        }
    }
    
    func getFoundDevices() -> [restaurant_printer_class]{
        if (brandPrinter ?? .HPRT) == .EPSON{
            return mwEpsonBluetooth?.printerList.map({restaurant_printer_class.inilaize(from: $0)}) ?? []
        }else{
            return dataSources.map({restaurant_printer_class.intilize(from: $0)})

        }
    }
    func selectPrinterBrand() -> Any?{
        if (brandPrinter ?? .HPRT) == .EPSON{
           return self.mwEpsonBluetooth?.selectDevice
        }else{
            return self.selectedPrinter
        }
    }
}
 
extension MWPrinterBluetooth:MWPrinterSDKProtocol{
    func connect(with ip: String, success: @escaping () -> Void, failure: @escaping (String) -> Void, receiveData: @escaping (Data?) -> Void) {
        if let blePrinter = self.selectPrinterBrand() {
            if let blePrinter = blePrinter as? PTPrinter, blePrinter.mac != ip {
                failure("Printer not found")
                return
            }
            if let blePrinter = blePrinter as? Epos2DeviceInfo, blePrinter.target != ip {
                failure("Printer not found")
                return
            }
        }else{
            failure("Printer not selected")
            return

        }
        self.connectBle(success:success,
                        failure:failure,
                        receiveData:receiveData)
    }
    
    func statusPrinter(success: @escaping () -> Void, failure: @escaping (String) -> Void) {
        getPrinterStatus(success:success,failure:failure)

    }
    
    func handlerSendToPrinter(sendSuccess: @escaping () -> Void,
                              sendFailure: @escaping (String) -> Void,
                              sendProgressUpdate: ((Double?) -> Void)?,
                              receiveData: ((Data?) -> Void)?,
                              printSuccess: @escaping () -> Void) {
        if self.brandPrinter == .EPSON {
            self.mwEpsonBluetooth?.handlerSendToPrinter(sendSuccess: sendSuccess, sendFailure: sendFailure, sendProgressUpdate: sendProgressUpdate, receiveData: receiveData, printSuccess: printSuccess)
            return
        }else{
            initalizeCompeteSend(sendSuccess:sendSuccess,sendFailure:sendFailure,sendProgressUpdate:sendProgressUpdate,receiveData:receiveData,printSuccess:printSuccess)
        }

    }
    func startPrint(image: UIImage?,openDrawer:Bool, sendFailure: ((String) -> Void)?) {
        if self.brandPrinter == .EPSON {
            mwEpsonBluetooth?.startPrint(image: image, openDrawer: openDrawer)
            return
        }else{
            let PaperSize = [384,576,640,832,2360,3540][1]
            let imageMode = PTBitmapMode.binary
            let imagePressMode = PTBitmapCompressMode.none
            guard let temp = image else { return }
            guard let zybImage = PDResetImage.scaleImageForWidth(image: temp, width: CGFloat(PaperSize)) else { return }
            guard let cgImage = zybImage.cgImage else { return }
            var cmdData = Data()
            let cmd = PTCommandESC.init()
            cmd.initializePrinter()
            cmd.appendRasterImage(cgImage, mode: imageMode, compress: imagePressMode, package: false)
            cmd.setFullCutWithDistance(100)
            //open cashdrawer
            if openDrawer{ cmd.kickCashdrawer(0) }
            
            cmdData.append(cmd.getCommandData())
            competeHandlerPrinter(cmdData:cmdData)
        }

   }
    func disConnect() {
        ptDispatcher?.disconnect()
        mwEpsonBluetooth?.disscount()
    }
    func openDrawer(completeHandler: @escaping (Bool) -> Void){
        var cmdData = Data()
        let cmd = PTCommandESC.init()
        cmd.initializePrinter()
        cmd.kickCashdrawer(0)
        cmdData.append(cmd.getCommandData())
        competeHandlerPrinter(cmdData:cmdData)
        completeHandler(true)
    }
}
class MWEpsonBluetooth:NSObject, Epos2DiscoveryDelegate{
    private var printer:Epos2Printer?
    private var valuePrinterSeries: Epos2PrinterSeries?
    private var valuePrinterModel: Epos2ModelLang?
    private var imageReceipt:UIImage?
    private var openDeawer:Bool = false
    private var sendSuccess: ( () -> Void)?
    private var sendFailure: ((String) -> Void)?
    
    static let shared:MWEpsonBluetooth = MWEpsonBluetooth()
    fileprivate var printerList: [Epos2DeviceInfo] = []
    fileprivate var filterOption: Epos2FilterOption = Epos2FilterOption()
    //    var targetMac:String?
    var selectDevice:Epos2DeviceInfo?{
        didSet{
            if let selectDevice = selectDevice {
                if MWPrinterBluetooth.shared.isConnect ?? false{
                    self.printer?.disconnect()
                    MWPrinterBluetooth.shared.isConnect = false
                    self.sendFailure?("Bluetooth printer changed")
                }
                self.makeConnect(with:selectDevice.target)
            }
        }
    }
    func disscount(){
        self.printer?.clearCommandBuffer()
        self.printer?.disconnect()
        MWPrinterBluetooth.shared.isConnect = false
    }
    func handlerSendToPrinter(sendSuccess: @escaping () -> Void, sendFailure: @escaping (String) -> Void, sendProgressUpdate: ((Double?) -> Void)?, receiveData: ((Data?) -> Void)?, printSuccess: @escaping () -> Void) {
        self.sendSuccess = sendSuccess
        self.sendFailure = sendFailure

        sendReceipt()
    }
    func startPrint(image: UIImage?,openDrawer:Bool) {
        createReceiptData(imageData:image,openDeawer: openDrawer)
    }
        
    func findByEpson(with reset:Bool = false,mac_ssd:String? = nil){
        if  reset {
           self.stopScanEpson()
            self.printerList.removeAll()
            MWPrinterBluetooth.shared.state = .Populate
            
        }else{
            
        }
            let result = Epos2Discovery.start(self.filterOption, delegate: self)
        if result != EPOS2_SUCCESS.rawValue {
            //ShowMsg showErrorEpos(result, method: "start")
            MWPrinterBluetooth.shared.state = .Error("[Error-start] \(result)")
       }
            SharedManager.shared.printLog("start discoverty = result  == \(result) === ")

    }
    func stopScanEpson(){
        var result = EPOS2_SUCCESS.rawValue;
        
        while true {
            result = Epos2Discovery.stop()
            
            if result != EPOS2_ERR_PROCESSING.rawValue {
                if (result == EPOS2_SUCCESS.rawValue) {
                    break;
                }
                else {
                    MWPrinterBluetooth.shared.state = .Error("[Stop] \( result)")
                    return;
                }
            }
        }
    }
    func getEpson(for mac:String) -> Epos2DeviceInfo?{
        if  self.printerList.count > 0 {
            return  self.printerList.first(where: {$0.target == mac})
        }
        return nil
    }
    func setEpson(with mac:String){
        if (self.selectDevice?.target ?? "").isEmpty {
            if self.printerList.count > 0 {
                self.selectDevice = self.printerList.first(where: {$0.target == mac})
            }
            
        }
    }
    func resetEpsonBLE(){
        printer?.setReceiveEventDelegate(nil)
        printer?.setStatusChangeEventDelegate(nil)
        printer = nil
    }

    func onDiscovery(_ deviceInfo: Epos2DeviceInfo!) {
        SharedManager.shared.printLog("disscovery === \(deviceInfo.target)")
        printerList.append(deviceInfo)
        MWPrinterBluetooth.shared.state = .Populate
    }
    func connectEpsonBle(success: @escaping () -> Void, failure: @escaping (String) -> Void, receiveData: @escaping (Data?) -> Void){
        if let selectDevice = self.selectDevice{
            self.connectPrinter(with: selectDevice.target, success: success, failure: failure)
        }
    }
}
extension MWEpsonBluetooth {
    func initalize()  {
        filterOption.deviceType = EPOS2_TYPE_PRINTER.rawValue
        self.valuePrinterSeries = EPOS2_TM_M30III
        self.valuePrinterModel = EPOS2_MODEL_ANK
        printer = Epos2Printer(printerSeries: valuePrinterSeries?.rawValue ?? 6,
                               lang: valuePrinterModel?.rawValue ?? 0)
        printer?.setReceiveEventDelegate(self)
        printer?.setStatusChangeEventDelegate(self)
        printer?.startMonitor()
    }
    func makeConnect(with ble:String){
        var result: Int32 = EPOS2_SUCCESS.rawValue
        let timeOutConnection = SharedManager.shared.appSetting().connection_printer_time_out
        result = printer?.connect( ble, timeout:Int(timeOutConnection * 1000)) ?? EPOS2_ERR_FAILURE.rawValue
        if result == EPOS2_SUCCESS.rawValue{
            MWPrinterBluetooth.shared.isConnect = true
        }else{
            MWPrinterBluetooth.shared.isConnect = false
        }

    }
    func connectPrinter(with ip:String,success: @escaping () -> Void, failure: @escaping (String) -> Void){
//        if MWPrinterBluetooth.shared.isConnect  ?? false{
//            success()
//            return
//        }
        var result: Int32 = EPOS2_SUCCESS.rawValue
        let timeOutConnection = SharedManager.shared.appSetting().connection_printer_time_out
            /*
             other by string
             let btConnection = Epos2BluetoothConnection()
                let BDAddress = NSMutableString()
                let result = btConnection?.connectDevice(BDAddress)
                if result == EPOS2_SUCCESS.rawValue {
                    success()
//                    delegate?.discoveryView(self, onSelectPrinterTarget: BDAddress as String)
//                    delegate = nil
//                    self.navigationController?.popToRootViewController(animated: true)
                }
                else {
                    failure("Cannot connect bluetooth printer")
                    Epos2Discovery.start(filterOption, delegate:self)
//                    printerView.reloadData()
                }
        */
        result = printer?.connect( ip, timeout:Int(timeOutConnection * 1000)) ?? EPOS2_ERR_FAILURE.rawValue
        if result == EPOS2_SUCCESS.rawValue{
            MWPrinterBluetooth.shared.isConnect = true
            success()
        }else{
            MWPrinterBluetooth.shared.isConnect = false
            getPrinterStatus(success:success, failure: failure)

        }
       

    }

     func getPrinterStatus(success: @escaping () -> Void, failure: @escaping (String) -> Void) {
        if printer == nil {
            failure("EPSON Printer not found")
        }
//         if MWPrinterBluetooth.shared.isConnect ?? false{
//             success()
//             return
//         }
        let status: Epos2PrinterStatusInfo  = printer!.getStatus()
        if status.connection != EPOS2_FALSE
        {
            let result =  printer?.beginTransaction() ?? EPOS2_ERR_FAILURE.rawValue
            if result != EPOS2_SUCCESS.rawValue && result != EPOS2_ERR_ILLEGAL.rawValue {
                MWPrinterBluetooth.shared.isConnect = false

                failure(QUEUE_ENUM_ERROR.BEGIN_TRANSACTION.get_error_info())

            }else{
                MWPrinterBluetooth.shared.isConnect = true
                success()
            }
        }
        else
        {
            MWPrinterBluetooth.shared.isConnect = false

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
                              compress:EPOS2_COMPRESS_AUTO.rawValue) ?? EPOS2_ERR_FAILURE.rawValue
        
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
        result = printer!.addCut(EPOS2_CUT_FEED.rawValue)
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
extension MWEpsonBluetooth: Epos2PtrReceiveDelegate ,Epos2PtrStatusChangeDelegate{
  
    func onPtrStatusChange(_ printerObj: Epos2Printer!, eventType: Int32) {
//        disConnect()
        self.imageReceipt = nil
        self.openDeawer = false
        self.sendFailure = nil
        self.sendSuccess = nil
        printer?.endTransaction()
//        printer?.disconnect()
        stop_monitor()
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
