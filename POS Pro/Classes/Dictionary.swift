//
//  Dictionary.swift
//  pos
//
//  Created by khaled on 8/6/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import Foundation
extension Dictionary {
    var jsonData: Data? {
        do {
        return try JSONSerialization.data(withJSONObject: self, options: [.prettyPrinted])
        } catch (let error) {
            SharedManager.shared.printLog(error)
                    return nil
                }
        }
    
    func toJSONString() -> String? {
//        if let jsonData = jsonData {
//            let jsonString = String(data: jsonData, encoding: .utf8)
//            return jsonString
//        }
        do {
             let jsonData = try JSONSerialization.data(withJSONObject: self, options: [.prettyPrinted])
             return String(data: jsonData, encoding: .utf8)
        } catch (let error) {
            SharedManager.shared.printLog(error)
        }
        return nil
    }
}
extension Dictionary where Key == String {
    func jsonString() -> String? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self)
        let jsonString = String(data: jsonData, encoding: .utf8)
        guard jsonString != nil else {return nil}
        return jsonString
        } catch (let error) {
            SharedManager.shared.printLog(error)
            return nil
        }
    }
    
   private var json: String {
        let invalidJson = "Not a valid JSON"
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            return String(bytes: jsonData, encoding: String.Encoding.utf8) ?? invalidJson
        } catch {
            return invalidJson
        }
    }
    
    func toString(key:String) -> String! {
        let val = self[key]
        
        return val as? String ?? ""
    }
    
    
    func toInt(key:String) -> Int! {
        let val = self[key]
    
        return val as? Int ?? 0
    }
    
    func toDouble(key:String) -> Double! {
        let val = self[key]
        
        return val as? Double ?? 0
    }
    
    func toBool(key:String) -> Bool! {
        let val = self[key]
        
        return val as? Bool ?? false
    }
    
    func toNSArray(key:String) -> NSArray? {
        let val = self[key]
        
        return val as? NSArray
    }
    
    func toNSDictionary(key:String) ->  NSDictionary?  {
        let val = self[key]
        
        return val as? NSDictionary
    }
    
    func toArray(key:String) -> [Any] {
        let val = self[key]
        
        return val as? [Any] ?? []
    }
    
    func toDictionary(json:String?) -> [String :Any] {
        
        if json == nil ||  (json?.isEmpty ?? false)
        {
           return [:]
        }
        
        if let data = json!.data(using: .utf8) {
             do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] ?? [:]
             } catch {
                 SharedManager.shared.printLog(error.localizedDescription)
             }
         }
        
         return  [:]
    }
    
    mutating func merge(with dictionary: Dictionary) {
        dictionary.forEach { updateValue($1, forKey: $0) }
    }
    
    func merged(with dictionary: Dictionary) -> Dictionary {
        var dict = self
        dict.merge(with: dictionary)
        return dict
    }
    
}
