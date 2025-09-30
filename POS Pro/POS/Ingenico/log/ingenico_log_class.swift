//
//  ingenico_log_class.swift
//  pos
//
//  Created by M-Wageh on 22/06/2021.
//  Copyright © 2021 khaled. All rights reserved.
//

import Foundation

class ingenico_log_class: NSObject {
    
    var dbClass:database_class?
    
    var id : Int?
    var ingenico_id :Int?

    
    var key : String?
    var prefix : String?
    var data : String?
    var updated_at:String? = Date().toString(dateFormat: printer_log_class.date_formate_database, UTC: true)
  
    
    
    override init() {
            
        dbClass = database_class(connect: .ingenico_log)

    }
      
      
      /**
       * Instantiate the instance using the passed dictionary values to set the properties values
       */
      init(fromDictionary dictionary: [String:Any]){
          super.init()
          
          id = dictionary["id"] as? Int ?? 0
        ingenico_id = dictionary["ingenico_id"] as? Int ?? 0

 
          key = dictionary["key"] as? String ?? ""
          data = dictionary["data"] as? String ?? ""
          prefix = dictionary["prefix"] as? String ?? ""
        updated_at = dictionary["updated_at"] as? String ?? ""

          
          dbClass = database_class(table_name: "log", dictionary: self.toDictionary(),id: id!,id_key:"id",connect: .ingenico_log)

      }
    
    
      func toDictionary() -> [String:Any]
       {
           var dictionary:[String:Any] = [:]
           
           
           dictionary["id"] = id ?? 0
            dictionary["ingenico_id"] = ingenico_id ?? 0
        

           dictionary["key"] = key ?? ""
           dictionary["data"] = data ?? ""
           dictionary["prefix"] = prefix ?? ""
        dictionary["updated_at"] = updated_at ?? baseClass.get_date_now_formate_datebase()

           
           return dictionary
       }
       
    
    func save()
       {
           self.updated_at = Date().toString(dateFormat: printer_log_class.date_formate_database, UTC: true)
           dbClass?.dictionary = self.toDictionary()
           dbClass?.id = self.id!
            dbClass?.insertId = false
        
           _ =  dbClass!.save()
       }
    
    
    static func get(key:String,prefix:String) -> ingenico_log_class  {
           
           let cls = ingenico_log_class(fromDictionary: [:])
        let dic =  cls.dbClass!.get_row(whereSql: " where key='\(key)' and prefix ='\(prefix)' ") ?? [:]
          
           return ingenico_log_class(fromDictionary:dic)
   }
    
    static func getAll(prefix:String, limit:[Int]) ->  [[String:Any]] {
        
        let cls = ingenico_log_class(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(whereSql: " where prefix ='\(prefix)' order by id desc limit \(limit[0]),\(limit[1]) ")
        return arr
        
    }
    
    static func getAll(limit:[Int]) ->  [[String:Any]] {
        
        let cls = ingenico_log_class(fromDictionary: [:])
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

        
        let cls = ingenico_log_class(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(whereSql: sql)
        return arr
        
    }
    
    
    static func countBefore(date:String?) -> Int   {
           
      
           if date != nil
           {
            
            let count:[String:Any] = database_class(connect: .ingenico_log).get_row(sql: "select count(*) as cnt from log where updated_at  < '\(date!)' ") ?? [:]

            return count["cnt"] as? Int ?? 0
             
           }
        
        return 0
           
       }
    
    static func deleteBefore(date:String?)   {
        
   
        if date != nil
        {
         
            let suc = database_class(connect: .ingenico_log).runSqlStatament(sql: "delete from log where updated_at  < '\(date!)' ")

        }
     
        
    }
    
    static func deleteAll(prefix:String?)   {
        
   
        if prefix == nil
        {
            _ = database_class(connect: .ingenico_log).runSqlStatament(sql: "delete from log")

        }
        else
        {
            _ = database_class(connect: .ingenico_log).runSqlStatament(sql: "delete from log where prefix='\(prefix!)'")

        }
     
        
    }
    
    static func set(key:String,value:Any,prefix:String,ingenico_id:Int? = nil)
    {
        let log = ingenico_log_class(fromDictionary: [:])
        log.key = key
        
        var  temp = ""
        if value is [String:Any]
        {
            let dic = value as? [String:Any] ?? [:]
            temp = dic.jsonString() ?? ""
        }
     
        log.data = temp
        log.prefix = prefix
        log.ingenico_id = ingenico_id
        
        log.save()
    }
    static func vacuum_database()
         {
             let sql = "vacuum"
             
             let semaphore = DispatchSemaphore(value: 0)
             SharedManager.shared.ingenico_log_db!.inDatabase { (db:FMDatabase) in

                 let success = db.executeUpdate(sql  , withArgumentsIn: [] )
                 
                 if !success
                 {
                     let error = db.lastErrorMessage()
                    SharedManager.shared.printLog("database Error : \(error)" )
                 }
                 
                 db.close()
                 semaphore.signal()
             }
             
             
             semaphore.wait()
         }
    
}
