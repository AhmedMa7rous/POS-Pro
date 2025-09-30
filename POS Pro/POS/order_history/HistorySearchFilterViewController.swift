//
//  HistorySearchFilterViewController.swift
//  pos
//
//  Created by Alhaytham Alfeel on 4/8/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import UIKit

class HistorySearchFilterViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var tfDate: UITextField!
    @IBOutlet weak var tfTime: UITextField!
    @IBOutlet weak var tfOrderNumber: UITextField!
    @IBOutlet weak var tfOrderType: UITextField!
    @IBOutlet weak var tfCustomer: UITextField!
    @IBOutlet weak var tfPaymentMethod: UITextField!
    @IBOutlet weak var tfCashier: UITextField!
    @IBOutlet weak var tfSessionNumber: UITextField!
    @IBOutlet weak var tfBusinessDay: UITextField!
    @IBOutlet weak var tfDriver: UITextField!
//    @IBOutlet weak var viewDriverName: UIView!
    @IBOutlet weak var tfCustomerPhone: UITextField!
    @IBOutlet weak var tfCustomerEmail: UITextField!

    private let DateFormat = "yyyy-MM-dd"
    private let TimeViewFormat = "hh:mm a"
    private let TimeSearchFormat = "HH:mm"
    
    private var orderTypes = [delivery_type_class]()
    private var paymentMethods = [[String:Any]]()
    
    var date: String?
    var time: String?
    var orderNumber: String?
    var orderType: String?
    var customer: String?
    var customerPhone: String?
    var customerEmail: String?

    var paymentMethod: String?
    var cashier: String?
    var sessionNumber: Int = 0
    var businessDay: String?

    var driverName: String?
    var driverID: Int?
    var selectDriver: pos_driver_class?

    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.preferredContentSize = CGSize.init(width: 700, height: 510)
        
        setupDateView()
        setupTimeView()
        setupOrderNumberView()
        setupOrderTypeView()
        //setupCustomerView()
        setupPaymentMethodView()
        //setupCashierView()
        setupSessionNumberView()
//        setupBusinessDayView()
        setupDriverNameView()
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.source is HistorySearchFilterViewController {
            
            if let text = tfTime.text {
                let formatter = DateFormatter()
                
                formatter.dateFormat = TimeViewFormat
                
                if let t = formatter.date(from: text)?
                    .subtract(years: 0, months: 0, days: 0, hours: 0, minutes: 0, seconds: TimeZone.current.secondsFromGMT()){
                    formatter.dateFormat = TimeSearchFormat
                    self.time = formatter.string(from: t)
                }
            }
            
            orderNumber = tfOrderNumber.hasText ? tfOrderNumber.text : nil
            orderType = tfOrderType.hasText ? tfOrderType.text : nil
            driverName = tfDriver.hasText ? tfDriver.text : nil
            
            customer = tfCustomer.hasText ? tfCustomer.text : nil
            customerPhone = tfCustomerPhone.hasText ? tfCustomerPhone.text : nil
            customerEmail = tfCustomerEmail.hasText ? tfCustomerEmail.text : nil

            paymentMethod = tfPaymentMethod.hasText ? tfPaymentMethod.text : nil
            cashier = tfCashier.hasText ? tfCashier.text : nil
            sessionNumber = Int(tfSessionNumber.text!) ?? 0
            
            
            date = tfDate.hasText ? tfDate.text : nil
//            businessDay = tfBusinessDay.hasText ? tfBusinessDay.text : nil
            
            
        }
    }
    
    // MARK: - Actions
   
    
    @IBAction func onCancelClick(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func onDateChanged(sender: UIDatePicker) {
        let formatter = DateFormatter()
        
        formatter.dateFormat = DateFormat
        tfDate.text = formatter.string(from: sender.date)
    }
    
    @objc func onTimeChanged(sender: UIDatePicker) {
        let formatter = DateFormatter()
        
        formatter.dateFormat = TimeViewFormat
        tfTime.text = formatter.string(from: sender.date)
    }
    
    @objc func onBusinessDayChanged(sender: UIDatePicker) {
        let formatter = DateFormatter()
        
        formatter.dateFormat = DateFormat
        tfBusinessDay.text = formatter.string(from: sender.date)
    }
    
    // MARK: - Minions
    
    func setupDateView() {
//        tfDate.inputView = datePicker(action: #selector(self.onDateChanged))
      tfDate.addTarget(self, action: #selector(tfDate_textFieldDidChange), for: .editingDidBegin)

    }
    
    @objc func tfDate_textFieldDidChange(_ textField: UITextField) {
        tfDate.resignFirstResponder()
        
        let calendar = calendarVC()

                 calendar.modalPresentationStyle = .formSheet
                 calendar.didSelectDay = { [weak self] date in
                     
                     
                    
                    self!.tfDate.text = date.toString(dateFormat:"yyyy-MM-dd")
                 
                      calendar.dismiss(animated: true, completion: nil)
                 }
        
        calendar.clearDay = {
            
            self.tfDate.text = nil
            calendar.dismiss(animated: true, completion: nil)

        }
        
        self .present(calendar, animated: true, completion: nil)
    }
    
    func setupTimeView() {
        let picker = UIDatePicker()
        
        picker.datePickerMode = .time
        picker.date = Date()
        picker.addTarget(self, action: #selector(self.onTimeChanged), for: UIControl.Event.valueChanged)
        
        tfTime.inputView = picker
    }
    
    func setupOrderNumberView() {
        tfOrderNumber.keyboardType = .numberPad
    }
    
    func setupOrderTypeView() {
//        orderTypes = orderTypeClass.getLocal()
//        tfOrderType.inputView = picker()
        tfOrderType.addTarget(self, action: #selector(tfOrderType_textFieldDidChange), for: .editingDidBegin)

    }
    func setupDriverNameView() {
//        orderTypes = orderTypeClass.getLocal()
//        tfOrderType.inputView = picker()
        tfDriver.addTarget(self, action: #selector(tfDriver_textFieldDidChange), for: .editingDidBegin)

    }
    func selectedDriver(_ selectedDriver:pos_driver_class)
    {
        self.selectDriver = selectedDriver
        self.tfDriver.text = selectedDriver.name
    }
    @objc func tfDriver_textFieldDidChange(_ textField: UITextField) {
        tfDriver.resignFirstResponder()
        let vc = DriverListRouter.createModule(tfDriver, selectDriver: self.selectDriver)
        self.present(vc, animated: true, completion: nil)
        vc.completionBlock = { driver in
            self.selectedDriver(driver)
        }
    }
    
    @objc func tfOrderType_textFieldDidChange(_ textField: UITextField) {
        tfOrderType.resignFirstResponder()
        
        let list = options_listVC()
              list.modalPresentationStyle = .formSheet
              
           orderTypes =  delivery_type_class.getAll()  //orderTypeClass.getLocal()
              
            
              for item in orderTypes
              {
                 
                  
                let title = item.display_name
                var dic:[String:Any] = [:]
                 dic[options_listVC.title_prefex] = title
                  
                  list.list_items.append(dic)

              }
              


              list.didSelect = { [weak self] data in
                  let dic = data
                  let title = dic[options_listVC.title_prefex] as? String ?? ""
                   
                self!.tfOrderType.text = title
//                self!.orderType = title
                
              }
        
              list.clear = {
                   
                   self.tfOrderType.text = nil
                   list.dismiss(animated: true, completion: nil)

               }
                  //  calendar.didSelect  = { [weak self] date in
              //           self?.setSelectedDate(date)
                      
                   //  }
              
            self.present(list, animated: true, completion: nil)
        
    }
    
    //    func setupCustomerView() {
    //    }
    
    func setupPaymentMethodView() {
//        paymentMethods = api.get_last_cash_result(keyCash: "get_account_Journals") as? [[String:Any]] ?? []
//        tfPaymentMethod.inputView = picker()
        tfPaymentMethod.addTarget(self, action: #selector(tfPaymentMethode_textFieldDidChange), for: .editingDidBegin)

    }
    
    @objc func tfPaymentMethode_textFieldDidChange(_ textField: UITextField) {
           tfPaymentMethod.resignFirstResponder()
           
           let list = options_listVC()
                 list.modalPresentationStyle = .formSheet
                 
        paymentMethods = account_journal_class.getAll()  //api.get_last_cash_result(keyCash: "get_account_Journals") as? [[String:Any]] ?? []
                 
               
                 for item in paymentMethods
                 {
                    
                     
                   let title = item["display_name"] as? String ?? ""
                   var dic:[String:Any] = [:]
                    dic[options_listVC.title_prefex] = title
                     
                     list.list_items.append(dic)

                 }
                 


                 list.didSelect = { [weak self] data in
                     let dic = data
                     let title = dic[options_listVC.title_prefex] as? String ?? ""
                      
                   self!.tfPaymentMethod.text = title
//                   self!.paymentMethod = title
                   
                 }
        
        list.clear = {
                      
                      self.tfPaymentMethod.text = nil
                      list.dismiss(animated: true, completion: nil)

                  }
        
        
                     //  calendar.didSelect  = { [weak self] date in
                 //           self?.setSelectedDate(date)
                         
                      //  }
                 
               self.present(list, animated: true, completion: nil)
           
       }
    
    
    //    func setupCashierView() {
    //    }
    
    func setupSessionNumberView() {
        tfSessionNumber.keyboardType = .numberPad
    }
    
    func setupBusinessDayView() {
//        tfBusinessDay.inputView = datePicker(action: #selector(self.onBusinessDayChanged))
        tfBusinessDay.addTarget(self, action: #selector(tfBusinessDay_textFieldDidChange), for: .editingDidBegin)

    }
    @objc func tfBusinessDay_textFieldDidChange(_ textField: UITextField) {
        tfBusinessDay.resignFirstResponder()
        
        let calendar = calendarVC()

                 calendar.modalPresentationStyle = .formSheet
                 calendar.didSelectDay = { [weak self] date in
                     
                     
                    self!.tfBusinessDay.text = date.toString(dateFormat:"yyyy-MM-dd")
//                    self!.businessDay =  self!.tfBusinessDay.text
                 
                      calendar.dismiss(animated: true, completion: nil)
                 }
        
        calendar.clearDay = {
                
                self.tfBusinessDay.text = nil
                calendar.dismiss(animated: true, completion: nil)

            }
        
        self .present(calendar, animated: true, completion: nil)
    }
    
    private func datePicker(action: Selector) -> UIDatePicker {
        let picker = UIDatePicker()
        
        picker.datePickerMode = .date
        picker.date = Date()
        picker.addTarget(self, action: action, for: UIControl.Event.valueChanged)
        
        return picker
    }
    
    private func picker() -> UIPickerView {
        let picker = UIPickerView()
        
        picker.dataSource = self
        picker.delegate = self
        
        return picker
    }
}

extension HistorySearchFilterViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == tfOrderType.inputView {
            return orderTypes.count
        } else if pickerView == tfPaymentMethod.inputView {
            return paymentMethods.count
        }
        
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == tfOrderType {
            return orderTypes[row].display_name
        } else if pickerView == tfPaymentMethod.inputView {
            let paymentMethod = delivery_type_class(fromDictionary:  paymentMethods[row]) // accountJournalsClass(fromDictionary: paymentMethods[row])
            
            return paymentMethod.display_name
        }
        
        return ""
    }
}

extension HistorySearchFilterViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == tfOrderType {
            tfOrderType.text = orderTypes[row].display_name
        } else if pickerView == tfPaymentMethod.inputView {
            let paymentMethod =  delivery_type_class(fromDictionary:  paymentMethods[row]) // //accountJournalsClass(fromDictionary: paymentMethods[row])
            
            tfPaymentMethod.text = paymentMethod.display_name
        }
    }
}
