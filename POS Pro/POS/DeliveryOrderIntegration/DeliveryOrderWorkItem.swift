//
//  DeliveryOrderWorkItem.swift
//  pos
//
//  Created by M-Wageh on 28/09/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation
class DeliveryOrderWorkItem {
    var order_integration:pos_order_integration_class
    var isStart:Bool = false
    private var orderTimeOutTask:DispatchWorkItem?
    
    init(_ order:pos_order_integration_class){
        self.order_integration = order
    }
    func sartTimeOutTask(){
        if checkIsTimeOut() {
            setOrderTimeOut()
            return
        }
        isStart = true
        if !(orderTimeOutTask?.isCancelled ?? false){
            if let timeOut = self.order_integration.time_out_duration , timeOut > 0 {
                let halfTimeOutSecand = (timeOut - 16)
                initalizeOrderTimeOutTask(deadline:halfTimeOutSecand)
                MWQueue.shared.timeOutDeliveryOrderQueue.asyncAfter(deadline: .now() + .seconds(3), execute: orderTimeOutTask!)
            }
        }
    }
    
    func stopTask(){
        orderTimeOutTask?.cancel()
        orderTimeOutTask = nil
    }
    private func getDifferentInSecand()->Int{
        let createDate = Date(strDate: order_integration.receive_datetime!, formate: baseClass.date_formate_database,UTC: false )
        return date_base_class.getSecondDifferenceFromTwoDates(start:createDate )
    }
    private func checkIsTimeOut() -> Bool{
        if let timeOut = self.order_integration.time_out_duration , timeOut > 0 {
            let minutLeft = getDifferentInSecand()
            return minutLeft > timeOut
        }
        return false
    }
    private func setOrderTimeOut(){
        pos_order_integration_class.setMenuStatus(with: .time_out, for: order_integration.order_uid ?? "")
        pos_order_class.setMenuStatus(with: .time_out, for: order_integration.order_uid ?? "")
        NotificationCenter.default.post(name: Notification.Name("time_out_integration_order"), object:nil,userInfo:nil )
    }
    private func initalizeOrderTimeOutTask(deadline:Int){
        orderTimeOutTask = DispatchWorkItem {
            
            if (self.orderTimeOutTask?.isCancelled ?? false) || (self.orderTimeOutTask == nil){
                self.stopTask()
                 DeliveryOrderIntegrationInteractor.shared.removeOrderTimeOutTasks(for: self.order_integration)
                 return
             }
            
             if self.order_integration.order_status == .pendding {
                 if self.checkIsTimeOut(){
                     self.setOrderTimeOut()
                     self.stopTask()
                 }else{
                     MWQueue.shared.timeOutDeliveryOrderQueue.asyncAfter(deadline: .now() + .seconds(deadline - self.getDifferentInSecand()), execute: self.orderTimeOutTask!)
                 }
             }else{
                 self.stopTask()
                 DeliveryOrderIntegrationInteractor.shared.removeOrderTimeOutTasks(for: self.order_integration)
             }
         }
    }
    
    
}
