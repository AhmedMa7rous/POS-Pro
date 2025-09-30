//
//  init_combo.swift
//  pos
//
//  Created by Khaled on 8/6/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import Foundation
typealias init_combo = combo_vc
extension init_combo
{
    
    func load_combo()
    {
        if product_combo?.is_combo_line == false   {
            return
        }
        
        getAvalalibeCombos()
        
        load_seleted_lines()
    }
    
    func getAvalalibeCombos()
    {
        let products_InCombo = get_products_InCombo_clac()
        product_combo!.products_InCombo = products_InCombo.list
        product_combo!.products_InCombo_avalibale_total_items = products_InCombo.total_items
        
    }
    
    
    
    func load_seleted_lines()
    {
        let last_index = list_collection_keys.count
        
        let sortedDic = product_combo!.products_InCombo.sorted { (aDic, bDic) -> Bool in
            return aDic.key < bDic.key
        }
        
        
        for (key,value) in  sortedDic
        {
            var index = 0
            let arr_sp = key.split(separator: "_")
            if arr_sp.count > 0
            {
                let str:String = String( arr_sp[0])
                index = last_index + (str.toInt() ?? 0)
            }
            
            let type:section_view = section_view.init(index_row:index ,title: key, type: .combo)
            index += 1
            
            list_collection_keys.append(type)
            var new_list:[product_product_class] = []
            //            new_list.append(contentsOf: value)
            
            for obj in value
            {
                if obj.auto_select_num > 0 || obj.app_require == true
                {
                    var temp:[product_product_class] =  products_auto_select_default_combo[key] ?? []
                    temp.append(obj)
                    products_auto_select_default_combo[key] = temp
                }
                
                new_list.append(obj)
            }
            
            list_collection[key] = new_list
        }
        
        let sortedKeys = list_collection_keys.sorted { (lhs:section_view, rhs:section_view) in
            return lhs.index_row < rhs.index_row
        }
        
        list_collection_keys.removeAll()
        list_collection_keys.append(contentsOf: sortedKeys)
        
        //        load_require()
        
        
        //            comboSeletedItems!.list_collection_keys = list_collection_keys
        //            comboSeletedItems!.avalibale_total_items = product_combo!.products_InCombo_avalibale_total_items  * qty
        //            comboSeletedItems!.reCheckCount()
        
        if product_combo?.combo_edit == true
        {
            for p in product_combo!.selected_products_in_combo
            {
                
                if p.qty > 0
                {
                    let combo = product_combo_class.get_combo(ID: p.combo_id!)
                    let key = get_section_name(cls_combo: combo)
                    
                    //                    var key = ""
                    //                    if combo.pos_category_id != 0
                    //                    {
                    //                        key = combo.pos_category_id_name  //p.combo!.pos_category_id_name
                    //
                    //                    }
                    //                    else
                    //                    {
                    //                        key = String( combo.id ) //p.combo!.pos_category_id_name
                    //
                    //                    }
                    //
                    //
                    //                    key = getKey_ordered(key_categ: key)
                    
                    var temp =  list_selected[key] ?? []
                    temp.append(p)
                    list_selected[key]  = temp
                    
                    //                                     comboSeletedItems!.addItem(section_key: key, product: p)
                    //                                     comboSeletedItems!.reCheckCount()
                }
                
            }
            
            setSutoSelect(get_defualt: true)
            
        }
        else
        {
            setSutoSelect()
        }
        
        self.collection?.reloadData()
        
    }
    
    func getKey_ordered(key_categ:String) -> String
    {
        var key = key_categ
        let filtered = list_collection_keys.filter { $0.title.contains(key) }
        if filtered.count > 0
        {
            key = filtered[0].title
        }
        
        return key
        
    }
    
    
    func setSutoSelect(get_defualt:Bool = false , multiply_qty : Int = 1)
    {
        for (_,value) in list_collection
        {
            let arr = value
            
            for product in arr
            {
                
                
                if product.default_product_combo == true || product.app_require == true
                {
                    let key = product.section_name
                    
                 
                    
                    
                    let line = create_line(product: product)
                    
                    if product.combo!.no_of_items < product.auto_select_num
                    {
                        line.qty = Double(product.combo!.no_of_items)
                        
                    }
                    else
                    {
                        if product.app_require
                        {
                            line.qty = Double(1 * multiply_qty)
                        }
                        else
                        {
                            line.qty = Double(product.auto_select_num) * Double(multiply_qty)
                            
                        }
                        
                    }
                    
                    
                    
                    if get_defualt == false
                    {
                        var temp  =     list_selected[key] ?? []
                        temp.append(line)
                        list_selected[key] = temp
                    }
                    
                    
//                    lines_defualt_select_combo.append(line)
                    //                            comboSeletedItems!.addItem(section_key: key, product: line)
                    
                    
                    
                    
                }
                
                
                
                
            }
            
        }
        
        
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
    
    
    
    func load_require()
    {
        var list:[product_product_class] = list_collection[Require_header]   ?? []
        let count = list.count
        
        
        if count == 0
        {
            
            return
        }
        
        
        for i in 0...count - 1
        {
            let product = list[i]
            
            product.app_require = true
            
            
            
            list[i] = product
            
            
            
        }
        
        list_collection[Require_header] = list
        
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
        
        var sql = """
                 SELECT  * from
                    (SELECT * from product_combo where product_tmpl_id = \(product_tmpl_id!) and product_combo.deleted = 0) as product_combo
                    inner join
                     (SELECT  re_id1 , re_id2 as attribute_id  FROM relations where re_table1_table2 = 'product_combo|attribute_value_ids' \(sql_attribute_1) ) as attribute_values
                     on product_combo.id  = attribute_values.re_id1
                     
                     INNER JOIN
                     (SELECT id as products_in_combo_id , re_id1  as products_ids ,re_id2  as products_ids2 from relations where re_table1_table2  = 'product_combo|product_product' )  as products_in_combo
                     on product_combo.id  = products_in_combo.products_ids
                     
                      inner join
                     ( select product_combo_price.attribute_value_id ,product_combo_price.auto_select_num ,product_combo_price.display_name ,product_combo_price.product_id
                     ,product_combo_price.product_name ,product_combo_price.product_tmpl_id ,product_combo_price.product_tmpl_name,product_combo_price.extra_price  FROM product_combo_price
                     where    product_combo_price.product_tmpl_id  = \(product_tmpl_id!)  \(sql_attribute_2) ) as  combo_price
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
                        where    product_combo_price.product_tmpl_id  = \(product_tmpl_id!) and product_combo_price.deleted = 0 ) as  combo_price
                       on  products_in_combo.products_ids2 = combo_price.product_id
 """
        
        
        
        sql = sql + " ORDER by product_combo.'sequence' , products_in_combo.products_in_combo_id"
        
//               SharedManager.shared.printLog(sql)
        let arr =  database_class().get_rows(sql: sql)
        
        return arr
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
            
            let categ_name = get_section_name(cls_combo: cls_combo)
            
            var newList = list_collection[categ_name]   ?? []
            newList.append(contentsOf: list)
            
            list_collection[categ_name] = newList
            
        }
        
 
        
        return (list_collection , avalibale_total_items)
    }
    
    
    func get_products_InCombo_clac_old(avalabile_combos:[[String:Any]]) -> (list:[String:[product_product_class]] , total_items:Double)
    {
        
        var list_collection: [String:[product_product_class]] = [:]
        var avalibale_total_items = 0.0
        
        //        var index = 1
        for combo  in avalabile_combos
        {
            var list:[product_product_class] = []
            
            //            let require = combo["require"] as? Bool ?? false
            //            let no_of_items = combo["no_of_items"] as? Bool ?? false
            //            let product_ids:[Int] = combo["product_ids"] as! [Int]
            
            let cls_combo = product_combo_class(fromDictionary: combo)
            avalibale_total_items = avalibale_total_items + Double(cls_combo.no_of_items)
            
            
            let arr_products = get_product_item_calc(combo: cls_combo,product_parent_id: (product_combo?.product_id)!)
            list.append(contentsOf: arr_products)
            
            
            let categ_name = get_section_name(cls_combo: cls_combo)
            
            var newList = list_collection[categ_name]   ?? []
            newList.append(contentsOf: list)
            
            list_collection[categ_name] = newList
            
            
            
        }
        
        return (list_collection , avalibale_total_items)
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
    
    func get_product_item_calc(combo:product_combo_class,product_parent_id:Int,number_of_call:Int = 0) -> [product_product_class]
    {
        if number_of_call == 0
        {
            numer_of_call_product_item_calc = 1
        }
        else
        {
            if numer_of_call_product_item_calc > 2
            {
                return []
            }
            
            numer_of_call_product_item_calc += 1
        }
        
        
        var list:[product_product_class] = []
        
        
        for id:Int  in combo.productProductIDS()
        {
            
            if id  != product_parent_id
            {
                
                var product = product_product_class.getProduct(ID: id)
                
                
                
                product.section_name = get_section_name(cls_combo: combo)
                
                
                if combo.pos_category_id == 0
                {
                    combo.pos_category_id_name = "Default"
                }
                
                product.combo = combo
                
                product = get_extra_price_calc(product: product )
                
                
                list.append(product )
                
                if product.is_combo
                {
                    
                    let combos = product_product_class.getCombos(product_id: product.id)
                    for sub_combo   in combos
                    {
                        let cls_combo = product_combo_class(fromDictionary: sub_combo)
                        let arr_products = get_product_item_calc(combo: cls_combo ,product_parent_id:product.id ,number_of_call: numer_of_call_product_item_calc)
                        
                        //                        list.append(contentsOf: arr_products)
                        for p in arr_products
                        {
                            var combo_p = p
                            combo_p = get_extra_price_calc(product: combo_p )
                            combo_p.combo = product_combo_class(fromDictionary:  combo.toDictionary())
                            
                            list.append(combo_p )
                            
                        }
                        
                        
                    }
                }
                
            }
            
            
        }
        
        return list
    }
    
    
    
    
    func get_extra_price_calc(product:product_product_class) -> product_product_class
    {
        if  product.combo?.product_tmpl_id == 0
        {
            return product
        }
        
        
        let compo_price = product.getComboPrice(product_id: product.id ,product_tmpl_id:product.combo!.product_tmpl_id,delete:false) ?? [:]
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
    
}
