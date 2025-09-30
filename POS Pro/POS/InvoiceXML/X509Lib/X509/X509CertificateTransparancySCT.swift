//
//  File.swift
//  
//
//  Created by Markus on 07.12.19.
//

import Foundation
import ASN1


extension X509 {
    
    class X509ExtCertificateTransparencySCT {

        enum HashAlgorithm : UInt8 {
            case none   = 0x00
            case md5    = 0x01
            case sha1   = 0x02
            case sha224 = 0x03
            case sha256 = 0x04
            case sha384 = 0x05
            case sha512 = 0x06
        }

        enum SignatureAlgorithm : UInt8 {
            case anonymous  = 0x00
            case rsa        = 0x01
            case dsa        = 0x02
            case ecdsa      = 0x03
        }
        
        
        var version:UInt8
        var id:Data
        var timestamp:UInt64
        var extensions:Data
        
        var hashAlgorithm:HashAlgorithm
        var signatureAlgorithm:SignatureAlgorithm
        
        var encodedSignatureValue:Data = Data()
        var derSignature:Data
        var signatureSequence = ASN1Sequence()
        
        init(encodedSCT: Data) {
            version = encodedSCT.first ?? 0
            id = Data(encodedSCT[1...32])
            timestamp = UInt64(bigEndian:encodedSCT[33...40].to(type: UInt64.self) ?? 0)  // miliseconds since epoch
            extensions = Data(encodedSCT[41...42])  // 2 bytes length field.
            
            hashAlgorithm = HashAlgorithm(rawValue: encodedSCT[43])!
            signatureAlgorithm = SignatureAlgorithm(rawValue: encodedSCT[44])!
            let signatureLength = UInt16(bigEndian:encodedSCT[45...46].to(type: UInt16.self) ?? 0)
            derSignature = Data(encodedSCT[47...encodedSCT.count-1])
            do {
                self.signatureSequence = try ASN1.build(derSignature) as! ASN1Sequence
                      
                }
                  catch  {
                      
                }
        }

    }
    
    
}
