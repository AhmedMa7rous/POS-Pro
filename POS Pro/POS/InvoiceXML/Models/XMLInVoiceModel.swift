//
//  XMLInVoiceModel.swift
//  pos
//
//  Created by M-Wageh on 01/04/2024.
//  Copyright © 2024 khaled. All rights reserved.
//

import Foundation
class XMLInVoiceModel{
    var Actual_Delivery_Date:String = ""
    var cbc:[CBC_TEMPLATE:String]?
    var accountingCustomerPartyModel:AccountingCustomerPartyModel?
    var taxTotalModel:TaxTotalModel?
    var accountingSupplierPartyModel:AccountingSupplierPartyModel?
    var legalMonetaryTotalModel:LegalMonetaryTotalModel?
    var order:pos_order_class
    var ublExtensionsModel:UBLExtensionsModel?
    var writeTime = ""
    var writedateStr = ""
    var referencOrderName = ""
    init(order:pos_order_class) {
        let countryCode = "SAR"
        self.order = order
        let writeDate = (order.write_date ?? "")
        

        Actual_Delivery_Date = writeDate
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let date = formatter.date(from: writeDate) {
            formatter.dateFormat = "HH:mm:ss'Z'"
            writeTime = formatter.string(from: date)
            SharedManager.shared.printLog(writeTime) //add timeStr to your timeLabel here...

            formatter.dateFormat = "yyyy-MM-dd"
            writedateStr = formatter.string(from: date)
            Actual_Delivery_Date = writedateStr
            SharedManager.shared.printLog(writedateStr) //add dateStr to your dateLabel here...
        }
        
        let company = SharedManager.shared.posConfig().company
        let customer = order.customer
        let isReturnOrder = order.is_return()
        let InvoiceTypeCode = isReturnOrder ? "381" : "388"
        let BuyerReference = "\(order.write_user_id ?? 1)"
        //MARK: - CBC
        cbc = CBC_TEMPLATE.getDictionaryCBC(ID: order.name ?? "", UUID: order.l10n_sa_uuid ?? "",
                                            IssueDate: writedateStr,
                                            IssueTime: writeTime,
                                            InvoiceTypeCode: InvoiceTypeCode,
                                            DocumentCurrencyCode: countryCode,
                                            TaxCurrencyCode: countryCode, BuyerReference: BuyerReference ?? "")
        if order.is_return(){
             referencOrderName = pos_order_class.get(order_id: order.parent_order_id)?.name ?? ""
        }
   //MARK: - AccountingSupplierParty
        self.accountingSupplierPartyModel = company?.getAccountingSupplierPartyModel()
        if let cust = customer{
            self.accountingCustomerPartyModel = cust.getAccountingSupplierPartyModel()
        }else{
            /**
             {
                             "name": "عميل نقدي",
                             "country_code": "SA",
                             "country_name": "Saudi Arabia",
                         }
             */
            let postalAddress = PostalAddress_ENUM.getDefaultDictionary()
            let partyTaxScheme:[PartyTaxScheme_ENUM:String] = [:]//PartyTaxScheme_ENUM.getDictionary(customer: self)
            let partyLegalEntity = PartyLegalEntity_ENUM.getDefaultDictionary()
            let contact_temp = Contact_ENUM.getDefaultDictionary()
            self.accountingCustomerPartyModel = AccountingCustomerPartyModel(CUSTOMER_ID: 1, CUSTOMER_NAME:  "عميل نقدي", postalAddressCus: postalAddress, partyTaxSchemeCus:partyTaxScheme, partyLegalEntityCus: partyLegalEntity, contactCus: contact_temp)

        }
        self.legalMonetaryTotalModel = LegalMonetaryTotalModel(order: order)
        self.taxTotalModel = TaxTotalModel(order)
        self.ublExtensionsModel = nil
    }
    /*
    func setUBLExtensionsModel(xml_content:String, signature:String,invoice_hash:String){
        self.ublExtensionsModel = UBLExtensionsModel(xml_content:xml_content , signature: signature, invoice_hash: invoice_hash)

    }
     */
    func getAllInvoiceLine()->String{
        var allString:[String] = []

        for line in order.pos_order_lines{
            let invoiceLineModel: InvoiceLineModel = InvoiceLineModel(from: line)
            allString.append(InvoiceLineHelper.getTemplate(invoiceLineModel))
            if line.is_combo_line ?? false{
                let addOnLines = line.selected_products_in_combo
                for addOn in addOnLines {
                    if (addOn.price_subtotal_incl ?? 0) > 0 {
                        let invoiceLineModel: InvoiceLineModel = InvoiceLineModel(from: addOn)
                        allString.append(InvoiceLineHelper.getTemplate(invoiceLineModel))
                    }
                }
            }
        }
        
        return allString.joined(separator: "\n   ")
    }
    func getAllAllowanceChargeLine()->String{
       
        var allString:[String] = []

       
        if let discountLine = order.get_discount_line(){
            let AllowanceDiscountTemplate = """
    <cac:AllowanceCharge>
        <cbc:ChargeIndicator>false</cbc:ChargeIndicator>
        <cbc:AllowanceChargeReasonCode>95</cbc:AllowanceChargeReasonCode>
        <cbc:AllowanceChargeReason>Discount</cbc:AllowanceChargeReason>
        <cbc:Amount currencyID="SAR">\(discountLine.price_subtotal_incl)</cbc:Amount>
    </cac:AllowanceCharge>
    """
           
            allString.append(AllowanceDiscountTemplate)
        }
        return allString.joined(separator: "\n   ")
    }
    func getAllPaymentMean()->String{
        var allString:[String] = []

        for orderStatement in order.get_bankStatement(){
            var paymentMeansModel = PaymentMeansModel(order: order,type: orderStatement.mean_code ?? .cash)
            allString.append(PaymentMeansHelper.getTemplate(paymentMeansModel))
        }
        return allString.joined(separator: "\n   ")
    }
    func getBillReferenceTemp() -> String {
        if order.is_return(), !referencOrderName.isEmpty{
            let referenceTemp = """
<cac:BillingReference>
    <cac:InvoiceDocumentReference>
    <cbc:ID>\(referencOrderName)</cbc:ID>
    </cac:InvoiceDocumentReference>
</cac:BillingReference>
"""
            return referenceTemp

        }
        
        return ""
    }
  
}
extension res_company_class{
    func getAccountingSupplierPartyModel()->AccountingSupplierPartyModel{
        let postalAddress = PostalAddress_ENUM.getDictionary(company: self)
        let partyTaxScheme = PartyTaxScheme_ENUM.getDictionary(company: self)
        let partyLegalEntity = PartyLegalEntity_ENUM.getDictionary(company: self)
        let contact_temp = Contact_ENUM.getDictionary(company: self)

        return AccountingSupplierPartyModel(CRN: self.l10n_sa_additional_identification_scheme ?? "",
                                            CRN_ID: self.l10n_sa_additional_identification_number ?? "",
                                            COMPANY_NAME: self.name,
                                            postalAddress:postalAddress , partyTaxScheme:partyTaxScheme ,
                                            partyLegalEntity: partyLegalEntity, contact_temp: contact_temp)
        
    }
}
extension res_partner_class{
    func getAccountingSupplierPartyModel()->AccountingCustomerPartyModel{
        let postalAddress = PostalAddress_ENUM.getDictionary(customer: self)
        let partyTaxScheme:[PartyTaxScheme_ENUM:String] = [:]//PartyTaxScheme_ENUM.getDictionary(customer: self)
        let partyLegalEntity = PartyLegalEntity_ENUM.getDictionary(customer: self)
        let contact_temp = Contact_ENUM.getDictionary(customer: self)

        return AccountingCustomerPartyModel(CUSTOMER_ID: self.id, CUSTOMER_NAME: self.name, postalAddressCus: postalAddress, partyTaxSchemeCus: partyTaxScheme, partyLegalEntityCus: partyLegalEntity, contactCus: contact_temp)
        
    }
}
