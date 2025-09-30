//
//  promotionSelectHelper.swift
//  pos
//
//  Created by khaled on 10/03/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import UIKit

class promotionSelectHelper: NSObject {
    
    var pos_condition:pos_conditions_class?
    var get_discount:get_discount_class?
    var quantity_discount:quantity_discount_class?
    var quantity_discount_amt:quantity_discount_amt_class?
    
    var promotion:pos_promotion_class!
    var order:pos_order_class!
    var parentLine:pos_order_line_class!

    
    var product:product_product_class!
    var qty:Double = 0
    
   
    var maxValue:Int {
        get {
              
            var no_of_applied_times = 1
            var qty =  Int(parentLine.qty)
            
            if  promotion.promotionType == .Buy_X_Get_Y_Free
                    {
                         
                if pos_condition!._operator != "greater_than_or_eql"
                {
                    no_of_applied_times = pos_condition!.no_of_applied_times

                }
                else if pos_condition!._operator == "greater_than_or_eql"
                {
                    no_of_applied_times = pos_condition!.no_of_applied_times
                    
                    return Int(pos_condition!.quantity_y)

                }
                
                    }
                    else if  promotion.promotionType  == .Buy_X_Get_Discount_On_Y
                    {
                        
                        no_of_applied_times = get_discount!.no_of_applied_times
                        qty = Int(qty / Int(get_discount!.qty))

                    }
                    else if  promotion.promotionType  == .Buy_X_Get_Fix_Discount_On_Y
                    {
                        
                         no_of_applied_times = get_discount!.no_of_applied_times
                         qty = Int(qty / Int(get_discount!.qty))

                    }
                    else if  promotion.promotionType  == .Percent_Discount_on_Quantity
                    {
                     
                         no_of_applied_times = quantity_discount!.no_of_applied_times

                    }
                    else if  promotion.promotionType  == .Fix_Discount_on_Quantity
                    {
                       
                         no_of_applied_times = quantity_discount_amt!.no_of_applied_times

                    }
            
            return qty * no_of_applied_times
        }
    }
    
    func copyClass() -> promotionSelectHelper
    {
        let temp = promotionSelectHelper()
        temp.promotion = self.promotion
        temp.order = self.order
        temp.parentLine = self.parentLine
        temp.product = self.product
        temp.qty = self.qty
        
 
 
        return temp
    }
    

    func checkPromotionType(_condtion:[String:Any])
    {
        if  promotion.promotionType == .Buy_X_Get_Y_Free
                {
                     
             pos_condition = pos_conditions_class(fromDictionary: _condtion)
                      
                }
                else if  promotion.promotionType  == .Buy_X_Get_Discount_On_Y
                {
                    get_discount =  get_discount_class(fromDictionary: _condtion)
                
                }
                else if  promotion.promotionType  == .Buy_X_Get_Fix_Discount_On_Y
                {
                    get_discount =   get_discount_class(fromDictionary: _condtion)
                    
                }
                else if  promotion.promotionType  == .Percent_Discount_on_Quantity
                {
                    quantity_discount =  quantity_discount_class(fromDictionary: _condtion)
                
                }
                else if  promotion.promotionType  == .Fix_Discount_on_Quantity
                {
                    quantity_discount_amt   = quantity_discount_amt_class(fromDictionary: _condtion)
                 
                }

    }
    
    
      func get_line_Buy_X_Get_Y_Free( ) -> pos_order_line_class
    {
        let line =  createLine()
        line.qty =  qty
        line.product_id = pos_condition!.product_y_id
   
        line.price_unit = 0
        line.price_subtotal = 0
        line.price_subtotal_incl = 0
        line.custome_price_app = true
        
        line.discount_type = discountType.free
 
        line.pos_promotion_id =  pos_condition!.pos_promotion_rel_id
        line.pos_conditions_id =  pos_condition!.id
        line.discount_display_name = promotion.display_name

 
 
        return line
    }
    
    
    func get_Buy_X_Get_Discount_On_Y() -> pos_order_line_class?
    {
        
        var line =  createLine()

        line.product_id = get_discount!.product_id_dis_id
        line.qty =  get_discount!.qty * Double(get_discount!.no_of_applied_times)
        line.discount_type = discountType.fixed
 
        line.pos_promotion_id =  get_discount!.pos_quantity_dis_rel_id
        line.pos_conditions_id =  get_discount!.id
        line.promotion_row_parent = self.parentLine.id

        line.price_unit = line.get_price()

        let  line_price = Double(line.qty) * line.price_unit!
        let discount_price = (  line_price * get_discount!.discount_dis_x) / 100
        
        
        line = add_discount_on_product(new_line: line, discount_dis_x: discount_price, precentValue: get_discount!.discount_dis_x)
 
        return line
        
     }
    
    func get_Buy_X_Get_Fix_Discount_On_Y() -> pos_order_line_class?
    {
        var line =  createLine()

        line.product_id = get_discount!.product_id_dis_id
        line.qty =  get_discount!.qty * Double(get_discount!.no_of_applied_times)
        line.discount_type = discountType.fixed
 
        line.pos_promotion_id =  get_discount!.pos_quantity_dis_rel_id
        line.pos_conditions_id =  get_discount!.id
        line.promotion_row_parent = self.parentLine.id

        line.price_unit = line.get_price()

 
        let discount_price =     get_discount!.discount_fixed_x
        
        
        line = add_discount_on_product(new_line: line, discount_dis_x: discount_price, precentValue: 0)
 
        return line
    }
    
    func get_Percent_Discount_on_Quantity() -> pos_order_line_class?
    {
        var line =  parentLine

      
        
        line!.discount_type = discountType.fixed
 
        line!.pos_promotion_id =  quantity_discount!.pos_quantity_rel_id
        line!.pos_conditions_id =  quantity_discount!.id
        line!.promotion_row_parent = self.parentLine.id

 
 
        let  line_price = Double(line!.qty) * line!.price_unit!
        let discount_price = (  line_price * quantity_discount!.discount_dis) / 100
        
        
        line = add_discount_on_product(new_line: line!, discount_dis_x: discount_price, precentValue:  quantity_discount!.discount_dis)
 
        return line
    }
    
    func get_Fix_Discount_on_Quantity() -> pos_order_line_class?
    {
        var line =  parentLine

      
        
        line!.discount_type = discountType.fixed
 
        line!.pos_promotion_id =  quantity_discount_amt!.pos_quantity_amt_rel_id
        line!.pos_conditions_id =  quantity_discount_amt!.id
        line!.promotion_row_parent = self.parentLine.id

 
 
        let discount_price = quantity_discount_amt?.discount_price
        
        
        line = add_discount_on_product(new_line: line!, discount_dis_x: discount_price!, precentValue: 0)
 
        return line
        
    }
    
    
    func createLine() -> pos_order_line_class
    {
        let line =  pos_order_line_class.create(order_id:  order.id!, product:  product)

         line.qty =  1
         line.promotion_row_parent = self.parentLine.id
         line.write_info = true
         line.is_promotion = true
        
        if ( product.is_combo)
        {
            line.is_combo_line =  product.is_combo
            line.product_tmpl_id =  product.product_tmpl_id
            
            let comboList:product_combo_helper_class = product_combo_helper_class()
            comboList.product_combo = line
            comboList.get_auto_select = true
            comboList.order_id = order.id
            comboList.load_combo()
            
            let selected = comboList.list_auto_select
            
            for row in selected
            {
                row.write_info = true
                
                if row.default_product_combo == true  || row.app_require == true
                {
                    let combo = product_combo_class.get_combo(ID: row.combo_id!)
                    if combo.no_of_items < row.auto_select_num!
                    {
                        row.qty = Double(combo.no_of_items)
                        
                    }
                    else
                    {
//                        row.qty = Double( row.auto_select_num ?? 1)
                        row.price_unit = 0
                        
                        if row.app_require
                        {
                            row.qty = Double(1 *  line.qty )
                        }
                        else
                        {
                            row.qty = Double(row.auto_select_num!) * Double( line.qty )
                            
                        }
                    }
              
                }
            }
            
            line.selected_products_in_combo = selected
            
        }
        
        
      
     
        
        return line
    }
    
    func add_discount_on_product(new_line:pos_order_line_class,discount_dis_x:Double, precentValue:Double) -> pos_order_line_class
    {
        let productDiscount = pos_discount_program_class.get_discount_product()
        
        new_line.discount_program_id = productDiscount!.product_id!
        new_line.discount_type = .fixed
        new_line.discount = discount_dis_x
 
        if precentValue == 0
        {
            new_line.discount_display_name = "\(promotion.display_name) with discount   \(discount_dis_x.toIntString()) "

        }
        else
        {
            new_line.discount_display_name = "\(promotion.display_name) with discount % \(precentValue) "

        }
        
        
        new_line.update_values_discount_line()
        
  
        return new_line
//        _ =  new_line.save(write_info: true, updated_session_status: .last_update_from_local)
        
    }
    
   func getChildPromotion() -> [pos_order_line_class]
    {
        if parentLine.id == 0
        {
            return []
        }
        
        let rows = pos_order_line_class.get_lines_promotions(_promotion_row_parent: parentLine.id)

        return rows
    }
    
 
    
    
    static  func deletePromotion(parentLine:pos_order_line_class) -> [pos_order_line_class]
    {
        let rows = pos_order_line_class.get_lines_promotions(_promotion_row_parent: parentLine.id)
        for row in rows
        {
            row.selected_products_in_combo = pos_order_line_class.get_lines_in_combo(order_id: row.order_id, product_id: row.product_id!,parent_line_id: row.id)
            
            row.is_void = true
            
            if row.is_combo_line!
            {
                if row.selected_products_in_combo.count > 0
                {
                    for combo_line in row.selected_products_in_combo
                    {
                        combo_line.is_void = true
                        combo_line.write_info = true
                        combo_line.printed = .none
                        


                    }
                }
            }
            
          _ =  row.save(write_info: true, updated_session_status: .last_update_from_local)
        }
        
        return rows
    }
    
    
    static  func deletePromotionInOrder(order:pos_order_class,delivery_type:delivery_type_class? = nil) -> pos_order_class
    {
        let promotionIds = delivery_type?.getPromotionIds() ?? []
        let rows = order.pos_order_lines
        for row in rows
        {
            //MARK: - check if new orderType have same promotion id
            if promotionIds.count > 0 {
                if let linePromotionId = row.pos_promotion_id,linePromotionId != 0 {
                    if promotionIds.contains(linePromotionId){
                        continue
                    }
                }
            }
            
            if row.promotion_row_parent != 0 && row.pos_promotion_id != 0
            {
                row.is_void = true
            }
            else if row.promotion_row_parent == row.id
            {
                row.promotion_row_parent = 0
                row.is_promotion = false
            }
            
            _ =  row.save(write_info: true, updated_session_status: .last_update_from_local)

        }

        return order
        
    }
    
    
    
}
