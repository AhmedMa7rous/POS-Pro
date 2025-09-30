//
//  scrapReasonClass.swift
//  pos
//
//  Created by Khaled on 4/17/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import UIKit

class pos_product_notes_class: NSObject {
    var dbClass:database_class?
    
    var id : Int = 0
    var qty : Int = 0
    
    var display_name : String = ""
    var name : String = ""
    var sequence : Int = 0
    
    var __last_update : String = ""
    
    
    
    var pos_category_ids:[Int] = []
    var deleted : Bool = false

    
    
    
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
        dictionary["deleted"] = deleted

        
        
        return dictionary
    }
    
    static func getAll(delet:Bool? = nil) ->  [[String:Any]] {
        
        let cls = pos_product_notes_class(fromDictionary: [:])
        var sql = ""
        if let delet = delet {
            sql = "where pos_product_notes.deleted = \(delet ?1:0)"
        }
        let arr  = cls.dbClass!.get_rows(whereSql: sql)
        return arr
        
    }
    
    static func getAll(delet:Bool? = nil) ->  [pos_product_notes_class] {
        
        
        
        let cls = pos_product_notes_class(fromDictionary: [:])
        var sql = ""
        if let delet = delet {
            sql = "where pos_product_notes.deleted = \(delet ?1:0)"
        }
        let arr  =  cls.dbClass!.get_rows(whereSql: sql)
        
        var rows :[pos_product_notes_class] = []
        for item in arr
        {
            rows.append(pos_product_notes_class(fromDictionary: item))
        }
        
        return rows
        
        
    }
    
    static func get(for pos_category_id:Int?, delet:Bool? = nil) ->  [pos_product_notes_class] {
        guard let pos_category_id = pos_category_id else {return []}
        
        
        let cls = pos_product_notes_class(fromDictionary: [:])
        var sql = """
        SELECT ppn.* from pos_product_notes ppn ,relations r WHERE r.re_id1 = ppn.id and r.re_id2  = \(pos_category_id) and r.re_table1_table2 = 'pos_product_notes|pos_category' and ppn.deleted = \((delet ?? false) ?1:0)
 """
      
        let arr  =  cls.dbClass!.get_rows(sql: sql)
        
        var rows :[pos_product_notes_class] = []
        for item in arr
        {
            rows.append(pos_product_notes_class(fromDictionary: item))
        }
        
        return rows
        
        
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
        
        relations_database_class(re_id1: self.id, re_id2: pos_category_ids, re_table1_table2: "pos_product_notes|pos_category").save()
        
        
    }
    
    func get_pos_category_ids() ->[Int]
    {
       return  dbClass?.get_relations_rows(re_id1:  id, re_table1_table2: "pos_product_notes|pos_category") ?? []
    }
    
    
    static func reset(temp:Bool = false)
    {
        let cls = pos_product_notes_class(fromDictionary: [:])
        
        var table = cls.dbClass!.table_name
         if temp
         {
            table =   "temp_" + cls.dbClass!.table_name
         }
        _ =   cls.dbClass!.runSqlStatament(sql: "update \(table) set deleted = 1")
        relations_database_class.reset(  re_table1_table2: "pos_product_notes|pos_category")

//      _ =  cls.dbClass?.runSqlStatament(sql: "delete from \(table)")
//        _ =  database_class().runSqlStatament(sql: "delete from relations where re_table1_table2='pos_product_notes|pos_category' ")
 
        
    }
    
    
    static func saveAll(arr:[[String:Any]],temp:Bool = false)
    {
        for item in arr
        {
            let pos = pos_product_notes_class(fromDictionary: item)
            pos.deleted = false
            pos.dbClass?.insertId = true
            pos.save(temp: temp)
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
