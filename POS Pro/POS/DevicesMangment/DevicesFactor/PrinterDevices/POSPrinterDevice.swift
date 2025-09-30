//
//  POSPrinterDevice.swift
//  pos
//
//  Created by M-Wageh on 22/08/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation
class POSPrinterDevice:AddDevicesFactorProtocol{
    func getSelectDataList(data: [account_journal_class]) {
        
    }
    
    var listField: [DeviceFieldModel]
    
    var resturantPrinter:restaurant_printer_class?
    let API:api?
    var typePrinter:DEVICES_TYPES_ENUM?



    init(resturantPrinter:restaurant_printer_class?,type:DEVICES_TYPES_ENUM?) {
        self.API = api()
        self.listField = []
        listField = []
        self.resturantPrinter = resturantPrinter
        self.typePrinter = type
        initalizeFieldList()
        reloadDeviceFactor(isBLe: false)
    }
    
   private func initalizeFieldList(){
        
        let nameString = "Name".arabic("اسم الطابعة")
        let brandString = "Printer Brand".arabic("`براند الطابعة")
        let modelString = "Printer Model".arabic("موديل الطابعة")
        let typeString = "Printer Type".arabic("نوع الطابعة")
       let bleConnection = "Bluetooth Connection".arabic("الإتصال بالبلوتوث")
       let ipString = "Printer IP".arabic("IP الطابعة")
//       let deviceTypeString = "Device Type".arabic("نوع الجهاز")
//       listField.append(DeviceFieldModel(title: deviceTypeString,
//                                          hint: deviceTypeString,
//                                          value: "",
//                                          fieldType: .DEVICE_TYPE))
       //MARK: - Connetion
       let connectionType = "Connection Type".arabic("نوع الإتصال")
       
       listField.append(DeviceFieldModel(title: nameString,
                                          hint: nameString,
                                          value:resturantPrinter?.name ?? "",
                                          fieldType: .NAME,sort: 0))
       
       
       listField.append(DeviceFieldModel(title: connectionType,
                                                   hint: connectionType,
                                         value:  resturantPrinter?.connectionType?.rawValue ?? ConnectionTypes.WIFI.rawValue,
                                                   fieldType: .ConnectionType,sort: 1))
       listField.append(DeviceFieldModel(title: ipString ,
                                          hint: ipString ,
                                          value:resturantPrinter?.printer_ip ?? "",
                                         fieldType: .IP,sort:2))
    
       
       if let editPrinter = self.resturantPrinter{
           self.reloadDeviceFactor(connectionType: editPrinter.connectionType ?? .WIFI)
           self.appendFieldType(fieldType: .BRAND_PRINTER)
           self.appendFieldType(fieldType: .MODEL_PRINTER)
           if( self.typePrinter) ?? .POS_PRINTER == .KDS_PRINTER{
               self.appendOrderTypeAndCateory()
           }
       }

//        listField.append(DeviceFieldModel(title: bleConnection,
//                                           hint: bleConnection,
//                                           value:resturantPrinter?.getBleConString() ?? "0",
//                                           fieldType: .BLE_CON))
        listField.append(DeviceFieldModel(title: brandString,
                                           hint: brandString,
                                           value:resturantPrinter?.brand ?? "",
                                           fieldType: .BRAND_PRINTER,sort: 3))
//        listField.append(DeviceFieldModel(title: modelString ,
//                                           hint: modelString,
//                                           value:resturantPrinter?.model ?? "",
//                                           fieldType: .MODEL_PRINTER))
//        listField.append(DeviceFieldModel(title: typeString ,
//                                           hint: typeString,
//                                           value:resturantPrinter?.type.rawValue ?? "",
//                                           fieldType: .TYPE_PRINTER))
       

    }
    func reloadDeviceFactor(isBLe:Bool?){
//        if let isBLE =  isBLe  {
//            removeConnectionType(isBLE: isBLE)
//                appendConnectionType(isBLE: isBLE)
//            return
//
//        }
        removeOrderTypeAndCateory()

        if (self.typePrinter ?? .POS_PRINTER) == .KDS_PRINTER{
            appendOrderTypeAndCateory()
        }
        
    }
    
    func reloadDeviceFactor(connectionType: ConnectionTypes){
        removeField()
        appendConnectionType(connectionType: connectionType)
        self.appendFieldType(fieldType: .BRAND_PRINTER)
        self.appendFieldType(fieldType: .MODEL_PRINTER)
        self.listField = self.listField.sorted(by: { $0.sort < $1.sort})

    }
    
    func reloadDeviceFactor(fieldType: DEVICE_FIELD_TYPES){
        appendFieldType(fieldType: fieldType)
        self.appendFieldType(fieldType: .BRAND_PRINTER)
        self.appendFieldType(fieldType: .MODEL_PRINTER)
        self.listField = self.listField.sorted(by: { $0.sort < $1.sort})

    }
    
//    private func appendConnectionType(isBLE:Bool){
//        if isBLE{
//            let bleString = "Select Bluetooth Printer".arabic("إختر طابعه البلوتوث")
//            let deviceModel = DeviceFieldModel(title: bleString ,
//                                               hint: bleString ,
//                                               value:resturantPrinter?.printer_ip ?? "",
//                                               fieldType: .BLE_SSD)
//            listField.insert(deviceModel, at: 3)
//
//        }else{
//            
//            let ipString = "Printer IP".arabic("IP الطابعة")
//            let deviceModel = DeviceFieldModel(title: ipString ,
//                                               hint: ipString ,
//                                               value:resturantPrinter?.printer_ip ?? "",
//                                               fieldType: .IP)
//            listField.insert(deviceModel, at: 3)
//
//        }
//    }
    
    private func appendConnectionType(connectionType: ConnectionTypes){
        switch connectionType {
        case .WIFI:
            let ipString = "Printer IP".arabic("IP الطابعة")
            let deviceModel = DeviceFieldModel(title: ipString ,
                                               hint: ipString ,
                                               value:resturantPrinter?.printer_ip ?? "",
                                               fieldType: .IP,sort: 2)
            //listField.insert(deviceModel, at: 3)
            listField.append(deviceModel)
        case .BLUETOOTH:
            let bleString = "Select Bluetooth Printer".arabic("إختر طابعه البلوتوث")
            let deviceModel = DeviceFieldModel(title: bleString ,
                                               hint: bleString ,
                                               value:resturantPrinter?.printer_ip ?? "",
                                               fieldType: .BLE_SSD,sort: 2)
            //listField.insert(deviceModel, at: 3)
            listField.append(deviceModel)
        case .USB:
            let usbPort = "Select USB Port".arabic("إختر مخرج USB")
            let deviceModel = DeviceFieldModel(title: usbPort ,
                                               hint: usbPort ,
                                               value:resturantPrinter?.printer_ip ?? "",
                                               fieldType: .USBPort,sort: 2)
            //listField.insert(deviceModel, at: 3)
            listField.append(deviceModel)
            
        default:
            break
        }
    }
    
    private func appendFieldType(fieldType: DEVICE_FIELD_TYPES){
        switch fieldType {
        case .BRAND_PRINTER:
            let brandString = "Printer Brand".arabic("`براند الطابعة")
            let deviceFieldModel = DeviceFieldModel(title: brandString,
                                                    hint: brandString,
                                                    value:resturantPrinter?.brand ?? "",
                                                    fieldType: fieldType,sort: 3)
            if !listField.contains(deviceFieldType: deviceFieldModel.fieldType) {
                listField.append(deviceFieldModel)
            }
            
        case .MODEL_PRINTER:
            let modelString = "Printer Model".arabic("موديل الطابعة")
            let deviceFieldModel = DeviceFieldModel(title: modelString ,
                                                    hint: modelString,
                                                    value:resturantPrinter?.model ?? "",
                                                    fieldType: fieldType,sort: 4)
            if !listField.contains(deviceFieldType: deviceFieldModel.fieldType) {
                listField.append(deviceFieldModel)
            }
            
        default:
            break
        }
    }
    
//    func removeConnectionType(isBLE:Bool){
//        if isBLE{
//            if let index_orderType = listField.firstIndex(where: { $0.fieldType == .IP})
//            { listField.remove(at: index_orderType) }
//
//        }else{
//            if let index_Type = listField.firstIndex(where: { $0.fieldType == .BLE_SSD})
//            { listField.remove(at: index_Type) }
//
//        }
//          //*  selectCategories.removeAll()
//          //*  selectOrderTypes.removeAll()
//
//    }
    
    func removeField(){
        
        if let index_Type = listField.firstIndex(where: { $0.fieldType == .BLE_SSD}) {
            listField.remove(at: index_Type)
        }
        
        if let index_Type = listField.firstIndex(where: { $0.fieldType == .USBPort}) {
            listField.remove(at: index_Type)
        }

        if let index_orderType = listField.firstIndex(where: { $0.fieldType == .IP}) {
            listField.remove(at: index_orderType)
        }
        
        if let index_Type = listField.firstIndex(where: { $0.fieldType == .BRAND_PRINTER}) {
            listField.remove(at: index_Type)
        }
        
        if let index_Type = listField.firstIndex(where: { $0.fieldType == .MODEL_PRINTER}) {
            listField.remove(at: index_Type)
        }
        //*  selectCategories.removeAll()
        //*  selectOrderTypes.removeAll()
    }
    
    private func appendOrderTypeAndCateory(){
        let categoryString = "Categories ".arabic(" التصنيفات")
        let orderTypeString = "Order Type ".arabic(" نوع الطلب")

        let categoryHintString = "ALL".arabic("الكل")
        let orderTypeHintString = "ALL".arabic("الكل")
        
        let valuesCategoryDic = pos_category_class.get(ids: resturantPrinter?.get_product_categories_ids() ?? [] )
        let valuesDeliveryDic = delivery_type_class.get(ids: resturantPrinter?.get_order_type_ids() ?? [] )
        listField.append(DeviceFieldModel(title: orderTypeString ,
                                           hint: orderTypeHintString,
                                           value:resturantPrinter?.getOrderNamesArray().joined(separator: ",") ?? "",
                                           fieldType: .ORDER_TYPES,
                                          valuesDic: (valuesDeliveryDic.count > 0 ? valuesDeliveryDic : nil),sort: 5 ))
        listField.append(DeviceFieldModel(title: categoryString ,
                                           hint: categoryHintString,
                                           value:resturantPrinter?.getCategoriesNamesArray().joined(separator: ",") ?? "",
                                           fieldType: .CATEGORY,
                                          valuesDic: (valuesCategoryDic.count > 0 ? valuesCategoryDic : nil),sort: 6 ))

    }
    func removeOrderTypeAndCateory(){
        if let index_orderType = listField.firstIndex(where: { $0.fieldType == .ORDER_TYPES})
        { listField.remove(at: index_orderType) }
        if let index_Type = listField.firstIndex(where: { $0.fieldType == .CATEGORY})
        { listField.remove(at: index_Type) }
          //*  selectCategories.removeAll()
          //*  selectOrderTypes.removeAll()

    }
   
  
   
    func saveEditDevice(with completionHandler: ((String?,Bool?)->Void)?)
    {
        self.checkNameField()
        if let error = getErrorMessage(isEditing: false) {
            completionHandler?(error,false)
            return
        }
     
            let new_printer = getRestaurantPrinterToSave()
            new_printer.setMacAddress()
            if let _ = resturantPrinter {
                hitUpdateRestaurantPrinterAPI(new_printer,completionHandler: completionHandler)
            }else{
                new_printer.server_id = 0
                    hitCreateRestaurantPrinterAPI(new_printer,completionHandler: completionHandler)
            }

        
    }
   private func getRestaurantPrinterToSave() -> restaurant_printer_class{
        var new_printer =  restaurant_printer_class(fromDictionary: [:])

        if let resturantPrinter = resturantPrinter {
            new_printer = resturantPrinter
        }
       new_printer.type = self.typePrinter ?? .KDS_PRINTER
        listField.forEach { deviceFieldModel in
            if deviceFieldModel.fieldType == .NAME {
                new_printer.name  = deviceFieldModel.value
                new_printer.display_name =  deviceFieldModel.value
            }
            if deviceFieldModel.fieldType == .IP  || deviceFieldModel.fieldType == .BLE_SSD || deviceFieldModel.fieldType == .USBPort {
                new_printer.printer_ip = deviceFieldModel.value

            }
            if deviceFieldModel.fieldType == .BLE_CON || deviceFieldModel.fieldType == .BLE_SSD {
                new_printer.is_ble_con_2  = true
            }
           
//            if deviceFieldModel.fieldType == .TYPE_PRINTER {
//                new_printer.type = DEVICES_TYPES_ENUM(rawValue: deviceFieldModel.value ) ?? .KDS_PRINTER
//
//            }
            if deviceFieldModel.fieldType == .ConnectionType {
                new_printer.connectionType = ConnectionTypes(rawValue: deviceFieldModel.value)
            }
            
            if deviceFieldModel.fieldType == .BRAND_PRINTER {
                new_printer.brand = deviceFieldModel.value
            }
            if deviceFieldModel.fieldType == .MODEL_PRINTER {
                new_printer.model  = deviceFieldModel.value
            }
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
           
        }

         
            new_printer.config_ids = [SharedManager.shared.posConfig().id]//selectPosConfig.map(){return $0.id}
            new_printer.company_id = SharedManager.shared.posConfig().company_id ?? 0
            new_printer.__last_update = baseClass.get_date_now_formate_datebase()
            new_printer.available_in_pos = SharedManager.shared.posConfig().id
        
    return new_printer

    }
    func setValues(for comingDevice: socket_device_class) {
        
    }
   
}
extension POSPrinterDevice {
    func hitCreateRestaurantPrinterAPI(_ printer:restaurant_printer_class,completionHandler: ((String?,Bool?)->Void)?)
    {
        printer.save()
      /*
        if AppDelegate.shared.enable_debug_mode_code()
        {
            completionHandler?("",true)
            return
        }
       */
        API?.new_create_restaurant_printer(printer: printer) { [self] result in
//            state = .LOADING
            if (result.success )
            {
                let id = result.response!["result"] as?  Int ?? 0
                if id != 0
                {
                    printer.server_id = id
                    printer.save()

                }
            }
            completionHandler?("",true)
//            state = .SAVED
        }
    }
    func hitUpdateRestaurantPrinterAPI(_ printer:restaurant_printer_class,completionHandler: ((String?,Bool?)->Void)?)
    {
        printer.save()
        /*
        if AppDelegate.shared.enable_debug_mode_code()
        {
            completionHandler?("",true)
            return
        }
         */
        API?.new_write_restaurant_printer(printer: printer) { [self] result in
//            state = .LOADING
            if (result.success )
            {
                    printer.save(temp: false, is_update: false)
            }
//            state = .SAVED
            completionHandler?("",true)

        }
    }
}

extension Array where Element == DeviceFieldModel {
    func contains(deviceFieldType type: DEVICE_FIELD_TYPES) -> Bool {
        return self.contains { $0.fieldType == type }
    }
}
