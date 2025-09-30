//
//  databaseClass.swift
//  pos
//
//  Created by Khaled on 4/16/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import UIKit
import Firebase
import FirebaseCrashlytics

enum connect_with_database {
    case database,log,printer_log,ingenico_log,multipeer_log,meesage_ip_log
}

class database_class: NSObject {
    
    var table_name:String
    var dictionary:[String:Any]
    var id_key:String
    var id:Int
    var insertId:Bool = false
    
    private var connect_with :connect_with_database!
    
    //    __block var db:FMDatabaseQueue!
    
    //    override init() {
    //
    //        db =  SharedManager.shared.database_db!
    //
    //       self.table_name = ""
    //       self.dictionary = [:]
    //       self.id = 0
    //       self.id_key = ""
    //
    //    }
    
    init(connect:connect_with_database? = .database) {
        
        connect_with = connect
        
        self.table_name = ""
        self.dictionary = [:]
        self.id = 0
        self.id_key = ""
        
    }
    
    
    
    init(table_name:String,dictionary:[String:Any]  ,id:Int,id_key:String,connect:connect_with_database? = .database) {
        self.table_name = table_name
        self.dictionary = dictionary
        self.id = id
        self.id_key = id_key
        
        connect_with = connect
        
        
        
    }
    
    func getDataBase() ->FMDatabaseQueue
    {
        if connect_with == .database
        {
            return SharedManager.shared.database_db!
            
        }
        else  if connect_with == .log
        {
            return SharedManager.shared.log_db!
            
        }
        else
          {
            if connect_with == .ingenico_log{
                return SharedManager.shared.ingenico_log_db!

            }
              else  if connect_with == .multipeer_log
              {
                  return SharedManager.shared.multipeer_log_db!
                  
              }else  if connect_with == .meesage_ip_log
            {
                return SharedManager.shared.message_ip_log_db!
                
            }else{
                return SharedManager.shared.printer_log_db!

            }
        }
        
    }
    
    func get_count(sql:String) -> Int
    {
         
        
        var count = 0
        
        let semaphore = DispatchSemaphore(value: 0)
        getDataBase().inDatabase { (db:FMDatabase) in
            
            let resutl:FMResultSet? = try? db.executeQuery(sql, values: nil)
            
            if resutl != nil
            {
                if resutl!.next()
                    {
                        
                        
                        count = Int(resutl!.int(forColumnIndex: 0))
                        resutl!.close()
                        
                    }
                    resutl!.close()
                    
            }
    
            db.close()
            semaphore.signal()
        }
        
        
        semaphore.wait()
        
        return count
    }
    
    
    func get_rows_count(whereSql:String) -> Int
    {
        
        let sql = "select count(*) from \(table_name) " + whereSql
        
        
        var count = 0
        
        let semaphore = DispatchSemaphore(value: 0)
        getDataBase().inDatabase { (db:FMDatabase) in
            
            let resutl:FMResultSet? = try? db.executeQuery(sql, values: nil)
            
            if resutl != nil
            {
                if resutl!.next()
                    {
                        
                        
                        count = Int(resutl!.int(forColumnIndex: 0))
                        resutl!.close()
                        
                    }
                    resutl!.close()
                    
            }
    
            db.close()
            semaphore.signal()
        }
        
        
        semaphore.wait()
        
        return count
    }
    
    func get_row (sql:String) -> [String:Any]? {
            var dic:[String:Any]?
           
           let semaphore = DispatchSemaphore(value: 0)
           getDataBase().inDatabase { (db:FMDatabase) in
               
               let resutl:FMResultSet? = try? db.executeQuery(sql, values: [])
               
               if resutl != nil
               {
                   if resutl!.next()
                           {
                               dic  = readData(resutl:resutl!)
                               
                               resutl!.close()
                           }
               }
           
               
               db.close()
            semaphore.signal()
           }
           
           
           semaphore.wait()
           
           
           return dic
       }
       
    
    func get_row (whereSql:String) -> [String:Any]? {
        let sql = "select * from \(table_name) " + whereSql
        var dic:[String:Any]?
        
        let semaphore = DispatchSemaphore(value: 0)
        getDataBase().inDatabase { (db:FMDatabase) in
            
            let resutl:FMResultSet? = try? db.executeQuery(sql, values: [])
            
            if resutl != nil
            {
                if resutl!.next()
                        {
                            dic  = readData(resutl:resutl!)
                            
                            resutl!.close()
                        }
            }
        
            
            db.close()
            semaphore.signal()
        }
        
        
        semaphore.wait()
        
        
        return dic
    }
    
    func get_rows( sql:String) ->[[String : Any]]
    {
        var arr:[[String : Any]] = []
        
        let semaphore = DispatchSemaphore(value: 0)
        getDataBase().inDatabase { (db:FMDatabase) in
            
            let rows:FMResultSet? = try? db.executeQuery(sql , values:[])
            
            if rows != nil
            {
                while (rows!.next()) {
                          //retrieve values for each record
                          let  dic  = readData(resutl:rows!)
                          
                          arr.append(dic)
                      }
                      rows!.close()
            }
      
            
            db.close()
            semaphore.signal()
        }
        
        
        semaphore.wait()
        
        return arr
    }
    
    func get_rows(fileds:String = "*" ,whereSql:String) ->[[String : Any]]
    {
        let sql = "select \(fileds) from \(table_name) " + whereSql
        var arr:[[String : Any]] = []
        
        let semaphore = DispatchSemaphore(value: 0)
        getDataBase().inDatabase { (db:FMDatabase) in
            
            let rows:FMResultSet? = try? db.executeQuery(sql , values:[])
            
            if rows != nil
            {
                while (rows!.next()) {
                             //retrieve values for each record
                             let  dic  = readData(resutl:rows!)
                             
                             arr.append(dic)
                         }
                         rows!.close()
            }
         
            
            db.close()
            semaphore.signal()
        }
        
        
        semaphore.wait()
        
        return arr
    }
    func get_ids(sql:String) ->[Int]
    {
       
        var arr:[Int] = []
        
        let semaphore = DispatchSemaphore(value: 0)
        getDataBase().inDatabase { (db:FMDatabase) in
            
            let rows:FMResultSet? = try? db.executeQuery(sql , values:[])
            
            if rows != nil
            {
                while (rows!.next()) {
                           //retrieve values for each record
                           let  value  = Int( rows!.int(forColumn: "re_id2"))
                           
                           arr.append(value)
                       }
                       rows!.close()
            }
       
            
            db.close()
            semaphore.signal()
        }
        
        
        semaphore.wait()
        
        return arr
    }
    func get_relations_rows(re_id1:Int,re_table1_table2:String, deleted:Bool? = nil) ->[Int]
    {
        var sql = "select * from relations where re_id1=\(re_id1) and re_table1_table2='\(re_table1_table2)'"
        if  deleted == nil{
            sql += " and deleted = 0"
        }
        var arr:[Int] = []
        
        let semaphore = DispatchSemaphore(value: 0)
        getDataBase().inDatabase { (db:FMDatabase) in
            
            let rows:FMResultSet? = try? db.executeQuery(sql , values:[])
            
            if rows != nil
            {
                while (rows!.next()) {
                           //retrieve values for each record
                           let  value  = Int( rows!.int(forColumn: "re_id2"))
                           
                           arr.append(value)
                       }
                       rows!.close()
            }
       
            
            db.close()
            semaphore.signal()
        }
        
        
        semaphore.wait()
        
        return arr
    }
    
    
    func get_relations_rows(re_id2:Int,re_table1_table2:String) ->[Int]
    {
        let sql = "select * from relations where re_id2=\(re_id2) and re_table1_table2 like'\(re_table1_table2)'"
        var arr:[Int] = []
        
        let semaphore = DispatchSemaphore(value: 0)
        getDataBase().inDatabase { (db:FMDatabase) in
            
            let rows:FMResultSet? = try? db.executeQuery(sql , values:[])
            
            if rows != nil
            {
                while (rows!.next()) {
                           //retrieve values for each record
                           let  value  = Int( rows!.int(forColumn: "re_id1"))
                           
                           arr.append(value)
                       }
                       rows!.close()
            }
       
            
            db.close()
            semaphore.signal()
        }
        
        
        semaphore.wait()
        
        return arr
    }
    
    
    
    func readData(resutl:FMResultSet) -> [String:Any]
    {
        //       SharedManager.shared.printLog(resutl.resultDictionary)
        //
        //        let dic:[String:Any]  = self.dictionary
        //        var temp:[String:Any] = [:]
        //        for (key,_) in dic
        //        {
        //            temp [key] = resutl.object(forColumn: key)
        //        }
        
        let temp:[String:Any] = resutl.resultDictionary as! [String : Any]
        return temp
    }
    
    func getSqlInsert() -> (sql:String , arr_values:[Any])
    {
        let dic:[String:Any]  = self.dictionary
        var sql = ""
        var values = ""
        
        //        let count = dic.keys.count
        var arr:[Any] = []
        //        arr.reserveCapacity(count)
        
        for (key,value) in dic
        {
            if value is [Any] || value is [String:Any]
            {
               SharedManager.shared.printLog("array values")
            }
            else
            {
                
                var addSql:Bool = false
                if insertId == true
                {
                    addSql = true
                }
                
                if key != id_key
                {
                    addSql = true
                }
                
                if addSql == true
                {
                    sql = sql + "," + key
                    values = values + ",?"
                    arr.append(value)
                }
            }
            
        }
        
        values.removeFirst()
        sql.removeFirst()
        
        sql = "insert into \(table_name) (" + sql + ") VALUES(" + values + ")"
        
        return (sql,arr)
        
    }
    
    func getSqlUpdate() -> (sql:String , arr_values:[Any])
    {
        let dic:[String:Any]  = self.dictionary
        let id = self.dictionary[id_key]
        
        var sql = ""
        var arr:[Any] = []
        
        for (key,value) in dic
        {
            if value is [Any] || value is [String:Any]
            {
               SharedManager.shared.printLog("array values")
            }
            else
            {
                if key != id_key
                {
                    sql = sql + "," + key + " = ?"
                    
                    arr.append(value)
                }
                
            }
            
            
            
        }
        
        sql.removeFirst()
        
        arr.append(id!)
        
        sql = "update \(table_name) set " + sql + " where \(id_key)=?"
        
        return (sql,arr)
        
    }
    
    
    func checkShiftExit() -> Bool
    {
        if self.id == 0  {
            return false
        }
        
        let sql = "select count(*) from \(table_name) where \(id_key) =?"
        var Exist:Bool = false
        
        let semaphore = DispatchSemaphore(value: 0)
        getDataBase().inDatabase { (db:FMDatabase) in
            
            let resutl:FMResultSet? = try? db.executeQuery(sql, values: [self.id])
            
            if resutl != nil
            {
                if resutl!.next()
                  {
                      let count:Int = Int(resutl!.int(forColumnIndex: 0))
                      
                      if count > 0
                      {
                          resutl!.close()
                          Exist =  true
                      }
                  }
                  
                  resutl!.close()
            }
  
            
            db.close()
            semaphore.signal()
        }
        
        
        semaphore.wait()
        
        return Exist
    }
    
    func save() -> Int
    {
        //       SharedManager.shared.printLog("Sql On \(table_name)")
        
   
        
        var  row_id = self.id
        
            let is_exist =  checkShiftExit()
        
        let semaphore = DispatchSemaphore(value: 0)
        getDataBase().inDatabase { (db:FMDatabase) in
            
            
            var sql = ""
            var arr_values:[Any] = []
        
            if is_exist == true
            {
                // update
                let cmd =  getSqlUpdate()
                sql = cmd.sql
                arr_values = cmd.arr_values
                
            }
            else
            {
                // insert
                let cmd = getSqlInsert()
                sql = cmd.sql
                arr_values = cmd.arr_values
            }
            
//           SharedManager.shared.printLog("sql : %@ , %@ " , sql , arr_values)

            
            let success = db.executeUpdate(sql,withArgumentsIn: arr_values)
            
            
            if !success
            {
                var values_temp = ""
 
                let joinedString = arr_values.toJsonString() ?? ""

                values_temp =   " \n sql:" + sql + " \n values : " + joinedString
                
            
                
                let error = db.lastErrorMessage()
                recordError(error_str: error,query: values_temp)
               SharedManager.shared.printLog("database Error : \(error)",force: true )
            }
            else
            {
                if is_exist == false
                {
                    row_id =  Int(db.lastInsertRowId)
                }
            }
            
            
            
            
            db.close()
            semaphore.signal()
        }
        
        
        semaphore.wait()
        
        return row_id
    }
    
    
    
    func remove() -> Bool
    {
        var  success = false
        
        let semaphore = DispatchSemaphore(value: 0)
        getDataBase().inDatabase { (db:FMDatabase) in
            
            
            let sql = "delete from \(table_name) where \(id_key) = \(id)"
            
            
            success = db.executeUpdate(sql,withArgumentsIn: [])
            
            if !success
            {
                let error = db.lastErrorMessage()
                recordError(error_str: error)
               SharedManager.shared.printLog("database Error : \(error)" )
            }
            
            
            
            db.close()
            semaphore.signal()
        }
        
        
        semaphore.wait()
        
        return success
    }
    
    func runSqlStatament(sql:String) -> Bool
    {
        var  success = false
        
        let semaphore = DispatchSemaphore(value: 0)
        getDataBase().inDatabase { (db:FMDatabase) in
            
            success = db.executeStatements(sql)
            
            if !success
            {
                let error = db.lastErrorMessage()
                if sql.contains("ALTER") && (error.contains("duplicate") || error.contains("not an error")) {
                    success = true
                }else{
                recordError(error_str: error)
               SharedManager.shared.printLog("database Error : \(error)" )
                }
            }
            
            
            
            db.close()
            semaphore.signal()
        }
        
        
        semaphore.wait()
        
        return success
    }
    
    
    
    func vacuum_database()
    {
        let sql = "vacuum"
        
        let semaphore = DispatchSemaphore(value: 0)
        getDataBase().inDatabase { (db:FMDatabase) in
            
            let success = db.executeUpdate(sql  , withArgumentsIn: [] )
            
            if !success
            {
                let error = db.lastErrorMessage()
                recordError(error_str: error)
               SharedManager.shared.printLog("database Error : \(error)" )
            }
            
            
            db.close()
            semaphore.signal()
        }
        
        
        semaphore.wait()
    }
    
    func recordError(  error_str:String , query:String = "")
    {
        
        if error_str.contains("disk")
        {
            SharedManager.shared.printLog(error_str)
        }
        
        if error_str.hasPrefix("duplicate")
        {
            return
        }
        
        if error_str.hasPrefix("no such table")
        {
            return
        }
        
         let err =  error_str // "test error"
        
        let error = NSError(domain: "DataBase", code: 5001, userInfo:
            [
                "error:" :  err,
                "query:" :  query,
            ])
      
        Crashlytics.crashlytics().record(error: error)

     }
    
    
    
}
