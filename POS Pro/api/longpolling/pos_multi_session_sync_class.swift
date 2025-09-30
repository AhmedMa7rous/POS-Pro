//
//  pos_multi_session_sync.swift
//  pos
//
//  Created by Khaled on 4/27/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import UIKit
import JavaScriptCore



class pos_multi_session_sync_class: NSObject {
    var dbClass:database_class?
    var load_kds: Bool = false
    
    
    let con = SharedManager.shared.conAPI()
    
    var id : Int = 0
    var last_id : Int?
    
    var action : String?
    var name : String? // order name as  "name": "Order 00979-018-0007",
    var uid : String? //    "uid": "00979-018-0007",
    
    var revision_ID : Int?
    var run_ID : Int?
    var message_ID : Int?
    
    var data : String?
 
    var con_timeout:TimeInterval = 60
    var scandWait:Int = 1
    
    //====================================
    // options (not in database)
    var order_on_server:Bool = false
    var new_order:Bool = false
    
    var pos_id : Int = 0
    
    var create_user_id : Int?
    var write_user_id : Int?
    var create_pos_id : Int?
    var write_pos_id : Int?
    
    var create_user_name : String?
    var write_user_name : String?
    var create_pos_name : String?
    var write_pos_name : String?
    
    
    
    var is_running:Bool = false
    var sync_all_running:Bool = false

    var list_exist_message_id:[Int] = []

    override init() {
        
    }
    
    
    /**
     * Instantiate the instance using the passed dictionary values to set the properties values
     */
    init(fromDictionary dictionary: [String:Any]){
        super.init()
        
        id = dictionary["id"] as? Int ?? 0
        revision_ID = dictionary["revision_ID"] as? Int ?? 0
        run_ID = dictionary["run_ID"] as? Int ?? SharedManager.shared.getCashRunId()
        message_ID = dictionary["message_ID"] as? Int ?? 0
        last_id = dictionary["last_id"] as? Int  
        
        
        
        uid = dictionary["uid"] as? String ?? ""
        name = dictionary["name"] as? String ?? ""
        
        action = dictionary["action"] as? String ?? ""
        data = dictionary["data"] as? String ?? ""
        
        
        
        dbClass = database_class(table_name: "pos_multi_session_sync", dictionary: self.toDictionary(),id: id,id_key:"id")
        
        
        
    }
    
    func toDictionary() -> [String:Any]
    {
        var dictionary:[String:Any] = [:]
        
        dictionary["uid"] = uid
        
        dictionary["name"] = name
        
        dictionary["id"] = id
        dictionary["last_id"] = last_id
        
        dictionary["revision_ID"] = revision_ID
        dictionary["run_ID"] = run_ID
        
        
        dictionary["message_ID"] = message_ID
        dictionary["action"] = action
        dictionary["data"] = data
        
        
        
        return dictionary
    }
    
    
    
    func nonce()-> String
    {
        let jsSource = "var testFunct = function() {return (Math.random() + 1).toString(36).substring(7);}"
        
        let context = JSContext()
        context?.evaluateScript(jsSource)
        
        let testFunction = context?.objectForKeyedSubscript("testFunct")
        let result = testFunction?.call(withArguments: [""])?.toString()
        
        return result!
    }
    
    
    func save()
    {
        dbClass?.dictionary = self.toDictionary()
        dbClass?.id = self.id
        
        
        self.id =  dbClass!.save()
        
        
    }
    
    static func get(uid:String ) -> pos_multi_session_sync_class
    {
        var cls = pos_multi_session_sync_class(fromDictionary: [:])
        let item  = cls.dbClass!.get_row(whereSql: " where uid = '\(uid)'")
        if item != nil
        {
            cls =  pos_multi_session_sync_class(fromDictionary: item!)
        }
        
        return cls
    }
    
    static func save_last_id(last_id:Int)
    {
        let cls = pos_multi_session_sync_class(fromDictionary: [:])
        let row   = cls.dbClass!.get_row(whereSql: " where action = 'last_id'")
        if row != nil
        {
            _  = cls.dbClass!.runSqlStatament(sql: "update pos_multi_session_sync set last_id = \(last_id) where action = 'last_id'")
        }
        else
        {
 
            _  = cls.dbClass!.runSqlStatament(sql: "insert into pos_multi_session_sync (last_id,action,revision_ID,run_ID,message_ID) values (\(last_id),'last_id',0,0,0)")
        }
    }
    
    static func get_last_id() -> Int
    {
        let cls = pos_multi_session_sync_class(fromDictionary: [:])
        let row   = cls.dbClass!.get_row(whereSql: "where action = 'last_id'  ")
        if row != nil
        {
//            let item = rows[0]
            let last_id = row!["last_id"]
            
            return last_id as? Int ?? 0
        }
        
        return 0
    }
    
    
    static func clear()
    {
        let cls = pos_multi_session_sync_class(fromDictionary: [:])
        _  = cls.dbClass!.runSqlStatament(sql: "delete from pos_multi_session_sync")
        
    }
    
}


