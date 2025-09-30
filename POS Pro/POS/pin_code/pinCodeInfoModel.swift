//
//  pinCodeInfoModel.swift
//  pos
//
//  Created by  Mahmoud Wageh on 4/8/21.
//  Copyright © 2021 khaled. All rights reserved.
//

import Foundation


import UIKit

class pinCodeInfoModel: NSObject {
    var dbClass:database_class?
    
    var id : Int = 0
    var qty : Int = 0
    
    var display_name : String = ""
    var name : String = ""
    var sequence : Int = 0
    
    var __last_update : String = ""
    
    
    
    var pos_category_ids:[Int] = []
    
    
    
    
    init(fromDictionary dictionary: [String:Any]){
        super.init()
        
        id = dictionary["id"] as? Int ?? 0
        
        
        
        display_name = dictionary["display_name"] as? String ?? ""
        name = dictionary["name"] as? String ?? ""
        __last_update = dictionary["__last_update"] as? String ?? ""
        sequence = dictionary["sequence"] as? Int ?? 0
        qty = dictionary["qty"] as? Int ?? 0
        
        pos_category_ids = dictionary["pos_category_ids"] as? [Int] ?? []
        
        
        dbClass = database_class(table_name: "pos_product_notes", dictionary: self.toDictionary(),id: id,id_key:"id")
        
       

    }
    
    
    func toDictionary() -> [String:Any]
    {
       var dictionary:[String:Any] = [:]
        
        dictionary["id"] = id
        dictionary["display_name"] = display_name
        dictionary["name"] = name
        dictionary["__last_update"] = __last_update
        dictionary["sequence"] = sequence
        dictionary["qty"] = self.qty
        
        
        
        return dictionary
    }
    
    static func getAll() ->  [[String:Any]] {
        
        let cls = pos_product_notes_class(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(whereSql: "")
        return arr
        
    }
    
    static func getAll() ->  [pos_product_notes_class] {
        
        
        
        let cls = pos_product_notes_class(fromDictionary: [:])
        let arr  =  cls.dbClass!.get_rows(whereSql: "")
        
        var rows :[pos_product_notes_class] = []
        for item in arr
        {
            rows.append(pos_product_notes_class(fromDictionary: item))
        }
        
        return rows
        
        
    }
    
    
    func save()
    {
        dbClass?.dictionary = self.toDictionary()
        dbClass?.id = self.id
        
        _ =  dbClass!.save()
        
        relations_database_class(re_id1: self.id, re_id2: pos_category_ids, re_table1_table2: "pos_product_notes|pos_category").save()
        
        
    }
    
    func get_pos_category_ids() ->[Int]
    {
       return  dbClass?.get_relations_rows(re_id1:  id, re_table1_table2: "pos_product_notes|pos_category") ?? []
    }
    
    
    
    static func saveAll(arr:[[String:Any]])
    {
        for item in arr
        {
            let pos = pos_product_notes_class(fromDictionary: item)
            pos.dbClass?.insertId = true
            pos.save()
        }
    }
    
    
    
    static func getDefault() ->  [[String:Any]] {
        
        let cls = pos_product_notes_class(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(whereSql: "")
        return arr
        
        //             var list : [scrapReasonClass] = []
        //
        //             for item in arr
        //             {
        //                 let cls = scrapReasonClass(fromDictionary: item  )
        //                 list.append(cls)
        //             }
        //             return list
    }
    
    
}
struct Odoo_Base<T:Codable>  : Codable {
    let jsonrpc : String?
    let id : Int?
    let result : T?


}

struct PinCodeInfoModel : Codable {
    let url : String?
    let database : String?
    let username : String?
    let password : String?
    let pos_ID : Int?
    let domain_user_id: Int?

    enum CodingKeys: String, CodingKey {
        case url = "url"
        case database = "database"
        case username = "username"
        case password = "password"
        case pos_ID = "pos_ID"
        case domain_user_id = "user_id"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        url = try values.decodeIfPresent(String.self, forKey: .url)
        database = try values.decodeIfPresent(String.self, forKey: .database)
        username = try values.decodeIfPresent(String.self, forKey: .username)
        password = try values.decodeIfPresent(String.self, forKey: .password)
        pos_ID = try values.decodeIfPresent(Int.self, forKey: .pos_ID)
        domain_user_id = try values.decodeIfPresent(Int.self, forKey: .domain_user_id)
    }
    func isValid()->Bool{
        return url != nil &&
        database != nil &&
        username != nil &&
        password != nil &&
        pos_ID != nil
//        &&
//        domain_user_id != nil
    }

}
