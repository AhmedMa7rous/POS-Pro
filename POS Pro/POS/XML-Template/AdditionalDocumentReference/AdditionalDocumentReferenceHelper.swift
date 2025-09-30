class AdditionalDocumentReferenceHelper {
    static let additionalDocumentReferenceTemplate:String = CashXMLFiles.shared.additional_document_reference_template ?? ""
    
    
    static func getTemplate(PIH:String = "",ICV:Int,QrCode:String = "") -> String{
        var template = AdditionalDocumentReferenceHelper.additionalDocumentReferenceTemplate
        template = template.replacingOccurrences(of: "#ICV#", with: "\(ICV)")

        if !PIH.isEmpty{
            let xmlPIH = """
<cbc:EmbeddedDocumentBinaryObject mimeCode=\"text/plain\">\(PIH)</cbc:EmbeddedDocumentBinaryObject>
"""
            template = template.replacingOccurrences(of: "#PIH#", with: xmlPIH)
        }else{
            template = template.replacingOccurrences(of: "#PIH#", with: "")

        }
        if !QrCode.isEmpty{
            let xmlQr = """
<cac:AdditionalDocumentReference>
    <cbc:ID>QR</cbc:ID>
    <cac:Attachment>
        <cbc:EmbeddedDocumentBinaryObject mimeCode=\"text/plain\">\(QrCode)</cbc:EmbeddedDocumentBinaryObject>
    </cac:Attachment>
</cac:AdditionalDocumentReference>
"""
            template = template.replacingOccurrences(of: "#AdditionalDocumentReference_QR_CODE#", with: xmlQr)
        }else{
            let xmlQr = """
<cac:AdditionalDocumentReference>
    <cbc:ID>QR</cbc:ID>
    <cac:Attachment>
        <cbc:EmbeddedDocumentBinaryObject mimeCode="text/plain"/>
    </cac:Attachment>
</cac:AdditionalDocumentReference>
"""
            template = template.replacingOccurrences(of: "#AdditionalDocumentReference_QR_CODE#", with: "")

        }
        
        
        

        return template
        
    }
    
}
