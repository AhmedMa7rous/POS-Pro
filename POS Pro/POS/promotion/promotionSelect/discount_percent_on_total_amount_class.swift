//
//  discount_percent_on_total_amount_class.swift
//  pos
//
//  Created by khaled on 17/03/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import UIKit

class discount_percent_on_total_amount_class: NSObject {

    var order:pos_order_class!
    var promotion:pos_promotion_class?
    
    func initPromotion()
    {
//        promotion = pos_promotion_class.get(promotion_type: "dicount_total" ,filter_code:nil)

        
        
 
 
    }

    func check()
    {
        guard order != nil, let orderTypeID = order.orderType?.id else{
            return
        }
        if !order.promotion_code.isEmpty
        {
            promotion = pos_promotion_class.get(promotion_type: "dicount_total" ,filter_code:order.promotion_code,orderType: orderTypeID)
        }
        else
        {
            if !(order.reward_bonat_code ?? "").isEmpty
            {
                promotion = promo_bonat_class.getPosPromotion(for: order.uid ?? "")
            }else{
                promotion = pos_promotion_class.get(promotion_type: "dicount_total" ,filter_code:nil,orderType: orderTypeID)
            }
        }

        if promotion != nil
        {
            apply_discount_percent_on_total_amount(promotion: promotion!)
        }else{
            let line_discount = self.order.get_discount_line()
            if line_discount != nil &&  (line_discount?.pos_promotion_id ?? 0) != 0
            {
                remove_discount_percent_on_total_amount(line_discount!)
            }
        }
    }
    
    func apply_discount_percent_on_total_amount(promotion:pos_promotion_class  )
    {
        
        var validate = true
        let line_discount = self.order.get_discount_line()
        var removeDiscountLine = false

        
//        if !promotion.filter_code.isEmpty
//        {
//            if order.promotion_code != promotion.filter_code
//            {
//                validate = false
//
//                if line_discount != nil
//                {
////                    remove_discount_percent_on_total_amount(line_discount!)
//                    removeDiscountLine = true
//                }
//
//            }
//         }
 
//        if validate == false
//        {
//            return
//        }
       
        
        let index = order.pos_order_lines.firstIndex(where: { (item) -> Bool in
            item.product_id == promotion.discount_product_id
        })
        

        let helper = promotion_helper_class()
        helper.order = order
        let isBonat = !(order.reward_bonat_code?.isEmpty ?? false)
        validate =  helper.can_apply(for: promotion)
        if isBonat {
            validate = true
        }
        if (promotionValidate.validate(promotion) == false || validate == false) && !isBonat
        {
            validate = false
            
            if line_discount != nil && line_discount?.pos_conditions_id == 0 && line_discount?.pos_promotion_id != 0
            {
//                remove_discount_percent_on_total_amount(line_discount!)
                removeDiscountLine = true

            }
        }
        
        
        if index == nil && validate == true
        {
//            validate = false
            
            if line_discount != nil && line_discount?.pos_conditions_id != 0 && line_discount?.pos_promotion_id != 0
            {
//                remove_discount_percent_on_total_amount(line_discount!)
                removeDiscountLine = true

            }

        }
        
       
        
        
        var operatorValue = false
        
        if validate == true &&  order.promotion_code == promotion.filter_code
        {
            //need to get total without insurance product
            var total = order.amount_total
            if line_discount != nil
            {
                total = total + (line_discount!.price_subtotal_incl! * -1)
                if let lineServiceCharge =  self.order.get_service_charge_line(){
                    total = total + (lineServiceCharge.price_subtotal_incl ?? 0.0)
                }

            }
            
              operatorValue =  total >= promotion.total_amount
            let _operator = promotion._operator //condition["pos_promotion_operator"] as? String ?? ""
            
            if !_operator.isEmpty  {
                if _operator == promotion_operator.is_eql_to.rawValue
                {
                    operatorValue =  total == promotion.total_amount
                }
                else if _operator == promotion_operator.greater_than_or_eql.rawValue
                {
                    operatorValue =  total >= promotion.total_amount
                }
                
            }
            
            if operatorValue
            {
 
                
                if line_discount != nil
                {
                    remove_discount_percent_on_total_amount(line_discount!)
                }
                
                    let productDiscount = pos_discount_program_class.get_discount_product()
                    if  productDiscount != nil
                    {
                        let is_fixed = promotion.promotionType == .Discount_fixed_on_Total_Amount
                        add_discount(order: order, value: promotion.total_discount, is_fixed: is_fixed, product_discount: productDiscount!.product, discount_display_name: promotion.display_name,pos_promotion_id: promotion.id,pos_conditions_id: 0,max_discount: promotion.max_discount,isBonat:isBonat)
                    }
              
                
 
                
            }
            else
            {
                 if line_discount != nil
                {
                    if line_discount!.pos_promotion_id == promotion.id
                    {
//                        remove_discount_percent_on_total_amount(line_discount!)
                        removeDiscountLine = true

                     }
                    
                }
                
            }
            
        }
        
        if operatorValue && removeDiscountLine
        {
            remove_discount_percent_on_total_amount(line_discount!)
        }
        else if operatorValue == false && removeDiscountLine
        {
            if line_discount?.pos_promotion_id != 0
            {
                remove_discount_percent_on_total_amount(line_discount!)
            }
        }
        
        
        
 
//        delegate?.reloadTableOrders(re_calc:true,reSave: false)
        
        
    }
    
    func remove_discount_percent_on_total_amount(_ line_discount:pos_order_line_class?)
    {
        if line_discount == nil
        {
            return
        }
        
        line_discount!.pos_promotion_id = 0
        line_discount!.discount_program_id = 0
        line_discount!.is_void = true
        _ =  line_discount!.save(write_info: true, updated_session_status: .last_update_from_local)
        self.order.save(write_info: false, updated_session_status: .last_update_from_local, re_calc: true)
    }
    
    
    func add_discount( order: pos_order_class ,value:Double,is_fixed:Bool ,product_discount:product_product_class , discount_display_name:String,pos_promotion_id:Int,pos_conditions_id:Int,max_discount:Double? = nil,isBonat:Bool = false)
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
            
            line_discount.update_values_discount_line()
            
        }
        else
        {
            let discount_value =  order.get_discount_percentage_value(percentage_value: value)
            
            
            var price_subtotal_incl = discount_value.price_subtotal_incl * -1
            if isBonat{
                if let maxValue = max_discount, maxValue != 0 {
                    if abs(price_subtotal_incl) > maxValue {
                        add_discount( order: order ,value:(maxValue * -1),is_fixed:true ,product_discount:product_discount , discount_display_name:discount_display_name,pos_promotion_id:pos_promotion_id,pos_conditions_id:pos_conditions_id,max_discount:max_discount)
                        return
                    }
                }
            }
 

            
            line_discount.custom_price = price_subtotal_incl
            line_discount.price_unit = price_subtotal_incl
            
            line_discount.discount_display_name = discount_display_name
            line_discount.discount_type = .percentage
            line_discount.discount = value
            
            line_discount.pos_promotion_id = pos_promotion_id
            line_discount.pos_conditions_id =  pos_conditions_id
            
            line_discount.update_values()
            
            line_discount.price_subtotal = discount_value.price_subtotal * -1
            line_discount.price_subtotal_incl = discount_value.price_subtotal_incl * -1

        }
        
        if line_discount.price_subtotal_incl != 0.0{
            _ =  line_discount.save(write_info: true, updated_session_status: .last_update_from_local)
            
            order.save(write_info: true, updated_session_status: .last_update_from_local, re_calc: true)
        }
        
    }
    
}
