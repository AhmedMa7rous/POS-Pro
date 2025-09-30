//
//  ProductAvailabilityModel.swift
//  pos
//
//  Created by DGTERA on 30/07/2024.
//  Copyright © 2024 khaled. All rights reserved.
//

import Foundation

struct ProductAvailabilityResponseModel {
    let jsonrpc: String?
    let id: Int?
    let result: ResultData?
    let error: OdooError?
    
    init(dictionary: [String: Any]) {
        self.jsonrpc = dictionary["jsonrpc"] as? String
        self.id = dictionary["id"] as? Int
        if let resultDict = dictionary["result"] as? [String: Any] {
            self.result = ResultData(dictionary: resultDict)
        } else {
            self.result = nil
        }
        if let errorDict = dictionary["error"] as? [String: Any] {
            self.error = OdooError(dictionary: errorDict)
        } else {
            self.error = nil
        }
    }
}

struct ResultData {
    let storable: [Storable]
    let consumable: [Consumable]
    
    init(dictionary: [String: Any]) {
        if let storableArray = dictionary["storable"] as? [[String: Any]] {
            self.storable = storableArray.map { Storable(dictionary: $0) }
        } else {
            self.storable = []
        }
        if let consumableArray = dictionary["consumable"] as? [[String: Any]] {
            self.consumable = consumableArray.map { Consumable(dictionary: $0) }
        } else {
            self.consumable = []
        }
    }
}

struct Consumable {
    let productID: Int
    let factor: Double
    let relatedStorableProduct: Int
    
    init(dictionary: [String: Any]) {
        self.productID = dictionary["product_id"] as? Int ?? 0
        self.factor = dictionary["factor"] as? Double ?? 0.0
        self.relatedStorableProduct = dictionary["related_storable_product"] as? Int ?? 0
    }
}

struct Storable {
    let productID: Int
    let quantity: Double
    
    init(dictionary: [String: Any]) {
        self.productID = dictionary["product_id"] as? Int ?? 0
        self.quantity = dictionary["quantity"] as? Double ?? 0
    }
}

struct OdooError {
    let code: Int
    let message: String
    let data: OdooErrorData?
    
    init(dictionary: [String: Any]) {
        self.code = dictionary["code"] as? Int ?? 0
        self.message = dictionary["message"] as? String ?? "Unknown error"
        if let dataDict = dictionary["data"] as? [String: Any] {
            self.data = OdooErrorData(dictionary: dataDict)
        } else {
            self.data = nil
        }
    }
}

struct OdooErrorData {
    let name: String
    let debug: String
    let message: String
    let arguments: [String]
    let context: [String: Any]
    
    init(dictionary: [String: Any]) {
        self.name = dictionary["name"] as? String ?? ""
        self.debug = dictionary["debug"] as? String ?? ""
        self.message = dictionary["message"] as? String ?? ""
        self.arguments = dictionary["arguments"] as? [String] ?? []
        self.context = dictionary["context"] as? [String: Any] ?? [:]
    }
}
