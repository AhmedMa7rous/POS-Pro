//
//  AddIngenicoDeviceVC.swift
//  pos
//
//  Created by M-Wageh on 07/06/2021.
//  Copyright © 2021 khaled. All rights reserved.
//

import UIKit
enum DEVICE_PAYMENT_TYPES{
    case Ingenico,GEIDEA
}
class AddIngenicoDeviceVC: UIViewController {

    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var nameErrorLbl: KLabel!
    @IBOutlet weak var IpTF: UITextField!
    @IBOutlet weak var ipErrorLbl: KLabel!
    @IBOutlet weak var saveBtn: KButton!
    @IBOutlet weak var statusStack: UIStackView!
    @IBOutlet weak var statusLbl: KLabel!
    @IBOutlet weak var statusImage: UIImageView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var portStack: UIStackView!
    @IBOutlet weak var portTF: UITextField!
    
    @IBOutlet weak var terminalStack: UIStackView!
    @IBOutlet weak var termiinalTF: UITextField!
    
    @IBOutlet weak var methodErrorLbl: KLabel!
    
    @IBOutlet weak var choseBtn: KButton!
    
    @IBOutlet weak var removeBtn: KButton!
    var router:AddIngenicoDeviceRouter?
    var setting: settingClass?
    var paymentDeviceProtocol:PaymentDeviceProtocol?
    var device_type:DEVICE_PAYMENT_TYPES = DEVICE_PAYMENT_TYPES.GEIDEA

    var selectDataList:[account_journal_class]?

    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.statusStack.isHidden = true
        self.activityIndicator.stopAnimating()
        initalIngenicoState()
        self.nameTF.text = ""
       
        terminalStack.isHidden = true //device_type != DEVICE_PAYMENT_TYPES.GEIDEA
        portStack.isHidden = true //device_type != DEVICE_PAYMENT_TYPES.GEIDEA
        selectDataList =  []
        if let listData = account_journal_class.get_bank_account(true){
            selectDataList?.append(contentsOf: listData)
            setTitleChoseBtn()
        }
        handleShowHideRemoveBtn()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bindData()
    }
    func bindData(){
        if let ip = setting?.ingenico_ip , !ip.isEmpty{
            self.IpTF.text = ip
            checkConnection(for:ip)
        }
        if let name = setting?.ingenico_name {
            self.nameTF.text = name
        }
        if let port = setting?.port_geidea {
            self.portTF.text = "\(port)"
        }
        if let terminalID = setting?.terminalID_geidea {
            self.termiinalTF.text = terminalID
        }
    }
    private func initalIngenicoState(){
        paymentDeviceProtocol?.updateStatusClosure = { (stateIngenico,message,data) in
            
            switch stateIngenico {
            case .check:
                DispatchQueue.main.async {
                    if (self.device_type != .GEIDEA) {
                if message?.count == 19 {
                    //connection sucess
                    self.statusLbl.text = "Connection success,TID:" + (message ?? "")
                    self.statusImage.isHighlighted = false
                    self.activityIndicator.stopAnimating()
                    self.statusStack.isHidden = false
                    return
                }
                        let error = (message?.isEmpty ?? true) ? "fail connection with Ingenico Device ." : (message ?? "")
                        self.statusImage.isHighlighted = true
                        self.statusLbl.text = error
                            self.activityIndicator.stopAnimating()
                        self.statusStack.isHidden = false

                        
                        
                    }else{
                        self.statusLbl.text = "Connection success,TID:" + (message ?? "")
                        self.statusImage.isHighlighted = false
                        self.activityIndicator.stopAnimating()
                        self.statusStack.isHidden = false

                    }
                    

                }
            case .error:
                    DispatchQueue.main.async {

                self.statusImage.isHighlighted = true
                self.statusLbl.text = message ?? ""
                        self.activityIndicator.stopAnimating()

                self.statusStack.isHidden = false
                    }
            case .receiveResponse:
                return
            case .empty:
               SharedManager.shared.printLog("initalize IngenicoInteractor successfully")
                return
            case .loading:
                DispatchQueue.main.async {
                    self.activityIndicator.startAnimating()
                }
                
            case .update_status(message: let message):
                print(message)
            }
        }
    }
    private func checkConnection(for ip:String){

        if let portInt = Int(self.portTF.text ?? ""){
            self.paymentDeviceProtocol?.setPort(with: portInt )
        }
        if let terminalID = self.termiinalTF.text {
            self.paymentDeviceProtocol?.setTerminalID(with: terminalID )
        }
        self.paymentDeviceProtocol?.setPort(with: 6100 )
        DispatchQueue.global(qos: .background).async {
            self.paymentDeviceProtocol?.checkConnection(with: ip)
            
        }
    }

    @IBAction func tapOnSave(_ sender: Any) {
        self.validateTF()
        if nameErrorLbl.isHidden && ipErrorLbl.isHidden && methodErrorLbl.isHidden {
            if let ip = self.IpTF.text ,
               let name = self.nameTF.text{
                setting?.ingenico_ip = ip
                setting?.ingenico_name = name
                if let port = Int(self.portTF.text ?? "") {
                    setting?.port_geidea = port
                }
                if let terminalID = self.termiinalTF.text  , !terminalID.isEmpty {
                    setting?.terminalID_geidea = terminalID
                }
                setting?.port_geidea = 6100
                setting?.save()
                account_journal_class.rest_is_support_geidea()
                account_journal_class.set_is_support_geidea(for: self.selectDataList ?? [])
                self.statusLbl.text = "Device has save successfully"
                let dataCheck = ["ingenicoIp":ip,"ingenicoName":name].jsonString()
                paymentDeviceProtocol?.addToLog( key: "SaveDevice" + "(\(ip))" , prefix: "Add", data: dataCheck)
                self.statusImage.isHighlighted = false
                statusStack.isHidden = false
            }
        
        }
    }
    
    
    @IBAction func tapCheckBtn(_ sender: UIButton) {
        let ipString = self.IpTF.text ?? ""
        if !ipString.isEmpty && verifyWholeIP(test: ipString)   {
            self.checkConnection(for:ipString)
            self.ipErrorLbl.isHidden = true
            self.ipErrorLbl.text = ""
        }else{
            self.ipErrorLbl.text = "wrong ip address!"
            self.ipErrorLbl.isHidden = false
        }
    }
    
    func validateTF(){
        let ipString = self.IpTF.text ?? ""
        let naemeString = self.nameTF.text ?? ""
        if ipString.isEmpty || !verifyWhileTyping(test:ipString){
            self.ipErrorLbl.text = "wrong ip address!".arabic("رقم خطآ")
            self.ipErrorLbl.isHidden = false
        }else{
            self.ipErrorLbl.isHidden = true
            self.ipErrorLbl.text = ""
        }
        if naemeString.isEmpty {
            self.nameErrorLbl.isHidden = false
            self.nameErrorLbl.text = "empty name !".arabic("يجب كتابه الاسم")

        }else{
            self.nameErrorLbl.isHidden = true
            self.nameErrorLbl.text = ""
        }
        if (selectDataList?.count ?? 0) <= 0 {
            self.methodErrorLbl.text = "please,Chose payment method".arabic("يجب تحديد طرق الدفع")
            self.methodErrorLbl.isHidden = false
        }else{
            self.methodErrorLbl.isHidden = true
        }

    }
    func show_bank_methods(_ sender:UIView)
    {
        ////
        let vc = SelectJournalTypeVC.createModule(sender, selectDataList: self.selectDataList)
        vc.selectDataList = self.selectDataList
        self.present(vc, animated: true, completion: nil)
        vc.completionBlock = { selectDataList in
            self.selectDataList?.removeAll()
            self.selectDataList?.append(contentsOf: selectDataList)
            self.setTitleChoseBtn()
        }
    }
    func setTitleChoseBtn(){
        var title = "Chose".arabic("اختر")
        if (self.selectDataList?.count ?? 0) > 0 {
            title = self.selectDataList?.map(){$0.display_name}.joined(separator: ", ") ?? ""
        }
        self.choseBtn.setTitle( title, for: .normal)
        

    }
    
    @IBAction func tapOnChoseMthodBtn(_ sender: KButton) {
        show_bank_methods(sender)
    }
    
    @IBAction func tapOnRemoveDevice(_ sender: KButton) {
              
        let alert = UIAlertController(title: "Remove Device".arabic(" حذف الجهاز"), message: "Are you sure to Remove Device ?".arabic("هل انت متأكد من حذف الجهاز؟"), preferredStyle: .alert)
        
        let action_void = UIAlertAction(title: "Remove".arabic("حذف") , style: .destructive, handler: { (action) in
            
            self.removeDeviceAction()
        })
                     
        alert.addAction(action_void)

        alert.addAction(UIAlertAction(title: "Cancel".arabic("الغاء") , style: .cancel, handler: { (action) in
            
            alert.dismiss(animated: true, completion: nil)
            
        }))
        
        
        self.present(alert, animated: true, completion: nil)
       

    }
    func removeDeviceAction(){
        let IP =  setting?.ingenico_ip
        let NAME =  setting?.ingenico_name

        nameErrorLbl.isHidden = true
        ipErrorLbl.isHidden = true
        methodErrorLbl.isHidden = true
        self.ipErrorLbl.text = ""
        methodErrorLbl.text = ""
        nameErrorLbl.text = ""
        self.IpTF.text = ""
        self.nameTF.text = ""
        self.portTF.text = ""
        self.termiinalTF.text = ""
   
        setting?.ingenico_ip = ""
        setting?.ingenico_name =  ""
        setting?.terminalID_geidea = ""
        setting?.port_geidea = 0
        setting?.save()
        
        account_journal_class.rest_is_support_geidea()
        handleShowHideRemoveBtn()
        self.statusLbl.text = "Device has remove successfully"
        let dataCheck = ["ingenicoIp":IP,"ingenicoName":NAME].jsonString()

        paymentDeviceProtocol?.addToLog( key: "RemoveDevice" + "(\(IP))" , prefix: "Remove", data: dataCheck)
    }
    func handleShowHideRemoveBtn(){
        self.removeBtn.isHidden = (setting?.ingenico_ip ?? "").isEmpty
    }
  
}
extension AddIngenicoDeviceVC: UITextFieldDelegate{
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.IpTF {
            if let text = textField.text {
                if verifyWhileTyping(test: text + string) {
                    self.ipErrorLbl.isHidden = true
                    self.ipErrorLbl.text = ""
                }else{
                    self.ipErrorLbl.text = "wrong ip address!"
                    self.ipErrorLbl.isHidden = false
                }
            }else{
                self.ipErrorLbl.text = "wrong ip address!"
                self.ipErrorLbl.isHidden = false
            }
        }
        if textField == self.nameTF {
            if let text = textField.text {
                if text.isEmpty {
                    self.nameErrorLbl.isHidden = false
                    self.nameErrorLbl.text = "empty name !"

                }else{
                    self.nameErrorLbl.isHidden = true
                    self.nameErrorLbl.text = ""
                }
            }else{
                self.nameErrorLbl.isHidden = false
                self.nameErrorLbl.text = "empty name !"
            }
        }
       
        return true

    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == self.IpTF {
            if let text = textField.text {
                if verifyWholeIP(test: text ) {
                    self.checkConnection(for:text)
                    self.ipErrorLbl.isHidden = true
                    self.ipErrorLbl.text = ""
                }else{
                    self.ipErrorLbl.text = "wrong ip address!"
                    self.ipErrorLbl.isHidden = false
                }
            }
        }
        if textField == self.nameTF {
            if let text = textField.text {
                if text.isEmpty {
                    self.nameErrorLbl.isHidden = false
                    self.nameErrorLbl.text = "empty name !"

                }else{
                    self.nameErrorLbl.isHidden = true
                    self.nameErrorLbl.text = ""
                }
            }
        }
    }

   
    func verifyWhileTyping(test: String) -> Bool {
        let pattern_1 = "^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])[.]){0,3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])?$"
        let regexText_1 = NSPredicate(format: "SELF MATCHES %@", pattern_1)
        let result_1 = regexText_1.evaluate(with: test)
        return result_1
    }

    func verifyWholeIP(test: String) -> Bool {
        let pattern_2 = "(25[0-5]|2[0-4]\\d|1\\d{2}|\\d{1,2})\\.(25[0-5]|2[0-4]\\d|1\\d{2}|\\d{1,2})\\.(25[0-5]|2[0-4]\\d|1\\d{2}|\\d{1,2})\\.(25[0-5]|2[0-4]\\d|1\\d{2}|\\d{1,2})"
        let regexText_2 = NSPredicate(format: "SELF MATCHES %@", pattern_2)
        let result_2 = regexText_2.evaluate(with: test)
        return result_2
    }
}
