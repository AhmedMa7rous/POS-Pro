//
//  CashHtmlFiles.swift
//  pos
//
//  Created by M-Wageh on 31/03/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation
struct CashHtmlFiles{
    static let shared = CashHtmlFiles()
    let logo_company:String?
    let odoo_header:String?
    let order_number:String?
    let vat_number:String?
    let ref_number:String?
    let CR_number:String?
    let PRINTER_NAME:String?
    let POS_name:String?
    let customer_name:String?
    let customer_vat:String?
    let table_number:String?
    let date_invoice:String?
    let order_type:String?
    let qty_item_price_pos:String?
    let qty_item_price_kds:String?
    let single_item:String?
    let single_item_combo:String?

    let single_item_kds:String?
    let single_item_combo_kds:String?

    let single_item_unite_price:String?
    let single_item_combo_unite_price:String?

    let qty_item_unite_price:String?
    let note_invoice:String?
    let note_invoice_unite_price:String?

    let price_section:String?
    let qr_html:String?
    let invoice_html:String?
    let insurance_html:String?
    let insurance_section_items_html:String?
    let item_td_html:String?

    let driver_name:String?
    let resend_try:String?

    private init(){
        self.logo_company = FileMangerHelper.shared.getString(from :"logo_company")
        self.odoo_header = FileMangerHelper.shared.getString(from :"odoo_header")
        self.order_number = FileMangerHelper.shared.getString(from :"order_number")
        self.vat_number = FileMangerHelper.shared.getString(from :"vat_number")
        self.ref_number = FileMangerHelper.shared.getString(from :"ref_number")
        self.CR_number = FileMangerHelper.shared.getString(from :"CR_number")
        self.PRINTER_NAME = FileMangerHelper.shared.getString(from :"PRINTER_NAME")
        self.POS_name = FileMangerHelper.shared.getString(from :"POS_name")
        self.customer_name = FileMangerHelper.shared.getString(from :"customer_name")
        self.customer_vat = FileMangerHelper.shared.getString(from :"customer_vat")
        self.table_number = FileMangerHelper.shared.getString(from :"table_number")
        self.date_invoice = FileMangerHelper.shared.getString(from :"date_invoice")
        self.order_type = FileMangerHelper.shared.getString(from :"order_type")
        self.qty_item_price_pos = FileMangerHelper.shared.getString(from :"qty_item_price_pos")
        self.qty_item_price_kds = FileMangerHelper.shared.getString(from :"qty_item_price_kds")
        self.single_item = FileMangerHelper.shared.getString(from :"single_item")
        self.single_item_kds = FileMangerHelper.shared.getString(from :"single_item_kds")
        self.note_invoice = FileMangerHelper.shared.getString(from :"note_invoice")
        self.price_section = FileMangerHelper.shared.getString(from :"price_section")
        self.qr_html = FileMangerHelper.shared.getString(from :"qr_html")
        self.invoice_html = FileMangerHelper.shared.getString(from :"invoice_html")
        self.driver_name = FileMangerHelper.shared.getString(from :"driver_name")
        self.insurance_html = FileMangerHelper.shared.getString(from: "insurance_html")
        self.insurance_section_items_html = FileMangerHelper.shared.getString(from: "insurance_section")
        self.item_td_html = FileMangerHelper.shared.getString(from: "item_td_html")
        self.qty_item_unite_price = FileMangerHelper.shared.getString(from :"item_qty_unite_price_header")
        self.single_item_unite_price = FileMangerHelper.shared.getString(from :"single_item_unit_price")
        self.single_item_combo = FileMangerHelper.shared.getString(from :"single_item_combo")
        self.single_item_combo_kds = FileMangerHelper.shared.getString(from :"single_item_combo_kds")
        self.single_item_combo_unite_price = FileMangerHelper.shared.getString(from :"single_item_combo_unit_price")
        self.note_invoice_unite_price = FileMangerHelper.shared.getString(from :"note_invoice_unite_price")
        self.resend_try = FileMangerHelper.shared.getString(from :"resend_try")

    }
    
    
    
    
}
