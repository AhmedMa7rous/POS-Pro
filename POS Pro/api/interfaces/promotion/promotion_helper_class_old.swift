//
//  app_promotion_class.swift
//  pos
//
//  Created by Khaled on 7/6/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import UIKit
 
class promotion_helper_class_old: NSObject {
    
 
    var list_promotion:[[String:Any]] = []
    
    var line:pos_order_line_class!
    
    var  order:pos_order_class!
    
    
    
   
   
    
    func get_promotion()   {
        
        list_promotion =   database_class().get_rows(sql: promotion_sql())
        
        check_pos_conditions()
        
    }
    
    
    func check_days_availability(days:[Int]) -> Bool
    {
        var pass = true
        
        let week_days = day_week_class.getAll()
        let day_name:String = Date.get_day_name(date:Date())
        
        let result =  week_days.filter{  $0["name"]! as? String == day_name }
        if result.count > 0
        {
            let day  = result[0]
            let day_id = day["id"] as? Int ?? 0
            
            let exsit = days.filter { $0 == day_id }
            if exsit.count > 0
            {
                pass = true
            }
            else
            {
                pass = false
            }
            
        }
        else
        {
            pass = false
        }
        
        return pass
        
    }
    
    func check_date_availability(from_date:String , to_date:String) -> Bool
    {
        if  from_date.isEmpty && from_date.isEmpty
        {
            return true
        }
        
        let fromdate = Date.init(strDate: from_date, formate: "yyyy-MM-dd",UTC: true)
        let todate = Date.init(strDate: to_date, formate: "yyyy-MM-dd",UTC: true)
        let date_now_str = Date().toString(dateFormat: "yyyy-MM-dd", UTC: true)
        
        let date_now = Date.init(strDate: date_now_str, formate: "yyyy-MM-dd",UTC: true)
        if  date_now >= fromdate && date_now  <= todate {
            return true
        }
        else
        {
            return false
            
        }
        
    }
    
    
    func check_time_availability(from_time:String , to_time:String) -> Bool
    {
        if  from_time.isEmpty && to_time.isEmpty
        {
            return true
        }
        
        let houre:Int =  Date.get_hours(date: Date()).toInt() ?? 0
        let fromTime:Int = from_time.toInt() ?? 0
        let toTime:Int = to_time.toInt() ?? 0
        
        if houre > fromTime && houre < toTime
        {
            return true
        }
        else
        {
            return false
        }
        
        
    }
    
    
    func check_availability(promotion:pos_promotion_class) -> Bool {
        
        guard check_date_availability(from_date: promotion.from_date, to_date: promotion.to_date) else {
            return false
        }
        
        guard  check_days_availability(days: promotion.get_day_of_week_ids()) else {
            return false
        }
        
        guard  check_time_availability(from_time: promotion.from_time, to_time: promotion.to_time) else {
            return false
        }
        
        
        return true
    }
    
    func check_pos_conditions()  {
        guard   (line != nil)   else {
            return
        }
        
        for condition in self.list_promotion {
            
            let promotion = pos_promotion_class(fromDictionary: remove_perfiex(dic: condition, prfiex: "pos_promotion_"))
            guard check_availability(promotion: promotion) else {
                return
            }
            
            if promotion.promotion_type == promotion_types.Buy_X_Get_Y_Free.rawValue
            {
                Buy_X_Get_Y_Free(condition: condition)
            }
            else if promotion.promotion_type == promotion_types.Buy_X_Get_Discount_On_Y.rawValue
            {
                Buy_X_Get_Discount_On_Y(condition: condition,promotion:promotion)
            }
            
            
            
            
        }
        
        
        
    }
    
    func Buy_X_Get_Discount_On_Y(condition:[String:Any],promotion:pos_promotion_class) {
        
        
        
        let parent_product_ids = promotion.get_parent_product_ids()
        
        let exist = order.pos_order_lines.filter{parent_product_ids.contains($0.product_id! ) && $0.is_void == false }
        
        
        if exist.count > 0
        {
            var validate = true
            
            if parent_product_ids.contains(line.product_id!)
            {
                validate = false
            }
            
            let dic = remove_perfiex(dic: condition, prfiex: "get_discount_")
            let pos_condition   = get_discount_class(fromDictionary: dic)
            
            if pos_condition.product_id_dis_id != line.product_id
            {
                validate = false
            }
            
            
            let index = order.pos_order_lines.firstIndex(where: { (item) -> Bool in
                item.product_id == pos_condition.product_id_dis_id
            })
            
            
            if index == nil
            {
                validate = false
            }
            
            
            
            
            if validate == true
            {
                let new_line = order.pos_order_lines[index!]
                
                
                if new_line.qty == pos_condition.qty
                {
                    
                    line.discount_type = .percentage
                    line.discount = pos_condition.discount_dis_x
                    
                }
                else if new_line.qty > pos_condition.qty
                {
                    //                let total = new_line.price_unit! * pos_condition.qty
                    //                let discount_value = (total *   pos_condition.discount_dis_x) / 100
                    //
                    //
                    //                new_line.discount_display_name = String( pos_condition.discount_dis_x) + " %"
                    //                new_line.discount_type = .fixed
                    //                new_line.discount = discount_value
                    
                }
                else if new_line.qty < pos_condition.qty
                {
                    line.discount_display_name = ""
                    line.discount_type = .percentage
                    line.discount = 0
                }
                
                
                
                
            }
            
            
            line.update_values()
            _ =  line.save(write_info: true, updated_session_status: .last_update_from_local)
            //            order.pos_order_lines[index!] = new_line
            
//            delegate?.reloadTableOrders(re_calc:false)
            
        }
        
    }
    
    func Buy_X_Get_Y_Free(condition:[String:Any]) {
        let product_x_id = condition["pos_conditions_product_x_id"] as? Int ?? 0
        
        if product_x_id != line?.product_id
        {
            return
        }
        
        
        let dic = remove_perfiex(dic: condition, prfiex: "pos_conditions_")
        let pos_condition   = pos_conditions_class(fromDictionary: dic)
        
        
        
        var add_product:Bool = false
        
        if pos_condition._operator == "is_eql_to"
        {
            if pos_condition.quantity == line!.qty
            {
                add_product = true
            }
        }
        else if pos_condition._operator == "greater_than_or_eql"
        {
            let qty =  line!.qty
            let quantity = pos_condition.quantity
            if qty >= quantity
            {
                add_product = true
            }
        }
        
        
        
        if add_product == true
        {
            
            let pos_line_new = pos_order_line_class(fromDictionary: [:])
            pos_line_new.product_id = pos_condition.product_y_id
            pos_line_new.qty = pos_condition.quantity_y
            pos_line_new.price_unit = 0
            pos_line_new.price_subtotal = 0
            pos_line_new.price_subtotal_incl = 0
            pos_line_new.custome_price_app = true
            pos_line_new.discount_type = .free
            
            
            pos_line_new.promotion_row_parent = line.id
            pos_line_new.pos_promotion_id = pos_condition.pos_promotion_rel_id
            pos_line_new.pos_conditions_id = pos_condition.id
            pos_line_new.discount_display_name = "Buy X Get Y Free Rule Applied..."
            
//            delegate?.addProduct(line: pos_line_new,new_qty:pos_condition.quantity_y,check_by_line: true,check_last_row: false )
        }
    }
    
    func remove_perfiex(dic:[String:Any] , prfiex:String) -> [String:Any]  {
        
        var new_dic:[String:Any]  = [:]
        
        for (key, value) in dic {
            let new_key = key.replacingOccurrences(of: prfiex, with: "")
            new_dic[new_key] = value
        }
        
        return new_dic
    }
    
    
    func promotion_sql() -> String {
        
        let sql = """

            SELECT

            pos_promotion.id as pos_promotion_id , pos_promotion.active as pos_promotion_active ,pos_promotion.discount_product_id as pos_promotion_discount_product_id ,pos_promotion.display_name as pos_promotion_display_name
            ,pos_promotion.from_date as pos_promotion_from_date ,pos_promotion.from_time as pos_promotion_from_time ,pos_promotion.operator as pos_promotion_operator ,pos_promotion.promotion_code as pos_promotion_promotion_code
            ,pos_promotion.promotion_type as pos_promotion_promotion_type ,pos_promotion."sequence" as pos_promotion_sequence ,pos_promotion.to_date as pos_promotion_to_date ,pos_promotion.to_time as pos_promotion_to_time
            ,pos_promotion.total_amount as pos_promotion_total_amount ,pos_promotion.total_discount as  pos_promotion_total_discount

            ,pos_conditions.display_name as pos_conditions_display_name ,pos_conditions.id as pos_conditions_id ,pos_conditions.operator as pos_conditions_operator  ,pos_conditions.pos_promotion_rel_id as pos_conditions_pos_promotion_rel_id
            ,pos_conditions.pos_promotion_rel_name as pos_conditions_pos_promotion_rel_name ,pos_conditions.product_x_id as pos_conditions_product_x_id ,pos_conditions.product_y_id as pos_conditions_product_y_id
            ,pos_conditions.quantity as pos_conditions_quantity,pos_conditions.quantity_y  as pos_conditions_quantity_y

            ,get_discount.discount_dis_x as get_discount_discount_dis_x,get_discount.display_name as get_discount_display_name ,get_discount.id as get_discount_id ,get_discount.pos_quantity_dis_rel_id as get_discount_pos_quantity_dis_rel_id
            ,get_discount.pos_quantity_dis_rel_name as get_discount_pos_quantity_dis_rel_name ,get_discount.product_id_dis_id as get_discount_product_id_dis_id ,get_discount.product_id_dis_name as get_discount_product_id_dis_name
            ,get_discount.qty  as get_discount_qty

            ,discount_multi_products.display_name as discount_multi_products_display_name ,discount_multi_products.id as discount_multi_products_id ,discount_multi_products.multi_product_dis_rel_id as discount_multi_products_multi_product_dis_rel_id
            ,discount_multi_products.multi_product_dis_rel_name as discount_multi_products_multi_product_dis_rel_name,discount_multi_products.products_discount as discount_multi_products_products_discount

            ,discount_multi_categories.categ_discount as discount_multi_categories_categ_discount ,discount_multi_categories.display_name as discount_multi_categories_display_name ,discount_multi_categories.id as discount_multi_categories_id
            ,discount_multi_categories.multi_categ_dis_rel_id as discount_multi_categories_multi_categ_dis_rel_id ,discount_multi_categories.multi_categ_dis_rel_name as discount_multi_categories_multi_categ_dis_rel_name

            ,discount_above_price.discount as discount_above_price_discount ,discount_above_price.discount_type as discount_above_price_discount_type ,discount_above_price.display_name as discount_above_price_display_name
            ,discount_above_price.fix_price_discount as discount_above_price_fix_price_discount ,discount_above_price.free_product_id as discount_above_price_free_product_id ,discount_above_price.id as discount_above_price_id
            ,discount_above_price.pos_promotion_id_id as discount_above_price_pos_promotion_id_id,discount_above_price.pos_promotion_id_name as discount_above_price_pos_promotion_id_name ,discount_above_price.price as discount_above_price_price

            ,quantity_discount.discount_dis as quantity_discount_discount_dis ,quantity_discount.display_name as quantity_discount_display_name ,quantity_discount.id as quantity_discount_id
            ,quantity_discount.pos_quantity_rel_id as quantity_discount_pos_quantity_rel_id ,quantity_discount.pos_quantity_rel_name as quantity_discount_pos_quantity_rel_name ,quantity_discount.quantity_dis  as quantity_discount_quantity_dis

            ,quantity_discount_amt.discount_price as quantity_discount_amt_discount_price ,quantity_discount_amt.display_name as quantity_discount_amt_display_name ,quantity_discount_amt.id as quantity_discount_amt_id
            ,quantity_discount_amt.pos_quantity_amt_rel_id as quantity_discount_amt_pos_quantity_amt_rel_id ,quantity_discount_amt.pos_quantity_amt_rel_name as quantity_discount_amt_pos_quantity_amt_rel_name
            ,quantity_discount_amt.quantity_amt as quantity_discount_amt_quantity_amt

            , (SELECT re_id2 from relations where re_table1_table2 = "pos_promotion|parent_product_ids" and pos_promotion.id = re_id1)  as parent_product_ids

            from pos_promotion
            left join
            pos_conditions on pos_promotion.id = pos_conditions.pos_promotion_rel_id
            left join
            get_discount on  pos_promotion.id = get_discount.pos_quantity_dis_rel_id
            left join
            discount_multi_products   on  pos_promotion.id = discount_multi_products.multi_product_dis_rel_id
            left join
            discount_multi_categories     on  pos_promotion.id = discount_multi_categories.multi_categ_dis_rel_id
            left join
            discount_above_price   on  pos_promotion.id = discount_above_price.pos_promotion_id_id
            left join
            quantity_discount    on  pos_promotion.id = quantity_discount.pos_quantity_rel_id
            left join
            quantity_discount_amt   on  pos_promotion.id = quantity_discount_amt.pos_quantity_amt_rel_id
            """
        
        
        return sql
    }
    
    
}


