//
//  MultiPeerLog.swift
//  pos
//
//  Created by Mohamed Magdy on 12/26/21.
//  Copyright © 2021 khaled. All rights reserved.
//

import Foundation
class MultiPeerLog:NSObject{
    var id : Int?
    var log:String?
    var note : String?
    var date : String?

    var dbClass:database_class?

    override init() {
        dbClass = database_class(connect: .multipeer_log)
    }
    init(fromDictionary dictionary: [String:Any]){
        super.init()
        
        id = dictionary["id"] as? Int ?? 0
        log = dictionary["log"] as? String ?? ""
        note = dictionary["note"] as? String ?? ""
        date = dictionary["date"] as? String ?? ""
        dbClass = database_class(table_name: "multipeer_log", dictionary: self.toDictionary(),id: id!,id_key:"id",connect: .multipeer_log)
    }
    
    
    func toDictionary() -> [String:Any]
    {
        var dictionary:[String:Any] = [:]
        
        dictionary["id"] = id
        dictionary["log"] = log
        dictionary["note"] = note
        dictionary["date"] = date
        return dictionary
    }
    
    static func set(log:String,note:String)
    {
        let multiPeerLog = MultiPeerLog(fromDictionary: [:])
        multiPeerLog.log = log
        multiPeerLog.note = note
        multiPeerLog.date = getCurrentTime()
        multiPeerLog.save()
    }
    
    static func getCurrentTime(format:String = "yyyy-MMM-dd HH:mm:ss")->String{
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        let date = Date()
        return dateFormatter.string(from: date)
    }
    func save()
    {
        dbClass?.dictionary = self.toDictionary()
        dbClass?.id = self.id!
        dbClass?.insertId = false
        
        self.id =  dbClass!.save()
    }

    static func countBefore(date:String? = nil) -> Int   {
//           if date != nil
//           {
               let Sql =  "select count(*) as cnt from multipeer_log "

//               let oldSql =  "select count(*) as cnt from multipeer_log where date  < '\(date!)' "
//             let newSql =  "select count(*) as cnt from multipeer_log where  STR_TO_DATE(date, '%Y-%m-%d hh:mm:ss') BETWEEN STR_TO_DATE(\(date ?? ""), '%Y-%m-%d hh:mm:ss') AND NOW()"
               let count:[String:Any] = database_class(connect: .multipeer_log).get_row(sql:Sql) ?? [:]

            return count["cnt"] as? Int ?? 0
             
//           }
//
//        return 0
           
       }
    static func reset()
    {
        let cls = MultiPeerLog(fromDictionary: [:])
        let sql = "Delete from multipeer_log where id NOT IN (SELECT id from multipeer_log  order by id DESC limit 200)"
        _ =  cls.dbClass?.runSqlStatament(sql: sql)
    }
    
    static func deleteAll(prefix:String?)   {
        
   
        if prefix == nil
        {
            _ = database_class(connect: .printer_log).runSqlStatament(sql: "delete from log")

        }
        else
        {
            _ = database_class(connect: .printer_log).runSqlStatament(sql: "delete from log where prefix='\(prefix!)'")

        }
     
        
    }

    
    
    static func vacuum_database()
         {
             let sql = "vacuum"
             
             let semaphore = DispatchSemaphore(value: 0)
             SharedManager.shared.multipeer_log_db!.inDatabase { (db:FMDatabase) in

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
