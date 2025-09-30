//
//  DevicesFactorProtocol.swift
//  pos
//
//  Created by M-Wageh on 21/08/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation


protocol AddDevicesFactorProtocol:class {
    var listField: [DeviceFieldModel] {get set}
    
    func reloadDeviceFactor(isBLe:Bool?)
    func reloadDeviceFactor(connectionType: ConnectionTypes)
    func reloadDeviceFactor(fieldType: DEVICE_FIELD_TYPES)
    func saveEditDevice(with completionHandler: ((String?,Bool?)->Void)?  )
    func setValues(for comingDevice:socket_device_class )
//    func getSelectDataList(data: [account_journal_class])
}



extension AddDevicesFactorProtocol {
    func checkNameField() {
        var tempValue: String = ""
        if (listField.firstIndex(where: {$0.fieldType == .IP}) != nil) {
            tempValue  = listField[listField.firstIndex(where: {$0.fieldType == .IP}) ?? 2].value
        } else if (listField.firstIndex(where: {$0.fieldType == .USBPort}) != nil) {
            tempValue  = listField[listField.firstIndex(where: {$0.fieldType == .USBPort}) ?? 2].value
        } else if (listField.firstIndex(where: {$0.fieldType == .BLE_SSD}) != nil) {
            tempValue  = listField[listField.firstIndex(where: {$0.fieldType == .BLE_SSD}) ?? 2].value
        }
        let nameFiled  = listField[listField.firstIndex(where: {$0.fieldType == .NAME}) ?? 0]
        if nameFiled.fieldType == .NAME {
            if nameFiled.value.isEmpty && !tempValue.isEmpty {
                listField[listField.firstIndex(where: {$0.fieldType == .NAME}) ?? 0].value = tempValue
            }
        }
    }
    func checkNameAndIpFields() -> Bool {
        let nameIndex = listField.firstIndex(where: {$0.fieldType == .NAME}) ?? 0
        var nameValue = listField[nameIndex].value
        
        let ipIndex = listField.firstIndex(where: {$0.fieldType == .IP}) ?? 1
        let ipValue = listField[ipIndex].value
        
        let isNameValid = verifyName(test: nameValue)
        let isIPValid = verifyWholeIP(test: ipValue)
        
        if isNameValid && isIPValid  {
            return true
        } else {
            return false
        }
    }

    func verifyWholeIP(test: String) -> Bool {
        let pattern_2 = "(25[0-5]|2[0-4]\\d|1\\d{2}|\\d{1,2})\\.(25[0-5]|2[0-4]\\d|1\\d{2}|\\d{1,2})\\.(25[0-5]|2[0-4]\\d|1\\d{2}|\\d{1,2})\\.(25[0-5]|2[0-4]\\d|1\\d{2}|\\d{1,2})"
        let regexText_2 = NSPredicate(format: "SELF MATCHES %@", pattern_2)
        return regexText_2.evaluate(with: test)
    }
    
    func verifyWhileTyping(test: String) -> Bool {
        let pattern_1 = "^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])[.]){0,3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])?$"
        let regexText_1 = NSPredicate(format: "SELF MATCHES %@", pattern_1)
        return regexText_1.evaluate(with: test)
    }
    func verifyName(test: String) -> Bool {
        let pattern = "^[\\w\\s]+$"
        let regexName = NSPredicate(format: "SELF MATCHES %@", pattern)
        return regexName.evaluate(with: test)
    }

    
    func getErrorMessage(isEditing:Bool) -> String?{
       let listError = self.listField.map { filedModel -> String? in
           let error = filedModel.fieldType.isFieldValid(with: filedModel.value,isEditing:isEditing)
           if error != "" {
               return error
           }
           
           return nil
       }.compactMap({$0})
      
       return listError.count > 0 ? listError.joined(separator: " \n ") : nil
    }
    func setValue(for index:Int,value:String? = nil,valuesDic:[[String:Any]]? = nil){
            if let value = value{
                self.listField[index].value = value
            }
            if let valuesDic = valuesDic{
                self.listField[index].valuesDic = valuesDic
            }
    }
    func setValue(for fieldType:DEVICE_FIELD_TYPES,value:String? = nil,valuesDic:[[String:Any]]? = nil){
        if let index = self.listField.firstIndex(where:{$0.fieldType == fieldType}){
            if let value = value{
                self.listField[index].value = value
            }
            if let valuesDic = valuesDic{
                self.listField[index].valuesDic = valuesDic
            }
        }
    }
    
    
    func getValue(for fieldType:DEVICE_FIELD_TYPES) -> String?{
        if let index = self.listField.firstIndex(where:{$0.fieldType == fieldType}){
            let value = self.listField[index].value
            if fieldType == .TYPE_PRINTER{
                return DEVICES_TYPES_ENUM.getTypeFrom(value:value ).rawValue
            }
            if !value.isEmpty {
                return value
            }
           
        }
        return nil
    }
    func getValue(for fieldType:DEVICE_FIELD_TYPES) -> [[String:Any]]?{
        if let index = self.listField.firstIndex(where:{$0.fieldType == fieldType}){
            if let valuesDic = self.listField[index].valuesDic{
                return valuesDic
            }
        }
        return nil
    }

}




