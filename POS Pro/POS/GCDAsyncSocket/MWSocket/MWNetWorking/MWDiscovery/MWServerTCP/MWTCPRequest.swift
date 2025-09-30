//
//  MWTCPRequest.swift
//  pos
//
//  Created by M-Wageh on 20/03/2023.
//  Copyright © 2023 khaled. All rights reserved.
//

import Foundation
class MWTCPRequest {
    enum MWTCP_REQUEST_STATUS{
        case NONE,START
    }
    static let shared = MWTCPRequest()
    let ipOrderFactor = IPOrderFactor.shared
    private var requestQueu = MWQueue.shared.mwTCPRequest
//    var completeDeviceInf: ((() -> Void)?) = nil
    var status:MWTCP_REQUEST_STATUS = .NONE
    private init(){}
    func requestAll(isOpen:Bool? = nil){
        if !MWLocalNetworking.sharedInstance.canMakeReqquest(){
            return
        }
        if status == .START {
            return
        }
        if !SharedManager.shared.mwIPnetwork {
            return
        }
        if SharedManager.shared.posConfig().isMasterTCP() {
            return
        }
//        if !SharedManager.shared.posConfig().isMasterTCP() {
//            let masterDevice = device_ip_info_class.getMasterStatus()
//            if !(masterDevice?.is_online ?? false ) && !(masterDevice?.is_open_session ?? false ){
////                self.requestAll(isOpen:isOpen)
////                MWMasterIP.shared.checkMasterStatus(masterDeviceComing: masterDevice )
//                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(200), execute: {
//                    MWTCPRequest.shared.sentDeviceInfo()
//                })
//                return
//            }
//        }
        status = .START
        requestQueu.async{
            var requestBody:[BodyMessageIpModel] = []
            
//            if !MWMessageQueueRun.shared.checkTypeInQueu(.SEND_DEVICE_INFO){
//                let messagePDeviceInfo = self.ipOrderFactor.sentDeviceInfo(isOpen)
//                requestBody.append(contentsOf: messagePDeviceInfo)
//            }
//
            if !MWMessageQueueRun.shared.checkTypeInQueu(.PENDING_ORDERS){
                let messagePendingOrder = self.ipOrderFactor.getUIDPendingOrders()
                requestBody.append(contentsOf: messagePendingOrder  )
            }
            
//            if !MWMessageQueueRun.shared.checkTypeInQueu(.DEVICE_INFO){
//                let messagePDeviceInfo = self.ipOrderFactor.getDeviceInfoRequest()
//                requestBody.append(contentsOf: messagePDeviceInfo)
//            }
            
            
            if requestBody.count > 0{
                MWMessageQueueRun.shared.addToQueu(messages:requestBody)
                MWMessageQueueRun.shared.startMWMessageQueue()
            }
            self.requestQueu.asyncAfter(deadline: .now() + .seconds(2), execute: {
                self.status = .NONE
            })
            


        
        }
    }
    /**
     
            [Description][Waiter/Master] : # Make requestPendingOrder to [Master-POS/Waiter/Sub-Cashier] when start or resum session
     */
    /**
     
            [Failure Case][Waiter] is closed and having pending order which changed
     */
    func requestPendingOrder(){
        if SharedManager.shared.posConfig().isMasterTCP() {
            return
        }
        if !MWLocalNetworking.sharedInstance.canMakeReqquest(){
            return
        }
        requestQueu.async{
        if !MWMessageQueueRun.shared.checkTypeInQueu(.PENDING_ORDERS){
        let requestBody = self.ipOrderFactor.getUIDPendingOrders()
            if requestBody.count > 0{
        MWMessageQueueRun.shared.addToQueu(messages:requestBody)
        MWMessageQueueRun.shared.startMWMessageQueue()
            }
            }
        }
    }
    /**
     
            [Request Device Info]
     */
    
    func requestSequence(){
        if SharedManager.shared.posConfig().isMasterTCP() {
            return
        }
        if SharedManager.shared.isSequenceAtMasterOnly() {
            return
        }
        requestQueu.async{
            if !MWMessageQueueRun.shared.checkTypeInQueu(.REQUEST_SEQ){

        let requestBody = self.ipOrderFactor.getSequenceRequest()
            if requestBody.count > 0{
        MWMessageQueueRun.shared.addToQueu(messages:requestBody)
        MWMessageQueueRun.shared.startMWMessageQueue()
            }
            }
        }
         
    }
    /**
     
            [Sent Device Info]
     */
    func sentDeviceInfo(_ is_open_session:Bool? = nil){
        if !MWLocalNetworking.sharedInstance.canMakeReqquest(){
            return
        }
        requestQueu.async{
            if !MWMessageQueueRun.shared.checkTypeInQueu(.SEND_DEVICE_INFO){

        let requestBody = self.ipOrderFactor.sentDeviceInfo(is_open_session)
            if requestBody.count > 0{
        MWMessageQueueRun.shared.addToQueu(messages:requestBody)
        MWMessageQueueRun.shared.startMWMessageQueue()
            }
            }
        }
         
    }
}

