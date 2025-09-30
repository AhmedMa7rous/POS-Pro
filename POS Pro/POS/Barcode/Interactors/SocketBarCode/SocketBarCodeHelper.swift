//
//  SocketBarCodeHelper.swift
//  pos
//
//  Created by M-Wageh on 15/03/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation
import SKTCapture

class SocketBarCodeHelper {
    var scannersDevices:[CaptureHelperDevice] = []
    var captureHelper = CaptureHelper.sharedInstance
    var deviceManager: CaptureHelperDeviceManager?
    var softscanIsON:Bool = false
    var captureVersion:String = ""
    var isNFCSupport:Bool = false
    var connectedDevice: CaptureHelperDevice?
    var delegate:BarcodeDeviceProtocol?
    static let shared:SocketBarCodeHelper = SocketBarCodeHelper()
    private init(){}
    func intializeCaptureHelper(){
        pushDelegate()
        captureHelper.dispatchQueue = DispatchQueue.main
        // open Capture Helper only once in the application
        captureHelper.openWithAppInfo(getSKTAppInfo(), withCompletionHandler: { (_ result: SKTResult) in
           SharedManager.shared.printLog("Result of Capture initialization: \(result.rawValue)")
        #if HOST_ACKNOWLEDGMENT
            captureHelper.setConfirmationMode(confirmationMode: .modeApp, withCompletionHandler: { (result) in
               SharedManager.shared.printLog("Data Confirmation Mode returns : \(result.rawValue)")
            })
            // to remove the Host Acknowledgment if it was set before
            // put back to the default Scanner Acknowledgment also called Local Acknowledgment
        #else
            self.captureHelper.setConfirmationMode(.modeDevice, withCompletionHandler: { (result) in
               SharedManager.shared.printLog("Data Confirmation Mode returns : \(result.rawValue)")
            })
        #endif
            
            
        })
        
        
    }
    private func getSKTAppInfo() -> SKTAppInfo {
        let appInfo = SKTAppInfo();
        appInfo.developerID = "e546e129-75a4-ec11-b3fe-000d3a308d89"
        appInfo.appID = "ios:com.dgtera.pos.pro"
        appInfo.appKey = "MC0CFQCFVIsujFDSJ+F/yDDR6wTy3fsG0AIUXF/lWmpso42CosJ8yBMLDuIu+nA="
        return appInfo
    }
    func pushDelegate(){
        captureHelper.pushDelegate(self)
    }
    func popDelegate(){
        captureHelper.popDelegate(self)
    }
    func getSoftScanStatusWithCompletionHandler(){
        captureHelper.getSoftScanStatusWithCompletionHandler( {(result, softScanStatus) in
           SharedManager.shared.printLog("getSoftScanStatusWithCompletionHandler received!")
           SharedManager.shared.printLog("Result:\(result.rawValue)")
            if result == SKTCaptureErrors.E_NOERROR {
                let status = softScanStatus
               SharedManager.shared.printLog("receive SoftScan status:\(status ?? .disable)")
                if status == .enable {
                    self.softscanIsON = true
                } else {
                    self.softscanIsON = false
                    if status == .notSupported {
                        self.setSoftScanStatus(with: status ?? .disable)
                    }
                }
            }
        })
    }
    //Mark:- ask for the Capture version
    func getVersionWithCompletionHandler(){
        captureHelper.getVersionWithCompletionHandler({ (result, version) in
           SharedManager.shared.printLog("getCaptureVersion completion received!")
           SharedManager.shared.printLog("Result:\(result.rawValue)")
            if result == SKTCaptureErrors.E_NOERROR {
                let major = String(format:"%d",(version?.major)!)
                let middle = String(format:"%d",(version?.middle)!)
                let minor = String(format:"%d",(version?.minor)!)
                let build = String(format:"%d",(version?.build)!)
               SharedManager.shared.printLog("receive Capture version: \(major).\(middle).\(minor).\(build)")
                self.captureVersion = "Capture Version: \(major).\(middle).\(minor).\(build)"
            }
        })
    }
    func checkTheNFCsupport(){
        if let dm = deviceManager {
            dm.getFavoriteDevicesWithCompletionHandler({ (result, favorites) in
               SharedManager.shared.printLog("getting the Device Manager favorites returns \(result.rawValue)")
                if result == SKTCaptureErrors.E_NOERROR {
                    if let fav = favorites {
                        self.isNFCSupport = !fav.isEmpty
                    }
                }
            })
        }
    }
    //MARK:-setSoftScanStatus
    func setSoftScanStatus(with status: SKTCaptureSoftScan){
        captureHelper.setSoftScanStatus(status, withCompletionHandler: { (result) in
           SharedManager.shared.printLog("enabling softScan returned \(result.rawValue)")
        })
    }
    //MARK:-changeNFCSupport
    func changeNFCSupport(){
        let deviceManagers = captureHelper.getDeviceManagers()
        for d in deviceManagers {
            deviceManager = d
        }
        
        if let _ = deviceManager {
            if !isNFCSupport{
               SharedManager.shared.printLog("turn off the NFC support...")
                setFavoriteDevices(with :"")
            }
            else {
               SharedManager.shared.printLog("turn on the NFC support...")
                setFavoriteDevices(with :"*")
            }
        }else{
            isNFCSupport = false
        }
    }
    //MARK:-setFavoriteDevices
    func setFavoriteDevices(with value:String){
        if let dm = deviceManager {
            dm.setFavoriteDevices(value, withCompletionHandler: { (result) in
               SharedManager.shared.printLog("turning off NFC support returns \(result.rawValue)")
            })
        }
    }
}
// MARK: - Helper functions

extension SocketBarCodeHelper: CaptureHelperDevicePresenceDelegate,
                               CaptureHelperDeviceManagerPresenceDelegate,
                               CaptureHelperDeviceDecodedDataDelegate,
                               CaptureHelperErrorDelegate,
                               CaptureHelperDevicePowerDelegate{
    func displayBatteryLevel(_ level: UInt?, fromDevice device: CaptureHelperDevice, withResult result: SKTResult) {
        if result != .E_NOERROR {
           SharedManager.shared.printLog("error while getting the device battery level: \(result.rawValue)")
        }
        else{
            let battery = SKTHelper.getCurrentLevel(fromBatteryLevel: Int(level!))
           SharedManager.shared.printLog("the device \((device.deviceInfo.name)! as String) has a battery level: \(String(describing: battery))%")
        }
    }
    
    // MARK: - CaptureHelperDevicePresenceDelegate
    
    func didNotifyArrivalForDevice(_ device: CaptureHelperDevice, withResult result: SKTResult) {
        let deviceName = String(describing: device.deviceInfo.name)
        scannersDevices.append(device)
       SharedManager.shared.printLog("Main view device arrival:\(deviceName)")
        
        // These few lines are only for the Host Acknowledgment feature,
        // if your application does not use this feature they can be removed
        // from the #if to the #endif
        
        device.getNotificationsWithCompletionHandler { (result :SKTResult, notifications:SKTCaptureNotifications?) in
            if result == .E_NOERROR {
                var notif = notifications!
                if !notif.contains(SKTCaptureNotifications.batteryLevelChange) {
                   SharedManager.shared.printLog("scanner not configured for battery level change notification, doing it now...")
                    notif.insert(SKTCaptureNotifications.batteryLevelChange)
                    device.setNotifications(notif, withCompletionHandler: {(result)->Void in
                        if result != .E_NOERROR {
                           SharedManager.shared.printLog("error while setting the device notifications configuration \(result.rawValue)")
                        } else {
                            device.getBatteryLevelWithCompletionHandler({ (result, batteryLevel) in
                                self.displayBatteryLevel(batteryLevel, fromDevice: device, withResult: result)
                            })
                        }
                    })
                    
                } else {
                   SharedManager.shared.printLog("scanner already configured for battery level change notification")
                    device.getBatteryLevelWithCompletionHandler({ (result, batteryLevel)->Void in
                        self.displayBatteryLevel(batteryLevel, fromDevice: device, withResult: result)
                    })
                }
            } else {
                if result == .E_NOTSUPPORTED {
                   SharedManager.shared.printLog("scanner \(String(describing: device.deviceInfo.name)) does not support reading for notifications configuration")
                } else {
                   SharedManager.shared.printLog("scanner \(String(describing: device.deviceInfo.name)) return an error \(result) when reading for notifications configuration")
                }
            }
        }
    }
    
    func didNotifyRemovalForDevice(_ device: CaptureHelperDevice, withResult result: SKTResult) {
       SharedManager.shared.printLog("Main view device removal:\(device.deviceInfo.name!)")
       SharedManager.shared.printLog("didNotifyRemovalForDevice in the detail view")
        var newScanners : [CaptureHelperDevice] = []
        for scanner in scannersDevices{
            if((scanner.deviceInfo.name ?? "") != device.deviceInfo.name){
                newScanners.append(scanner)
            }
        }
        // if the scanner that is removed is SoftScan then
        // we nil its reference
        //        if softScanner != nil {
        //            if softScanner == device {
        //                softScanner = nil
        //            }
        //        }
        scannersDevices = newScanners
    }
    
    // MARK: - CaptureHelperDeviceManagerPresenceDelegate
    // THIS IS THE PLACE TO TURN ON THE BLE FEATURE SO THE NFC READER CAN
    // BE DISCOVERED AND CONNECT TO THIS APP
    func didNotifyArrivalForDeviceManager(_ device: CaptureHelperDeviceManager, withResult result: SKTResult) {
       SharedManager.shared.printLog("device manager arrival notification")
        //        scannersDevices.append(device)
        // this device property completion block might update UI
        // element, then we set its dispatchQueue here to this app
        // main thread
        if  deviceManager == nil{
            deviceManager = device
        }
        
        deviceManager?.dispatchQueue = DispatchQueue.main
        deviceManager?.getFavoriteDevicesWithCompletionHandler { (result, favorites) in
           SharedManager.shared.printLog("getting the favorite devices returned \(result.rawValue)")
            if result == .E_NOERROR {
                if let fav = favorites {
                    // if favorites is empty (meaning NFC reader auto-discovery is off)
                    // then set it to "*" to connect to any NFC reader in the vicinity
                    // To turn off the BLE auto reconnection, set the favorites to
                    // an empty string
                    if fav.isEmpty {
                        device.setFavoriteDevices("*", withCompletionHandler: { (result) in
                           SharedManager.shared.printLog("setting new favorites returned \(result.rawValue)")
                        })
                    }
                }
            }
        }
    }
    
    func didNotifyRemovalForDeviceManager(_ device: CaptureHelperDeviceManager, withResult result: SKTResult) {
       SharedManager.shared.printLog("device manager removal notifcation")
        deviceManager = nil
       SharedManager.shared.printLog("Main view device removal:\(device.deviceInfo.name!)")
        //       SharedManager.shared.printLog("didNotifyRemovalForDevice in the detail view")
        //        var newScanners : [CaptureHelperDevice] = []
        //        for scanner in scannersDevices{
        //            if((scanner.deviceInfo.name ?? "") != device.deviceInfo.name){
        //                newScanners.append(scanner)
        //            }
        //        }
        //        // if the scanner that is removed is SoftScan then
        //        // we nil its reference
        ////        if softScanner != nil {
        ////            if softScanner == device {
        ////                softScanner = nil
        ////            }
        ////        }
        //        scannersDevices = newScanners
        
    }
    // MARK: - CaptureHelperDeviceDecodedDataDelegate
    
    // This delegate is called each time a decoded data is read from the scanner
    // It has a result field that should be checked before using the decoded
    // data.
    // It would be set to SKTCaptureErrors.E_CANCEL if the user taps on the
    // cancel button in the SoftScan View Finder
    func didReceiveDecodedData(_ decodedData: SKTCaptureDecodedData?, fromDevice device: CaptureHelperDevice, withResult result: SKTResult) {
        
        if result == .E_NOERROR {
            let rawData = decodedData?.decodedData
            let rawDataSize = rawData?.count
            let size = String(describing: rawDataSize)
            let data = String(describing: decodedData?.decodedData)
            
           SharedManager.shared.printLog("Size: \(String(describing: rawDataSize))")
           SharedManager.shared.printLog("data: \(String(describing: decodedData?.decodedData))")
            let string = decodedData?.stringFromDecodedData()!
           SharedManager.shared.printLog("Decoded Data \(String(describing: string))")
            
            delegate?.didReceiveDecodedData(size, data, string)
            // this code can be removed if the application is not interested by
            // the host Acknowledgment for the decoded data
            #if HOST_ACKNOWLEDGMENT
            device.setDataConfirmationWithLed(SKTCaptureDataConfirmationLed.green, withBeep:SKTCaptureDataConfirmationBeep.good, withRumble: SKTCaptureDataConfirmationRumble.good, withCompletionHandler: {(result) in
                if result != .E_NOERROR {
                   SharedManager.shared.printLog("error trying to confirm the decoded data: \(result.rawValue)")
                }
            })
            #endif
            
        }
    }
    
    // MARK: - CaptureHelperErrorDelegate
    
    func didReceiveError(_ error: SKTResult) {
       SharedManager.shared.printLog("Receive a Capture error: \(error.rawValue)")
    }
    
    // MARK: - CaptureHelperDevicePowerDelegate
    
    func didChangePowerState(_ powerState: SKTCapturePowerState, forDevice device: CaptureHelperDevice) {
       SharedManager.shared.printLog("Receive a didChangePowerState \(powerState)")
    }
    
    func didChangeBatteryLevel(_ batteryLevel: Int, forDevice device: CaptureHelperDevice) {
       SharedManager.shared.printLog("Receive a didChangeBatteryLevel \(batteryLevel)")
    }
    
    
}

