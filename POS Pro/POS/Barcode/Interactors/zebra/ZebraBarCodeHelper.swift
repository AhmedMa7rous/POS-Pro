//
//  zebraBarCodeHelper.swift
//  pos
//
//  Created by M-Wageh on 15/03/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation
enum MWScannerBluetooth_SATE{
    case NONE,Loading,Populate,Selected(ScannerInfo),Error(String)
}
class ZebraBarCodeHelper: NSObject {
    /// The shared property is static, can access it from anywhere in code. This ensures global access
    static var shared: ZebraBarCodeHelper {
        let instance = ZebraBarCodeHelper()
        return instance
    }
    
    weak var sdkApiInstance : ISbtSdkApi?
    
    // Allocate an array to store the list of available scanners.
    var availableScanners: [SbtScannerInfo]?
    // Allocate an array to store the list of active scanners.
    var activeScanners: [SbtScannerInfo]?
    var connectedDevice: SbtScannerInfo?
    var availableScannerList:[ScannerInfo] = []
    /// Private initializer, to avoid initializing singleton class again.
    var delegate:BarcodeDeviceProtocol?
    var isConnected:Bool = false
    var stateZebra:MWScannerBluetooth_SATE?{
        didSet{
            self.updateLoadingStatusClosure?()
        }
    }
    var updateLoadingStatusClosure: (() -> Void)?

    private override init() {
        super.init()
        availableScanners = []
//        self.intializeCaptureHelper()
        sdkApiInstance = SbtSdkFactory.createSbtSdkApiInstance()
        
        //SBT_OPMODE_BTLE
//        sdkApiInstance?.sbtSetOperationalMode(Int32(SBT_OPMODE_BTLE))
        
                sdkApiInstance?.sbtSetOperationalMode(Int32(SBT_OPMODE_ALL))
        
        sdkApiInstance?.sbtSubsribe(forEvents: Int32(SBT_EVENT_SCANNER_APPEARANCE) |
                                    Int32(SBT_EVENT_SCANNER_DISAPPEARANCE) |
                                    Int32(SBT_EVENT_SESSION_ESTABLISHMENT) |
                                    Int32(SBT_EVENT_SESSION_TERMINATION) |
                                    Int32(SBT_EVENT_BARCODE) |
                                    Int32(SBT_EVENT_IMAGE) |
                                    Int32(SBT_EVENT_VIDEO))
        // enable/disable auto connect on app relaunch
//        sdkApiInstance?.sbtAutoConnectToLastConnectedScanner(onAppRelaunch: true)
        print("Zebra SDK version: \(getSDKVersion())")
        
        sdkApiInstance?.sbtSetDelegate(self)
        
        


        self.addZebraEventListener()
        
        
    }
    func deinitShared(){
        let idSave =  CashZebra.shared.getDeviceID()
        if idSave.isExist{
            self.disconnectScanner(idSave.valueInt)
        }

        sdkApiInstance?.sbtSetDelegate(nil)
        sdkApiInstance = nil
        activeScanners = nil
        connectedDevice = nil
//        delegate = nil
    }
    ///initialized sdk settings and subscribe for events
    func intializeCaptureHelper() {
        
        sdkApiInstance = SbtSdkFactory.createSbtSdkApiInstance()
        
        //SBT_OPMODE_BTLE
//        sdkApiInstance?.sbtSetOperationalMode(Int32(SBT_OPMODE_BTLE))
        
                sdkApiInstance?.sbtSetOperationalMode(Int32(SBT_OPMODE_ALL))
        
        sdkApiInstance?.sbtSubsribe(forEvents: Int32(SBT_EVENT_SCANNER_APPEARANCE) |
                                    Int32(SBT_EVENT_SCANNER_DISAPPEARANCE) |
                                    Int32(SBT_EVENT_SESSION_ESTABLISHMENT) |
                                    Int32(SBT_EVENT_SESSION_TERMINATION) |
                                    Int32(SBT_EVENT_BARCODE) |
                                    Int32(SBT_EVENT_IMAGE) |
                                    Int32(SBT_EVENT_VIDEO))
        // enable/disable auto connect on app relaunch
//        sdkApiInstance?.sbtAutoConnectToLastConnectedScanner(onAppRelaunch: true)
        
        
    }
    func startDiscoveryOrConnect(){
        let idSave = CashZebra.shared.getDeviceID()
        if !idSave.isExist {
            self.startDiscoveryOnly()
//            sdkApiInstance?.sbtAutoConnectToLastConnectedScanner(onAppRelaunch: true)
        }else{
//            self.connectByID()

        self.startDiscoveryOnly()
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300), execute: {
                self.connectToSaveDevice()
            })
    
        //sdkApiInstance?.sbtEstablishCommunicationSession(scanInfo.scannerId)
            
           
        }
    }
    func connectToSaveDevice(){
        if self.updateLoadingStatusClosure == nil{
            if let availableScanners = self.availableScanners{
                
                let idScanner = CashZebra.shared.getDeviceID()
                let scannerFind =  availableScanners.filter({$0.getScannerID() == idScanner.valueInt})
                if let foundScaner = scannerFind.first{
                    connectBySbtScannerInfo(foundScaner)
                }else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                        self.connectToSaveDevice()
                    })
                }
                
               
            }
        }
    }
    func connectBySbtScannerInfo(_ scanner:SbtScannerInfo){
        let stateDevice = CashZebra.shared.getZebraDeviceStatue()
        if stateDevice.connect {
                DispatchQueue.main.async {
                    let result: SBT_RESULT = self.sdkApiInstance?.sbtEstablishCommunicationSession(scanner.getScannerID()) ?? SBT_RESULT_FAILURE
                    if result == SBT_RESULT_FAILURE {
                        // stateZebra = .Error("Try again, Error Connection")
//                        SharedManager.shared.initalBannerNotification(title: "Connection!".arabic("الاتصال"), message: "Try again, Error Connection", success: false, icon_name: "icon_error")
//                        SharedManager.shared.banner?.dismissesOnTap = true
//                        SharedManager.shared.banner?.show()
                    }
                    self.stopDiscoveryOnly()
                }
                
        }
    }
    func startDiscoveryOnly(){
        // actively detect appearance/disappearance of scanners
        sdkApiInstance?.sbtEnableAvailableScannersDetection(true)
        // start Bluetooth discovery of scanners
        sdkApiInstance?.sbtEnableBluetoothScannerDiscovery(true)
    }
    func stopDiscoveryOnly(){
        sdkApiInstance?.sbtEnableBluetoothScannerDiscovery(false)
    }
    func stopScannerDiscovery() {
        let idSave = CashZebra.shared.getDeviceID()
        if !idSave.isExist{
            // Stop discovery and hide the loading indicator
            sdkApiInstance?.sbtEnableBluetoothScannerDiscovery(false)
//            sdkApiInstance?.sbtEnableAvailableScannersDetection(false)
        }else{
            disconnectScanner(idSave.valueInt)
        }

        }
   
    
    
    /// Get sdk version
    /// - Returns: The sdk version
    func getSDKVersion() -> String {
        
        return sdkApiInstance?.sbtGetVersion() ?? ""
        
    }
    ///ZebraEventReceiver
    func addZebraEventListener(){
        sdkApiInstance?.sbtSetDelegate(self)
        
    }
    
    func getSTCPairingBarcode(setDefaultsStatus: Bool , imageView : UIImageView) -> UIImage {
        
        return sdkApiInstance?.sbtGetPairingBarcode(BARCODE_TYPE_STC, withComProtocol: STC_SSI_BLE, withSetDefaultStatus: setDefaultsStatus ? SETDEFAULT_YES : SETDEFAULT_NO , withImageFrame: imageView.frame) ?? UIImage()
    }
    
    /// Disconnect the scanner
    ///  - Parameter scannerId : Id of the scanner
    func disconnectScanner(_ scannerID:Int32){
            sdkApiInstance?.sbtTerminateCommunicationSession(scannerID)
    }
    func lanuchAfterAdd(_ scannerID:Int32){
        // actively detect appearance/disappearance of scanners
        sdkApiInstance?.sbtEnableAvailableScannersDetection(true)
        // start Bluetooth discovery of scanners
        sdkApiInstance?.sbtEnableBluetoothScannerDiscovery(true)
//        sdkApiInstance?.sbtAutoConnectToLastConnectedScanner(onAppRelaunch: true)

        
        // Optionally, you can set a timeout if needed to stop discovery after some time
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [self] in
                   sdkApiInstance?.sbtEnableBluetoothScannerDiscovery(false)

               }

    }
    func connectToScanner_recu(_ scannerID:Int32) {
            // Establish connection with the new scanner
            let result: SBT_RESULT = sdkApiInstance?.sbtEstablishCommunicationSession(scannerID) ?? SBT_RESULT_FAILURE
            if result == SBT_RESULT_FAILURE {
                DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
                   // self.connectToScanner(scannerID)
                }
            }else{
                isConnected = true
            }
        
    }
    func popDelegate(){
        sdkApiInstance?.sbtSetDelegate(nil)

    }
    func getScannerInfo(availableScanner: SbtScannerInfo) -> ScannerInfo{
        let scannerInfo = ScannerInfo(
            scannerId: availableScanner.getScannerID(),
            connectionType: availableScanner.getConnectionType(),
            autoCommunicationSessionReestablishment: availableScanner.getAutoCommunicationSessionReestablishment(),
            active: availableScanner.isActive(),
            available: availableScanner.isAvailable(),
            isStcConnected: availableScanner.isStcConnected(),
            scannerName: availableScanner.getScannerName(),
            scannerModel: availableScanner.getScannerModel())
        return scannerInfo
    }
    func addScannerToAvailableList(scanner: ScannerInfo) {
        if (!self.availableScannerList.contains(scanner)) {
            self.availableScannerList.append(scanner)
        }
    }
    func saveDevice(for selectDevice: SbtScannerInfo? ){
        let idSave =  CashZebra.shared.getDeviceID()

        if let deviceID = selectDevice?.getScannerID(),idSave.isExist {
            if idSave.valueInt == deviceID {
                return
            }
        }
        if let selectDevice = selectDevice {
            self.connectedDevice = selectDevice
        }
        if let deviceName = selectDevice?.getScannerName(),let deviceID = selectDevice?.getScannerID(){
            cashDevice(deviceName:deviceName,deviceID:"\(deviceID)",stop:"0")

        }
    }
    func saveDevice(for selectDevice: ScannerInfo? ){
        let idSave =  CashZebra.shared.getDeviceID()

        if let deviceID = selectDevice?.scannerId,idSave.isExist {
            if idSave.valueInt == deviceID {
                return
            }
        }
        if let deviceName = selectDevice?.scannerName,let deviceID = selectDevice?.scannerId{
            cashDevice(deviceName:deviceName,deviceID:"\(deviceID)",stop:"0")

        }
    }
    func cashDevice(deviceName:String,deviceID:String,stop:String){
        cash_data_class.set(key: "barcode_device_zebra", value: "\(deviceName)" )
        cash_data_class.set(key: "barcode_device_id", value:deviceID  )
        cash_data_class.set(key: "barcode_device_type", value: "ZebraBarCode" )
        cash_data_class.set(key: "barcode_device_stop", value: stop )
    }
   
    func saveAndCEstablish(scanInfo:ScannerInfo){
        let scannerID = scanInfo.scannerId
//        sdkApiInstance?.sbtEstablishCommunicationSession(scanInfo.scannerId)
        let result: SBT_RESULT = sdkApiInstance?.sbtEstablishCommunicationSession(scannerID) ?? SBT_RESULT_FAILURE
        if result == SBT_RESULT_FAILURE {
            stateZebra = .Error("Try again, Error Connection")
        }else{
            stateZebra = .Selected(scanInfo)

        }

    }
}
// Definition of a class that implements the SbtSdkApiDelegate protocol
extension ZebraBarCodeHelper:  ISbtSdkApiDelegate {
    // TODO: variables

    
    func sbtEventScannerAppeared(_ availableScanner: SbtScannerInfo!) {
        //This event occurs when the presence of a scanner appears.
        guard let availableScanner = availableScanner else{
            print("No barcode data received.")
            return}
        print("sbtEventScannerAppeared === ",availableScanner)
//        sdkApiInstance?.sbtEstablishCommunicationSession(availableScanner.getScannerID())
        if self.updateLoadingStatusClosure == nil {
            self.connectedDevice = availableScanner
            self.connectToSaveDevice()
        }
        self.availableScanners?.append(availableScanner)
        self.availableScannerList.append(getScannerInfo(availableScanner:availableScanner ))
        stateZebra = .Populate
        

    }
    
    func sbtEventScannerDisappeared(_ scannerID: Int32) {
        //This event occurs when a scanner is no longer present.
        print("sbtEventScannerDisappeared === ",scannerID)
        self.availableScannerList.removeAll { scannerInfo in
            return scannerInfo.scannerId == scannerID
        }
        stateZebra = .Populate

    }
    
    func sbtEventCommunicationSessionEstablished(_ activeScanner: SbtScannerInfo!) {
        //This event occurs when communication is established with a scanner.
        print("sbtEventCommunicationSessionEstablished === ",activeScanner)

    }
    
    func sbtEventCommunicationSessionTerminated(_ scannerID: Int32) {
        //This event occurs when communication with a scanner is terminated.
        print("sbtEventCommunicationSessionTerminated === ",scannerID)


    }
    
    func sbtEventBarcode(_ barcodeData: String?, barcodeType: Int32, fromScanner scannerID: Int32) {
        guard let barcodeData = barcodeData else{
            print("No barcode data received.")
            return}
        print("sbtEventBarcode === ",barcodeData)

    }
    
    func sbtEventBarcodeData(_ barcodeData: Data?, barcodeType: Int32, fromScanner scannerID: Int32) {
        //This event occurs when barcode data is read and received.
        guard let barcodeData = barcodeData else{
            print("No barcode data received.")

            return}
        print("sbtEventBarcodeData === ",barcodeData)
        if let string = String(data: barcodeData, encoding: .utf8) {
            print("Converted string: \(string)")
            delegate?.didReceiveDecodedData(nil,nil, string)

        } else {
            print("Failed to convert data to string.")
        }
        

    }
    
    func sbtEventFirmwareUpdate(_ fwUpdateEventObj: FirmwareUpdateEvent!) {
        //This event occurs when firmware update is in progress. You don't need to specifically subscribe to this event. You just have to implement this delegate method.
        print("sbtEventFirmwareUpdate === " )


    }
    
}
extension ZebraBarCodeHelper {
    
}

struct ScannerInfo : Hashable{
    
    var scannerId: Int32
    var connectionType: Int32
    var autoCommunicationSessionReestablishment: Bool
    var active: Bool
    var available: Bool
    var isStcConnected: Bool
    var scannerName: String
    var scannerModel: String
    var serialNo: String?
    var firmware: String?
    var dateOfManufacture: String?
    var configurationFileName: String?
    
    /// Method to get the display text for the connection type
    func getConnectionType() -> String {
        var connectionTypeText = "";
        switch (self.connectionType) {
        case Int32(SBT_CONNTYPE_MFI):
            connectionTypeText = "MFi"
            break;
        case Int32(SBT_CONNTYPE_BTLE):
            connectionTypeText = "BT LE"
            break;
        default:
            connectionTypeText = "Unknown"
        }
        return connectionTypeText
    }
}
class CashZebra{
    static let shared:CashZebra = CashZebra()
    private init(){}
    func getZebraDeviceName() -> (Bool,String){
       let name = (cash_data_class.get(key: "barcode_device_zebra" ) ) ?? ""
        return (name.isEmpty , name)
    }
    func getZebraDeviceStatue() -> (connect:Bool,stop:Bool){
       let stop = (cash_data_class.get(key: "barcode_device_stop" ) ) ?? ""
        return ((stop == "0"),(stop == "1"))
    }
    func getDeviceID() -> (vauleString:String,valueInt:Int32,isExist:Bool){
        if  let idSave =  cash_data_class.get(key: "barcode_device_id") {
            if let idInt = Int32(idSave){
                return (idSave,idInt,true)
            }
        }
        return ("",0,false)

    }
}
