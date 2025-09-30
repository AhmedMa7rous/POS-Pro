//
//  printer_mac_address.swift
//  pos
//
//  Created by M-Wageh on 16/11/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation
//import LANScanner
//
//var netInfo = LANScanner.getHostName("192.168.5.101")
class PrinterMacAddressInteractor{
    private let API:api?
    static let shared:PrinterMacAddressInteractor = PrinterMacAddressInteractor()
    private init(){
        self.API = api()
    }
    func setMacAddress(){
        MWQueue.shared.printerMacAddressThread.async {
       let printerNotHaveMAc =  restaurant_printer_class.getAll( " mac_address = '' " ).map({restaurant_printer_class(fromDictionary: $0)})
        if printerNotHaveMAc.count > 0{
            printerNotHaveMAc.forEach { printerDB in
                let printerIP = printerDB.printer_ip
                if !printerIP.isEmpty{
                    if  let macAddress = self.findMacAddress(for: printerDB.printer_ip ),!macAddress.isEmpty {
                    printerDB.mac_address = macAddress
                    printerDB.save()
                    self.hitUpdateRestaurantPrinterAPI(printerDB)
                }
                }
            }
        }
        }
    }
    func findMacAddress(for ipaddress: String) -> String? {
        return MacFinder.ip2mac(ipaddress)
    }
    func hitUpdateRestaurantPrinterAPI(_ printer:restaurant_printer_class)
    {
        if AppDelegate.shared.enable_debug_mode_code()
        {
            return
        }
        API?.new_write_restaurant_printer(printer: printer) { [self] result in
            if (result.success )
            {
                    
            }

        }
    }
}
/*
// MARK: - Network methods
  func getHostName(_ ipaddress: String) -> String? {
      return MacFinder.ip2mac(ipaddress)
    var hostName:String? = nil
    var ifinfo: UnsafeMutablePointer<addrinfo>?
    
    /// Get info of the pa3ssed IP address
    if getaddrinfo(ipaddress, nil, nil, &ifinfo) == 0 {
        
        var ptr = ifinfo
        while ptr != nil {
            
            let interface = ptr!.pointee
            
            /// Parse the hostname for addresses
            var hst = [CChar](repeating: 0, count: Int(NI_MAXHOST))
            if getnameinfo(interface.ai_addr, socklen_t(interface.ai_addrlen), &hst, socklen_t(hst.count),
                           nil, socklen_t(0), 0) == 0 {
                
                if let address = String(validatingUTF8: hst) {
                    hostName = address
                }
            }
            ptr = interface.ai_next
        }
        freeaddrinfo(ifinfo)
    }
    
    return hostName
}

//  Converted to Swift 5.7 by Swiftify v5.7.28606 - https://swiftify.com/
 func hostnames(forIPv4Address address: String?) -> [AnyHashable]? {
    var result:  UnsafeMutablePointer<addrinfo>? = nil
    var hints: addrinfo

    memset(&hints, 0, MemoryLayout.size(ofValue: hints))
    hints.ai_flags = AI_NUMERICHOST
    hints.ai_family = PF_UNSPEC
    hints.ai_socktype = SOCK_STREAM
    hints.ai_protocol = 0
      
    let errorStatus = getaddrinfo((address as NSString?)?.cString(using: String.Encoding.ascii.rawValue), nil, &hints, &result)
    if errorStatus != 0 {
        return nil
    }

    let addressRef = CFDataCreate(nil, UnsafePointer<UInt8>(UInt8(result?.ai_addr ?? 0)), result?.ai_addrlen ?? 0)
    if addressRef == nil {
        return nil
    }
    freeaddrinfo(result)

    var hostRef: CFHost? = nil
    if let addressRef = addressRef {
        hostRef = CFHostCreateWithAddress(kCFAllocatorDefault, addressRef) as? CFHost
    }
    if hostRef == nil {
        return nil
    }


    var succeeded = false
    if let hostRef = hostRef {
        succeeded = CFHostStartInfoResolution(hostRef, .names, nil)
    }
    if !succeeded {
        return nil
    }

    var hostnames: [AnyHashable] = []

    var hostnamesRef: CFArray? = nil
    if let hostRef = hostRef {
        hostnamesRef = CFHostGetNames(hostRef, nil)
    }
    for currentIndex in 0..<((hostnamesRef as? [AnyHashable])?.count ?? 0) {
        if let object = (hostnamesRef as? [AnyHashable])?[currentIndex] {
            hostnames.append(object)
        }
    }

    return hostnames
}
extension Data {
    func castToCPointer<T>() -> T {
        let mem = UnsafeMutablePointer<T>.allocate(capacity: 1)
        _ = self.copyBytes(to: UnsafeMutableBufferPointer(start: mem, count: 1))
        return mem.move()
    }
}
*/
