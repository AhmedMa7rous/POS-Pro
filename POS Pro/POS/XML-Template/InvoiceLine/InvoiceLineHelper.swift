class InvoiceLineHelper {
    static let InvoiceLineTemplate:String =  CashXMLFiles.shared.invoice_line_template ?? ""
    
    
    static func getTemplate(_ model:InvoiceLineModel?) -> String{
        guard let model = model else { return "" }
        var template = InvoiceLineHelper.InvoiceLineTemplate
        template = template.replacingOccurrences(of: "#ID#", with: "\(model.productID)")

        template = template.replacingOccurrences(of: "#InvoicedQuantity#", with: "\(model.InvoicedQuantity)")
        template = template.replacingOccurrences(of: "#LineExtensionAmount#", with: "\(model.LineExtensionAmount)")
        template = template.replacingOccurrences(of: "#TaxAmount#", with: "\(model.TaxAmount)")
        template = template.replacingOccurrences(of: "#RoundingAmount#", with: "\(model.RoundingAmount)")
        template = template.replacingOccurrences(of: "#TaxableAmount#", with: "\(model.TaxableAmount)")
        
        template = template.replacingOccurrences(of: "#TaxSubtotal_TaxAmount#", with: "\(model.TaxSubtotal_TaxAmount)")
        template = template.replacingOccurrences(of: "#TaxSubtotal_Percent#", with: "\(model.TaxSubtotal_Percent)")
        template = template.replacingOccurrences(of: "#TaxCategory_ID#", with: "\(model.TaxCategory_ID)")
        template = template.replacingOccurrences(of: "#TaxCategory_Percent#", with: "\(model.TaxCategory_Percent)")
        template = template.replacingOccurrences(of: "#TaxScheme_ID#", with: "\(model.TaxScheme_ID)")
        if model.Item_Description.isEmpty{
            template = template.replacingOccurrences(of: "#Item_Description#", with: "" )
        }else{
            template = template.replacingOccurrences(of: "#Item_Description#", with: "<cbc:Description>\(model.Item_Description)</cbc:Description>" )
        }
        template = template.replacingOccurrences(of: "#Item_NAME#", with: model.Item_NAME)
        template = template.replacingOccurrences(of: "#ClassifiedTaxCategory_ID#", with: "\(model.ClassifiedTaxCategory_ID)")
        template = template.replacingOccurrences(of: "#ClassifiedTaxCategory_Percent#", with: "\(model.ClassifiedTaxCategory_Percent)")
        template = template.replacingOccurrences(of: "#ClassifiedTaxCategory_TaxScheme_ID#", with: "\(model.ClassifiedTaxCategory_TaxScheme_ID)")
        template = template.replacingOccurrences(of: "#PriceAmount#", with: "\(model.PriceAmount)")

        return template
        
    }
    
}
