//
//  posConfigClass.swift
//  pos
//
//  Created by khaled on 8/22/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

struct peerConfig: Codable {
 
    var messageType:Int = 0
    var id : Int = 0
    var name : String?
    var logo : String?
    var casherName : String?
    var sliderImages : [Int] = []
    var posUrl : String?
 
    
   static func toClass(json:String) -> peerConfig?
    {
        do {
            let decoded = try JSONDecoder().decode(peerConfig.self, from: Data(json.utf8))
            return decoded
        } catch {
           SharedManager.shared.printLog("Failed to decode JSON")
        }
        
        return nil
    }
    
    func toJson() -> String?
    {
        do {
           let data = try JSONEncoder().encode(self)
           // Print the encoded JSON data
           if let jsonString = String(data: data, encoding: .utf8) {
              return jsonString
           }
        } catch _ {
           SharedManager.shared.printLog("Failed to encode JSON")
        }
        
        return nil
    }
   
   
}
