//
//  ByteConverter.swift
//  pos
//
//  Created by M-Wageh on 29/11/2021.
//  Copyright © 2021 khaled. All rights reserved.
//

import Foundation

class ByteConverter {
    
    class func byteFromUint8(value: UInt8) -> Data {
        var byteArray: [UInt8] = [0]
        byteArray[0] = value & 0xff
        return Data(bytes: byteArray)
    }
    
    class func byteFromString(value: String) -> Data {
        var tempString = String(value)
        tempString.append("\0")
        let data: Data = value.data(using: .utf8)!
        return data
    }
    
   
}
