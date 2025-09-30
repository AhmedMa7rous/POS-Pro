//
//  File.swift
//  
//
//  Created by Markus on 01.12.19.
//

import Foundation
import ASN1
import BigInt


extension X509 {
    
    struct Certificate: Equatable {
        var text = "Hello, World!"
        private static let beginPemBlock = "-----BEGIN CERTIFICATE-----"
        private static let endPemBlock   = "-----END CERTIFICATE-----"

        var asn1Sequence:ASN1Sequence = ASN1Sequence()
        let signatureAlgorithmId:AlgorithmId
        
        enum sequencePosition : Int {
            case version = 0
            case serialNumber = 1
            case signatureAlg = 2
            case issuer = 3
            case dateValidity = 4
            case subject = 5
            case publicKey = 6
            case extensions = 7
        }
        
        init(pemRepresentation  pemString:String) throws {
            
            // find begin string
            if pemString.contains(Certificate.beginPemBlock) {
            // valid PEM certificate
            // remove newline, begin and end markers
            let strippedPemCert = String(pemString.filter { !$0.isNewline})
            let pemComponents = strippedPemCert.components(separatedBy: "-----")
            guard pemComponents.count == 5 else {
                    throw X509Error.invalidPEMString
                }
            guard let der = Data(base64Encoded: pemComponents[2]) else {
                    throw X509Error.invalidPEMString
                }
                asn1Sequence = try ASN1.build(der) as! ASN1Sequence
                self.signatureAlgorithmId = AlgorithmId(asn1Sequence: asn1Sequence.get(1) as! ASN1Sequence)
                
            } else {
                if let der = Data(base64Encoded: pemString){
                    asn1Sequence = try ASN1.build(der) as! ASN1Sequence
                    self.signatureAlgorithmId = AlgorithmId(asn1Sequence: asn1Sequence.get(1) as! ASN1Sequence)
                } else
                {
                    self.signatureAlgorithmId = AlgorithmId(asn1Sequence: ASN1Sequence())

                        throw X509Error.invalidPEMString
                   
                }
                   
                    
            }
            
        }
        
        
        init(newCertificate:Certificate) throws {
            self.text = newCertificate.text
            self.asn1Sequence =  try ASN1.build(newCertificate.asn1Sequence.encode()) as! ASN1Sequence
            self.signatureAlgorithmId = AlgorithmId(asn1Sequence: self.asn1Sequence.get(1) as! ASN1Sequence)
        }
        
     
        
        var encodedTBSCertificate:Data? {
            return Data(asn1Sequence.get(0).encode())
        }
        
        private var tbsCertificate:ASN1Sequence? {
            return asn1Sequence.get(0) as? ASN1Sequence
        }

         var encodedPreTbsCertificate:Data? {
             
             // create a copy of the tbsCertificate
             let preTbsCertificate:ASN1Sequence = try! ASN1.build(self.tbsCertificate!.encode())as! ASN1Sequence
             // get the extenstion sequence
             let extensionSequence = (((preTbsCertificate.get(sequencePosition.extensions.rawValue) as! ASN1Ctx).value?[0]) as! ASN1Sequence)
             // finde the SCT extension sequence
             let extensionIndex = extensionSequence.getValue().firstIndex(where: {(($0 as! ASN1Sequence).get(0) as! ASN1ObjectIdentifier).oid == "1.3.6.1.4.1.11129.2.4.2"})
             // remove it.
             extensionSequence.remove(extensionIndex!)
             
             return Data(preTbsCertificate.encode())
         }
        
        
        // MARK: Basic Fields
        
        /// Gets the version (version number) value from the certificate.
        var version: Int? {
            if let v = (((self.tbsCertificate?.get(sequencePosition.version.rawValue)) as! ASN1Ctx).value?[0] as! ASN1Integer).value.asInt() {
                  return v + 1
             }
               return nil
        }
        
        /// Gets the serialNumber value from the certificate.
           var serialNumber: BInt? {
            return ((self.tbsCertificate?.get(sequencePosition.serialNumber.rawValue)) as! ASN1Integer).value
           }
        
        var publicKey:X509.PublicKey? {
            return X509.PublicKey(asn1Sequence: ((self.tbsCertificate?.get(sequencePosition.publicKey.rawValue)) as! ASN1Sequence))
        }
        
        
        var signatureAlgorithmOid:String {
            return self.signatureAlgorithmId.oid
        }
        
        var signatureAlgorithmName:String? {
            return self.signatureAlgorithmId.name
        }
        
        var signatureAlgorithmParameters:Data {
            return self.signatureAlgorithmId.parameters
        }
        
        var signatureValue:Data {
            return Data((asn1Sequence.get(2) as! ASN1BitString).bits)
        }
        
        
        var issuer:String {
            let seq = (self.tbsCertificate?.get(sequencePosition.issuer.rawValue) as! ASN1Sequence)
            return String()
        }
        
        
        
        
        
        
        
        
        // MARK: Extension Attributes
        
        /// Gets the extension information of the given OID code.
        func extensionObject(oid: String) -> X509.Extension? {
        
            if let extensionObject =  self.extensions?.getValue().first(where: {(($0 as! ASN1Sequence).get(0) as! ASN1ObjectIdentifier).oid == oid}) {
                return X509.Extension.init(asn1Sequence: extensionObject as! ASN1Sequence)
            } else {
                return nil
            }
        }
        
        private var extensions:ASN1Sequence? {
            return (((self.tbsCertificate?.get(sequencePosition.extensions.rawValue) as! ASN1Ctx).value?[0]) as! ASN1Sequence)
        }
        
        
        var certificateTransparencySCTs:[X509ExtCertificateTransparencySCT] {
            var result:[X509ExtCertificateTransparencySCT] = []
        
            guard let certficateTransparencySequence = extensionObject(oid: "1.3.6.1.4.1.11129.2.4.2") else {
                return result
            }
            
            let tlsEncodedSCTs =   Data((certficateTransparencySequence.asn1Value as! ASN1OctetString).value) // 2 bytes number of octets + n * SCT  see https://letsencrypt.org/2018/04/04/sct-encoding.html
            
            
            var SCTListSize = tlsEncodedSCTs.count - Int(2) //without the length field (2 bytes)
            var SCTLength = UInt16(0)
            var SCTOffset = UInt16(2)
            
            
            while SCTListSize > 0 {
                
                // read length of first SCT
                SCTLength = UInt16(bigEndian: tlsEncodedSCTs[SCTOffset...SCTOffset+2].to(type: UInt16.self) ?? 0) // find the length of the current SCT.
                
                let SCTData = Data(tlsEncodedSCTs[SCTOffset+2...SCTOffset+2+SCTLength-1])  // copy the bytes for the SCT
                
                let SCT = X509ExtCertificateTransparencySCT(encodedSCT: SCTData)
                
                result.append(SCT)
                
                SCTOffset = SCTOffset+2+SCTLength  // move the pointer to the next SCT.
                
                SCTListSize = SCTListSize - Int(SCTLength) - Int(2)  // reduce the remaining list size.
                
            }
            
            return result
        }
        
        
    }
    
}
