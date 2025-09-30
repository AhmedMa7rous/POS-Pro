//
//  rules.swift
//  pos
//
//  Created by Khaled on 1/24/21.
//  Copyright © 2021 khaled. All rights reserved.
//

import Foundation



class ios_rule:NSObject
{
    
    
    var dbClass:database_class?
    
    var id : Int = 0
    var name: String!
    var key: rule_key = .none
    var _description: String?
//    var default_value:Bool = true
    
    var access:Bool = true
    
    var other_lang_name:String!
    
    init(fromDictionary dictionary: [String:Any]){
        super.init()
        
        id = dictionary["id"] as? Int ?? 0

        
        
        name = dictionary["name"] as? String ?? ""
       let key_str = dictionary["key"] as? String ?? ""
        
        key = rule_key(rawValue: key_str) ??  key
        
        
        _description = dictionary["description"] as? String ?? ""
//        default_value = dictionary["default_value"] as? Bool ?? default_value

        other_lang_name = dictionary["other_lang_name"] as? String ?? ""

        dbClass = database_class(table_name: "ios_rule", dictionary: self.toDictionary(),id: id,id_key:"id")

    }
    
    func toDictionary() -> [String:Any]
    {
       var dictionary:[String:Any] = [:]
        
        dictionary["id"] = id
        dictionary["name"] = name
        dictionary["key"] = key.rawValue
        dictionary["description"] = _description
//        dictionary["default_value"] = default_value
        dictionary["other_lang_name"] = other_lang_name

        
        
        return dictionary
        
    }
    
    
    func save(temp:Bool = false)
    {
        dbClass?.dictionary = self.toDictionary()
        dbClass?.id = self.id
        
        if temp
        {
            dbClass!.table_name =  "temp_" + dbClass!.table_name
        }
        
        _ =  dbClass!.save()
        
        
    }
    
    static func saveAll(arr:[[String:Any]],temp:Bool = false)
    {
        for item in arr
        {
            let pos = ios_rule(fromDictionary: item)
            pos.dbClass?.insertId = true
            pos.save(temp: temp)
        }
    }
    
    static func getAll() ->  [[String:Any]] {
        
        let cls = ios_rule(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(whereSql: "")
        return arr
        
    }
    
    static func reset(temp:Bool = false)
    {
        let cls = ios_rule(fromDictionary: [:])
        
        var table = cls.dbClass!.table_name
         if temp
         {
            table =   "temp_" + cls.dbClass!.table_name
         }
        
      _ =  cls.dbClass?.runSqlStatament(sql: "delete from \(table)")
    }
    

}
