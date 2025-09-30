//
//  TlvEntity.swift
//  pos
//
//  Created by M-Wageh on 29/11/2021.
//  Copyright © 2021 khaled. All rights reserved.
//

import Foundation

class TlvEntity {
    var length: UInt16?
    var value: Data?
    var tag: UInt8?
    
    func valueData() -> Data {
        //return value!
        guard value == nil else {
            return value!
        }
        
        return Data()
    }
    
}
