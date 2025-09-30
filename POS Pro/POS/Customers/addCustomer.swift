//
//  addCustomer.swift
//  pos
//
//  Created by Khaled on 12/5/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

protocol addCustomer_delegate {
    func reload_customers(customer:res_partner_class)
}
class addCustomer: UIViewController ,countries_list_delegate ,UITextFieldDelegate{
    
    @IBOutlet weak var txt_name: UITextField!
    @IBOutlet weak var txt_street: UITextField!
    @IBOutlet weak var txt_city: UITextField!
    // @IBOutlet weak var txt_zip: UITextField!
    // @IBOutlet weak var txt_country: UIButton!
    @IBOutlet weak var txt_email: UITextField!
    @IBOutlet weak var txt_phone: kTextField!
    @IBOutlet weak var txt_vat: UITextField!
    // @IBOutlet weak var txt_vat: UITextField!
    
    @IBOutlet weak var addMoreAddressBtn: KButton!
    
    @IBOutlet weak var choseAreaDeliveryBtn: KButton!
    var selectedDeliveryArea:[pos_delivery_area_class]?
    var delegate:addCustomer_delegate?
    
    var country_list:countries_list!
    let con = SharedManager.shared.conAPI()
    
    var customer :res_partner_class?
    var deliveryContacts:[res_partner_class]?

    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        country_list = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.preferredContentSize = CGSize.init(width: 700, height: 510)
        viewData()
        setTitleDeliveryAreaBtn()
    }
    func completeAddMoreAddress(listConntectAddressAdded:[res_partner_class]?){
        if let clients = listConntectAddressAdded {
            self.deliveryContacts = clients
        }
    }
    @IBAction func tapOnAddMoreAddress(_ sender: KButton) {
        let vc = MultiAddressRouter.createModule(parentCustomer: self.customer,listConntectAddressAdded: self.deliveryContacts  , completeHandler: completeAddMoreAddress)
        self.present(vc, animated: true)
    }
    
    @IBAction func tapOnChoseDeliveryAreaBtn(_ sender: KButton) {
        let selectUservc:SelectDeliveryAreaVC = SelectDeliveryAreaVC.createModule(sender,selectDataList:  self.selectedDeliveryArea,dataList:pos_delivery_area_class.getAll().map({pos_delivery_area_class(fromDictionary: $0)}))
            selectUservc.completionBlock = { selectDataList in
                if  selectDataList.count > 0{
                    if (selectDataList.first?.id ?? 0) == -1{
                        self.selectedDeliveryArea = nil
                    }else{
                        self.selectedDeliveryArea = selectDataList
                    }
                    self.setTitleDeliveryAreaBtn()
                }
            }
            self.present(selectUservc, animated: true, completion: nil)
    }
    func setTitleDeliveryAreaBtn(){
        if let selectedDeliveryArea = selectedDeliveryArea, selectedDeliveryArea.count > 0{
            self.choseAreaDeliveryBtn.setTitle(selectedDeliveryArea.map({$0.display_name}).joined(separator: ","), for: .normal)
        }else{
            if let customer = self.customer{
                self.choseAreaDeliveryBtn.setTitle(customer.pos_delivery_area_name, for: .normal)
            }else{
                self.choseAreaDeliveryBtn.setTitle("Choose delivery area".arabic("اختر منطقة التسليم"), for: .normal)
            }

        }
    }
    
    func viewData()
    {
        if customer != nil
        {
            txt_name.text = customer?.name
            txt_street.text = customer?.street
            txt_city.text = customer?.city
            txt_email.text = customer?.email
            txt_phone.text = customer?.phone
            txt_vat.text = customer?.vat
        }
    }
    
    func country_selected(country:res_country_class)
    {
        // txt_country.setTitle(country.name, for: .normal)
    }
    
    @IBAction func btnSelectCountry(_ sender: Any) {
        let storyboard = UIStoryboard(name: "customers", bundle: nil)
        country_list = storyboard.instantiateViewController(withIdentifier: "countries_list") as? countries_list
        country_list.modalPresentationStyle = .pageSheet
        country_list.delegate = self
        
        
        self.present(country_list, animated: true, completion: nil)
        
    }
    @IBAction func btnOk(_ sender: Any) {
        
        if txt_name.text!.isEmpty
        {
            printer_message_class.show("Please enter customer name.".arabic("الرجاء إدخال اسم العميل."), vc: self)
            return
        }
        var  phone = txt_phone.text!.replacingOccurrences(of: " ", with: "")
           phone = phone.replacingOccurrences(of: "(", with: "")
         phone = phone.replacingOccurrences(of: ")", with: "")
        phone = phone.replacingOccurrences(of: "-", with: "")
        
        if !phone.isEmpty
        {
            var isSameEditPhone = false
            if let currentPhone = self.customer?.phone, phone == currentPhone  {
                isSameEditPhone = true
            }
            if !isSameEditPhone && (res_partner_class.get(phone: phone) != nil){
                printer_message_class.show("Already exist phone number.".arabic("رقم هاتف موجود بالفعل"), vc: self)
                return
            }
        }
        let setting = SharedManager.shared.appSetting()
        if setting.enable_phone_mandatory_add_customer {
            if txt_phone.text!.isEmpty
            {
                printer_message_class.show("Please enter phone number.".arabic("الرجاء إدخال رقم الهاتف."), vc: self)
                return

            }

            if phone.count < 8
            {
                printer_message_class.show("Invalid phone number.".arabic("رقم الهاتف غير صحيح."), vc: self)
                return
            }
            
           
        }
        if setting.enable_email_mandatory_add_customer {
            let email = txt_email.text ?? ""
            if email.isEmpty
            {
                printer_message_class.show("Please enter email.".arabic("الرجاء إدخال البريد الإلكتروني."), vc: self)
                return
            }
            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
            if !emailPred.evaluate(with: email){
                printer_message_class.show("Invalid Email address.".arabic("بريد إلكتروني خاطئ ."), vc: self)
            return
            }
            
        }

        
        if customer == nil
        {
            addNewCustomer()
        }
        else
        {
            editNewCustomer()
        }
        
      
        
    }
    
    func editNewCustomer()
    {
        customer!.name = txt_name.text ?? ""
        customer!.street = txt_street.text ?? ""
        customer!.city = txt_city.text ?? ""
        // customer.zip = txt_zip.text ?? ""
        customer!.email = txt_email.text ?? ""
        customer!.phone = txt_phone.text ?? ""
        customer!.vat = txt_vat.text ?? ""
        if let selectedDeliveryArea = selectedDeliveryArea, selectedDeliveryArea.count > 0{
            customer!.pos_delivery_area_id = selectedDeliveryArea.first?.id ?? 0
            customer!.pos_delivery_area_name = selectedDeliveryArea.first?.name ?? ""
            
        }
        if country_list != nil
        {
            customer!.country_Id = country_list.selectedCountry.id
            
        }
//        self.customer!.save()
//        self.saveDeliveryContacts()
        var contacrNeedUpdated = self.deliveryContacts ?? []
        guard let customerObject = self.customer else {
            return
        }
        loadingClass.show(view: self.view)
            con.userCash = .stopCash
            con.update_customer(customer: customerObject) { (Results) in
            loadingClass.hide(view: self.view)
            
            if Results.success == true
            {
                self.customer?.save()
                self.saveDeliveryContacts()

            }
                else
            {
                 messages.showAlert(Results.message ?? "")
                return

            }
            
            
            if self.delegate != nil
            {
                self.delegate?.reload_customers(customer: self.customer!)
            }
            
            self.dismiss(animated: true, completion: nil)
            
            }
       
     
        
    }
    func saveDeliveryContacts(){
        self.deliveryContacts?.forEach({ deliveryContact in
            if let id = customer?.id, id != 0{
                deliveryContact.parent_id = id

            }
            deliveryContact.parent_name = customer?.name ?? ""
            deliveryContact.row_parent_id = customer?.row_id ?? 0
            deliveryContact.save()
        })
    }
    
    func addNewCustomer()
    {
        customer = res_partner_class(fromDictionary: [:])
        customer!.name = txt_name.text ?? ""
        customer!.street = txt_street.text ?? ""
        customer!.city = txt_city.text ?? ""
        // customer.zip = txt_zip.text ?? ""
        customer!.email = txt_email.text ?? ""
        customer!.phone = txt_phone.text ?? ""
        customer!.vat = txt_vat.text ?? ""
        // customer.barcode = txt_barcode.text ?? ""
        // customer.vat = txt_vat.text ?? ""
        if let selectedDeliveryArea = selectedDeliveryArea, selectedDeliveryArea.count > 0{
            customer!.pos_delivery_area_id = selectedDeliveryArea.first?.id ?? 0
            customer!.pos_delivery_area_name = selectedDeliveryArea.first?.name ?? ""

        }
        if country_list != nil
        {
            customer!.country_Id = country_list.selectedCountry.id
            
        }
        
        customer!.save()
        self.saveDeliveryContacts()
        DispatchQueue.global(qos: .background).async {
            AppDelegate.shared.sync.send_pending_customers()
        }
           DispatchQueue.main.async {
        if self.delegate != nil
        {
            self.customer!.id = -1
            
            self.delegate?.reload_customers(customer: self.customer!)
        }
        }
        
        self.dismiss(animated: true, completion: nil)
        
        /*
         loadingClass.show(view: self.view)
         con.userCash = .stopCash
         con.create_customer(customer: customer) { (Results) in
         loadingClass.hide(view: self.view)
         
         if Results.success == true
         {
         
         let id = Results.response!["result"]
         if id != nil
         {
         customer.id = id as? Int ?? 0
         
         self.pending?.data = customer.toDictionary().json
         self.pending?.id_server = customer.id
         self.pending?.save()
         }
         
         
         if self.delegate != nil
         {
         self.delegate?.reload_customers(customer: customer)
         }
         
         self.dismiss(animated: true, completion: nil)
         
         }
         else
         {
         MessageView.show_in_view(Results.message ?? "", view: self.view)
         }
         }
         */
    }
    
    @IBAction func btnCancel(_ sender: Any) {
        
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var fullString = textField.text ?? ""
        
         
         if  string.isEmpty == false  && string.isNumber() == false {
            return false
        }
        
        fullString.append(string)
        if range.length == 1 {
            textField.text = format(phoneNumber: fullString, shouldRemoveLastDigit: true)
        } else {
            textField.text = format(phoneNumber: fullString)
        }
        return false
    }
    
    func format(phoneNumber: String, shouldRemoveLastDigit: Bool = false) -> String {
        
        guard !phoneNumber.isEmpty else { return "" }
        guard let regex = try? NSRegularExpression(pattern: "[\\s-\\(\\)]", options: .caseInsensitive) else { return "" }
        let r = NSString(string: phoneNumber).range(of: phoneNumber)
        var number = regex.stringByReplacingMatches(in: phoneNumber, options: .init(rawValue: 0), range: r, withTemplate: "")

        if number.count > 12 {
            let tenthDigitIndex = number.index(number.startIndex, offsetBy: 12)
            number = String(number[number.startIndex..<tenthDigitIndex])
        }

        if shouldRemoveLastDigit {
            let end = number.index(number.startIndex, offsetBy: number.count-1)
            number = String(number[number.startIndex..<end])
        }

        if number.count < 7 {
            let end = number.index(number.startIndex, offsetBy: number.count)
            let range = number.startIndex..<end
            number = number.replacingOccurrences(of: "(\\d{3})(\\d+)", with: "($1) $2", options: .regularExpression, range: range)

        } else {
            let end = number.index(number.startIndex, offsetBy: number.count)
            let range = number.startIndex..<end
            number = number.replacingOccurrences(of: "(\\d{3})(\\d{3})(\\d+)", with: "($1) $2-$3", options: .regularExpression, range: range)
        }

        return number
    }
    
}
