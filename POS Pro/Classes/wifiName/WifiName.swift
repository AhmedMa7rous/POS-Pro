//
//  WifiName.swift
//  pos
//
//  Created by M-Wageh on 24/08/2021.
//  Copyright © 2021 khaled. All rights reserved.
//

import Foundation
import SystemConfiguration.CaptiveNetwork
import CoreLocation

struct NetWorkInfo{
    var interface:String
    var success:Bool = false
    var ssid:String?
    var bssid:String?
  
    
    
}




public class SSID{
    class func fetchNetworkInfo()->[NetWorkInfo]?{

        if let interfaces = CNCopySupportedInterfaces() as NSArray? {
            var networkInfos = [NetWorkInfo]()
          for interface in interfaces {
            let interfaceName = interface as! String
            var networkInfo = NetWorkInfo(interface: interfaceName, success: false, ssid: nil, bssid: nil)
            
            if let dic = CNCopyCurrentNetworkInfo(interface as! CFString) as NSDictionary? {
                networkInfo.success = true
                networkInfo.ssid = dic[kCNNetworkInfoKeySSID as String] as? String
                networkInfo.bssid = dic[kCNNetworkInfoKeyBSSID as String] as? String
              
            }
            networkInfos.append(networkInfo)
          }
            return networkInfos
            
        }
        return nil
    }
}

class WiFi:NSObject {
    var locationManager: CLLocationManager?
    var currentNetworkInfo:Array<NetWorkInfo>?{
        get{
            return SSID.fetchNetworkInfo()
        }
    }
    static let shared:WiFi = WiFi()
  
    func setupLocation(){
        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedAlways {
           // updateWifi()
        }else{
            locationManager = CLLocationManager()
            locationManager?.delegate = self
            locationManager?.requestAlwaysAuthorization()
        }
       
    }
   private func updateWifi(){
       SharedManager.shared.printLog("Show All Wifi")
        currentNetworkInfo?.forEach({ item in
            if let ssid = item.ssid {
               SharedManager.shared.printLog("SSID: \(String(describing: ssid))")

            }
        })
    }
   private func getConnectWifiName() -> String {
        var ssid: String = ""

        currentNetworkInfo?.forEach({ item in
            if item.success {
//               SharedManager.shared.printLog("SSID: \(String(describing: item.ssid))")
                ssid =  item.ssid ?? ""
            }
        })
        return ssid
    }
     func getWiFiName() -> String {
        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedAlways {
            return getConnectWifiName()

        }else{
            return "location not allow"
        }
     }
}
extension WiFi: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    if status == .authorizedAlways || status == .authorizedAlways {
      let ssid = self.getWiFiName()
     SharedManager.shared.printLog("SSID: \(String(describing: ssid))")
    }
  }
}
