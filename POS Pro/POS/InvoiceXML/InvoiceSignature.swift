//
//  InvoiceSignature.swift
//  pos
//
//  Created by M-Wageh on 02/04/2024.
//  Copyright © 2024 khaled. All rights reserved.
//

import Foundation
import Security
import CommonCrypto
import ASN1Decoder
import CryptoKit
import CryptorECC
import secp256k1

class InvoiceSignature {
    
    static let shared:InvoiceSignature = InvoiceSignature()
    
    private init(){}
    
    private func generateDigitalSignature(xmlData: Data, privateKey: SecKey) -> String? {
        // Prepare the data to be signed (e.g., the XML eInvoice)
        let dataToSign = xmlData
        
        // Create a SHA256 hash of the data
        var sha256Digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        dataToSign.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(dataToSign.count), &sha256Digest)
        }
        let sha256Data = Data(bytes: sha256Digest)
        
        // Sign the hash using the private key
        var error: Unmanaged<CFError>?
        guard let signature = SecKeyCreateSignature(privateKey,
                                                    .ecdsaSignatureDigestX962SHA256,
                                                    sha256Data as CFData,
                                                    &error) as Data? else {
            SharedManager.shared.printLog("Error creating signature: \(error!.takeRetainedValue() as Error)")
            return nil
        }
        
        // Encode the signature as Base64
        let base64Signature = signature.base64EncodedString()
        
        return base64Signature
    }
    func loadInvoiceSignature(hashInvoice:String) -> String?{
        guard let privateKeyPem = SharedManager.shared.privateKeyBase64 else {return nil}

       return TESTPK().run(hashXML:hashInvoice , privateKey: privateKeyPem)

       /* if let privateKey = loadPrivateKey(), // Load the private key
           let xmlData = "<invoice>...</invoice>".data(using: .utf8), // Provide XML eInvoice data
           let signature = generateDigitalSignature(xmlData: xmlData, privateKey: privateKey) {
            
            SharedManager.shared.printLog("Digital signature:", signature)
            return signature
        } else {
            SharedManager.shared.printLog("Failed to generate digital signature")
            return nil
        }
        */
    }
    private func loadPrivateKey(password: String = "") -> SecKey? {
        
        
        //        guard let filePath = Bundle.main.path(forResource: fileName, ofType: "p12"),
        //              let p12Data = try? Data(contentsOf: URL(fileURLWithPath: filePath)) else {
        //            SharedManager.shared.printLog("Failed to load .p12 file")
        //            return nil
        //        }
        guard let base64Encoded = SharedManager.shared.privateKeyBase64 else {return nil}
        var pemString = base64Encoded.replacingOccurrences(of: "-----END EC PRIVATE KEY-----\n", with: "-----END EC PRIVATE KEY-----")
       var testPEMPOS = """
-----BEGIN EC PRIVATE KEY-----
MHQCAQEEIGEZhLQsxtYx7oXIWoqaVOXr2/4P7onyMJ58ycOJACXKoAcGBSuBBAAK
oUQDQgAErT6EZFrDF+G+BCT4M1NHCnvOaRQ+5RoEo8bYCPIiLZSEliZdAEM3Y1Y5
oxDmfgq48bhfnkmCzGa/1Wjm+1G8uw==
-----END EC PRIVATE KEY-----
"""
        var testPEM = """
-----BEGIN EC PRIVATE KEY-----
MHcCAQEEIJX+87WJ7Gh19sohyZnhxZeXYNOcuGv4Q+8MLge4UkaZoAoGCCqGSM49
AwEHoUQDQgAEikc5m6C2xtDWeeAeT18WElO37zvFOz8p4kAlhvgIHN23XIClNESg
KVmLgSSq2asqiwdrU5YHbcHFkgdABM1SPA==
-----END EC PRIVATE KEY-----
"""

        do {
            // Remove PEM header and footer
              let pemComponents = pemString.components(separatedBy: "\n")
              let base64String = pemComponents.dropFirst().dropLast().joined()
              
              // Decode base64-encoded DER data
              guard let derData = Data(base64Encoded: base64String) else {
                  throw NSError(domain: "PEMError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to decode base64-encoded data"])
              }
              
              // Initialize ECPrivateKey object from DER data
            
            let eccPrivateKey = try ECPrivateKey(key: testPEMPOS)
            SharedManager.shared.printLog(eccPrivateKey)

        }
        catch (let error){
            SharedManager.shared.printLog(error)
        }
            let derData = self.decodeToDER(base64Encoded)
            SharedManager.shared.printLog(" InvoiceSignature derData === \(derData)")

            guard let p12Data2 = derData else { return nil }
        guard let p12Data = encodeECPrivateKeyToDER(p12Data2) else {
                return nil
            }

        let options = [kSecImportExportPassphrase as String: password]
        var items: CFArray?
        let status = SecPKCS12Import(p12Data as CFData, options as CFDictionary, &items)
        
        if status == errSecSuccess, let items = items as? Array<Dictionary<String, Any>>, let firstItem = items.first {
            if let identity = firstItem[kSecImportItemIdentity as String] as! SecIdentity? {
                var privateKey: SecKey?
                let copyStatus = SecIdentityCopyPrivateKey(identity, &privateKey)
                
                if copyStatus == errSecSuccess {
                    return privateKey
                } else {
                    SharedManager.shared.printLog("Failed to extract private key from identity")
                }
            }
        } else {
            SharedManager.shared.printLog("Failed parse l10n_sa_private_key ")
        }
        
        return nil
    }
    func loadInvoiceSignature2(hashInvoice:String) -> String?{
        let decoded_hash = decode(hashInvoice) ?? ""
//        let privateKey = loadPEMPrivateKey()
        /*
         let attributes: [String: Any] = [
             String(kSecAttrKeyType): kSecAttrKeyTypeRSA,
             String(kSecAttrKeyClass): kSecAttrKeyClassPublic,
             String(kSecAttrKeySizeInBits): derData.count * 8
         ]

         var error: Unmanaged<CFError>?
         if let key5 = SecKeyCreateWithData(derData as CFData, attributes as CFDictionary, &error){
             let plKey = self.convertSecKeyToBase64(inputKey:key5)
             SharedManager.shared.printLog(plKey)
         }
         if let error = error {
             SharedManager.shared.printLog("Error creating certificate: \(error.takeRetainedValue() as Error)")
         } else {
             SharedManager.shared.printLog("Failed to create certificate from data")
         }
         */
        if let base64Encoded = SharedManager.shared.privateKeyBase64{
            let derData = self.decodeToDER(base64Encoded)
            SharedManager.shared.printLog(" InvoiceSignature derData === \(derData)")

            guard let derData = derData else { return nil }
            DigitalSignatureHelper.test(data:derData )

            let vvv = self.importPrivateKey(from:derData,password:"")
            SharedManager.shared.printLog(" InvoiceSignature vvv === \(vvv)")
            if let privateKey = loadPrivateKey2(derData),
               let data = decoded_hash.data(using: .utf8),
               let signature = getDigitalSignature(privateKey: privateKey, data: data) {
                SharedManager.shared.printLog("Digital Signature:")
                SharedManager.shared.printLog(signature.base64EncodedString())
                return signature.base64EncodedString()
            } else {
                SharedManager.shared.printLog("Failed to generate digital signature.")
            }
        }
        
        return nil

       
    }
    
    func loadPrivateKey2(_ privateKeyData:Data) -> SecKey? {
        // Load the private key data from file
//        guard let privateKeyPath = Bundle.main.path(forResource: "company_id", ofType: "der"),
//              let privateKeyData = FileManager.default.contents(atPath: privateKeyPath) else {
//            SharedManager.shared.printLog("Failed to load private key data.")
//            return nil
//        }
        
        // Create a dictionary with key attributes
        let keyAttributes: [CFString: Any] = [
            kSecAttrKeyType: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeyClass: kSecAttrKeyClassPrivate
        ]
        
        // Create a SecKey instance from the private key data
        var error: Unmanaged<CFError>?
        guard let privateKey = SecKeyCreateWithData(privateKeyData as CFData, keyAttributes as CFDictionary, &error) else {
            if let error = error?.takeRetainedValue() {
                SharedManager.shared.printLog("Failed to create private key: \(error)")
            } else {
                SharedManager.shared.printLog("Failed to create private key.")
            }
            return nil
        }
        
        return privateKey
    }
    func importPrivateKey(from p12Data: Data, password: String) -> String? {
        let options = [kSecImportExportPassphrase as String: password]
        var items: CFArray?

        let status = SecPKCS12Import(p12Data as CFData, options as CFDictionary, &items)
        guard status == errSecSuccess else { return nil }

        let itemsArray = items! as NSArray
        guard let item = itemsArray.firstObject as? [String: AnyObject]
               else {
            return nil
        }
        guard let identity = item[kSecImportItemIdentity as String] else {
            return nil
        }
//        guard let identity = (item[kSecImportItemIdentity as String] as? SecIdentity) else{return nil}
        var privateKey: SecKey?
        SecIdentityCopyPrivateKey(identity as! SecIdentity, &privateKey)

        guard let key = privateKey else { return nil }

        // Extract the key data
        var error: Unmanaged<CFError>?
        guard let keyData = SecKeyCopyExternalRepresentation(key, &error) as Data? else {
            SharedManager.shared.printLog("Error extracting key data: \(error!.takeRetainedValue() as Error)")
            return nil
        }

        // Convert key data to a base64 encoded string
        let base64KeyString = keyData.base64EncodedString()

        return base64KeyString
    }

    func getDigitalSignature(privateKey: SecKey, data: Data) -> Data? {
        // Create a SHA-256 hash of the data
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
        }
        
        // Sign the hash using the private key
        var signature: Unmanaged<CFError>?
        guard let signatureData = SecKeyCreateSignature(privateKey, .ecdsaSignatureDigestX962SHA256, Data(hash) as CFData, &signature) as Data? else {
            SharedManager.shared.printLog("Failed to create signature.")
            return nil
        }
        
        return signatureData
    }
    private func encodeECPrivateKeyToDER(_ keyData: Data) -> Data? {
        // ASN.1 DER sequence header for EC private key
        let sequenceHeader: [UInt8] = [0x30, 0x81, 0xa4]
        
        // ASN.1 DER octet string header for the private key data
        let octetStringHeader: [UInt8] = [0x04, 0x81]
        
        // Length of the private key data
        let keyLength = keyData.count
        
        // Initialize DER-encoded data
        var derData = Data()
        
        // Add sequence header
        derData.append(Data(sequenceHeader))
        
        // Add octet string header
        derData.append(Data(octetStringHeader + [UInt8(keyLength)]))
        
        // Add private key data
        derData.append(keyData)
        
        return derData
    }
    private  func decodeToDER(_ pem: String) -> Data? {
        let beginPemBlock = "-----BEGIN EC PRIVATE KEY-----"
        let endPemBlock = "-----END EC PRIVATE KEY-----"
        if
//            let pem = String(data: pemData, encoding: .ascii),
            pem.contains(beginPemBlock) {

            let lines = pem.components(separatedBy: .newlines)

            var base64buffer  = ""
            var certLine = false
            for line in lines {
                if line == endPemBlock {
                    certLine = false
                }
                if certLine {
                    base64buffer.append(line)
                }
                if line == beginPemBlock {
                    certLine = true
                }
            }
            if var derDataDecoded = Data(base64Encoded: base64buffer) {
                SharedManager.shared.printLog(base64buffer)
              if let str = String(data: derDataDecoded, encoding: .utf8) {
                  SharedManager.shared.printLog(str)
                    
                  if let database64 = Data(base64Encoded: str){
                      derDataDecoded = database64
                  }
                }
                return derDataDecoded
            }
        }

        return nil
    }
    
    /*
    func loadPEMPrivateKey() -> String? {
        // Path to your PEM private key file
        guard let keyFilePath = Bundle.main.path(forResource: "company_id", ofType: "pem") else {
            SharedManager.shared.printLog("Private key file not found.")
            return nil
        }
        
        // Load the private key data from file
        guard let privateKeyPEM = try? String(contentsOfFile: keyFilePath) else {
            SharedManager.shared.printLog("Failed to load private key data.")
            return nil
        }
        
        // Decode the PEM private key data using SwiftyRSA
        do {
            let privateKey = try PrivateKey(pemEncoded: privateKeyPEM)
            // Convert the private key data to a base64-encoded string
            let base64PrivateKey = try privateKey.data().base64EncodedString()
            return base64PrivateKey
        } catch {
            SharedManager.shared.printLog("Failed to decode PEM private key: \(error)")
            return nil
        }
    }*/
    func decode(_ invoiceHashBase64:String) -> String?{
        if let data = Data(base64Encoded: invoiceHashBase64) {
            if let decodedString = String(data: data, encoding: .utf8) {
                SharedManager.shared.printLog("decode hash Invoice String:\(decodedString)")
                return decodedString
            } else {
                SharedManager.shared.printLog("Failed to decode data into a UTF-8 string.")
            }
        } else {
            SharedManager.shared.printLog("Failed to decode base64 encoded string.")
        }
        return nil
    }
}
/**
 res_company ["l10n_sa_private_key"]
 
 
 - some : -----BEGIN EC PRIVATE KEY-----
MHQCAQEEIGEZhLQsxtYx7oXIWoqaVOXr2/4P7onyMJ58ycOJACXKoAcGBSuBBAAK
oUQDQgAErT6EZFrDF+G+BCT4M1NHCnvOaRQ+5RoEo8bYCPIiLZSEliZdAEM3Y1Y5
oxDmfgq48bhfnkmCzGa/1Wjm+1G8uw==
-----END EC PRIVATE KEY-----
 
 */
import Security
import CommonCrypto

class TESTPK{

    // Function to decode the EC private key from its PEM string representation
    func decodeECPrivateKey(fromPEM pemString: String) -> Data? {
        // Remove PEM header and footer
        let pemComponents = pemString.components(separatedBy: "\n").filter { !$0.isEmpty && !$0.hasPrefix("-----") }
        let base64String = pemComponents.joined()
        
        // Decode base64-encoded DER data
        guard let derData = Data(base64Encoded: base64String) else {
            SharedManager.shared.printLog("Failed to decode base64-encoded data")
            return nil
        }
        
        return derData
    }

    // Function to generate an ECDSA signature for data using the EC private key
    func generateECDSASignature(data: Data, privateKey: Data) -> Data? {
        // Hash the data using SHA256
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &digest)
        }
        let hashedData = Data(digest)
        
        // Placeholder implementation for signing data with the private key
        // Here you'd typically use a library like libsecp256k1 or CommonCrypto to perform the actual signing
        // Below is a placeholder implementation using CommonCrypto's HMAC with SHA256 for demonstration purposes
        var signature = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256), privateKey.bytes, privateKey.count, hashedData.bytes, hashedData.count, &signature)
        return Data(signature)
    }
    func run(hashXML:String,privateKey:String) ->String?{
        let privateKeyPEM = privateKey
        let xmlEInvoiceData = hashXML
        let privateKeyBase64 = privateKeyPEM
               .replacingOccurrences(of: "-----BEGIN EC PRIVATE KEY-----", with: "")
               .replacingOccurrences(of: "-----END EC PRIVATE KEY-----", with: "")
               .replacingOccurrences(of: "\n", with: "")
           
           guard let privateKeyData = Data(base64Encoded: privateKeyBase64) else {
               SharedManager.shared.printLog("Invalid private key format")
               return nil
           }
        do {
            let mwPrivateKey = try secp256k1.Signing.PrivateKey(derRepresentation: privateKeyData)
                let signature = try mwPrivateKey.signature(for: Data(xmlEInvoiceData.utf8))
            var signatureData = try signature.derRepresentation
            let base64Signature = signatureData.base64EncodedString()
            return base64Signature
            } catch {
                SharedManager.shared.printLog("Failed to sign the hash: \(error)")
                return nil
            }
    }

   

}
