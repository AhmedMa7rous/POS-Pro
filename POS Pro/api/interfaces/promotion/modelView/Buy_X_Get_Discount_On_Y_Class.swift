//
//  Buy_X_Get_Discount_On_Y+ext.swift
//  pos
//
//  Created by khaled on 30/08/2021.
//  Copyright © 2021 khaled. All rights reserved.
//

import Foundation


class Buy_X_Get_Discount_On_Y_Class: NSObject {
    
    var helper:promotion_helper_class!
    
    private var delegate:promotion_helper_delegate?
    
    private var line:pos_order_line_class!
    
    private   var  order:pos_order_class!
    
    
    
   
    
    
    func check(  listPromotion:[[String:Any]]) {
        
        var newlistPromotion = listPromotion
    
        
        self.line = helper.line
        self.order = helper.order
        self.delegate = helper.delegate
        
        let avalible  =  helper.validate2(newlistPromotion)
        
        guard  avalible._avalible else {
            for condition in newlistPromotion {
                
                let promotion = pos_promotion_class(fromDictionary: promotion_helper_class.remove_perfiex(dic: condition, prfiex: "pos_promotion_"))
                let dic = promotion_helper_class.remove_perfiex(dic: condition, prfiex: "get_discount_")
                let  get_discount   = get_discount_class(fromDictionary: dic)
                
                reset_discount(get_discount: get_discount , promotion: promotion )
            }
            
            delegate?.reloadTableOrders(re_calc: true, reSave: true)

            return
        }
         
        if avalible._promotion != nil
        {
            newlistPromotion.removeAll()
            newlistPromotion.append(avalible._promotion!)
        }

 
        for condition in newlistPromotion {
            
            let promotion = pos_promotion_class(fromDictionary: promotion_helper_class.remove_perfiex(dic: condition, prfiex: "pos_promotion_"))
            let dic = promotion_helper_class.remove_perfiex(dic: condition, prfiex: "get_discount_")
            let  get_discount   = get_discount_class(fromDictionary: dic)
            
        
            
 
//            let parent_product_ids = promotion.get_parent_product_ids()
//            let rows_parent = order.pos_order_lines.filter{parent_product_ids.contains($0.product_id! ) && $0.is_void == false }
//            if rows_parent.count == 0
//            {
//
//                reset_discount(get_discount: get_discount , promotion: promotion )
//
//               continue
//            }
//
            
     
            //            get_discount.num_of_applied = 2
            
            if get_discount.product_id_dis_id != 0
            {
                
                let total_products_qty = helper.get_total_qty_for(product_id:get_discount.product_id_dis_id)
//                if total_products_qty < get_discount.qty
//                {
//                    return
//                }
                
                let q_products_cannot_applied = total_products_qty.toInt()  %  get_discount.qty.toInt()
                var q_products_can_applied = total_products_qty.toInt() - q_products_cannot_applied

//                let no_of_applied_times = get_discount.no_of_applied_times
                let no_of_qty_applied_items =  get_discount.no_of_applied_times * get_discount.qty.toInt()
                if no_of_qty_applied_items < q_products_can_applied
                {
                    q_products_can_applied = no_of_qty_applied_items
                }
                
                
                let lst_products = order.pos_order_lines.filter({$0.product_id  == get_discount.product_id_dis_id})
                
                var total_qty_applied:Int = 0
                
                for line in lst_products
                {
                    if (total_qty_applied < q_products_can_applied)
                    {
                        total_qty_applied += line.qty.toInt()
                        var qty = line.qty.toInt()
                        
                        if total_qty_applied > q_products_can_applied
                        {
                            qty = q_products_can_applied - (total_qty_applied - line.qty.toInt())
                        }
                        
                        var  discount_price = 0.0
                        
                        if promotion.promotion_type == "buy_x_get_fix_dis_y"
                        {
                            let no_of_applied_times:Double = Double( qty) / get_discount.qty
                            
                            discount_price = get_discount.discount_fixed_x *  no_of_applied_times
                        }
                        else
                        {
                            let  line_price = Double(qty) * line.price_unit!
                               discount_price = (  line_price * get_discount.discount_dis_x) / 100
                        }
           
                        
                        add_discount_on_product(new_line: line, discount_dis_x: discount_price, pos_promotion_id: promotion.id, pos_conditions_id: get_discount.id,precentValue: get_discount.discount_dis_x)
                        
                        add_conditions_row_parents_ids(get_discount.id,line.product_id!,promotion_types.Buy_X_Get_Discount_On_Y)
                    }
                    else
                    {
                        remove_discount( line)
                    }
                    
                    
//                    check_all_products_in_list(new_line: line, total_products_qty: total_products_qty, get_discount: get_discount, promotion: promotion,parent_product_exist: parent_product_exist,count_lines: lst_products.count)
                    
                }
                
                
            }
            
        }
        
        delegate?.reloadTableOrders()
//        delegate?.reloadTableOrders(re_calc:true,reSave: false)
        
        
    }
    
    func check_all_products_in_list(new_line:pos_order_line_class,total_products_qty:Double,get_discount:get_discount_class,promotion:pos_promotion_class,parent_product_exist:Bool,count_lines:Int)
    {
        let count_promotion_applied = helper.get_total_qty(new_line.product_id!, promotion.id, get_discount.id) //helper.get_total_qty_for(promotion_id: promotion.id)
        var total_qty = count_promotion_applied.total
        total_qty =  total_qty / get_discount.qty

//        if   get_discount.no_of_applied_times <= total_qty.toInt()
//        {
//            return
//        }
        
        
        var removeDiscount = false
        
        if total_products_qty >= get_discount.qty && parent_product_exist == true
        {
            let num_applied  =  (total_products_qty / get_discount.qty).toInt()
 
             
            
            if total_qty.toInt() <=  num_applied
            {
 
                var diff_qty = new_line.qty - get_discount.qty
                if diff_qty > 0
                {
                    diff_qty = new_line.qty  -  diff_qty
                }
                else
                {
                    diff_qty = new_line.qty
                }
                
                var  line_price = diff_qty * new_line.price_unit!
                line_price = Double( num_applied) *  line_price
                let  discount_price = (  line_price * get_discount.discount_dis_x) / 100
                
 

                add_discount_on_product(new_line: new_line, discount_dis_x: discount_price, pos_promotion_id: promotion.id, pos_conditions_id: get_discount.id,precentValue: get_discount.discount_dis_x)
                
                add_conditions_row_parents_ids(get_discount.id,line.product_id!,promotion_types.Buy_X_Get_Discount_On_Y)
            }
            else
            {
                if total_qty.isInteger()
                {
                    removeDiscount = true
                }
               
            }
            
            
            
            
            
        }
        else //if (total_products_qty < get_discount.qty) || parent_product_exist == false
        {
            
            removeDiscount = true
            
        }
        
        if removeDiscount == true
        {
            remove_discount( new_line)
            
        }
        
    }
    
    
    func remove_discount(_ new_line:pos_order_line_class)
    {
        new_line.discount_display_name = ""
        new_line.discount_type = .fixed
        new_line.discount = 0
        
        new_line.promotion_row_parent = 0
        new_line.pos_promotion_id = 0
        new_line.pos_conditions_id = 0
        
        new_line.update_values()
        
        _ =  new_line.save(write_info: true, updated_session_status: .last_update_from_local)
        
    }
    
    func reset_discount(get_discount:get_discount_class,promotion:pos_promotion_class)
    {
        _ =  database_class().runSqlStatament(sql: "delete from relations where re_id1 = \(get_discount.id) and re_table1_table2 = 'pos_promotion|\(promotion_types.Buy_X_Get_Discount_On_Y.rawValue)|\(order.id!)'")

        _ =  database_class().runSqlStatament(sql:  "update pos_order_line  set discount  = 0 , discount_display_name  = '' ,pos_promotion_id  = 0 , pos_conditions_id  = 0 , promotion_row_parent  = 0 where order_id  = \(order.id!) and pos_promotion_id = \(promotion.id) and pos_conditions_id = \(get_discount.id)")
        
        
        let result =  order.pos_order_lines.filter({$0.order_id == order.id! && $0.pos_promotion_id == promotion.id && $0.pos_conditions_id == get_discount.id })
        
        for row in result
        {
            remove_discount(row)
        }
        
        
        
    }
    
    
    
    
    func add_discount_on_product(new_line:pos_order_line_class,discount_dis_x:Double,pos_promotion_id:Int,pos_conditions_id:Int,precentValue:Double)
    {
        let productDiscount = pos_discount_program_class.get_discount_product()
        
        new_line.discount_program_id = productDiscount!.product_id!
        new_line.discount_type = .fixed
        new_line.discount = discount_dis_x
//        new_line.discount_display_name = "Promotion with discount \(discount_dis_x)%"
        if precentValue == 0
        {
            new_line.discount_display_name = "Promotion with discount   \(discount_dis_x.toIntString()) "

        }
        else
        {
            new_line.discount_display_name = "Promotion with discount % \(precentValue) "

        }
        
        new_line.pos_promotion_id = pos_promotion_id
        new_line.pos_conditions_id = pos_conditions_id
        new_line.update_values()
        
        
        _ =  new_line.save(write_info: true, updated_session_status: .last_update_from_local)
        
    }
    
    
    
    func add_conditions_row_parents_ids(_ pos_conditions_id:Int,_ product_id:Int,_ key:promotion_types)
    {
        
        let current_ids = helper.get_row_parents_ids(product_id)
        
        _ =  database_class().runSqlStatament(sql: "delete from relations where re_id1 = \(pos_conditions_id) and re_table1_table2='pos_promotion|\(key.rawValue)|\(order.id!)'")
        
        
        relations_database_class(re_id1: pos_conditions_id, re_id2: current_ids, re_table1_table2: "pos_promotion|\(key.rawValue)|\(order.id!)").save()
        
    }
    
}
