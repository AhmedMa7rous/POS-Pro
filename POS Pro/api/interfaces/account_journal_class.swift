//
//  posConfigClass.swift
//  pos
//
//  Created by khaled on 8/22/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

class account_journal_class: NSObject {
    var dbClass:database_class?
    
    var id : Int = 0
    var display_name : String = ""
    var type : String = ""
    var code : String = ""
    var payment_type : String = ""
   
    var sequence : Int = 0
    var __last_update : String?
    var image_small : String?

    
    
    // not used in database
    var rowIndex : Int  = 0
    var due : Double  = 0
    var tendered : String  = "0"
    var changes : Double  = 0
    var rest : Double  = 0
    
    var stc_account_code : String = ""
    var stc_username : String = ""
    var stc_password : String = ""
    
    var stc_test_account_code : String = ""
    var stc_test_username : String = ""
    var stc_test_password : String = ""
    var deleted : Bool = false

    var is_select:Bool = false
    var is_support_geidea:Bool = false

    
    // loyalty
//    var loyalty_amount_remaining:Double = 0
    
//   let const header_demo_stc  = [
//        "X-ClientCode" : "61263756001" ,
//        "X-UserName" : "@nm@RT3$tU$3R",
//        "X-Password" : "@Nm@RT3$tP@$$w0rd",
//        "Content-Type" : "application/json"
//    ]
    
 
    
    override init()
    {
        
    }
    
    
    init(fromDictionary dictionary: [String:Any]){
        super.init()
        
        id = dictionary["id"] as? Int ?? 0
        
        
        
        type = dictionary["type"] as? String ?? ""
        code = dictionary["code"] as? String ?? ""
        
        payment_type = dictionary["payment_type"] as? String ?? ""
        
        stc_account_code = dictionary["stc_account_code"] as? String ?? ""
        stc_username = dictionary["stc_username"] as? String ?? ""
        stc_password = dictionary["stc_password"] as? String ?? ""
        
        stc_test_account_code = dictionary["stc_test_account_code"] as? String ?? ""
        stc_test_username = dictionary["stc_test_username"] as? String ?? ""
        stc_test_password = dictionary["stc_test_password"] as? String ?? ""
        
        
        display_name = dictionary["display_name"] as? String ?? ""
        id = dictionary["id"] as? Int ?? 0
        sequence = dictionary["sequence"] as? Int ?? 0
        __last_update = dictionary["__last_update"] as? String
        image_small = dictionary["image_small"] as? String
        is_support_geidea = dictionary["is_support_geidea"] as? Bool ?? false
        if let is_support =  dictionary["is_support_geidea"] as? Bool {
            is_support_geidea = is_support
        } else{
            is_support_geidea = SharedManager.shared.is_account_journal_suport_geidea(id:dictionary["id"] as? Int ?? 0)
        }
        
        // not used in database
        //========================
        //        rowIndex = dictionary["rowIndex"] as?  Int ?? 0
        //        due = dictionary["due"] as?  Double ?? 0
        //        tendered = dictionary["tendered"] as?  String ?? ""
        //        changes = dictionary["changes"] as?  Double ?? 0
        //        rest = dictionary["rest"] as?  Double ?? 0
        //========================
        
        dbClass = database_class(table_name: "account_journal", dictionary: self.toDictionary(),id: id,id_key:"id")

    }
    
    func toDictionary() -> [String:Any]
    {
       var dictionary:[String:Any] = [:]
        // not used in database
        //========================
        
        //        dictionary["rowIndex"] = rowIndex
        //        dictionary["rest"] = rest
        //        dictionary["changes"] = changes
        //        dictionary["tendered"] = tendered
        //        dictionary["due"] = due
        //========================
        
        dictionary["display_name"] = display_name
        dictionary["id"] = id
        dictionary["type"] = type
        dictionary["sequence"] = sequence
        
        dictionary["code"] = code
        
        
        dictionary["payment_type"] = payment_type
        dictionary["stc_account_code"] = stc_account_code
        dictionary["stc_username"] = stc_username
        dictionary["stc_password"] = stc_password
        dictionary["__last_update"] = __last_update
        dictionary["image_small"] = image_small

        
        dictionary["stc_test_account_code"] = stc_test_account_code
        dictionary["stc_test_username"] = stc_test_username
        dictionary["stc_test_password"] = stc_test_password
        dictionary["deleted"] = deleted

        dictionary["is_support_geidea"] = is_support_geidea
        
        
        return dictionary
        
    }
    
    static func reset(temp:Bool = false)
    {
        let cls = account_journal_class(fromDictionary: [:])
        
        var table = cls.dbClass!.table_name
         if temp
         {
            table =   "temp_" + cls.dbClass!.table_name
         }
        _ =   cls.dbClass!.runSqlStatament(sql: "update \(table) set deleted = 1")

//      _ =  cls.dbClass?.runSqlStatament(sql: "delete from \(table)")
        
 
        
    }
    
    func save(temp:Bool = false)
    {
        dbClass?.dictionary = self.toDictionary()
        dbClass?.id = self.id
        if temp
        {
            dbClass!.table_name =  "temp_" + dbClass!.table_name
        }
        
        _ =  dbClass!.save()
        
        
    }
    
    
    static func saveAll(arr:[[String:Any]],temp:Bool = false)
    {
        for item in arr
        {
            let pos = account_journal_class(fromDictionary: item)
            pos.deleted = false
            pos.dbClass?.insertId = true
            pos.save(temp: temp)
        }
    }
    
    static func getAll(delet:Bool? = nil,showCashMethodOnly:Bool = false) ->  [[String:Any]] {
        
        let cls = account_journal_class(fromDictionary: [:])
        var cashOnlySql = ""
        var sql = ""
        if let delet = delet {
            sql = "where account_journal.deleted = \(delet ?1:0)"
        }
        if showCashMethodOnly {
            //cashOnlySql =  " and account_journal.type = 'cash' "
        }
        let arr  = cls.dbClass!.get_rows(whereSql: "\(sql) \(cashOnlySql) order by 'sequence'")
        return arr
        
    }
    
    
    static func get(id:Int) ->account_journal_class?
    {
        var cls = account_journal_class(fromDictionary: [:])
        
        let row:[String:Any]?  = cls.dbClass!.get_row(whereSql: "where id =\(id)")
        if row != nil
        {
            cls = account_journal_class(fromDictionary: row!)
            
            return cls
        }
        
        return nil
    }
    
 
    static func get_cash_default() ->account_journal_class?
    {
        var cls = account_journal_class(fromDictionary: [:])
        
        let row:[String:Any]?  = cls.dbClass!.get_row(whereSql: "where type ='cash' limit 0,1")
        if row != nil
        {
            cls = account_journal_class(fromDictionary: row!)
            
            return cls
        }
        
        return nil
    }
    
    static func get_stc_default() ->account_journal_class?
    {
        var cls = account_journal_class(fromDictionary: [:])
        
        let row:[String:Any]?  = cls.dbClass!.get_row(whereSql: "where payment_type ='stc' limit 0,1")
        if row != nil
        {
            cls = account_journal_class(fromDictionary: row!)
            
            return cls
        }
        
        return nil
    }
    
    static func get_loyalty_default() ->account_journal_class?
    {
        var cls = account_journal_class(fromDictionary: [:])
        
        let row:[String:Any]?  = cls.dbClass!.get_row(whereSql: "where payment_type ='loyalty' limit 0,1")
        if row != nil
        {
            cls = account_journal_class(fromDictionary: row!)
//            cls.id = 30
            return cls
        }
        
        return nil
    }
    static func get_bank_account(_ is_geidea:Bool = false,ids:[Int] = []) ->[account_journal_class]?
    {
        let idsString = ids.map({"\($0)"}).joined(separator: ",")
        let cls = account_journal_class(fromDictionary: [:])
        var sql = "where type = 'bank' and payment_type !='stc' "
        if is_geidea {
            sql += " and is_support_geidea = 1"
        }
        if !idsString.isEmpty{
            sql += " and id in (\(idsString))"
        }
        let arr  = cls.dbClass!.get_rows(whereSql: sql + " order by 'sequence' " )
        return arr.map(){account_journal_class(fromDictionary: $0)}
    }
    static func set_is_support_geidea(for items:[account_journal_class]) {
        if items.count <= 0 {
            return
        }
        let ids = items.map(){"\($0.id)"}.joined(separator: ",")
        cash_data_class.set(key: "journal_accounts_support_geidea", value:ids )

        let sql =  """
        UPDATE
            account_journal
        SET
            is_support_geidea = 1
        WHERE
            id IN ( \(ids) );
        """

            
            let semaphore = DispatchSemaphore(value: 0)
            SharedManager.shared.database_db!.inDatabase { (db:FMDatabase) in
                
                let resutl =  db.executeStatements(sql)
                if !resutl
                {
                    let error = db.lastErrorMessage()
                   SharedManager.shared.printLog("database Error : \(error)" )
                }
                db.close()
                semaphore.signal()
            }
            semaphore.wait()
    }
    static func rest_is_support_geidea(){
        let sql =  """
        UPDATE
            account_journal
        SET
            is_support_geidea = 0 ;
        """

            
            let semaphore = DispatchSemaphore(value: 0)
            SharedManager.shared.database_db!.inDatabase { (db:FMDatabase) in
                
                let resutl =  db.executeStatements(sql)
                if !resutl
                {
                    let error = db.lastErrorMessage()
                   SharedManager.shared.printLog("database Error : \(error)" )
                }
                db.close()
                semaphore.signal()
            }
            semaphore.wait()
    }
    func getPaymentMean()->PAYMENT_MEANS_CODE{
        if self.type == "bank"  {
            return PAYMENT_MEANS_CODE.bank
        }
        if self.type == "cash"  {
            return PAYMENT_MEANS_CODE.cash
        }
        return PAYMENT_MEANS_CODE.unknown

    }
    static func get(ids:[Int]) ->  [[String:Any]] {
        if ids.count == 0
        {
            return []
        }
        
        var str_ids = ""
        for i in ids
        {
            str_ids = str_ids + "," + String(i)
        }
        
        str_ids.removeFirst()
        
        let cls = account_journal_class(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(whereSql: "where id in (\(str_ids)) ")
        return arr
        
    }
}
