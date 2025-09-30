//
//  logClass.swift
//  pos
//
//  Created by Khaled on 4/26/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import UIKit

class logClass: NSObject {
    
    var dbClass:database_class?
    
    var id : Int?
    var row_id :Int?
    var req_count :Int = 0

    
    var key : String?
    var prefix : String?
    var data : String?
  
    
    
    override init() {
            
        dbClass = database_class(connect: .log)

    }
      
      
      /**
       * Instantiate the instance using the passed dictionary values to set the properties values
       */
      init(fromDictionary dictionary: [String:Any]){
          super.init()
          
          id = dictionary["id"] as? Int ?? 0
          row_id = dictionary["row_id"] as? Int ?? 0
        req_count = dictionary["req_count"] as? Int ?? 0

 
          key = dictionary["key"] as? String ?? ""
          data = dictionary["data"] as? String ?? ""
          prefix = dictionary["prefix"] as? String ?? ""
  
          
          dbClass = database_class(table_name: "log", dictionary: self.toDictionary(),id: id!,id_key:"id",connect: .log)

      }
    
    
      func toDictionary() -> [String:Any]
       {
           var dictionary:[String:Any] = [:]
           
           
           dictionary["id"] = id ?? 0
            dictionary["row_id"] = row_id ?? 0
           dictionary["req_count"] = req_count
        

           dictionary["key"] = key ?? ""
           dictionary["data"] = data ?? ""
           dictionary["prefix"] = prefix ?? ""
 
           
           return dictionary
       }
       
    
    func save()
       {
    
           dbClass?.dictionary = self.toDictionary()
           dbClass?.id = self.id!
            dbClass?.insertId = false
        
           _ =  dbClass!.save()
       }
    
    
    static func get(key:String,prefix:String) -> logClass  {
           
           let cls = logClass(fromDictionary: [:])
        let dic =  cls.dbClass!.get_row(whereSql: " where key='\(key)' and prefix ='\(prefix)' ") ?? [:]
          
           return logClass(fromDictionary:dic)
   }
    
    static func getAll(prefix:String, limit:[Int]) ->  [[String:Any]] {
        
        let cls = logClass(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(whereSql: " where prefix ='\(prefix)' order by id desc limit \(limit[0]),\(limit[1]) ")
        return arr
        
    }
    
    static func getAll(limit:[Int]) ->  [[String:Any]] {
        
        let cls = logClass(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(whereSql: " order by id desc limit \(limit[0]),\(limit[1]) ")
        return arr
        
    }
    
    static func search(txt:String ,prefix:String = "",limit:[Int]) ->  [[String:Any]] {
        var sql = " where data like'%\(txt)%'   "
        if prefix != ""
        {
              sql = sql + " and prefix ='\(prefix)'"

        }
        
        sql = sql + " order by id desc  limit \(limit[0]),\(limit[1])"

        
        let cls = logClass(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(whereSql: sql)
        return arr
        
    }
    
    
    static func countBefore(date:String?) -> Int   {
           
      
           if date != nil
           {
            
            let count:[String:Any] = database_class(connect: .log).get_row(sql: "select count(*) as cnt from log where updated_at  < '\(date!)' ") ?? [:]

            return count["cnt"] as? Int ?? 0
             
           }
        
        return 0
           
       }
    
    static func deleteBefore(date:String?)   {
        
   
        if date != nil
        {
         
            let suc = database_class(connect: .log).runSqlStatament(sql: "delete from log where updated_at  < '\(date!)' ")

        }
     
        
    }
    
    static func deleteAll(prefix:String?)   {
        
   
        if prefix == nil
        {
            _ = database_class(connect: .log).runSqlStatament(sql: "delete from log")

        }
        else
        {
            _ = database_class(connect: .log).runSqlStatament(sql: "delete from log where prefix='\(prefix!)'")

        }
     
        
    }
    
    static func set(key:String,value:Any,prefix:String,row_id:Int? = nil)
    {
        let log = logClass(fromDictionary: [:])
        log.key = key
        
        var  temp = ""
        if value is [String:Any]
        {
            let dic = value as? [String:Any] ?? [:]
            temp = dic.jsonString() ?? ""
        }
     
        log.data = temp
        log.prefix = prefix
        log.row_id = row_id
        
        log.save()
    }
    
    
}
