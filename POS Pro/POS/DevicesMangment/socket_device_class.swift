//
//  socket_device_class.swift
//  pos
//
//  Created by M-Wageh on 22/08/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation

class socket_device_class:NSObject{
    var id : Int = 0
    var name:String?
    var device_ip:String?
    var device_mac:String?
    var type:DEVICES_TYPES_ENUM?
    var device_status:SOCKET_DEVICE_STATUS?
    var order_type_ids:[Int] = []
    var account_journal_ids:[Int] = []
    var product_categories_ids:[Int] = []
    var pingStatus:PING_STATUS = .NONE
    var dbClass:database_class?
    
    init(from dictionary:[String:Any]) {
        super.init()
        id = dictionary["id"] as? Int ?? 0
        device_ip = dictionary["device_ip"] as? String
        device_mac = dictionary["device_mac"] as? String
        name = dictionary["name"] as? String
        order_type_ids = dictionary["order_type_ids"] as? [Int] ?? []
        account_journal_ids = dictionary["account_journal_ids"] as? [Int] ?? []

        device_status = SOCKET_DEVICE_STATUS(rawValue:  dictionary["device_status"] as? Int ?? 0 )
        type = DEVICES_TYPES_ENUM(rawValue:  dictionary["type"] as? String ?? "" )
        pingStatus = PING_STATUS(rawValue:  dictionary["pingStatus"] as? Int ?? 0 ) ?? .NONE
        dbClass = database_class(table_name: "socket_device", dictionary: self.toDictionary(),id: id,id_key:"id")
        
    }
    func toDictionary(forSave:Bool = false) ->Dictionary<String, Any>{
        var dictionary = Dictionary<String, Any>()
        dictionary["id"] = id
        dictionary["name"] = name ?? ""
        dictionary["device_ip"] = device_ip ?? ""
        dictionary["device_mac"] = device_mac ?? ""
        dictionary["device_status"] = device_status?.rawValue ?? 0
        dictionary["order_type_ids"] = order_type_ids
        dictionary["account_journal_ids"] = account_journal_ids

        dictionary["type"] = type?.rawValue ?? 0
        if !forSave {
            dictionary["pingStatus"] = pingStatus.rawValue
        }

        return dictionary
    }
    static func find(by ip:String) -> Bool {
        let cls = socket_device_class(from: [:])
        let sql = """
                   SELECT  socket_device.* from socket_device where device_ip = '\(ip)'
                   """
        let arr = cls.dbClass!.get_rows(sql: sql)
      return cls.dbClass!.get_rows(sql: sql).count > 0
    }
    static func getAll() ->  [[String:Any]] {
        
        let cls = socket_device_class(from: [:])
        let sql = """
                   SELECT  socket_device.* from socket_device
                   """
        let arr = cls.dbClass!.get_rows(sql: sql)
        
        return arr.sorted{ ( $0["id"] as! Int) < ( $1["id"] as! Int) }
        
    }
    static func getActiveNotPrintersDevices() ->  [socket_device_class] {
        let devicesType:String = DEVICES_TYPES_ENUM.getTypesNotPrinters().map({$0.valueForSql()}).joined(separator: ", ")
        let cls = socket_device_class(from: [:])
        let sql = """
                   SELECT  socket_device.* from socket_device where device_status in (0,1) and type in (\(devicesType)) order by id desc
                   """
        let arr = cls.dbClass!.get_rows(sql: sql)
        
        return arr.map({socket_device_class(from: $0)})
        
    }
    static func getDevices(for types:[DEVICES_TYPES_ENUM],with statue:[SOCKET_DEVICE_STATUS]? = nil,excludeIP:String? = nil ) ->  [[String:Any]] {
        var statusQury = ""
        var excludeIPQury = ""

        if let statue = statue, statue.count > 0  {
            statusQury = "and device_status in (" + statue.map({"\($0.rawValue)"}).joined(separator: ",") + ")"
        }
        if let excludeIP = excludeIP  {
            excludeIPQury = "and device_ip not in ('" + excludeIP + "')"
        }
        let devicesType:String = types.map({$0.valueForSql()}).joined(separator: ", ")
        let cls = socket_device_class(from: [:])
        let sql = """
                   SELECT  socket_device.* from socket_device where type in (\(devicesType)) \(statusQury) \(excludeIPQury) order by id desc
                   """
        let arr = cls.dbClass!.get_rows(sql: sql)
        
        return arr
        
    }
    static func getDevice(by ip:String) ->  socket_device_class? {
        let cls = socket_device_class(from: [:])
        let sql = """
                   SELECT  socket_device.* from socket_device where device_ip = '\(ip)'
                   """
        let arr = cls.dbClass!.get_rows(sql: sql)
        if let deviceDic = arr.first {
            return socket_device_class(from:deviceDic )
        }
        return nil
    }
    func get_account_journal_ids() -> [Int]
    {
        return dbClass?.get_relations_rows(re_id1: self.id, re_table1_table2: "socket_device|account_journal") ?? []
        
    }
    func get_order_type_ids() -> [Int]
    {
        return dbClass?.get_relations_rows(re_id1: self.id, re_table1_table2: "socket_device|order_type_ids") ?? []
        
    }
    func get_product_categories_ids() -> [Int]
    {
        return dbClass?.get_relations_rows(re_id1: self.id, re_table1_table2: "socket_device|pos_category") ?? []

    }
    func save(startHost:Bool = true){
        dbClass?.dictionary = self.toDictionary(forSave: true)
        self.id =  dbClass!.save()
        relations_database_class(re_id1: self.id, re_id2: order_type_ids, re_table1_table2: "socket_device|order_type_ids").save()
        relations_database_class(re_id1: self.id, re_id2: product_categories_ids, re_table1_table2: "socket_device|pos_category").save()
        relations_database_class(re_id1: self.id, re_id2: account_journal_ids, re_table1_table2: "socket_device|account_journal").save()

        if startHost {
            DispatchQueue.main.async {
                MWLocalNetworking.sharedInstance.mwClientTCP.reSearch()
            }
        }
    }
    func updateMacAddress(with value:String?){
        if let value = value , !value.isEmpty , value != self.device_mac {
            _ =  database_class().runSqlStatament(sql:  "update socket_device  set device_mac  = '\(value)' where id = \(self.id)")
        }
    }
    func delete()
    {
        _ =   dbClass?.runSqlStatament(sql: "delete from socket_device where id = \(self.id)" )
        relations_database_class.delete(re_id1: self.id, re_table1_table2: "socket_device|order_type_ids")
//        MWLocalNetworking.sharedInstance.startAutoJoinOrHost()
        DispatchQueue.main.async {
            MWLocalNetworking.sharedInstance.mwClientTCP.reSearch()
        }
    }
    func getOrderNamesArray()->[String]{
        let order_type_ids = self.get_order_type_ids()
        let order_types =  delivery_type_class.get(ids: order_type_ids)
        var order_type_names_array : [String] = []
        for orderType in order_types
        {
            if let key_name = orderType["display_name"]  as? String {
                order_type_names_array.append(key_name)
            }
        }
        return order_type_names_array
    }
    
    func getPaymentMethodsArray(ids:[Int]) -> [String] {
        let data = account_journal_class.get_bank_account(ids: ids) ?? []
        let stringArray = data.map { $0.display_name }
        return stringArray
    }
    func getCategoriesNamesArray()->[String]{
       let cats_ids = self.get_product_categories_ids()
      let cats =  pos_category_class.get(ids: cats_ids)
       var cats_names_array : [String] = []
       for c in cats
       {
           if let key_name = c["name"]  as? String {
               cats_names_array.append(key_name)
           }
       }
       if cats_names_array.count == 0 {
           if id == 0 {
               cats_names_array.append("Master")
           }
       }
       return cats_names_array
   }
    static func == (lhs: socket_device_class, rhs: socket_device_class) -> Bool {
        return lhs.id == rhs.id
    }
    func checkService(_ hostName:String) -> Bool{
        return hostName == (self.device_ip ?? "" )
       // return (hostName.contains(self.device_ip ?? "" ) || hostName.contains(self.device_mac ?? "" )) && !hostName.isEmpty
    }
    static func saveMasterSockectDevice(status:Bool){
        if !SharedManager.shared.mwIPnetwork{
            return
        }
        if SharedManager.shared.posConfig().isMasterTCP(){
            return
        }
        let allTargetDevices = socket_device_class.getDevices(for: [.MASTER],with: [.NONE, .ACTIVE,.NOT_ACTIVE]).map({socket_device_class(from: $0)})
        if allTargetDevices.count > 0 {
            allTargetDevices.forEach { device in
                device.device_status = status ?  .ACTIVE : .NOT_ACTIVE
                device.save(startHost: false)
            }
        }else{
        var dictionary = Dictionary<String, Any>()
//        dictionary["id"] = -3
        dictionary["name"] = "MW-POS-Master"
        dictionary["device_ip"] = MWConstantLocalNetwork.MessageKeys.MASTER_DEVICE_NAME
        dictionary["device_mac"] = MWConstantLocalNetwork.MessageKeys.MASTER_DEVICE_NAME
        dictionary["device_status"] = status ? 1 : 2
        dictionary["order_type_ids"] = []
        dictionary["type"] = DEVICES_TYPES_ENUM.MASTER.rawValue
        dictionary["pingStatus"] = PING_STATUS.NONE.rawValue
        socket_device_class(from:dictionary ).save(startHost: false)
        }
    }
    static func isContainte() ->  Bool {
        if SharedManager.shared.posConfig().isMasterTCP() {
            let count:[String:Any] = database_class(connect: .database).get_row(sql: "select count(*) as cnt from socket_device ") ?? [:]
            return (count["cnt"] as? Int ?? 0) > 0
        }
        return true
        
    }
    static func getSocketDevices(for types:[DEVICES_TYPES_ENUM],with statue:[SOCKET_DEVICE_STATUS]? = nil,excludeIP:String? = nil ) ->  [socket_device_class] {
            var statusQury = ""
            var excludeIPQury = ""

            if let statue = statue, statue.count > 0  {
                statusQury = "and device_status in (" + statue.map({"\($0.rawValue)"}).joined(separator: ",") + ")"
            }
            if let excludeIP = excludeIP  {
                excludeIPQury = "and device_ip not in ('" + excludeIP + "')"
            }
            let devicesType:String = types.map({$0.valueForSql()}).joined(separator: ", ")
            let cls = socket_device_class(from: [:])
            let sql = """
                       SELECT  socket_device.* from socket_device where type in (\(devicesType)) \(statusQury) \(excludeIPQury) order by id desc
                       """
            let arr = cls.dbClass!.get_rows(sql: sql)
            
            return arr.compactMap({socket_device_class(from: $0)})
            
        }
}

