//
//  MWPrinterMigration.swift
//  pos
//
//  Created by M-Wageh on 19/02/2023.
//  Copyright © 2023 khaled. All rights reserved.
//

import Foundation
class MWPrinterMigration{
    static let shared = MWPrinterMigration()
    private init(){
        
    }
    
    func setDefaultForMultibrandPrinterSetting(){
        DispatchQueue.global(qos: .background).async {
            if !(SharedManager.shared.appSetting().enable_support_multi_printer_brands) {
                let printerInfo  = self.getCurrentPrinterInfo()
                let namePrinter = printerInfo.name
                let ipPrinter = printerInfo.ip
                if namePrinter.isEmpty &&  ipPrinter.isEmpty {
                    SharedManager.shared.appSetting().enable_support_multi_printer_brands = true
                    SharedManager.shared.appSetting().save()
                }else{
                    MWPrinterMigration.shared.migrationOldPOS()
                    SharedManager.shared.appSetting().enable_support_multi_printer_brands = true
                    SharedManager.shared.appSetting().save()

                }
            }
        }
    }
    
    func getCurrentPrinterInfo()->(ip:String,name:String){
        let printerIp  = cash_data_class.get(key: "setting_ip") ?? ""
        let printerName  = cash_data_class.get(key: "setting_name") ?? ""
        return(ip:printerIp,name:printerName)
    }
    func setCurrentPrinter(name:String,ip:String){
        cash_data_class.set(key: "setting_ip", value: ip)
        cash_data_class.set(key: "setting_name", value: name)
    }
    
    func migrationOldPOS(){
        DispatchQueue.global(qos: .background).async {
            let printerInfo  = self.getCurrentPrinterInfo()
            var printerName = printerInfo.name
            let printerIp = printerInfo.ip
            if printerIp.isEmpty {
                return
            }
            if printerName.isEmpty {
                printerName = printerIp
            }
            self.createMWPrinter(name: printerName, ip:  printerIp, type: .POS_PRINTER)
            self.setCurrentPrinter(name: "" , ip: "")
            restaurant_printer_class.setAvailableInPos()
        }
    }
    func migrationNewPOS()  {
        DispatchQueue.global(qos: .background).async {
            let existPrinterPOS = restaurant_printer_class.get(printer_type:.POS_PRINTER)
            if existPrinterPOS.count > 0 {
                let epsonPrinter = existPrinterPOS.filter({$0.brand?.lowercased() == "epson"})
                if epsonPrinter.count > 0 {
                    if let printerPOS = epsonPrinter.first {
                        self.setCurrentPrinter(name: printerPOS.name  , ip: printerPOS.printer_ip )
                        self.deletPrinterAPI(printer: printerPOS)
                    }
                }
            }
        }
    }
    private func checkPrinterIsExist(ip:String,type:DEVICES_TYPES_ENUM) -> Bool{
        if let existPrinterIp = restaurant_printer_class.get(ip:ip ){
            if existPrinterIp.type.rawValue == type.rawValue {
                return true
            }
        }
        return false
    }
    private func createMWPrinter(name:String,ip:String,type:DEVICES_TYPES_ENUM){
        if !checkPrinterIsExist(ip: ip, type: type) {
            let new_printer =  restaurant_printer_class(fromDictionary: [:])
            new_printer.name  = name
            new_printer.display_name =  name
            new_printer.printer_ip = ip
            new_printer.type = type
            new_printer.brand = "EPSON"
            new_printer.model  = "TM_T20"
            new_printer.config_ids = [SharedManager.shared.posConfig().id]//selectPosConfig.map(){return $0.id}
            new_printer.company_id = SharedManager.shared.posConfig().company_id ?? 0
            new_printer.__last_update = baseClass.get_date_now_formate_datebase()
            new_printer.available_in_pos = SharedManager.shared.posConfig().id
            new_printer.server_id = 0
//            createRestaurantPrinterAPI(printer:new_printer)
            self.createRestaurantPrinterAPI(printer: new_printer)
        }
        
        
        /**
         if deviceFieldModel.fieldType == .CATEGORY {
         let selectCategories = deviceFieldModel.valuesDic ?? []
         if selectCategories.count > 0 {
         new_printer.product_categories_ids = selectCategories.map(){return $0["id"] as? Int }.compactMap({$0})
         }else{
         new_printer.product_categories_ids = pos_category_class.getAll().map(){pos_category_class(fromDictionary: $0)}.map(){return $0.id}
         
         }
         }
         if deviceFieldModel.fieldType == .ORDER_TYPES {
         let selectOrderTypes = deviceFieldModel.valuesDic ?? []
         if selectOrderTypes.count > 0 {
         new_printer.order_type_ids = selectOrderTypes.map(){return $0["id"] as? Int }.compactMap({$0})
         }else{
         new_printer.order_type_ids = delivery_type_class.getAll().map(){delivery_type_class(fromDictionary: $0)}.map(){return $0.id}
         
         }
         }
         
         */
    }
    private func deletPrinterAPI(printer:restaurant_printer_class){
        DispatchQueue.global(qos: .background).async {
        SharedManager.shared.conAPI().new_delete_restaurant_printer(printer: printer) { result in
            printer.delete()
        }
        }
    }
    private func createRestaurantPrinterAPI(printer:restaurant_printer_class){
        if AppDelegate.shared.enable_debug_mode_code() == true
        {
            
                return
           
        }
        DispatchQueue.global(qos: .background).async {
        SharedManager.shared.conAPI().new_create_restaurant_printer(printer: printer) { result in
            if (result.success )
            {
                let id = result.response!["result"] as?  Int ?? 0
                if id != 0
                {
                    printer.server_id = id
                    printer.save()
                }
            }
        }
        }
    }
}
