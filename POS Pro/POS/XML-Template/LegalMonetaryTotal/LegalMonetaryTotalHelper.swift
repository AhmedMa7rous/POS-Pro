class LegalMonetaryTotalHelper {
    static let LegalMonetaryTotalTemplate:String = CashXMLFiles.shared.xml_legal_monetary_total_template ?? ""
    
    
    static func getTemplate(_ model:LegalMonetaryTotalModel?) -> String{
        guard let model = model else { return "" }
        var template = LegalMonetaryTotalHelper.LegalMonetaryTotalTemplate
        
        
        template = template.replacingOccurrences(of: "#LineExtensionAmount#", with: "\(model.LineExtensionAmount)")
        template = template.replacingOccurrences(of: "#TaxExclusiveAmount#", with: "\(model.TaxExclusiveAmount)")
        template = template.replacingOccurrences(of: "#TaxInclusiveAmount#", with: "\(model.TaxInclusiveAmount)" )
        template = template.replacingOccurrences(of: "#AllowanceTotalAmount#", with: "\(model.AllowanceTotalAmount)")
        let chargeValue = (model.ChargeTotalAmount.toDouble() ?? 0) > 0 ? "\((model.ChargeTotalAmount.toDouble() ?? 0))" : ""
        if chargeValue.isEmpty{
            template = template.replacingOccurrences(of: "#ChargeTotalAmount#", with: "")
        }else{
            template = template.replacingOccurrences(of: "#ChargeTotalAmount#", with: "<cbc:ChargeTotalAmount currencyID=\"SAR\">\(chargeValue)</cbc:ChargeTotalAmount>")
        }
        template = template.replacingOccurrences(of: "#PrepaidAmount#", with: "\(model.PrepaidAmount)")
        template = template.replacingOccurrences(of: "#PayableAmount#", with: "\(model.PayableAmount)")
        return template
        
    }
    
}
