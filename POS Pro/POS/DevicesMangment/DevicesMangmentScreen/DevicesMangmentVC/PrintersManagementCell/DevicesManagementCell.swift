//
//  DevicesManagementCell.swift
//  pos
//
//  Created by M-Wageh on 04/06/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import UIKit

protocol DevicesManagementProtocol{
    func testConnection(for printer:restaurant_printer_class)
    func testGeideaConnection(for device_socket:socket_device_class)
    func testPrinter(for printer:restaurant_printer_class)
    func deletPrinter(for printer:restaurant_printer_class)
    func openLogPrinter(for printer:restaurant_printer_class)
    func deletSocketDevice(for device_socket:socket_device_class)
    func deleteGeideaDevice(for device_socket:socket_device_class)
}

class DevicesManagementCell: UITableViewCell {

    @IBOutlet weak var printerNameLbl: UILabel!
    @IBOutlet weak var testConnectionBtn: KButton!
    @IBOutlet weak var testPrinterBtn: KButton!
    @IBOutlet weak var logBtn: KButton!
    @IBOutlet weak var deletBtn: KButton!
    @IBOutlet weak var pingBtn: KButton!
    
    var delegate:DevicesManagementProtocol?
    var deviceDictionary: [String:Any]? {
        didSet{
            if let deviceDictionary = deviceDictionary {
                 let type = DEVICES_TYPES_ENUM(rawValue:deviceDictionary["type"] as? String ?? "")
                if type == DEVICES_TYPES_ENUM.POS_PRINTER ||  type == DEVICES_TYPES_ENUM.KDS_PRINTER{
                    resturantPrinterHandling(restaurant_printer_class(fromDictionary:deviceDictionary ))
                }else if type == DEVICES_TYPES_ENUM.GEIDEA {
                    geideaDeviceHandling(socket_device_class(from: deviceDictionary))
                }else
                {
                    socketDeviceHandling(socket_device_class(from: deviceDictionary))
                }
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    private func setIsHiddenPrinterActionBtn(with isHidden:Bool){
        testConnectionBtn.isHidden = isHidden
        testPrinterBtn.isHidden = isHidden
    }
    func socketDeviceHandling(_ socketDevice:socket_device_class){
        pingBtn.isHidden = false
        setIsHiddenPrinterActionBtn(with:true)
        var titlePrinter = socketDevice.device_ip ?? ""
        if socketDevice.device_ip != socketDevice.name {
            titlePrinter += " / " + (socketDevice.name ?? "")
        }
        printerNameLbl.text = titlePrinter
        pingBtn.backgroundColor = socketDevice.pingStatus.getColor()
    }
    func resturantPrinterHandling(_ printer:restaurant_printer_class){
        setIsHiddenPrinterActionBtn(with:false)
        pingBtn.isHidden = true
        self.doStyle(for:TEST_PRINTER_Status(rawValue: printer.test_printer_status) ?? .NONE)
        var titlePrinter = printer.printer_ip
        if printer.printer_ip != printer.display_name {
            titlePrinter += " / " + printer.display_name
        }
        if let brand = printer.brand {
            titlePrinter += " / " + brand
        }
        printerNameLbl.text = titlePrinter
    }
    func geideaDeviceHandling(_ socketDevice:socket_device_class){
        testConnectionBtn.isHidden = false
        pingBtn.isHidden = true
        testPrinterBtn.isHidden = true
        var titlePrinter = socketDevice.name ?? ""
        printerNameLbl.text = titlePrinter
        testConnectionBtn.backgroundColor = socketDevice.pingStatus.getColor()
    }
    func doStyle(for status:TEST_PRINTER_Status){
        switch status {
        case .NONE:
            self.testPrinterBtn.backgroundColor = #colorLiteral(red: 0.431372549, green: 0.431372549, blue: 0.431372549, alpha: 1)
        case .SUCCESS:
            self.testPrinterBtn.backgroundColor = #colorLiteral(red: 0, green: 0.6274509804, blue: 0.6156862745, alpha: 1)
        case .FAIL:
            self.testPrinterBtn.backgroundColor = #colorLiteral(red: 0.5294117647, green: 0.3529411765, blue: 0.4823529412, alpha: 1)
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
   
    
    @IBAction func tapOnTestConnectionBtn(_ sender: KButton) {
        if let deviceDictionary = self.deviceDictionary{
            let type = DEVICES_TYPES_ENUM(rawValue:deviceDictionary["type"] as? String ?? "")
            
           if type == DEVICES_TYPES_ENUM.GEIDEA {
                self.delegate?.testGeideaConnection(for: socket_device_class(from: deviceDictionary))
            } else{
                self.delegate?.testConnection(for: restaurant_printer_class(fromDictionary:deviceDictionary ))
            }
        }
    }
    
    @IBAction func tapOnTestPrinterBtn(_ sender: KButton) {
        if let deviceDictionary = self.deviceDictionary{
            self.delegate?.testPrinter(for: restaurant_printer_class(fromDictionary:deviceDictionary))
        }

    }
    
    
    @IBAction func tapOnLogBtn(_ sender: KButton) {
        if let deviceDictionary = self.deviceDictionary {
            self.delegate?.openLogPrinter(for: restaurant_printer_class(fromDictionary:deviceDictionary))
        }
    }
    
    @IBAction func tapOnDeletPrinterBtn(_ sender: KButton) {
        if let deviceDictionary = self.deviceDictionary{
        let type = DEVICES_TYPES_ENUM(rawValue:deviceDictionary["type"] as? String ?? "")
            if type?.canAcces() ?? true{
                if type == DEVICES_TYPES_ENUM.POS_PRINTER ||  type == DEVICES_TYPES_ENUM.KDS_PRINTER{
                    self.delegate?.deletPrinter(for: restaurant_printer_class(fromDictionary:deviceDictionary ))
                } else if type == DEVICES_TYPES_ENUM.GEIDEA {
                    self.delegate?.deleteGeideaDevice(for: socket_device_class(from: deviceDictionary))
                } else{
                    self.delegate?.deletSocketDevice(for: socket_device_class(from: deviceDictionary))
                }
            }
        }

    }
    
}
