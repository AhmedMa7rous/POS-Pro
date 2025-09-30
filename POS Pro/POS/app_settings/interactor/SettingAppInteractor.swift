//
//  SettingAppInteractor.swift
//  pos
//
//  Created by  Mahmoud Wageh on 4/19/21.
//  Copyright © 2021 khaled. All rights reserved.
//

import Foundation
class SettingAppInteractor {
    
    static  var shared = SettingAppInteractor()
    private var API:api?
    private var cash_setting = SharedManager.shared.appSetting().toDictionary()
    private var cash_setting_obj: settingClass {
        get{
            return SharedManager.shared.appSetting()
        }
    }

    private init() {
        API = SharedManager.shared.conAPI()
    }
    
    func getSettingPos(){
        if AppDelegate.shared.enable_debug_mode_code() {
            
           // return
        }

        if !cash_setting_obj.link_setting_with_odoo_2 {
            return
        }
        API?.hitGetSettingAPI { (result) in
            if result.success{
            let result: [[String:Any]]   =  result.response?["result"] as? [[String:Any]] ?? []
            if result.count >= 0 {
            ios_settings.reset()
            ios_settings.saveAll(arr: result)
            self.updateCashedSettingValue(result)
            }
            }

        }
    }
    func setSettingApp(for name:String, with value:String){
//        DispatchQueue.global(qos: .background).async {
        if AppDelegate.shared.enable_debug_mode_code() {
            
           // return
        }
            MWQueue.shared.firebaseQueue.async {

            FireBaseService.defualt.setFRSettingApp(keySetting:name,valueSetting:value)
        }
        if !cash_setting_obj.link_setting_with_odoo_2 {
            return
        }
        
        if let objc = ios_settings.getSettingWith(name:name){
            objc.value = value
            objc.save()
            self.updateCashedSettingValue(objc)
          
            API?.hitSetSettingAPI(for:name, with:value) { (result) in
                if ((result.message?.contains("create it first")) ?? false) {
                    if let keySetting = SETTING_KEY(rawValue: name) {
                        self.createPosSetting(keySetting: keySetting, value: value)
                        
                    }
                }
            }
            
        }else{
            if !cash_setting_obj.link_setting_with_odoo_2 {
                return
            }
            if let keySetting = SETTING_KEY(rawValue: name) {
                let objcSetting = keySetting.initPosSetting()
                objcSetting.value = value
                objcSetting.save()
                self.updateCashedSettingValue(objcSetting)
                
                self.createPosSetting(keySetting: keySetting, value: value)
            }
            
        }
    }
    private func createPosSetting(keySetting: SETTING_KEY,value:String){
        let objcSetting = keySetting.initPosSetting()
        objcSetting.value = value
        let objcGeneralSetting = keySetting.initGeneralSetting()
        objcGeneralSetting.value = value
        API?.hitCreateGeneralSettingAPI(appSetting: [objcSetting.toDictionary(),objcGeneralSetting.toDictionary()]) {   (result) in
            SharedManager.shared.printLog(result)
        }
    }
    private func updateCashedSettingValue(_ item:ios_settings){
        guard  let settingKey = SETTING_KEY(rawValue: item.name)  else {
            return
        }
        if settingKey == SETTING_KEY.default_printer_name {
            updateCashedPrinterSettingValue(name:item.value )
            
        }
        if settingKey == SETTING_KEY.default_printer_ip {
            updateCashedPrinterSettingValue(ip:item.value)
        }
        cash_setting[item.name] = item.value
        cash_data_class.set(key: "settingClass_setting", value: cash_setting.jsonString() ?? "")
    }
     func updateCashedSettingValue(_ items: [[String:Any]]){
        items.forEach { (item) in
            let settingObjc = ios_settings(fromDictionary: item)
            updateCashedSettingValue(settingObjc)
        }
        
    }
     func updateCashedPrinterSettingValue(name: Any? = nil, ip: Any? = nil){
        if let printerName = name as? String {
            cash_data_class.set(key: "setting_name", value: printerName)
        }
        if let printerIp = ip as? String {
            cash_data_class.set(key: "setting_ip", value: printerIp)
        }
        let cashName   = cash_data_class.get(key: "setting_name") ?? ""
        let cashIp  = cash_data_class.get(key: "setting_ip") ?? ""
        if !cashName.isEmpty && !cashIp.isEmpty{
            cash_data_class.set(key: "setting_saved", value: "true")
        }
    }
    
    private func currentSetting(){
        for keySetting in SETTING_KEY.allCases {
            getCashIosSettingFor(keySetting).save()
        }
    }
    
    private func getCashIosSettingFor(_ key:SETTING_KEY) -> ios_settings{
        let cash_setting = SharedManager.shared.appSetting().toDictionary()
        let name = key.rawValue
        let currentValue = cash_setting.count > 0 ? (cash_setting[key.stringKey()] as Any) : key.getDefaultValue()
        let defaultValue = key.getDefaultValue()
        let option = ""
        let type =  key.getType()
        let scope = SCOPE_SETTINGS.pos
        let version = Bundle.main.fullVersion
        let posID = 102
        return ios_settings(name: name,
                            value: currentValue,
                            defaultValue: defaultValue,
                            option: option,
                            type: type,
                            scope: scope,
                            version: version,
                            posID: posID)
    }
}
