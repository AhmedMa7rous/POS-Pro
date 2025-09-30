//
//  pendingClass.swift
//  pos
//
//  Created by Khaled on 3/9/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import UIKit

class  pendingOpetions
{
    var is_synced:Bool? = false
    var getCount:Bool? = false
    var orderID:Int?
    var id_server:Int?
    var id:Int?
    var key:String?
    var orderDesc:Bool?
    var LIMIT:[Int]?
    
    
}

class pendingClass: NSObject {
    
    public var id:Int?
    public var id_server:Int?
    public var order_id:Int?
    
    public var key : String?
    public var data : String?
    
    override init() {
    }
    
    
    init(with_id:Int) {
        super.init()
        
        let cls = get_pending(id: with_id)
        if cls != nil
        {
            self.id = cls?.id
            self.id_server = (cls?.id_server == 0 ) ? nil :  cls?.id_server
            self.order_id = (cls?.order_id  == 0 ) ? nil :  cls?.order_id
            self.key = cls?.key
            self.data = cls?.data
        }
    }
    
    init(fromDictionary dictionary: [String:Any]) {
        
        id = dictionary["id"] as? Int ?? 0
        id_server = dictionary["id_server"] as? Int
        order_id = dictionary["order_id"] as? Int
        
        key = dictionary["key"] as? String ?? ""
        data = dictionary["data"] as? String ?? ""
        
        
    }
    
    public func toDictionary() -> [String:Any] {
        
        var dictionary:[String:Any] = [:]
        dictionary["id"] = self.id
        dictionary["id_server"] = self.id_server
        
        dictionary["order_id"] = self.order_id
        dictionary["key"] = self.key
        dictionary["data"] = self.data
        
        
        return dictionary
    }
    
    
    func delete()
    {
        let semaphore = DispatchSemaphore(value: 0)
        
        
        SharedManager.shared.database_db!.inDatabase { (db:FMDatabase) in
            
            let success = db.executeUpdate(
                "delete from pending where id =?"
                , withArgumentsIn: [self.id! ]  )
            
            if !success
            {
                let error = db.lastErrorMessage()
                print("database Error : %@" , error)
            }
            
            semaphore.signal()
        }
        
        semaphore.wait()
    }
    func save()
    {
        let semaphore = DispatchSemaphore(value: 0)
        
        //         let data =   JsonToDictionary.jsonString(with: self.toDictionary(), prettyPrinted: true)  ?? ""
        
        SharedManager.shared.database_db!.inDatabase { (db:FMDatabase) in
            
            if id == nil
            {
                let success = db.executeUpdate(
                    "insert into pending (id_server,order_id,key,data) VALUES (?,?,?,?) "
                    , withArgumentsIn: [id_server  ?? NSNull(),  order_id  ?? NSNull(), self.key!,data! ]  )
                
                if !success
                {
                    let error = db.lastErrorMessage()
                    print("database Error : %@" , error)
                }
            }
            else
            {
                
                let success = db.executeUpdate(
                    "update pending set id_server =? ,order_id=? ,key=? ,data=? where id=? "
                    , withArgumentsIn: [id_server  ?? NSNull(),  order_id  ?? NSNull(), self.key!,data! ,self.id! ]  )
                
                if !success
                {
                    let error = db.lastErrorMessage()
                    print("database Error : %@" , error)
                }
            }
            
            semaphore.signal()
        }
        
        semaphore.wait()
        
        
    }
    
    
    static func get_status_sorted_Sql(options:pendingOpetions   ) -> String
    {
        
        var sql =  "select * from pending   "
        if  options.getCount == true
        {
            sql = "select count(*) from pending  "
        }
        
        var list_where:[String] = []
        if options.id != nil
        {
            list_where.append("id = \(options.id!)")
        }
        
        if options.id_server != nil
        {
            list_where.append("id_server = \(options.id_server!)")
        }
        
        if options.key != nil
        {
            list_where.append("key = '\(options.key!)'")
        }
        
        if options.orderID != nil
        {
            list_where.append("orderID = \(options.orderID!)")
        }
        
        if options.is_synced != nil
        {
            if options.is_synced == true
            {
                list_where.append("id_server is not null")
            }
            else
            {
                list_where.append("id_server is  null")
            }
            
        }
        
        
        if list_where.count > 0
        {
            sql = sql + " where "
            
            var and = ""
            for wh in list_where
            {
                sql = String(format: "%@ %@ %@", sql , and , wh)
                
                if and == ""
                {
                    and = "and"
                }
            }
            
        }
        
        
        
        if options.orderDesc == false
        {
            sql = String(format: "%@ %@", sql , "order by  id asc")
        }
        else
        {
            sql = String(format: "%@ %@", sql , "order by  id desc")
            
        }
        
        if options.LIMIT != nil
        {
            
            sql = String(format: "%@ LIMIT %d,%d", sql , options.LIMIT![0], options.LIMIT![1])
            
        }
        
        
        return sql
    }
    
    
    static func get_status_sorted(options:pendingOpetions ) -> [pendingClass]
    {
        var list:[pendingClass] = []
        
        // =====================================================================================
        let sql = get_status_sorted_Sql(options: options )
        
        let semaphore = DispatchSemaphore(value: 0)
        SharedManager.shared.database_db!.inDatabase { (db:FMDatabase) in
            
            let rows:FMResultSet = try!   db.executeQuery(sql, values: [])
            while (rows.next()) {
                //retrieve values for each record
                let data = rows.string(forColumn: "data")
                let dic =  data?.toDictionary() ?? [:]
                
                let cls = pendingClass(fromDictionary: dic)
                
                cls.id = Int(rows.int(forColumn: "id"))
                cls.order_id = Int(rows.int(forColumn: "order_id"))
                cls.id_server = Int(rows.int(forColumn: "id_server"))
                cls.key =  rows.string(forColumn: "key")
                cls.data = data
                
                list.append(cls)
            }
            
            rows.close()
            
            semaphore.signal()
        }
        
        
        semaphore.wait()
        // =====================================================================================
        
        return list
    }
    
    static func get_status_sorted(options:pendingOpetions ) -> [[String: Any]]
    {
        var list:[[String: Any]] = []
        
        // =====================================================================================
        let sql = get_status_sorted_Sql(options: options )
        
        let semaphore = DispatchSemaphore(value: 0)
        SharedManager.shared.database_db!.inDatabase { (db:FMDatabase) in
            
            let rows:FMResultSet = try!   db.executeQuery(sql, values: [])
            while (rows.next()) {
                //retrieve values for each record
                let data = rows.string(forColumn: "data")
                var dic =  data?.toDictionary() ?? [:]
                
                dic["pending_id"] = Int(rows.int(forColumn: "id"))
                dic["pending_order_id"] = Int(rows.int(forColumn: "order_id"))
                dic["pending_id_server"] = Int(rows.int(forColumn: "id_server"))
                dic["pending_key"] = rows.string (forColumn: "key")
                
                list.append(dic)
            }
            
            rows.close()
            
            semaphore.signal()
        }
        
        
        semaphore.wait()
        // =====================================================================================
        
        return list
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
    
    static func get_status_sorted_count(options:pendingOpetions ) -> Int
    {
        
        options.getCount = true
        let sql = get_status_sorted_Sql(options:options )
        let totalCount = get_count(sql: sql)
        
        options.getCount = false
        
        return totalCount
    }
    
    func get_pending(id:Int) -> pendingClass?
    {
        let option = pendingOpetions()
        option.id =  id
        
        let list:[pendingClass] = pendingClass.get_status_sorted(options: option)
        if list.count > 0
        {
            
            return list[0]
        }
        
        return nil
    }
}
