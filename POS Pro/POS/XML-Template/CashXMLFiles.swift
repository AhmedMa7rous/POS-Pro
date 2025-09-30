//
//  CashXMLFiles.swift
//  pos
//
//  Created by M-Wageh on 01/04/2024.
//  Copyright © 2024 khaled. All rights reserved.
//

import Foundation
struct CashXMLFiles{
    static let shared = CashXMLFiles()
    let xml_Invoice_template:String?
    let xml_tax_total_template:String?
    let xml_legal_monetary_total_template:String?
    let accounting_customer_party_template:String?
    let invoice_line_template:String?
    let additional_document_reference_template:String?
    let signature_template:String?
    let accounting_supplier_party_template:String?
    let payment_means_template:String?
    let ubl_extensions_template:String?
    let ubl_extension_temp_odoo:String?

    private init(){
        self.xml_Invoice_template = FileMangerHelper.shared.getString(from :"xml_Invoice_template",with:"xml")
        self.xml_tax_total_template = FileMangerHelper.shared.getString(from :"xml_tax_total_template",with:"xml")
        self.xml_legal_monetary_total_template = FileMangerHelper.shared.getString(from :"xml_legal_monetary_total_template",with:"xml")
        self.accounting_customer_party_template = FileMangerHelper.shared.getString(from :"accounting_customer_party_template",with:"xml")
        self.invoice_line_template = FileMangerHelper.shared.getString(from :"invoice_line_template",with:"xml")
        self.additional_document_reference_template = FileMangerHelper.shared.getString(from :"additional_document_reference_template",with:"xml")
        self.signature_template = FileMangerHelper.shared.getString(from :"signature_template",with:"xml")
        self.accounting_supplier_party_template = FileMangerHelper.shared.getString(from :"accounting_supplier_party_template",with:"xml")
        self.payment_means_template = FileMangerHelper.shared.getString(from :"payment_means_template",with:"xml")
        self.ubl_extensions_template = FileMangerHelper.shared.getString(from :"ubl_extensions_template",with:"xml")
        self.ubl_extension_temp_odoo = FileMangerHelper.shared.getString(from :"ubl_extension_temp_odoo",with:"xml")

    }
    
    
    
    
}
