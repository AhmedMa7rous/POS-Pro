//
//  BluetoothService.swift
//  pos
//
//  Created by M-Wageh on 12/04/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation

import CoreBluetooth

class BluetoothHelper: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var manager: CBCentralManager!
    let scanningDelay = 1.0
    var items = [String: [String: Any]]()
    var selectPeripheral:CBPeripheral?
    var arrayPeripheral:[CBPeripheral] = []
    static let shared:BluetoothHelper = BluetoothHelper()
    
    private override init(){
        super.init()
    }
    func initlize(){
        manager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func getDevicesCount() -> Int{
        return self.items.keys.count
    }
    
    func getName(at indexPath: IndexPath) -> String?{
        if let item = itemForIndexPath(indexPath){
            return item["name"] as? String
        }
        return nil
    }
    
    func itemForIndexPath(_ indexPath: IndexPath) -> [String: Any]?{
        
        if indexPath.row > items.keys.count{
            return nil
        }
        
        return Array(items.values)[indexPath.row]
    }
    
    // MARK: - CBCentralManagerDelegate
    
    func centralManagerDidUpdateState(_ central: CBCentralManager){
        if central.state == .poweredOn{
            manager.scanForPeripherals(withServices: nil, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber){
        
        didReadPeripheral(peripheral, rssi: RSSI)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        
        didReadPeripheral(peripheral, rssi: RSSI)
        
        delay(scanningDelay){
            peripheral.readRSSI()
        }
    }
    
    func didReadPeripheral(_ peripheral: CBPeripheral, rssi: NSNumber){
        arrayPeripheral.append(peripheral)
        if let name = peripheral.name{
            
            items[name] = [
                "name":name,
                "rssi":rssi
            ]
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral){
        peripheral.readRSSI()
    }
     func BLEConnect(with indexPath: IndexPath){


           self.selectPeripheral = self.arrayPeripheral[indexPath.row]
         if let blePeripheral = self.selectPeripheral{
             self.manager.stopScan()
             self.manager.connect(blePeripheral, options: nil)
         }

         }
}

func delay(_ delay:Double, closure:@escaping ()->()) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}

