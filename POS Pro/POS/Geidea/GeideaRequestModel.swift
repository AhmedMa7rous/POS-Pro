//
//  GeideaRequestModel.swift
//  pos
//
//  Created by M-Wageh on 12/06/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation
struct GeideaRequestModel {
    var device_ip: String {
            set{
                
            }
            get{
                let gediaDevices = socket_device_class.getSocketDevices(for: [DEVICES_TYPES_ENUM.GEIDEA])
                if let gediaDevice = gediaDevices.first  {
                    return gediaDevice.device_ip ?? SharedManager.shared.appSetting().ingenico_ip
                }else{
                    return SharedManager.shared.appSetting().ingenico_ip
                }
            }
        }
    var device_port: Int {
            set{
                
            }
            get{
                return SharedManager.shared.appSetting().port_geidea
            }
        }
    var device_terminal: String {
               set{
                   
               }
               get{
                   return SharedManager.shared.appSetting().terminalID_geidea
               }
           }
    var amount:String = ""
    var msg_id:String = "PUR"
    var ecr_no:String = ""
    var ecr_receipt_no:String = ""
    var field1:String = ""
    var field2:String = ""
    var field3:String = ""
    var field4:String = ""
    var field5:String = ""
    
    init(){
        device_ip = SharedManager.shared.appSetting().ingenico_ip
        device_port = SharedManager.shared.appSetting().port_geidea
    }
}
