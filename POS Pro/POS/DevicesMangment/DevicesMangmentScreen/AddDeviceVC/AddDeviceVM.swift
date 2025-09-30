//
//  AddPrinterVM.swift
//  pos
//
//  Created by M-Wageh on 04/06/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation
class AddDeviceVM {
    
    enum AddDeviceState{
        case EMPTY,RELOAD,RELOAD_ROW(Int),LOADING,ERROR(String),SAVED
    }
    
    var state: AddDeviceState = .EMPTY {
        didSet {
            self.updateLoadingStatusClosure?(state)
        }
    }
    
    var updateLoadingStatusClosure: ((AddDeviceState) -> Void)?

    var devicesFactorProtocol:AddDevicesFactorProtocol?
    let API:api?
    var fieldsCount: Int {
        return devicesFactorProtocol?.listField.count ?? 0
    }
    
    init(from devicesFactorProtocol:AddDevicesFactorProtocol?) {
        API = api()
        self.devicesFactorProtocol = devicesFactorProtocol
    }
   
    
    func getDeviceField(at indexPath:IndexPath)->DeviceFieldModel?
    {
        return devicesFactorProtocol?.listField[indexPath.row]
    }
    
    func handlingSetValue(for index:Int, value: String? = nil, valuesDic: [[String : Any]]? = nil, selecDataList: [account_journal_class]? = nil){
        
        self.devicesFactorProtocol?.setValue(for: index, value: value, valuesDic: valuesDic)
        if devicesFactorProtocol?.listField[index].fieldType == .BLE_CON {
            let isON = (value ?? "0") == "1"
            devicesFactorProtocol?.setValue(for: .IP, value: "")
            devicesFactorProtocol?.setValue(for: .BLE_SSD, value: "")
            devicesFactorProtocol?.reloadDeviceFactor(isBLe: isON)
            state = .RELOAD
            return
        }
        
        if devicesFactorProtocol?.listField[index].fieldType == .ConnectionType {
            guard let value = value, let connection = ConnectionTypes(rawValue: value) else { return }
//            devicesFactorProtocol?.setValue(for: .IP, value: "")
//            devicesFactorProtocol?.setValue(for: .BLE_SSD, value: "")
//            devicesFactorProtocol?.setValue(for: .USBPort, value: "")
            devicesFactorProtocol?.reloadDeviceFactor(connectionType: connection)
            state = .RELOAD
            return
        }
        
        if devicesFactorProtocol?.listField[index].fieldType == .IP ||
            devicesFactorProtocol?.listField[index].fieldType == .BLE_SSD ||
            devicesFactorProtocol?.listField[index].fieldType == .USBPort {
//            devicesFactorProtocol?.reloadDeviceFactor(fieldType: .BRAND_PRINTER)
//            devicesFactorProtocol?.setValue(for: .BRAND_PRINTER, value: "")
//            state = .RELOAD
//            return
        }
        
        if devicesFactorProtocol?.listField[index].fieldType == .BRAND_PRINTER {
            guard let value = value else { return }
            devicesFactorProtocol?.setValue(for: .BRAND_PRINTER, value: value)
            devicesFactorProtocol?.setValue(for: .MODEL_PRINTER, value: "")
            devicesFactorProtocol?.reloadDeviceFactor(fieldType: .MODEL_PRINTER)
            state = .RELOAD
            return
        }
        
        if devicesFactorProtocol?.listField[index].fieldType == .TYPE_PRINTER {
            devicesFactorProtocol?.reloadDeviceFactor(isBLe: nil)
            state = .RELOAD
            return
        }
        state = .RELOAD_ROW(index)
    }
    func saveEditPrinter(){
        state = .LOADING
        devicesFactorProtocol?.saveEditDevice(with: { error , success in
            if !(error?.isEmpty ?? true) {
                self.state = .ERROR(error ?? "")
            }else{
                self.state = .SAVED
            }
        })
    }
    func getResturantPrinter() -> restaurant_printer_class?{
        var result:restaurant_printer_class? = nil
        if let posPrinter = self.devicesFactorProtocol as? POSPrinterDevice, let resturantPrinter = posPrinter.resturantPrinter , !resturantPrinter.printer_ip.isEmpty{
            result = resturantPrinter
        }else{
            let posPrinter = restaurant_printer_class(fromDictionary: [:])
            posPrinter.printer_ip = devicesFactorProtocol?.getValue(for: .BLE_SSD) ?? devicesFactorProtocol?.getValue(for: .USBPort) ?? ""
            if !posPrinter.printer_ip.isEmpty{
                result = posPrinter
            }

        }
        return result
    }
    
    func getCategoriesSelectList() -> [pos_category_class]?{
        if let selectValues = self.devicesFactorProtocol?.getValue(for: .CATEGORY) as [[String:Any]]?{
            return selectValues.map({pos_category_class(fromDictionary: $0)})
        }
        return nil
    }
    func getOrderTypeSelectList() -> [delivery_type_class]?{
        if let selectValues = self.devicesFactorProtocol?.getValue(for: .ORDER_TYPES) as [[String:Any]]?{
            return selectValues.map({delivery_type_class(fromDictionary: $0)})
        }
        return nil
    }
    func getPaymentMethodsList() -> [account_journal_class]?{
        if let selectValues = self.devicesFactorProtocol?.getValue(for: .PAYMENT_METHODS) as [[String:Any]]?{
            return selectValues.map({account_journal_class(fromDictionary: $0)})
        }
        return nil
    }
    func getPosSelectList() -> [pos_config_class]?{
        if let selectValues = self.devicesFactorProtocol?.getValue(for: .POS_CONFIG) as [[String:Any]]?{
            return selectValues.map({pos_config_class(fromDictionary: $0)})
        }
        return nil
    }
    func getSelectStringList(fieldType: DEVICE_FIELD_TYPES) -> [String]?{
        if let currentValue = self.devicesFactorProtocol?.getValue(for: fieldType) as String?{
            return currentValue.replacingOccurrences(of: " ", with: "").components(separatedBy: ",")
        }
        return nil
    }
}

