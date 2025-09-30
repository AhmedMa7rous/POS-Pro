//
//  app_helper.swift
//  pos
//
//  Created by Khaled on 3/1/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import UIKit

class app_helper: NSObject {
    
    public var force_reload_casher_list : Bool = false
    
    
    override init() {
    }
    
    init(fromDictionary dictionary: [String:Any]) {
        
        force_reload_casher_list = dictionary["force_reload_casher_list"] as? Bool ?? false
        
        
    }
    
    public func toDictionary() -> [String:Any] {
        
        var dictionary:[String:Any] = [:]
        dictionary["force_reload_casher_list"] = self.force_reload_casher_list
        
        
        
        return dictionary
    }
    
    func save()
    {
        
        cash_data_class.set(key: "app_helper_class", value: self.toDictionary().jsonString() ?? "")
        //           myuserdefaults.setitems("app_helper", setValue: self.toDictionary(), prefix: className)
        
    }
    
    
    static func getDefault() -> app_helper {
        //            let className:String = "app_helper"
        //           let cls = myuserdefaults.getitem("app_helper", prefix:className) as? [String : Any] ?? [:]
        let cls = cash_data_class.get(key: "app_helper_class") ?? ""
        return app_helper(fromDictionary: cls.toDictionary() ?? [:]  )
    }
}
