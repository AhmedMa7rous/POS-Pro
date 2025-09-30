//
//  app_settings.swift
//  pos
//
//  Created by  Mahmoud Wageh on 4/19/21.
//  Copyright © 2021 khaled. All rights reserved.
//

import Foundation


class ios_settings:NSObject
{
    var dbClass:database_class?
    var name: String = ""
    var value: Any?
    var option: String?
    var default_value: Any?
    var type: TYPE_SETTINGS?
    var scope: SCOPE_SETTINGS?
    var version: String?
    var pos_id: String?
    var id:Int = 0
    
    init(
        name: String,
        value: Any?,
        defaultValue: Any,
        option: String,
        type: TYPE_SETTINGS,
        scope: SCOPE_SETTINGS,
        version: String,
        posID: Int
    )  {
        super.init()

        self.name =  name
        if let value = value {
            self.value = "\(value)"
        }else{
            self.value = "\(defaultValue)"
        }
        self.default_value = defaultValue
        self.option = option
        self.type = type
        self.scope =  scope
        self.version =  version
        self.pos_id = posID == -1 ? "None" : "\(posID)"
        self.id = SETTING_KEY(rawValue:name)?.getID() ?? 0
        dbClass = database_class(table_name: "ios_settings",
                                 dictionary: self.toDictionary(),
                                 id: id,
                                 id_key:"id")
        
    }
   
    init(fromDictionary dictionary: [String:Any]){
        super.init()
        name = dictionary["name"] as? String ?? ""
        if let value =  dictionary["value"] as? String{
            self.value = casteTypeFor(value)
        }
        if let defaultValue =  dictionary["default_value"] as? String {
            if  self.value == nil {
                self.value = casteTypeFor(defaultValue)
            }
            self.default_value = casteTypeFor(defaultValue)
        }
        
       
        option = dictionary["option"] as? String ?? ""
        scope = SCOPE_SETTINGS(rawValue: dictionary["scope"] as? String ?? "") ?? scope
        version = dictionary["version"] as? String ?? ""
        pos_id = dictionary["pos_id"] as? String ?? "None"
        type = TYPE_SETTINGS(rawValue: dictionary["type"] as? String ?? "") ??  type
        id =  dictionary["id"] as? Int ?? 0
        dbClass = database_class(table_name: "ios_settings",
                                 dictionary: self.toDictionary(),
                                 id:id,
                                 id_key:"id")
        
    }
    private func casteTypeFor(_ value:String) -> Any {
        if  value.lowercased() == "false"{
            return false
        }
        if  value.lowercased() == "true"{
            return true
        }
        if  let intValue = Int(value){
            return intValue
        }
        if  let doubleValue = Double(value){
            return doubleValue
        }
        return value
        
    }
    
    func toDictionary() -> [String:Any]
    {
        var dictionary:[String:Any] = [:]
        if let id = SETTING_KEY(rawValue:name) {
            dictionary["id"] = String(describing:id.getID())
        }
        dictionary["name"] = name
        if let value = self.value {
            dictionary["value"] =  value
        }
        if let defaultValue = self.default_value {
            if  self.value == nil {
                dictionary["default_value"] =  value
            }
            dictionary["default_value"] =  defaultValue
        }
        
        
        dictionary["option"] = option
        dictionary["scope"] = scope?.rawValue ?? ""
        dictionary["version"] = version
        if pos_id != "None" {
            dictionary["pos_id"] = pos_id
        }else{
            dictionary["pos_id"] = ""

        }
        dictionary["type"] = type?.rawValue ?? ""
        return dictionary
    }
    
    
    func save()
    {
        dbClass?.dictionary = self.toDictionary()
        dbClass?.id = self.id
        _ =  dbClass!.save()
        
    }
    
    static func saveAll(arr:[[String:Any]])
    {
        for item in arr
        {
            let pos = ios_settings(fromDictionary: item)
            pos.dbClass?.insertId = true
            pos.save()
        }
    }
    
    static func getAll() ->  [[String:Any]] {
        let cls = ios_settings(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(whereSql: "")
        return arr
        
    }
    static func getAllObject() ->  [ios_settings] {
        let cls = ios_settings(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(whereSql: "")
        let objectArray:[ios_settings] = arr.map { (item) -> ios_settings in
            return ios_settings(fromDictionary:item)
        }
        return objectArray
        
    }
    static func getSettingWith(name:String) ->  ios_settings? {
        let cls = ios_settings(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(whereSql: "where name = " + "'"+name+"'")
        if let setting = arr.first{
            return ios_settings(fromDictionary:setting)

        }
        return nil
    }
    
    static func reset()
    {
        let cls = restaurant_table_class(fromDictionary: [:])
        _ =  cls.dbClass?.runSqlStatament(sql: "delete from ios_settings")
    }
    
    
}
