//
//  X509Certificate.swift
//  pos
//
//  Created by M-Wageh on 02/04/2024.
//  Copyright © 2024 khaled. All rights reserved.
//

import Foundation
import Security
import CryptoKit
import CommonCrypto
import ASN1Decoder
class MWX509Certificate{
    static let shared = MWX509Certificate()
    private var publicKey:Data?
    private var signatureString:Data?
     var isValid:Bool?
    private var x509: X509Certificate?
    var certificate_str:String?
    var serialNumber:String?
    var issuerName:String?
    private init(){
        
    }
    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        return dateFormatter
    }()
   @discardableResult func getX509Certificate() -> X509Certificate?{
       if let x509 = self.x509{
           return x509
       }
       guard let binarySecurityToken = SharedManager.shared.x509CertBase64 else {return nil}
       if let data = Data(base64Encoded: binarySecurityToken) ,
          let str = String(data: data, encoding: .utf8) {
           self.certificate_str = str
       }
      guard let base64Encoded = self.certificate_str else {
          return nil
      }
       let derData = Data(base64Encoded: base64Encoded)
       guard let certificateData = derData else {
           return nil
       }
       do {
           let certificate =  try X509.Certificate.init(pemRepresentation:certificate_str ?? "")
           self.serialNumber = certificate.serialNumber?.asString()

           self.x509 = try X509Certificate(der: certificateData )
           
           let subject = x509?.subjectDistinguishedName ?? ""
           let publickDerEn =  x509?.publicKey?.derEncodedKey
           self.signatureString = x509?.signature
           self.issuerName = x509?.issuerDistinguishedName?.replacingOccurrences(of: " ", with: "").components(separatedBy: ",").reversed().joined(separator: ", ")
           self.publicKey = publickDerEn
       } catch {
           SharedManager.shared.printLog(error)
       }
       return nil
    }
    /*
    func hexStringToString(_ hex: String) -> String {
        var str = ""
        var startIndex = hex.startIndex

        while startIndex < hex.endIndex {
            let endIndex = hex.index(startIndex, offsetBy: 2, limitedBy: hex.endIndex) ?? hex.endIndex
            let hexByte = hex[startIndex..<endIndex]
            if let byte = UInt8(hexByte, radix: 16) {
                str.append(Character(UnicodeScalar(byte)))
            }
            startIndex = endIndex
        }

        return str
    }
    */
    func getZatcaDateTime() -> String {
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0) // UTC
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        
        return dateFormatter.string(from: now)
    }
    
    func base64EncodeSHA256Hex() -> String? {
        let binarySecurityToken = self.certificate_str // SharedManager.shared.x509CertBase64
        guard let base64EncodedString =  SharedManager.shared.x509CertBase64  else {return nil}
        // Decode the Base64 encoded certificate
            guard let certData = Data(base64Encoded: base64EncodedString) else {
                SharedManager.shared.printLog("Failed to decode Base64 string.")
                return nil
            }
            
            // Calculate SHA-256 hash of the decoded certificate
            var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
            certData.withUnsafeBytes {
                _ = CC_SHA256($0.baseAddress, CC_LONG(certData.count), &hash)
            }
            
            // Convert the hash to a hexadecimal string
            let hexString = hash.map { String(format: "%02hhx", $0) }.joined()
            
            // Encode the hexadecimal string in Base64
            guard let hexData = hexString.data(using: .utf8) else {
                SharedManager.shared.printLog("Failed to convert hex string to Data.")
                return nil
            }
            
            let base64EncodedHash = hexData.base64EncodedString()
            
            return base64EncodedHash
     
    }
    func loadCSIDCertificate()  {
        self.getX509Certificate()
    }
    
    
    func getSignatureValue() -> Data?{
        if let signatureString = self.signatureString, signatureString.count != 0{
            return signatureString
        }else{
            loadCSIDCertificate()
            return self.signatureString
        }
    }
    func getPublicKeyValue() -> Data?{
        if let publicKey = self.publicKey, publicKey.count != 0{
            return publicKey
        }else{
            loadCSIDCertificate()
            return self.publicKey
        }
    }
    
/*
    private func setIsValid(for certificate: SecCertificate){
        var certificateInfo = [String: Any]()
        if let subjectName = SecCertificateCopySubjectSummary(certificate) as String?
            {
            SharedManager.shared.printLog("Subject: \(subjectName)")
            // Get the validity period
            if let range = subjectName.range(of: "notBefore=") {
                    let startIndex = range.upperBound
                    let endIndex = subjectName.index(startIndex, offsetBy: 13)
                    if let notBefore = dateFormatter.date(from: String(subjectName[startIndex..<endIndex])) {
                        certificateInfo["Valid From"] = notBefore
                    }
                }
            if let range = subjectName.range(of: "notAfter=") {
                    let startIndex = range.upperBound
                    let endIndex = subjectName.index(startIndex, offsetBy: 13)
                    if let notAfter = dateFormatter.date(from: String(subjectName[startIndex..<endIndex])) {
                        self.isValid = notAfter > Date()
                        certificateInfo["Valid Until"] = notAfter
                    }
                }
                
        } else {
            SharedManager.shared.printLog("Failed to retrieve subject or issuer information")
        }
    }
    private func checkExpire(){
        let nextDay = Calendar.current.date(byAdding: .day, value: 14, to: Date())
            let toDay = Date()
            SharedManager.shared.printLog(toDay)
            SharedManager.shared.printLog(nextDay!)

            if nextDay! < toDay  {
                SharedManager.shared.printLog("date1 is earlier than date2")
            }


//            let nextDay = Calendar.current.date(byAdding: .month, value: 1, to: Date())
//            let toDay = Date()
//            SharedManager.shared.printLog(toDay)
//            SharedManager.shared.printLog(nextDay!)
//
//            if nextDay! >= toDay  {
//                SharedManager.shared.printLog("date2 is earlier than date1")
//            }
    }
    private func setSignatureData(from certificateData: Data)  {
        let signatureRange = NSRange(location: 86, length: certificateData.count - 86)
           
           // Get the signature data from the certificate
           let signatureData = certificateData.subdata(in: Range(signatureRange)!)
        self.signatureString = signatureData //.base64EncodedString()
        SharedManager.shared.printLog("Certificate Signature:")
        SharedManager.shared.printLog(signatureData.base64EncodedString())

    }
   private func publicSecKey(for certificate: SecCertificate) -> SecKey? {
       var possibleTrust: SecTrust?
       SecTrustCreateWithCertificates(certificate, SecPolicyCreateBasicX509(), &possibleTrust)
       guard let trust = possibleTrust else { return nil }
       var result: SecTrustResultType = .unspecified
       SecTrustEvaluate(trust, &result)
       return SecTrustCopyPublicKey(trust)
       /*
        if #available(iOS 12.0, *) {
            return SecCertificateCopyKey(certificate)
        } else if #available(iOS 10.3, *) {
            return SecCertificateCopyPublicKey(certificate)
        } else {
            var possibleTrust: SecTrust?
            SecTrustCreateWithCertificates(certificate, SecPolicyCreateBasicX509(), &possibleTrust)
            guard let trust = possibleTrust else { return nil }
            var result: SecTrustResultType = .unspecified
            SecTrustEvaluate(trust, &result)
            return SecTrustCopyPublicKey(trust)
        }
        */
    }
   private func convertSecKeyToBase64(inputKey: SecKey?) ->String? {
        if let inputKey = inputKey {
            var error:Unmanaged<CFError>?
            if let cfdata = SecKeyCopyExternalRepresentation(inputKey, &error) {
                let data:Data = cfdata as Data
                let b64Key = data.base64EncodedString()
                return b64Key
            }
        }
        return nil
    }
    */

   
}
extension Data {
    // Convert Data to an Int (Big Endian)
    func toInt() -> Int {
        var value: Int = 0
        self.forEach { byte in
            value = value << 8 | Int(byte)
        }
        return value
    }
}
/**
 pos_config ["l10n_sa_production_csid_json"]
 
 {"requestID": 7703106245,
 "tokenType": "http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-x509-token-profile-1.0#X509v3",
 "dispositionMessage": "ISSUED",
 "binarySecurityToken": "TUlJRWF6Q0NCQkdnQXdJQkFnSVRZd0FBSGhlUXNSOG02K1E4RWdBQkFBQWVGekFLQmdncWhrak9QUVFEQWpCaU1SVXdFd1lLQ1pJbWlaUHlMR1FCR1JZRmJHOWpZV3d4RXpBUkJnb0praWFKay9Jc1pBRVpGZ05uYjNZeEZ6QVZCZ29Ka2lhSmsvSXNaQUVaRmdkbGVIUm5ZWHAwTVJzd0dRWURWUVFERXhKUVJWcEZTVTVXVDBsRFJWTkRRVEV0UTBFd0hoY05NalF3TkRBeU1URTFOalV3V2hjTk1qWXdOREF5TVRJd05qVXdXakNCdVRFTE1Ba0dBMVVFQmhNQ1UwRXhHREFXQmdOVkJBZ1REMUpwZVdGa2FDQkVjbmtnVUc5eWRERVZNQk1HQTFVRUJ3d00yS2ZaaE5peDJZcllwOWkyTVRFd0x3WURWUVFLRENqWXROaXgyWVBZcVNEWXA5bUUyTEhZcDlpczJLM1ppaURZcDltRTJMcllzTmluMktiWml0aXBNUk13RVFZRFZRUUxFd296TVRBNU5UUTROek01TVRFd0x3WURWUVFERENqWXROaXgyWVBZcVNEWXA5bUUyTEhZcDlpczJLM1ppaURZcDltRTJMcllzTmluMktiWml0aXBNRll3RUFZSEtvWkl6ajBDQVFZRks0RUVBQW9EUWdBRXJUNkVaRnJERitHK0JDVDRNMU5IQ252T2FSUSs1Um9FbzhiWUNQSWlMWlNFbGlaZEFFTTNZMVk1b3hEbWZncTQ4YmhmbmttQ3pHYS8xV2ptKzFHOHU2T0NBazh3Z2dKTE1JR2hCZ05WSFJFRWdaa3dnWmFrZ1pNd2daQXhHekFaQmdOVkJBUU1FakV0VDJSdmIzd3lMVEUwZkRNdFVWcEdNVEVmTUIwR0NnbVNKb21UOGl4a0FRRU1Eek14TURrMU5EZzNNemt3TURBd016RU5NQXNHQTFVRURBd0VNVEV3TURFeE1DOEdBMVVFR2d3bzJMVFlzZG1EMktrZzJLZlpoTml4MktmWXJOaXQyWW9nMktmWmhOaTYyTERZcDlpbTJZcllxVEVPTUF3R0ExVUVEd3dGVDNSb1pYSXdIUVlEVlIwT0JCWUVGSUNqSFYxQ00rTnJndllFamRXNGllSW5FazJ4TUI4R0ExVWRJd1FZTUJhQUZLcFlPSU9wbGlWTjZsUjZ1WlFINDFkUStEdm9NSUhPQmdnckJnRUZCUWNCQVFTQndUQ0J2akNCdXdZSUt3WUJCUVVITUFLR2dhNXNaR0Z3T2k4dkwwTk9QVkJGV2tWSlRsWlBTVU5GVTBOQk1TMURRU3hEVGoxQlNVRXNRMDQ5VUhWaWJHbGpKVEl3UzJWNUpUSXdVMlZ5ZG1salpYTXNRMDQ5VTJWeWRtbGpaWE1zUTA0OVEyOXVabWxuZFhKaGRHbHZiaXhFUXoxbGVIUjZZWFJqWVN4RVF6MW5iM1lzUkVNOWJHOWpZV3cvWTBGRFpYSjBhV1pwWTJGMFpUOWlZWE5sUDI5aWFtVmpkRU5zWVhOelBXTmxjblJwWm1sallYUnBiMjVCZFhSb2IzSnBkSGt3RGdZRFZSMFBBUUgvQkFRREFnZUFNRHdHQ1NzR0FRUUJnamNWQndRdk1DMEdKU3NHQVFRQmdqY1ZDSUdHcUIyRTBQc1NodTJkSklmTyt4blR3RlZtZ1p6WUxZUGx4VjBDQVdRQ0FSQXdIUVlEVlIwbEJCWXdGQVlJS3dZQkJRVUhBd0lHQ0NzR0FRVUZCd01ETUNjR0NTc0dBUVFCZ2pjVkNnUWFNQmd3Q2dZSUt3WUJCUVVIQXdJd0NnWUlLd1lCQlFVSEF3TXdDZ1lJS29aSXpqMEVBd0lEU0FBd1JRSWhBSVZNMlRhbkpBcEdNVWlnVUMyUHBhdmpkeHJZaDN6R204UVBURXBuWTJQQkFpQm5kd29yblRMWkw2am1RVEowYWVYTlg0M3Azc1M3a0hGays2NWhDQlN5R1E9PQ==",
 "secret": "bHXkJuLYF3HKfDztbWGc6y/f5l3tE+UVFQoeNBAdFVI="}
 
 
 */
/**
[ "binarySecurityToken": ]
 "TUlJRWF6Q0NCQkdnQXdJQkFnSVRZd0FBSGhlUXNSOG02K1E4RWdBQkFBQWVGekFLQmdncWhrak9QUVFEQWpCaU1SVXdFd1lLQ1pJbWlaUHlMR1FCR1JZRmJHOWpZV3d4RXpBUkJnb0praWFKay9Jc1pBRVpGZ05uYjNZeEZ6QVZCZ29Ka2lhSmsvSXNaQUVaRmdkbGVIUm5ZWHAwTVJzd0dRWURWUVFERXhKUVJWcEZTVTVXVDBsRFJWTkRRVEV0UTBFd0hoY05NalF3TkRBeU1URTFOalV3V2hjTk1qWXdOREF5TVRJd05qVXdXakNCdVRFTE1Ba0dBMVVFQmhNQ1UwRXhHREFXQmdOVkJBZ1REMUpwZVdGa2FDQkVjbmtnVUc5eWRERVZNQk1HQTFVRUJ3d00yS2ZaaE5peDJZcllwOWkyTVRFd0x3WURWUVFLRENqWXROaXgyWVBZcVNEWXA5bUUyTEhZcDlpczJLM1ppaURZcDltRTJMcllzTmluMktiWml0aXBNUk13RVFZRFZRUUxFd296TVRBNU5UUTROek01TVRFd0x3WURWUVFERENqWXROaXgyWVBZcVNEWXA5bUUyTEhZcDlpczJLM1ppaURZcDltRTJMcllzTmluMktiWml0aXBNRll3RUFZSEtvWkl6ajBDQVFZRks0RUVBQW9EUWdBRXJUNkVaRnJERitHK0JDVDRNMU5IQ252T2FSUSs1Um9FbzhiWUNQSWlMWlNFbGlaZEFFTTNZMVk1b3hEbWZncTQ4YmhmbmttQ3pHYS8xV2ptKzFHOHU2T0NBazh3Z2dKTE1JR2hCZ05WSFJFRWdaa3dnWmFrZ1pNd2daQXhHekFaQmdOVkJBUU1FakV0VDJSdmIzd3lMVEUwZkRNdFVWcEdNVEVmTUIwR0NnbVNKb21UOGl4a0FRRU1Eek14TURrMU5EZzNNemt3TURBd016RU5NQXNHQTFVRURBd0VNVEV3TURFeE1DOEdBMVVFR2d3bzJMVFlzZG1EMktrZzJLZlpoTml4MktmWXJOaXQyWW9nMktmWmhOaTYyTERZcDlpbTJZcllxVEVPTUF3R0ExVUVEd3dGVDNSb1pYSXdIUVlEVlIwT0JCWUVGSUNqSFYxQ00rTnJndllFamRXNGllSW5FazJ4TUI4R0ExVWRJd1FZTUJhQUZLcFlPSU9wbGlWTjZsUjZ1WlFINDFkUStEdm9NSUhPQmdnckJnRUZCUWNCQVFTQndUQ0J2akNCdXdZSUt3WUJCUVVITUFLR2dhNXNaR0Z3T2k4dkwwTk9QVkJGV2tWSlRsWlBTVU5GVTBOQk1TMURRU3hEVGoxQlNVRXNRMDQ5VUhWaWJHbGpKVEl3UzJWNUpUSXdVMlZ5ZG1salpYTXNRMDQ5VTJWeWRtbGpaWE1zUTA0OVEyOXVabWxuZFhKaGRHbHZiaXhFUXoxbGVIUjZZWFJqWVN4RVF6MW5iM1lzUkVNOWJHOWpZV3cvWTBGRFpYSjBhV1pwWTJGMFpUOWlZWE5sUDI5aWFtVmpkRU5zWVhOelBXTmxjblJwWm1sallYUnBiMjVCZFhSb2IzSnBkSGt3RGdZRFZSMFBBUUgvQkFRREFnZUFNRHdHQ1NzR0FRUUJnamNWQndRdk1DMEdKU3NHQVFRQmdqY1ZDSUdHcUIyRTBQc1NodTJkSklmTyt4blR3RlZtZ1p6WUxZUGx4VjBDQVdRQ0FSQXdIUVlEVlIwbEJCWXdGQVlJS3dZQkJRVUhBd0lHQ0NzR0FRVUZCd01ETUNjR0NTc0dBUVFCZ2pjVkNnUWFNQmd3Q2dZSUt3WUJCUVVIQXdJd0NnWUlLd1lCQlFVSEF3TXdDZ1lJS29aSXpqMEVBd0lEU0FBd1JRSWhBSVZNMlRhbkpBcEdNVWlnVUMyUHBhdmpkeHJZaDN6R204UVBURXBuWTJQQkFpQm5kd29yblRMWkw2am1RVEowYWVYTlg0M3Azc1M3a0hGays2NWhDQlN5R1E9PQ=="
 
 
 [Decode]
 MIIEazCCBBGgAwIBAgITYwAAHheQsR8m6+Q8EgABAAAeFzAKBggqhkjOPQQDAjBiMRUwEwYKCZImiZPyLGQBGRYFbG9jYWwxEzARBgoJkiaJk/IsZAEZFgNnb3YxFzAVBgoJkiaJk/IsZAEZFgdleHRnYXp0MRswGQYDVQQDExJQRVpFSU5WT0lDRVNDQTEtQ0EwHhcNMjQwNDAyMTE1NjUwWhcNMjYwNDAyMTIwNjUwWjCBuTELMAkGA1UEBhMCU0ExGDAWBgNVBAgTD1JpeWFkaCBEcnkgUG9ydDEVMBMGA1UEBwwM2KfZhNix2YrYp9i2MTEwLwYDVQQKDCjYtNix2YPYqSDYp9mE2LHYp9is2K3ZiiDYp9mE2LrYsNin2KbZitipMRMwEQYDVQQLEwozMTA5NTQ4NzM5MTEwLwYDVQQDDCjYtNix2YPYqSDYp9mE2LHYp9is2K3ZiiDYp9mE2LrYsNin2KbZitipMFYwEAYHKoZIzj0CAQYFK4EEAAoDQgAErT6EZFrDF+G+BCT4M1NHCnvOaRQ+5RoEo8bYCPIiLZSEliZdAEM3Y1Y5oxDmfgq48bhfnkmCzGa/1Wjm+1G8u6OCAk8wggJLMIGhBgNVHREEgZkwgZakgZMwgZAxGzAZBgNVBAQMEjEtT2Rvb3wyLTE0fDMtUVpGMTEfMB0GCgmSJomT8ixkAQEMDzMxMDk1NDg3MzkwMDAwMzENMAsGA1UEDAwEMTEwMDExMC8GA1UEGgwo2LTYsdmD2Kkg2KfZhNix2KfYrNit2Yog2KfZhNi62LDYp9im2YrYqTEOMAwGA1UEDwwFT3RoZXIwHQYDVR0OBBYEFICjHV1CM+NrgvYEjdW4ieInEk2xMB8GA1UdIwQYMBaAFKpYOIOpliVN6lR6uZQH41dQ+DvoMIHOBggrBgEFBQcBAQSBwTCBvjCBuwYIKwYBBQUHMAKGga5sZGFwOi8vL0NOPVBFWkVJTlZPSUNFU0NBMS1DQSxDTj1BSUEsQ049UHVibGljJTIwS2V5JTIwU2VydmljZXMsQ049U2VydmljZXMsQ049Q29uZmlndXJhdGlvbixEQz1leHR6YXRjYSxEQz1nb3YsREM9bG9jYWw/Y0FDZXJ0aWZpY2F0ZT9iYXNlP29iamVjdENsYXNzPWNlcnRpZmljYXRpb25BdXRob3JpdHkwDgYDVR0PAQH/BAQDAgeAMDwGCSsGAQQBgjcVBwQvMC0GJSsGAQQBgjcVCIGGqB2E0PsShu2dJIfO+xnTwFVmgZzYLYPlxV0CAWQCARAwHQYDVR0lBBYwFAYIKwYBBQUHAwIGCCsGAQUFBwMDMCcGCSsGAQQBgjcVCgQaMBgwCgYIKwYBBQUHAwIwCgYIKwYBBQUHAwMwCgYIKoZIzj0EAwIDSAAwRQIhAIVM2TanJApGMUigUC2PpavjdxrYh3zGm8QPTEpnY2PBAiBndwornTLZL6jmQTJ0aeXNX43p3sS7kHFk+65hCBSyGQ==
 
 */
