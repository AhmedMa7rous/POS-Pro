//
//  EmptyFactoryDevice.swift
//  pos
//
//  Created by M-Wageh on 22/08/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation
class EmptyFactoryDevice:AddDevicesFactorProtocol{
    func getSelectDataList(data: [account_journal_class]) {
        
    }
    
    var dataSourceListField: [DeviceFieldModel]
    
    
    
   
    
    var listField: [DeviceFieldModel]
    init() {
        listField = []
        dataSourceListField = []
    }
    
    func reloadDeviceFactor(isBLe: Bool?) {
        
    }
    
    func reloadDeviceFactor(fieldType: DEVICE_FIELD_TYPES) {
        
    }
    
    func reloadDeviceFactor(connectionType: ConnectionTypes) {
        
    }
    func saveEditDevice(with completionHandler: ((String?, Bool?) -> Void)?) {
        completionHandler?("",true)
    }
    func setValues(for comingDevice: socket_device_class) {
        
    }
    
}
