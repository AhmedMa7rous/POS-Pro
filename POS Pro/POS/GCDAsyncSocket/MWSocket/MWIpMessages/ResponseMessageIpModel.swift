//
//  ResponseMessageIpModel.swift
//  pos
//
//  Created by M-Wageh on 09/09/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation
enum CODE_RESPONSE:Int{
    case success = 0 ,fail
}
class ResponseMessageIpModel:MWIPMessageProtocol{
    var target:DEVICES_TYPES_ENUM
    let code:CODE_RESPONSE
    let reciever:  [String:Any]
    let message: String
    let timestamp: Date
    let seq: Int
    let uid: String
    let closedByMaster: Bool
//    var res_void_pending_uid:[String]?
//    var res_closed_pending_uid:[String]?
//    var res_sync_pending_uid:[String]?
    
    init(message:String,code:CODE_RESPONSE,target:DEVICES_TYPES_ENUM,responeNewOrder:ResponeNewOrderModel?) {
        self.reciever = MessageIpInfoModel().toDict()
        self.message = message
        self.timestamp = Date()
        self.code = code
        self.target = target
        self.seq = responeNewOrder?.seq ?? MWConstantLocalNetwork.defaultSequence
        self.uid = responeNewOrder?.uid ?? ""
        self.closedByMaster = responeNewOrder?.is_closed_by_master ?? false
//        res_void_pending_uid = responeNewOrder?.res_void_pending_uid
//        res_closed_pending_uid = responeNewOrder?.res_closed_pending_uid
//        res_sync_pending_uid = responeNewOrder?.res_sync_pending_uid


    }
    
    required init(jsonData: Data) throws {
        var reciever_initalize:[String:Any] = [:]
        var message_initalize:String = ""
        var timestamp_initalize = Date()
        var code_initalize:CODE_RESPONSE  = .success
        var target_initalize  = ""
        var sequence_initalize  = MWConstantLocalNetwork.defaultSequence
        var uid_initalize  = ""
        var close_by_master_initalize  = false
//        var res_void_pending_uid_initalize:[String] = []
//        var res_closed_pending_uid_initalize:[String] = []
//        var res_sync_pending_uid_initalize:[String] = []
/*
        if let dict = try JSONSerialization.jsonObject(with: jsonData, options: .mutableLeaves) as? NSDictionary {
            reciever_initalize = dict[MWConstantLocalNetwork.MessageKeys.RECIEVER_KEY] as? [String:Any] ?? [:]
            code_initalize = CODE_RESPONSE(rawValue:dict[MWConstantLocalNetwork.MessageKeys.CODE_KEY] as? Int ?? 0) ?? .success
            message_initalize = dict[MWConstantLocalNetwork.MessageKeys.MESSAGE_KEY] as? String ?? ""
            target_initalize = dict[MWConstantLocalNetwork.MessageKeys.TARGET_KEY] as? String ?? ""
            if let interval = dict[MWConstantLocalNetwork.MessageKeys.TIMESTAMP_KEY] as? TimeInterval {
                timestamp_initalize = Date(timeIntervalSince1970: interval / 1000)
            }
        }*/
        if let dict = try JSONSerialization.jsonObject(with: jsonData, options: .mutableLeaves) as? NSDictionary {
            if let recieverInitalize = dict[MWConstantLocalNetwork.MessageKeys.RECIEVER_KEY] as? [String:Any] {
                reciever_initalize = recieverInitalize
            }else{
                throw MWNetworkError.parsingError("MWNetworkError RECIEVER_KEY parsingError")
            }
            if let codeStatus = dict[MWConstantLocalNetwork.MessageKeys.CODE_KEY] as? Int {
                code_initalize = CODE_RESPONSE(rawValue:codeStatus) ?? .success

            }else{
                throw MWNetworkError.parsingError("MWNetworkError CODE_KEY parsingError")
            }
            if let messageInitalize = dict[MWConstantLocalNetwork.MessageKeys.MESSAGE_KEY] as? String {
                message_initalize = messageInitalize

            }else{
                throw MWNetworkError.parsingError("MWNetworkError MESSAGE_KEY parsingError")
            }
            if let targetInitalize = dict[MWConstantLocalNetwork.MessageKeys.TARGET_KEY] as? String {
                target_initalize = targetInitalize

            }else{
                throw MWNetworkError.parsingError("MWNetworkError TARGET_KEY parsingError")
            }
            if let interval = dict[MWConstantLocalNetwork.MessageKeys.TIMESTAMP_KEY] as? TimeInterval {
                 timestamp_initalize = Date(timeIntervalSince1970: interval / 1000)
            }else{
                throw MWNetworkError.parsingError("MWNetworkError TIMESTAMP_KEY parsingError")
            }
            if let sequenceInitalize = dict[MWConstantLocalNetwork.MessageKeys.SEQUENCE_RESPONSE] as? Int {
                sequence_initalize = sequenceInitalize

            }
            if let uidInitalize = dict[MWConstantLocalNetwork.MessageKeys.UID_KEY] as? String {
                uid_initalize = uidInitalize

            }
            if let closedInitalize = dict[MWConstantLocalNetwork.MessageKeys.closed_by_master] as? Bool {
                close_by_master_initalize = closedInitalize

            }
            
//            if let res_void_pending_uid_ini = dict["res_void_pending_uid"] as? [String] {
//                res_void_pending_uid_initalize = res_void_pending_uid_ini
//
//            }
//            if let res_closed_pending_uid_initalize = dict["res_closed_pending_uid"] as? [String] {
//                res_void_pending_uid_initalize = res_closed_pending_uid_initalize
//
//            }
//            if let res_sync_pending_uid_ini = dict["res_sync_pending_uid"] as? [String] {
//                res_sync_pending_uid_initalize = res_sync_pending_uid_ini
//
//            }
        }else{
            throw MWNetworkError.parsingError("MWNetworkError ResponseMessageIpModel parsingError")
        }
        self.reciever = reciever_initalize
        self.message = message_initalize
        self.timestamp = timestamp_initalize
        self.code = code_initalize
        self.target = DEVICES_TYPES_ENUM(rawValue: target_initalize) ?? .KDS
        self.seq = sequence_initalize
        self.uid = uid_initalize
        self.closedByMaster = close_by_master_initalize
//        res_void_pending_uid = res_void_pending_uid_initalize
//        res_closed_pending_uid = res_closed_pending_uid_initalize
//        res_sync_pending_uid = res_sync_pending_uid_initalize


    }
    
    init(dict: Dictionary<String, Any>) {
        self.reciever = dict[MWConstantLocalNetwork.MessageKeys.RECIEVER_KEY] as? [String:Any] ?? [:]
        self.message = dict[MWConstantLocalNetwork.MessageKeys.MESSAGE_KEY] as? String ?? ""
        if let interval = dict[MWConstantLocalNetwork.MessageKeys.TIMESTAMP_KEY] as? TimeInterval {
            self.timestamp = Date(timeIntervalSince1970: interval)
        } else {
            self.timestamp = Date()
        }
        self.code = CODE_RESPONSE(rawValue:dict[MWConstantLocalNetwork.MessageKeys.DATA_KEY] as? Int ?? 0) ?? .success
        self.target = DEVICES_TYPES_ENUM(rawValue:dict[MWConstantLocalNetwork.MessageKeys.TARGET_KEY] as? String ?? "") ?? .KDS
        self.seq = dict[MWConstantLocalNetwork.MessageKeys.SEQUENCE_RESPONSE] as? Int ?? MWConstantLocalNetwork.defaultSequence
        self.uid = dict[MWConstantLocalNetwork.MessageKeys.UID_KEY] as? String ?? ""
        self.closedByMaster = dict[MWConstantLocalNetwork.MessageKeys.closed_by_master] as? Bool ?? false
//        self.res_void_pending_uid = dict["res_void_pending_uid"] as? [String]
//        self.res_closed_pending_uid = dict["res_closed_pending_uid"] as? [String]
//        self.res_sync_pending_uid = dict["res_sync_pending_uid"] as? [String]

    }
    
    func toDict() -> Dictionary<String, Any> {
        var dict = Dictionary<String, Any>()
        dict[MWConstantLocalNetwork.MessageKeys.RECIEVER_KEY] = self.reciever
        dict[MWConstantLocalNetwork.MessageKeys.MESSAGE_KEY] = self.message
        dict[MWConstantLocalNetwork.MessageKeys.TIMESTAMP_KEY] = (Int) (self.timestamp.timeIntervalSince1970 * 1000)
        dict[MWConstantLocalNetwork.MessageKeys.CODE_KEY] = self.code.rawValue
        dict[MWConstantLocalNetwork.MessageKeys.TARGET_KEY] = self.target.rawValue
        dict[MWConstantLocalNetwork.MessageKeys.SEQUENCE_RESPONSE] = self.seq
        dict[MWConstantLocalNetwork.MessageKeys.UID_KEY] = self.uid
        dict[MWConstantLocalNetwork.MessageKeys.closed_by_master] = self.closedByMaster
//        dict["res_void_pending_uid"] =  self.res_void_pending_uid
//        dict["res_closed_pending_uid"] = self.res_closed_pending_uid
//        dict["res_sync_pending_uid"] = self.res_sync_pending_uid

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
}
