//
//  promotionSelect+masterTable.swift
//  pos
//
//  Created by khaled on 08/03/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation
import UIKit

class promotion_cell: UITableViewCell {
    
    @IBOutlet var lblTitle: UILabel!
}
extension promotionSelect
{
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//
//        return 150
//
//    }
    
     
    
    func tableViewPromotions(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  list_promotions.count
    }
    
    func tableViewPromotions(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "cell"
        
         var cell: promotion_cell! = tableView.dequeueReusableCell(withIdentifier: identifier) as? promotion_cell
        if cell == nil {
            tableView.register(UINib(nibName: "product_choose_cell", bundle: nil), forCellReuseIdentifier: identifier)
            cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? promotion_cell
        }
        
        let prom = self.list_promotions[indexPath.row]
        
        cell?.lblTitle.text = prom["pos_promotion_display_name"] as? String ?? ""

        return cell!
    }
    
    
    func tableViewPromotions(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
        list_selected.removeAll()
        
        let prom = self.list_promotions[indexPath.row]
        selectedhelper.promotion = pos_promotion_class(fromDictionary: promotion_helper_class.remove_perfiex(dic: prom, prfiex: "pos_promotion_"))

        showCondtions()
         
        tableCondtions.reloadData()
        
        
    }
    
    func showCondtions()
    {
        list_condtions.removeAll()
        
      
        if selectedhelper.promotion.promotionType == .Buy_X_Get_Y_Free
        {
           
            list_condtions.append(contentsOf: pos_conditions_class.getAll(promotion_id:selectedhelper.promotion.id ,product_x_id: parent_line.product_id))
          
        }
        else if selectedhelper.promotion.promotionType == .Buy_X_Get_Discount_On_Y || selectedhelper.promotion.promotionType == .Buy_X_Get_Fix_Discount_On_Y
        {
            list_condtions.append(contentsOf:  get_discount_class.getAll(promotion_id:selectedhelper.promotion.id ))

        }
        else if selectedhelper.promotion.promotionType == .Percent_Discount_on_Quantity
        {
            list_condtions.append(contentsOf:  quantity_discount_class.getAll(promotion_id:selectedhelper.promotion.id ))

        }
        else if selectedhelper.promotion.promotionType == .Fix_Discount_on_Quantity
        {
            list_condtions.append(contentsOf:  quantity_discount_amt_class.getAll(promotion_id:selectedhelper.promotion.id ))

        }
    }
    
    
    func validatePromotion(_ promotion:pos_promotion_class)
    {
        
        
    }
    
}
