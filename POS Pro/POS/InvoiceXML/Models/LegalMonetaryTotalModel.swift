//
//  LegalMonetaryTotalModel.swift
//  pos
//
//  Created by M-Wageh on 01/04/2024.
//  Copyright © 2024 khaled. All rights reserved.
//

import Foundation
class LegalMonetaryTotalModel{
    var LineExtensionAmount:String,TaxExclusiveAmount:String,
        TaxInclusiveAmount:String,
        AllowanceTotalAmount:String,
        ChargeTotalAmount:String,
        PrepaidAmount:String,
        PayableAmount:String
   
    init(order:pos_order_class){
        let price_inc = String(format: "%.2f", (abs(order.amount_total)))

        let price_subtotal = String(format: "%.2f", (abs(order.amount_total) - abs(order.amount_tax)))
        let totalVat = String(format: "%.2f", abs(order.amount_tax))
        let totalOrder = String(format: "%.2f", abs(order.amount_total))
        
        self.LineExtensionAmount = price_subtotal
        self.TaxExclusiveAmount = price_subtotal
        self.TaxInclusiveAmount = totalOrder
        self.AllowanceTotalAmount = "0.00"
        self.ChargeTotalAmount = ""
        self.PrepaidAmount = "0.00"
        self.PayableAmount = totalOrder
    }
}
