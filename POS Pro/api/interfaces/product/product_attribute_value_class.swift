//
//  scrapReasonClass.swift
//  pos
//
//  Created by Khaled on 4/17/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import UIKit

class product_attribute_value_class: NSObject {
    var dbClass:database_class?
    
    var id : Int = 0
    
    var attribute_id_id : Int = 0
    var attribute_id_name : String = ""

  
    var name : String = ""
     
 
    var product_id : Int = 0
    var product_tmpl_id : Int = 0

     
    var price_extra:Double = 0
    var lst_price:Double = 0

    
    
    
    init(fromDictionary dictionary: [String:Any]){
        super.init()
        
        id = dictionary["id"] as? Int ?? 0
        name = dictionary["name"] as? String ?? ""

        price_extra = dictionary["price_extra"] as? Double ?? 0
        lst_price = dictionary["lst_price"] as? Double ?? 0
        product_id = dictionary["product_id"] as? Int ?? 0

        attribute_id_id = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "attribute_id", keyOfDatabase: "attribute_id_id",Index: 0) as? Int ?? 0
        attribute_id_name = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "attribute_id", keyOfDatabase: "attribute_id_name",Index: 1) as? String ??  ""

        product_tmpl_id = dictionary["product_tmpl_id_id"] as? Int ?? 0

        
 

        dbClass = database_class(table_name: "product_attribute_value", dictionary: self.toDictionary(),id: id,id_key:"id")

        
    }
    
    
    func toDictionary() -> [String:Any]
    {
        var dictionary:[String:Any] = [:]
        
        dictionary["id"] = id
        dictionary["name"] = name
        dictionary["attribute_id_id"] = attribute_id_id
        dictionary["attribute_id_name"] = attribute_id_name
 
         
        
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
        let cls = product_attribute_value_class(fromDictionary: [:])
        
        var table = cls.dbClass!.table_name
         if temp
         {
            table =   "temp_" + cls.dbClass!.table_name
         }
        
      _ =  cls.dbClass?.runSqlStatament(sql: "delete from \(table)")
        
  
        
    }
    
    static func saveAll(arr:[[String:Any]],temp:Bool = false)
    {
        for item in arr
        {
            let pos = product_attribute_value_class(fromDictionary: item)
            pos.dbClass?.insertId = true
            pos.save(temp: temp)
        }
    }
    
    
    
    static func getAll() ->  [[String:Any]] {
        
        let cls = product_attribute_value_class(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(whereSql: "")
        return arr
        
      
    }
    
    static func get_product_attribute_value(product_tmpl_id:Int) -> [product_attribute_value_class]
    {
 
        
//        let sql = """
//               SELECT att.*, product_product.id as product_id ,product_product.lst_price,product_product.attribute_value_id FROM
//               (
//               select relations.re_id2  as attribute_value_id,product_attribute_value.attribute_id_id, product_product.* from  product_product
//               inner join relations
//               on relations.re_id1  = product_product.id
//               INNER JOIN product_attribute_value
//               on product_attribute_value.id = attribute_value_id
//               WHERE   re_table1_table2 ='products|attribute_value_ids'  and product_product.product_tmpl_id  = 89  and product_product.deleted = 0
//
//
//               ) as  product_product
//
//               inner join
//               (
//               SELECT product_attribute_value.*,product_template_attribute_value.price_extra  ,product_template_attribute_value.product_tmpl_id_id,product_attribute_value_id_name  from product_attribute_value
//               inner join product_template_attribute_value
//               on product_template_attribute_value.product_attribute_value_id_id = product_attribute_value.id and product_template_attribute_value.attribute_id_id = product_attribute_value.attribute_id_id
//               inner join
//                 (SELECT * from relations  where relations.re_table1_table2 = "product_template|valid_product_attribute_value_ids" and re_id1 = 89) as  attribute_value_ids
//                  on product_attribute_value.id =  attribute_value_ids.re_id2
//
//                  WHERE  product_template_attribute_value.product_tmpl_id_id  = 89
//                  ORDER BY product_template_attribute_value.own_sequence
//                      ) as att
//
//               ON   product_product.attribute_value_id = att.id  and product_product.attribute_id_id = att.attribute_id_id
//        """
        
        let sql = """
                        SELECT product_attribute_value.*,product_template_attribute_value.price_extra ,product_template_attribute_value.product_tmpl_id_id from product_attribute_value
                     inner join product_template_attribute_value
                     on product_template_attribute_value.product_attribute_value_id_id = product_attribute_value.id
                     
                     inner join
                    (SELECT * from relations
                            where relations.re_table1_table2 = "product_template|valid_product_attribute_value_ids" and re_id1 = \(product_tmpl_id) and relations.deleted = 0) as  attribute_value_ids
                            on product_attribute_value.id =  attribute_value_ids.re_id2
                      WHERE  product_template_attribute_value.product_tmpl_id_id  = \(product_tmpl_id)

                                 ORDER BY product_template_attribute_value.own_sequence
            """
        
        let cls = product_attribute_value_class(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(sql: sql)
        
        var rows :[product_attribute_value_class] = []
        for item in arr
        {
            rows.append(product_attribute_value_class(fromDictionary: item))
        }
        
        return rows
        
    }
    
    static func get_product_attribute_value(product_id:Int) -> [product_attribute_value_class]
    {
        let sql = """
        SELECT product_attribute_value.* FROM relations
         inner join product_attribute_value
         on product_attribute_value.id = relations.re_id2
        where re_table1_table2 = "products|attribute_value_ids" and re_id1  = \(product_id)
        """
        
      let cls = product_attribute_value_class(fromDictionary: [:])
               let arr  = cls.dbClass!.get_rows(sql: sql)
               
               var rows :[product_attribute_value_class] = []
               for item in arr
               {
                   rows.append(product_attribute_value_class(fromDictionary: item))
               }
               
               return rows
               
        
    }
    
    static func get_product_attribute_value_class(product_id:Int,attribute_value_id:Int) -> product_attribute_value_class?
    {
        let sql = """
        SELECT product_attribute_value.* FROM relations
         inner join product_attribute_value
         on product_attribute_value.id = relations.re_id2
        where re_table1_table2 = "products|attribute_value_ids" and re_id1  = \(product_id) and re_id2 = \(attribute_value_id)
        """
        
      let cls = product_attribute_value_class(fromDictionary: [:])
        if let item  = cls.dbClass!.get_row(sql: sql){
            return product_attribute_value_class(fromDictionary: item)
        }
            return nil
               
               
        
    }

    
    
    static func get_all_attribute_value(product_tmpl_id:Int ) -> [[String : Any]]
    {
        let deletQuery = ""//"and product_product.deleted != 1"
        let sql = """
        SELECT  relations.re_id1 , relations.re_id2 , product_product.* from product_product
        inner join relations
        on product_product.id  = relations.re_id1
        WHERE  product_product.product_tmpl_id  = \(product_tmpl_id)   and relations.re_table1_table2 = "products|attribute_value_ids" \(deletQuery)
        
        """
        
        let cls = product_attribute_value_class(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(sql: sql)
        
      
        
        return arr
        
    }

    

    
    
}
