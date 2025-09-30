//
//  ordersStatisticsViewController.swift
//  pos
//
//  Created by Khaled on 12/11/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

class ordersStatisticsViewController: UIViewController ,UITableViewDelegate ,UITableViewDataSource{

 
    @IBOutlet var tableview: UITableView!
    var list_items:  [Any] = []
    
    var parent_vc:UIViewController!
    var day :String? = ""
    var day_formate :String? = ""
    
    
    
    var session_status :String? = ""
    var business_day :String? = ""
    
    var shift_id  :String? = ""
    var shift_start_date :String? = ""
    var shift_end_date :String? = ""
    var shift_start_balance  :String? = ""
    var shift_end_balance  :String? = ""
    var cashierID:Int?

    
    
    

    var cls_ordersStatistics:ordersStatistics?
    var tapGesture: UITapGestureRecognizer?

    override func viewDidLoad() {
        super.viewDidLoad()
        AppStoreUpdate.shared.initalAppStore()

        tableview.delegate = self
        tableview.dataSource = self
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapPrintLastSession(_:)))
       
//        DispatchQueue.global(qos: .background).async {
//            self.cls_ordersStatistics = ordersStatistics().getOrders_statistics(day: self.day ?? "", formate: self.day_formate ?? "")
//
//      reloadTable()
//        }
        
        
    }
    @objc func tapPrintLastSession(_ sender:UITapGestureRecognizer){
        
        self.printLastSession()
    }
    @objc func tapEnableTraining(_ sender:UISwitch){
        self.handle_traing_mode()
    }
    @objc func tapUpdateVersionBtn(_ sender:UIButton){
        AppStoreUpdate.shared.openAppStore()

    }
   
    func printLastSession(){
        if let image =  FileMangerHelper.shared.getLastSessionImageReport(){
            loadingClass.show(view:self.view)
            runner_print_class.runPrinterReceipt(  logoData: image , openDeawer: false)
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: {
                loadingClass.hide(view: self.view)
            })
           
        }else{
        let storyboard = UIStoryboard(name: "reports", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "zReport") as! zReport
        if let lastSession = pos_session_class.getLastSession(){
            vc.activeSessionLast = lastSession
            vc.shift_id = lastSession.id
            vc.print_inOpen = true
            vc.auto_close = true
            vc.custom_header = "End session".arabic("نهايه الجلسه") //"Last session report".arabic("تقرير اخر جلسة")
            
            
            vc.hideNav = true
            vc.forLockDriver = (SharedManager.shared.posConfig().pos_type?.lowercased().contains("driver_screen") ?? false)
            
//            vc.modalPresentationStyle = .fullScreen

            parent_vc.present(vc, animated: true, completion: nil)
        }else{
            messages.showAlert("No session found to print".arabic("لا يوجد جلسات لطباعة"))
        }
        }

       
    }
    func reloadTable()  {
     
            self.reloadTable_async()
        
        
    }
 
    func reloadTable_async()
    {
        
     

        self.list_items.removeAll()
        
        let pos = SharedManager.shared.posConfig()
        if AppStoreUpdate.shared.isNeedToUpdate ?? false{
            let app_version = AppStoreUpdate.shared.appStoreVersion ?? ""
            
            self.list_items.append([ LanguageManager.text("Please,update version to \(app_version)" , ar:  "برجاء تحديث النسخة الي   \(app_version) ") , "update_verion"])
        }
//        self.list_items.append([ LanguageManager.text( "Enable training mode", ar: "تفعيل وضع التدريب" ) ,
//                                 "training_mode" ])
        if !SharedManager.shared.posConfig().isMasterTCP(){
            if SharedManager.shared.appSetting().enable_add_waiter_via_wifi{
            self.list_items.append([ LanguageManager.text( "Current Ip", ar: "IP الحالي" ) ,  "\(MWConstantLocalNetwork.posHostServiceName)" ])
                
            self.list_items.append([ LanguageManager.text( "Device Type", ar: "نوع الجهاز" ) ,  "\(pos.getDeviceType())" ])
            }

        }else if SharedManager.shared.mwIPnetwork{
            self.list_items.append([ LanguageManager.text( "Device Type", ar: "نوع الجهاز" ) ,  "\(pos.getDeviceType())" ])
        }
        self.list_items.append([ LanguageManager.text( "Company name", ar: "الشركة" ) ,  "\(pos.company_name ?? "")" ])
        self.list_items.append([ LanguageManager.text( "Domain", ar: "الرابط" )  , api.getDomain() ])

        self.list_items.append([ LanguageManager.text( "POS", ar: "نقاط البيع" )  , pos.name ])
/*
        if cashierID != nil
        {
            if cashierID != 0
            {
                self.list_items.append([ LanguageManager.text("Session open by" , ar: "تم فتح الجلسه  من قبل" ) ,   res_users_class.get(id: cashierID!)!.name ] )
            }
    
        }
        */
        /*
        if shift_id != ""
             {
            self.list_items.append([ LanguageManager.text("Session number" , ar: "رقم الجلسة" ) , shift_id ])
             }
         */
        
        if session_status != ""
        {
            self.list_items.append([ LanguageManager.text("Session Status" , ar: "حالة الجلسة" ) , self.session_status ])

        }
        
        if business_day != ""
        {
            self.list_items.append([ LanguageManager.text("Business day" , ar: "يوم العمل" ) , self.business_day ])

        }
       
         
        if shift_start_date != ""
        {
            self.list_items.append([ LanguageManager.text( "Session start at", ar: "تبدأ الجلسة في" ) , shift_start_date ])
        }
        
//        if shift_end_date != ""
//        {
          //  self.list_items.append([ LanguageManager.text( "Session end at" , ar: "تنتهي الجلسة في" ), shift_end_date ])
//        }
        
//        if shift_start_balance != ""
//        {
            self.list_items.append([ LanguageManager.text("Start balance"  , ar: "بداية الرصيد" ), shift_start_balance ])
//        }
//        if shift_end_balance != ""
//        {
            self.list_items.append([ LanguageManager.text("End balance" , ar: "نهاية الرصيد" ) , shift_end_balance ])
//        }
        
        self.list_items.append([ LanguageManager.text("Version" , ar:  "الإصدار") , Bundle.main.fullVersion ])


        
        let chasher = SharedManager.shared.activeUser()

      //  self.list_items.append([ LanguageManager.text("Login user Name" , ar:  "اسم المستخدم") , chasher.name ])
        
        self.list_items.append([ LanguageManager.text("Upload /  Last upload at" , ar:  "رفع / تم الرفع فى ") , uploadAWS3.getLastUploadUrlLastPath() ])
        if SharedManager.shared.appSetting().show_print_last_session_dashboard{
            self.list_items.append([ LanguageManager.text( "Print last session report", ar: "طباعة تقرير اخر جلسة" ) ,  "" ])
        }
       
        
         
//        self.list_items.append(["Number of orders" , self.cls_ordersStatistics!.number_of_orders ])
//              self.list_items.append(["Value of orders" , self.cls_ordersStatistics!.value_of_orders ])
//              self.list_items.append(["Number of return" , self.cls_ordersStatistics!.number_of_return ])
//              self.list_items.append(["Value of return_orders" , self.cls_ordersStatistics!.value_of_return_orders ])
//              self.list_items.append(["Number of void orders" , self.cls_ordersStatistics!.number_of_void_orders ])
//              self.list_items.append(["Value of void orders" , self.cls_ordersStatistics!.value_of_void_orders ])
//              self.list_items.append(["Number of void products" , self.cls_ordersStatistics!.number_of_void_products] )
//              self.list_items.append(["Value of void products" , self.cls_ordersStatistics!.value_of_void_products ])

              self.tableview.reloadData()
    }
    
 
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
//        let obj =   list_items[indexPath.row] as! [String:Any]
        let obj =   list_items[indexPath.row] as! [Any]
        let key = obj[0] as? String
        let value = obj[1]  as? String
        if (key == "Print last session report" || key == "طباعة تقرير اخر جلسة") && (value == "") {
            self.printLastSession()
        }
        else if (key == "Upload /  Last upload at"  || key == "رفع / تم الرفع فى ")
        {
            AppDelegate.shared.auto_export.upload_all()
            messages.showAlert("Backup is  in process".arabic("جارى الرفع فى الخلفيه"))
        }else if ( key == "Domain" || key == "الرابط" ){
            if let urlString = value, let url = URL(string: urlString){
                UIApplication.shared.openURL(url)
            }
        }
        
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list_items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ordersStatisticsTableViewCell
       
        cell.enable_sw.isHidden = true
        cell.btn_cell.isHidden = true
        cell.btn_cell.setTitle("", for: .normal)
        cell.containerView.backgroundColor = .clear

        let obj =   list_items[indexPath.row] as! [Any]
        let key = obj[0] as? String
        let value = obj[1]  as? String
        
        cell.lblName.text = key
        cell.lblValue.text = value
        if let tapGesture = self.tapGesture{
        cell.contentView.removeGestureRecognizer(tapGesture)
        }
        if value == "Open"
        {
            cell.lblValue.textColor = UIColor.blue
        }
        else  if value == "Closed"
        {
            cell.lblValue.textColor = UIColor.red
        }
        else if (key == "Print last session report" || key == "طباعة تقرير اخر جلسة") && (value == "") {
                cell.lblName.textColor = #colorLiteral(red: 0.9764705882, green: 0.4672009945, blue: 0.04901309311, alpha: 1)
                if let tapGesture = self.tapGesture{
                    cell.contentView.addGestureRecognizer(tapGesture)
                }
            cell.printerImage.isHidden = false
        }else if is_key_train_mode(key:key ?? "",value: value ?? "" ) {
            cell.enable_sw.isHidden = false
            cell.lblValue.text = ""
            cell.enable_sw.isOn = SharedManager.shared.appSetting().enable_traing_mode
            cell.enable_sw.addTarget(self, action: #selector(tapEnableTraining(_:)), for: .valueChanged)
            
        }else if is_key_update_mode(key:key ?? "",value: value ?? "" ){
            cell.btn_cell.isHidden = false
            cell.lblName.text = key
            cell.lblName.textColor = #colorLiteral(red: 0.928860724, green: 0.1337852776, blue: 0.221417129, alpha: 1)
            cell.lblValue.text = ""
            cell.btn_cell.setTitle((" "+"Update version"+" ").arabic((" "+"تحديث النسخة"+" ")), for: .normal)
            cell.btn_cell.addTarget(self, action: #selector(tapUpdateVersionBtn(_:)), for: .touchUpInside)
           
        }
        else if (key == "Upload /  Last upload at"  || key == "رفع / تم الرفع فى ")
        {
            cell.lblName.textColor = #colorLiteral(red: 0.1960784346, green: 0.3411764801, blue: 0.1019607857, alpha: 1)
            cell.lblName.font = UIFont.boldSystemFont(ofSize: 17)
         }
        else{
                cell.lblName.textColor = #colorLiteral(red: 0.4470588235, green: 0.4470588235, blue: 0.4470588235, alpha: 1)
                cell.lblValue.textColor =  cell.lblName.textColor
            }

        
       
        
        
        return cell
    }
    
    private func is_key_train_mode(key:String,value:String )->Bool{
        return (value == "training_mode")
    }
    private func is_key_update_mode(key:String,value:String )->Bool{
        return value.lowercased().contains("update_verion")
    }
    func handle_traing_mode(){
        let setting = settingClass(fromDictionary: [:])
        setting.enable_traing_mode = !SharedManager.shared.appSetting().enable_traing_mode
        setting.save()
        if setting.enable_traing_mode == false {
            pos_order_class.reset()
            pos_order_line_class.reset()
            pos_order_account_journal_class.reset()
        }
        self.tableview.reloadData()
        if let parent = self.parent_vc as? baseViewController {
            parent.init_traing_mode()
        }
        
    }
}

extension pos_order_class {
   
    static func reset(temp:Bool = false)
       {
       var table = "pos_order"
       if temp
       {
          table =   "temp_"  + table
       }
       
             let cls = pos_order_class(fromDictionary: [:])
        _ =  cls.dbClass?.runSqlStatament(sql: "delete from \(table)")
      }
}

extension pos_order_line_class {
    static func reset(temp:Bool = false)
       {
       var table = "pos_order_line"
       if temp
       {
          table =   "temp_"  + table
       }
       
             let cls = pos_order_line_class(fromDictionary: [:])
        _ =  cls.dbClass?.runSqlStatament(sql: "delete from \(table)")
      }
}

extension pos_order_account_journal_class {
    static func reset(temp:Bool = false)
       {
       var table = "pos_order_account_journal"
       if temp
       {
          table =   "temp_"  + table
       }
       
             let cls = pos_order_account_journal_class(fromDictionary: [:])
        _ =  cls.dbClass?.runSqlStatament(sql: "delete from \(table)")
      }
}
