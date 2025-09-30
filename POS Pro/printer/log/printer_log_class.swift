//
//  cashClass.swift
//  pos
//
//  Created by Khaled on 4/15/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import UIKit


enum rowType:String {
    case none,order,kds,return_order,test,bill,history,report,scrap,error,insurance,note_printer,history_void,order_table
}

class printer_log_class: NSObject {
    
    static var  date_formate_database:String = "yyyy-MM-dd HH:mm:ss"

    
    var id : Int = 0
    var order_id : Int = 0
    var printed : Bool = false
    var sequence : Int = 0

    
    var ip : String?
    var printer_name : String?

    var status : String?
    var print_job_id : String?
    var start_at : String?
    var stop_at : String?
    var print_sequence : String?
    var row_type : rowType?
    var html : String?

    var wifi_ssid : String?

    var is_from_ip : Bool = false

    var dbClass:database_class?
     
    override init() {
        dbClass = database_class(connect: .printer_log)
    }
    
    
    init(fromDictionary dictionary: [String:Any]){
        super.init()
        
        id = dictionary["id"] as? Int ?? 0
        order_id = dictionary["order_id"] as? Int ?? 0
        sequence = dictionary["sequence"] as? Int ?? 0
        printed = dictionary["printed"] as? Bool ?? false

        
        printer_name = dictionary["printer_name"] as? String ?? ""
        ip = dictionary["ip"] as? String ?? ""
        status = dictionary["status"] as? String ?? ""
        print_job_id = dictionary["print_job_id"] as? String ?? ""
        start_at = dictionary["start_at"] as? String ?? ""
        stop_at = dictionary["stop_at"] as? String ?? ""
        print_sequence = dictionary["print_sequence"] as? String ?? ""
        print_sequence = dictionary["print_sequence"] as? String ?? ""
        html = dictionary["html"] as? String ?? ""
        wifi_ssid = dictionary["wifi_ssid"] as? String ?? ""

        row_type = rowType.init(rawValue:  dictionary["row_type"] as? String ?? rowType.none.rawValue)!
        is_from_ip = dictionary["is_from_ip"] as? Bool ?? false

        
        dbClass = database_class(table_name: "log", dictionary: self.toDictionary(),id: id,id_key:"id",connect: .printer_log)
    }
    
    
    func toDictionary() -> [String:Any]
    {
        var dictionary:[String:Any] = [:]
        
        dictionary["printer_name"] = printer_name
        dictionary["sequence"] = sequence
        dictionary["printed"] = printed
        dictionary["id"] = id
        dictionary["order_id"] = order_id
        dictionary["ip"] = ip ?? ""
        dictionary["status"] = status ?? ""
        dictionary["print_job_id"] = print_job_id ?? ""
        dictionary["start_at"] = start_at ?? ""
        dictionary["stop_at"] = stop_at ?? ""
        dictionary["print_sequence"] = print_sequence ?? ""
        dictionary["html"] = html ?? ""
        dictionary["wifi_ssid"] = wifi_ssid

        dictionary["row_type"] = row_type?.rawValue ?? rowType.none.rawValue
        dictionary["is_from_ip"] = is_from_ip

        return dictionary
    }
    
    
    
    func save()
    {
        dbClass?.dictionary = self.toDictionary()
        dbClass?.id = self.id
        dbClass?.insertId = false
        
        self.id =  dbClass!.save()
        
        
    }
    
 
    static func getAll() ->  [[String:Any]] {
          
          let cls = printer_log_class(fromDictionary: [:])
          let arr  = cls.dbClass!.get_rows(whereSql: "")
          return arr
          
      }
    static func getAll(limit:[Int]) ->  [[String:Any]] {
        
        let cls = printer_log_class(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(whereSql: " order by id desc limit \(limit[0]),\(limit[1]) ")
        return arr
        
    }
    
    
    static func search(any:String ,limit:[Int]) ->  [[String:Any]] {
        
        let cls = printer_log_class(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(whereSql: " where (ip || ' ' || print_sequence || order_id) like'%\(any)%'   order by id desc limit \(limit[0]),\(limit[1])   ")
        return arr
        
    }
    
    static func search(ip:String ,limit:[Int]) ->  [[String:Any]] {
        
        let cls = printer_log_class(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(whereSql: " where ip like'%\(ip)%'   order by id desc limit \(limit[0]),\(limit[1])   ")
        return arr
        
    }
    
    static func search(print_sequence:String ,limit:[Int]) ->  [[String:Any]] {
        
        let cls = printer_log_class(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(whereSql: " where print_sequence like'%\(print_sequence)%'   order by id desc limit \(limit[0]),\(limit[1])   ")
        return arr
        
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
    
    
    func add_message(_ msg:String)
    {

        print_sequence = (print_sequence ?? "") + "\n" + msg
        
        self.save()
    }
    
    
         func get_date_now_formate_datebase() -> String {
        
            return Date().toString(dateFormat: printer_log_class.date_formate_database, UTC: true)
     
    }
    static func deleteBefore(date:String?)   {
        
   
        if date != nil
        {
         
            let suc = database_class(connect: .printer_log).runSqlStatament(sql: "delete from log where updated_at  < '\(date!)' OR updated_at == NULL")
            
        }
     
        
    }
    static func countBefore(date:String?) -> Int   {
           
      
           if date != nil
           {
            
            let count:[String:Any] = database_class(connect: .log).get_row(sql: "select count(*) as cnt from log where updated_at  < '\(date!)' OR updated_at == NULL") ?? [:]

            return count["cnt"] as? Int ?? 0
             
           }
        
        return 0
           
       }
    
    static func vacuum_database()
         {
             let sql = "vacuum"
             
             let semaphore = DispatchSemaphore(value: 0)
             SharedManager.shared.printer_log_db!.inDatabase { (db:FMDatabase) in

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
        self.status = (self.status ?? "") + status + "\n"
    }
    
    static func checkExitsJob(_ currentLog:printer_log_class?) -> Bool{
        guard let current_log = currentLog else {
            return false
        }
        let current_html = (current_log.html ?? "").trim_before_item() //trim_html()
        if current_html.isEmpty {
            return false
        }
        let current_log_id = current_log.id

        let printer_name = current_log.printer_name ?? ""
        let current_order_id = current_log.order_id
        
        let cls = printer_log_class(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(whereSql: " where id != \(current_log_id) and printer_name = '\(printer_name)' and order_id = '\(current_order_id)' and row_type = 'kds' ")
       
        for dic in arr {
            let log = printer_log_class(fromDictionary: dic)
            if !(log.print_sequence?.lowercased().contains("can't") ?? false) {
                let html_log = (log.html ?? "").trim_before_item()
                if html_log.elementsEqual(current_html){
                    return true
                }
            }
        }
        
        return false
        
    }
    static func getLog(by id:Int) ->  [[String:Any]] {
          
          let cls = printer_log_class(fromDictionary: [:])
          let arr  = cls.dbClass!.get_rows(whereSql: "where id = \(id)")
          return arr
          
      }
    
    
}

 
