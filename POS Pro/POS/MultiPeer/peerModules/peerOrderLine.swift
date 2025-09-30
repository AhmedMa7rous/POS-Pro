//
//  posOrderLineClass.swift
//  pos
//
//  Created by Khaled on 4/20/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import UIKit
 
struct peerOrderLine: Codable {
 
    
    
    var qty : String = ""
    var productName : String = ""
    var productPrice : String = ""
    var productNote : String = ""
    var is_combo_line:Bool = false
    var selected_products_in_combo:[peerOrderLine] = []
    var void:Bool = false

   
    
    static func toClass(json:String) -> peerOrderLine?
     {
         do {
             let decoded = try JSONDecoder().decode(peerOrderLine.self, from: Data(json.utf8))
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
