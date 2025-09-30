//
//  scrapReasonClass.swift
//  pos
//
//  Created by Khaled on 4/17/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import UIKit
enum TEST_PRINTER_Status:Int {
    case NONE = 0 , FAIL,SUCCESS
}
class restaurant_printer_class: NSObject {
    var dbClass:database_class?
    
    var id : Int = 0
    
    var display_name : String = ""
    var name : String = ""
    var proxy_ip : String = ""
    var epson_printer_ip : String = ""

    var printer_type : String = ""
    var printer_ip : String = ""
    var company_id : Int = 0
    var config_ids:[Int] = []

    var connectionType: ConnectionTypes?
    
    var __last_update: String = ""
  
    var product_categories_ids:[Int] = []
    var order_type_ids:[Int] = []
    var test_printer_status:Int = TEST_PRINTER_Status.NONE.rawValue
    var brand:String?
    var model:String?
    var type:DEVICES_TYPES_ENUM = DEVICES_TYPES_ENUM.KDS_PRINTER
    var is_active:Bool = true
    var server_id:Int?
    var available_in_pos:Int?
    var mac_address:String?
    var is_ble_con_2:Bool?

    init(fromDictionary dictionary: [String:Any]){
        super.init()
        
        id = dictionary["id"] as? Int ?? 0
        
        
        
        display_name = dictionary["display_name"] as? String ?? ""
        name = dictionary["name"] as? String ?? ""
        __last_update = dictionary["__last_update"] as? String ?? ""
        proxy_ip = dictionary["printer_ip"] as? String ?? ""
        epson_printer_ip = dictionary["epson_printer_ip"] as? String ?? ""
//        printer_type = dictionary["printer_type"] as? String ?? ""
        printer_ip = dictionary["printer_ip"] as? String ?? ""
 
        company_id = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "company_id", keyOfDatabase: "company_id",Index: 0) as? Int ?? 0

        config_ids = dictionary["config_ids"] as? [Int] ?? []
        product_categories_ids = dictionary["product_categories_ids"] as? [Int] ?? []
        order_type_ids = dictionary["order_type_ids"] as? [Int] ?? []
        test_printer_status = dictionary["test_printer_status"] as? Int ?? 0
        brand = dictionary["brand"] as? String ?? "EPSON"
        model = dictionary["model"] as? String ?? "TM_T20"
        mac_address = dictionary["mac_address"] as? String ?? ""
        type =  (dictionary["type"] as? String ?? "").lowercased().contains("pos") ? DEVICES_TYPES_ENUM.POS_PRINTER : DEVICES_TYPES_ENUM.KDS_PRINTER
        is_active = dictionary["is_active"] as? Bool ?? true
        server_id = dictionary["server_id"] as? Int ?? 0
        if let connectionTypeEnum = (dictionary["connection_type"] as? String ), !connectionTypeEnum.isEmpty{
            
            connectionType = ConnectionTypes(rawValue: connectionTypeEnum.uppercased())

        }else{
            if let connectionTypeEnum = (dictionary["connectionType"] as? String ), !connectionTypeEnum.isEmpty{

                connectionType = ConnectionTypes(rawValue: connectionTypeEnum.uppercased())

            }else{
                connectionType = ConnectionTypes.WIFI
            }
        }
       
    
        if let available_in_pos_array = dictionary["available_in_pos"] as? [Any] ,
            let available_in_pos_id = available_in_pos_array.first as? Int {
            available_in_pos = available_in_pos_id

        }else{
            available_in_pos = dictionary["available_in_pos"] as? Int ?? 0

        }
        is_ble_con_2 = dictionary["is_ble_con_2"] as? Bool ?? false


        dbClass = database_class(table_name: "restaurant_printer", dictionary: self.toDictionary(),id: id,id_key:"id")

        
    }
    
    
    func toDictionary() -> [String:Any]
    {
        var dictionary:[String:Any] = [:]
        
        dictionary["id"] = id
        dictionary["display_name"] = display_name
        dictionary["name"] = name
        dictionary["__last_update"] = __last_update
        dictionary["proxy_ip"] = printer_ip
        dictionary["epson_printer_ip"] = epson_printer_ip
        dictionary["test_printer_status"] = test_printer_status

//        dictionary["printer_type"] = printer_type
        dictionary["printer_ip"] = printer_ip
        dictionary["company_id"] = company_id

        dictionary["brand"] = brand
        dictionary["model"] = model
        dictionary["type"] = type.rawValue

        dictionary["is_active"] = is_active
        dictionary["server_id"] = server_id
        dictionary["available_in_pos"] = available_in_pos
        dictionary["mac_address"] = mac_address
        dictionary["is_ble_con_2"] = is_ble_con_2

        dictionary["connectionType"] = connectionType?.rawValue ?? "WIFI"
        
        return dictionary
    }
    
    
    func save(temp:Bool = false, is_update:Bool = false)
    {
        dbClass?.dictionary = self.toDictionary()
        dbClass?.id = self.id
        
        if temp
        {
            dbClass!.table_name =  "temp_" + dbClass!.table_name
        }
        
        let last_id =  dbClass!.save()
        if self.id == 0 {
            self.id = last_id
        }
        if !is_update {
        relations_database_class(re_id1: self.id, re_id2: product_categories_ids, re_table1_table2: "restaurant_printer|pos_category").save()
        relations_database_class(re_id1: self.id, re_id2: order_type_ids, re_table1_table2: "restaurant_printer|order_type_ids").save()
        relations_database_class(re_id1: self.id, re_id2: config_ids, re_table1_table2: "restaurant_printer|config_ids").save()

        }

        
    }
    
    func delete()
    {
        _ =   dbClass?.runSqlStatament(sql: "delete from restaurant_printer where id = \(self.id)" )
        relations_database_class.delete(re_id1: self.id, re_table1_table2: "restaurant_printer|pos_category")
        relations_database_class.delete(re_id1: self.id, re_table1_table2: "restaurant_printer|order_type_ids")
        relations_database_class.delete(re_id1: self.id, re_table1_table2: "restaurant_printer|config_ids")

    }
    
    static func reset(temp:Bool = false)
    {
        let cls = restaurant_printer_class(fromDictionary: [:])
        
        var table = cls.dbClass!.table_name
         if temp
         {
            table =   "temp_" + cls.dbClass!.table_name
         }
        
        
      _ =  cls.dbClass?.runSqlStatament(sql: "delete from \(table)")
        
        _ =  database_class().runSqlStatament(sql: "delete from relations where re_table1_table2='restaurant_printer|pos_category' ")
        _ =  database_class().runSqlStatament(sql: "delete from relations where re_table1_table2='restaurant_printer|order_type_ids' ")
        _ =  database_class().runSqlStatament(sql: "delete from relations where re_table1_table2='restaurant_printer|config_ids' ")

    }
    static func saveAll(arr:[[String:Any]],temp:Bool = false)
    {
        for item in arr
        {
            let pos = restaurant_printer_class(fromDictionary: item)
            pos.server_id = pos.id
            pos.dbClass?.insertId = true
            pos.save(temp: temp)
        }
    }
    
    static func getAll(_ condation:String = "") ->  [[String:Any]] {
        
        let cls = restaurant_printer_class(fromDictionary: [:])
//        let arr  = cls.dbClass!.get_rows(whereSql: "")
        var sql = """
                SELECT  restaurant_printer.* from restaurant_printer
                inner join
                (select * from relations WHERE  re_table1_table2  = 'restaurant_printer|config_ids' and re_id2 = \(SharedManager.shared.posConfig().id) ) as config_ids
                on restaurant_printer.id  = config_ids.re_id1
                """
        if !condation.isEmpty {
            sql += " where \(condation)"
        }
        if SharedManager.shared.appSetting().enable_support_multi_printer_brands {
            sql = """
                   SELECT  restaurant_printer.* from restaurant_printer where available_in_pos = \(SharedManager.shared.posConfig().id)
                   """
            
            if !condation.isEmpty {
                sql += " and \(condation)"
            }

        }
        let arr = cls.dbClass!.get_rows(sql: sql)
        
        return arr.sorted{ ( $0["id"] as! Int) < ( $1["id"] as! Int) }
        
    }
    static func getAllNotSync() ->  [[String:Any]] {
        
        let cls = restaurant_printer_class(fromDictionary: [:])
//        let arr  = cls.dbClass!.get_rows(whereSql: "")
        var sql = """
                SELECT  restaurant_printer.* from restaurant_printer
                inner join
                (select * from relations WHERE  re_table1_table2  = 'restaurant_printer|config_ids' and re_id2 = \(SharedManager.shared.posConfig().id) ) as config_ids
                on restaurant_printer.id  = config_ids.re_id1
                where server_id = 0
                """
        if SharedManager.shared.appSetting().enable_support_multi_printer_brands {
            sql = """
                   SELECT  restaurant_printer.* from restaurant_printer
                   where available_in_pos = \(SharedManager.shared.posConfig().id)
                   and server_id = 0
                   """
        }
        let arr = cls.dbClass!.get_rows(sql: sql)
        
        return arr.sorted{ ( $0["id"] as! Int) < ( $1["id"] as! Int) }
        
    }
    
    
    static  func get(ip:String) -> restaurant_printer_class? {
        
        var cls = restaurant_printer_class(fromDictionary: [:])
        let row:[String:Any]?   = cls.dbClass!.get_row(whereSql: "where printer_ip = '\(ip)'") ?? [:]
        if row != nil
        {

            cls = restaurant_printer_class(fromDictionary: row!)
            return cls

        }
        
        
        return nil
        
    }
    static func get(printer_type:DEVICES_TYPES_ENUM) -> [restaurant_printer_class] {
        var result:[restaurant_printer_class] = []
        let cls = restaurant_printer_class(fromDictionary: [:])
        let rows   = cls.dbClass!.get_rows(whereSql: "where type = '\(printer_type.rawValue)' and is_active = 1")
        rows.forEach({ row in
                result.append(restaurant_printer_class(fromDictionary: row))
            })
            return result
        
    }
    
    
    func get_product_categories_ids() -> [Int]
    {
        return dbClass?.get_relations_rows(re_id1: self.id, re_table1_table2: "restaurant_printer|pos_category") ?? []

    }
    
    func get_order_type_ids() -> [Int]
    {
        return dbClass?.get_relations_rows(re_id1: self.id, re_table1_table2: "restaurant_printer|order_type_ids") ?? []

    }
    func get_config_ids() -> [Int]
    {
        return dbClass?.get_relations_rows(re_id1: self.id, re_table1_table2: "restaurant_printer|config_ids") ?? []

    }
    
    static  func update(with status :TEST_PRINTER_Status , for id:Int){
        if id == 0 {
            cash_data_class.set(key: "test_printer_status", value: "\(status.rawValue)")
            return
        }
        var cls = restaurant_printer_class(fromDictionary: [:])
        let row:[String:Any]?   = cls.dbClass!.get_row(whereSql: "where id = '\(id)'") ?? [:]
        if row != nil
        {
            cls = restaurant_printer_class(fromDictionary: row!)
            cls.test_printer_status = status.rawValue
            cls.save(is_update:true)
        }
    }
    static  func getTestStatus(for id:Int) -> TEST_PRINTER_Status{
        var cls = restaurant_printer_class(fromDictionary: [:])
        let row:[String:Any]?   = cls.dbClass!.get_row(whereSql: "where id = '\(id)'") ?? [:]
        if row != nil
        {
            cls = restaurant_printer_class(fromDictionary: row!)
            return TEST_PRINTER_Status(rawValue: cls.test_printer_status) ?? .NONE
        }
        return .NONE
    }
    static func getCategoriesNames(for id:Int)->[String]{
        var cls = restaurant_printer_class(fromDictionary: [:])
        let row:[String:Any]?   = cls.dbClass!.get_row(whereSql: "where id = '\(id)'") ?? [:]
        if row != nil
        {
            cls = restaurant_printer_class(fromDictionary: row!)
            return cls.getCategoriesNamesArray()
        }
        return []
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
    func getPosNamesArray()->[String]{
       let config_ids = self.get_config_ids()
      let config_pos =  pos_config_class.get(ids: config_ids)
       var config_pos_names_array : [String] = []
       for pos in config_pos
       {
           if let key_name = pos["name"]  as? String {
               config_pos_names_array.append(key_name)
           }
       }
       return config_pos_names_array
   }
    func haveFailReport() -> Bool{
       return printer_error_class.haveRecord(for: self.id)
    }
    func getMacAddressFromIp()->String{
        if !self.printer_ip.isEmpty{
        return "" //PrinterMacAddressInteractor.shared.findMacAddress(for: self.printer_ip) ?? ""
        }
        return ""
    }
    func setMacAddress(){
        self.mac_address = getMacAddressFromIp()
    }
    static func setAvailableInPos() {
        
        let cls = restaurant_printer_class(fromDictionary: [:])
        let  sql = """
                    UPDATE restaurant_printer SET available_in_pos = \(SharedManager.shared.posConfig().id)
                   """
        
        
        let suceess =  cls.dbClass!.runSqlStatament(sql: sql)
        SharedManager.shared.printLog("suceess==\(suceess)")
        
    }
    func getBleConString()->String{
        if self.is_ble_con_2 ?? false{
            return "1"
        }
        return "0"
    }
    func sortNumber()->Int{
       return self.type == .POS_PRINTER ? 1 : 0
    }
}
