//
//  BarcodeDeviceInteractor.swift
//  pos
//
//  Created by M-Wageh on 15/03/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation
protocol BarcodeDeviceProtocol{
    func didReceiveDecodedData(_ size:String?,_ data: String?,_ stringData:String?)

}
class ZebraBarcodeDeviceInteractor:BarcodeDeviceProtocol {
    static let shared:ZebraBarcodeDeviceInteractor = ZebraBarcodeDeviceInteractor()
    var zebraBarCodeHelper = ZebraBarCodeHelper.shared
    var selectIndex:IndexPath?
    var didReceiveDecodedDataCompletation:((_ d1BarCodeModel:D1BarCodeModel?)->())?

     private init(){
//        deviceInfo = DeviceInfoModel()
        DispatchQueue.main.async {
//            self.initalize()
            self.zebraBarCodeHelper.intializeCaptureHelper()
            self.zebraBarCodeHelper.addZebraEventListener()
            self.zebraBarCodeHelper.delegate = self

        }
    }
    func stopScannerDiscovery(){
        self.zebraBarCodeHelper.stopScannerDiscovery()
    }
    func startDiscoveryOrConnect(){
        self.zebraBarCodeHelper.startDiscoveryOrConnect()

//        zebraBarCodeHelper.intializeCaptureHelper()
//        zebraBarCodeHelper.addZebraEventListener()
//        zebraBarCodeHelper.delegate = self
//        initalizeDeviceIfConnect()
//        zebraBarCodeHelper.getAvailableActiveScanners()
    }
   
    func didReceiveDecodedData(_ size:String?,_ data: String?,_ stringData:String?){
         guard let stringData = stringData else {return}
        self.didReceiveDecodedDataCompletation?(D1BarCodeModel(D1barcode: stringData))
    }

   
    
    
   
   
    
   
    deinit{
        zebraBarCodeHelper.popDelegate()
    }

}

class BarcodeDeviceInteractor:BarcodeDeviceProtocol {
    static let shared:BarcodeDeviceInteractor = BarcodeDeviceInteractor()
    var deviceInfo:DeviceInfoModel?
    let socketBarCodeHelper = SocketBarCodeHelper.shared
    weak var bluetoothHelper:BluetoothHelper?
    var selectIndex:IndexPath?
    var didReceiveDecodedDataCompletation:((_ d1BarCodeModel:D1BarCodeModel?)->())?

    private init(){
//        deviceInfo = DeviceInfoModel()
        DispatchQueue.main.async {
            self.initalize()
        }
    }
    func initalize(){
        socketBarCodeHelper.intializeCaptureHelper()
        socketBarCodeHelper.delegate = self
        initalizeDeviceIfConnect()
        bluetoothHelper = BluetoothHelper.shared
        bluetoothHelper?.initlize()
    }
    func removeDevice(){
        if let nameDevice = cash_data_class.get(key: "barcode_device_name" ), !nameDevice.isEmpty{
            for (index,device) in socketBarCodeHelper.captureHelper.getDevices().enumerated(){
                if (device.deviceInfo.name ?? "").contains(nameDevice){
                    cash_data_class.set(key: "barcode_device_name", value: "" )
                    cash_data_class.set(key: "barcode_device_type", value: "" )
                    deviceInfo = nil
                }
            }
            
        }

    }
    
    func initalizeDeviceIfConnect(){
        if let nameDevice = cash_data_class.get(key: "barcode_device_name" ), !nameDevice.isEmpty{
            for device in socketBarCodeHelper.captureHelper.getDevices(){
                if (device.deviceInfo.name ?? "").contains(nameDevice){
                    socketBarCodeHelper.connectedDevice = device
                    self.initalDeviceInfo()
                }
            }
        }
    }
    func didReceiveDecodedData(_ size:String?,_ data: String?,_ stringData:String?){
         guard let stringData = stringData else {return}
        self.didReceiveDecodedDataCompletation?(D1BarCodeModel(D1barcode: stringData))
    }

    func isBleDeviceConntect()->Bool{
        return deviceInfo != nil
    }
    func getCountInfoRows()->Int{
        if let dic = deviceInfo?.dic{
            return dic.count
        }
        return deviceInfo?.toDictionary().count ?? 0
    }
    func getInfo(at index:Int)->[String:String]?{
        //TODO:- get devices info
        if let dic = deviceInfo?.dic{
            return dic[index]
        }
        return deviceInfo?.toDictionary()[index]
    }
    
    func getStepsSetup() -> [StepSetupModel]{
        let setupSteps = [
            StepSetupModel(title: "Turn on barcode Scanner", subtitle: "Make sure that Bluetooth is turned on \n Press and hold power button until the scanner comes on. \n LED light will start blinking and low high tones will sound", icon: "socket-mobile-device", btntitle: "Next...", type: .image),
           
            StepSetupModel(title: "Turn on pairing mode", subtitle: "Please, scan the following barcode to configure your scanner in Application mode \n After scanning you will hear confirmation tones",icon: "MFI-socket-barcode" ,btntitle: "Next...", type: .image),

            StepSetupModel(title: "Pair barcode scanner", subtitle: "Select your barcode scanner from avaliable devices \n Device may take a secands to appear ", icon: "", btntitle: "Next..", type: .table),

            
            StepSetupModel(title: "Barcode scanner setup complete", subtitle: "", icon: "", btntitle: "Done", type: .none),

        ]
        return setupSteps
    }
    func getCountDiscoverDevices() -> Int{
        return bluetoothHelper?.getDevicesCount() ?? 0
    }
    func getDeviceNameFor(_ index:IndexPath)->String{
        return bluetoothHelper?.getName(at: index) ?? "Socket Mobile"
    }
    func didSelectDeviceAt(index:IndexPath){
        selectIndex = index
        bluetoothHelper?.BLEConnect(with: index)
    }
    func saveDeviceConnect(){
        guard let  index = selectIndex else {return}
        let selectDevice = socketBarCodeHelper.scannersDevices[index.row]
        socketBarCodeHelper.connectedDevice = selectDevice
        let info = selectDevice.deviceInfo
        cash_data_class.set(key: "barcode_device_zebra", value: info.name ?? "" )
        cash_data_class.set(key: "barcode_device_type", value: "socketBarCode" )
        initalDeviceInfo()
    }
    
    func initalDeviceInfo(){
        if let info = socketBarCodeHelper.connectedDevice?.deviceInfo{
        var dic:[[String:String]] = [[:]]
        dic.append(["Name":info.name ?? ""])
        dic.append(["Guid":info.guid ?? ""])
        dic.append(["Device Type":"\(info.deviceType)"])

        deviceInfo = DeviceInfoModel()
        deviceInfo?.dic = dic
        }
    }
    deinit{
        socketBarCodeHelper.popDelegate()
    }

}
