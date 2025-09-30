//
//  GeideaDevice.swift
//  pos
//
//  Created by Muhammed Elsayed on 08/02/2024.
//  Copyright © 2024 khaled. All rights reserved.
//

import Foundation
class GeideaDevice:AddDevicesFactorProtocol{
    func reloadDeviceFactor(connectionType: ConnectionTypes) {
        
    }
    
    func reloadDeviceFactor(fieldType: DEVICE_FIELD_TYPES) {
        
    }
    
    var listField: [DeviceFieldModel]
    var socketDeviceModel:socket_device_class?
    let API:api?
    var setting: settingClass?
    var paymentDeviceProtocol:PaymentDeviceProtocol?
    var device_type:DEVICE_PAYMENT_TYPES = DEVICE_PAYMENT_TYPES.GEIDEA
    var selectDataList:[account_journal_class]?
    init(socketDeviceModel:socket_device_class?) {
        self.API = api()
        self.listField = []
        self.socketDeviceModel = socketDeviceModel
        initalizeFieldList()
        reloadDeviceFactor(isBLe: false)
        paymentDeviceProtocol = GeideaInteractor.shared 
        setting = SharedManager.shared.appSetting()
    }
    private func initalizeFieldList(){
        let nameString = "Device Name".arabic("اسم الجهاز")
        let ipString = "Device IP".arabic("IP الجهاز")
        let paymentMethodtring = "Payment Methods".arabic("طرق الدفع")
        let orderTypeHintString = "ALL".arabic("الكل")
        var valuesDeliveryDic:[[String:Any]] = []
        var defaultValue:String = ""
        let selectedIDS = socketDeviceModel?.get_account_journal_ids() ?? []
        if selectedIDS.count > 0{
             valuesDeliveryDic = account_journal_class.get(ids: selectedIDS)
            defaultValue =  socketDeviceModel?.getPaymentMethodsArray(ids: selectedIDS).joined(separator: ",") ?? ""
        }
            

         listField.append(DeviceFieldModel(title: nameString,
                                            hint: nameString,
                                            value:socketDeviceModel?.name ?? "",
                                            fieldType: .NAME))
        listField.append(DeviceFieldModel(title: ipString,
                                          hint: ipString,
                                          value:socketDeviceModel?.device_ip ?? "",
                                          fieldType: .GEIDEA_IP))
        listField.append(DeviceFieldModel(title: paymentMethodtring ,
                                           hint: orderTypeHintString,
                                          value:defaultValue,
                                           fieldType: .PAYMENT_METHODS,
                                          valuesDic: (valuesDeliveryDic.count > 0 ? valuesDeliveryDic : nil)))
    }
    func reloadDeviceFactor(isBLe: Bool?) {
        
    }
    
    func getSelectDataList(data: [account_journal_class]) {
        self.selectDataList = data
    }
    
    func saveEditDevice(with completionHandler: ((String?,Bool?)->Void)?)
    {
        if !checkNameAndIpFields() {
            completionHandler?("Invalid data entry",false)
            return
        }
        if let error = getErrorMessage(isEditing: socketDeviceModel != nil) {
            completionHandler?(error,false)
            return
        }
        socketDeviceModel = getSocketDeviceToSave()
        if let newSocketDeviceModel = socketDeviceModel {
            
            setting?.ingenico_ip = newSocketDeviceModel.device_ip ?? ""
            setting?.ingenico_name = newSocketDeviceModel.name ?? ""
            setting?.port_geidea = 6100
            setting?.save()
//            account_journal_class.rest_is_support_geidea()
//            account_journal_class.set_is_support_geidea(for: self.selectDataList  ?? [])

            newSocketDeviceModel.save()
            completionHandler?("",true)
            return
            
        }
        completionHandler?("Error Hapen",false)
    }
    private func getSocketDeviceToSave() -> socket_device_class{
        var new_device =  socket_device_class(from: [:])
        new_device.type = DEVICES_TYPES_ENUM.GEIDEA
        if let socketDeviceModel = self.socketDeviceModel {
            new_device = socketDeviceModel
        }
        setValues(for:new_device )
        return new_device
    }
    func setValues(for comingDevice:socket_device_class ){
        listField.forEach { deviceFieldModel in
            if deviceFieldModel.fieldType == .NAME {
                comingDevice.name = deviceFieldModel.value
            }
            if deviceFieldModel.fieldType == .GEIDEA_IP {
                comingDevice.device_ip = deviceFieldModel.value
            }
            if deviceFieldModel.fieldType == .PAYMENT_METHODS {
                let selectOrderTypes:[[String:Any]] = deviceFieldModel.valuesDic ?? []
               let selectAccounts = selectOrderTypes.compactMap({account_journal_class(fromDictionary: $0)})
                account_journal_class.rest_is_support_geidea()
                account_journal_class.set_is_support_geidea(for:selectAccounts)
                if selectOrderTypes.count > 0 {
                    comingDevice.account_journal_ids = selectOrderTypes.map(){return $0["id"] as? Int }.compactMap({$0})
                }else{
                    comingDevice.account_journal_ids = account_journal_class.get_bank_account()?.map(){return $0.id} ?? []
                }
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
