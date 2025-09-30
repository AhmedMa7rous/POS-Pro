//
//  relationsDatabaseClass.swift
//  pos
//
//  Created by Khaled on 4/16/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import UIKit

class relations_database_class: NSObject {
    
    var re_id1:Int!
    var re_id2:[Int]!
    var re_table1_table2:String!
    var data:String?
    var deleted : Bool = false

    override init() {
         
    }
    
    init(re_id1:Int,re_id2:[Int],re_table1_table2:String,data_str:String? = nil) {
        super.init()
        
        self.re_id1 = re_id1
        self.re_id2 = re_id2
        self.re_table1_table2 = re_table1_table2
        self.data = data_str
        self.deleted = false
        
    }
    
    
    static func reset(re_table1_table2:String)
    {
        _ =  database_class().runSqlStatament(sql: "update relations set deleted = 1  where re_table1_table2='\(re_table1_table2)' ")

//        _ =  database_class().runSqlStatament(sql: "delete from relations where re_table1_table2='\(re_table1_table2)' ")
    }
 
    static func delete(re_id1:Int ,re_table1_table2:String)
    {
        _ =  database_class().runSqlStatament(sql: "update relations set deleted = 1  where re_table1_table2='\(re_table1_table2)' and re_id1=\(re_id1) ")

//        _ =  database_class().runSqlStatament(sql: "delete from relations where re_table1_table2='\(re_table1_table2)' and re_id1=\(re_id1)")
    }
    static func delete(re_id1:[Int] ,re_table1_table2:String)
    {
        _ =  database_class().runSqlStatament(sql: "update relations set deleted = 1  where re_table1_table2='\(re_table1_table2)' and re_id1 in ( \(re_id1.map({"\($0)"}).joined(separator: ", ")) ) ")

//        _ =  database_class().runSqlStatament(sql: "delete from relations where re_table1_table2='\(re_table1_table2)' and re_id1=\(re_id1)")
    }
    
    func save_old()
    {
     
        _ =  database_class().runSqlStatament(sql: "update relations set deleted = 1  where re_table1_table2='\(re_table1_table2!)' and re_id1=\(re_id1!) ")

//         _ =  database_class().runSqlStatament(sql: "delete from relations where re_table1_table2='\(re_table1_table2!)' and re_id1=\(re_id1!)")
        
        let sql = NSMutableString()
        for id in re_id2
        {
            sql.append("insert into relations(re_id1,re_id2,re_table1_table2) values (\(re_id1!) , \(id) , '\(re_table1_table2!)');")
            sql.append("\n")
        }
        
        if !String(sql).isEmpty
        {
            _ =  database_class().runSqlStatament(sql: String(sql))

        }

    }
    
    
    func save()
    {
        _ =  database_class().runSqlStatament(sql: "update relations set deleted = 1  where re_table1_table2='\(re_table1_table2!)' and re_id1=\(re_id1!)")

        
//        _ =  database_class().runSqlStatament(sql: "delete from relations where re_table1_table2='\(re_table1_table2!)' and re_id1=\(re_id1!)")
        for id in re_id2
        {
            let is_exist_row = is_exist_row(re_id1!,id,re_table1_table2!)
            var sql = "insert into relations(re_id1,re_id2,re_table1_table2,data,deleted) values(\(re_id1!),\(id),'\(re_table1_table2!)',\(data ?? "null"),0)"
            if is_exist_row {
                sql = "update relations set deleted = 0 where re_id1=\(re_id1!) and re_id2=\(id) and re_table1_table2='\(re_table1_table2!)'"
            }
            _ = database_class(connect: .database).runSqlStatament(sql: sql)
        
        }
        
    }
    private func getData()->Any {
      if let theValue = data {
        return theValue
      } else {
        return NSNull()
      }
    }
   
    func is_exist_row(_ re_id1:Int,_ re_id2:Int,_ re_table1_table2:String) ->Bool
    {
        let sql = "select count(*) as cnt from relations where re_id1=\(re_id1) and re_id2=\(re_id2) and re_table1_table2='\(re_table1_table2)'"
        
        let count:[String:Any] = database_class(connect: .database).get_row(sql: sql) ?? [:]

        if (count["cnt"] as? Int ?? 0) > 0  {
            return true
        }
        return false
    }
    func getMaxCountPrint(re_id1:Int,re_table1_table2:String, deleted:Bool? = nil) ->Int{
        //select max(re_id2) as print_count from relations where re_id1=802 and re_table1_table2='pos_order|print_count'
        var sql = "select max(re_id2) as print_count from relations where re_id1=\(re_id1) and re_table1_table2='\(re_table1_table2)'"
        if let deleted_flag = deleted {
            sql += " and deleted = \(deleted_flag ? 1 : 0)"
        }

        var arr:[Int] = []
        
        let semaphore = DispatchSemaphore(value: 0)
        database_class().getDataBase().inDatabase { (db:FMDatabase) in
            
            let rows:FMResultSet? = try? db.executeQuery(sql , values:[])
            
            if rows != nil
            {
                while (rows!.next()) {
                           //retrieve values for each record
                           let  value  = Int( rows!.int(forColumn: "print_count"))
                           
                           arr.append(value)
                       }
                       rows!.close()
            }
       
            db.close()
            semaphore.signal()
        }
        
        
        semaphore.wait()
        
        return arr.first ?? 0
    }
    func get_relations_rows(re_id1:Int,re_table1_table2:String, deleted:Bool? = nil) ->[Int]
    {
        var sql = "select * from relations where re_id1=\(re_id1) and re_table1_table2='\(re_table1_table2)'"
        if let deleted_flag = deleted {
            sql += " and deleted = \(deleted_flag ? 1 : 0)"
        }

        var arr:[Int] = []
        
        let semaphore = DispatchSemaphore(value: 0)
        database_class().getDataBase().inDatabase { (db:FMDatabase) in
            
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
    
    func get_relations_rows_re_id1(re_id2:Int,re_table1_table2:String, deleted:Bool? = nil) ->[Int]
    {
        var sql = "select * from relations where re_id2=\(re_id2) and re_table1_table2='\(re_table1_table2)'"
        if let deleted_flag = deleted {
            sql += " and deleted = \(deleted_flag ? 1 : 0)"
        }
        var arr:[Int] = []
        
        let semaphore = DispatchSemaphore(value: 0)
        database_class().getDataBase().inDatabase { (db:FMDatabase) in
            
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
    
    
    func get_relations_rows(re_id1:Int? = nil,re_table1_table2:String , deleted:Bool? = nil) ->[String]
    {
        var sql = ""
 
         if re_id1 != nil
         {
            sql = "select * from relations where re_id1=\(re_id1!) and re_table1_table2='\(re_table1_table2)'"
        }
        else
         {
            sql = "select * from relations where   re_table1_table2='\(re_table1_table2)'"
        }
        if let deleted_flag = deleted {
            sql += " and deleted = \(deleted_flag ? 1 : 0)"
        }
        
        
        var arr:[String] = []
        
        let semaphore = DispatchSemaphore(value: 0)
        database_class().getDataBase().inDatabase { (db:FMDatabase) in
            
            let rows:FMResultSet? = try? db.executeQuery(sql , values:[])
            
            if rows != nil
            {
                while (rows!.next()) {
                    //retrieve values for each record
                    let  value  =  rows!.string(forColumn: "data") // Int( rows!.int(forColumn: "data"))
                    if value != nil
                    {
                        arr.append(value!)
                        
                    }
                }
                rows!.close()
            }
            db.close()
            
            semaphore.signal()
        }
        
        
        semaphore.wait()
        
        return arr
    }
   static func get_relations_id(re_id1:Int,re_id2:Int,re_table1_table2:String, deleted:Bool = false) ->[Int]
    {
        var sql = "select * from relations where re_id1=\(re_id1) and re_id2=\(re_id2) and re_table1_table2='\(re_table1_table2)'"
            sql += " and deleted = \(deleted ? 1 : 0)"
        var arr:[Int] = []
        
        let semaphore = DispatchSemaphore(value: 0)
        database_class().getDataBase().inDatabase { (db:FMDatabase) in
            
            let rows:FMResultSet? = try? db.executeQuery(sql , values:[])
            
            if rows != nil
            {
                while (rows!.next()) {
                           //retrieve values for each record
                           let  value  = Int( rows!.int(forColumn: "id"))
                           
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
    static func get_re_id1(for id:Int, deleted:Bool = false) ->[Int]
     {
         var sql = "select * from relations where id=\(id)"
             sql += " and deleted = \(deleted ? 1 : 0)"
         var arr:[Int] = []
         
         let semaphore = DispatchSemaphore(value: 0)
         database_class().getDataBase().inDatabase { (db:FMDatabase) in
             
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
    
    
}
