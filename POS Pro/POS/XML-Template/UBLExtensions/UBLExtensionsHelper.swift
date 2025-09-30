//
//  UBLExtensionsHelper.swift
//  pos
//
//  Created by M-Wageh on 08/04/2024.
//  Copyright © 2024 khaled. All rights reserved.
//

import Foundation
class UBLExtensionsHelper {
    static let ublExtensionsTemplate:String = CashXMLFiles.shared.ubl_extensions_template ?? ""
    static let ublExtensionsTempOdoo:String = CashXMLFiles.shared.ubl_extension_temp_odoo ?? ""

    static func getTempOdoo() -> String{
        return ""
        /*
        var tempOdoo = UBLExtensionsHelper.ublExtensionsTempOdoo
        return tempOdoo
         */
    }
    static func getTemplate(_ model:UBLExtensionsModel?) -> String{
        guard let model = model else {return ""}
        var template = """
<ext:UBLExtensions>
    <ext:UBLExtension>
        <ext:ExtensionURI>urn:oasis:names:specification:ubl:dsig:enveloped:xades</ext:ExtensionURI>
        <ext:ExtensionContent>
            <sig:UBLDocumentSignatures xmlns:sbc="urn:oasis:names:specification:ubl:schema:xsd:SignatureBasicComponents-2" xmlns:sig="urn:oasis:names:specification:ubl:schema:xsd:CommonSignatureComponents-2" xmlns:sac="urn:oasis:names:specification:ubl:schema:xsd:SignatureAggregateComponents-2">
                <sac:SignatureInformation>
                    <cbc:ID>urn:oasis:names:specification:ubl:signature:1</cbc:ID>
                    <sbc:ReferencedSignatureID>urn:oasis:names:specification:ubl:signature:Invoice</sbc:ReferencedSignatureID>
                    <ds:Signature xmlns:ds="http://www.w3.org/2000/09/xmldsig#" Id="signature">
                        <ds:SignedInfo>
                            <ds:CanonicalizationMethod Algorithm="http://www.w3.org/2006/12/xml-c14n11"/>
                            <ds:SignatureMethod Algorithm="http://www.w3.org/2001/04/xmldsig-more#ecdsa-sha256"/>
                            <ds:Reference Id="invoiceSignedData" URI="">
                                <ds:Transforms>
                                    <ds:Transform Algorithm="http://www.w3.org/TR/1999/REC-xpath-19991116">
                                        <ds:XPath>not(//ancestor-or-self::ext:UBLExtensions)</ds:XPath>
                                    </ds:Transform>
                                    <ds:Transform Algorithm="http://www.w3.org/TR/1999/REC-xpath-19991116">
                                        <ds:XPath>not(//ancestor-or-self::cac:Signature)</ds:XPath>
                                    </ds:Transform>
                                    <ds:Transform Algorithm="http://www.w3.org/TR/1999/REC-xpath-19991116">
                                        <ds:XPath>not(//ancestor-or-self::cac:AdditionalDocumentReference[cbc:ID='QR'])</ds:XPath>
                                    </ds:Transform>
                                    <ds:Transform Algorithm="http://www.w3.org/2006/12/xml-c14n11"/>
                                </ds:Transforms>
                                <ds:DigestMethod Algorithm="http://www.w3.org/2001/04/xmlenc#sha256"/>
                                <ds:DigestValue>#invoice_hash#</ds:DigestValue>
                            </ds:Reference>
                            <ds:Reference Type="http://www.w3.org/2000/09/xmldsig#SignatureProperties" URI="#xadesSignedProperties">
                                <ds:DigestMethod Algorithm="http://www.w3.org/2001/04/xmlenc#sha256"/>
                                <ds:DigestValue>#signed_properties_hash#</ds:DigestValue>
                            </ds:Reference>
                        </ds:SignedInfo>
                        <ds:SignatureValue>#SignatureValue#</ds:SignatureValue>
                        <ds:KeyInfo>
                            <ds:X509Data>
                                <ds:X509Certificate>#X509Certificate#</ds:X509Certificate>
                            </ds:X509Data>
                        </ds:KeyInfo>
                        <ds:Object>
                            <xades:QualifyingProperties Target="signature" xmlns:xades="http://uri.etsi.org/01903/v1.3.2#">
                                <xades:SignedProperties Id="xadesSignedProperties">
                                    <xades:SignedSignatureProperties>
                                        <xades:SigningTime>#SigningTime#</xades:SigningTime>
                                        <xades:SigningCertificate>
                                            <xades:Cert>
                                                <xades:CertDigest>
                                                    <ds:DigestMethod
                                                    Algorithm="http://www.w3.org/2001/04/xmlenc#sha256"/>
                                                    <ds:DigestValue>#public_key_hashing#</ds:DigestValue>
                                                </xades:CertDigest>
                                                <xades:IssuerSerial>
                                                    <ds:X509IssuerName>#X509IssuerName#</ds:X509IssuerName>
                                                    <ds:X509SerialNumber>#X509SerialNumber#</ds:X509SerialNumber>
                                                </xades:IssuerSerial>
                                            </xades:Cert>
                                        </xades:SigningCertificate>
                                    </xades:SignedSignatureProperties>
                                </xades:SignedProperties>
                            </xades:QualifyingProperties>
                        </ds:Object>
                    </ds:Signature>
                </sac:SignatureInformation>
            </sig:UBLDocumentSignatures>
        </ext:ExtensionContent>
    </ext:UBLExtension>
</ext:UBLExtensions>
"""//UBLExtensionsHelper.ublExtensionsTemplate
        template = template.replacingOccurrences(of: "#invoice_hash#", with: model.invoice_hash)
        template = template.replacingOccurrences(of: "#signed_properties_hash#", with: model.signed_properties_hash)
        template = template.replacingOccurrences(of: "#SignatureValue#", with: model.signature)
        template = template.replacingOccurrences(of: "#X509Certificate#", with: model.b64_decoded_cert)
        template = template.replacingOccurrences(of: "#SigningTime#", with: model.signing_time)
        template = template.replacingOccurrences(of: "#public_key_hashing#", with: model.public_key_hashing)
        template = template.replacingOccurrences(of: "#X509IssuerName#", with: model.issuer_name)
        template = template.replacingOccurrences(of: "#X509SerialNumber#", with: model.serial_number)
        return template
        
    }
    
}

