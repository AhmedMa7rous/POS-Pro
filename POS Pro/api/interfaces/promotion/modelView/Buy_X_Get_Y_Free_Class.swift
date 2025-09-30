//
//  Buy_X_Get_Y_Free+ext.swift
//  pos
//
//  Created by khaled on 30/08/2021.
//  Copyright © 2021 khaled. All rights reserved.
//

import Foundation

 class Buy_X_Get_Y_Free_Class: NSObject {
    
    var helper:promotion_helper_class!
    
    private var delegate:promotion_helper_delegate?
    
    private var line:pos_order_line_class!
    
    private   var  order:pos_order_class!
    
    // MARK: - Buy_X_Get_Y_Free
    
    func check(listPromotion:[[String:Any]]) {

        var newlistPromotion = listPromotion

        self.line = helper.line
        self.order = helper.order
        self.delegate = helper.delegate
        
        let avalible  =  helper.validate2(newlistPromotion)

        
        guard   avalible._avalible  else {
            for condition in newlistPromotion {
                let dic = promotion_helper_class.remove_perfiex(dic: condition, prfiex: "pos_conditions_")
                let pos_condition   = pos_conditions_class(fromDictionary: dic)
                
                remove_promotion(pos_condition)
            }
            
            return
        }
         
        if avalible._promotion != nil
        {
            newlistPromotion.removeAll()
            newlistPromotion.append(avalible._promotion!)
        }

 
        for condition in newlistPromotion {
            
            let promotion = pos_promotion_class(fromDictionary: promotion_helper_class.remove_perfiex(dic: condition, prfiex: "pos_promotion_"))
            apply(condition: condition, promotion: promotion)
        }
        
    }
    
    
    func is_available (pos_condition:pos_conditions_class,_ last_qty:Double,_ new_qty:Double) -> Bool
    {
        if last_qty > new_qty
        {
            return true
        }
        
        let count_products_x = helper.get_total_qty_for(product_id: pos_condition.product_x_id)
        let num_promotion_can_applay = count_products_x / pos_condition.quantity_y

        let count_applied = helper.get_count_free_promotion_applied(product_id_y:pos_condition.product_y_id,pos_condition_id: pos_condition.id)
        let diff_count:Double = count_applied / pos_condition.quantity_y

        // handel to update lower value
        if num_promotion_can_applay < diff_count
        {
            return true
        }
        
        if diff_count.toInt() >=  pos_condition.no_of_applied_times
        {
            return false
        }
        
        return true
    }
    
    
    func apply(condition:[String:Any],promotion:pos_promotion_class) {
        
  
        
        
        
        let product_x_id = condition["pos_conditions_product_x_id"] as? Int ?? 0
        let promotion_display_name = condition["pos_promotion_display_name"] as? String ?? ""
        
        let dic = promotion_helper_class.remove_perfiex(dic: condition, prfiex: "pos_conditions_")
        let pos_condition   = pos_conditions_class(fromDictionary: dic)
        
        
//        if !helper.can_apply(for: promotion) {
//
//
//            remove_promotion(pos_condition)
//
//            return
//        }
        
        
        if product_x_id != line?.product_id
        {
            return
        }
        
        

        
        
        
        
        var add_product:Bool = false
        var pos_condition_quantity_y = pos_condition.quantity_y
        
        if pos_condition._operator == "is_eql_to"
        {
             
            let total_products_qty = helper.get_total_qty_for(product_id:line.product_id!)
             
            
            let diff:Double = total_products_qty / pos_condition.quantity
            
            let qty_int:Int = diff.toInt()
            
            
            pos_condition_quantity_y = Double(qty_int  ) *  pos_condition.quantity_y
            
            add_product = true
            
            
        }
        else if pos_condition._operator == "greater_than_or_eql"
        {
            //            let qty =  line!.qty
            var qty = helper.get_total_qty_for(product_id:line.product_id!)
            
            let quantity = pos_condition.quantity
            if qty >= quantity
            {
                
                // check if applied
                let exist = helper.get_total_qty(pos_condition.product_y_id,pos_condition.pos_promotion_rel_id,pos_condition.id)
                if exist.total <= 0
                {
                    qty = pos_condition.quantity_y
                    add_product = true
                }
       
                
                
            }
            else
            {
                qty = 0
//                add_product = true
                remove_promotion(pos_condition)

                return
            }
            
            pos_condition_quantity_y = qty
        }
        
        
        if add_product == true
        {
            
            
            let ptemp = product_product_class.get(id: pos_condition.product_y_id)
            
            
            let pos_line_new = pos_order_line_class.get_line_promotion(order_id: order.id!, _pos_promotion_id: pos_condition.pos_promotion_rel_id,_pos_conditions_id: pos_condition.id) ??  pos_order_line_class.create(order_id:  order.id!, product: ptemp!)
       
            let last_qty =  pos_line_new.qty
//            let pos_line_new =   pos_order_line_class.create(order_id:  order.id!, product: ptemp!)
            
            if pos_line_new.id == 0 && pos_condition_quantity_y == 0
            {
                return
            }
            
            pos_line_new.product_id = pos_condition.product_y_id
            pos_line_new.qty = pos_condition_quantity_y
            pos_line_new.price_unit = 0
            pos_line_new.price_subtotal = 0
            pos_line_new.price_subtotal_incl = 0
            pos_line_new.custome_price_app = true
            pos_line_new.discount_type = .free
            pos_line_new.write_info = true
            
            if (ptemp!.is_combo)
            {
                pos_line_new.is_combo_line = ptemp!.is_combo
                pos_line_new.product_tmpl_id =  ptemp!.product_tmpl_id
                
                let comboList:product_combo_helper_class = product_combo_helper_class()
                comboList.product_combo = pos_line_new
                comboList.get_auto_select = true
                comboList.order_id = order.id
                comboList.load_combo()
                
                let selected = comboList.list_auto_select
                
                for line in selected
                {
                    line.write_info = true
                }
                
                pos_line_new.selected_products_in_combo = selected
                
            }
            
            
            
            pos_line_new.pos_promotion_id = pos_condition.pos_promotion_rel_id
            pos_line_new.pos_conditions_id = pos_condition.id
            pos_line_new.discount_display_name = promotion_display_name //"Buy X Get Y Free Rule Applied..."
            
            if pos_line_new.qty == 0
            {
                pos_line_new.is_void = true
                delete_promotion_row_parents_free(pos_condition.pos_promotion_rel_id,pos_condition.id,product_x_id,promotion_types.Buy_X_Get_Y_Free)

            }
            else
            {
                if is_available(pos_condition: pos_condition,last_qty,pos_line_new.qty)
                {
                    add_promotion_row_parents_ids( pos_condition.pos_promotion_rel_id,pos_condition.id,product_x_id,promotion_types.Buy_X_Get_Y_Free)

                    pos_line_new.is_void = false
                }
                else if last_qty > pos_line_new.qty
                {
                    add_promotion_row_parents_ids( pos_condition.pos_promotion_rel_id,pos_condition.id,product_x_id,promotion_types.Buy_X_Get_Y_Free)

                    pos_line_new.is_void = false
                }
                
                
               
            }
            
            if (pos_line_new.id == 0)
            {
                if is_available(pos_condition: pos_condition,last_qty,pos_line_new.qty)
                {
                    delegate?.addProduct(line: pos_line_new,new_qty:pos_condition_quantity_y,check_by_line: false,check_last_row: false , stop_check:true )

                }
                
            }
            else
            {
                let frist_index = order.pos_order_lines.firstIndex(where: {$0.id == pos_line_new.id}) ?? -1
                if (frist_index == -1)
                {
                    if is_available(pos_condition: pos_condition,last_qty,pos_line_new.qty)
                    {
                        delegate?.addProduct(line: pos_line_new,new_qty:pos_condition_quantity_y,check_by_line: false,check_last_row: false, stop_check:true  )

                    }
                    
                }
                else
                {
//                    if !helper.can_apply(for: promotion) {
//                        pos_line_new.is_void = true
//
//                    }
                    
                    if pos_line_new.is_void == true
                    {
                        delegate?.saveProduct(line: pos_line_new, rowIndex: frist_index,forceSave:true )
                    }
                    else   if is_available(pos_condition: pos_condition,last_qty,pos_line_new.qty)
                    {
                         delegate?.saveProduct(line: pos_line_new, rowIndex: frist_index ,forceSave: false )
                    }
                    
                    
                    
                }
                
                
            }
            
        }
    }
    
    
    func remove_promotion(_ pos_condition:pos_conditions_class)
    {
        let result =  order.pos_order_lines.filter({$0.order_id == order.id! && $0.pos_promotion_id == pos_condition.pos_promotion_rel_id && $0.pos_conditions_id == pos_condition.id })
        
        if result.count > 0
        {
            let line_pm = result.first
            delegate?.deleteProductt(line: line_pm!)
            delete_promotion_row_parents_free(pos_condition.pos_promotion_rel_id, pos_condition.id, pos_condition.product_x_id, .Buy_X_Get_Y_Free)
        }
        
    }
    
    func delete_line_promotion(_ pos_promotion_id:Int,_ pos_condition_id:Int?,_ order_id:Int)
    {
        
        // delete combo lines
        if pos_condition_id != nil
        {
            _ =  database_class().runSqlStatament(sql: "delete from pos_order_line where parent_line_id  in (SELECT id from pos_order_line where pos_promotion_id = \(pos_promotion_id) and pos_conditions_id =\(pos_condition_id!) and order_id = \(order_id))")
            
            
            _ =  database_class().runSqlStatament(sql: "delete from pos_order_line where pos_promotion_id = \(pos_promotion_id) and pos_conditions_id =\(pos_condition_id!) and order_id = \(order_id)")
        }
        else
        {
            _ =  database_class().runSqlStatament(sql: "delete from pos_order_line where parent_line_id  in (SELECT id from pos_order_line where pos_promotion_id = \(pos_promotion_id)   and order_id = \(order_id))")
            
            
            _ =  database_class().runSqlStatament(sql: "delete from pos_order_line where pos_promotion_id = \(pos_promotion_id)  and order_id = \(order_id)")
        }
    
        
        
    }
    
    
    
    
    func delete_promotion_row_parents_free(_ pos_promotion_id:Int,_ pos_conditions_id:Int,_ product_id:Int,_ key:promotion_types)
    {
        
        
        _ =  database_class().runSqlStatament(sql: "delete from relations where re_id1 = \(pos_promotion_id) and re_table1_table2='pos_promotion|\(pos_conditions_id)|\(key.rawValue)|\(order.id!)'")
        
        
        
    }
    
    
    func add_promotion_row_parents_ids(_ pos_promotion_id:Int,_ pos_conditions_id:Int,_ product_id:Int,_ key:promotion_types)
    {
        
        let current_ids = helper.get_row_parents_ids(product_id)
        
        
        delete_promotion_row_parents_free(pos_promotion_id,pos_conditions_id,product_id,key)
        
        let key = "pos_promotion|\(pos_conditions_id)|\(key.rawValue)|\(order.id!)"
        relations_database_class(re_id1: pos_promotion_id, re_id2: current_ids, re_table1_table2:key ).save()
        
    }
    
    
    
    
    
}
