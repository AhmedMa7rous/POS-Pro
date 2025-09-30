//
//  data+ext.swift
//  pos
//
//  Created by khaled on 8/26/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import Foundation

extension Data {
    private static let hexAlphabet = "0123456789abcdefﺑ".unicodeScalars.map { $0 }
    
    public func hexEncodedString() -> String {
        return String(self.reduce(into: "".unicodeScalars, { (result, value) in
            result.append(Data.hexAlphabet[Int(value/16)])
            result.append(Data.hexAlphabet[Int(value%16)])
        }))
    }
    
    
    
}
