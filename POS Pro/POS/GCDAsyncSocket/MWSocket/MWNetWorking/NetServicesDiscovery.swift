//
//  NetServicesDiscovery.swift
//  pos
//
//  Created by M-Wageh on 05/01/2023.
//  Copyright © 2023 khaled. All rights reserved.
//

import Foundation
import Foundation
/*
class FindServices:NSObject,NetServiceDelegate,NetServiceBrowserDelegate {

    let browser = NetServiceBrowser()
    var arrayService = [NetService]()
    var arrayHosts = [HostStructure]()


    init(netService: String, domain: String) {
        super.init()
        browser.delegate = self
        browser.searchForServices(ofType: netService, inDomain: domain)
        //var arrayHosts  = hostStuct.arrayHosts
    }

    func stopService(){
        browser.stop()
        browser.delegate  = nil
    }

    //MARK: Delegates

    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        service.delegate = self
        service.resolve(withTimeout: 0.0)
        arrayService.append(service)
    }

    func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
    }

    func netServiceBrowserWillSearch(_ browser: NetServiceBrowser) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "FindInstancesWillSearch"), object: nil)
    }

    func netServiceBrowser(_ browser: NetServiceBrowser, didNotSearch errorDict: [String : NSNumber]) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "FindInstancesStopSearch"), object: nil)
    }

    func netServiceDidResolveAddress(_ sender: NetService) {
        if let addresses = sender.addresses, addresses.count > 0 {
            for address in addresses {
                let data = address as NSData
                let inetAddress: sockaddr_in = data.castToCPointer()
                if inetAddress.sin_family == __uint8_t(AF_INET) {
                    if let ip = String(cString: inet_ntoa(inetAddress.sin_addr), encoding: .ascii) {
                        // IPv4
                        SharedManager.shared.printLog(ip)
                        let port = String(UInt16(inetAddress.sin_port).byteSwapped)
                        addToArrayHost(name: sender.name, ip: ip, port: port)
                    }


                } else if inetAddress.sin_family == __uint8_t(AF_INET6) {
                    let inetAddress6: sockaddr_in6 = data.castToCPointer()
                    let ipStringBuffer = UnsafeMutablePointer<Int8>.allocate(capacity: Int(INET6_ADDRSTRLEN))
                    var addr = inetAddress6.sin6_addr

                    if let ipString = inet_ntop(Int32(inetAddress6.sin6_family), &addr, ipStringBuffer, __uint32_t(INET6_ADDRSTRLEN)) {
                        if let ip = String(cString: ipString, encoding: .ascii) {
                            // IPv6
                            SharedManager.shared.printLog(ip)
                        }
                    }

                    ipStringBuffer.deallocate(capacity: Int(INET6_ADDRSTRLEN))
                }
            }
        }
    }


    func netService(_ sender: NetService, didNotResolve errorDict: [String : NSNumber]) {
    }

    func getAddress(data: NSData){
    }

    //MARK ARRAY CONTROL AND NOTIFICATION

    func addToArrayHost(name: String, ip: String, port: String){
        arrayHosts.append(HostStructure(name: name, ip: ip, port: port, username: "", password: ""))
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "FindInstancesNewService"), object: nil)
    }

    func getHosts ()->[HostStructure]{
        return arrayHosts
    }
}


extension NSData {
    func castToCPointer<T>() -> T {
        let mem = UnsafeMutablePointer<T>.allocate(capacity: MemoryLayout<T.Type>.size)
        self.getBytes(mem, length: MemoryLayout<T.Type>.size)
        return mem.move()
    }
}
*/
