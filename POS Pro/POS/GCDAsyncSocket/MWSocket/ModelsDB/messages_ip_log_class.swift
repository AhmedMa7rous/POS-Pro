//
//  messages_ip_log_class.swift
//  pos
//
//  Created by M-Wageh on 10/09/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation

class messages_ip_log_class: NSObject {
    
    static var  date_formate_database:String = "yyyy-MM-dd HH:mm:ss"
    
    
    var id : Int = 0
    var from_ip : String?
    var to_ip : String?
    var status : String?
    var body : String?
    var response : String?
    var wifi_ssid : String?
    
    var dbClass:database_class?
    var isFaluire:Bool?
    var messageIdentifier : String?

    override init() {
        dbClass = database_class(connect: .meesage_ip_log)
    }
    
    
    init(fromDictionary dictionary: [String:Any]){
        super.init()
        
        id = dictionary["id"] as? Int ?? 0
        status = dictionary["status"] as? String ?? ""
        from_ip = dictionary["from_ip"] as? String ?? ""
        to_ip = dictionary["to_ip"] as? String ?? ""
        body = dictionary["body"] as? String ?? ""
        response = dictionary["response"] as? String ?? ""
        wifi_ssid = dictionary["wifi_ssid"] as? String ?? ""
        isFaluire =  dictionary["isFaluire"] as? Bool ?? false
        messageIdentifier = dictionary["messageIdentifier"] as? String ?? ""

        dbClass = database_class(table_name: "log", dictionary: self.toDictionary(),id: id,id_key:"id",connect: .meesage_ip_log)
    }
    
    
    func toDictionary() -> [String:Any]
    {
        var dictionary:[String:Any] = [:]
        
        dictionary["status"] = status
        dictionary["from_ip"] = from_ip
        dictionary["to_ip"] = to_ip
        dictionary["body"] = body
        dictionary["response"] = response ?? ""
        dictionary["wifi_ssid"] = wifi_ssid ?? ""
        dictionary["isFaluire"] = isFaluire ?? false
        dictionary["messageIdentifier"] = messageIdentifier ?? ""

        return dictionary
    }
    
    
    
    func save()
    {
        dbClass?.dictionary = self.toDictionary()
//        dbClass?.id = self.id
//        dbClass?.insertId = false
        
        self.id =  dbClass!.save()
        
        
    }
    
    
    static func getAll() ->  [[String:Any]] {
        
        let cls = messages_ip_log_class(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(whereSql: "")
        return arr
        
    }
    static func getAll(limit:[Int]) ->  [[String:Any]] {
        
        let cls = messages_ip_log_class(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(whereSql: " order by id desc limit \(limit[0]),\(limit[1]) ")
        return arr
        
    }
    
    
    static func search(any:String ,limit:[Int]) ->  [[String:Any]] {
        
        let cls = messages_ip_log_class(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(whereSql: " where (from_ip || ' ' || to_ip || body) like'%\(any)%'   order by id desc limit \(limit[0]),\(limit[1])   ")
        return arr
        
    }
    
    static func isExist(body keyWord:String ) ->  Bool {
        let count:[String:Any] = database_class(connect: .meesage_ip_log).get_row(sql: "select count(*) as cnt from log where messageIdentifier like'%\(keyWord)%' ") ?? [:]
        
        return (count["cnt"] as? Int ?? 0) > 0
        
    }
    
    
    static func deleteAll()   {
        _ = database_class(connect: .meesage_ip_log).runSqlStatament(sql: "delete from log")
    }
    
    
    func get_date_now_formate_datebase() -> String {
        
        return Date().toString(dateFormat: messages_ip_log_class.date_formate_database, UTC: true)
        
    }
    static func deleteBefore(date:String?)   {
        
        
        if date != nil
        {
            
            let suc = database_class(connect: .meesage_ip_log).runSqlStatament(sql: "delete from log where updated_at  < '\(date!)' OR updated_at == NULL")
            
            SharedManager.shared.printLog(suc)
        }
        
        
    }
    static func countBefore(date:String?) -> Int   {
        
        
        if date != nil
        {
            
            let count:[String:Any] = database_class(connect: .meesage_ip_log).get_row(sql: "select count(*) as cnt from log where updated_at  < '\(date!)' OR updated_at == NULL") ?? [:]
            
            return count["cnt"] as? Int ?? 0
            
        }
        
        return 0
        
    }
    
    static func vacuum_database()
    {
        let sql = "vacuum"
        
        let semaphore = DispatchSemaphore(value: 0)
        SharedManager.shared.message_ip_log_db!.inDatabase { (db:FMDatabase) in
            
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
    
    
    func addStatus(_ status:String){
        self.status = (self.status ?? "") + status + "at [\(Date().toString(dateFormat: baseClass.date_fromate_satnder, UTC: true))] " + "\n"
    }
    
    
    static func getLog(by id:Int) ->  [[String:Any]] {
        
        let cls = messages_ip_log_class(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(whereSql: "where id = \(id)")
        return arr
        
    }
    
    
}


