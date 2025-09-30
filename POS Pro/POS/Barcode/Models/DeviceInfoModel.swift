//
//  DeviceInfoModel.swift
//  pos
//
//  Created by M-Wageh on 16/03/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation
class DeviceInfoModel {
    var model:String = ""
    var status:String = ""
    var captureVersion:String?
    var isNFCSupport:Bool?
    var battery:String?
    var dic:[[String:String]] = [[:]]
    
    func toDictionary()->[[String:String]]{
        var dic_array:[[String:String]] = []
        dic_array.append(["Model":model])
        dic_array.append(["Status":status])
        if let captureVersion = captureVersion {
            dic_array.append(["Version":captureVersion])
        }
        if let battery = battery {
            dic_array.append(["Battery":battery])
        }
       
        return dic_array
    }
}
