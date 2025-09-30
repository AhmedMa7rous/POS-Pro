class PaymentMeansHelper {
    static let PaymentMeansTemplate:String = CashXMLFiles.shared.payment_means_template ?? ""
    
    
    static func getTemplate(_ model:PaymentMeansModel?) -> String{
        guard let model = model else {return ""}
        var template = PaymentMeansHelper.PaymentMeansTemplate
       
        //Payment_Means_Code
        template = template.replacingOccurrences(of: "#Payment_Means_Code#", with: model.Payment_Means_Code)

        template = template.replacingOccurrences(of: "#Payment_Due_Date#", with: model.Payment_Due_Date)
        template = template.replacingOccurrences(of: "#Instruction_ID#", with: model.Instruction_ID)
        if let returnResonNote = model.returnReson{
            let returnTemp = """
       <cbc:InstructionNote> -, \(returnResonNote)</cbc:InstructionNote>
    """
            template = template.replacingOccurrences(of: "#RETURN_RESON_NOTE#", with: returnTemp)

        }else{
            template = template.replacingOccurrences(of: "#RETURN_RESON_NOTE#", with: "")

        }
        template = template.replacingOccurrences(of: "#Payment_ID#", with: model.Payment_ID)
        return template
        
    }
    
}

