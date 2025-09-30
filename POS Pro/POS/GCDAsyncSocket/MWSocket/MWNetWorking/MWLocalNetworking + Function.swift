//
//  MWLocalNetworking + Join.swift
//  pos
//
//  Created by M-Wageh on 09/09/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation
extension MWLocalNetworking {
    func addSocketConnected(_ socketConnected: GCDAsyncSocket){
        MWQueue.shared.mwClientArrayQueue.async {
            if socketConnected.localHost == nil && socketConnected.localAddress == nil {
                return
            }
        if  self.connectedSockets.count > 0{
            self.connectedSockets.removeAll(where:{$0.localHost == socketConnected.localHost})
            self.connectedSockets.append(socketConnected)
/*
        self.connectedSockets.forEach { asyncSocket in
            if asyncSocket != socketConnected{
                self.connectedSockets.append(socketConnected)
            }
        }*/
        }else{
            self.connectedSockets.append(socketConnected)
        }
            self.connectedSockets = self.connectedSockets.filter({$0.localHost != nil && $0.localHost != nil}).compactMap({$0})

        }
        
    }
    func checkAndAdd(_ service: NetService,sendInfo:Bool){
        

        if  self.serviceFound.count > 0{
            self.checkAndRemove(service)
            self.serviceFound.append(service)
        }else{
            self.serviceFound.append(service)
        }
        if sendInfo {
            MWMasterIP.shared.dismissMasterBanner()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1), execute: {
                MWTCPRequest.shared.sentDeviceInfo()
            })
        }
        if self.serviceTasks.count > 0 {
            mwClientTCP.runAppenServiceFromTasks()
        }
//        SharedManager.shared.printLog("checkAndAdd self.serviceFound.count====\(self.serviceFound.count)")
//        SharedManager.shared.printLog("service ====\(self.serviceFound.map({$0.name}))")
    }
    func isNeedToSearchService(){
        let devicesTypes:[DEVICES_TYPES_ENUM] = SharedManager.shared.posConfig().isMasterTCP() ? [.WAITER,.SUB_CASHER,.KDS] :[.MASTER]
        let allTargetDevices = socket_device_class.getDevices(for:devicesTypes,with: [.NONE, .ACTIVE]).map({socket_device_class(from: $0)})
        let nameServercesFound = self.serviceFound.map({$0.name})
        
        if nameServercesFound.count > 0 {
            
        }
        
    }
    func removeAllService(){
        self.serviceFound.removeAll()
    }
    func checkAndRemove(_ comingService: NetService){

        if  self.serviceFound.count > 0{
            
//            self.serviceFound.removeAll(where: {$0.name == comingService.name})
            if let indexCurrent = self.serviceFound.firstIndex(where: {$0.name == comingService.name}){
                if self.serviceFound.count > indexCurrent {
                    self.serviceFound.remove(at: indexCurrent)
                }
            }
            DispatchQueue.main.async {
                device_ip_info_class.setOffline(for: comingService.name)
                if !SharedManager.shared.posConfig().isMasterTCP(){
                    MWMasterIP.shared.checkMasterStatus()
                }
            }
         
            
        }
//        SharedManager.shared.printLog("checkAndRemove self.serviceFound.count====\(self.serviceFound.count)")
//        SharedManager.shared.printLog("comingService ====\(comingService.name)")

    }
    func ping(for socket_device:socket_device_class, completionHandler:@escaping (_ result: String) -> Void ){
       
        guard let device_ip = socket_device.device_ip, device_ip.verifyIP() else {
            completionHandler("Fail as Wrong IP")
            return
        }
        let once = try? SwiftyPing(host: device_ip, configuration: PingConfiguration(interval: 0.5, with: 5), queue: DispatchQueue.global())
        once?.observer = { (response) in
            if  let error = response.error{
                completionHandler( error.localizedDescription ?? "")
            }else{
                if self.getIpDevices().count == 0{
                    completionHandler("Ping Successfully , but Device not start service  , please check device and ip address ")
                    return
                }else{
                    if self.getIpDevices().filter ({  socket_device == $0.socket_device }).count == 0 {
                        completionHandler("Ping Successfully , but Device not start service  , please check device and ip address ")
                        return
                    }
                       
                }
                completionHandler("Ping Successfully, and  Device service start Successfully")
            }
        }
        once?.targetCount = 1
        try? once?.startPinging()
    }


    func checkService(for ipDevice:IPDeviceModel){
//        self.discovery.count72003Error = 0
        self.mwClientTCP.serviceSelected(ipDevice)
    }

    func removeService(for ipDevice:IPDeviceModel){
        if let index = self.serviceFound.firstIndex(where: {$0.name == ipDevice.service.name}){
            self.serviceFound.remove(at:index )
        }
    }
    func getIpDevices() -> [IPDeviceModel]{
        var ipDevices:[IPDeviceModel] = []
        self.serviceFound.forEach { netService in
            if let socketDevice = getSocketDevice(for:netService){
                ipDevices.append(IPDeviceModel(service: netService, socket_device: socketDevice))
            }
            /*self.activeDevices.forEach { socketDevice in
                if socketDevice.checkService(netService.name) {
                    ipDevices.append(IPDeviceModel(service: netService, socket_device: socketDevice))
                }
            }*/
        }
        return ipDevices
        
    }
    func getSocketDevice(for service:NetService)->socket_device_class? {
        if self.activeDevices.count > 0 {
           return self.activeDevices.first(where: {$0.device_ip == service.name})
        }
        return nil
    }
    func forceTimeOutDisConnect(){
        self.mwClientTCP.forceTimeOutDisConnectClient()
    }
    func masterServiceFound() -> Bool{
        var allService:[NetService] = []
        allService.append(contentsOf:self.serviceFound )
        allService.append(contentsOf: self.serviceTasks)
        let isFound = allService.map({$0.name.lowercased()}).contains(MWConstantLocalNetwork.MessageKeys.MASTER_DEVICE_NAME.lowercased())
        if !isFound {
            
            MWLocalNetworking.sharedInstance.mwClientTCP.reSearchForServices()
        }

        return isFound
    }
    func canMakeReqquest() -> Bool{
        let haveServices = self.serviceFound.count > 0
        let isPublished =  mwServerTCP.isPublished
        let isStartWorking = mwServerTCP.isStarWorking
        if !isPublished && isStartWorking {
            MWLocalNetworking.sharedInstance.mwServerTCP.stop()
            MWLocalNetworking.sharedInstance.mwServerTCP.start()
        }
        var canMakeRequest = haveServices && isPublished
        if !SharedManager.shared.posConfig().isMasterTCP() && !haveServices{
            if !haveServices && !isPublished && !isStartWorking{
                MWMasterIP.shared.dismissMasterBanner()
            }else{
                MWMasterIP.shared.showMasterOfflineNotification(for: .OFFLINE)
            }
        }else{
            MWMasterIP.shared.dismissMasterBanner()
        }
        if !SharedManager.shared.posConfig().isMasterTCP(){
         //   canMakeRequest = !isPublished && haveServices
        }
        
        if !canMakeRequest{
            self.doRequest()
        }
        return canMakeRequest
    }
}
