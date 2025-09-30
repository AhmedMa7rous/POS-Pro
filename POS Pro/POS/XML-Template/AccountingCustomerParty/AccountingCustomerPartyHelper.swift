class AccountingCustomerPartyHelper {
    static let AccountingCustomerPartyTemplate:String = CashXMLFiles.shared.accounting_customer_party_template ?? ""
    
    
    static func getTemplate(_ model:AccountingCustomerPartyModel?) -> String{
        guard let model = model else { return "" }
        var template = AccountingCustomerPartyHelper.AccountingCustomerPartyTemplate
        let postalAddress_temp = PostalAddress_ENUM.getTemplate(from:model.postalAddressCus)
        let partyTaxScheme_temp = PartyTaxScheme_ENUM.getTemplate(from:model.partyTaxSchemeCus)
        let partyLegalEntity_temp = PartyLegalEntity_ENUM.getTemplate(from:model.partyLegalEntityCus)
        let contact_temp = Contact_ENUM.getTemplate(from:model.contactCus)
        
        
        template = template.replacingOccurrences(of: "#CUSTOMER_ID#", with: "\(model.CUSTOMER_ID)")
        template = template.replacingOccurrences(of: "#CUSTOMER_NAME#", with: model.CUSTOMER_NAME)
        template = template.replacingOccurrences(of: "#PostalAddress_TEMPLATE#", with: postalAddress_temp)
        template = template.replacingOccurrences(of: "#PartyTaxScheme_TEMPLATE#", with: "")
        template = template.replacingOccurrences(of: "#PartyLegalEntity_TEMPLATE#", with: partyLegalEntity_temp)
        template = template.replacingOccurrences(of: "#Contact_TEMPLATE#", with: contact_temp)
        return template
        
    }
    
}
