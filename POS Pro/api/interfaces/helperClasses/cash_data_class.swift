//
//  cashClass.swift
//  pos
//
//  Created by Khaled on 4/15/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import UIKit

class cash_data_class: NSObject {
    
    var id : Int = 0
    var key : String?
    var value : String?
    
    var dbClass:database_class?
    
    
    var enableCash:Bool = true
    var TimeToReloadCash:Int = 0
    
    let lastupdate_prefex = "lastupdate"
    
    
    init(_ ReloadEveryMinute:Int) {
        TimeToReloadCash = ReloadEveryMinute
    }
    
    init(_ ReloadEveryMinute:Double) {
        TimeToReloadCash = Int(ReloadEveryMinute)
    }
    
    
    override init() {
    }
    
    
    init(fromDictionary dictionary: [String:Any]){
        super.init()
        
        id = dictionary["id"] as? Int ?? 0
        key = dictionary["key"] as? String ?? ""
        value = dictionary["value"] as? String ?? ""
        
        dbClass = database_class(table_name: "cash_data", dictionary: self.toDictionary(),id: id,id_key:"id")
    }
    
    
    func toDictionary() -> [String:Any]
    {
        var dictionary:[String:Any] = [:]
        
        
        dictionary["id"] = id
        dictionary["key"] = key ?? ""
        dictionary["value"] = value ?? ""
        
        return dictionary
    }
    
    static func set(key:String,value:String)
    {
        let cash = getCash(key: key)
        cash.key = key
        cash.value = value
        
        cash.save()
    }
    
    static func get(key:String) -> String?
    {
        return getCash(key: key).value
    }
    
    static func remove(key:String)
    {
        let cash = getCash(key: key)
        _ = cash.dbClass?.remove()
    }
    
    static  func getCash(key:String) -> cash_data_class {
        
        var cash = cash_data_class(fromDictionary: [:])
        
        let row:[String:Any]?   = cash.dbClass!.get_row(whereSql: "where key = '\(key)'") ?? [:]
        if row != nil
        {
            cash = cash_data_class(fromDictionary: row!)
            
        }
        return cash
        
    }
    
    
    func save()
    {
        dbClass?.dictionary = self.toDictionary()
        dbClass?.id = self.id
        
        _ =  dbClass!.save()
        
        
    }
    
    
}


extension cash_data_class
{
    
    func getTimelastupdate(_ key:String) -> String?
    {
        return cash_data_class.get(key: lastupdate_prefex + "_" + key)
    }
    
    func setTimelastupdate(_ key:String)
    {
        
        cash_data_class.set(key: lastupdate_prefex + "_" + key, value: String(Date.currentDateTimeMillis()))
    }
    
    
    func isTimeTopdate(_ key:String) -> Bool
    {
        
        //      return true
        
        if enableCash == false
        {
            return true
        }
        else
        {
            let dt = getTimelastupdate(key)
            if (dt ?? "").isEmpty
            {
                return true
            }
            
            let dt_int = Int64(dt!) ?? 0
            let time_now = Date.currentDateTimeMillis()
            let diff = time_now - dt_int
            
            let day =  TimeToReloadCash * 60 * 1000
            
            if diff >= day && key != "api_loaded"
            {
                return true
            }
            else
            {
                return false
            }
            
            
        }
        
    }
    
    func saveData( url:String ,keydata:String , dictionary:[String:Any])
    {
        
    }
    
    func getSavedLastData( url:String ,keydata:String ) -> [String:Any]?
    {
        return nil
    }
    
    func getLastData( url:String ,keydata:String , UseCash:Bool , checkInternet:Bool) -> [String:Any]?
    {
        
        return nil
    }
    
}
