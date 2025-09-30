//
//  InvoiceTlv.swift
//  pos
//
//  Created by M-Wageh on 29/11/2021.
//  Copyright © 2021 khaled. All rights reserved.
//

import Foundation

class InvoiceTlvModel : BaseTlvGenerate {
    var sellerName: String = ""
    var vatNumber: String = ""
    var timeStamp: String = ""
    var totalWithVat: String = "0.00"
    var totalVat: String = "0.00"
    var xmlInvoice: String = ""
    var signature: String = ""
    var x509PublicKey: Data?
    var x509Signature:Data?

    override func encodeTlvPackage() {
        self.tlv.pushString(value: self.sellerName, tag: 1)
        self.tlv.pushString(value: self.vatNumber, tag: 2)
        self.tlv.pushString(value: self.timeStamp, tag: 3)
        self.tlv.pushString(value: self.totalWithVat, tag: 4)
        self.tlv.pushString(value: self.totalVat, tag: 5)
        if !xmlInvoice.isEmpty {
            self.tlv.pushString(value: self.xmlInvoice, tag: 6)
        }
        if !signature.isEmpty {
            self.tlv.pushString(value: self.signature, tag: 7)
        }
        if let x509PublicKey = x509PublicKey {
            self.tlv.pushData(byteData:x509PublicKey , tag: 8)
        }
        if let x509Signature = x509Signature {
            self.tlv.pushData(byteData:x509Signature, tag: 9)
        }

    }
}
