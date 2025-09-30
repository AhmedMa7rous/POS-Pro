//
//  DeviceMangmentVM.swift
//  pos
//
//  Created by M-Wageh on 04/06/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation
class DeviceMangmentVM {
    enum DevicesMangmentState{
        case EMPTY,RELOAD,LOADING,ERROR(String)
    }
    var avaliableDevices:[[String:Any]] = [[:]]
    var avaliableDevicesTypes:[DEVICES_TYPES_ENUM] = DEVICES_TYPES_ENUM.allCases
    var state: DevicesMangmentState = .EMPTY {
        didSet {
            self.updateLoadingStatusClosure?(state)
        }
    }
    var updateLoadingStatusClosure: ((DevicesMangmentState) -> Void)?
    let API:api?
    var isStaerTestConnection:Bool = false
    var setting: settingClass?
    var paymentDeviceProtocol:PaymentDeviceProtocol?
    init(devicesTypes:[DEVICES_TYPES_ENUM]) {
        API = api()
         
        if  devicesTypes.count > 0{
            avaliableDevicesTypes = devicesTypes
            
            devicesTypes.forEach { deviceType in
                if deviceType == .POS_PRINTER {
                    avaliableDevices.append(contentsOf: restaurant_printer_class.getAll())
                }else{
                    avaliableDevices.append(contentsOf: socket_device_class.getDevices(for:[deviceType]))
                }
            }
            // avaliableDevices.append(contentsOf: socket_device_class.getAll())
        }
        paymentDeviceProtocol = GeideaInteractor.shared 
    }
    func reloadFetch(){
        avaliableDevices.removeAll()
        avaliableDevices.append(contentsOf: restaurant_printer_class.getAll())
        avaliableDevices.append(contentsOf: socket_device_class.getAll())
        
        state = .RELOAD
    }
    func getSectionCount()->Int
    {
        return avaliableDevicesTypes.count
    }
    func getTitle(for section:Int)->String
    {
        return avaliableDevicesTypes[section].getLocalizeName() + " [\(getDeviceCount(for:section))]"
    }
    func getDeviceCount(for section:Int)->Int
    {
        return getDevices(for:section).count
    }
    func getDevice(at indexPath:IndexPath)->[String:Any]
    {
        return getDevices(for:indexPath.section)[indexPath.row]
    }
    func setPing(at indexPath:IndexPath,with pingStatus:PING_STATUS)
    {
        let dictionary_device = getDevice(at:indexPath)
        if let index = avaliableDevices.firstIndex(where: { dictionary in
          return ( dictionary["id"] as? Int ?? 0) == ( dictionary_device["id"] as? Int ?? 0)
        }) {
            avaliableDevices[index]["pingStatus"] = pingStatus.rawValue
            state = .RELOAD
        }
    }
    
    private func getDevices(for section:Int) -> [[String:Any]]{
        let type = DEVICES_TYPES_ENUM(rawValue: avaliableDevicesTypes[section].rawValue)
        return avaliableDevices.filter { avaliable_device in
            return DEVICES_TYPES_ENUM(rawValue:avaliable_device["type"] as? String ?? "") == type
        }
    }
    func hitDeletPrinterAPI(_ printer:restaurant_printer_class){
        if AppDelegate.shared.enable_debug_mode_code()
        {
            printer.delete()
            self.reloadFetch()
            return
        }
        API?.new_delete_restaurant_printer(printer: printer) { [self] result in
            state = .LOADING
//            if (result.success )
//            {
                printer.delete()
                self.reloadFetch()
                return
//            }
//            state = .ERROR(result.message ?? "please try again later".arabic("الرجاء معاودة المحاولة في وقت لاحق"))
        }
        
    }
    func deletDevice(_ socketDevice:socket_device_class){
        socketDevice.delete()
        self.reloadFetch()
    }
    func removeDeviceAction(_ socketDevice:socket_device_class){
        let IP =  setting?.ingenico_ip
        let NAME =  setting?.ingenico_name
        setting?.ingenico_ip = ""
        setting?.ingenico_name =  ""
        setting?.terminalID_geidea = ""
        setting?.port_geidea = 0
        setting?.save()
        account_journal_class.rest_is_support_geidea()
        let dataCheck = ["ingenicoIp":IP,"ingenicoName":NAME].jsonString()
        
        paymentDeviceProtocol?.addToLog( key: "RemoveDevice" + "(\(IP))" , prefix: "Remove", data: dataCheck)
        socketDevice.delete()
        self.reloadFetch()
    }
    func checkConnection(for ip:String){
        self.paymentDeviceProtocol?.setPort(with: 6100 )
        DispatchQueue.global(qos: .background).async {
            self.paymentDeviceProtocol?.checkConnection(with: ip)
        }
    }
}
extension DeviceMangmentVM:DevicesManagementProtocol{
    func testConnection(for printer:restaurant_printer_class){}
    func testGeideaConnection(for device_socket:socket_device_class){}
    func testPrinter(for printer:restaurant_printer_class){}
    func deletPrinter(for printer:restaurant_printer_class){}
    func deletSocketDevice(for device_socket:socket_device_class){}
    func deleteGeideaDevice(for device_socket: socket_device_class) {}
    func openLogPrinter(for printer:restaurant_printer_class){}
}

