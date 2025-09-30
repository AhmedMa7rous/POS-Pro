//
//  addCustomerNew.swift
//  pos
//
//  Created by Muhammed Elsayed on 03/04/2024.
//  Copyright © 2024 khaled. All rights reserved.
//

import UIKit
import FlagPhoneNumber

protocol addCustomer_delegate_new {
    func reload_customers(customer:res_partner_class)
}
extension addCustomerNew:  FPNTextFieldDelegate {
    func validatePhoneNumber() -> (isValid: Bool, message: String) {
        if (txt_phone.text ?? "").count <= 0 {
            return (true, "")
        }
        var isValid = false // Default to false
        var message = "" // Default to an empty message
        
        // Ensure the phone number is not empty
        guard let phoneNumber = txt_phone.text, !phoneNumber.isEmpty, let phoneCode = self.phoneCode else {
            return (false, "Phone number is required.".arabic("رقم الهاتف مطلوب."))
        }
        
        // Print the phone number for debugging
        print("Phone number: \(phoneNumber), Phone Code: \(phoneCode)")
        // Remove any non-numeric characters (spaces, dashes, etc.)
        let cleanedPhoneNumber = phoneNumber.filter { $0.isNumber }
        
        // Check if the cleaned phone number has at least 7 digits
        if cleanedPhoneNumber.count < 7 {
            return (false, "رقم الهاتف يجب أن يحتوي على 7 أرقام على الأقل.")
        }
        
        let pattern: String
        switch phoneCode {
        case "+20": // Egypt
            // Check if phone number starts with '0'
            if cleanedPhoneNumber.hasPrefix("0") {
                // If it starts with '0', valid prefixes are 010, 011, 012, or 015 followed by 8 digits
                pattern = "^(010|011|012|015)[0-9]{8}$"
                message = "Phone number should start with 010, 011, 012, or 015 followed by 8 digits.".arabic( "رقم الهاتف يجب أن يبدأ بـ 010 أو 011 أو 012 أو 015 ويتبعها 8 أرقام.")
            } else {
                // If it doesn't start with '0', valid prefixes are 10, 11, 12, or 15 followed by 7 digits
                pattern = "^(10|11|12|15)[0-9]{8}$"
                message = "Phone number should start with 10, 11, 12, or 15 followed by 8 digits (without the leading 0).".arabic("رقم الهاتف يجب أن يبدأ بـ 10 أو 11 أو 12 أو 15 ويتبعها 8 أرقام (دون الصفر في البداية).")
            }
            
        case "+966": // Saudi Arabia
            if cleanedPhoneNumber.hasPrefix("0") {
                
                pattern = "^05[0-9]{8}$"  // Phone number starts with 05 and followed by 8 digits
                message = "Phone number should start with 05 followed by 8 digits.".arabic("رقم الهاتف يجب أن يبدأ بـ 05 ويتبعها 8 أرقام.")
            }else{
                pattern = "^5[0-9]{8}$"  // Phone number starts with 05 and followed by 8 digits
                message = "Phone number should start with 05 followed by 8 digits.".arabic("رقم الهاتف يجب أن يبدأ بـ 05 ويتبعها 8 أرقام.")

            }
        case "+971": // UAE
            if cleanedPhoneNumber.hasPrefix("0") {
                
                pattern = "^05[0-9]{8}$"  // Phone number starts with 05 and followed by 8 digits
                message = "Phone number should start with 05 followed by 8 digits.".arabic("رقم الهاتف يجب أن يبدأ بـ 05 ويتبعها 8 أرقام.")
            }else{
                pattern = "^5[0-9]{8}$"  // Phone number starts with 05 and followed by 8 digits
                message = "Phone number should start with 05 followed by 8 digits.".arabic("رقم الهاتف يجب أن يبدأ بـ 05 ويتبعها 8 أرقام.")
            }
        default:
            // In the default case, ensure the phone number has at least 7 digits
            if cleanedPhoneNumber.count < 7 {
                return (false, "رقم الهاتف يجب أن يحتوي على 7 أرقام على الأقل.")
            }
            // Handle unknown country codes here
            pattern = "^[0-9]{7,}$" // Basic pattern for a valid phone number with at least 7 digits
            message = "رمز الدولة غير صالح. رقم الهاتف يجب أن يحتوي على 7 أرقام على الأقل."
        }
        
        // Check if the phone number matches the pattern
        let predicate = NSPredicate(format: "SELF MATCHES %@", pattern)
        isValid = predicate.evaluate(with: cleanedPhoneNumber)
        
        if isValid {
            message = "Phone number is valid.".arabic("رقم الهاتف صالح.")
        }
        
        return (isValid, message)
    }
    // Called when editing ends on the phone number field
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 100{
            let validOperation = validatePhoneNumber() // Call validation when editing ends
            
            print(validOperation.message)
            if !validOperation.isValid {
                showErrorMessage(validOperation.message)
            }
            
            
        }
    }
    func showErrorMessage(_ msg:String){
        SharedManager.shared.initalBannerNotification(title: "", message: msg , success: false, icon_name: "icon_error")
        SharedManager.shared.banner?.dismissesOnTap = true
        SharedManager.shared.banner?.show(duration: 3.0)
    }
    func fpnDisplayCountryList() {
        print("Country list is about to be displayed")
        guard let listController = listController else {return}
        let navigationViewController = UINavigationController(rootViewController: listController)
        
        listController.title = "Choose Countries".arabic("إختر الدولة")
        listController.setup(repository: txt_phone.countryRepository)
        listController.didSelect = { [weak self] country in
            self?.txt_phone.setFlag(countryCode: country.code)
        }
        
        self.present(navigationViewController, animated: true, completion: nil)
        
    }
    
    // This method is required when the user selects a country
    func fpnDidSelectCountry(name: String, dialCode: String, code: String) {
        phoneCode = dialCode
        print("Selected country: \(name) with dial code: \(dialCode) and country code: \(code)")
    }
    
    // This method is required to validate the phone number
    func fpnDidValidatePhoneNumber(textField: FPNTextField, isValid: Bool) {
        if !(textField.text?.isEmpty ?? true){
            if isValid {
                print("Phone number is valid")
            } else {
                print("Phone number is invalid")
            }
        }
    }
    func setFlagBasedOnTimezone(forCountryCode code: String = "") {
        if code.isEmpty{
            // Get the current timezone
            let currentTimeZone = TimeZone.current
            
            // Example mapping from timezone to country code (You can expand this list)
            let timezoneToCountryCode = [
                "Africa/Cairo": "EG", // Egypt
                "Asia/Riyadh": "SA",  // Saudi Arabia
                "Asia/Dubai": "AE"    // United Arab Emirates
            ]
            
            
            // Get the country code based on the current timezone
            if let countryCode = timezoneToCountryCode[currentTimeZone.identifier] {
                // Set the flag using the country code
                txt_phone.setFlag(countryCode: FPNCountryCode(rawValue: countryCode)!)
            }
        }else{
            txt_phone.setFlag(countryCode: FPNCountryCode(rawValue: code)!)

        }
    }
}
class addCustomerNew: UIViewController ,countries_list_delegate ,UITextFieldDelegate{
    
    @IBOutlet weak var txt_name: UITextField!
    @IBOutlet weak var txt_street: UITextField!
    @IBOutlet weak var txt_city: UITextField!
    // @IBOutlet weak var txt_zip: UITextField!
    // @IBOutlet weak var txt_country: UIButton!
    @IBOutlet weak var txt_email: UITextField!
    @IBOutlet weak var txt_phone: FPNTextField!
    @IBOutlet weak var txt_vat: UITextField!
    // @IBOutlet weak var txt_vat: UITextField!
    
    @IBOutlet weak var addMoreAddressBtn: KButton!
    
    @IBOutlet weak var choseAreaDeliveryBtn: KButton!

    var listController: FPNCountryListViewController?
    var selectedDeliveryArea:[pos_delivery_area_class]?
    var delegate:addCustomer_delegate_new?
    
    var country_list:countries_list!
    let con = SharedManager.shared.conAPI()
    
    var customer :res_partner_class?
    var deliveryContacts:[res_partner_class]?
    var initalValue:String?
    var phoneCode:String?

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        country_list = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPhoneNumberField()
        self.preferredContentSize = CGSize.init(width: 700, height: 510)
        viewData()
        if let selectCountry = self.txt_phone.selectedCountry{
            self.phoneCode = selectCountry.phoneCode
        }
        setTitleDeliveryAreaBtn()
        if let initalValue = initalValue, !initalValue.isEmpty{
            if initalValue.isNumber() {
                self.extractCountryCode(from:initalValue)
                self.txt_phone.text = initalValue
            }else{
                self.txt_name.text = initalValue
                
            }
        }
    }
    
    func setupPhoneNumberField() {
        DispatchQueue.main.async{
            self.listController = FPNCountryListViewController(style: .grouped)
            self.txt_phone.hasPhoneNumberExample = false
            self.txt_phone.isEnabled = true // Keep text input enabled
            self.txt_phone.displayMode = .list // Choose .list or .picker for country selection
            //        txt_phone.displayMode = .picker
            //        txt_phone.placeholder = "Phone Number"
            
            // Optional customizations
            self.txt_phone.borderStyle = .roundedRect
            //        txt_phone.setFlag(for: .EG) // Set default to Egypt (+20)
            if self.customer == nil{
                self.setFlagBasedOnTimezone()
            }
            
            
            // Delegate for handling events
            self.txt_phone.delegate = self
        }
    }
    // Function to extract country code from the phone number
      func extractCountryCode(from phoneNumber: String)  {
          
          // Get the first 3 characters as the country code
          if !phoneNumber.isEmpty{
               let countryCode = String(phoneNumber.prefix(5))
                  setFlag(forCountryCode: countryCode)
          }

         
      }
      
      // Function to return flag based on country code
      func setFlag(forCountryCode countryCode: String)  {
          if  countryCode.contains("20") {
              setFlagBasedOnTimezone(forCountryCode:"EG")
              self.phoneCode = "+20"
return
          }
          if  countryCode.contains("966") {
              setFlagBasedOnTimezone(forCountryCode:"SA")
              self.phoneCode = "+966"

return
          }
          if  countryCode.contains("971") {
              setFlagBasedOnTimezone(forCountryCode:"AE")
              self.phoneCode = "+971"

return
          }
         
         
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
            self.extractCountryCode(from:customer?.phone ?? "")

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
            let validOperation = validatePhoneNumber() // Call validation when editing ends
            if !validOperation.isValid {
                showErrorMessage(validOperation.message)
                return
            }
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
        if let phoneCode = self.phoneCode ,!phoneCode.isEmpty, let phoneNumber = txt_phone.text,  !phoneNumber.isEmpty {
            customer!.phone = (phoneCode + "-") + phoneNumber

        }else{
            customer!.phone = (txt_phone.text ?? "")
        }
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
        if let phoneCode = self.phoneCode ,!phoneCode.isEmpty, let phoneNumber = txt_phone.text,  !phoneNumber.isEmpty {
            customer!.phone = (phoneCode + "-") + phoneNumber

        }else{
            customer!.phone = (txt_phone.text ?? "")
        }
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
        self.delegate?.reload_customers(customer: self.customer!)
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
    /*
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
    */
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
