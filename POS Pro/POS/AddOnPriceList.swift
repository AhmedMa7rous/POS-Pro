//
//  AddOnPriceList.swift
//  pos
//
//  Created by M-Wageh on 15/08/2023.
//  Copyright © 2023 khaled. All rights reserved.
//

import Foundation
//product.combo.price.line
class pos_line_add_on_price_list_class:NSObject{
    var dbClass:database_class?
    var id : Int = 0
    var line_uid : String = ""
    var product_combo_price_line_ids:String = ""
    var extra_price:Double = 0
    init(fromDictionary dictionary: [String:Any]){
        super.init()
        id = dictionary["id"] as? Int ?? 0
        line_uid = dictionary["line_uid"] as? String ?? ""
        product_combo_price_line_ids = dictionary["product_combo_price_line_ids"] as? String ?? ""
        extra_price = dictionary["extra_price"] as? Double ?? 0
        dbClass = database_class(table_name: "pos_line_add_on_price_list", dictionary: self.toDictionary(),id: id,id_key:"id")
    }
    func toDictionary() -> [String:Any]
    {
        var dictionary:[String:Any] = [:]
        dictionary["id"] = id
        dictionary["line_uid"] = line_uid
        dictionary["product_combo_price_line_ids"] = product_combo_price_line_ids
        dictionary["extra_price"] = extra_price

        return dictionary
    }
    func save()
    {
        dbClass?.dictionary = self.toDictionary()
        dbClass?.id = self.id
        _ =  dbClass!.save()
    }
    static func addOrUpdate(lineUID:String,product_combo_price_line_ids:String,extraPrice:Double){
        let cls = pos_line_add_on_price_list_class(fromDictionary: [:])
        if let currentRow:[String:Any] = cls.dbClass?.get_row(whereSql: "where line_uid = '\(lineUID)'"){
            let exist_cls = pos_line_add_on_price_list_class(fromDictionary: currentRow)
            exist_cls.product_combo_price_line_ids = product_combo_price_line_ids
            exist_cls.extra_price = extraPrice
            cls.save()
        }else{
            cls.line_uid = lineUID
            cls.product_combo_price_line_ids = product_combo_price_line_ids
            cls.extra_price = extraPrice
            cls.save()
        }
    }
    static func getPriceAddon(for lineUID:String,priceListID:Int) -> Double?{
        let cls = pos_line_add_on_price_list_class(fromDictionary: [:])
        var addonPriceListIds = ""
        let addOnPriceListIDSSql = """
        SELECT
        product_combo_price_line_ids  as ids
        from
        pos_line_add_on_price_list
        WHERE
        line_uid = '\(lineUID)'
        """
        
        if let result:[String:Any] = cls.dbClass?.get_row(sql: addOnPriceListIDSSql){
            if let ids = result["ids"] as? String{
                addonPriceListIds  = ids
            }
            
        }
        
        var price:Double? = nil
        if !addonPriceListIds.isEmpty{
            let sql = """
SELECT
    price
from
    product_combo_price_line
WHERE
    product_combo_price_line.id in (\(addonPriceListIds))
    and price_list_id = \(priceListID)
"""
            if let result:[String:Any] = cls.dbClass?.get_row(sql: sql){
                if let priceResult = result["price"] as? Double  {
                    return priceResult
                }
            }
        }
        
        let extraPriceSql = """
            SELECT  extra_price from pos_line_add_on_price_list WHERE line_uid = '\(lineUID)'
"""
        if let result:[String:Any] = cls.dbClass?.get_row(sql: extraPriceSql){
            if let extraPriceResult = result["extra_price"] as? Double  {
                return extraPriceResult
            }
        }
        
        
        return price
        
    }
}
class product_combo_price_line_class: NSObject {
    var dbClass:database_class?
    
    var id : Int = 0
    
    var display_name : String = ""
    
    var __last_update : String = ""
    
    var price_list_id: Int = 0
    var price_list_name: String = ""
    
    
    var combo_price_id : Int = 0
    var combo_price_name: String = ""
    
    var product_tmpl_id : Int = 0
    var product_tmpl_id_name: String = ""

    var product_id : Int = 0
    var product_id_name: String = ""

    var attribute_value_id : Int = 0
    var attribute_value_id_name: String = ""

    var price : Double = 0.0
    var deleted : Bool = false

    
    
    
    
    init(fromDictionary dictionary: [String:Any]){
        super.init()
        
        id = dictionary["id"] as? Int ?? 0
        
                
        display_name = dictionary["display_name"] as? String ?? ""
        __last_update = dictionary["__last_update"] as? String ?? ""
        
        
        //        price_list_id = (dictionary["price_list_id"]as? [Any] ?? []).getIndex(0) as? Int ?? 0
        price_list_id = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "price_list_id", keyOfDatabase: "price_list_id",Index: 0) as? Int ?? 0
        price_list_name = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "price_list_id", keyOfDatabase: "price_list_name",Index: 1)as? String  ?? ""
        
        //        combo_price_id = (dictionary["combo_price_id"]as? [Any] ?? []).getIndex(0) as? Int ?? 0
        combo_price_id = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "combo_price_id", keyOfDatabase: "combo_price_id",Index: 0) as? Int ?? 0
        combo_price_name = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "combo_price_id", keyOfDatabase: "combo_price_name",Index: 1) as? String  ?? ""
        
        
        product_tmpl_id = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "product_tmpl_id", keyOfDatabase: "product_tmpl_id",Index: 0) as? Int ?? 0
        product_tmpl_id_name = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "product_tmpl_id", keyOfDatabase: "product_tmpl_id_name",Index: 1) as? String  ?? ""

        product_id = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "product_id", keyOfDatabase: "product_id",Index: 0) as? Int ?? 0
        product_id_name = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "product_id", keyOfDatabase: "product_id_name",Index: 1) as? String  ?? ""

        attribute_value_id = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "attribute_value_id", keyOfDatabase: "attribute_value_id",Index: 0) as? Int ?? 0
        attribute_value_id_name = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "attribute_value_id", keyOfDatabase: "attribute_value_id_name",Index: 1) as? String  ?? ""

        price = dictionary["price"] as? Double ?? 0.0
        
        dbClass = database_class(table_name: "product_combo_price_line", dictionary: self.toDictionary(),id: id,id_key:"id")
        
    }
    
    
    func toDictionary() -> [String:Any]
    {
        var dictionary:[String:Any] = [:]
        
        dictionary["id"] = id
        dictionary["display_name"] = display_name
        dictionary["__last_update"] = __last_update
        
        dictionary["price_list_id"] = price_list_id
        dictionary["price_list_name"] = price_list_name
        dictionary["combo_price_id"] = combo_price_id
        dictionary["combo_price_name"] = combo_price_name
        dictionary["product_tmpl_id"] = product_tmpl_id
        dictionary["product_tmpl_id_name"] = product_tmpl_id_name
        dictionary["product_id"] = product_id
        dictionary["product_id_name"] = product_id_name
        
        dictionary["attribute_value_id"] = attribute_value_id
        dictionary["attribute_value_id_name"] = attribute_value_id_name

        dictionary["price"] = price
        dictionary["deleted"] = deleted

        
        return dictionary
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
    
    static func reset(temp:Bool = false)
    {
        let cls = product_combo_price_line_class(fromDictionary: [:])
        
        var table = cls.dbClass!.table_name
         if temp
         {
            table =   "temp_" + cls.dbClass!.table_name
         }
        
        _ =   cls.dbClass!.runSqlStatament(sql: "update \(table) set deleted = 1")

//      _ =  cls.dbClass?.runSqlStatament(sql: "delete from \(table)")
        
 
        
    }
    
     static func clear()
     {
         let cls = product_combo_price_line_class(fromDictionary: [:])
        _  = cls.dbClass!.runSqlStatament(sql: "delete from product_combo_price_line")
     }
    
    static func saveAll(arr:[[String:Any]],temp:Bool = false)
    {
        clear()
        
        for item in arr
        {
            let pos = product_combo_price_line_class(fromDictionary: item)
            pos.deleted = false
            pos.dbClass?.insertId = true
            pos.save(temp: temp)
        }
    }
    
    static func getAll() ->  [[String:Any]] {
        
        let cls = product_combo_price_line_class(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(whereSql: "")
        return arr
        
    }
    static func getPriceList(for templateID:Int)->[product_combo_price_line_class]{
        let sql = "select * FROM product_combo_price_line where product_combo_price_line.product_tmpl_id = \(templateID)"
        let result:[[String:Any]] = database_class(connect: .database).get_rows(sql: sql)
        return result.map({product_combo_price_line_class(fromDictionary: $0)})
    }
    static func getExtraPrice(for product_id:Int,price_list_id:Int )->product_combo_price_line_class?{
        let sql = "select * FROM product_combo_price_line where product_combo_price_line.product_id = \(product_id) and product_combo_price_line.price_list_id = \(price_list_id)"
        if let result:[String:Any] = database_class(connect: .database).get_row(sql: sql){
            return product_combo_price_line_class(fromDictionary: result)
        }
        return nil
    }
    
    func getPriceFor(addOn:pos_order_line_class){
        
        
    }
    
}

extension api {
    func get_product_combo_price_line(completion: @escaping (_ result: api_Results) -> Void)  {
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
        
        var fields =  [
            "id","price_list_id","combo_price_id","product_id","product_tmpl_id","attribute_value_id","price","display_name","__last_update"
        ]
                
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params": [
                "model": "product.combo.price.line",
                "method": "search_read",
                "args": [],
                "kwargs": [
                    "fields": fields,
                    "domain": [],
                    "offset": 0,
                    "limit": false,
                    "context": get_context()

                ]
            ]
            
            
        ]
        
        let Cookie = api.get_Cookie()
        
        let header:[String:String] = [
            "Cookie" :  Cookie
        ]
        
        callApi(url: url,keyForCash:  getCashKey(key: "get_product_combo_price_line"),header: header, param: param, completion: completion);
        
    }
    
        
}

extension load_base_apis {
    func get_product_combo_price_line(){
        let item_key = "get_product_combo_price_line" ;
        if localCash?.isTimeTopdate(item_key) == false  {
            _ = self.handleUI(item_key: item_key, result: nil)
            self.runQueue()
            return
        }
        
        con!.get_product_combo_price_line { (result) in
            let saveInDataBase = self.handleUI(item_key: item_key, result: result)
            if saveInDataBase
            {
                let list:[[String:Any]]  = result.response?["result"] as? [[String:Any]] ?? []
                
                let cls = product_combo_price_line_class(fromDictionary: [:])
                pos_base_class.create_temp(  cls.dbClass!)
//                pos_base_class.rest_temp( cls.dbClass!)
                product_combo_price_line_class.reset(temp: true)
                product_combo_price_line_class.saveAll(arr: list,temp: true)
                pos_base_class.copy_temp( cls.dbClass!)

                self.localCash?.setTimelastupdate(item_key)
                
            }
            
            self.runQueue()
            
        }
    }
}
