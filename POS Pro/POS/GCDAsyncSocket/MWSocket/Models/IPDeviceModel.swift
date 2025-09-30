//
//  IPDeviceModel.swift
//  pos
//
//  Created by M-Wageh on 09/09/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation
extension NetService{
    static func == (lhs: NetService, rhs: NetService) -> Bool {
        return lhs.name == rhs.name
    }
}
class IPDeviceModel:Equatable
{
    var service: NetService
//    var connectSocket: GCDAsyncSocket
    var socket_device:socket_device_class
    var delegate:NextMessageQueueDelegate?
    private var messages:[messages_ip_queue_class]
    var current_message:messages_ip_queue_class?
    var messages_ip_log:messages_ip_log_class?
    var status:MWQueue_Status = MWQueue_Status.NONE

    init(service: NetService,socket_device:socket_device_class){
        self.service = service
        self.socket_device = socket_device
        self.messages = []
        self.messages_ip_log = messages_ip_log_class(fromDictionary: [:])
    }
    
    func setLogWith(state:String? = nil,
                    response:ResponseMessageIpModel? = nil)
    {
       
        if let state = state {
            self.messages_ip_log?.addStatus(state)
        }
        if let bodyMessages = current_message {
            self.messages_ip_log?.body = bodyMessages.message //json(from: [bodyMessages].map({$0.toDict().jsonString() ?? ""}))  ?? ""
            self.messages_ip_log?.messageIdentifier = bodyMessages.messageIdentifier 
        }
        if let response = response {
            self.messages_ip_log?.response = response.toDict().jsonString()
        }
    }
  
   
    func json(from object:Any) -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
            return nil
        }
        return String(data: data, encoding: String.Encoding.utf8)
    }
    static func == (lhs: IPDeviceModel, rhs: IPDeviceModel) -> Bool {
        return lhs.service.name == rhs.service.name && lhs.socket_device.name == rhs.socket_device.name
    }
    private func removeCurentMessage(){
        if self.messages.count > 0 {
        self.messages.removeFirst()
        }
        self.current_message = nil
        self.messages_ip_log?.addStatus("finish sent message at \(Date().toString(dateFormat: baseClass.date_fromate_satnder, UTC: true))")
        self.messages_ip_log?.save()
        self.messages_ip_log = nil
        self.messages_ip_log = messages_ip_log_class(fromDictionary: [:])

    }
    //MARK: - next Message if success
    func nextMessage() -> messages_ip_queue_class?{
        MWMessageQueueRun.shared.stopTimeOutTask()
        if let idFirstMessage = self.messages.first?.id {
            messages_ip_queue_class.delete(for: [idFirstMessage])
        }
        removeCurentMessage()
        if self.messages.count > 0 {
            initalizeMessagesLog()
            if self.current_message != nil {
                MWMessageQueueRun.shared.sartTimeOutTask()
            }
        }
        return self.current_message
    }
    func initalizeMessagesLog(){
        if let nextMessage = self.messages.first {
        self.messages_ip_log = messages_ip_log_class(fromDictionary: [:])
        self.messages_ip_log?.from_ip = MWConstantLocalNetwork.getIPV4Address()
        self.messages_ip_log?.to_ip = service.name
        self.current_message = nextMessage
            self.setLogWith(state: "Start Send Message at \(Date().toString(dateFormat: baseClass.date_fromate_satnder, UTC: true))")
        }
    }
    func startSendMessage(){
        initalizeMessagesLog()
        if self.current_message == nil {
            self.setLogWith(state: "Unable to sent as current message is nil")
            self.messages_ip_log?.addStatus("finish sent message at  \(Date().toString(dateFormat: baseClass.date_fromate_satnder, UTC: true))")
            self.messages_ip_log?.save()
            self.nextQueue(previousSuccess:false)
        }else{
            MWLocalNetworking.sharedInstance.checkService(for: self)
        }
    }
    //MARK: -  Message is Fail
    func saveCurrentMessageAsFailure(){
        self.messages_ip_log?.isFaluire = true
        self.messages_ip_log?.addStatus("Unable as previous Message Reult fail at \(Date().toString(dateFormat: baseClass.date_fromate_satnder, UTC: true)) ")
        if let failMessage = self.current_message{
            MWMessageQueueRun.shared.appendToFailureMessages([failMessage])
        }
        self.removeCurentMessage()
    }

    func nextQueue(previousSuccess:Bool){
//        MWMessageQueueRun.shared.mwMessagesQueue.async {
        if !previousSuccess{
            self.saveCurrentMessageAsFailure()
            if self.messages.count > 0 {
                self.messages.forEach { _  in
                    self.initalizeMessagesLog()
                    self.saveCurrentMessageAsFailure()
                }
            }
        }
        if let idFirstMessage = self.messages.first?.id {
            messages_ip_queue_class.delete(for: [idFirstMessage])
        }
        self.messages.removeAll()
        self.delegate?.next(with: previousSuccess)
        self.messages_ip_log = nil
       // }
    }
    func appendMessages(_ messages:[messages_ip_queue_class]){
        self.messages.append(contentsOf:messages )
    }
    func isContaineMessage() -> Bool{
        return self.messages.count > 0
    }
    
}
