//
//  SettingCell.swift
//  pos
//
//  Created by M-Wageh on 09/07/2023.
//  Copyright © 2023 khaled. All rights reserved.
//

import UIKit

class SettingCell: UITableViewCell {
    
    @IBOutlet weak var settingHintLbl: UILabel!
    
    @IBOutlet weak var settingSwitch: UISwitch!
    @IBOutlet weak var settingSegment: UISegmentedControl!
    
    @IBOutlet weak var settingTF: UITextField!
    @IBOutlet weak var settingView: UIView!
    @IBOutlet weak var settingTimeLbl: UILabel?
    
    @IBOutlet weak var settingBtn: UIButton!
    var mwsettingAppVM:MWSettingAppVM?
    var indexPath:IndexPath?
    
    var settingItemModle:SettingItemModle?{
        didSet{
            if let settingItemModle = settingItemModle {
                settingHintLbl.text = settingItemModle.hintText
                let typeSetting = settingItemModle.settingKey
                self.settingSwitch.isHidden = !(typeSetting.getType() == .check_box)
                self.settingTF.isHidden = !(typeSetting.getType() == .number || typeSetting.getType() == .text)
                self.settingSegment.isHidden = !(typeSetting.getType() == .combo)
                if let valueSetting = settingItemModle.value {
                    
                    if typeSetting == .enable_OrderType{
                        hideAll()
                        self.settingSegment.isHidden = false
                        self.settingSegment.selectedSegmentIndex = (valueSetting as? Int) ?? 0
                        self.settingSegment.setTitle("Disable".arabic("إيقاف"), forSegmentAt: 0)
                        self.settingSegment.setTitle("Payment".arabic("عند الدفع"), forSegmentAt: 1)
                        self.settingSegment.setTitle("New order".arabic("طلب جديد"), forSegmentAt: 2)
                        
                    }else{
                        if typeSetting == .enable_cloud_kitchen{
                            hideAll()
                            self.settingSegment.isHidden = false
                            self.settingSegment.selectedSegmentIndex = (valueSetting as? Int) ?? 0
                            self.settingSegment.setTitle("Disable".arabic("إيقاف"), forSegmentAt: 0)
                            self.settingSegment.setTitle("Start Session".arabic("بداء الجلسه"), forSegmentAt: 1)
                            self.settingSegment.setTitle("New order".arabic("طلب جديد"), forSegmentAt: 2)
                        }else if typeSetting == .options_for_require_customer{
                            hideAll()
                            self.settingSegment.isHidden = false
                            self.settingSegment.selectedSegmentIndex = (valueSetting as? Int) ?? 0
                            self.settingSegment.setTitle("None".arabic("بدون"), forSegmentAt: 0)
                            self.settingSegment.setTitle("Ask".arabic("سؤال"), forSegmentAt: 1)
                            self.settingSegment.setTitle("Require".arabic("مطلوب"), forSegmentAt: 2)
                        }
                        else if  typeSetting == .close_old_session_to_allow_create_new_orders{
                            self.hideAll()
                            self.settingBtn.isHidden = false
                            let timeCloseOldSession  = SharedManager.shared.appSetting().time_close_old_session_to_allow_create_new_orders
                            self.settingBtn.setTitle( timeCloseOldSession, for: .normal)
                            self.casteTypeFor(valueSetting)
                        }else if  typeSetting == .enable_invoice_width{
                            self.hideAll()
                            self.settingBtn.isHidden = false
                            let invoiceWidth  = SharedManager.shared.appSetting().width_invoice_to_set_new_dimensions
                            self.settingBtn.setTitle( invoiceWidth, for: .normal)
                            self.casteTypeFor(valueSetting)
                        }else if  typeSetting == .width_invoice_to_set_new_dimensions{
                            self.hideAll()
                            self.settingBtn.isHidden = false
                            let widthDimensions = SharedManager.shared.appSetting().width_invoice_to_set_new_dimensions
                            self.settingBtn.setTitle( widthDimensions, for: .normal)
                            self.casteTypeFor(valueSetting)
                        }else{
                            self.hideAll()
                            self.casteTypeFor(valueSetting)
                            if typeSetting == .disable_idle_timer{
                                if let isDisable = valueSetting as? Bool, !isDisable{
                                    self.settingHintLbl.textColor = #colorLiteral(red: 0.9304464459, green: 0.1336709261, blue: 0.2233623266, alpha: 1)

                                }else{
                                    self.settingHintLbl.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)

                                }
                            }
                        }
                    }
                }
                
                
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        setStyleForBtn()
        hideAll()
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        hideAll()
        
    }
    func configCell(_ mwsettingAppVM:MWSettingAppVM, _ indexPath:IndexPath ){
        self.hideAll()
        self.mwsettingAppVM = mwsettingAppVM
        self.indexPath = indexPath
        self.setBkColor()
        self.settingItemModle = mwsettingAppVM.getSettingItem(at: indexPath.section, for: indexPath.row)

    }
    
    func setStyleForBtn(){
        self.settingBtn.layer.cornerRadius = 8
        self.settingBtn.layer.borderWidth = 1
        self.settingBtn.layer.borderColor =  #colorLiteral(red: 0.3254901961, green: 0.1529411765, blue: 0.5019607843, alpha: 1)
    }
    func hideAll(){
        self.settingSwitch.isHidden = true
        self.settingTF.isHidden = true
        self.settingSegment.isHidden = true
        self.settingBtn.isHidden = true
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    @IBAction func togleSeqmentSetting(_ sender: UISegmentedControl) {
        if let indexPath = self.indexPath{
            mwsettingAppVM?.updateSetting(for: indexPath, with: sender.selectedSegmentIndex)
        }
    }
    
    @IBAction func togleSwitchSetting(_ sender: UISwitch) {
        self.mwsettingAppVM?.state = .dismissKB
        if let indexPath = self.indexPath{
            if !(mwsettingAppVM?.togleSetting(for: indexPath, with: sender.isOn) ?? false) {
                sender.isOn = false
            }
//            mwsettingAppVM?.updateSetting(for: indexPath, with: sender.isOn)
        }
    }
    
    @IBAction func tfSettingEditing(_ sender: UITextField) {
        if let indexPath = self.indexPath{
            let stringValue = sender.text ?? ""
            if  let validateValue = self.settingItemModle?.validateValue(stringValue){
                if validateValue.valid {
                    if let valueCaste = validateValue.casteValue{
                        mwsettingAppVM?.updateSetting(for: indexPath, with: valueCaste)
                    }
                }else if let settingKey = self.settingItemModle?.settingKey{
                    self.mwsettingAppVM?.state = .show_alert(settingKey)
                    if let oldValue = self.settingItemModle?.value as? String{
                        sender.text = oldValue
                    }else{
                        if let oldIntValue = self.settingItemModle?.value as? Int{
                            sender.text = "\(oldIntValue)"
                        }else{
                            if let oldDoubleValue = self.settingItemModle?.value as? Double{
                                sender.text = "\(oldDoubleValue)"
                            }
                        }
                    }
                }
            }
            
        }
    }
    
    @IBAction func tapOnTimeCloseSession(_ sender: UIButton) {
        let typeSetting = settingItemModle?.settingKey
        if typeSetting == .enable_invoice_width {
            let widthPickerVC = InvoiceWidthPicker.createModule(sender)
            widthPickerVC.selectWidthClosure = { selectedWidth in
                sender.setTitle("\(selectedWidth) mm", for: .normal)
                DispatchQueue.global(qos: .background).async {
                    SharedManager.shared.appSetting().width_invoice_to_set_new_dimensions = selectedWidth
                    SharedManager.shared.appSetting().save()

                    SettingAppInteractor.shared.setSettingApp(for: SETTING_KEY.width_invoice_to_set_new_dimensions.rawValue, with: selectedWidth)
                }
                widthPickerVC.dismiss(animated: true, completion: nil)
               }
            let vc = AppDelegate.shared.window?.visibleViewController()
            vc?.present(widthPickerVC, animated: true, completion: nil)
        } else {
            if let isEnable = self.settingItemModle?.value as? Bool, isEnable {
                let calendar = time_picker()
                calendar.minTime =  sender.titleLabel?.text ?? ""
                
                         calendar.modalPresentationStyle = .formSheet
                         calendar.didSelectDay = { [weak self] date in
                             
                            let time:String = String(date)
                             DispatchQueue.global(qos: .background).async {
                                 SharedManager.shared.appSetting().time_close_old_session_to_allow_create_new_orders = time
                                 SharedManager.shared.appSetting().save()

                                 SettingAppInteractor.shared.setSettingApp(for:SETTING_KEY.time_close_old_session_to_allow_create_new_orders.rawValue, with: time)
                             }
                             sender.setTitle(time, for: .normal)
         
                              calendar.dismiss(animated: true, completion: nil)
                         }
                
                let vc = AppDelegate.shared.window?.visibleViewController()
                
                vc?.present(calendar, animated: true, completion: nil)
            }
        }
    }
    
    
    private func setBkColor(){
        let isEvenRow = (indexPath?.row ?? 0) % 2 == 0
       let titleColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1) //UIColor.init(hexString: "#6A6A6A")
        let bkColor = #colorLiteral(red: 0.9026321769, green: 0.8532004952, blue: 0.9270676374, alpha: 1)
        //DED3E6
        //#colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.968627451, alpha: 1)
        self.settingView.backgroundColor = isEvenRow ? bkColor : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        self.settingHintLbl.textColor =  titleColor
        
    }
    private func setSwitch(with value:Bool){
        self.settingSwitch.isHidden = false
        self.settingSwitch.isOn = value
    }
    private func setTime(with value:String){
        self.settingTimeLbl?.isHidden = false
        self.settingTimeLbl?.text = value
    }
    private func setTF(with value:Int){
        self.settingTF.isHidden = false
        self.settingTF.text = "\(value)"
    }
    private func setTF(with value:Double){
        self.settingTF.isHidden = false
        self.settingTF.text = "\(value)"
    }
    private func casteTypeFor(_ value:Any) {
        if let value = value as? Bool{
            self.setSwitch(with:value)

        }else{
            if let value = value as? String{
                self.setTime(with:value)
            }else if  let intValue = value as? Int{
                    self.setTF(with: intValue)
                }else if  let doubleValue = value as? Double{
                    self.setTF(with: doubleValue)
                }
            }
        }
}
