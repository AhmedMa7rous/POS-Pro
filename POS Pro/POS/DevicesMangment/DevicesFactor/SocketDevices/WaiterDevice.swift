//
//  WaiterDevice.swift
//  pos
//
//  Created by M-Wageh on 16/03/2023.
//  Copyright © 2023 khaled. All rights reserved.
//

import Foundation

class WaiterDevice:AddDevicesFactorProtocol{
    func reloadDeviceFactor(connectionType: ConnectionTypes) {
        
    }
    
    func reloadDeviceFactor(fieldType: DEVICE_FIELD_TYPES) {
        
    }
    
    var listField: [DeviceFieldModel]
    var socketDeviceModel:socket_device_class?
    let API:api?
    init(socketDeviceModel:socket_device_class?) {
        self.API = api()
        self.listField = []
        self.socketDeviceModel = socketDeviceModel
        initalizeFieldList()
        reloadDeviceFactor(isBLe: false)
    }
    private func initalizeFieldList(){
        let nameString = "Name".arabic("اسم الجهاز")
        let activeString = "Active Status".arabic("حاله الجهاز")


         listField.append(DeviceFieldModel(title: nameString,
                                            hint: nameString,
                                            value:socketDeviceModel?.name ?? "",
                                            fieldType: .NAME))
        let ipString = "Waiter IP".arabic("IP  الويتر")
        listField.append(DeviceFieldModel(title: ipString,
                                          hint: ipString,
                                          value:socketDeviceModel?.device_ip ?? "",
                                          fieldType: .IP))
        
        listField.append(DeviceFieldModel(title: activeString,
                                          hint: activeString,
                                          value:"\(socketDeviceModel?.device_status?.rawValue ?? 0)",
                                          fieldType: .SOCKET_STATUS_DEVICE))

        
    }
    func reloadDeviceFactor(isBLe: Bool?){
    }
    func getSelectDataList(data: [account_journal_class]) {
        
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
        new_device.type = DEVICES_TYPES_ENUM.WAITER
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
           if deviceFieldModel.fieldType == .SOCKET_STATUS_DEVICE {
               let selectStatus = deviceFieldModel.value
               if selectStatus.isEmpty
               {
                   comingDevice.device_status = SOCKET_DEVICE_STATUS.ACTIVE

               }else{
                   comingDevice.device_status = SOCKET_DEVICE_STATUS.get(value:selectStatus )
               }
           }
       }
    }
    
}
