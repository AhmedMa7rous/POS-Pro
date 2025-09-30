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

struct PublicKey: Equatable {
    
    private static let beginPemBlock = "-----BEGIN KEY-----"
    private static let endPemBlock   = "-----END KEY-----"
    
    let asn1Sequence:ASN1Sequence
    let keyBitstring:ASN1BitString
    let algorithmId:AlgorithmId
    
    init(asn1Sequence:ASN1Sequence) {
        self.asn1Sequence = asn1Sequence
        self.keyBitstring = self.asn1Sequence.get(1) as! ASN1BitString
        self.algorithmId = AlgorithmId(asn1Sequence: self.asn1Sequence.get(0) as! ASN1Sequence)
    }
    
    init(derRepresentation: Data) throws {
        asn1Sequence = try ASN1.build(derRepresentation) as! ASN1Sequence
        self.keyBitstring = self.asn1Sequence.get(1) as! ASN1BitString
        self.algorithmId = AlgorithmId(asn1Sequence: self.asn1Sequence.get(0) as! ASN1Sequence)
    }
    
    init(pemRepresentation  pemString:String) throws {
        
        // find begin string
        if pemString.contains(PublicKey.beginPemBlock) {
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
            self.keyBitstring = self.asn1Sequence.get(1) as! ASN1BitString
            self.algorithmId = AlgorithmId(asn1Sequence: self.asn1Sequence.get(0) as! ASN1Sequence)
            
        } else {
            if let der = Data(base64Encoded: pemString){
                asn1Sequence = try ASN1.build(der) as! ASN1Sequence
                self.keyBitstring = self.asn1Sequence.get(1) as! ASN1BitString
                self.algorithmId = AlgorithmId(asn1Sequence: self.asn1Sequence.get(0) as! ASN1Sequence)
            } else {
                self.asn1Sequence = ASN1Sequence()
                self.algorithmId = AlgorithmId(asn1Sequence: ASN1Sequence())
                 let keyBitstring = try? ASN1BitString([], 0)
                       
                    throw X509Error.invalidPEMString
                }
               
           
        }
        
    }
    
    var algorithmOid:String {
        return self.algorithmId.oid
    }
    
    var algorithmName:String? {
        return self.algorithmId.name
    }
    
    var algorithmParameters:Data {
        return self.algorithmId.parameters
    }
    
    var derEncodedKey:Data? {
       return Data((asn1Sequence.get(1) as! ASN1BitString).bits)
    }
    
//    var keyValue0:BInt? {
//       return (keyBitstring.get(0) as! ASN1Integer).value
//    }
//    var keyValue1:BInt? {
//       return (keyBitstring.get(1) as! ASN1Integer).value
//    }



    /**
     * This method transforms a DER encoded key to PEM format. It gets a Base64 representation of
     * the key and then splits this base64 string in 64 character chunks. Then it wraps it in
     * BEGIN and END key tags.
     */
    func PEMKeyFromDERKey(_ data: Data) -> String {
        // base64 encode the result
        let base64EncodedString = data.base64EncodedString(options: [])

        // split in lines of 64 characters.
        var currentLine = ""
        var resultString = PublicKey.beginPemBlock
        var charCount = 0
        for character in base64EncodedString {
            charCount += 1
            currentLine.append(character)
            if charCount == 64 {
                resultString += currentLine + "\n"
                charCount = 0
                currentLine = ""
            }
        }
        // final line (if any)
        if currentLine.count > 0 { resultString += currentLine + "\n" }
        // final tag
        resultString += PublicKey.endPemBlock
        return resultString
    }



    }
}
