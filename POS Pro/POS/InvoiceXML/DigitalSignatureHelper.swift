//
//  DigitalSignatureHelper.swift
//  pos
//
//  Created by M-Wageh on 06/04/2024.
//  Copyright © 2024 khaled. All rights reserved.
//

import Foundation
import Security
import CommonCrypto

import ASN1Decoder
class DigitalSignatureHelper {
    static func test(data:Data){
        do {
            let pkcs = try PKCS7(data: data )
            SharedManager.shared.printLog(pkcs.signatures)
        }catch (let error){
            SharedManager.shared.printLog(error)
        }
    }

    
    func signInvoice(invoiceHash: String, usingKeyWithTag keyTag: String) -> String? {
        // Decode the Base64-encoded invoice hash
        guard let hashData = Data(base64Encoded: invoiceHash) else {
            SharedManager.shared.printLog("Invalid Base64 string.")
            return nil
        }
        
        // Retrieve the private key from the Keychain
        guard let privateKey = retrievePrivateKey(tag: keyTag) else {
            SharedManager.shared.printLog("Private key not found.")
            return nil
        }
        
        // Sign the hash
        return signDataWithPrivateKey(hashData: hashData, privateKey: privateKey)
    }

    private func retrievePrivateKey(tag: String) -> SecKey? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: tag,
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecReturnRef as String: true
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess else { return nil }
        
        return (item as! SecKey)
    }
    
    private func signDataWithPrivateKey(hashData: Data, privateKey: SecKey) -> String? {
        var error: Unmanaged<CFError>?
        guard let signature = SecKeyCreateSignature(privateKey,
                                                    .ecdsaSignatureMessageX962SHA256,
                                                    hashData as CFData,
                                                    &error) as Data? else {
            SharedManager.shared.printLog("Error creating signature: \(error!.takeRetainedValue())")
            return nil
        }

        return signature.base64EncodedString()
    }
}
