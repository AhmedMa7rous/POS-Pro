//
//  TaxTotalModel.swift
//  pos
//
//  Created by M-Wageh on 01/04/2024.
//  Copyright © 2024 khaled. All rights reserved.
//

import Foundation
class TaxTotalModel{
    var  Tax_Amount:String,
         TaxSubtotal_Taxable_Amount:String,
         TaxSubtotal_Tax_Amount:String,
         Percent:String,TaxCategory_ID:String,
         TaxCategory_Percent:String,
         VAT:String,
         TaxTotal_Value:String
    init(_ order:pos_order_class){
        let price_subtotal = String(format: "%.2f", (abs(order.amount_total) - abs(order.amount_tax)))
        let totalVat = String(format: "%.2f", abs(order.amount_tax))
        let totalOrder = String(format: "%.2f", abs(order.amount_total))

        self.Tax_Amount = totalVat
        self.TaxSubtotal_Taxable_Amount = price_subtotal
        self.TaxSubtotal_Tax_Amount = totalVat
        self.Percent = "15.0"
        self.TaxCategory_ID = "S"
        self.TaxCategory_Percent = "15.0"
        self.VAT = "VAT"
        self.TaxTotal_Value = totalVat
    }
   
}
