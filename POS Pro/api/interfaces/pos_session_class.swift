//
//  posConfigClass.swift
//  pos
//
//  Created by khaled on 8/22/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit
import Firebase
import FirebaseCrashlytics

enum showAs {
    case
    start , end ,
    cashIn ,
    cashOut
}
enum server_status_ref:Int {
    case not_created = 0 , open = 1 , closed = 2
}

class posSessionOptions
{
    var id : Int?
    var server_session_id : Int?
    
    var start_session : String?
    var end_session : String?
     var between_start_session:[String]?
    var search : String?

    var start_Balance : Double?
    var end_Balance : Double?
    
    var  sequence: Int?
     
    var isOpen:Bool?
     
    var posID:Int?
    var cashierID:Int?
    
    var page:Int = 0
    var LIMIT:Int = 0
    
    var getCount:Bool? = false
var orderDesc:Bool?
    
    var get_last_active_session:Bool? = false
    var get_active_session:Bool? = false
    var get_last_session_offline:Bool? = false

}

class pos_session_class: NSObject {
    var dbClass:database_class?
    
    
    var log_message: [String] = []
    
    var id : Int = 0
    var server_session_id : Int = 0
    
    var start_session : String?
    var end_session : String?
    
    
    var start_Balance : Double  = 0
    var end_Balance : Double  = 0
    
    var  sequence: Int = 0
    
    
    var isOpen:Bool = false
    
    var server_status:server_status_ref = .not_created
    
    var posID:Int?
    var cashierID:Int?
    
    
    var show_as:showAs = showAs.start
    
    var cashbox_list : [cashbox_class] = []
    
    var server_session_name : String = ""

    
    func pos() ->pos_config_class
    {
        return pos_config_class.getPos(posID: posID!)
    }
    
    func cashier() ->res_users_class
    {
        return res_users_class.getCashier(ID: cashierID!)
    }
    
    
    
    func appendLog(_ log:String)
    {
        
//        let len = 5 * 5
//        if log_message.count > len
//        {
//            var temp_log: [String] = []
//            temp_log.append(contentsOf: log_message)
//            log_message.removeAll()
//            for i in 0...len - 1
//            {
//                log_message.append(temp_log[i])
//            }
//        }
        
//        let key = "session " +  String(self.id)
//        let log_class = logClass.get(key:key , prefix: "pos_session" )
//       var last_data =  log_class.data  ?? ""
//        last_data = log + "\n" + last_data
        
        log_message.append(log)
    }
    
    override init() {
        super.init()
        
        
        id =  0
        
        
        server_session_id =   0
        sequence =   0
        posID =  0
        cashierID =   0
        
        server_status = .not_created
        
        
        start_Balance =  0
        end_Balance =   0
        
        isOpen =  false
        
        start_session =    ""
        end_session =    ""
        server_session_name = ""
        
        dbClass = database_class(table_name: "pos_session", dictionary: self.toDictionary(),id: id,id_key:"id")
        
    }
    
    init(fromDictionary dictionary: [String:Any]){
        
        super.init()
        
        id = dictionary["id"] as? Int ?? 0
        
        
        server_session_id = dictionary["server_session_id"] as? Int ?? 0
        sequence = dictionary["sequence"] as? Int ?? 0
        posID = dictionary["posID"] as? Int ?? 0
        cashierID = dictionary["cashierID"] as? Int ?? 0
        
        server_status = server_status_ref.init(rawValue:  dictionary["server_status"] as? Int ?? 0)!
        
        
        start_Balance = dictionary["start_Balance"] as? Double ?? 0
        end_Balance = dictionary["end_Balance"] as? Double ?? 0
        
        isOpen = dictionary["isOpen"] as? Bool ?? false
        
        start_session = dictionary["start_session"] as? String ??  ""
        end_session = dictionary["end_session"] as? String ??  ""
        server_session_name = dictionary["server_session_name"] as? String ??  ""

        dbClass = database_class(table_name: "pos_session", dictionary: self.toDictionary(),id: id,id_key:"id")
        
    }
    
    func toDictionary() -> [String:Any]
    {
        
        var dictionary:[String:Any] = [:]
        
        dictionary["id"] = id
        dictionary["server_session_id"] = server_session_id
        dictionary["sequence"] = sequence
        dictionary["posID"] = posID
        dictionary["cashierID"] = cashierID
        dictionary["server_status"] = server_status.rawValue
        dictionary["start_Balance"] = start_Balance
        dictionary["end_Balance"] = end_Balance
        dictionary["isOpen"] = isOpen
        dictionary["start_session"] = start_session
        dictionary["end_session"] = end_session
        dictionary["server_session_name"] = server_session_name

        
        // stop update isOpen in saveSession
        return baseClass.fillterProperties(dictionary: dictionary, excludeProperties: ["isOpen","end_session","end_Balance"])

    }
    
    func saveSession() -> Int
    {
         
        dbClass?.dictionary = self.toDictionary()
        dbClass?.id = self.id
        dbClass?.insertId = false
        let row_id =  dbClass!.save()
        
        saveLog(row_id: row_id)
        
        return row_id
    }
    
    static func close_session(session_id:Int,end_session:String,end_Balance:Double)
    {
        let sql = "update pos_session set isOpen = 0 , end_session =? , end_Balance =?  where id = ?"
        
        let semaphore = DispatchSemaphore(value: 0)
                 
                 SharedManager.shared.database_db!.inDatabase { (db:FMDatabase) in
                     
                    let success  = db.executeUpdate(sql, withArgumentsIn: [end_session,end_Balance,session_id])
                    
                    if (!success) {
                        let error_str = db.lastError().localizedDescription
 
                        // add log to local
                       // ============================
                        let key = "session " +  String(session_id)
                        let log = logClass.get(key:key , prefix: "pos_session" )
                        log.id = 0
                        log.data =  (log.data ?? "") + "\n" + error_str
                        log.row_id = session_id
                        log.key = key
                        log.prefix = "pos_session"
                        
                        log.save()
                        
                        // add log to firebase
                       // ============================

                        let dt = baseClass.get_date_now_formate_satnder() // must to be UTC  as server online
 
                        let _ = NSError(domain: "close session", code: 5002, userInfo:
                            [
                                "id" : session_id,
                                "date" :  dt ,
                                "value" : 0,
                                "close" : error_str
 
                                
                            ]
                        )
                        
//                        Crashlytics.crashlytics().record(error: error)
                    }

 
                     db.close()
                     semaphore.signal()
                 }
                 
                 
                 semaphore.wait()
    }
    
   static func open_session(session_id:Int)
    {
        let sql = "update pos_session set isOpen = 1 where id = \(session_id)"
        
        let semaphore = DispatchSemaphore(value: 0)
                 
                 SharedManager.shared.database_db!.inDatabase { (db:FMDatabase) in
                     
                    let success  = db.executeUpdate(sql, withArgumentsIn: [])
                    
                    if (!success) {
                        let error_str = db.lastError().localizedDescription
 
                        // add log to local
                       // ============================
                        let key = "session " +  String(session_id)
                        let log = logClass.get(key:key , prefix: "pos_session" )
                        log.id = 0
                        log.data =  (log.data ?? "") + "\n" + error_str
                        log.row_id = session_id
                        log.key = key
                        log.prefix = "pos_session"
                        
                        log.save()
                        
                        // add log to firebase
                       // ============================

                        let dt = baseClass.get_date_now_formate_satnder() // must to be UTC  as server online
 
                        let _ = NSError(domain: "close session", code: 5002, userInfo:
                            [
                                "id" : session_id,
                                "date" :  dt ,
                                "value" : 0,
                                "open" : error_str
 
                                
                            ]
                        )
                        
//                        Crashlytics.crashlytics().record(error: error)
                    }

 
                     db.close()
                     semaphore.signal()
                 }
                 
                 
                 semaphore.wait()
    }
    
    func saveLog(row_id:Int)
    {
        if log_message.count > 0
        {
 
            let key = "session " +  String(row_id)
            let log = logClass.get(key:key , prefix: "pos_session" )
            if let jsonString = log_message.toJsonString(){
            log.data =  (log.data ?? "") + "\n" + jsonString
            }else{
                log.data =  (log.data ?? "") + "\n" + "Cannot Json String"
            }
            log.row_id = row_id
            log.key = key
            log.prefix = "pos_session"
            
            let setting = SharedManager.shared.appSetting()

            if setting.enable_record_all_log
            {
                log.id = 0
                if let jsonString = log_message.toJsonString(){

                log.data  = jsonString
                }else{
                    log.data = "Cannot Json String"
                }
            }
            
            log.save()
        }
        
    }
    
    //===============================================
    
       static func get_pos_session_sql(options:posSessionOptions ,getCount:Bool  ) -> String
        {
            var fields = "pos_session.*"
            if  getCount == true
             {
                fields = "count(*) "
             }
            
            var sql = "select \(fields) from pos_session "
 
            
            var list_where:[String] = []
            
            if options.id != nil
            {
                list_where.append("pos_session.id = \(options.id!)")
            }
   
            
            if options.server_session_id != nil
            {
                list_where.append("pos_session.server_session_id = \(options.server_session_id!)")
                
            }
       
            
            if options.start_session != nil
            {
                list_where.append("pos_session.start_session like '%\(options.start_session!)%'")
                
            }
            
            if options.end_session != nil
            {
                list_where.append("pos_session.end_session like '%\(options.end_session!)%'")
                
            }
            
            
            if options.start_Balance != nil
            {
                list_where.append("pos_session.start_Balance = \(options.start_Balance!)")
                
            }
            
            if options.end_Balance != nil
            {
                list_where.append("pos_session.end_Balance = \(options.end_Balance!)")
                
            }
            
            
            if options.sequence != nil
            {
                list_where.append("pos_session.sequence = \(options.sequence!)")
            }
            
            
            if options.between_start_session != nil
            {
                let fromDay = options.between_start_session![0]
                let toDay = options.between_start_session![1]
                
                if fromDay == toDay
                {
                    list_where.append("pos_session.start_session like '\(fromDay)%' ")
                }
                else
                {
                    list_where.append("pos_session.start_session between '\(fromDay)' and '\(toDay)'")
                    
                }
                
            }
            
            if options.isOpen != nil
            {
                
                
                list_where.append("pos_session.isOpen = '\( options.isOpen! )'")
                
            }
            
          if options.posID != nil
           {
                 list_where.append("pos_session.posID = '\( options.posID! )'")
 
             }
            
            if options.cashierID != nil
            {
                list_where.append("pos_session.cashierID = \( options.cashierID! )")
            }
            
            
            if options.get_last_active_session == true
            {

                list_where.append("isopen = 0 ")
                options.orderDesc = true
            }
            
            if options.get_active_session == true
            {
                  list_where.append("isopen =1 ")
                   
            }
                       
            if options.get_last_session_offline == true
           {
                   list_where.append("server_status = 0 or server_status = 1")
                     options.orderDesc = false
                     options.LIMIT = 1
                     options.page = 0
             }
            
            
            // ========================================================
            
            if list_where .count > 0
            {
                sql = sql + " where "
            }
            
            var and = ""
            for wh in list_where
            {
                sql = String(format: "%@ %@ %@", sql , and , wh)
                
                if and == ""
                {
                    and = "and"
                }
            }
            
            if options.orderDesc == false
            {
                sql = String(format: "%@ %@", sql , " order by pos_session.id asc")
            }
            else
            {
                sql = String(format: "%@ %@", sql , " order by pos_session.id desc")
                
            }
            
            if options.LIMIT != 0
            {
                let start = options.page * options.LIMIT
                sql = String(format: "%@ LIMIT %d,%d", sql ,start, options.LIMIT)
                
            }
            
            return sql
        }
    
      static func get_count(sql:String ) -> Int
        {
            
            
            var totalCount = 0
            let semaphore = DispatchSemaphore(value: 0)
            
            SharedManager.shared.database_db!.inDatabase { (db:FMDatabase) in
                
                let rows:FMResultSet = try!   db.executeQuery(sql, values: [])
                if (rows.next()) {
                    //retrieve values for each record
                    totalCount = Int(rows.int(forColumnIndex: 0))
                    
                }
                
                rows.close()
                
                semaphore.signal()
            }
            
            
            semaphore.wait()
            
            
            return totalCount
        }
        
        static func get_pos_session_count(options:posSessionOptions ) -> Int
        {
            
            let sql = get_pos_session_sql(options:options ,getCount: true)
            let totalCount = get_count(sql: sql)
            
            
            
            return totalCount
        }
        
        static func get_pos_sessions(options:posSessionOptions ) -> [pos_session_class]
        {
            var list:[pos_session_class] = []
             
            // =====================================================================================
            let sql = get_pos_session_sql(options: options,getCount: false)
            
            let cls = pos_session_class(fromDictionary: [:])
            let arr  = cls.dbClass!.get_rows(sql: sql)
            
            for item in arr
            {
               let cls:pos_session_class = pos_session_class(fromDictionary: item  )
                list.append(cls)
     
             }
    
            return list
        }
    
    static func get_pos_sessions(options:posSessionOptions ) -> [[String:Any]]
           {
               var list:[[String:Any]] = []
                
               // =====================================================================================
               let sql = get_pos_session_sql(options: options,getCount: false)
               
               let cls = pos_session_class(fromDictionary: [:])
               let arr  = cls.dbClass!.get_rows(sql: sql)
               
               for item in arr
               {
                    list.append(item)
        
                }
       
               return list
           }
       
    
    //===============================================
 
    
    static func getSession(sessionID:Int) -> pos_session_class?
    {

        let options = posSessionOptions()
        options.id = sessionID

        let arr:[pos_session_class] = get_pos_sessions(options: options)
        if arr.count > 0
        {
            return arr[0]
        }

        return nil



    }
    
    static func getSession(day:String) -> pos_session_class?
    {
           let options = posSessionOptions()
              options.start_session = day

              let arr:[pos_session_class] = get_pos_sessions(options: options)
              if arr.count > 0
              {
                  return arr[0]
              }

              return nil

    }
     
    static func get_last_session_offline() -> pos_session_class?
    {
        
        let options = posSessionOptions()
        options.get_last_session_offline = true

        let arr:[pos_session_class] = get_pos_sessions(options: options)
        if arr.count > 0
        {
            return arr[0]
        }

        return nil
        
 
        
    }
    static func get_last_session_offline_no_condation() -> pos_session_class?
    {
        
        let options = posSessionOptions()

        let arr:[pos_session_class] = get_pos_sessions(options: options)
        if arr.count > 0
        {
            return arr[0]
        }

        return nil
        
 
        
    }
    
    
    static func getLastActiveSession() -> pos_session_class?
    {
        
        let options = posSessionOptions()
        options.get_last_active_session = true

        let arr:[pos_session_class] = get_pos_sessions(options: options)
        if arr.count > 0
        {
            return arr[0]
        }

        return nil
        
        
//        let cls = pos_session_class(fromDictionary: [:])
//
//        let row:[String:Any]?  = cls.dbClass!.get_row(whereSql: " where isopen = 0 order by id desc" )
//        if row != nil
//        {
//            return pos_session_class(fromDictionary: row!)
//        }
//
//        return nil
        
        
         
    }
    
   
    
    static func getActiveSession() -> pos_session_class?
    {
        if let activeSession = SharedManager.shared.activeSessionShared {
            return activeSession
        }
        let options = posSessionOptions()
        options.get_active_session = true

        let arr:[pos_session_class] = get_pos_sessions(options: options)
        if arr.count > 0
        {
            let activeSession =  arr[0]
            SharedManager.shared.activeSessionShared = activeSession
            return arr[0]
        }

        return nil
        
 
        
    }
    static func getLastSession() -> pos_session_class?
    {
        
        let options = posSessionOptions()
        options.get_active_session = false

        let arr:[pos_session_class] = get_pos_sessions(options: options)
        if arr.count > 0
        {
            return arr.first
        }

        return nil
        
 
        
    }
    
    
    static func force_close_all_sessions ()  {
        
        let cls = pos_session_class(fromDictionary: [:])
       _ = cls.dbClass!.runSqlStatament(sql: "update pos_session set isOpen = 0")
        
    }
 
    static func force_close_sessions (session_id:Int)  {
        
        let dt =  baseClass.get_date_now_formate_satnder()
        
        let cls = pos_session_class(fromDictionary: [:])
       _ = cls.dbClass!.runSqlStatament(sql: "update pos_session set isOpen = 0 , end_session='\(dt)' where id =\(session_id) ")
        
    }
 
    static func check_session_closed(session_id:Int) -> Bool
      {
          
          let sql = "select isOpen from pos_session where id =\(session_id)"
          var is_closed = false
          let semaphore = DispatchSemaphore(value: 0)
          
          SharedManager.shared.database_db!.inDatabase { (db:FMDatabase) in
              
              let rows:FMResultSet = try!   db.executeQuery(sql, values: [])
              if (rows.next()) {
                  //retrieve values for each record
                 let  isOpen = Int(rows.int(forColumnIndex: 0))
                if isOpen == 0
                {
                    is_closed = true
                }
                 
              }
              
              rows.close()
              
              semaphore.signal()
          }
          
          
          semaphore.wait()
          
          
          return is_closed
      }

    func set_server_status_session(with status: server_status_ref){
        if status == .closed {
            let orders =  pos_order_class.get_not_sync_orders(for: self)
            self.server_status = orders.count > 0 ? .open : status
        }else{
            self.server_status = status
        }
    }
    func update_session_id_local_pending_order(session_id:Int)  {
            if session_id != 0 {
                DispatchQueue.global(qos: .background).async {
                    let posID = SharedManager.shared.posConfig().id
                    let dt =  baseClass.get_date_now_formate_satnder()
                    
                    let cls = pos_session_class(fromDictionary: [:])
                    _ = cls.dbClass!.runSqlStatament(sql: "update pos_order set session_id_local = \(session_id) where is_void = 0 and is_closed  != 1 and session_id_local > 0 and write_pos_id  = \(posID) ")
                }
        }
            
        }
     
}

