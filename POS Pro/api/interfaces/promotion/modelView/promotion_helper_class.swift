//
//  app_promotion_class.swift
//  pos
//
//  Created by Khaled on 7/6/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import UIKit

enum promotion_types:String {
    case
        Buy_X_Get_Y_Free = "buy_x_get_y"
        ,Buy_X_Get_Discount_On_Y = "buy_x_get_dis_y"
        ,Buy_X_Get_Fix_Discount_On_Y = "buy_x_get_fix_dis_y"
        ,Discount_percentage_on_Total_Amount = "dicount_total"
        ,Percent_Discount_on_Quantity = "quantity_discount"
        ,Fix_Discount_on_Quantity = "quantity_price"
        ,Discount_On_Combination_Products = "discount_on_multi_product"
        ,Discount_On_Multiple_Categories = "discount_on_multi_categ"
        ,Discount_On_Above_Price = "discount_on_above_price"
        ,Discount_fixed_on_Total_Amount = "dicount_fixed_total"

}

enum promotion_operator:String {
    case is_eql_to = "is_eql_to"
    case greater_than_or_eql = "greater_than_or_eql"
}

protocol promotion_helper_delegate:class {
    func saveProduct(line:pos_order_line_class,rowIndex:Int , forceSave:Bool    )
    func addProduct(line:pos_order_line_class,new_qty:Double,check_by_line:Bool,check_last_row:Bool,stop_check:Bool)
    func deleteProductt(line:pos_order_line_class )
    func reloadTableOrders(re_calc:Bool,reSave:Bool )
    func reloadTableOrders( )

    func re_read_order()
}

class promotion_helper_class: NSObject {
    
    var delegate:promotion_helper_delegate?
    
    
    var line:pos_order_line_class!
    
    var  order:pos_order_class!
    
    
    let Buy_X_Get_Y_Free:Buy_X_Get_Y_Free_Class = Buy_X_Get_Y_Free_Class()
    let Buy_X_Get_Discount_On_Y:Buy_X_Get_Discount_On_Y_Class = Buy_X_Get_Discount_On_Y_Class()
    let Discount_percentage_on_Total_Amount:Discount_percentage_on_Total_Amount_Class = Discount_percentage_on_Total_Amount_Class()
    let Percent_Discount_on_Quantity:Percent_Discount_on_Quantity_Class = Percent_Discount_on_Quantity_Class()
    let Fix_Discount_on_Quantity:Fix_Discount_on_Quantity_Class = Fix_Discount_on_Quantity_Class()
    
    
    
    
    func get_promotionOld()
    {
        
        guard line != nil else {
            return
        }
        
        Buy_X_Get_Y_Free.helper = self
        Buy_X_Get_Discount_On_Y.helper = self
        Discount_percentage_on_Total_Amount.helper = self
        Percent_Discount_on_Quantity.helper = self
        Fix_Discount_on_Quantity.helper = self
        
        // ========================================================================
        // check if product has promotion in Buy_X_Get_Y_Free
        
        let list_p_free = database_class().get_rows(sql: promotion_sql() + " WHERE  pos_conditions_product_x_id =  \(line.product_id!) and  pos_promotion_promotion_type = 'buy_x_get_y'")
        if list_p_free.count > 0
        {
            Buy_X_Get_Y_Free.check(listPromotion:list_p_free)
        }
        
        guard line != nil else {
            return
        }
        // ========================================================================
        // check if product has promotion in Buy_X_Get_Discount_On_Y
        
        let list_p_discount = database_class().get_rows(sql: promotion_sql() + " WHERE  get_discount_product_id_dis_id =  \(line.product_id!) or parent_product_ids = \(line.product_id!) and  pos_promotion_promotion_type = 'buy_x_get_dis_y'")
        if list_p_discount.count > 0
        {
            Buy_X_Get_Discount_On_Y.check( listPromotion:list_p_discount)
        }
        
        guard line != nil else {
            return
        }
        
        // ========================================================================
        // check if product has promotion in buy_x_get_fix_dis_y
        
        let list_fixed_discount = database_class().get_rows(sql: promotion_sql() + " WHERE  get_discount_product_id_dis_id =  \(line.product_id!) or parent_product_ids = \(line.product_id!) and  pos_promotion_promotion_type = 'buy_x_get_fix_dis_y'")
        if list_fixed_discount.count > 0
        {
            Buy_X_Get_Discount_On_Y.check( listPromotion:list_fixed_discount)
        }
        
        guard line != nil else {
            return
        }
        
        
        // ========================================================================
        // Discount Percent on total Amount
        
//        let list_Percent_discount = database_class().get_rows(sql: promotion_sql() + " WHERE  pos_promotion_discount_product_id =  \(line.product_id!) ")
        let list_Percent_discount = database_class().get_rows(sql: promotion_sql() + " WHERE  pos_promotion_promotion_type = 'dicount_total' ")
        if list_Percent_discount.count > 0
        {
            Discount_percentage_on_Total_Amount.check(listPromotion:list_Percent_discount)

        }
        
        
        
        // ========================================================================
        // Percent_Discount_on_Quantity
        
//        let list_Percent_Discount_on_Quantity = database_class().get_rows(sql: promotion_sql() + " WHERE  quantity_discount_quantity_dis > 0 ")
        let list_Percent_Discount_on_Quantity = database_class().get_rows(sql: promotion_sql() + " WHERE   pos_promotion_promotion_type = 'quantity_discount'  order by quantity_discount_quantity_dis desc")

        if list_Percent_Discount_on_Quantity.count > 0
        {
             Percent_Discount_on_Quantity.check( listPromotion:list_Percent_Discount_on_Quantity)

        }
        
        
        // ========================================================================
        // Fix_Discount_on_Quantity
        
//        let list_Fix_Discount_on_Quantity = database_class().get_rows(sql: promotion_sql() + " WHERE  pos_promotion_product_id_amt =  \(line.product_id!) ")
        let list_Fix_Discount_on_Quantity = database_class().get_rows(sql: promotion_sql() + " WHERE  pos_promotion_promotion_type = 'quantity_price' order by quantity_discount_amt_quantity_amt desc")

        if list_Fix_Discount_on_Quantity.count > 0
        {
 
            Fix_Discount_on_Quantity.check(listPromotion:list_Fix_Discount_on_Quantity)

        }
        
 
        delegate?.reloadTableOrders(re_calc:true,reSave: false)

    }
    
    
    // MARK: - check_pos_conditions
    func validate2(_ listPromotion:[[String:Any]] ,_ validatOther:promotion_types? = nil) -> (_avalible:Bool,_promotion:[String:Any]? )
    {
        var avalible = false
 
        
        for condition in listPromotion {
            let condition_frist = condition //listPromotion.first
            
            let promotion_validate = pos_promotion_class(fromDictionary: promotion_helper_class.remove_perfiex(dic: condition_frist, prfiex: "pos_promotion_"))
            avalible =  check_availability(promotion: promotion_validate)
            
            if avalible == true
            {
                avalible =  can_apply(for: promotion_validate)
            }
            
          
            if avalible == true
            {
                if    promotion_validate.promotion_type == "buy_x_get_fix_dis_y" ||    promotion_validate.promotion_type == "buy_x_get_dis_y"
                {
                let parent_product_ids = promotion_validate.get_parent_product_ids()
                let rows_parent = order.pos_order_lines.filter{parent_product_ids.contains($0.product_id! ) && $0.is_void == false }
             
                if rows_parent.count == 0
                {
                   avalible = false
                }
                }
                else if  promotion_validate.promotion_type == "quantity_price"
                {
                    
                    let lst_products = order.pos_order_lines.filter({$0.product_id  == promotion_validate.product_id_amt && $0.is_void == false })

                    if lst_products.count == 0
                    {
                       avalible = false
                    }
                }
                
            }
            
            if avalible == true
            {
                return ( true, condition)
            }
        }
        
        
        return (avalible,nil)
   
         
    }
    
    func validate(_ listPromotion:[[String:Any]] ,_ validatOther:promotion_types? = nil) -> Bool
    {
        var avalible = false
        
        
        for condition in listPromotion {
            let condition_frist = condition //listPromotion.first
            
            let promotion_validate = pos_promotion_class(fromDictionary: promotion_helper_class.remove_perfiex(dic: condition_frist, prfiex: "pos_promotion_"))
            avalible =  check_availability(promotion: promotion_validate)
            
            if avalible == true
            {
                avalible =  can_apply(for: promotion_validate)
            }
            
            
            if avalible == true
            {
                return true
            }
        }
        
        
        return avalible
   
        
//        if validatOther != nil
//        {
//            if validatOther == .Fix_Discount_on_Quantity
//            {
////                let rows_applied =  get_discount_count(line.product_id!, promotion_validate.id )
////                let count = rows_applied.count
////
////                let dic =  remove_perfiex(dic: condition_frist!, prfiex: "quantity_discount_amt_")
////                let  get_discount   = quantity_discount_amt_class(fromDictionary: dic)
////
////
////                if count >= get_discount.no_of_applied_times && !rows_applied.contains(line.id)
////                {
////                    return false
////                }
//            }
//            else if  validatOther == .Percent_Discount_on_Quantity
//            {
////                let rows_applied =  get_discount_count(line.product_id!, promotion_validate.id )
////                let count = rows_applied.count
////
////                let dic =  remove_perfiex(dic: condition_frist!, prfiex: "quantity_discount_")
////                let  get_discount   = quantity_discount_class(fromDictionary: dic)
////
////
////                if count >= get_discount.no_of_applied_times && !rows_applied.contains(line.id)
////                {
////                    return false
////                }
//            }
//
//        }
        
//        return true
    }
    
    
    // MARK: - SQL
   static func remove_perfiex(dic:[String:Any] , prfiex:String) -> [String:Any]  {
        
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
                       ,pos_promotion.total_amount as pos_promotion_total_amount ,pos_promotion.total_discount as  pos_promotion_total_discount ,pos_promotion.product_id_amt as pos_promotion_product_id_amt
                       , pos_promotion.product_id_qty as pos_promotion_product_id_qty ,pos_promotion.no_of_applied_times as pos_promotion_no_of_applied_times
                       
                       ,pos_conditions.display_name as pos_conditions_display_name ,pos_conditions.id as pos_conditions_id ,pos_conditions.operator as pos_conditions_operator  ,pos_conditions.pos_promotion_rel_id as pos_conditions_pos_promotion_rel_id
                       ,pos_conditions.pos_promotion_rel_name as pos_conditions_pos_promotion_rel_name ,pos_conditions.product_x_id as pos_conditions_product_x_id ,pos_conditions.product_y_id as pos_conditions_product_y_id
                       ,pos_conditions.quantity as pos_conditions_quantity,pos_conditions.quantity_y  as pos_conditions_quantity_y,pos_conditions.no_of_applied_times  as pos_conditions_no_of_applied_times
                       
                       ,get_discount.discount_dis_x as get_discount_discount_dis_x,get_discount.display_name as get_discount_display_name ,get_discount.id as get_discount_id ,get_discount.pos_quantity_dis_rel_id as get_discount_pos_quantity_dis_rel_id
                       ,get_discount.pos_quantity_dis_rel_name as get_discount_pos_quantity_dis_rel_name ,get_discount.product_id_dis_id as get_discount_product_id_dis_id ,get_discount.product_id_dis_name as get_discount_product_id_dis_name
                       ,get_discount.qty  as get_discount_qty , get_discount.no_of_applied_times as  get_discount_no_of_applied_times , get_discount.discount_fixed_x as  get_discount_discount_fixed_x
                       
                       ,discount_multi_products.display_name as discount_multi_products_display_name ,discount_multi_products.id as discount_multi_products_id ,discount_multi_products.multi_product_dis_rel_id as discount_multi_products_multi_product_dis_rel_id
                       ,discount_multi_products.multi_product_dis_rel_name as discount_multi_products_multi_product_dis_rel_name,discount_multi_products.products_discount as discount_multi_products_products_discount
                       
                       ,discount_multi_categories.categ_discount as discount_multi_categories_categ_discount ,discount_multi_categories.display_name as discount_multi_categories_display_name ,discount_multi_categories.id as discount_multi_categories_id
                       ,discount_multi_categories.multi_categ_dis_rel_id as discount_multi_categories_multi_categ_dis_rel_id ,discount_multi_categories.multi_categ_dis_rel_name as discount_multi_categories_multi_categ_dis_rel_name
                       
                       ,discount_above_price.discount as discount_above_price_discount ,discount_above_price.discount_type as discount_above_price_discount_type ,discount_above_price.display_name as discount_above_price_display_name
                       ,discount_above_price.fix_price_discount as discount_above_price_fix_price_discount ,discount_above_price.free_product_id as discount_above_price_free_product_id ,discount_above_price.id as discount_above_price_id
                       ,discount_above_price.pos_promotion_id_id as discount_above_price_pos_promotion_id_id,discount_above_price.pos_promotion_id_name as discount_above_price_pos_promotion_id_name ,discount_above_price.price as discount_above_price_price
                       
                       ,quantity_discount.discount_dis as quantity_discount_discount_dis ,quantity_discount.display_name as quantity_discount_display_name ,quantity_discount.id as quantity_discount_id
                       ,quantity_discount.pos_quantity_rel_id as quantity_discount_pos_quantity_rel_id ,quantity_discount.pos_quantity_rel_name as quantity_discount_pos_quantity_rel_name
                       ,quantity_discount.quantity_dis  as quantity_discount_quantity_dis,quantity_discount.no_of_applied_times  as quantity_discount_no_of_applied_times
                       
                       ,quantity_discount_amt.discount_price as quantity_discount_amt_discount_price ,quantity_discount_amt.display_name as quantity_discount_amt_display_name ,quantity_discount_amt.id as quantity_discount_amt_id
                       ,quantity_discount_amt.pos_quantity_amt_rel_id as quantity_discount_amt_pos_quantity_amt_rel_id ,quantity_discount_amt.pos_quantity_amt_rel_name as quantity_discount_amt_pos_quantity_amt_rel_name
                       ,quantity_discount_amt.quantity_amt as quantity_discount_amt_quantity_amt,quantity_discount_amt.no_of_applied_times  as  quantity_discount_amt_no_of_applied_times
                       
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
    
    
    // MARK: - gloabl
    
    func add_discount( order: pos_order_class ,value:Double,is_fixed:Bool ,product_discount:product_product_class , discount_display_name:String,pos_promotion_id:Int,pos_conditions_id:Int)
    {
        let line_discount = pos_order_line_class.get_or_create(order_id:  order.id!, product: product_discount)
        line_discount.product = product_discount
        line_discount.order_id =  order.id!
        
        
        if is_fixed
        {
            
            
            line_discount.discount_display_name = discount_display_name
            line_discount.discount = value * -1
            line_discount.discount_type = .fixed
            line_discount.custom_price = value
            line_discount.price_unit = value
            
            
            
            line_discount.pos_promotion_id = pos_promotion_id
            line_discount.pos_conditions_id =  pos_conditions_id
            
            line_discount.update_values()
            
        }
        else
        {
            let discount_value =  order.get_discount_percentage_value(percentage_value: value)
            
            
            let price_subtotal_incl = discount_value.price_subtotal_incl * -1
            
 

            
            line_discount.custom_price = price_subtotal_incl
            line_discount.price_unit = price_subtotal_incl
            
            line_discount.discount_display_name = discount_display_name
            line_discount.discount_type = .percentage
            line_discount.discount = value
            
            line_discount.pos_promotion_id = pos_promotion_id
            line_discount.pos_conditions_id =  pos_conditions_id
            
            line_discount.update_values()
            
            line_discount.price_subtotal = discount_value.price_subtotal * -1
            
        }
        
        
        _ =  line_discount.save(write_info: true, updated_session_status: .last_update_from_local)
        
        order.save(write_info: true, updated_session_status: .last_update_from_local, re_calc: true)
        
        
    }
    
    func get_count_line_for(_ product_id:Int) -> (total:Double,num_lines:Int)
    {
        let sql = """
            SELECT sum(qty) as tot_qty ,count(*) as count_lines  from pos_order_line
            where product_id  == \(product_id) and order_id = \(order.id!) and is_void = 0
            """
        
        var tot_qty:Double = 0
        var count_lines:Int = 0

        let list  = database_class().get_rows(sql: sql)
        if list.count > 0
        {
            let row = list[0]
            count_lines = row["count_lines"] as? Int ?? 0
            tot_qty = row["tot_qty"] as? Double ?? 0

        }
        

        return (Double(tot_qty) , count_lines)
    }
    
    func get_total_qty(_ product_id:Int,_ pos_promotion_id:Int,_ pos_conditions_id:Int) -> (total:Double,num_lines:Int)
    {
        let sql = """
            SELECT sum(qty) as tot_qty ,count(*) as count_lines  from pos_order_line
            where product_id  == \(product_id) and order_id = \(order.id!) and is_void = 0 and pos_promotion_id = \(pos_promotion_id) and pos_conditions_id = \(pos_conditions_id)
            """
        
        var tot_qty:Double = 0
        var count_lines:Int = 0

        let list  = database_class().get_rows(sql: sql)
        if list.count > 0
        {
            let row = list[0]
            count_lines = row["count_lines"] as? Int ?? 0
            tot_qty = row["tot_qty"] as? Double ?? 0

        }
        

        return (Double(tot_qty) , count_lines)
    }
    
    func get_discount_count(_ product_id:Int,_ pos_promotion_id:Int ) -> [Int]
    {
        let sql = """
            SELECT id from pos_order_line
            where product_id  == \(product_id) and order_id = \(order.id!) and is_void = 0 and pos_promotion_id = \(pos_promotion_id)
            and discount != 0
            """
        
        var ids:[Int] = []
        let list  = database_class().get_rows(sql: sql)
        for row in list
        {
            let id = row["id"] as? Int ?? 0
            if id != 0
            {
                ids.append(id)
            }
        }
        
        
        return ids
    }
    
    func get_count_free_promotion_applied( product_id_y:Int,pos_condition_id:Int) -> Double
    {
        let sql = """
            SELECT sum(qty) from pos_order_line
            where product_id  == \(product_id_y) and order_id = \(order.id!) and is_void = 0 and pos_promotion_id != 0 and pos_conditions_id = \(pos_condition_id)
            """
        
        let total =   database_class().get_count(sql: sql)
        
        return  Double(total)
    }
    
    func get_total_qty_for( product_id:Int) -> Double
    {
        let sql = """
            SELECT sum(qty) from pos_order_line
            where product_id  == \(product_id) and order_id = \(order.id!) and is_void = 0
            """
        
        let total =   database_class().get_count(sql: sql)
        
        return Double(total)
    }
    
    func get_total_qty_for(  promotion_id:Int) -> Double
    {
        let sql = """
            SELECT sum(qty) from pos_order_line
            where pos_promotion_id  == \(promotion_id) and order_id = \(order.id!) and is_void = 0
            """
        
        let total =   database_class().get_count(sql: sql)
        
        return Double(total)
    }
    
    func get_row_parents_ids(_ product_id:Int) -> [Int]
    {
        let sql = """
            SELECT id from pos_order_line
            where product_id  == \(product_id) and order_id = \(order.id!) and is_void = 0
            """
        
        var ids:[Int] = []
        let list  = database_class().get_rows(sql: sql)
        for row in list
        {
            let id = row["id"] as? Int ?? 0
            if id != 0
            {
                ids.append(id)
            }
        }
        
        
        return ids
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
    func can_apply(for promotion:pos_promotion_class) -> Bool {
        
        let pos_ids = promotion.get_apply_on_pos_ids()
        let order_types_ids = promotion.get_apply_on_order_types_ids()
        
        if pos_ids.count > 0 {
            let pos_current = SharedManager.shared.posConfig()
            if !pos_ids.contains(pos_current.id) {
                return false
            }
        }
//        if order_types_ids.count > 0 {
//            if let order_type = self.order.orderType{
//                if !order_types_ids.contains(order_type.id) {
//                    return false
//                }
//            }
//        }
        return true
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
    
}


