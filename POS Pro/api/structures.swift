//
//  structures.swift
//  pos
//
//  Created by khaled on 8/6/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import Foundation

/*
var defString = String(stringLiteral: "")
var defInt = -1

struct User: Codable, CustomStringConvertible {
    var id: Int?
    var firstName: String?
    var lastName: String?
    var avatar: String?
    
    var description: String {
        return """
        ------------
        id = \(id ?? defInt)
        firstName = \(firstName ?? defString)
        lastName = \(lastName ?? defString)
        avatar = \(avatar ?? defString)
        ------------
        """
    }
}


struct product: Decodable {
    
    let id: Int
    let jsonrpc : String
    let result: [result]
    
}
struct result: Codable {
    
    let id: checkReturnType?
    let barcode : checkReturnType?
    let display_name: checkReturnType?
    
    let default_code:  checkReturnType?
    let list_price: checkReturnType?
    let to_weight: checkReturnType?
    let description_sale: checkReturnType?
    let description: checkReturnType?
    let tracking: checkReturnType?
    let lst_price: checkReturnType?
    let standard_price: checkReturnType?
    let image:  checkReturnType?

    let product_tmpl_id: [checkReturnType]?
    let categ_id: [checkReturnType]?
    let pos_categ_id: [checkReturnType]?
    let taxes_id: [checkReturnType]?
    let uom_id: [checkReturnType]?

 
    
}

enum checkReturnType: Codable {
    case string(String)
    case bool(Bool)
    case int(Int)
    case float(Float)
    case double(Double)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
         do {  self = try .string(container.decode(String.self))} catch DecodingError.typeMismatch {
             do {  self = try .bool(container.decode(Bool.self))} catch DecodingError.typeMismatch {
                 do {  self = try .double(container.decode(Double.self))} catch DecodingError.typeMismatch {
                     do {  self = try .float(container.decode(Float.self))} catch DecodingError.typeMismatch {
                         do {  self = try .int(container.decode(Int.self))} catch DecodingError.typeMismatch {
                            
                                            throw DecodingError.typeMismatch(checkReturnType.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Encoded payload not of an expected type"))
                        }}}}}
        
//        do {  self = try .string(container.decode(String.self))} catch DecodingError.typeMismatch {
//
//            do {  self = try .bool(container.decode(Bool.self)) }
//
//            catch DecodingError.typeMismatch {
//                throw DecodingError.typeMismatch(checkReturnType.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Encoded payload not of an expected type"))
//            }
//        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .bool(let bool):  try container.encode(bool)
        case .string(let string):  try container.encode(string)
        case .int(let int):  try container.encode(int)
        case .float(let float):  try container.encode(float)
        case .double(let double):  try container.encode(double)
            
        }
    }
}

*/
