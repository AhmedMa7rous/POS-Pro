//
//  File.swift
//  
//
//  Created by Markus on 04.12.19.
//

import Foundation
import ASN1

extension X509 {
    struct Extension: Equatable {
        
        let asn1Sequence:ASN1Sequence
        let asn1Value:ASN1
        
        
        init(asn1Sequence:ASN1Sequence) {
            self.asn1Sequence = asn1Sequence
            self.asn1Value = try! ASN1.build((asn1Sequence.getValue().last as! ASN1OctetString).value)
        }
        
        
        var oid:String {
            return (asn1Sequence.get(0) as! ASN1ObjectIdentifier).oid
        }
        
        var name:String? {
            return oidNames[self.oid]
        }
        
         var isCritical: Bool {
               
               return false
           }
    }
}
