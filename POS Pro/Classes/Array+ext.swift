//
//  Array+ext.swift
//  pos
//
//  Created by Khaled on 4/16/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import UIKit

extension Array {
    
    func getIndex(_ Index:Int) -> Any?
    {
        if self.count == 0
        {
            return nil
        }
        
        return self[Index]
    }
    
    func toString() -> String?
    {
        guard let data = try? JSONSerialization.data(withJSONObject: self, options: .fragmentsAllowed) else {
            return nil
        }
        var str =  String(data: data, encoding: .utf8)
        
        if str != nil
        {
            str = str?.replacingOccurrences(of: "[", with: "")
            str = str?.replacingOccurrences(of: "]", with: "")
        }


        return str
    }
    
    
    func toJsonString() -> String?
    {
        do {
         let data = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted) 
        return String(data: data, encoding: .utf8)
        }catch let error as NSError {
            SharedManager.shared.printLog(error)
        }
        return nil
    }
    
    func to_array(json:String) -> [Any]?
    {
        let data = json.data(using: .utf8)!

        do {
            if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [Dictionary<String,Any>]
            {
                return jsonArray
//               SharedManager.shared.printLog(jsonArray) // use the json here
            } else {
               SharedManager.shared.printLog("bad json")
            }
        } catch let error as NSError {
            SharedManager.shared.printLog(error)
        }
        
        return nil
    }
    func unique<T:Hashable>(map: ((Element) -> (T)))  -> [Element] {
           var set = Set<T>() //the unique list kept in a Set for fast retrieval
           var arrayOrdered = [Element]() //keeping the unique list of elements but ordered
           for value in self {
               if !set.contains(map(value)) {
                   set.insert(map(value))
                   arrayOrdered.append(value)
               }
           }

           return arrayOrdered
       }
    
}
