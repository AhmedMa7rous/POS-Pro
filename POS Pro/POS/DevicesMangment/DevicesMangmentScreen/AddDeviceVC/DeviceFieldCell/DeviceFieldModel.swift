//
//  DeviceFieldModel.swift
//  pos
//
//  Created by M-Wageh on 04/06/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation

    
   
class DeviceFieldModel{
    var title:String
    var hint:String
    var value:String
    var fieldType:DEVICE_FIELD_TYPES
    var valuesDic:[[String:Any]]?
    var sort:Int = 0

    init(title:String,hint:String,value:String,fieldType:DEVICE_FIELD_TYPES,valuesDic:[[String:Any]]? = nil,sort:Int = 0) {
        self.title = title
        self.hint = hint
        self.value = value
        self.fieldType = fieldType
        self.valuesDic = valuesDic
        self.sort = sort
    }
}
