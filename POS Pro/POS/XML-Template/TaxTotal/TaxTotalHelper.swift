class TaxTotalHelper {
    static let TaxTotalTemplate:String = CashXMLFiles.shared.xml_tax_total_template ?? ""
    
    
    static func getTemplate(_ model:TaxTotalModel?) -> String{
        guard let model = model else { return "" }

        var template = TaxTotalHelper.TaxTotalTemplate
        if template.isEmpty {
            return ""
        }
        template = template.replacingOccurrences(of: "#Tax_Amount#", with: "\(model.Tax_Amount)")
        template = template.replacingOccurrences(of: "#TaxSubtotal_Taxable_Amount#", with: "\(model.TaxSubtotal_Taxable_Amount)" )
        template = template.replacingOccurrences(of: "#TaxSubtotal_Tax_Amount#", with: "\(model.TaxSubtotal_Tax_Amount)" )

//        template = template.replacingOccurrences(of: "#Tax_Amount#", with: "0.00")
//        template = template.replacingOccurrences(of: "#TaxSubtotal_Taxable_Amount#", with: "0.00" )
//        template = template.replacingOccurrences(of: "#TaxSubtotal_Tax_Amount#", with: "0.00" )

        template = template.replacingOccurrences(of: "#Percent#", with: model.Percent)
        template = template.replacingOccurrences(of: "#TaxCategory_ID#", with: model.TaxCategory_ID)
        template = template.replacingOccurrences(of: "#TaxCategory_Percent#", with: model.TaxCategory_Percent)
        template = template.replacingOccurrences(of: "#VAT#", with: model.VAT)
        template = template.replacingOccurrences(of: "#TaxTotal_Value#", with: "\(model.TaxTotal_Value)")
        
        return template
        
    }
    
}
