//
//  product_combo_helper_class.swift
//  pos
//
//  Created by khaled on 28/05/2021.
//  Copyright © 2021 khaled. All rights reserved.
//

import UIKit

class product_combo_helper_class: NSObject {

    var order_id:Int!
    var product_combo:pos_order_line_class!
    var get_auto_select:Bool = false

    var list_auto_select:[pos_order_line_class] = []
    
    func load_combo()
    {
        if product_combo?.is_combo_line == false   {
            return
        }
        
        getAvalalibeCombos()
        
        
    }
    
    func getAvalalibeCombos()
    {
        let products_InCombo = get_products_InCombo_clac()
        product_combo!.products_InCombo = products_InCombo.list
        product_combo!.products_InCombo_avalibale_total_items = products_InCombo.total_items
        
    }
    
   
    
    
    func get_products_InCombo_clac () -> (list:[String:[product_product_class]] , total_items:Double)
    {
        
        var list_collection: [String:[product_product_class]] = [:]
        var avalibale_total_items = 0.0
        
        let arr_combo_and_products = get_products_combo()
        
        
        for row in arr_combo_and_products
        {
            var list:[product_product_class] = []
            
            let cls_combo = product_combo_class(fromDictionary: row)
            avalibale_total_items = avalibale_total_items + Double(cls_combo.no_of_items)
            
            let product_id = row["product_id"] as? Int ?? 0
            
            var product = product_product_class.get(id: product_id)
            if product == nil
            {
                continue
            }
            
            product?.combo = cls_combo
            product?.app_require = cls_combo.require
            product = get_extra_price_calc(product: product! )
            
            product?.section_name = get_section_name(cls_combo: cls_combo)
            
            if cls_combo.pos_category_id == 0
            {
                cls_combo.pos_category_id_name = "Default"
            }
            
            
            list.append(product!)
            
            if get_auto_select
            {
                list_auto_select.append(create_line(product: product!))
            }
            
            let categ_name = get_section_name(cls_combo: cls_combo)
            
            var newList = list_collection[categ_name]   ?? []
            newList.append(contentsOf: list)
            
            list_collection[categ_name] = newList
            
        }
        
 
        
        return (list_collection , avalibale_total_items)
    }
    
    func create_line(product:product_product_class) -> pos_order_line_class
    {
        let line = pos_order_line_class.create(order_id: order_id, product: product)
        
        //        let line = pos_order_line_class.get_or_create(order_id: order_id, product: product)
        line.parent_product_id = product_combo?.product_id
        line.combo_id = product.combo?.id
        line.qty = 1
        line.auto_select_num = product.auto_select_num
        line.extra_price = product.comob_extra_price
        line.default_product_combo = product.default_product_combo
        
        return line
    }
    
    func get_products_combo() -> [[String:Any]]
    {
        //        let product_id =  product_combo?.product_id
        let product_tmpl_id = product_combo?.product_tmpl_id
        let attribute_value_id = product_combo?.attribute_value_id
        
        var sql_attribute_1 = ""
        var sql_attribute_2 = ""
        
        if attribute_value_id != nil
        {
            sql_attribute_1 = " and re_id2 = \(attribute_value_id!)"
            sql_attribute_2 = " and attribute_value_id = \(attribute_value_id!)"
            
        }
        
        var sql_auto_select = ""
        if get_auto_select
        {
            sql_auto_select = " and product_combo_price.auto_select_num >= 1 "
        }
        
        var sql = """
                 SELECT  * from
                    (SELECT * from product_combo where product_tmpl_id = \(product_tmpl_id!) and product_combo.deleted = 0 ) as product_combo
                    inner join
                     (SELECT  re_id1 , re_id2 as attribute_id  FROM relations where re_table1_table2 = 'product_combo|attribute_value_ids' \(sql_attribute_1) ) as attribute_values
                     on product_combo.id  = attribute_values.re_id1
                     
                     INNER JOIN
                     (SELECT id as products_in_combo_id , re_id1  as products_ids ,re_id2  as products_ids2 from relations where re_table1_table2  = 'product_combo|product_product' )  as products_in_combo
                     on product_combo.id  = products_in_combo.products_ids
                     
                      inner join
                     ( select product_combo_price.attribute_value_id ,product_combo_price.auto_select_num ,product_combo_price.display_name ,product_combo_price.product_id
                     ,product_combo_price.product_name ,product_combo_price.product_tmpl_id ,product_combo_price.product_tmpl_name,product_combo_price.extra_price  FROM product_combo_price
                     where    product_combo_price.product_tmpl_id  = \(product_tmpl_id!)  \(sql_attribute_2) \(sql_auto_select) ) as  combo_price
                    on  products_in_combo.products_ids2 = combo_price.product_id
        
                UNION
        
              SELECT * from (
                       SELECT  * from
                       (SELECT * from product_combo where product_tmpl_id = \(product_tmpl_id!) and product_combo.deleted = 0) as product_combo
                       left join
                        (SELECT  re_id1 , re_id2 as attribute_id  FROM relations where re_table1_table2 = 'product_combo|attribute_value_ids'   ) as attribute_values
                        on product_combo.id  = attribute_values.re_id1
                        where re_id1  is NULL ) as pp
                        
                        
                        INNER JOIN
                        (SELECT id as products_in_combo_id ,re_id1  as products_ids ,re_id2  as products_ids2 from relations where re_table1_table2  = 'product_combo|product_product' )  as products_in_combo
                        on pp.id  = products_in_combo.products_ids
                        
                         inner join
                        ( select product_combo_price.attribute_value_id ,product_combo_price.auto_select_num ,product_combo_price.display_name ,product_combo_price.product_id
                        ,product_combo_price.product_name ,product_combo_price.product_tmpl_id ,product_combo_price.product_tmpl_name,product_combo_price.extra_price  FROM product_combo_price
                        where    product_combo_price.product_tmpl_id  = \(product_tmpl_id!) \(sql_auto_select) and product_combo_price.deleted = 0) as  combo_price
                       on  products_in_combo.products_ids2 = combo_price.product_id
 """
        
        
        
        sql = sql + " ORDER by product_combo.'sequence' , products_in_combo.products_in_combo_id"
        SharedManager.shared.printLog(sql)
        let arr =  database_class().get_rows(sql: sql)
        
        return arr
    }
    
    
    func get_extra_price_calc(product:product_product_class) -> product_product_class
    {
        if  product.combo?.product_tmpl_id == 0
        {
            return product
        }
        
        
        let compo_price = product.getComboPrice(product_id: product.id ,product_tmpl_id:product.combo!.product_tmpl_id) ?? [:]
        let combo = product_combo_price_class(fromDictionary: compo_price)
        product.comob_extra_price = combo.extra_price
        
        if combo.auto_select_num > 0
        {
            product.app_selected = true
            product.auto_select_num = combo.auto_select_num
            product.default_product_combo = true
            
            
            
        }
        
        return product
        
    }
    
    func get_section_name(cls_combo:product_combo_class) -> String
    {
        let Require_header = "0_Require"
        if cls_combo.require == true
        {
            return Require_header
        }
        
        var categ_name = ""
        
        if cls_combo.pos_category_id != 0
        {
            categ_name =   cls_combo.pos_category_id_name
            
            //                     categ_name = String(format: "%d_%@" , index , categ_name)
            categ_name = String(format: "%d_%@" , cls_combo.sequence , categ_name)
            
            
        }
        else
        {
            categ_name =  String(  cls_combo.id)
            categ_name = String(format: "%d_%@" , 1000 , categ_name)
            
        }
        
        return categ_name
    }
    
}
