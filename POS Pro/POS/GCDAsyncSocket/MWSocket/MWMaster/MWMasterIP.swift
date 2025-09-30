//
//  MWMasterIP.swift
//  pos
//
//  Created by M-Wageh on 02/05/2023.
//  Copyright © 2023 khaled. All rights reserved.
//

import Foundation
import BRYXBanner

class MWMasterIP {
    enum MASTER_IP_MASSAGES:Int{
        case OFFLINE,SESSION_CLOSED,MASTER_SERVER,NOT_PUBLISH,WIFI_OFF,IP_ADD_CHANGED
        
        func getTitle() -> String{
            switch self{
            case .OFFLINE :
                return  "[Check Master Device]".arabic("تحقق من اتصال الجهاز الرئيسي")
            case .SESSION_CLOSED :
                return  "[Check Master Session]".arabic("تحقق من جلسه الجهاز الرئيسي")
            case .MASTER_SERVER :
                return  "[Master-Service not found ]".arabic("[لم يتم العثور على الخدمة الرئيسية]")
            case .NOT_PUBLISH :
                return  "[Check local network permission]".arabic("تحقق من امكانيه الوصول  ")
            case .WIFI_OFF :
                return  "[Check WIFI Connection]".arabic("تحقق من  الاتصال بالشبكه  ")
            case .IP_ADD_CHANGED :
                return  "[IP has Changed]".arabic("حدث تغير ل IP")
            }
        }
        func getMessage(master_device: device_ip_info_class? = nil) -> String{
            var nameMaster = ""
            if let masterDevice = master_device ,let  name_master = masterDevice.pos_name{
                nameMaster = name_master
            }

            switch self{
            case .OFFLINE :
                if  !nameMaster.isEmpty{
                    return  "\(nameMaster) device is Offline,please check it".arabic("\(nameMaster)  غير متاح من فضلك تآكد من تشغيله")

                }
                return  "Master device is Offline,please check it".arabic("الجهاز الرئيسيه غير متاح من فضلك تآكد من تشغيله")
            case .SESSION_CLOSED :
                if  !nameMaster.isEmpty{
                    return  "Session is closed from \(nameMaster) device,please check it".arabic("الجلسة مغلقة من \(nameMaster)  ، يرجى التحقق منها")
                }
                return  "Session is closed from Master device,please check it".arabic("الجلسة مغلقة من الجهاز الرئيسي ، يرجى التحقق منها")
            case .MASTER_SERVER :
                return  "Please restart the application".arabic("الرجاء إعادة تشغيل التطبيق")
            case .NOT_PUBLISH :
                return  "Please, Check local-network permission and restart application".arabic("تحقق من امكانيه الوصول  ")
            case .WIFI_OFF :
                return  "Please check wifi connection".arabic("الرجاء التحقق من الاتصال بالشبكه  ")
            case .IP_ADD_CHANGED :
                let workingIP = SharedManager.shared.cashWorkingIP
                let currentIP = MWConstantLocalNetwork.iPAddress

                return  "Ip changed from \(workingIP) to \(currentIP) ".arabic("حدث تغير ل IP من \(workingIP) الي \(currentIP)")


                
            }
        }
        
    }
    var masterBanner: Banner?
    static let shared = MWMasterIP()
    var lastMasterOnline:Bool = true

    private init(){
    }
    func isOnLine()->Bool{
        if SharedManager.shared.isSequenceAtMasterOnly(){
            
            return true
        }
        return self.checkMasterStatus()
/*
        if SharedManager.shared.isSequenceAtMasterOnly(){
            if lastMasterOnline {
                DispatchQueue.global().asyncAfter(deadline: .now() + 15) {
                    self.lastMasterOnline = self.checkMasterStatus()
                }
                return true
            }else{
                return self.checkMasterStatus()
            }
        }else{
            self.lastMasterOnline = self.checkMasterStatus()

            return self.lastMasterOnline
        }
           
       // self.getMasterDevice()?.is_online ?? false
 */
    }
    private func getMasterDevice() -> device_ip_info_class?{
        return device_ip_info_class.getMasterStatus()
    }

    func showMasterOfflineNotification(for message:MASTER_IP_MASSAGES,master_device: device_ip_info_class? = nil){
        if SharedManager.shared.mwIPnetwork {
            if message == .OFFLINE {
                device_ip_info_class.setOffline(for:MWConstantLocalNetwork.MessageKeys.MASTER_DEVICE_NAME,checkMaster: false )
            }
            if message == .SESSION_CLOSED {
                device_ip_info_class.setMasterCloseSession()
            }
           let masterDevice = master_device ?? device_ip_info_class.getMasterStatus()
            let title = message.getTitle()
            let messageString = message.getMessage(master_device: masterDevice)
           
            DispatchQueue.main.async {
                if let banner = self.masterBanner{
                    if (banner.titleLabel.text?.lowercased() ?? "" ) == title.lowercased() &&  (banner.detailLabel.text?.lowercased() ?? "" ) == messageString.lowercased(){
//                        self.masterBanner?.show(duration: nil)
                        return
                    }
                }

//            self.dismissMasterBanner()
            self.initalMasterBannerNotification(title:title, message: messageString, success: false, icon_name: "icon_error" )
                self.masterBanner?.dismissesOnTap = true
//            let view = AppDelegate.shared.window?.visibleViewController()?.view
         //   self.masterBanner?.show(duration: nil)
//            self.masterBanner?.didMoveToSuperview()
           
            
        }
        }
    }
//    @objc func master_device_is_offline(notification: Notification) {
//        showMasterOfflineNotification(for:.OFFLINE)
//    }
    /*
    func addNotificationCenter(){
        if !SharedManager.shared.posConfig().isMasterTCP(){
            NotificationCenter.default.addObserver(self, selector: #selector( master_device_is_offline(notification:)), name: Notification.Name(MWConstantLocalNetwork.NotificationKeys.MASTER_IS_OFFLINE), object: nil)
        }
    }
    func removeNotificationCenter(){
        if !SharedManager.shared.posConfig().isMasterTCP(){
            NotificationCenter.default.removeObserver(self, name: Notification.Name(MWConstantLocalNetwork.NotificationKeys.MASTER_IS_OFFLINE), object: nil)
        }
    }
     */
    func postMasterIpDeviceOffline(){
        if !SharedManager.shared.posConfig().isMasterTCP(){
            sequence_session_ip.shared.forceStop()
                showMasterOfflineNotification(for:.OFFLINE)
/*
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
            NotificationCenter.default.post(name: Notification.Name(MWConstantLocalNetwork.NotificationKeys.MASTER_IS_OFFLINE), object:  nil,userInfo: nil)
        })
 */
        }
    }
    func initalMasterBannerNotification(title:String,message:String,success:Bool, icon_name:String)  {
        masterBanner?.dismiss()
        masterBanner = nil
//        let red = UIColor(red:198.0/255.0, green:26.00/255.0, blue:27.0/255.0, alpha:1.000)
           let green = UIColor(red:48.00/255.0, green:174.0/255.0, blue:51.5/255.0, alpha:1.000)
         let yellow = #colorLiteral(red: 0.6243936419, green: 0.2647369504, blue: 0.8237219453, alpha: 1)//UIColor(red:255.0/255.0, green:204.0/255.0, blue:51.0/255.0, alpha:1.000)
        masterBanner = Banner(title: title,
                           subtitle: message,
                           image: UIImage(named: icon_name),
                           backgroundColor: success ? green:yellow )
    }
    @discardableResult  func checkMasterStatus(masterDeviceComing:device_ip_info_class? = nil ) -> Bool{
      
        /*if SharedManager.shared.mwIPnetwork{
            self.showLocalNetWorkPermissionNotification()
            if !SharedManager.shared.posConfig().isMasterTCP(){
                
                let masterDevice = masterDeviceComing ?? device_ip_info_class.getMasterStatus()
                
                let cash_is_online = masterDevice?.is_online ?? false
                let cash_is_open_session = masterDevice?.is_open_session ?? false
                
                let masterServerNotExist = !MWLocalNetworking.sharedInstance.masterServiceFound()
                if !masterServerNotExist{
                    masterDevice?.is_online = true
                    device_ip_info_class.setOffline(for:MWConstantLocalNetwork.MessageKeys.MASTER_DEVICE_NAME,is_online: 1, checkMaster: false )
                    return true
                }
                if !(masterDevice?.is_online ?? false){
                    showMasterOfflineNotification(for:.OFFLINE,master_device: masterDevice)
                    return false
                }
                self.dismissMasterBanner()
                    if !(masterDevice?.is_open_session ?? false){
                        showMasterOfflineNotification(for:.SESSION_CLOSED,master_device: masterDevice)
                        return false
                    }
                if  masterServerNotExist {
                    showMasterOfflineNotification(for:.OFFLINE,master_device: masterDevice)
                    return false
                }
                    
                
            }
        }
        */
      return true
    }
    
    func dismissMasterBanner(){
        DispatchQueue.main.async {
            self.masterBanner?.dismiss()
            self.masterBanner = nil
        }
    }
    func showLocalNetWorkPermissionNotification(){
            if !MWLocalNetworking.sharedInstance.mwServerTCP.isPublished{
                self.dismissMasterBanner()
                self.showMasterOfflineNotification(for:.NOT_PUBLISH)
            }
    }
    
}
