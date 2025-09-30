//
//  File.swift
//  
//
//  Created by Markus on 07.12.19.
//

import Foundation
import ASN1

extension X509 {
    
   
    struct Signature: Equatable {
        
        let asn1Sequence:ASN1Sequence
        let algorithmId:AlgorithmId
        
        init(asn1Sequence:ASN1Sequence) {
            self.asn1Sequence = asn1Sequence
            self.algorithmId = AlgorithmId.init(asn1Sequence: asn1Sequence.get(0) as! ASN1Sequence)
        }
        
        init(pemRepresentation  pemString:String) throws {
            guard let der = Data(base64Encoded: pemString) else {
                    throw X509Error.invalidPEMString
                }
             let asn1Sequence = try ASN1.build(der) as! ASN1Sequence
            
            self.init(asn1Sequence: asn1Sequence)
            
        }
        
        var encodedSignature:Data? {
            return Data((asn1Sequence.get(1) as! ASN1BitString).bits)
        }
    }
    
}
