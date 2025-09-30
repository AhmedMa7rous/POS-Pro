//
//  calculate_tax.swift
//  pos
//
//  Created by khaled on 8/23/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

class calculate_tax: NSObject {
    
    /*
     compute_all: function(taxes, price_unit, quantity, currency_rounding, no_map_tax) {
     var self = this;
     var list_taxes = [];
     var currency_rounding_bak = currency_rounding;
     if (this.pos.company.tax_calculation_rounding_method == "round_globally"){
     currency_rounding = currency_rounding * 0.00001;
     }
     var total_excluded = round_pr(price_unit * quantity, currency_rounding);
     var total_included = total_excluded;
     var base = total_excluded;
     _(taxes).each(function(tax) {
     if (!no_map_tax){
     tax = self._map_tax_fiscal_position(tax);
     }
     if (!tax){
     return;
     }
     if (tax.amount_type === 'group'){
     var ret = self.compute_all(tax.children_tax_ids, price_unit, quantity, currency_rounding);
     total_excluded = ret.total_excluded;
     base = ret.total_excluded;
     total_included = ret.total_included;
     list_taxes = list_taxes.concat(ret.taxes);
     }
     else {
     var tax_amount = self._compute_all(tax, base, quantity);
     tax_amount = round_pr(tax_amount, currency_rounding);
     
     if (tax_amount){
     if (tax.price_include) {
     total_excluded -= tax_amount;
     base -= tax_amount;
     }
     else {
     total_included += tax_amount;
     }
     if (tax.include_base_amount) {
     base += tax_amount;
     }
     var data = {
     id: tax.id,
     amount: tax_amount,
     name: tax.name,
     };
     list_taxes.push(data);
     }
     }
     });
     return {
     taxes: list_taxes,
     total_excluded: round_pr(total_excluded, currency_rounding_bak),
     total_included: round_pr(total_included, currency_rounding_bak)
     };
     },
     */
    func calc_tax(taxes:[Any] ,price_unit:Double , quantity:Double , currency_rounding:Double? , no_map_tax:Double?,isCombo:Bool,discount:Double)
        ->  (taxes:[Any], total_excluded: Double, total_included: Double , tax_amount:Double) {
            
            
            var list_taxes:[Any] = []
            
            var total_excluded = price_unit
//            if isCombo == false
//            {
                total_excluded = (price_unit * quantity) - (discount)
//            }
            
            
            total_excluded = total_excluded.rounded_app()
            var total_included = total_excluded
            var base = total_excluded
            let start_base = base
            var taxAmount:Double = 0
            
          
            let company_local_id = SharedManager.shared.posConfig().company_id
            
            for tax_id in taxes
            {
                let clsTax:account_tax_class! = account_tax_class.get(tax_id:  tax_id as! Int)
                
                if clsTax != nil
                {
                    let company_id = clsTax.company_id
                    
                    if company_id == company_local_id
                    {
                        
                        
                        if (clsTax!.amount_type == account_tax_class.amount_type_taxs.group.rawValue)
                        {
                            let ret = self.calc_tax(taxes: clsTax.children_tax_ids, price_unit:price_unit, quantity:quantity, currency_rounding:currency_rounding, no_map_tax: no_map_tax,isCombo: isCombo,discount:discount)
                            
                            total_excluded = ret.total_excluded
                            base = ret.total_excluded
                            total_included = ret.total_included
                            //                list_taxes.addObjects(from: ret.taxes )
                            list_taxes.append(ret.taxes)
                            
                        }
                        else
                        {
                            var tax_amount = compute_all(tax: clsTax!, base_amount: start_base, quantity: quantity,isCombo: isCombo)
                            tax_amount = tax_amount.rounded_app()
                            //                if (tax_amount > 0)
                            //                {
                            if (clsTax.price_include) {
                                total_excluded -= tax_amount
                                base -= tax_amount
                            }
                            else {
                                total_included += tax_amount
                            }
                            
                            if (clsTax.include_base_amount) {
                                base += tax_amount
                            }
                            
                            taxAmount = tax_amount
                            
                            var data:[String:Any] = [:]
                            data["id"] = clsTax.id
                            data["amount"] = tax_amount
                            data["name"] = clsTax.name
                            
                            //                    data.setValue(clsTax.id, forKey: "id")
                            //                    data.setValue(tax_amount, forKey: "amount")
                            //                    data.setValue(clsTax.name, forKey: "name")
                            
                            list_taxes.append (data)
                            
                            //                }
                            
                        }
                        
                    }
                }
            }
            
            
            
            return (list_taxes, total_excluded.rounded_app(),total_included.rounded_app(),taxAmount)
            
    }
    
    
    func compute_all(tax:account_tax_class, base_amount:Double, quantity:Double,isCombo:Bool) -> Double {
        
        if (tax.amount_type == account_tax_class.amount_type_taxs.fixed.rawValue)
        {
            let qty = quantity
            //            if isCombo == true
            //            {
            //                qty = 1
            //            }
            
            let sign_base_amount:Double = base_amount >= 0 ? 1 : -1
            return (abs(tax.amount) * sign_base_amount) * qty
            
        }
        
        if (tax.amount_type == account_tax_class.amount_type_taxs.percent.rawValue && !tax.price_include) ||
            (tax.amount_type == account_tax_class.amount_type_taxs.division.rawValue &&  tax.price_include)
            
        {
            
            return (base_amount * tax.amount / 100)
            
        }
        
        if (tax.amount_type == account_tax_class.amount_type_taxs.percent.rawValue && tax.price_include)
        {
            
            return (base_amount - (base_amount / (1 + tax.amount / 100)))
            
        }
        
        if (tax.amount_type == account_tax_class.amount_type_taxs.division.rawValue && !tax.price_include)
        {
            
            return (base_amount / (1 - tax.amount / 100) - base_amount)
            
        }
        
        return 0
    }
    
    
    func get_tax(tax_id:Int) -> account_tax_class? {
        
        let arr:[account_tax_class] = account_tax_class.getAll()
        
        
        for item in arr
        {
           
            if item.id == tax_id
            {
                return item
            }
        }
        
        
        return nil
    }
    
    
    
    
    
    
    
    
    
    
}
