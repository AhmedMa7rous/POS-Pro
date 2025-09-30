//
//  navigation_message_type_class.swift
//  pos
//
//  Created by khaled on 29/03/2021.
//  Copyright © 2021 khaled. All rights reserved.
//

import Foundation

public class notifications_messages_class {
    var success:Bool = false
    var message:String = ""
    var date:String = ""
    var title:String = ""
    var icon_name:String = ""
    var key:String = ""

    init(_ _tile:String = "" ,_ _message:String = "" ,_ _date:String = "" ,_ _success:Bool = false,_ _icon_name:String = "" ,_ _key:String = "") {
        self.success = _success
        self.message = _message
        self.title = _tile
        self.date = _date
        self.icon_name = _icon_name
        self.key = _key

    }
    
    init(dic:[String:Any])
    {
       
        self.success =  dic["success"] as? Bool ?? false
        self.message =  dic["message"] as? String ?? ""
        self.title =  dic["title"] as? String ?? ""
        self.date =  dic["date"] as? String ?? ""
        self.icon_name =  dic["icon_name"] as? String ?? ""
        self.key = dic["key"] as? String ?? ""
        
    }
    
    func toJosn() -> [String:Any]
    {
        var dic:[String:Any] = [:]
        dic["message"] = self.message
        dic["date"] = self.date
        dic["success"] = self.success
        dic["title"] = self.title
        dic["icon_name"] = self.icon_name
        dic["key"] = self.key

        return dic
    }
    
    func fromJosn(json:[String:Any]) -> notifications_messages_class {
        
        let type = notifications_messages_class()
        type.success =  json["success"] as? Bool ?? false
        type.message =  json["message"] as? String ?? ""
        type.title =  json["title"] as? String ?? ""
        type.date =  json["date"] as? String ?? ""
        type.icon_name =  json["icon_name"] as? String ?? ""
        
        return type
        
    }
    
    func save()
    {
        notifications_messages_class.save_notification(self)
    }
    
    static  func save_notification(_ type:notifications_messages_class,_ update_exist:Bool = false,_ key:String  = "")  {
        
        var log:logClass?
        
        if update_exist == true
        {
            log = logClass.get(key: key, prefix: "notification")
            log!.key = key

        }
        else {
            log = logClass(fromDictionary: [:])
            log!.key = type.title

        }
        
        log!.prefix =  "notification"
  
        type.key = key
         log!.data = type.toJosn().jsonString()

        log!.save()

    }
    
    static  func alert(tile:String  ,msg:String,date:String  ,   icon_name:String ,success:Bool = false,update_exist:Bool = false ,  key:String  = "")
    {
        if msg.isEmpty
        {
            return
        }
        
 
        let type = notifications_messages_class(tile,msg,date,success, icon_name)
        
        notifications_messages_class.save_notification( type,update_exist,key)
        
        NotificationCenter.default.post(name: Notification.Name("show_aleart"), object:type )
        
    }
    
   
}
