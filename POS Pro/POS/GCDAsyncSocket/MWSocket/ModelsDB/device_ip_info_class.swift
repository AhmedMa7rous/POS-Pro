//
//  device_ip_info_class.swift
//  pos
//
//  Created by M-Wageh on 21/03/2023.
//  Copyright © 2023 khaled. All rights reserved.
//

import Foundation
class device_ip_info_class:NSObject{
    var id:Int = 0
    var sockect_device_id:Int?
    var order_sequces:Int?
    var is_open_session:Bool?
    var is_online:Bool?
    var pos_name:String?
    var user_name:String?

    var dbClass:database_class?
    override init() {
        dbClass = database_class(connect: .meesage_ip_log)
    }
    init(fromDictionary dictionary: [String:Any]){
        super.init()
        
        id = dictionary["id"] as? Int ?? 0
        sockect_device_id = dictionary["sockect_device_id"] as? Int ?? 0
        order_sequces = dictionary["order_sequces"] as? Int ?? 0
        is_open_session = dictionary["is_open_session"] as? Bool ?? false
        is_online = dictionary["is_online"] as? Bool ?? false
        pos_name = dictionary["pos_name"] as? String ?? ""
        user_name = dictionary["user_name"] as? String ?? ""

        dbClass = database_class(table_name: "device_ip_info", dictionary: self.toDictionary(),id: id,id_key:"id",connect: .meesage_ip_log)
    }
    convenience init(from sender:MessageIpInfoModel) {
        self.init()
        self.id =  0
        self.sockect_device_id =  0
        self.order_sequces = sender.currentSeq
        self.is_open_session = sender.isOpenSession
        self.is_online = sender.isOnline
        self.pos_name = sender.posName
        self.user_name = sender.userName

        self.dbClass = database_class(table_name: "device_ip_info", dictionary: self.toDictionary(),id: id,id_key:"id",connect: .meesage_ip_log)

    }
    
    
    func toDictionary() -> [String:Any]
    {
        var dictionary:[String:Any] = [:]
        dictionary["id"] = id

        dictionary["sockect_device_id"] = sockect_device_id
        dictionary["order_sequces"] = order_sequces
        dictionary["is_open_session"] = is_open_session
        dictionary["is_online"] = is_online
        dictionary["pos_name"] = pos_name
        dictionary["user_name"] = user_name

        return dictionary
    }
    func save()
    {
        if !(self.pos_name ?? "").isEmpty{
            dbClass?.dictionary = self.toDictionary()
            self.id =  dbClass!.save()
        }
    }
    func updateLastDate(){
        let sql = """
        update device_ip_info set updated_at = datetime('now') where id = \(self.id)
        """
        _ =  database_class(connect: .meesage_ip_log).runSqlStatament(sql:  sql)        
    
    }
    func updateIfExist() -> (isExist:Bool,oldOnline:Bool) {
        if let existDeviceDic = database_class(connect: .meesage_ip_log).get_row(sql: "select * from device_ip_info where sockect_device_id =\(sockect_device_id ?? 0)" )
        {
            let existDevice = device_ip_info_class(fromDictionary: existDeviceDic)
            let previousStatus = existDevice.is_online ?? false
            self.id = existDevice.id
            existDevice.order_sequces = self.order_sequces
            existDevice.is_open_session = self.is_open_session
            existDevice.is_online = self.is_online
            existDevice.pos_name = self.pos_name
            existDevice.user_name = self.user_name
            existDevice.save()
            return (true,previousStatus)
        }
        return (false,false)
    }
    static func getCurrentInfo() -> [String:Any]{
        let device = device_ip_info_class(fromDictionary: [:])
        device.is_online = true
        device.is_open_session = pos_session_class.getActiveSession() != nil
        device.order_sequces = sequence_session_ip.shared.currentSeq
        return device.toDictionary()
    }
    static func resetDevicesInfo(){
        let sql = """
        update device_ip_info set is_online = 0, is_open_session = 0,order_sequces = -1 , updated_at = datetime('now')
        """
        _ =  database_class(connect: .meesage_ip_log).runSqlStatament(sql:  sql)
    }
    static func setMasterCloseSession(){
        let sql = """
        update device_ip_info set is_open_session = 0, updated_at = datetime('now')
        """
        _ =  database_class(connect: .meesage_ip_log).runSqlStatament(sql:  sql)
    }
    static func setOffline(for ip:String,is_online:Int = 0,checkMaster:Bool = true){
        if let socketDevice = socket_device_class.getDevice(by: ip){
            if let existDeviceDic = database_class(connect: .meesage_ip_log).get_row(sql: "select * from device_ip_info where sockect_device_id =\(socketDevice.id)" )
            {
                let sql = """
                update device_ip_info set is_online = \(is_online), updated_at = datetime('now') where sockect_device_id = \(socketDevice.id)
                """
                _ =  database_class(connect: .meesage_ip_log).runSqlStatament(sql:  sql)
            }else{
               let newDevice = device_ip_info_class(fromDictionary: [:])
                newDevice.is_online = is_online != 0
                newDevice.sockect_device_id = socketDevice.id
                newDevice.save()
                
            }
            if checkMaster{
                if ip == MWConstantLocalNetwork.MessageKeys.MASTER_DEVICE_NAME{
                    MWMasterIP.shared.postMasterIpDeviceOffline()
                }
            }
        
        }
       
    }
    static func getMasterStatus() -> device_ip_info_class? {
        if let existDeviceDic = database_class(connect: .meesage_ip_log).get_row(sql: "select * from device_ip_info " )
        {
            return device_ip_info_class(fromDictionary: existDeviceDic)
        }
        return nil
    }
}
