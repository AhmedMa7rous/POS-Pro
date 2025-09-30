//
//  rules.swift
//  pos
//
//  Created by Khaled on 1/24/21.
//  Copyright © 2021 khaled. All rights reserved.
//

import Foundation



class ios_group:NSObject
{
    
    
    var dbClass:database_class?
    
    var id : Int = 0
    var name: String!
    var company_id: Int?
 
    var user_ids:[Int] = []
    var role_ids:[Int] = []

    
    init(fromDictionary dictionary: [String:Any]){
        super.init()
        
        id = dictionary["id"] as? Int ?? 0
        name = dictionary["name"] as? String ?? ""
        
        
        company_id = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "company_id", keyOfDatabase: "company_id",Index: 0) as? Int ?? 0

        if let userIds = dictionary["user_ids"] as? [Int]{
            user_ids = userIds
        }else if let userIds = dictionary["pos_user_ids"] as? [Int]{
            user_ids = userIds
        }
        role_ids = dictionary["role_ids"] as? [Int] ?? []

        
        dbClass = database_class(table_name: "ios_group", dictionary: self.toDictionary(),id: id,id_key:"id")

    }
    
    func toDictionary() -> [String:Any]
    {
       var dictionary:[String:Any] = [:]
        
        dictionary["id"] = id
        dictionary["name"] = name
        dictionary["company_id"] = company_id
        
        
        
        return dictionary
        
    }
    
    func get_user_ids() -> [Int]
    {
        return dbClass?.get_relations_rows(re_id1: self.id, re_table1_table2:  "ios_group|res_users") ?? []
    }
    
    func get_role_ids() -> [Int]
    {
        return dbClass?.get_relations_rows(re_id1: self.id, re_table1_table2:  "ios_group|ios_rule") ?? []
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
        
        relations_database_class(re_id1: self.id, re_id2: user_ids, re_table1_table2: "ios_group|res_users").save()
        relations_database_class(re_id1: self.id, re_id2: role_ids, re_table1_table2: "ios_group|ios_rule").save()

        
    }
    
    static func saveAll(arr:[[String:Any]],temp:Bool = false)
    {
        for item in arr
        {
            let pos = ios_group(fromDictionary: item)
            pos.dbClass?.insertId = true
            pos.save(temp: temp)
        }
    }
    
    static func getAll() ->  [[String:Any]] {
        
        let cls = ios_group(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(whereSql: "")
        return arr
        
    }
    
    static func reset(temp:Bool = false)
    {
        let cls = ios_group(fromDictionary: [:])
        
        var table = cls.dbClass!.table_name
         if temp
         {
            table =   "temp_" + cls.dbClass!.table_name
         }
        
      _ =  cls.dbClass?.runSqlStatament(sql: "delete from \(table)")
        
        _ =  database_class().runSqlStatament(sql: "delete from relations where re_table1_table2='ios_group|res_users' ")
        _ =  database_class().runSqlStatament(sql: "delete from relations where re_table1_table2='ios_group|ios_rule' ")

    }
    

}
