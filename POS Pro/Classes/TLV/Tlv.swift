//
//  Tlv.swift
//  pos
//
//  Created by M-Wageh on 29/11/2021.
//  Copyright © 2021 khaled. All rights reserved.
//

import Foundation


class Tlv {
    let tlvTagByte = 1
    let tlvLengthByte = 1
    let intByte = 4
    let longByte = 8
    
    var data: Data = Data()
    var tlvArray: Array = Array<TlvEntity>()
    
    func encode() -> Data {
        return self.data
    }
        
    func packageTlv2(tag: UInt8, length: UInt8, data: Data) {
        
        self.data.append(ByteConverter.byteFromUint8(value: tag))
        self.data.append(ByteConverter.byteFromUint8(value: length))
        self.data.append(data)
    }

    
    func pushString(value: String, tag: UInt8) {
        let byteData: Data = ByteConverter.byteFromString(value: value)
        let dataLength: UInt8 = UInt8(byteData.count)
        self.packageTlv2(tag: tag, length: dataLength, data: byteData)
    }
    func pushData(byteData: Data, tag: UInt8) {
        let binaryData = byteData.map { String($0, radix: 2).padLeft(toSize: 8) }.joined(separator: " ")
        let dataLength: UInt8 = UInt8(byteData.count)
        self.packageTlv2(tag: tag, length: dataLength, data: byteData)
    }

}
