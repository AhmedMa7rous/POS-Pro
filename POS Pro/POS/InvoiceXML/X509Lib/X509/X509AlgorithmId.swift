//
//  File.swift
//  
//
//  Created by Markus on 04.12.19.
//

import Foundation
import ASN1

extension X509 {
    struct AlgorithmId: Equatable {
        
        let asn1Sequence:ASN1Sequence
        
        
        init(asn1Sequence:ASN1Sequence) {
            self.asn1Sequence = asn1Sequence
        }
        
        
        var oid:String {
            return (asn1Sequence.get(0) as! ASN1ObjectIdentifier).oid
        }
        
        var name:String? {
            return oidNames[self.oid]
        }
        
        var parameters:Data {
            // Parameters are optional
            let asn1Params = asn1Sequence.get(1)
            
            if (asn1Params.tag != ASN1.TAG_Null) {
                
            }
            return Data()
        }
    }
}
