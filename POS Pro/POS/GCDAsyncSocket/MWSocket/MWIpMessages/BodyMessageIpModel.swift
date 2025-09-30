//
//  BodyMessageIpModel.swift
//  pos
//
//  Created by M-Wageh on 22/08/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation
protocol MWIPMessageProtocol{
    init(jsonData: Data) throws
    var target:DEVICES_TYPES_ENUM { get set }
    func toDict() -> Dictionary<String, Any>
    func toJsonData() throws -> Data
    func getIPData() -> Data?
}
class BodyMessageIpModel:MWIPMessageProtocol{
    var target:DEVICES_TYPES_ENUM
    var targetIp:String
    var sender:  [String:Any]
    let data: [[String:Any]]
    let timestamp: Date
    var ipMessageType: IP_MESSAGE_TYPES
    var noTries:Int = 0

    init(data: [[String:Any]],ipMessageType: IP_MESSAGE_TYPES,target:DEVICES_TYPES_ENUM,targetIp:String,noTries:Int) {
        self.sender = MessageIpInfoModel().toDict()
        self.data = data
        self.timestamp = Date()
        self.ipMessageType = ipMessageType
        self.target = target
        self.targetIp = targetIp
        self.noTries = noTries

    }
    
    required init(jsonData: Data) throws {
        var sender_initalize:[String:Any] = [:]
        var message:[[String:Any]] = []
        var timestamp_initalize = Date()
        var messageType_initalize  = 0
        var target_initalize  = ""
        var targetIp_initalize  = ""
        var number_tries = 0

        if let dict = try JSONSerialization.jsonObject(with: jsonData, options: .mutableLeaves) as? NSDictionary {
            if let senderInitalize = dict[MWConstantLocalNetwork.MessageKeys.SENDER_KEY] as? [String:Any] {
                sender_initalize = senderInitalize
            }else{
                throw MWNetworkError.parsingError("MWNetworkError SENDER_KEY parsingError")
            }
            if let messageTypeInitalize = dict[MWConstantLocalNetwork.MessageKeys.IP_MESSAGE_TYPE_KEY] as? Int  {
                messageType_initalize = messageTypeInitalize
            }else{
                throw MWNetworkError.parsingError("MWNetworkError IP_MESSAGE_TYPE_KEY parsingError")
            }
            if let targetInitalize = dict[MWConstantLocalNetwork.MessageKeys.TARGET_KEY] as? String {
                target_initalize = targetInitalize
            }else{
                throw MWNetworkError.parsingError("MWNetworkError TARGET_KEY parsingError")
            }
            if let messageInitalize = dict[MWConstantLocalNetwork.MessageKeys.DATA_KEY] as? [[String:Any]] {
                message = messageInitalize
            }else{
                throw MWNetworkError.parsingError("MWNetworkError DATA_KEY parsingError")
            }
            if let intervalInitalize = dict[MWConstantLocalNetwork.MessageKeys.TIMESTAMP_KEY] as? TimeInterval {
                timestamp_initalize = Date(timeIntervalSince1970: intervalInitalize / 1000)
            }else{
                throw MWNetworkError.parsingError("MWNetworkError TIMESTAMP_KEY parsingError")
            }
            if let targetIPInitalize = dict[MWConstantLocalNetwork.MessageKeys.TARGET_IP_KEY] as? String {
                targetIp_initalize = targetIPInitalize
            }else{
                throw MWNetworkError.parsingError("MWNetworkError TARGET_IP_KEY parsingError")
            }
            
            if let numberTriesInitalize = dict[MWConstantLocalNetwork.MessageKeys.NUMBER_TRIES] as? Int {
                number_tries = numberTriesInitalize
            }else{
                throw MWNetworkError.parsingError("MWNetworkError NUMBER_TRIES parsingError")
            }
         
            

            

        }else{
            throw MWNetworkError.parsingError("MWNetworkError BodyMessageIpModel parsingError")
        }
        self.sender = sender_initalize
        self.data = message
        self.timestamp = timestamp_initalize
        self.ipMessageType = IP_MESSAGE_TYPES(rawValue: messageType_initalize) ?? .None
        self.target = DEVICES_TYPES_ENUM(rawValue: target_initalize) ?? .KDS
        self.targetIp = targetIp_initalize
        self.noTries = number_tries
    }
    
    init(dict: Dictionary<String, Any>) {
        self.ipMessageType = IP_MESSAGE_TYPES(rawValue: dict[MWConstantLocalNetwork.MessageKeys.IP_MESSAGE_TYPE_KEY] as? Int ?? 0) ?? .None
        self.sender = dict[MWConstantLocalNetwork.MessageKeys.SENDER_KEY] as? [String:Any] ?? [:]
        self.data = dict[MWConstantLocalNetwork.MessageKeys.DATA_KEY] as? [[String:Any]] ?? []
        if let interval = dict[MWConstantLocalNetwork.MessageKeys.TIMESTAMP_KEY] as? TimeInterval {
            self.timestamp = Date(timeIntervalSince1970: interval)
        } else {
            self.timestamp = Date()
        }
        self.target = DEVICES_TYPES_ENUM(rawValue:dict[MWConstantLocalNetwork.MessageKeys.TARGET_KEY] as? String ?? "") ?? .KDS
        self.targetIp = dict[MWConstantLocalNetwork.MessageKeys.TARGET_IP_KEY] as? String ?? ""
        self.noTries = dict[MWConstantLocalNetwork.MessageKeys.NUMBER_TRIES] as? Int ?? 0

    }
    
    func toDict() -> Dictionary<String, Any> {
        var dict = Dictionary<String, Any>()
        dict[MWConstantLocalNetwork.MessageKeys.IP_MESSAGE_TYPE_KEY] = self.ipMessageType.rawValue
        dict[MWConstantLocalNetwork.MessageKeys.SENDER_KEY] = self.sender
        dict[MWConstantLocalNetwork.MessageKeys.DATA_KEY] = self.data
        dict[MWConstantLocalNetwork.MessageKeys.TIMESTAMP_KEY] = (Int) (self.timestamp.timeIntervalSince1970 * 1000)
        dict[MWConstantLocalNetwork.MessageKeys.TARGET_KEY] = self.target.rawValue
        dict[MWConstantLocalNetwork.MessageKeys.TARGET_IP_KEY] = self.targetIp
        dict[MWConstantLocalNetwork.MessageKeys.NUMBER_TRIES] = self.noTries

        return dict
    }
    
    func toJsonData() throws -> Data {
        return try JSONSerialization.data(withJSONObject: toDict(), options: .fragmentsAllowed)
    }
     func getIPData() -> Data?{
        do {
            var messageData = try self.toJsonData()
            messageData.append(GCDAsyncSocket.crlfData())
            return messageData
        } catch let error {
            SharedManager.shared.printLog("ERROR: \(error) - Couldn't serialize message \(self)")
        }
        return nil
    }
    func getTitleMessage() -> String{
        let orderNumber = self.data.map({ "#" + "\($0["sequence_number"] as? Int ?? 0)"}).joined(separator: ",")
        let timeAgoSinceDate = date_base_class.timeAgoSinceDate(self.timestamp, currentDate: Date(), numericDates: true)
        if let device = socket_device_class.getDevice(by: targetIp),let deviceName = device.name {
            if device.name != targetIp,  !deviceName.isEmpty {
            return orderNumber + " - " + deviceName + " - " + targetIp + " - \(timeAgoSinceDate)"
            }
        }
        return orderNumber + " - " + targetIp + " - \(timeAgoSinceDate)"
    }
    func getOrderUid() ->[String]?{
        return self.data.map({$0["uid"] as? String ?? ""})
    }
    func getIdentifier() -> String{
        return self.getOrderUid()?.compactMap({$0}).sorted().joined(separator: "-") ?? ""
    }
}
extension BodyMessageIpModel:Hashable{
    static func == (lhs: BodyMessageIpModel, rhs: BodyMessageIpModel) -> Bool {
        return lhs.getIdentifier() == rhs.getIdentifier()
    }
    func hash(into hasher: inout Hasher) {
        return hasher.combine(self.getIdentifier())
    }
}
