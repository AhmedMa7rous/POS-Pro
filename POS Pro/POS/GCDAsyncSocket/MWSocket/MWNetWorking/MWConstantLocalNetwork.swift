//
//  MWConstantLocalNetwork.swift
//  kds
//
//  Created by M-Wageh on 07/09/2022.
//  Copyright © 2022 khaled. All rights reserved.
// @11223344@$

import Foundation
import Network
class MWConstantLocalNetwork{
    struct MessageKeys{
        static let MASTER_DEVICE_NAME = "mw.localnetwork.poss.tcp"

        static let SENDER_KEY = "sender"
        static let DATA_KEY = "data"
        static let TIMESTAMP_KEY = "timestamp"
        static let IP_MESSAGE_TYPE_KEY = "ip_message_type"
        static let TARGET_KEY = "target"
        static let RECIEVER_KEY = "reciever"
        static let MESSAGE_KEY = "message"
        static let CODE_KEY = "code"
        static let FALIURE_KEY = "faliure"
        static let TARGET_IP_KEY = "target_ip"
        static let MAC_ADDRESS_KEY = "mac_address"
        static let IP_ADDRESS_KEY = "ip_address"
        static let POS_ID_KEY = "pos_id"
        static let DEVICE_TYPE_KEY = "device_type"
        static let DEVICE_INFO_KEY = "device_info"
        static let COMPANY_ID_KEY = "company_id"
        static let NUMBER_TRIES = "number_tries"
        static let EXCLUD_UID = "exclud_uid"
        static let DEVICE_INFO = "device_info"
        static let CURRENT_SEQ_SESSION = "current_seq_session"
        static let NEXT_SEQ_SESSION = "next_seq_session"
        static let IS_OPEN_SESSION = "is_open_session"
        static let IS_ONLINE = "is_online"
        static let ORDER_SEQ = "order_sequces"
        static let IS_MASTER = "is_master"
        static let REQUEST_SEQ = "request_seq"
        static let POS_NAME = "pos_name"
        static let USER_NAME = "user_name"
        static let OFF_SET_PENDING = "offset_pending"
        static let SEQUENCE_RESPONSE = "sequence_response"
        static let UID_KEY = "uid"
        static let closed_by_master = "closed_by_master"







    }
    struct NotificationKeys{
        static let MASTER_IS_OFFLINE = "master_offline"
    }
    //"_testService._tcp."
    static let domainNetwork = "local."
    static let typeLocalNetwork = "_MWLocalNetworking._tcp."
    static let networkingQueue = "MWLocalNetworkingQueue"
    static let defaultSequence = -30

//    static let host_port: UInt16 = 9090//0//8080
    static var posHostServiceName:String {
        get{
            if SharedManager.shared.posConfig().isMasterTCP(){
                return MessageKeys.MASTER_DEVICE_NAME 
            }else{
                return getIPV4Address()
            }
        }
    }


    static func getIPV4Address() -> String {
        let ipAddress = NWInterface.InterfaceType.wifi.ipv4 ?? ""
        if ipAddress.isEmpty {
            DispatchQueue.main.asyncAfter(deadline:.now() + .seconds(2) , execute: {
                MWMasterIP.shared.showMasterOfflineNotification(for: .WIFI_OFF)
            })
        }else{
            let cashWorkingIP = SharedManager.shared.cashWorkingIP
            if !cashWorkingIP.isEmpty &&  cashWorkingIP != ipAddress && !SharedManager.shared.posConfig().isMasterTCP(){
                DispatchQueue.main.asyncAfter(deadline:.now() + .seconds(2) , execute: {
                    MWMasterIP.shared.showMasterOfflineNotification(for: .IP_ADD_CHANGED)
                })
            }
        }
        return ipAddress
    }
    
    static var iPAddress:String{
        get{
            return NWInterface.InterfaceType.wifi.ipv4 ?? ""
/*
       let macAddress = getMacAddress()
        let ipAddress = NWInterface.InterfaceType.wifi.ipv4 ?? ""
       return    [ipAddress,macAddress].joined(separator: "-")
 */
        }
    }
    
    static func getMacAddress() -> String{
        var mac = ""
        if let ipV6 = NWInterface.InterfaceType.wifi.ipv6 {
             mac = NWInterface.InterfaceType.GetMACAddressFromIPv6(ip:ipV6)
        }
        return mac
    }
}
extension NWInterface.InterfaceType {
    var names : [String]? {
        switch self {
        case .wifi: return ["en0"]
        case .wiredEthernet: return ["en2", "en3", "en4"]
        case .cellular: return ["pdp_ip0","pdp_ip1","pdp_ip2","pdp_ip3"]
        default: return nil
        }
    }

    func address(family: Int32) -> String?
    {
        guard let names = names else { return nil }
        var address : String?
        for name in names {
            guard let nameAddress = self.address(family: family, name: name) else { continue }
            address = nameAddress
            break
        }
        return address
    }

    func address(family: Int32, name: String) -> String? {
        var address: String?

        // Get list of all interfaces on the local machine:
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0, let firstAddr = ifaddr else { return nil }

        // For each interface ...
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee

            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(family)
            {
                // Check interface name:
                if name == String(cString: interface.ifa_name) {
                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
        }
        freeifaddrs(ifaddr)

        return address
    }
    static func GetMACAddressFromIPv6(ip: String) -> String{
          let IPStruct = IPv6Address(ip)
          if(IPStruct == nil){
              return ""
          }
          let extractedMAC = [
              (IPStruct?.rawValue[8])! ^ 0b00000010,
              IPStruct?.rawValue[9],
              IPStruct?.rawValue[10],
              IPStruct?.rawValue[13],
              IPStruct?.rawValue[14],
              IPStruct?.rawValue[15]
          ]
          return String(format: "%02x:%02x:%02x:%02x:%02x:%02x", extractedMAC[0] ?? 00,
              extractedMAC[1] ?? 00,
              extractedMAC[2] ?? 00,
              extractedMAC[3] ?? 00,
              extractedMAC[4] ?? 00,
              extractedMAC[5] ?? 00)
      }

    var ipv4 : String? { self.address(family: AF_INET) }
    var ipv6 : String? { self.address(family: AF_INET6) }
    
}

