//
//  RSAPublicKey.swift
//  pos
//
//  Created by M-Wageh on 05/04/2024.
//  Copyright © 2024 khaled. All rights reserved.
//

import Foundation
import Security

class RSAPublicKey {
    
    class func generateRSAPublicKey(modulus: String, exponent: String) -> SecKey? {
        guard let modulusData = Data(base64UrlEncoded: modulus) else {
            return nil
        }
        guard let exponentData = Data(base64UrlEncoded: exponent) else {
            return nil
        }
        
        let publicKeyAttributes: [CFString: Any] = [
            kSecAttrKeyType: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass: kSecAttrKeyClassPublic,
        ]
        
        var error: Unmanaged<CFError>?
        
        let dataa = Data(modulus: modulusData, exponent: exponentData)
        
        guard let publicKey = SecKeyCreateWithData(dataa as CFData, publicKeyAttributes as CFDictionary, &error) else {
            if let error = error?.takeRetainedValue() {
                SharedManager.shared.printLog("Failed to create RSA public key: \(error)")
            }
            return nil
        }
        var error1:Unmanaged<CFError>?
        if let cfdata = SecKeyCopyExternalRepresentation(publicKey, &error1) {
            let data:Data = cfdata as Data
            let b64Key = data.base64EncodedString()
            print("Key =>", b64Key)
        }
        return publicKey
    }
    class func publicKeyToDER(_ publicKey: SecKey) -> Data? {
        var error: Unmanaged<CFError>?
        guard let data = SecKeyCopyExternalRepresentation(publicKey, &error) as Data? else {
            if let error = error?.takeRetainedValue() {
                SharedManager.shared.printLog("Error: \(error)")
            }
            return nil
        }
        return data
    }
    class func secKeyToData(_ publicKey: SecKey) -> Data? {
        var error: Unmanaged<CFError>?
        
        guard let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, &error) as Data? else {
            if let error = error?.takeRetainedValue() {
                SharedManager.shared.printLog("Failed to convert SecKey to data: \(error)")
            }
            return nil
        }
        return publicKeyData
    }
}


/// Encoding/Decoding lengths as octets
///
private extension NSInteger {
    func encodedOctets() -> [CUnsignedChar] {
        // Short form
        if self < 128 {
            return [CUnsignedChar(self)];
        }
        
        // Long form
        let i = Int(log2(Double(self)) / 8 + 1)
        var len = self
        var result: [CUnsignedChar] = [CUnsignedChar(i + 0x80)]
        
        for _ in 0..<i {
            result.insert(CUnsignedChar(len & 0xFF), at: 1)
            len = len >> 8
        }
        
        return result
    }
    
    init?(octetBytes: [CUnsignedChar], startIdx: inout NSInteger) {
        if octetBytes[startIdx] < 128 {
            // Short form
            self.init(octetBytes[startIdx])
            startIdx += 1
        } else {
            // Long form
            let octets = NSInteger(octetBytes[startIdx] as UInt8 - 128)
            
            if octets > octetBytes.count - startIdx {
                self.init(0)
                return nil
            }
            
            var result = UInt64(0)
            
            for j in 1...octets {
                result = (result << 8)
                result = result + UInt64(octetBytes[startIdx + j])
            }
            
            startIdx += 1 + octets
            self.init(result)
        }
    }
}

private extension Data {
    init(modulus: Data, exponent: Data) {
        // Make sure neither the modulus nor the exponent start with a null byte
        var modulusBytes = [CUnsignedChar](UnsafeBufferPointer<CUnsignedChar>(start: (modulus as NSData).bytes.bindMemory(to: CUnsignedChar.self, capacity: modulus.count), count: modulus.count / MemoryLayout<CUnsignedChar>.size))
        let exponentBytes = [CUnsignedChar](UnsafeBufferPointer<CUnsignedChar>(start: (exponent as NSData).bytes.bindMemory(to: CUnsignedChar.self, capacity: exponent.count), count: exponent.count / MemoryLayout<CUnsignedChar>.size))
        
        // Make sure modulus starts with a 0x00
        if let prefix = modulusBytes.first , prefix != 0x00 {
            modulusBytes.insert(0x00, at: 0)
        }
        
        // Lengths
        let modulusLengthOctets = modulusBytes.count.encodedOctets()
        let exponentLengthOctets = exponentBytes.count.encodedOctets()
        
        // Total length is the sum of components + types
        let totalLengthOctets = (modulusLengthOctets.count + modulusBytes.count + exponentLengthOctets.count + exponentBytes.count + 2).encodedOctets()
        
        // Combine the two sets of data into a single container
        var builder: [CUnsignedChar] = []
        let data = NSMutableData()
        
        // Container type and size
        builder.append(0x30)
        builder.append(contentsOf: totalLengthOctets)
        data.append(builder, length: builder.count)
        builder.removeAll(keepingCapacity: false)
        
        // Modulus
        builder.append(0x02)
        builder.append(contentsOf: modulusLengthOctets)
        data.append(builder, length: builder.count)
        builder.removeAll(keepingCapacity: false)
        data.append(modulusBytes, length: modulusBytes.count)
        
        // Exponent
        builder.append(0x02)
        builder.append(contentsOf: exponentLengthOctets)
        data.append(builder, length: builder.count)
        data.append(exponentBytes, length: exponentBytes.count)
        
        self.init(bytes: data.bytes, count: data.length)
    }
}

extension Data {
    init?(base64UrlEncoded: String) {
        var base64Encoded = base64UrlEncoded
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        let paddingLength = 4 - base64Encoded.count % 4
        if paddingLength < 4 {
            base64Encoded += String(repeating: "=", count: paddingLength)
        }

        self.init(base64Encoded: base64Encoded)
    }
}
