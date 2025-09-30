//
//  InvoiceLineModel.swift
//  pos
//
//  Created by M-Wageh on 01/04/2024.
//  Copyright © 2024 khaled. All rights reserved.
//

import Foundation
class InvoiceLineModel{
    var productID:Int
    var InvoicedQuantity:Double
    var LineExtensionAmount:String
    var TaxAmount:String
    var RoundingAmount:String
    var TaxableAmount:String
    
    var TaxSubtotal_TaxAmount:String
    var TaxSubtotal_Percent:String
    var TaxCategory_ID:String
    var TaxCategory_Percent:String
    var TaxScheme_ID:String
    
    var Item_Description:String
    var Item_NAME:String
    var ClassifiedTaxCategory_ID:String
    var ClassifiedTaxCategory_Percent:String
    var ClassifiedTaxCategory_TaxScheme_ID:String
    var PriceAmount:String
    
    
    init(from line:pos_order_line_class){

        let id_taxCategory = "S"
        let id_taxScheme = "VAT"
        let precentTax = "15.0"
        let producct = line.product
        let amount_tax_double = (abs(line.price_subtotal_incl ?? 0.0)) - (abs(line.price_subtotal ?? 0.0))
        let totalVat = String(format: "%.2f", abs(amount_tax_double))
        let price_subtotal = String(format: "%.2f", abs(line.price_subtotal ?? 0.0))
        let price_subtotal_incl = String(format: "%.2f", abs(line.price_subtotal_incl ?? 0.0))
        let price_unite = String(format: "%.2f", (abs(line.price_subtotal ?? 0.0))/abs(line.qty))
        self.productID = line.product_id ?? 0
        self.InvoicedQuantity = abs(line.qty)
        self.LineExtensionAmount = price_subtotal
        self.TaxAmount = totalVat
        self.RoundingAmount = price_subtotal_incl
        self.TaxableAmount = price_subtotal
        self.TaxSubtotal_TaxAmount = totalVat
        self.TaxSubtotal_Percent = precentTax
        self.TaxCategory_ID = id_taxCategory
        self.TaxCategory_Percent = precentTax
        self.TaxScheme_ID = id_taxScheme
        self.Item_Description = producct?.description_ ?? ""
        self.Item_NAME = producct?.name ?? ""
        self.ClassifiedTaxCategory_ID = id_taxCategory
        self.ClassifiedTaxCategory_Percent = precentTax
        self.ClassifiedTaxCategory_TaxScheme_ID = id_taxScheme
        self.PriceAmount = price_subtotal
    }


}
