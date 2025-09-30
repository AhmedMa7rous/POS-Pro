//
//  Discount_percentage_on_Total_Amount+ext.swift
//  pos
//
//  Created by khaled on 30/08/2021.
//  Copyright © 2021 khaled. All rights reserved.
//

import Foundation


class Discount_percentage_on_Total_Amount_Class: NSObject {
    
    var helper:promotion_helper_class!
    
    private var delegate:promotion_helper_delegate?
    
    private var line:pos_order_line_class!
    
    private   var  order:pos_order_class!
    
    
    // MARK: - Discount_percentage_on_Total_Amount
    func check(listPromotion:[[String:Any]]) {
        
        var newlistPromotion = listPromotion

        self.line = helper.line
        self.order = helper.order
        self.delegate = helper.delegate
        
        let avalible  =  helper.validate2(newlistPromotion)

      
        guard   avalible._avalible  else {
            
            let line_discount = self.order.get_discount_line()

            if line_discount != nil
            {
                if line_discount?.pos_promotion_id != 0 && line_discount?.pos_conditions_id != 0
                {
                    remove_discount(line_discount!)
                }
            }
            
            return
        }
        
        if avalible._promotion != nil
        {
            newlistPromotion.removeAll()
            newlistPromotion.append(avalible._promotion!)
        }
        
        
        for condition in newlistPromotion
        {
            let promotion = pos_promotion_class(fromDictionary:  promotion_helper_class.remove_perfiex(dic: condition, prfiex: "pos_promotion_"))

            apply_discount_percent_on_total_amount(condition: condition, promotion: promotion )

        }
 
    }
    
    
    func apply_discount_percent_on_total_amount(condition:[String:Any],promotion:pos_promotion_class  ) {
        
        var validate = true
 
        
        let index = order.pos_order_lines.firstIndex(where: { (item) -> Bool in
            item.product_id == promotion.discount_product_id
        })
        
        let line_discount = self.order.get_discount_line()

        
        if index == nil
        {
            validate = false
            
            if line_discount != nil && line_discount?.pos_conditions_id != 0 && line_discount?.pos_promotion_id != 0
            {
                remove_discount(line_discount!)
            }

        }
        
        
        
        if validate == true
        {

            var total = order.amount_total
            if line_discount != nil
            {
                total = total + (line_discount!.price_subtotal_incl! * -1)
            }
            
            var operatorValue =  total >= promotion.total_amount
            let _operator = condition["pos_promotion_operator"] as? String ?? ""
            
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
 
                
                if line_discount == nil
                {
                    let productDiscount = pos_discount_program_class.get_discount_product()
                    if  productDiscount != nil
                    {
                        helper.add_discount(order: order, value: promotion.total_discount, is_fixed: false, product_discount: productDiscount!.product, discount_display_name: promotion.display_name,pos_promotion_id: promotion.id,pos_conditions_id: 0)
                    }
                }
                
 
                
            }
            else
            {
                 if line_discount != nil
                {
                    if line_discount!.pos_promotion_id == promotion.id
                    {
                        remove_discount(line_discount!)
                        
//                        self.order.save(write_info: false, updated_session_status: .last_update_from_local, re_calc: true)
                    }
                    
                }
                
            }
            
        }
        
        
        
//        delegate?.re_read_order()
        delegate?.reloadTableOrders(re_calc:true,reSave: false)
        
        
    }
    
    func remove_discount(_ line_discount:pos_order_line_class?)
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
    
    
}
