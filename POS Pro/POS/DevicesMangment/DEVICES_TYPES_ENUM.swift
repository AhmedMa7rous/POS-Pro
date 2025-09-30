//
//  DEVICES_TYPES_ENUM.swift
//  pos
//
//  Created by M-Wageh on 22/08/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation
enum DEVICES_TYPES_ENUM:String,CaseIterable{
    case POS_PRINTER = "POS Printer"
    case KDS_PRINTER = "KDS Printer"

    case SUB_CASHER = "sub_casher"
    case KDS = "Kitchen"
    case WAITER = "Waiter"
    case CDS = "CDS"
    case NOTIFIER = "Notifier"
    case PAYMENT = "Payment"
    case MASTER = "master"
    case GEIDEA = "Geidea"

    func valueForSql()->String{
        return "'\(self.rawValue)'"
    }
    
    func valueForAPI()->String{
        if self == .KDS_PRINTER {
            return "kds"
        }else  if self == .POS_PRINTER {
            return "pos"
        }else{
            return self.rawValue
        }
    }
    static func getTypesNotPrinters() -> [DEVICES_TYPES_ENUM] {
        return [DEVICES_TYPES_ENUM.KDS,
                DEVICES_TYPES_ENUM.WAITER,
                DEVICES_TYPES_ENUM.SUB_CASHER,
                DEVICES_TYPES_ENUM.CDS,
                DEVICES_TYPES_ENUM.MASTER,
                DEVICES_TYPES_ENUM.NOTIFIER,
                DEVICES_TYPES_ENUM.GEIDEA]
    }
    static func getAll() -> [DEVICES_TYPES_ENUM]{
        return DEVICES_TYPES_ENUM.allCases
    }
    static func getAllPrinterTypesString()->[String]{
        return [DEVICES_TYPES_ENUM.POS_PRINTER.getLocalizeName(),DEVICES_TYPES_ENUM.KDS_PRINTER.getLocalizeName() ]
    }
    static func getTypeFrom(value:String)->DEVICES_TYPES_ENUM {
        if value == "POS Printer" {
            return .POS_PRINTER
        }
        if value == "KDS Printer" {
            return .KDS_PRINTER
        }
        if value == "Waiter device" {
            return .WAITER
        }
        if value == "sub casher device" {
            return .SUB_CASHER
        }
        if value == "Kitchen device" {
            return .KDS
        }
        if value == "CDS device" {
            return .CDS
        }
        if value == "Notifier device" {
            return .NOTIFIER
        }
        if value == "Payment device" {
            return .PAYMENT
        }
        if value == "Master device"  {
            return .MASTER
        }
        if value == "Geidea device"  {
            return .GEIDEA
        }
        return DEVICES_TYPES_ENUM.POS_PRINTER
    }
    func getLocalizeName()->String{
        switch self {
        case .POS_PRINTER : return "POS Printer"
        case .KDS_PRINTER : return  "KDS Printer"
        case .SUB_CASHER : return  "sub casher device"
        case .KDS : return  "Kitchen device"
        case .CDS : return  "CDS device"
        case .NOTIFIER : return  "Notifier device"
        case .PAYMENT : return  "Payment device"
        case .WAITER : return  "Waiter device"
        case .MASTER : return  "Master device"
        case .GEIDEA : return "Geidea device"
        }
    }
    
    func getTypeName2()->String{
        return self.rawValue
    }
    
    func getDeviceFactor(printer:restaurant_printer_class? = nil,
                         socketDevice:socket_device_class? = nil) -> AddDevicesFactorProtocol{
        switch self {
        case .POS_PRINTER:
            return POSPrinterDevice(resturantPrinter: printer,type: DEVICES_TYPES_ENUM.POS_PRINTER)
        case .KDS_PRINTER:
            return POSPrinterDevice(resturantPrinter: printer, type: DEVICES_TYPES_ENUM.KDS_PRINTER)
        case .SUB_CASHER:
            return SubCashierDevice(socketDeviceModel: socketDevice)
        case .KDS:
            return KDSDevice(socketDeviceModel: socketDevice)
        case .CDS:
            return CDSDevice(socketDeviceModel: socketDevice)
        case .NOTIFIER:
            return NotifierDevice(socketDeviceModel: socketDevice)
        case .PAYMENT:
            return EmptyFactoryDevice()
        case .WAITER:
            return WaiterDevice(socketDeviceModel: socketDevice)
        case .MASTER:
            return EmptyFactoryDevice()
        case .GEIDEA :
            return  GeideaDevice(socketDeviceModel: socketDevice)
        }
    }
    func getIpConnectionTag()->Int{
        switch self {
        case .POS_PRINTER : return 0
        case .KDS_PRINTER : return  1
        case .SUB_CASHER : return  2
        case .KDS : return  3
        case .CDS : return  4
        case .NOTIFIER : return  5
        case .PAYMENT : return  6
        case .WAITER : return  7
        case .MASTER : return  8
        case .GEIDEA : return 9
        }
    }
    static func currentDevicType() -> DEVICES_TYPES_ENUM{
        let typePos = SharedManager.shared.posConfig().pos_type ?? ""
//        SharedManager.shared.printLog("typePos == \(typePos)")
        let isWaiter = typePos.lowercased().contains("waiter")
       if isWaiter {
           return .WAITER
        }
            return .MASTER
    }
    
    func canAcces() -> Bool {
        var canAaccess = true
        if [DEVICES_TYPES_ENUM.POS_PRINTER,DEVICES_TYPES_ENUM.KDS_PRINTER].contains(self){
            canAaccess =  SharedManager.shared.activeUser().canAccess(for: .printers_managment)
            if !canAaccess{
                SharedManager.shared.initalBannerNotification(title:  "Not Allowed".arabic("غير مسموح"), message: "You don't have a permission for this".arabic("ليس لديك إذن بهذا"), success: false, icon_name: "icon_error")
                SharedManager.shared.banner?.dismissesOnTap = true
                SharedManager.shared.banner?.show(duration: 3)
            }
        }
        return canAaccess
        
        
    }

}
