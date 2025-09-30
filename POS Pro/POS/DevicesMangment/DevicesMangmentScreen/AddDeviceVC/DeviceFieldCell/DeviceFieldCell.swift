//
//  DeviceFieldCell.swift
//  pos
//
//  Created by M-Wageh on 04/06/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import UIKit
enum DEVICE_FIELD_TYPES{
    case BRAND_PRINTER,MODEL_PRINTER,TYPE_PRINTER,NAME,IP,CATEGORY,ORDER_TYPES,POS_CONFIG,SOCKET_STATUS_DEVICE,PAYMENT_METHODS, GEIDEA_IP,BLE_CON,BLE_SSD,ConnectionType, USBPort
    
    func isFieldValid(with value:String?,isEditing:Bool) -> String {
        let isValueEmpty = (value ?? "").isEmpty
        switch self {
        case .ConnectionType:
            return isValueEmpty ? "You must select connection type" : ""
        case .BRAND_PRINTER:
            return isValueEmpty ? "You must select printer brand" : ""
        case .MODEL_PRINTER:
            return isValueEmpty ? "You must select printer model" : ""
        case .TYPE_PRINTER:
            return isValueEmpty ? "You must select printer type" : ""
        case .NAME:
            return isValueEmpty ? "" : ""
        case .IP:
            //check ip not taken by another device
            if isValueEmpty {
                    return "You must enter printer Ip"
            }else{
                if isEditing{
                    return ""
                }else{
                    #if DEBUG
                    return socket_device_class.find(by:value ?? "" ) ? "Ip is added before , please edit or remove it first" : ""

                    #else
                    if AppDelegate.shared.enable_debug_mode_code() == false{
                    if value == MWConstantLocalNetwork.getIPV4Address() {
                        return "This device is working with these ip".arabic("هذا الجهاز يعمل مع هذه IP")
                    }
                    }
                    return socket_device_class.find(by:value ?? "" ) ? "Ip is added before , please edit or remove it first" : ""
                    #endif

                }
            }
        case .CATEGORY:
            return isValueEmpty ? "" : ""
        case .ORDER_TYPES:
            return isValueEmpty ? "" : ""
        case .POS_CONFIG:
            return isValueEmpty ? "" : ""
        case .SOCKET_STATUS_DEVICE:
            return isValueEmpty ? "" : ""
        case .GEIDEA_IP:
            return isValueEmpty ? "" : ""
        case .PAYMENT_METHODS:
            return isValueEmpty ? "" : ""
        case .BLE_CON:
            return isValueEmpty ? "" : ""
        case .BLE_SSD:
            if isValueEmpty {
                    return "You must select bluetooth printer"
            }else{
                if isEditing{
                    return ""
                }else{
                    return socket_device_class.find(by:value ?? "" ) ? "Printer is added before , please edit or remove it first" : ""
                }
            }
        case .USBPort:
            if isValueEmpty {
                    return "You must select USB Port"
            }else{
                if isEditing{
                    return ""
                }else{
                    return socket_device_class.find(by:value ?? "" ) ? "Printer is added before , please edit or remove it first" : ""
                }
            }
       
        }
       
    }
}

class DeviceFieldCell: UITableViewCell {
    
    @IBOutlet weak var titleFieldLbl: UILabel!
    @IBOutlet weak var selectBtn: UIButton!
    @IBOutlet weak var ipTF: UITextField!
    @IBOutlet weak var searchBtn: KButton!
    @IBOutlet weak var arrowNextImage: UIImageView!
    
    @IBOutlet weak var switchBtn: UISwitch!
    @IBOutlet weak var togleView: UIView!
    var deviceFieldModel:DeviceFieldModel?{
        didSet
        {
            if let deviceFieldModel = deviceFieldModel {
                setValue()
                handleUI(for:deviceFieldModel.fieldType)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    private func setValue(){
        let value = deviceFieldModel?.value ?? ""
        let title = deviceFieldModel?.title ?? ""
        let hint = deviceFieldModel?.hint ?? ""
        let type = deviceFieldModel?.fieldType ?? .NAME
        titleFieldLbl.text = title
        let colorValue = value.isEmpty ? #colorLiteral(red: 0.768627451, green: 0.768627451, blue: 0.7764705882, alpha: 1) : #colorLiteral(red: 0.986671865, green: 0.468683362, blue: 0, alpha: 1)
        
        if type == .NAME  {
            if value.isEmpty {
                self.ipTF.placeholder = hint
                
            }else{
                self.ipTF.text = value
            }
            self.ipTF.textColor = colorValue
        }else{
            if type == .SOCKET_STATUS_DEVICE {
                self.switchBtn.isOn =  value != "2"
            }else if type == .BLE_CON {
                self.switchBtn.isOn =  value == "1"
            } else{
            self.selectBtn.setTitle(value.isEmpty ? hint : value, for: .normal)
            self.selectBtn.setTitleColor(colorValue, for: .normal)
            }
        }
    }
    private func handleUI(for type:DEVICE_FIELD_TYPES){
        if type == .NAME {
            self.ipTF.isHidden  = false
            self.arrowNextImage.isHidden = true
            self.searchBtn.isHidden = true
            self.selectBtn.isHidden = true
            self.togleView.isHidden = true
        }else{
            self.ipTF.isHidden  = true
            self.searchBtn.isHidden = true
            if type == .SOCKET_STATUS_DEVICE {
                self.togleView.isHidden = false
                self.arrowNextImage.isHidden = true
                self.selectBtn.isHidden = true
            }else if type == .BLE_CON {
                self.togleView.isHidden = false
                self.arrowNextImage.isHidden = true
                self.selectBtn.isHidden = true
            } else {
                self.arrowNextImage.isHidden = false
                self.selectBtn.isHidden = false
                self.togleView.isHidden = true

            }
        }
       
    }
}


