//
//  queue_log_class.swift
//  pos
//
//  Created by M-Wageh on 10/11/2021.
//  Copyright © 2021 khaled. All rights reserved.
//

import Foundation
enum state_printed_queue:Int{
    case none = 0 , not_printed,not_all_printed,printed
}
class queue_log_class: NSObject {
    
    var id : Int = 0
    var order_id : Int = 0
    var ip : String?
    var printer_name : String?
    var type_printer:String?
    var state_printed : state_printed_queue?
    var numb_lines : Int = 0
    var init_qty : Int = 0
    var last_qty : Int = 0

    var dbClass:database_class?
     
    override init() {
        dbClass = database_class(connect: .printer_log)
    }
    
    
    init(fromDictionary dictionary: [String:Any]){
        super.init()
        
        id = dictionary["id"] as? Int ?? 0
        order_id = dictionary["order_id"] as? Int ?? 0
        numb_lines = dictionary["numb_lines"] as? Int ?? 0
        init_qty = dictionary["init_qty"] as? Int ?? 0
        last_qty = dictionary["last_qty"] as? Int ?? 0

        state_printed = state_printed_queue.init(rawValue:dictionary["state_printed"] as? Int ?? 0)
        type_printer = dictionary["type_printer"] as? String ?? ""
        printer_name = dictionary["printer_name"] as? String ?? ""
        ip = dictionary["ip"] as? String ?? ""
        dbClass = database_class(table_name: "queue_log", dictionary: self.toDictionary(),id: id,id_key:"id",connect: .printer_log)
    }
    
    
    func toDictionary() -> [String:Any]
    {
        var dictionary:[String:Any] = [:]
        
        dictionary["printer_name"] = printer_name
        dictionary["state_printed"] = state_printed?.rawValue ?? state_printed_queue.none.rawValue
        dictionary["type_printer"] = type_printer
        dictionary["id"] = id
        dictionary["order_id"] = order_id
        dictionary["ip"] = ip ?? ""
        dictionary["numb_lines"] = numb_lines
        dictionary["last_qty"] = last_qty
        dictionary["init_qty"] = init_qty

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
          
          let cls = queue_log_class(fromDictionary: [:])
          let arr  = cls.dbClass!.get_rows(whereSql: "")
          return arr
          
      }
    static func getAll(limit:[Int]) ->  [[String:Any]] {
        
        let cls = queue_log_class(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(whereSql: " order by id desc limit \(limit[0]),\(limit[1]) ")
        return arr
        
    }
    static func deleteBefore(date:String?)   {
        
   
        if date != nil
        {
         
            let suc = database_class(connect: .printer_log).runSqlStatament(sql: "delete from queue_log where updated_at  < '\(date!)' OR updated_at == NULL")
            
        }
     
        
    }
}
