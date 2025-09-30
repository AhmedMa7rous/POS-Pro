//
//  SubCashierDevice.swift
//  pos
//
//  Created by M-Wageh on 22/08/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation

class SubCashierDevice:AddDevicesFactorProtocol{
    func getSelectDataList(data: [account_journal_class]) {
        
    }
    
    var listField: [DeviceFieldModel]
    var socketDeviceModel:socket_device_class?
    let API:api?
    init(socketDeviceModel:socket_device_class?) {
        self.API = api()
        self.listField = []
        self.socketDeviceModel = socketDeviceModel
        initalizeFieldList()
    }
    private func initalizeFieldList(){
        let nameString = "Name".arabic("اسم الجهاز")

         listField.append(DeviceFieldModel(title: nameString,
                                            hint: nameString,
                                            value:socketDeviceModel?.name ?? "",
                                            fieldType: .NAME))
        let ipString = "Addtional Cashier IP".arabic("IP الكاشير الاضافي")
        listField.append(DeviceFieldModel(title: ipString,
                                          hint: ipString,
                                          value:socketDeviceModel?.device_ip ?? "",
                                          fieldType: .IP))
        
    }
    
    func reloadDeviceFactor(isBLe: Bool?) {
        
    }
    
    func reloadDeviceFactor(connectionType: ConnectionTypes) {
        
    }
    
    func reloadDeviceFactor(fieldType: DEVICE_FIELD_TYPES) {
        
    }
    
    func saveEditDevice(with completionHandler: ((String?,Bool?)->Void)?)
    {
        self.checkNameField()
        if let error = getErrorMessage(isEditing: socketDeviceModel != nil) {
            completionHandler?(error,false)
            return
        }
        socketDeviceModel = getSocketDeviceToSave()
        
        if let newSocketDeviceModel = socketDeviceModel {
            newSocketDeviceModel.save()
            completionHandler?("",true)
            return
        }
        completionHandler?("Error Hapen",false)
    }
    private func getSocketDeviceToSave() -> socket_device_class{
        var new_device =  socket_device_class(from: [:])
        
        if let socketDeviceModel = self.socketDeviceModel {
            new_device = socketDeviceModel
            setValues(for: new_device)
            return new_device
        }
        new_device.order_type_ids = []
        new_device.device_status = SOCKET_DEVICE_STATUS.ACTIVE
        new_device.type = DEVICES_TYPES_ENUM.SUB_CASHER
        setValues(for: new_device)
        return new_device
    }
   func setValues(for comingDevice:socket_device_class ){
       listField.forEach { deviceFieldModel in
           if deviceFieldModel.fieldType == .IP {
               comingDevice.device_ip = deviceFieldModel.value
           }
           if deviceFieldModel.fieldType == .NAME {
               comingDevice.name = deviceFieldModel.value
           }
       }
    }
    
}
