//
//  UBLExtensionsModel.swift
//  pos
//
//  Created by M-Wageh on 08/04/2024.
//  Copyright © 2024 khaled. All rights reserved.
//

import Foundation
import CommonCrypto

class UBLExtensionsModel{
    var issuer_name:String,serial_number:String,signing_time:String,
        public_key_hashing:String,prehash_content:String,signature:String,
        b64_decoded_cert:String,invoice_hash:String,signed_properties_hash:String
    
    init(xml_content:String, signature:String,invoice_hash:String,signing_time:String?){
        let issuerName = MWX509Certificate.shared.issuerName ?? ""
        let serialNumber = MWX509Certificate.shared.serialNumber ?? ""
        let signingTime = signing_time ?? MWX509Certificate.shared.getZatcaDateTime()
        let publicKey = (MWX509Certificate.shared.base64EncodeSHA256Hex() ?? "") //.toBase64()
        
        self.issuer_name = issuerName
        self.serial_number = serialNumber
        self.signing_time = signingTime
        self.public_key_hashing = publicKey
        self.prehash_content = xml_content // unSginXmlContent
        self.signature = signature
        self.b64_decoded_cert = MWX509Certificate.shared.certificate_str ?? ""
        self.invoice_hash = invoice_hash
        self.signed_properties_hash = ""
        if let hash = UBLExtensionsModel.calculateSignedPropertiesHash(issuerName: issuerName, serialNumber: serialNumber, signingTime: signingTime, publicKey: publicKey) {
            SharedManager.shared.printLog("SHA256 Hash (Base64 Encoded):\(hash)" )
            self.signed_properties_hash = hash
        } else {
            SharedManager.shared.printLog("Error calculating hash.")
        }
    }
    static func calculateSignedPropertiesHash(issuerName: String, serialNumber: String, signingTime: String, publicKey: String) -> String? {
        let test_6 = """
<xades:SignedProperties xmlns:xades="http://uri.etsi.org/01903/v1.3.2#" Id="xadesSignedProperties">
                                    <xades:SignedSignatureProperties>
                                        <xades:SigningTime>\(signingTime)</xades:SigningTime>
                                        <xades:SigningCertificate>
                                            <xades:Cert>
                                                <xades:CertDigest>
                                                    <ds:DigestMethod xmlns:ds="http://www.w3.org/2000/09/xmldsig#" Algorithm="http://www.w3.org/2001/04/xmlenc#sha256"/>
                                                    <ds:DigestValue xmlns:ds="http://www.w3.org/2000/09/xmldsig#">\(publicKey)</ds:DigestValue>
                                                </xades:CertDigest>
                                                <xades:IssuerSerial>
                                                    <ds:X509IssuerName xmlns:ds="http://www.w3.org/2000/09/xmldsig#">\(issuerName)</ds:X509IssuerName>
                                                    <ds:X509SerialNumber xmlns:ds="http://www.w3.org/2000/09/xmldsig#">\(serialNumber)</ds:X509SerialNumber>
                                                </xades:IssuerSerial>
                                            </xades:Cert>
                                        </xades:SigningCertificate>
                                    </xades:SignedSignatureProperties>
                                </xades:SignedProperties>
"""
        let canonicalizedData = test_6.data(using: .utf8)!
        // Calculate SHA-256 hash
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        canonicalizedData.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(canonicalizedData.count), &hash)
        }
        let hexString = hash.map { String(format: "%02x", $0) }.joined()
       
        return hexString.toBase64()
    }
    
    // Function to adjust indentation of XML string
    static func indentXML(_ xmlString: String, spaces: Int) -> String {
        var indentedString = ""
        let indentation = String(repeating: " ", count: spaces)
        
        let lines = xmlString.components(separatedBy: "\n")
        for (index, line) in lines.enumerated() {
            if index == 0 {
                indentedString += line
            } else {
                indentedString += "\(indentation)\(line)"
            }
            indentedString += "\n"
        }
        
        return indentedString
    }
}
