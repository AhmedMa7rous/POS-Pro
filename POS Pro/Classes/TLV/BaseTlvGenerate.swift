//
//  BaseTlvGenerate.swift
//  pos
//
//  Created by M-Wageh on 29/11/2021.
//  Copyright © 2021 khaled. All rights reserved.
//

import Foundation

class BaseTlvGenerate {
    var tlv: Tlv = Tlv()
    var moduleId: UInt32 = 0
    var messageCode: UInt16 = 0
    
    func encodeTlvPackage() {

    }
    
    func packageData() -> Data {
        self.encodeTlvPackage()
        return self.tlv.encode()
    }
}
