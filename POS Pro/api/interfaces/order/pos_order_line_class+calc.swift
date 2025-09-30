//
//  productProductClass_calc_ext.swift
//  pos
//
//  Created by Khaled on 4/25/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import UIKit

extension pos_order_line_class  {
    
    
    func calcTotal(price:Double) -> Double
    {
        //        let price_num:Double =  self.get_price()
        //self.price_app_priceList ?? 0
        //        if self.price_app != "" {
        //            price_num = self.price_app.toDouble()!
        //        }
        
        let qty_num:Double! =   self.qty
        //        let price_num:Double! = self.price_app.toDouble() ?? 0
        let disc_num:Double! =  self.discount
        
        var total  = price
        if is_combo_line == true
        {
            total = total + self.extra_price!
        }
        else
        {
            total  = qty_num * price
        }
        
        //        if disc_num != 0
        //        {
        //            let disc_amount = (disc_num * total) / 100
        //            total = total - disc_amount
        //        }
        total = total - getDiscountValue(total: total, disc_num: disc_num)
        return total
    }
    
    func getDiscountValue(total:Double,disc_num:Double) -> Double
    {
        if self.discount_type == .fixed
        {
            return disc_num
        }
        else
        {
            if disc_num != 0
            {
                let disc_amount = (disc_num * total) / 100
                return disc_amount
            }
        }
        
        
        return 0
    }
    
    func  get_tax(price:Double,discount:Double) -> (taxes:[Any], total_excluded: Double, total_included: Double , tax_amount:Double)  {
        let taxs = calculate_tax()
        
        //        let price = self.get_price()
        let rec = taxs.calc_tax(taxes: self.product.get_taxes_id(posLine: self)   , price_unit: price , quantity: self.qty  , currency_rounding: 0, no_map_tax: 0,isCombo: self.is_combo_line!,discount: discount)
        
        return rec
    }
    
    
    func get_price() -> Double
    {
        //        self.price_app = (self.price_app == nil) ? "" : self.price_app
        self.qty  = ( self.qty  == 0) ? 1 : self.qty
        
        
        return get_price_custome()
        
    }
    
    
    func get_price_custome() -> Double
    {
//        if self.pos_promotion_id != 0
//        {
//            self.custome_price_app = true
//        }
        
        if self.custome_price_app == true
        {
            return  self.price_unit ?? 0
        }
        else if self.priceList != nil
        {
            let calc :calculate_pricelist = calculate_pricelist()
            let temp_product = self.product
            if self.custom_price != 0
            {
                temp_product?.lst_price =  self.custom_price!
                
            }
            
            return   calc.get_price(product: temp_product!, rule: self.priceList, quantity: self.qty)
            
        }
        else
        {
            if self.custom_price != 0
            {
                return self.custom_price!
                
            }
            else
            {
                return self.product.price
                
            }
        }
    }
    
    
    func update_values(checkAddOnPriceList:Bool = true)
    {
        
       
        
        if self.priceList == nil
        {
      
            self.priceList = product_pricelist_class.getDefault()
        }
        
        var price = 0.0
        if is_combo_line == true && parent_product_id != 0
        {
            price =  self.extra_price!
            if checkAddOnPriceList && SharedManager.shared.appSetting().enable_new_combo {
                if let priceListID = self.priceList?.id{
                    if let addOnPriceListValue =  pos_line_add_on_price_list_class.getPriceAddon(for: self.uid, priceListID: priceListID ){
                        if addOnPriceListValue != self.extra_price{
                            self.extra_price = addOnPriceListValue
                            self.save()
                        }
                        price =  addOnPriceListValue
                    }
                }
            }
        }
        else
        {
            price = self.get_price()
        }
        
        

        self.price_unit = price;
        
        if self.discount! != 0
        {
            if self.discount_type == .fixed
            {
                let tax = self.get_tax(price: price,discount: self.discount!)
                
                self.price_subtotal_incl = tax.total_included //- self.discount!
                self.price_subtotal = tax.total_excluded //- self.discount!
            }
            else
            {
                let pos = SharedManager.shared.posConfig()
                let line_discount:pos_order_line_class? = pos_order_line_class.get(order_id: self.order_id, product_id: pos.discount_program_product_id!,is_void: false)
                
                if line_discount?.id == self.id
                {
                    let tax = self.get_tax(price: price,discount: 0)

                        self.price_subtotal_incl = tax.total_included
                        self.price_subtotal = tax.total_excluded
                }
                else
                {
                    let disc_amount = ((self.discount! * price * self.qty) / 100)

                    let tax = self.get_tax(price: price,discount: disc_amount)

                    
                        self.price_subtotal_incl = tax.total_included // - disc_amount
                        self.price_subtotal = tax.total_excluded //- disc_amount
                }
                
         
                     
            }
    
        }
        else
        {
            let tax = self.get_tax(price: price,discount: 0)

            self.price_subtotal_incl = tax.total_included
            self.price_subtotal = tax.total_excluded
        }
   
        
        //        }
//        update_values_discount_line()
        
        
    }
    
    
    func update_values_discount_line()
    {
        let price = getDiscountValue_promotion(total: self.price_unit!, disc_num: self.discount!)
       
            
            if self.discount_type == .fixed
            {
                let tax = self.get_tax(price: price,discount:self.discount!)

                self.price_subtotal_incl = tax.total_included //- self.discount!
                self.price_subtotal = tax.total_excluded //- self.discount!
            }
            else
            {
                let tax = self.get_tax(price: price,discount:0)

                self.price_subtotal_incl = tax.total_included
                self.price_subtotal = tax.total_excluded
            }
       
         
    }
    
    func getDiscountValue_promotion(total:Double,disc_num:Double) -> Double
    {
        if self.discount_type == .fixed
        {
            return total
        }
        else
        {
            if disc_num != 0
            {
                let disc_amount = total - ((disc_num * total) / 100)
                return disc_amount
            }
        }
        
        
        return 0
    }
    
    
}
