//
//  mw_info_ip_message.swift
//  pos
//
//  Created by M-Wageh on 20/10/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation
class MessageIpInfoModel{
    var posID:Int?
    var posCompanyID:Int?
    var deviceType:DEVICES_TYPES_ENUM = .SUB_CASHER
    var ipAddress:String?
    var macAddress:String?
    var currentSeq:Int?
    var isOpenSession:Bool?
    var isOnline:Bool?
    var isMaster:Bool?
    var posName:String?
    var userName:String?

//    var nextSeq:Int?
    init(){
        let posConfig = SharedManager.shared.posConfig()
        posID = posConfig.id
        posCompanyID = posConfig.company_id
        self.ipAddress = MWConstantLocalNetwork.posHostServiceName //getIPV4Address()
        self.macAddress = MWConstantLocalNetwork.getMacAddress()
        self.deviceType = DEVICES_TYPES_ENUM.currentDevicType()
        self.currentSeq = sequence_session_ip.shared.currentSeq
        let activeSession =  pos_session_class.getActiveSession()
        self.isOpenSession = activeSession != nil
        self.isOnline = MWLocalNetworking.sharedInstance.mwServerTCP.isPublished
        self.isMaster =  MWConstantLocalNetwork.posHostServiceName == MWConstantLocalNetwork.MessageKeys.MASTER_DEVICE_NAME
        self.posName = posConfig.name
        self.userName = SharedManager.shared.activeUser().name ?? ""

//        self.nextSeq = sequence_session_ip.shared.nextSeq

    }
    required init(dict: Dictionary<String, Any>)  {
        self.posCompanyID = dict[MWConstantLocalNetwork.MessageKeys.COMPANY_ID_KEY] as? Int
        self.posID = dict[MWConstantLocalNetwork.MessageKeys.POS_ID_KEY] as? Int
        self.deviceType = DEVICES_TYPES_ENUM (rawValue: dict[MWConstantLocalNetwork.MessageKeys.DEVICE_TYPE_KEY] as? String ?? "") ?? .KDS
        self.ipAddress = dict[MWConstantLocalNetwork.MessageKeys.IP_ADDRESS_KEY] as? String
        self.macAddress = dict[MWConstantLocalNetwork.MessageKeys.MAC_ADDRESS_KEY] as? String
        self.currentSeq = dict[MWConstantLocalNetwork.MessageKeys.CURRENT_SEQ_SESSION] as? Int
        self.isOpenSession = dict[MWConstantLocalNetwork.MessageKeys.IS_OPEN_SESSION] as? Bool
        self.isOnline = dict[MWConstantLocalNetwork.MessageKeys.IS_ONLINE] as? Bool
        self.isMaster = dict[MWConstantLocalNetwork.MessageKeys.IS_MASTER] as? Bool
        self.posName = dict[MWConstantLocalNetwork.MessageKeys.POS_NAME] as? String
        self.userName = dict[MWConstantLocalNetwork.MessageKeys.USER_NAME] as? String

//        self.nextSeq = dict[MWConstantLocalNetwork.MessageKeys.NEXT_SEQ_SESSION] as? Int

    }
    
    func toDict() -> Dictionary<String, Any> {
        var dict = Dictionary<String, Any>()
        dict[MWConstantLocalNetwork.MessageKeys.COMPANY_ID_KEY] = self.posCompanyID
        dict[MWConstantLocalNetwork.MessageKeys.POS_ID_KEY] = self.posID
        dict[MWConstantLocalNetwork.MessageKeys.DEVICE_TYPE_KEY] = deviceType.rawValue
        dict[MWConstantLocalNetwork.MessageKeys.IP_ADDRESS_KEY] = self.ipAddress
        dict[MWConstantLocalNetwork.MessageKeys.MAC_ADDRESS_KEY] = self.macAddress
        dict[MWConstantLocalNetwork.MessageKeys.CURRENT_SEQ_SESSION] = self.currentSeq
        dict[MWConstantLocalNetwork.MessageKeys.IS_OPEN_SESSION] = self.isOpenSession
        dict[MWConstantLocalNetwork.MessageKeys.IS_ONLINE] = self.isOnline
        dict[MWConstantLocalNetwork.MessageKeys.IS_MASTER] = self.isMaster
        dict[MWConstantLocalNetwork.MessageKeys.POS_NAME] = self.posName
        dict[MWConstantLocalNetwork.MessageKeys.USER_NAME] = self.userName

//        dict[MWConstantLocalNetwork.MessageKeys.NEXT_SEQ_SESSION] = self.nextSeq

        return dict
    }
    
    func toJsonData() throws -> Data {
        return try JSONSerialization.data(withJSONObject: toDict(), options: .fragmentsAllowed)
    }
    func unqieAddress()->String{
        return [ipAddress ?? "",macAddress ?? ""].joined(separator: "-")
    }
   
}

