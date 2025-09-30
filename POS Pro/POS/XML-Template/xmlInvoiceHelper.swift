import CryptoKit
import libxml2
import Foundation
import CommonCrypto

class XMLInvoiceHelper {
    static let xmlInvoiceTemplate:String = CashXMLFiles.shared.xml_Invoice_template ?? ""
    
    
    static func getTemplate(model:XMLInVoiceModel,PIH:String) -> (template:String,teemplateWithEx:String,teemplateWithQR:String){
        var template_with_ubl_ext = ""
        var template_with_QR = ""
        var template = XMLInvoiceHelper.xmlInvoiceTemplate
        template = template.replacingOccurrences(of: "#CBC_TEMPLATE#", with:  CBCHelper.getTemplate(model.cbc))

        template = template.replacingOccurrences(of: "#Billing_Reference_TEMPLATE#", with:  model.getBillReferenceTemp())

        template = template.replacingOccurrences(of: "#Accounting_Supplier_Party_TEMPLATE#", with: AccountingSupplierPartyHelper.getTemplate(model.accountingSupplierPartyModel))
        
        template = template.replacingOccurrences(of: "#Accounting_Customer_Party_TEMPLATE#", with: AccountingCustomerPartyHelper.getTemplate( model.accountingCustomerPartyModel))
        
        
        template = template.replacingOccurrences(of: "#Actual_Delivery_Date#", with: model.Actual_Delivery_Date)
        
        template = template.replacingOccurrences(of: "#Payment_Means_TEMPLATE#", with: model.getAllPaymentMean())
        
        template = template.replacingOccurrences(of: "#Tax_Total_TEMPLATE#", with: TaxTotalHelper.getTemplate( model.taxTotalModel))
        template = template.replacingOccurrences(of: "#Legal_Monetary_Total_TEMPLATE#", with: LegalMonetaryTotalHelper.getTemplate(model.legalMonetaryTotalModel))
        template = template.replacingOccurrences(of: "#Invoice_Line_TEMPLATE#", with: model.getAllInvoiceLine() )
        template = template.replacingOccurrences(of: "#Allowance_Charge_TEMPLATE#", with: model.getAllAllowanceChargeLine() )

        template = removeEmptyLines(from:template)
        template_with_ubl_ext = template
        template = template.replacingOccurrences(of: "#UBLExtension_TEMPLATE#", with: UBLExtensionsHelper.getTempOdoo() )
        template_with_QR = template.replacingOccurrences(of: "#Additional_Document_Reference_TEMPLATE#", with: AdditionalDocumentReferenceHelper.getTemplate(PIH: PIH , ICV: model.order.l10n_sa_chain_index ?? 1, QrCode: "#QR_CODE_TLV#" ))

        template = template.replacingOccurrences(of: "#Additional_Document_Reference_TEMPLATE#", with: AdditionalDocumentReferenceHelper.getTemplate(PIH: PIH , ICV: model.order.l10n_sa_chain_index ?? 1, QrCode: "" ))
        template = template.replacingOccurrences(of: "#SIGNATURE_TEMPLATE#", with: "")
        template_with_QR = template_with_QR.replacingOccurrences(of: "#SIGNATURE_TEMPLATE#", with: SignatureHelper.getTemplate())
        template_with_ubl_ext = template_with_ubl_ext.replacingOccurrences(of: "#SIGNATURE_TEMPLATE#", with: SignatureHelper.getTemplate())
        return (template,template_with_ubl_ext,template_with_QR)
        
    }
    static func removeEmptyLines(from xml: String) -> String {
        let pattern = "\\n\\s*\\n"
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: xml.utf16.count)
        let formattedXML = regex.stringByReplacingMatches(in: xml, options: [], range: range, withTemplate: "\n")
        return formattedXML.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    static func getSHA256(for xml:String) -> String? {
        if #available(iOS 13.0, *) {
        if let xmlData = xml.data(using: .utf8) {
            let hash = SHA256.hash(data: xmlData)
            //Get string representation of the hash (matches hash.description)
            let hashedString = hash.map({ String(format: "%02hhx", $0) }).joined()
            //Get the base64 string
            let encodedString = hashedString.data(using: .utf8)!.base64EncodedString()
            SharedManager.shared.printLog("xml SHA256")
            SharedManager.shared.printLog(encodedString)
            SharedManager.shared.printLog("================================")

            return encodedString
        }
            
        } else {
            // Fallback on earlier versions
        }
        return nil
    }
    static func generateInvoiceXmlSha(xmlContent: String) -> (xmlSha:String?,canonicalizeXml:String) {
        func validateXMLString(_ xmlString: String) -> Bool {
            
            // Convert the XML string to Data
            guard let xmlData = xmlString.data(using: .utf8) else {
                SharedManager.shared.printLog("Failed to convert XML string to Data")
                return false
            }
            
            // Create an XMLParser instance with the XML data
            let parser = XMLParser(data: xmlData)
            
            // Assign a delegate to the parser (optional)
            parser.delegate = nil
            
            // Attempt to parse the XML
            let success = parser.parse()
            
            // If parsing fails, you can retrieve the error
            if !success {
                if let error = parser.parserError {
                    SharedManager.shared.printLog("XML Validation Error: \(error.localizedDescription)")
                }
                return false
            }
            
            // If parsing succeeds, the XML is valid
            return true
        }
        // Function to manually canonicalize XML content
        func canonicalizeXml(content: String) -> String? {
            // This is a basic approach; canonicalization typically involves sorting attributes, etc.
          //  return content //.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\t", with: "")
            // Convert the XML string to a C string
            if (content == "0"){
                return content
            }
            if !validateXMLString(content){
                SharedManager.shared.printLog("Failed to validateXMLString ")

                return nil
            }
            // Convert XML string to C string
               guard let xmlCString = content.cString(using: .utf8) else {
                   SharedManager.shared.printLog("Failed to convert XML string to C string")
                   return nil
               }
               
               // Parse XML document
               guard let xmlDoc = xmlReadMemory(xmlCString, Int32(strlen(xmlCString)), nil, nil, Int32(XML_PARSE_RECOVER.rawValue)) else {
                   SharedManager.shared.printLog("Failed to parse XML document")
                   return nil
               }
               defer { xmlFreeDoc(xmlDoc) }
               
               // Memory pointer for the canonicalized output
               var canonicalizedPtr: UnsafeMutablePointer<xmlChar>? = nil
            // Canonicalize the XML document directly into memory
            let canonicalizedSize = xmlC14NDocDumpMemory(xmlDoc, nil, Int32(XML_C14N_1_1.rawValue), nil, 0, &canonicalizedPtr)
                if canonicalizedSize < 0 {
                    SharedManager.shared.printLog("Canonicalization failed with error code: \(canonicalizedSize)")
                    return nil
                }
               
               
               if canonicalizedSize == 0 || canonicalizedPtr == nil {
                   SharedManager.shared.printLog("Canonicalized data is empty or pointer is nil.")
                   return nil
               }
               
               // Convert the canonicalized XML to a Swift String
               let canonicalizedData = Data(bytes: canonicalizedPtr!, count: Int(canonicalizedSize))
               xmlFree(canonicalizedPtr)  // Free the memory allocated by libxml2
               
               if let canonicalizedXML = String(data: canonicalizedData, encoding: .utf8) {
                   return canonicalizedXML
               } else {
                   SharedManager.shared.printLog("Failed to convert canonicalized data to string")
                   return nil
               }
        }
        

        // Function to manually transform and canonicalize XML content
        func transformAndCanonicalizeXml(content: String) -> String? {
            // Implement your XSL transformation logic or manually adjust the XML content here
            // For simplicity, assume the content is already transformed and just canonicalize it
            return  canonicalizeXml(content: content)
        }

        // Assume xmlContent is already in string form and represents the XML document
        guard let transformedXmlString = transformAndCanonicalizeXml(content: xmlContent) else {
            return (xmlSha:nil,canonicalizeXml:xmlContent)
        }
        //return transformedXmlString.mwsha256() //.toBase64()
        
        guard let transformedXmlData = transformedXmlString.data(using: .utf8) else {
            return (xmlSha:nil,canonicalizeXml:xmlContent)
        }
          
          
          var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        transformedXmlData.withUnsafeBytes {
              _ = CC_SHA256($0.baseAddress, CC_LONG(transformedXmlData.count), &hash)
          }
          
          let hashData = Data(hash).base64EncodedString() //hash.map { String(format: "%02x", $0) }.joined()//
        return (xmlSha:hashData,canonicalizeXml:transformedXmlString)
    }
    
}
