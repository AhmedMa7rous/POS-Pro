//
//  filter_report.swift
//  pos
//
//  Created by khaled on 01/04/2021.
//  Copyright © 2021 khaled. All rights reserved.
//

import UIKit

class filter_report: UIViewController {

    var start_date:String?
    var end_date:String?
    var start_time: String?
    var end_time: String?
    
//    let date_formate = "dd/MM/yyyy"
    let date_formate = "yyyy-MM-dd hh:mm a"


    @IBOutlet var btnSelectShift: UIButton!

 
    @IBOutlet var btnEndDate: UIButton!
    @IBOutlet var btnStartDate: UIButton!
    
    var shift_id:Int?
    var dictionary = [Int:[pos_order_line_class]]()

    var didSelect : (([String:Any]) -> Void)?
    var withParseDate:Bool = false

    var option:ordersListOpetions =  ordersListOpetions()
    var selected_dic:[String:Any] = [:]

    private lazy var formatter: DateFormatter = {
        let f = DateFormatter()
        f.timeZone  = TimeZone(secondsFromGMT: 0)!
        f.dateFormat = "hh:mm a"      // "HH:mm" for 24-hour
        return f
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
     
        self.option = selected_dic["option"] as! ordersListOpetions
        let shift_name = selected_dic["shift_name"] as? String ?? ""
        start_date = selected_dic["start_date"] as? String ?? ""
        end_date = selected_dic["end_date"] as? String ?? ""
            
            btnStartDate.setTitle(start_date, for: .normal)
           btnEndDate.setTitle(end_date, for: .normal)
            btnSelectShift.setTitle(shift_name, for: .normal)
            
        shift_id = self.option.sesssion_id

        
        
    }
    
 
    
    @IBAction func btnSelectShift(_ sender: Any) {
         
         let list = options_listVC()
         list.modalPresentationStyle = .formSheet
         let allOption = [options_listVC.title_prefex:"All"]
        let noneOption = [options_listVC.title_prefex:"By time"]
        list.list_items.append(noneOption)
         list.list_items.append(allOption)
         
         let options = posSessionOptions()
 
       options.between_start_session = [get_start_date(),get_end_date()]

 
   
         let arr: [[String:Any]] =    pos_session_class.get_pos_sessions(options: options)
         for item in arr
         {
             var dic = item
             let shift = pos_session_class(fromDictionary: item)
             
             let dt = Date(strDate: shift.start_session!, formate: baseClass.date_fromate_satnder,UTC: true)
             let startDate = dt.toString(dateFormat: baseClass.date_fromate_satnder_12h, UTC: false)
             
 
             
             let title = String( shift.id ) + " - " + startDate
             dic[options_listVC.title_prefex] = title
             
             list.list_items.append(dic)

         }
         


         list.didSelect = { [weak self] data in
             let dic = data
             let title = dic[options_listVC.title_prefex] as? String ?? ""
             if title == "All"
             {
                 self!.shift_id = nil
                 self!.btnSelectShift.setTitle("All", for: .normal)

             }
             else
             if title == "By Time"
             {
                 self!.shift_id = nil
                 self!.btnSelectShift.setTitle("By Time", for: .normal)

             }else
                 {
                     self!.shift_id = dic["id"] as? Int
                     self!.btnSelectShift.setTitle(title, for: .normal)
                     
                 }
             
             self!.loadReport()
         }
           
         
         list.clear = {
             self.shift_id = nil
             self.btnSelectShift.setTitle("By Time", for: .normal)
             
                          list.dismiss(animated: true, completion: nil)

                     }

         
         self.present(list, animated: true, completion: nil)

     }
 
 @IBAction func btnStartDate(_ sender: Any) {
     showCalendarTimePicker(forStartDate: true)
     
//     let calendar = calendarVC()
//
//     if self.start_date != nil
//     {
//         calendar.startDate = Date(strDate: self.start_date!, formate: self.date_formate, UTC: true)
//     }
//     
//     calendar.modalPresentationStyle = .formSheet
//     calendar.didSelectDay = { [weak self] date in
//         
//         
//         self?.start_date = date.toString(dateFormat:self!.date_formate)
//         self?.btnStartDate.setTitle( self?.start_date, for: .normal)
//         
//         self?.end_date = date.toString(dateFormat:self!.date_formate)
//         self?.btnEndDate.setTitle( self?.end_date, for: .normal)
//         
//        
//         //          self?.doneSelect()
//         calendar.dismiss(animated: true) {
//             self?.presentUTCTimePicker(seed: date)
//         }
//         
//     }
//    self.present(calendar, animated: true, completion: nil)
 }
 
 @IBAction func btnEndDate(_ sender: Any) {
     showCalendarTimePicker(forStartDate: false)
//     let calendar = calendarVC()
//
//     if self.end_date != nil
//     {
//         calendar.startDate = Date(strDate: self.end_date!, formate:self.date_formate, UTC: true)
//     }
//     
//     calendar.modalPresentationStyle = .formSheet
//     calendar.didSelectDay = { [weak self] date in
//         
//         
//         self?.end_date = date.toString(dateFormat: self!.date_formate)
//         self?.btnEndDate.setTitle(self?.end_date, for: .normal)
//         
//         
////          self?.doneSelect()
//         
//         calendar.dismiss(animated: true, completion: nil)
//
//     }
//    self.present(calendar, animated: true, completion: nil)
 }
 
    func get_start_date() -> String
    {
        let date_str = start_date!
        let checkDay = baseClass.get_date_local_to_search(DateOnly: date_str, format: date_formate ,returnFormate: "yyyy-MM-dd")
        
        return checkDay
    }
    
    func get_end_date() -> String
    {
        let date_str = end_date!
        
        let endDaty_str = baseClass.get_date_local_to_search(DateOnly: date_str, format: date_formate ,returnFormate: "yyyy-MM-dd",addHours: 24)
        
        return endDaty_str
    }
    func doneSelect() -> Bool {
        let def = baseClass.compareTwoDate(start_date!, dt2_new: end_date!, formate: date_formate)
        if def < 0
        {
            //end_date = start_date
            printer_message_class.show("invaled date: To date should be greater than From date", vc: self)
            return false
        }
        else
        {
            loadReport()
            return true
        }
        
        
    }
    
    private func showCalendarTimePicker(forStartDate: Bool) {
        let pickerVC          = DateTimePickerVC()
        if forStartDate {
            let dateTimeString = (start_date ?? "") //+ " " + (start_time ?? "00:00 am")
            let dateTime = Date().toDate( dateTimeString , format:  baseClass.date_fromate_satnder_12h)
            pickerVC.initialDate  = dateTime

        }else{
            let dateTimeString = (end_date ?? "") //+ " " + (end_time ?? "00:00 am")
            let dateTime = Date().toDate( dateTimeString , format:  baseClass.date_fromate_satnder_12h)
            pickerVC.initialDate  = dateTime

        }
        pickerVC.onPicked     = { [weak self] date, time in
            guard let self = self else { return }
            // format & assign to your labels
            if forStartDate {
                self.start_date = date
                self.start_time = time
                self.start_date = date + " " + time
                self.btnStartDate.setTitle(self.start_date, for: .normal)
            } else {
                self.end_date = date
                self.end_time = time
                self.end_date = date + " " + time

                self.btnEndDate.setTitle(self.end_date , for: .normal)
            }
            
        }

        let cardSize = CGSize(width: 380, height: 420)
        pickerVC.modalPresentationStyle = .formSheet
        pickerVC.preferredContentSize   = cardSize
        present(pickerVC, animated: true)
    }
    
    private func presentUTCTimePicker(seed date: Date) {

        let pickerVC = UTCTimePickerVC()
        pickerVC.initialDate = date

        pickerVC.onTimePicked = { [weak self] utcDate in
            guard let self = self else { return }
            self.start_time = self.formatter.string(from: utcDate)
            print("Selected Time: \(self.start_time)")
        }
        pickerVC.preferredContentSize = CGSize(width: 320, height: 280)
        pickerVC.modalPresentationStyle = .formSheet
        present(pickerVC, animated: true)
    }

    
    func loadReport()
    {
                  dictionary.removeAll()
               
                //let start_date =  get_start_date()
               // let end_date =  get_end_date()
        
           

        option.between_start_session = []

        if withParseDate{
            let start_date =  get_start_date()
            let end_date =  get_end_date()

            option.between_start_session?.append(start_date)
            option.between_start_session?.append(end_date)

        }else{
            option.between_start_session?.append(self.start_date!)
            option.between_start_session?.append(self.end_date!)

        }
        
                option.sesssion_id = shift_id  ?? 0
                option.parent_product = true
                option.write_pos_id = SharedManager.shared.posConfig().id
        let shiftName = btnSelectShift.titleLabel?.text ?? ""
        let start_date = btnStartDate.titleLabel?.text ?? ""
        let end_date = btnEndDate.titleLabel?.text ?? ""

       if shiftName.lowercased().contains("by time") {
            let start_date =   baseClass.get_date_local_to_search(DateOnly: start_date, format: date_formate ,returnFormate:  baseClass.date_formate_database)
            let end_date =   baseClass.get_date_local_to_search(DateOnly: end_date, format: date_formate ,returnFormate:  baseClass.date_formate_database)

            self.option.betweenDate = "'\(start_date)' And '\(end_date)'"
        }else{
            self.option.betweenDate = nil
        }
        var dic:[String:Any] = [:]
        dic["option"] = option
        dic["shift_name"] =  btnSelectShift.titleLabel?.text
        dic["start_date"] =  btnStartDate.titleLabel?.text
        dic["end_date"] =  btnEndDate.titleLabel?.text

        self.didSelect!(dic)
        
//                showActivityIndicator()
//                DispatchQueue.global(qos: .userInteractive).async {
//                    self.html = self.printOrder_html()
//                    SharedManager.shared.printLog( self.html )
//                    DispatchQueue.main.async {
//                        self.webView.loadHTMLString(self.html, baseURL:  Bundle.main.bundleURL)
//                    }
//                }
    }
    
   
    @IBAction func btn_ok(_ sender: Any) {
        if self.doneSelect() {
            self.dismiss(animated: true, completion: nil)
        }
    }
    @IBAction func btn_cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)

    }
    
}
