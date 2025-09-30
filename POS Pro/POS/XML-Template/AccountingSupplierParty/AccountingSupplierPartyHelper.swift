class AccountingSupplierPartyHelper {
    static let AccountingSupplierPartyTemplate:String = CashXMLFiles.shared.accounting_supplier_party_template ?? ""
    
    
    static func getTemplate(_ model:AccountingSupplierPartyModel? ) -> String{
        guard let model = model else {
            return ""
        }
        var template = AccountingSupplierPartyHelper.AccountingSupplierPartyTemplate
        let postalAddress_temp = PostalAddress_ENUM.getTemplate(from:model.postalAddress)
        let partyTaxScheme_temp = PartyTaxScheme_ENUM.getTemplate(from:model.partyTaxScheme)
        let partyLegalEntity_temp = PartyLegalEntity_ENUM.getTemplate(from:model.partyLegalEntity)
        let contact_temp = Contact_ENUM.getTemplate(from:model.contact_temp)
        
        
        template = template.replacingOccurrences(of: "#CRN#", with: model.CRN)
        template = template.replacingOccurrences(of: "#CRN_ID#", with: model.CRN_ID)

        template = template.replacingOccurrences(of: "#COMPANY_NAME#", with: model.COMPANY_NAME)
        template = template.replacingOccurrences(of: "#PostalAddress_TEMPLATE#", with: postalAddress_temp)
        template = template.replacingOccurrences(of: "#PartyTaxScheme_TEMPLATE#", with: partyTaxScheme_temp)
        template = template.replacingOccurrences(of: "#PartyLegalEntity_TEMPLATE#", with: partyLegalEntity_temp)
        template = template.replacingOccurrences(of: "#Contact_TEMPLATE#", with: contact_temp)
        return template
        
    }
    
}
