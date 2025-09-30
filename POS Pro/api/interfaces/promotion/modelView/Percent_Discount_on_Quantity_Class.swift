//
//  Percent_Discount_on_Quantity+ext.swift
//  pos
//
//  Created by khaled on 30/08/2021.
//  Copyright © 2021 khaled. All rights reserved.
//

import Foundation


class Percent_Discount_on_Quantity_Class: NSObject {
    
    var helper:promotion_helper_class!
    
    private weak var delegate:promotion_helper_delegate?
    
    private var line:pos_order_line_class!
    
    private   var  order:pos_order_class!
    
    
    
    // MARK: - percent discount on quantity
    
    func check(  listPromotion:[[String:Any]]) {
         
        var newlistPromotion = listPromotion

        self.line = helper.line
        self.order = helper.order
        self.delegate = helper.delegate
        
        let avalible  =  helper.validate2(newlistPromotion,.Percent_Discount_on_Quantity)

        
        guard avalible._avalible else {
            
            for condition in newlistPromotion {
                
                let promotion = pos_promotion_class(fromDictionary: promotion_helper_class.remove_perfiex(dic: condition, prfiex: "pos_promotion_"))
                let dic = promotion_helper_class.remove_perfiex(dic: condition, prfiex: "quantity_discount_")
                let  get_discount   = quantity_discount_class(fromDictionary: dic)
                
                reset_discount(get_discount: get_discount , promotion: promotion )
            }
            
            delegate?.reloadTableOrders( )
            
            return
        }
        
        
       if avalible._promotion != nil
       {
           newlistPromotion.removeAll()
           newlistPromotion.append(avalible._promotion!)
       }
        
        var stop_next = false
         
        for index in 0...newlistPromotion.count - 1 {
//        for condition in listPromotion {
            
            if stop_next == true
            {
                return
            }
            
            let condition = newlistPromotion[index]
            
            let promotion = pos_promotion_class(fromDictionary: promotion_helper_class.remove_perfiex(dic: condition, prfiex: "pos_promotion_"))

        
            let quantity_discount = quantity_discount_class(fromDictionary: promotion_helper_class.remove_perfiex(dic: condition, prfiex: "quantity_discount_"))
            let quantity =  quantity_discount.quantity_dis
            let discount_price = quantity_discount.discount_dis
 
            let total_products_qty = helper.get_total_qty_for(product_id:promotion.product_id_qty).toInt()
            
//             reset_discount(get_discount: quantity_discount , promotion: promotion )
            
            let no_of_qty_applied_items =  quantity_discount.no_of_applied_times * quantity.toInt()

           
            if total_products_qty != quantity.toInt()
            {
                if index == newlistPromotion.count - 1
                {
                    if total_products_qty < quantity.toInt()
                    {
                         reset_discount(get_discount: quantity_discount , promotion: promotion )
//                        continue
                    }
                    
                }
                else if index == 0 && total_products_qty > no_of_qty_applied_items
                {
                     break
                }
                else
                {
                     reset_discount(get_discount: quantity_discount , promotion: promotion )

//                    continue
                }

            }
            
 
      
//            let discount_one_line_price =  (line.price_unit! * discount_price) / 100

 
                
                let q_products_cannot_applied = total_products_qty   %  quantity.toInt()
                var q_products_can_applied = total_products_qty  - q_products_cannot_applied

                if no_of_qty_applied_items < q_products_can_applied
                {
                    q_products_can_applied = no_of_qty_applied_items
                }
                
                
                let lst_products = order.pos_order_lines.filter({$0.product_id  == promotion.product_id_qty})
                
                var total_qty_applied:Int = 0
                
               
                for line in lst_products
                {
                    if (total_qty_applied < q_products_can_applied)
                    {
                        total_qty_applied += line.qty.toInt()
                        var qty = line.qty.toInt()
                        if qty > q_products_can_applied
                        {
                            qty = q_products_can_applied
                        }
                        
//                        let new_discount = (discount_one_line_price * Double( qty) )
 
                        let  line_price = Double(qty) * line.price_unit!
                        let  new_discount = (  line_price * discount_price) / 100
                        
                        add_discount_on_product(new_line: line, discount_dis_x: new_discount, pos_promotion_id: promotion.id, pos_conditions_id: quantity_discount.id)
                       delegate?.reloadTableOrders(re_calc:true,reSave: true)
                         
                        stop_next = true
                      
                        
                    }
                    else
                    {
                        remove_discount( line)
                    }
                    
   
                    
                }
                
                
         
            
        }
 
 
    }
    
    func check_old(  listPromotion:[[String:Any]]) {
         
        self.line = helper.line
        self.order = helper.order
        self.delegate = helper.delegate
        
        
        guard  helper.validate(listPromotion,.Percent_Discount_on_Quantity) else {
            
            for condition in listPromotion {
                
                let promotion = pos_promotion_class(fromDictionary: promotion_helper_class.remove_perfiex(dic: condition, prfiex: "pos_promotion_"))
                let dic = promotion_helper_class.remove_perfiex(dic: condition, prfiex: "quantity_discount_")
                let  get_discount   = quantity_discount_class(fromDictionary: dic)
                
                reset_discount(get_discount: get_discount , promotion: promotion )
            }
            
            delegate?.reloadTableOrders( )
            
            return
        }
        
        
        for condition in listPromotion
        {
            let promotion = pos_promotion_class(fromDictionary:  promotion_helper_class.remove_perfiex(dic: condition, prfiex: "pos_promotion_"))
     
            let dic = promotion_helper_class.remove_perfiex(dic: condition, prfiex: "quantity_discount_")
            let  get_discount   = quantity_discount_class(fromDictionary: dic)
            
            
            let discount_pres = get_discount.discount_dis //condition["quantity_discount_discount_dis"] as? Double ?? 0
            let quantity_discount = get_discount.quantity_dis //condition["quantity_discount_quantity_dis"] as? Double ?? 0
            
            let num_applied = (line.qty / quantity_discount).toInt()
            
            if num_applied >  get_discount.no_of_applied_times
            {
                break
            }
            
      
              if line.product_id != promotion.product_id_qty
             {
                 return
             }
              
            
             if line!.qty >= quantity_discount
             {
                let discount_price = ( Double( num_applied) * quantity_discount * line.price_unit! * discount_pres) / 100

                     add_discount_on_product(new_line: line, discount_dis_x: discount_price, pos_promotion_id: promotion.id, pos_conditions_id: 0)
                    delegate?.reloadTableOrders()

                break
             }
            else
             {
                remove_discount(line)
                delegate?.reloadTableOrders(re_calc:true,reSave: true)

             }
       
             
             
        }
 
 
    }
    
     
    
 
    
    func remove_discount(_ new_line:pos_order_line_class)
    {
        new_line.discount_display_name = ""
        new_line.discount_type = .percentage
        new_line.discount = 0
        
        new_line.promotion_row_parent = 0
        new_line.pos_promotion_id = 0
        new_line.pos_conditions_id = 0
        
        new_line.update_values()
        
        _ =  new_line.save(write_info: true, updated_session_status: .last_update_from_local)
        
    }
    
    func reset_discount(get_discount:quantity_discount_class,promotion:pos_promotion_class)
    {
   
        

        _ =  database_class().runSqlStatament(sql:  "update pos_order_line  set discount  = 0 , discount_display_name  = '' ,pos_promotion_id  = 0 , pos_conditions_id  = 0 , promotion_row_parent  = 0 where order_id  = \(order.id!) and pos_promotion_id = \(promotion.id) and pos_conditions_id = \(get_discount.id)")
        
        
        let result =  order.pos_order_lines.filter({$0.order_id == order.id! && $0.pos_promotion_id == promotion.id && $0.pos_conditions_id == get_discount.id })
        
        for row in result
        {
            remove_discount(row)
        }
        
        
        
    }
    
    
    func add_discount_on_product(new_line:pos_order_line_class,discount_dis_x:Double,pos_promotion_id:Int,pos_conditions_id:Int)
    {
        let productDiscount = pos_discount_program_class.get_discount_product()
        
        new_line.discount_program_id = productDiscount!.product_id!
        new_line.discount_type = .fixed
        new_line.discount = discount_dis_x
        new_line.discount_display_name = "Promotion with discount \(discount_dis_x.toIntString()) "
        
        
        new_line.pos_promotion_id = pos_promotion_id
        new_line.pos_conditions_id = pos_conditions_id
        new_line.update_values_discount_line()
        
        
        _ =  new_line.save(write_info: true, updated_session_status: .last_update_from_local)
        
    }
    
 
    
}
