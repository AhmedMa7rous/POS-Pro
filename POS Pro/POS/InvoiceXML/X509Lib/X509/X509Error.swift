//
//  File.swift
//  
//
//  Created by Markus on 01.12.19.
//

import Foundation


struct X509Error: Error, Equatable {
    
    /// A human readable description of the error.
    let localizedDescription: String

    private let internalError: InternalError
    
    private enum InternalError {
        case invalidPEMString, unknownPEMHeader, failedBase64Encoding, failedASN1Decoding, unsupportedCurve, failedNativeKeyCreation, failedEvpInit, failedSigningAlgorithm, invalidRSLength, failedEncryptionAlgorithm, failedUTF8Decoding, failedDecryptionAlgorithm
    }
    
    /// Error thrown when an invalid PEM String used to initialize a key.
    static let invalidPEMString = X509Error(localizedDescription: "Input was not a valid PEM String", internalError: .invalidPEMString)
    
    /// Error thrown when the PEM header is not recognized.
    static let unknownPEMHeader = X509Error(localizedDescription: "Input PEM header was not recognized", internalError: .unknownPEMHeader)

    /// Error thrown when a String fails to be Base64 encoded.
    static let failedBase64Encoding = X509Error(localizedDescription: "Failed to base64 encode the String", internalError: .failedBase64Encoding)

    /// Error thrown when the ASN1 data could not be decoded to the expected structure.
    static let failedASN1Decoding = X509Error(localizedDescription: "ASN1 data could not be decoded to expected structure", internalError: .failedASN1Decoding)
    
    /// Error thrown when the key's object identifier is for a curve that is not supported.
    static let unsupportedCurve = X509Error(localizedDescription: "The key object identifier is for a non-supported curve", internalError: .unsupportedCurve)
    
    /// Error thrown when the key could not be converted to a native key (`SecKey` for Apple, `EC_KEY` for linux).
    static let failedNativeKeyCreation = X509Error(localizedDescription: "The key data could not be converted to a native key", internalError: .failedNativeKeyCreation)
    
    /// Error thrown when the encryption envelope fails to initialize.
    static let failedEvpInit = X509Error(localizedDescription: "Failed to initialize the signing envelope", internalError: .failedEvpInit)
        
    /// Error thrown when the signing algorithm could not create the signature.
    static let failedSigningAlgorithm = X509Error(localizedDescription: "Signing algorithm failed to create the signature", internalError: .failedSigningAlgorithm)
    
    /// Error thrown when the provided R and S Data was not a valid length.
    /// They must be the same length and either 32, 48 or 66 bytes (depending on the curve used).
    static let invalidRSLength = X509Error(localizedDescription: "The provided R and S values were not a valid length", internalError: .invalidRSLength)
    
    /// Error thrown when the encryption algorithm could not encrypt the plaintext.
    static let failedEncryptionAlgorithm = X509Error(localizedDescription: "Encryption algorithm failed to encrypt the data", internalError: .failedEncryptionAlgorithm)
    
    /// Error thrown when the decryption algorithm could not decrypt the encrypted Data.
    static let failedDecryptionAlgorithm = X509Error(localizedDescription: "Decryption algorithm failed to decrypt the data", internalError: .failedDecryptionAlgorithm)
    
    /// Error thrown when the Data could not be decoded into a UTF8 String.
    static let failedUTF8Decoding = X509Error(localizedDescription: "Data could not be decoded as a UTF8 String", internalError: .failedUTF8Decoding)
    
    /// Checks if X509rrors are equal, required for Equatable protocol.
    static func == (lhs: X509Error, rhs: X509Error) -> Bool {
        return lhs.internalError == rhs.internalError
    }
}
