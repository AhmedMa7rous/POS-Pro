//
//  load_base_apis + app_setting.swift
//  pos
//
//  Created by  Mahmoud Wageh on 4/21/21.
//  Copyright © 2021 khaled. All rights reserved.
//

import Foundation
//MARK:- create settings with Sync data
extension load_base_apis{
    func create_settings()
    {
        var allGeneralSetting :[[String:Any]] = []
        for keySetting in SETTING_KEY.allCases {
            let objcSetting = keySetting.initGeneralSetting()
            objcSetting.save()
            allGeneralSetting.append(objcSetting.toDictionary())
            }
        if allGeneralSetting.count > 0 {
            let item_key = "create_settings" ;
            if localCash?.isTimeTopdate(item_key) == false  {
                _ = self.handleUI(item_key: item_key, result: nil)
                self.runQueue()
                return
            }
            if !SharedManager.shared.appSetting().link_setting_with_odoo_2 {
                _ = self.handleUI(item_key: item_key, result: nil)
                self.runQueue()
                return
            }
            con!.hitCreateGeneralSettingAPI(appSetting: allGeneralSetting) {   (result) in
                let _ = self.handleUI(item_key: item_key, result: result)
                self.runQueue()
            }
        }
    }
    func create_pos_settings()
    {
        var allPOSSetting :[[String:Any]] = []
        for keySetting in SETTING_KEY.allCases {
            let objcSetting = keySetting.initPosSetting()
            objcSetting.save()
            allPOSSetting.append(objcSetting.toDictionary())
            }
        if allPOSSetting.count > 0 {
            let item_key = "create_pos_settings" ;
            if localCash?.isTimeTopdate(item_key) == false  {
                _ = self.handleUI(item_key: item_key, result: nil)
                self.runQueue()
                return
            }
            if !SharedManager.shared.appSetting().link_setting_with_odoo_2 {
                _ = self.handleUI(item_key: item_key, result: nil)
                self.runQueue()
                return
            }
            con!.hitCreateGeneralSettingAPI(appSetting: allPOSSetting) {   (result) in
                let _ = self.handleUI(item_key: item_key, result: result)
                self.runQueue()
            }
        }
    }
    func get_settings()
    {
        let item_key = "get_setting" ;
        if localCash?.isTimeTopdate(item_key) == false  {
            _ = self.handleUI(item_key: item_key, result: nil)
            self.runQueue()
            return
        }
        if !SharedManager.shared.appSetting().link_setting_with_odoo_2 {
            _ = self.handleUI(item_key: item_key, result: nil)
            self.runQueue()
            return
        }
        
        con!.hitGetSettingAPI { (result) in
            let saveInDataBase = self.handleUI(item_key: item_key, result: result)
            if saveInDataBase
            {
                let result: [[String:Any]]   =  result.response?["result"] as? [[String:Any]] ?? []
                if result.count > 0 {
                    ios_settings.reset()
                    ios_settings.saveAll(arr: result)
                    SettingAppInteractor.shared.updateCashedSettingValue(result)
                    self.localCash?.setTimelastupdate(item_key)
                }else{
                    
                }
 
               
                
            }
            
            self.runQueue()
            
        }
    }
}
