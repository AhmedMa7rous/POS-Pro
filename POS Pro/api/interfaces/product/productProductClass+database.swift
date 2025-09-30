//
//  productProductClass+extension.swift
//  pos
//
//  Created by Khaled on 4/25/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import UIKit

extension product_product_class  {
    
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
        
        let cls = product_product_class(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(whereSql: "where id in (\(str_ids)) ")
        return arr
        
    }
    static func get(by posCategoryId:Int) ->  [[String:Any]] {
        if posCategoryId == 0
        {
            return []
        }
        
        
        
        let cls = product_product_class(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(whereSql: "where pos_categ_id in (\(posCategoryId)) ")
        return arr
        
    }
    
    static func getAll() ->  [[String:Any]] {
         
         let cls = product_product_class(fromDictionary: [:])
         let arr  = cls.dbClass!.get_rows(whereSql: "")
         return arr
         
     }
    static func getStrobalIds() ->  [Int] {
         
         let cls = product_product_class(fromDictionary: [:])
         let arr  = cls.dbClass!.get_rows(whereSql: "where type = 'product'")
        return arr.compactMap({$0["id"] as? Int})
         
     }
    
    func get_taxes_id(posLine:pos_order_line_class?) -> [Int]
    {
        if let taxes_id_array =  self.taxes_id_array_string{
            if  taxes_id_array.count == 1 {
                if let taxID = Int(taxes_id_array){
                    return  [taxID]
                    
                }
                
            }
            if  taxes_id_array.count > 1{
                let taxes_id_int = taxes_id_array.replacingOccurrences(of: " ", with: "").split(separator: ",").compactMap({Int($0)})
                if taxes_id_int.count > 0{
                    return taxes_id_int
                }
            }
            
        }
        
        if let taxesIDS = dbClass?.get_relations_rows(re_id1: self.id, re_table1_table2: "products|taxes_id"), taxesIDS.count > 0{
            return taxesIDS
        }else{
            if let default_taxes_ids = SharedManager.shared.posConfig().company.account_sale_tax_id, !self.insurance_product{
                return  [default_taxes_ids]

            }
        }
        SharedManager.shared.reportTaxIdFR(posLine:posLine,productId: self.id )
        return  []

    }
    
    func getProductVariantIds() -> [Int]
    {
        return dbClass?.get_relations_rows(re_id1: self.id, re_table1_table2: "products|product_variant_ids") ?? []
    }
    
    static  func getProductComboIds(product_id:Int) -> [Int]
    {
        let cls = product_combo_class(fromDictionary: [:])
        return cls.dbClass?.get_relations_rows(re_id1: product_id, re_table1_table2: "products|product_combo_ids") ?? []
    }
    
   static  func getCombos(product_id:Int)-> [[String:Any]]
      {
        let comboIDS = self.getProductComboIds(product_id:product_id)
          
            var ids:String = ""
               for id in comboIDS
               {
                   if ids == ""
                   {
                       ids =   String(id)

                   }
                   else
                   {
                       ids = ids + "," + String(id)

                   }
               }
               
               
               
               let cls = product_combo_class(fromDictionary: [:])
               let list = cls.dbClass!.get_rows(whereSql: " where id in (\(ids)) ")

          return list
      }
      
    func getComboPrice(product_id:Int,product_tmpl_id:Int,delete:Bool? = nil)-> [String:Any]?
    {
        
        
        let cls = product_combo_price_class(fromDictionary: [:])
        var sql =  " where product_id = \(product_id) and product_tmpl_id =\(product_tmpl_id)  "
        if let deleted = delete {
            sql += "and deleted = \(deleted ? 1 : 0)"
        }
        let list = cls.dbClass!.get_row(whereSql:sql)
        
        return list
    }
    
 
    static func get(id:Int) -> product_product_class?
    {
        var cls = product_product_class(fromDictionary: [:])
        
        let row:[String:Any]?  = cls.dbClass!.get_row(whereSql: "where id = \(String(id))"  )
        if row != nil
        {
            cls = product_product_class(fromDictionary: row!)
        }
        else
        {
            return nil
        }
        
        return cls
    }
    static func get(barcode:String) -> product_product_class?
    {
        var cls = product_product_class(fromDictionary: [:])
        
        let row:[String:Any]?  = cls.dbClass!.get_row(whereSql: "where barcode = \(barcode)"  )
        if row != nil
        {
            cls = product_product_class(fromDictionary: row!)
        }
        else
        {
            return nil
        }
        
        return cls
    }
    
    static func getWithMinPrice(_ product_tmpl_id:Int) -> product_product_class?
    {
        var cls = product_product_class(fromDictionary: [:])
        
        let sql = """
            SELECT count(product_template_id ) as variants_count , MIN( list_price ) ,products.* from (
                           SELECT product_template .id as product_template_id ,product_product.* from product_product
                           inner join product_template
                           on product_template .id  = product_product.product_tmpl_id
                           where deleted  = 0  and product_product.product_tmpl_id = \(product_tmpl_id)) as products
                           GROUP by  product_template_id
                           order by products."sequence"
            """
        
        let row:[String:Any]?  = cls.dbClass!.get_row(sql: sql )
        if row != nil
        {
            cls = product_product_class(fromDictionary: row!)
        }
        else
        {
            return nil
        }
        
        return cls
    }
    
    
    static func getProduct(ID:Int) -> product_product_class
    {
        var cls = product_product_class(fromDictionary: [:])
        
        let row:[String:Any]?  = cls.dbClass!.get_row(whereSql: "where id = \(String(ID))"  )
        if row != nil
        {
            cls = product_product_class(fromDictionary: row!)
        }
        
        return cls
    }
    
    static func getMainProduct() ->  [[String:Any]] {
        
        let cls = product_product_class(fromDictionary: [:])
        
        let pos = SharedManager.shared.posConfig()
        
        cls.dbClass!.dictionary["variants_count"] = 0
 //        let sql = """
//        SELECT count(product_template .id  ) as variants_count , MIN(product_product.lst_price ) ,product_product.* from product_product
//        inner join product_template
//        on product_template .id  = product_product.product_tmpl_id
//        GROUP by  product_template .id
//        HAVING deleted  = 0
//        order by product_product."sequence"
        //pos_categ_id
//      """
//        let products_restrict_query = pos_config_class.get_products_restrict_query()
        var brand_option = ""
        if let brand_id = SharedManager.shared.selected_pos_brand_id {
            brand_option = "and (product_product.brand_id is null or product_product.brand_id = \(brand_id) ) "
        }
        let sql = """
            SELECT count(product_template_id ) as variants_count , MIN( lst_price ) ,products.* from (
               SELECT product_template .id as product_template_id ,product_product.* from product_product
               inner join product_template
               on product_template .id  = product_product.product_tmpl_id
               where product_product.deleted  = 0  \(brand_option) and (company_id = \(String(pos.company_id!)) OR company_id = 0 ) ) as products
               GROUP by  product_template_id
               order by products."sequence"
        """
        
        let arr  = cls.dbClass!.get_rows(sql:sql)
        
        return arr
        
    }
    
    static func readProducts(arr :[Any]) -> [product_product_class]
    {
        var list:[product_product_class] = []
        
        let arr_dic = arr as? [[String : Any]] ?? [[:]]
        
        for item in arr_dic
        {
            let obj = product_product_class(fromDictionary: item)
            
            list.append(obj)
            
            
        }
        
        return list
    }
    
}
