//
//  restructurePromotions.swift
//  pos
//
//  Created by khaled on 06/03/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import UIKit

class restructurePromotions: NSObject {
    
    private var promotion:pos_promotion_class!
    private var rePromotion:promotions_products_class!

    
    func restructure(_promotion:pos_promotion_class)
    {
        rePromotion = promotions_products_class()
        rePromotion.promotion_id = promotion.id
        
        
        if _promotion.promotion_type == promotion_types.Buy_X_Get_Y_Free.rawValue
        {
            restructure_Buy_X_Get_Y_Free()
        }
        
        
    }
    
    private func restructure_Buy_X_Get_Y_Free()
    {
        let lstCondtion = pos_conditions_class.getAll(promotion_id: promotion.id)
        
        for row in lstCondtion
        {
            let cd = pos_conditions_class(fromDictionary: row)
            rePromotion.promotion_id = cd.pos_promotion_rel_id
            rePromotion.product_x = cd.product_x_id
            rePromotion.quantity_x = cd.quantity
            rePromotion.product_y = cd.product_y_id
            rePromotion.quantity_y = cd.quantity_y
            rePromotion.discount = 100 // 100%
            rePromotion.discount_type = .percentage // 100%
            rePromotion.no_applied = cd.no_of_applied_times
            rePromotion.save()
        }
        
        
    }
    

}
