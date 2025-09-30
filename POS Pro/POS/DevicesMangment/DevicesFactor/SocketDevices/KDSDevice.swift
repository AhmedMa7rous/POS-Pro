//
//  KDSDevice.swift
//  pos
//
//  Created by M-Wageh on 22/08/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation
class KDSDevice:AddDevicesFactorProtocol{
    func getSelectDataList(data: [account_journal_class]) {
        
    }
    
    var dataSourceListField: [DeviceFieldModel]
    var listField: [DeviceFieldModel]
    var socketDeviceModel:socket_device_class?
    let API:api?
    init(socketDeviceModel:socket_device_class?) {
        self.API = api()
        self.listField = []
        dataSourceListField = []
        self.socketDeviceModel = socketDeviceModel
        initalizeFieldList()
    }
    private func initalizeFieldList(){
        let ipString = "KDS IP".arabic("IP المطبخ ")
        let statusDevice = "Status".arabic("الحاله")
        let orderTypeString = "Order Type ".arabic(" نوع الطلب")
        let orderTypeHintString = "ALL".arabic("الكل")
        let nameString = "Name".arabic("اسم الجهاز")
        let activeString = "Active Status".arabic("حاله الجهاز")

         listField.append(DeviceFieldModel(title: nameString,
                                            hint: nameString,
                                            value:socketDeviceModel?.name ?? "",
                                            fieldType: .NAME))
        listField.append(DeviceFieldModel(title: ipString,
                                          hint: ipString,
                                          value:socketDeviceModel?.device_ip ?? "",
                                          fieldType: .IP))
        listField.append(DeviceFieldModel(title: activeString,
                                          hint: activeString,
                                          value:"\(socketDeviceModel?.device_status?.rawValue ?? 0)",
                                          fieldType: .SOCKET_STATUS_DEVICE))

        appendOrderTypeAndCateory()
        /*
        listField.append(DeviceFieldModel(title: statusDevice,
                                          hint: statusDevice,
                                          value:socketDeviceModel?.device_status?.getDescription() ?? "",
                                          fieldType: .SOCKET_STATUS_DEVICE))
        
        let valuesDeliveryDic = delivery_type_class.get(ids: socketDeviceModel?.get_order_type_ids() ?? [] )
        listField.append(DeviceFieldModel(title: orderTypeString ,
                                           hint: orderTypeHintString,
                                           value:socketDeviceModel?.getOrderNamesArray().joined(separator: ",") ?? "",
                                           fieldType: .ORDER_TYPES,
                                          valuesDic: valuesDeliveryDic.count > 0 ? valuesDeliveryDic : nil ))
*/
    }
    private func appendOrderTypeAndCateory(){
        let categoryString = "Categories ".arabic(" التصنيفات")
        let orderTypeString = "Order Type ".arabic(" نوع الطلب")

        let categoryHintString = "ALL".arabic("الكل")
        let orderTypeHintString = "ALL".arabic("الكل")
        
        let valuesCategoryDic = pos_category_class.get(ids: socketDeviceModel?.get_product_categories_ids() ?? [] )
        let valuesDeliveryDic = delivery_type_class.get(ids: socketDeviceModel?.get_order_type_ids() ?? [] )
        listField.append(DeviceFieldModel(title: orderTypeString ,
                                           hint: orderTypeHintString,
                                           value:socketDeviceModel?.getOrderNamesArray().joined(separator: ",") ?? "",
                                           fieldType: .ORDER_TYPES,
                                          valuesDic: valuesDeliveryDic.count > 0 ? valuesDeliveryDic : nil ))
        listField.append(DeviceFieldModel(title: categoryString ,
                                           hint: categoryHintString,
                                           value:socketDeviceModel?.getCategoriesNamesArray().joined(separator: ",") ?? "",
                                           fieldType: .CATEGORY,
                                          valuesDic: valuesCategoryDic.count > 0 ? valuesCategoryDic : nil ))

    }
    
    func reloadDeviceFactor(isBLe: Bool?) {
        
    }
    
    func reloadDeviceFactor(fieldType: DEVICE_FIELD_TYPES) {
        
    }
    
    func reloadDeviceFactor(connectionType: ConnectionTypes) {
        
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
        new_device.type = DEVICES_TYPES_ENUM.KDS
        if let socketDeviceModel = self.socketDeviceModel {
            new_device = socketDeviceModel
        }
        setValues(for:new_device )
        return new_device
    }
    func setValues(for comingDevice:socket_device_class ){
        listField.forEach { deviceFieldModel in
            if deviceFieldModel.fieldType == .IP {
                comingDevice.device_ip = deviceFieldModel.value
            }
            if deviceFieldModel.fieldType == .ORDER_TYPES {
                let selectOrderTypes = deviceFieldModel.valuesDic ?? []
                if selectOrderTypes.count > 0 {
                    comingDevice.order_type_ids = selectOrderTypes.map(){return $0["id"] as? Int }.compactMap({$0})
                }else{
                    comingDevice.order_type_ids = delivery_type_class.getAll().map(){delivery_type_class(fromDictionary: $0)}.map(){return $0.id}
                   
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
            if deviceFieldModel.fieldType == .NAME {
                comingDevice.name = deviceFieldModel.value
            }
            if deviceFieldModel.fieldType == .CATEGORY {
                let selectCategories = deviceFieldModel.valuesDic ?? []
                if selectCategories.count > 0 {
                    comingDevice.product_categories_ids = selectCategories.map(){return $0["id"] as? Int }.compactMap({$0})
                }else{
                    comingDevice.product_categories_ids = pos_category_class.getAll().map(){pos_category_class(fromDictionary: $0)}.map(){return $0.id}
                   
                }
            }
            
           
        }
    }
    
}
