//
//  condtionsList.swift
//  pos
//
//  Created by khaled on 08/03/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation


extension promotionSelect
{
 
    
    func tableViewCondtions(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  list_condtions.count
    }
    
    func tableViewCondtions(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        
        let identifier = "Cell"
        var cell: product_choose_cell! = tableView.dequeueReusableCell(withIdentifier: identifier) as? product_choose_cell
        if cell == nil {
            tableView.register(UINib(nibName: "product_choose_cell", bundle: nil), forCellReuseIdentifier: identifier)
            cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? product_choose_cell
        }
        
        let row = self.list_condtions[indexPath.row]
        
        let tempSelectedhelper = selectedhelper.copyClass()
        tempSelectedhelper.checkPromotionType(_condtion: row)
        
        let product = getProduct(tempSelectedhelper)
        
        let rowIndex = list_selected.firstIndex(where: {$0.product_id == product!.id}) ?? -1
        
        if rowIndex >= 0
        {
            cell.line = list_selected[rowIndex]
           

            cell.index = rowIndex

        }
        else
        {
            cell.line = nil
        }
        
        cell.parent = self
        
         cell.selectedhelper = tempSelectedhelper
       
        cell.order = order
        cell.updateCell()
        
 
        
        return cell!
    }
    
    
    func tableViewCondtions(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let row = self.list_condtions[indexPath.row]
        
        selectedhelper.checkPromotionType(_condtion: row)
        
        apply(_selectedhelper:selectedhelper)

        
    }
    
    func apply(_selectedhelper:promotionSelectHelper!)
    {
        selectedhelper = _selectedhelper
        
        let product = getProduct(_selectedhelper)
        
        let rowIndex = list_selected.firstIndex(where: {$0.product_id == product!.id}) ?? -1
        
        var line:pos_order_line_class?
        
        if rowIndex >= 0
        {
            line = list_selected[rowIndex]
            
            if line!.tag_temp == "selected"
            {
                line!.tag_temp = ""
                
                if selectedhelper.promotion.promotionType == .Buy_X_Get_Y_Free
                {
                    line!.is_void = true
                }
                else
                {
                    line!.discount_program_id = 0
                    line!.discount_type = .fixed
                    line!.discount = 0
                    line!.promotion_row_parent = 0
                    line!.pos_promotion_id = 0
                    line!.pos_conditions_id = 0
                    line!.is_promotion = false
                    line!.discount_display_name = ""
                    line!.update_values()
                }
            }
            else
            {
                line!.tag_temp = "selected"
                line!.is_void = false


            }
            list_selected[rowIndex] = line!
        }
         
        selectedhelper.product = product!
        
            if selectedhelper.promotion.promotionType == .Buy_X_Get_Y_Free
            {
//                 let condtion = pos_conditions_class(fromDictionary: row)
//                selectedhelper.pos_condition = condtion
             
                
                add(line,rowIndex: rowIndex,promotionLine: line == nil ? selectedhelper.get_line_Buy_X_Get_Y_Free(): nil )
                
               
            }
            else if selectedhelper.promotion.promotionType == .Buy_X_Get_Discount_On_Y
            {
//                let  condtion = get_discount_class(fromDictionary: row)
//                selectedhelper.get_discount = condtion

                add(line,rowIndex: rowIndex,promotionLine: line == nil ? selectedhelper.get_Buy_X_Get_Discount_On_Y(): nil )

            }
            else if selectedhelper.promotion.promotionType == .Buy_X_Get_Fix_Discount_On_Y
            {
//                let  condtion = get_discount_class(fromDictionary: row)
//
//                selectedhelper.get_discount = condtion

                add(line,rowIndex: rowIndex,promotionLine: line == nil ? selectedhelper.get_Buy_X_Get_Fix_Discount_On_Y(): nil )
                
             }
            else if selectedhelper.promotion.promotionType == .Percent_Discount_on_Quantity
            {
//                let  condtion = quantity_discount_class(fromDictionary: row)
//
//                selectedhelper.quantity_discount = condtion

                add(line,rowIndex: rowIndex,promotionLine: line == nil ? selectedhelper.get_Percent_Discount_on_Quantity(): nil,newqty: parent_line.qty )
             }
            else if selectedhelper.promotion.promotionType == .Fix_Discount_on_Quantity
            {
//                let  condtion = quantity_discount_amt_class(fromDictionary: row)
//
//                selectedhelper.quantity_discount_amt = condtion
 
                add(line,rowIndex: rowIndex,promotionLine: line == nil ? selectedhelper.get_Fix_Discount_on_Quantity(): nil ,newqty: parent_line.qty)
            }
     
         


        
        tableCondtions.reloadData()
    }
    
    func add(_ _line:pos_order_line_class?,rowIndex:Int,promotionLine:pos_order_line_class?,newqty:Double = 1)
    {
 
        if _line == nil
        {
            selectedhelper.qty = newqty
        
            promotionLine!.qty = newqty
            promotionLine!.tag_temp = "selected"
            
             list_selected.append(promotionLine!)

        }
        else
        {
            // line removed before saved in DB , so we can remove it from list
            if _line!.id == 0
            {
                list_selected.remove(at: rowIndex)
            }
            else
            {
//                _line!.qty = 1
                list_selected[rowIndex] = _line!

            }
            
        }
    }
    
    
   
    
    
    
}
