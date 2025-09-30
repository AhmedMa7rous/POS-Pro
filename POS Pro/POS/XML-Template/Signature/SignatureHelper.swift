class SignatureHelper {
    static let signatureTemplate:String =  CashXMLFiles.shared.signature_template ?? ""
    

    static func getTemplate() -> String{
    let template = """
<cac:Signature>
    <cbc:ID>urn:oasis:names:specification:ubl:signature:Invoice</cbc:ID>
    <cbc:SignatureMethod>urn:oasis:names:specification:ubl:dsig:enveloped:xades</cbc:SignatureMethod>
</cac:Signature>
""" //SignatureHelper.signatureTemplate

return template

}

}
