//
//  SharedManager.swift
//  pos
//
//  Created by Khaled on 1/21/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import UIKit
import BRYXBanner
import FirebaseCrashlytics

class SharedManager  {
    static let shared = SharedManager()
    
    var mwIPnetwork:Bool{
        get{
           // let supportKDS = self.appSetting().enable_add_kds_via_wifi
            let supportWaiter = self.appSetting().enable_add_waiter_via_wifi
            let sequenuceIP = self.appSetting().enable_sync_order_sequence_wifi
            let masterOnly = self.appSetting().enable_sequence_at_master_only
//            return supportKDS || supportWaiter || sequenuceIP || masterOnly
            return  supportWaiter || sequenuceIP || masterOnly

        }
    }
    var session_expired :Bool = false
    
    // DataBase
    var domain_url:String?
    
    var database_path_str:String?
    var log_path_str:String?
    var dataBasePath_printer_log:String?
    var dataBasePath_ingenico_log:String?
    var dataBasePath_multipeer:String?
    var dataBasePath_mesages_ip_log:String?

    private var poll_obj:pos_multi_session_sync_class?
    
    private var db_database:FMDatabaseQueue?
    private var log_database:FMDatabaseQueue?
    private var printer_log_database:FMDatabaseQueue?
    private var ingenico_log_database:FMDatabaseQueue?
    private var multipeer_log_database:FMDatabaseQueue?
    private var message_ip_log_database:FMDatabaseQueue?

    let check_total = discount_percent_on_total_amount_class()
    var cashWorkingIP:String = ""
    var activeSessionShared:pos_session_class?
    var pos_categ_ids: [Int] = []

    var poll:pos_multi_session_sync_class?
    {
        get
        {
            if poll_obj == nil
            {
                poll_obj = pos_multi_session_sync_class(fromDictionary: [:])
            }
            
            return poll_obj
        }
    }
    
    var poll_updates = pos_multi_session_updates()
    
    
    // printer
    // Defualt printer always at index 0
    var printers_pson_print:[Int:epson_printer_class] = [:]
    var epson_queue:epson_queue_class! = epson_queue_class()
    
    
    var database_db:FMDatabaseQueue? {
        get
        {
            return check_database()
        }
    }
    
    var log_db:FMDatabaseQueue? {
        get
        {
            return check_log()
        }
    }
    
    var printer_log_db:FMDatabaseQueue? {
        get
        {
            return checkDB_printer_log()
        }
    }
    var multipeer_log_db:FMDatabaseQueue? {
        get
        {
            return checkDB_multipeer_log()
        }
    }
    var ingenico_log_db:FMDatabaseQueue? {
        get
        {
            return checkDB_ingenico_log()
        }
    }
    var message_ip_log_db:FMDatabaseQueue? {
        get
        {
            return checkDB_mesages_ip_log()
        }
    }
    
    private var pos_config_shared:pos_config_class?
    private var active_res_users:res_users_class?
    private var app_settings:settingClass?
    private var shared_con:api?
    private var order_void_id:Int?
    private var multiPeerSession:MultiPeerManager?
    var banner: Banner?
    lazy var qrCodeGenerator: QRCodeGenerator = QRCodeGenerator.shared
    var invoiceComposer:InvoiceComposer?
    var selected_pos_brand:res_brand_class?{
        get{
          return res_brand_class.getSelectedBrandIfEnableSetting()
        }
    }
    var selected_pos_brand_id:Int?{
        get{
          return selected_pos_brand?.id
        }
    }

    var selected_pos_brand_name:String?{
        get{
          return selected_pos_brand?.display_name
        }
    }
    var getBrandReport:Bool{
        get{
          return true
        }
    }
    var insuranceComposer:InsuranceBondReportComposer?
    var newCombo:Bool{
        get{
            return true //self.appSetting().enable_new_combo
        }
        }
    var lastActionDate:Date?
    
    var x509CertBase64:String?{
        get{
            return self.posConfig().binarySecurityToken
        }
        
    }
    var phase2InvoiceOffline:Bool?{
        get{
            let isSettingEnable = self.appSetting().enable_phase2_Invoice_Offline_default
            let isPOSSupport = self.posConfig().binarySecurityToken ?? ""

            return (isSettingEnable && !isPOSSupport.isEmpty)
        }
    }
    var privateKeyBase64:String?{
        get{
            return  self.posConfig().company.l10n_sa_private_key
        }
        
    }
    private var api_DB_name:String?
    var currentReadUIDs:[String] = []
    func addUidRead(_ uid:String){
        if !uid.isEmpty{
            currentReadUIDs.append(uid)
        }
    }
    func removeUidRead(_ uid:String){
        if !uid.isEmpty && currentReadUIDs.count > 0{
            currentReadUIDs.removeAll(where: {$0 == uid})
        }
    }
    func removeAllUid(){
        if  currentReadUIDs.count > 0{
            currentReadUIDs.removeAll()
        }
    }
    func checkUidRead(_ uid:String) -> Bool{
        if !uid.isEmpty && currentReadUIDs.count > 0{
            
            return currentReadUIDs.contains(uid)
        }
        return false
    }
    func getNameDB() -> String?{
        if let api_DB_name = self.api_DB_name,!api_DB_name.isEmpty {
            return api_DB_name
        }else{
            self.api_DB_name = cash_data_class.get(key: "api_Database") ?? ""

        }
        return self.api_DB_name
    }
    func updateDBName(){
        self.api_DB_name = cash_data_class.get(key: "api_Database") ?? ""
    }
    func updateLastActionDate(){
        let secandToPass = self.appSetting().time_pass_to_go_lock_screen
        if secandToPass > 0 {
            lastActionDate = Date()
        }
    }
    func restLastActionDate(){
        lastActionDate = nil
    }
    func timeToNavigateLockScreen(){
        let secandToPass = self.appSetting().time_pass_to_go_lock_screen
        if secandToPass > 0 {
            if let lastActionDate = lastActionDate{
                let diffInSecand = date_base_class.getSecondDifferenceFromTwoDates(start:lastActionDate )
                SharedManager.shared.printLog("diffInSecand ==== \(diffInSecand)")
                if diffInSecand >= secandToPass{
                    self.restLastActionDate()
                    let last_session = pos_session_class.getLastSession()
                    AppDelegate.shared.login_users(activeSession: nil )
                }
            }
        }
    }

    func database_path(filename:String) -> String
    {
        let database_file = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(filename).appendingPathExtension("db")
        let toPath = database_file!.absoluteString.replacingOccurrences(of: "file://", with: "")
        
        
        
        let bundle = Bundle.main
        
        let url = bundle.path(forResource: filename, ofType: "db" )
        
        
        if !FileManager.default.fileExists(atPath: toPath) {
            do {
                try FileManager.default.copyItem(atPath: url!, toPath: toPath)
                //                   sleep(3)
            } catch {
                 SharedManager.shared.printLog(error)
            }
        }
        else
        {
           self.printLog("\(filename).db is fileExists")
            
        }
        
        return toPath
    }
    
    func check_database() -> FMDatabaseQueue
    {
        
        if self.database_path_str == nil
        {
            self.database_path_str = database_path(filename: "database")
           self.printLog("path :\(self.database_path_str ?? "")")
        }
        
        if db_database == nil
        {
            db_database =  FMDatabaseQueue.init(path: database_path_str)!
            
        }
        else
        {
            return db_database!
        }
        
        return db_database!
        
        
    }
    
    func check_log() -> FMDatabaseQueue
    {
        
        if self.log_path_str == nil
        {
            self.log_path_str = database_path(filename: "log")
           self.printLog("path : \(self.log_path_str ?? "")")
        }
        
        if log_database == nil
        {
            log_database =  FMDatabaseQueue.init(path: log_path_str)!
        }
        else
        {
            return log_database!
        }
        
        return log_database!
    }
    func checkDB_mesages_ip_log() -> FMDatabaseQueue
    {
        
        if self.dataBasePath_mesages_ip_log == nil
        {
            self.dataBasePath_mesages_ip_log = database_path(filename: "mesages_ip_log")
          printLog("path :\(self.dataBasePath_printer_log ?? "")")
        }
        
        
        if message_ip_log_database == nil
        {
            message_ip_log_database =  FMDatabaseQueue.init(path: dataBasePath_mesages_ip_log)!
        }
        else
        {
            return message_ip_log_database!
        }
        
        return message_ip_log_database!
        
        
    }
    func checkDB_printer_log() -> FMDatabaseQueue
    {
        
        if self.dataBasePath_printer_log == nil
        {
            self.dataBasePath_printer_log = database_path(filename: "printer_log")
           self.printLog("path :\(self.dataBasePath_printer_log ?? "")")
        }
        
        
        if printer_log_database == nil
        {
            printer_log_database =  FMDatabaseQueue.init(path: dataBasePath_printer_log)!
        }
        else
        {
            return printer_log_database!
        }
        
        return printer_log_database!
        
        
    }
    func checkDB_multipeer_log() -> FMDatabaseQueue
    {
        
        if self.dataBasePath_multipeer == nil
        {
            self.dataBasePath_multipeer = database_path(filename: "multipeer_log")
           self.printLog("path : \(self.dataBasePath_multipeer ?? "")" )
        }
        
        
        if multipeer_log_database == nil
        {
            multipeer_log_database =  FMDatabaseQueue.init(path: dataBasePath_multipeer)!
        }
        else
        {
            return multipeer_log_database!
        }
        
        return multipeer_log_database!
        
        
    }
    func checkDB_ingenico_log() -> FMDatabaseQueue
    {
        
        if self.dataBasePath_ingenico_log == nil
        {
            self.dataBasePath_ingenico_log = database_path(filename: "ingenico_log")
           self.printLog("path :\(self.dataBasePath_ingenico_log ?? "")")
        }
        
        
        if ingenico_log_database == nil
        {
            ingenico_log_database =  FMDatabaseQueue.init(path: dataBasePath_ingenico_log)!
        }
        else
        {
            return ingenico_log_database!
        }
        
        return ingenico_log_database!
        
        
    }
    
    
    func remove_database()
    {
        database_db?.close()
        
        removeDataBase_data(database: "database")
        self.database_path_str = nil
    }
    
    func remove_log()
    {
        log_db?.close()
        
        removeDataBase_data(database: "log")
        self.log_path_str = nil
    }
    func remove_message_ip_log()
      {
          message_ip_log_db?.close()
          
          removeDataBase_data(database: "mesages_ip_log")
          self.log_path_str = nil
      }
    
    func remove_printerlog()
      {
          printer_log_db?.close()
          
          removeDataBase_data(database: "printer_log")
          self.log_path_str = nil
      }
    func remove_multipeerlog()
      {
          multipeer_log_db?.close()
          
          removeDataBase_data(database: "multipeer_log")
          self.log_path_str = nil
      }
    func remove_ingenico_log()
      {
        ingenico_log_database?.close()
          
          removeDataBase_data(database: "ingenico_log")
          self.dataBasePath_ingenico_log = nil
      }
    
    func removeDataBase_data_old(database:String)
    {
        let database_file = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(database).appendingPathExtension("db")
        let toPath = database_file!.absoluteString.replacingOccurrences(of: "file://", with: "")


        if  FileManager.default.fileExists(atPath: toPath) {
            do {
                try FileManager.default.removeItem(atPath: toPath)
            } catch {
                 SharedManager.shared.printLog(error)
            }
        }

    }
    
     func removeDataBase_data(database:String)
     {

        let new_folder = create_new_folder()
        if new_folder != nil
        {
            let new_path = new_folder! + "/" + database
            
            let database_file = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(database).appendingPathExtension("db")
            let fromPath = database_file!.absoluteString.replacingOccurrences(of: "file://", with: "")
            
            let database_file_new = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(new_path).appendingPathExtension("db")
            let toPath = database_file_new!.absoluteString.replacingOccurrences(of: "file://", with: "")
            
            if  FileManager.default.fileExists(atPath: fromPath) {
                do {
                    try FileManager.default.moveItem(atPath: fromPath, toPath: toPath)
                } catch {
                     SharedManager.shared.printLog(error)
                }
            }
        }
        
     }
    
    
    func create_new_folder() -> String?
    {
        let date = Date().toString(dateFormat:"yyyy-MM-dd_hh_mm_ss_a", UTC: true)

        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let docURL = URL(string: documentsDirectory)!
        let dataPath = docURL.appendingPathComponent(date)
        if !FileManager.default.fileExists(atPath: dataPath.absoluteString) {
            do {
                try FileManager.default.createDirectory(atPath: dataPath.absoluteString, withIntermediateDirectories: true, attributes: nil)
            } catch {
                SharedManager.shared.printLog(error.localizedDescription)
                return nil
            }
        }
        
        return date
    }
    
    func clearLogsDB(){
        let date_now:Date = Date()
        let older_date_str =  date_now.toString(dateFormat:baseClass.date_formate_database)
        let countPrinterLog = printer_log_class.countBefore(date: older_date_str)
        if countPrinterLog > 0
        {
            printer_log_class.deleteBefore(date: older_date_str)
            queue_log_class.deleteBefore(date: older_date_str)
            printer_log_class.init().dbClass?.vacuum_database()
            printer_error_class.reset()
        }
    }
    
    func loadImage(_ photo:UIImageView,base64String:String,handleHiden:Bool = false){
        DispatchQueue.global(qos: .userInitiated).async {
            let  logoData :UIImage? = UIImage.ConvertBase64StringToImage(imageBase64String:base64String )
                        DispatchQueue.main.async {
                            photo.isHidden = handleHiden
                            if let imageData = logoData {
                                photo.image = imageData
                                photo.isHidden = false
                            }
                        }
                    }
    }
    func getCashRunId() -> Int{
        let cashRunID =  cash_data_class.get(key: "cash_run_ID") ?? ""
        if !cashRunID.isEmpty{
            if let run_id = Int(cashRunID){
               return run_id
            }
        }
        return 0
    }
    func getCashDomainUserId() -> Int{
        let cashDomainUserId =  cash_data_class.get(key: "user_id") ?? ""
        if !cashDomainUserId.isEmpty{
            if let domain_user_id = Int(cashDomainUserId){
               return domain_user_id
            }
        }
        return 0
    }
    
    func posConfig() -> pos_config_class{
        if let config = self.pos_config_shared , !(config.name ?? "").isEmpty{
            return config
        }
        self.pos_config_shared = pos_config_class.getDefault()
        return self.pos_config_shared!
    }
    func getRiayalSymbol(total:String, fontSize:Double = 30) -> NSMutableAttributedString{
        let text = NSMutableAttributedString(string: " \(total) ")
        let symbol = NSAttributedString(string: "\u{E900}", attributes: [
            .font: UIFont(name: "saudi_riyal", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
        ])
        text.insert(symbol, at: 0) // إضافة الرمز قبل الرقم
        return text
    }
    
    func getCurrencySymbol() -> String {
        let currentCurrency = self.posConfig().currency_name ?? "SAR"
        return currentCurrency.lowercased().contains("sar") ? "<span class='riyal-symbol'>\u{E900}</span>" : "EGP"
    }

    
    func getCurrencyName(_ isArabic:Bool = false) -> String{
        var currentCurrency = self.posConfig().currency_name ?? "SAR"
        if isArabic {
            currentCurrency = currentCurrency.lowercased().contains("sar") ? "ريال" : "جنيه"
        }
        return currentCurrency
    }
    func getTaxValueInvoice() -> Int{
        var currentCurrency = self.posConfig().currency_name ?? "SAR"
         return currentCurrency.lowercased().contains("sar") ? 15 : 14
    }
    
    func getClientCountry() -> String {
        var currentCurrency = self.posConfig().currency_name ?? "SAR"
        switch currentCurrency {
        case "EGP":
            return "Egypt"
        default:
            return "Saudi Arabia"
        }
    }
    
    func showQrCodeBill() -> Bool{
        var currentCurrency = self.posConfig().currency_name ?? "SAR"
         return currentCurrency.lowercased().contains("sar") ? true : false
    }
    private func setsConfigForPOS() {
        self.pos_config_shared = pos_config_class.getDefault()
    }
    
    func activeUser() -> res_users_class{
        if let user = self.active_res_users {
            return user
        }
        self.active_res_users = res_users_class.getDefault()
        return self.active_res_users!
    }
    private func setsActiveUser() {
        self.active_res_users = res_users_class.getDefault()
    }
    func appSetting() -> settingClass{
        if let settings = self.app_settings {
            return settings
        }
        self.app_settings = settingClass.getSettingClass()
        return self.app_settings!
    }
    func setsAppSettings() {
        self.app_settings = settingClass.getSettingClass()
    }
    func conAPI() -> api{
        if let con = self.shared_con {
            return con
        }
        self.shared_con = api()
        return self.shared_con!
    }
    private func setsSharedCon() {
        self.shared_con = api()
    }
    
    func setGloobalObject(){
        setsConfigForPOS()
        setsActiveUser()
        setsAppSettings()
        setsSharedCon()
        saveDeviceInfo()
    }
    func resetGloobalObject(){
        self.pos_config_shared = nil
        self.active_res_users = nil
        self.app_settings = nil


    }
    func loadImageFrom(_ folder:APP_FOLDERS,in leaf:LEAF_FOLDERS = .none, with name:String,for photo:UIImageView,handleHiden:Bool = false){
        let imageName = name.partBeforeUnderscore()
        DispatchQueue.global(qos: .userInitiated).async {
            if imageName != nil, let image = FileMangerHelper.shared.getFile(from:folder,in :leaf , with:imageName!){
                DispatchQueue.main.async {
                    photo.isHidden = handleHiden
                    if (image != photo.image) {
                        photo.image = image
                    }
                    photo.isHidden = false
                }
            } else if let image = FileMangerHelper.shared.getFile(from:folder,in :leaf , with:name){
                DispatchQueue.main.async {
                    photo.isHidden = handleHiden
                    if (image != photo.image) {
                        photo.image = image
                    }
                    photo.isHidden = false
                }
            }else{
                DispatchQueue.main.async {
                photo.isHidden = true
                }
            }
        }
    }
    func isDiffVersion() -> Bool {
        let currentVersion = Bundle.main.fullVersion
        let storeVersion = UserDefaults.standard.string(forKey: "version_user_default")
        if storeVersion != currentVersion { return true }
        return true
    }
    func alterCashImagesDataBase(){
        DispatchQueue.global(qos: .userInitiated).async {
        let _ = product_product_class.getAll().map({product_product_class(fromDictionary: $0)})
        let _ = pos_category_class.getAll().map({pos_category_class(fromDictionary: $0)})
        let _ = res_users_class.getAll().map({res_users_class(fromDictionary: $0)})
        let _ = res_company_class.getAll().map({res_company_class(fromDictionary: $0)})
        }
    }
    func removeNotUsesFiles(from folder:APP_FOLDERS,in leaf:LEAF_FOLDERS = .none, filesName:[String],tagName:String? = nil){
        DispatchQueue.global(qos: .userInitiated).async {
            let directoryContents = FileMangerHelper.shared.getAllFilles(from:folder,in :leaf )
            for path in directoryContents {
                let nameFile = path.deletingPathExtension().lastPathComponent + ".png"
                if let tagName = tagName {
                    if !nameFile.contains(tagName){
                        continue
                    }
                }
                if !filesName.contains(nameFile) {
                    FileMangerHelper.shared.removeFile(from: folder,in:leaf,with:nameFile )
                }
            }
        }
    }
    func remove_user_default()
      {
        UserDefaults.standard.removeObject(forKey: "version_user_default")
      }
    func openVoidResonVC(void_lines:[pos_order_line_class], vc:UIViewController,completion:@escaping()->()){
        if self.appSetting().enable_enter_reason_void{
            
            let dataList = void_reason_class.get_all()
            let selectVoidReasonvc:SelectReasonVoidVC = SelectReasonVoidVC.createModule(nil,selectDataList:  [],dataList:dataList)
            selectVoidReasonvc.completionBlock = { selectDataList in
                    if  selectDataList.count > 0{
                        let voidReasonTF = selectDataList.compactMap({$0.name}).joined(separator: "\n ")
                        void_lines.forEach { voidLine in
                            voidLine.return_reason = voidReasonTF
                           let _ = voidLine.save()
                        }
                    }
                completion()

                }
            vc.present(selectVoidReasonvc, animated: true, completion: nil)
            
            return
        }else{
            completion()

        }

    }
    func premission_for_void_line(line:pos_order_line_class, vc:UIViewController, completion:@escaping()->()){
        DispatchQueue.main.async{
            /*
        if !MWMasterIP.shared.isOnLine(){
            messages.showAlert( "Check master device".arabic("  تحقق من اتصال الجهاز الرئيسي"), title:"")
            return
        }
             */
        let pos = self.posConfig()
        let is_allow_pin = pos.allow_pin_code
            if  line.is_sent_to_kitchen() || line.isSendToMultisession()
        {

            //voidـorder_after_send
            if !self.activeUser().canAccess(for: .voidـorder_after_send) {
                if is_allow_pin {
                        
                    self.openPincode(for :vc,rule: rule_key.voidـorder_after_send){
                            self.openVoidResonVC(void_lines: [line], vc: vc,completion: completion)

                        }
                    return
                }
//                else{
//                    guard  rules.check_access_rule(rule_key.voidـorder_after_send) else {
//                        return
//                    }
//                }
            }

        }
        else
        {
            if !self.activeUser().canAccess(for: .voidـorder_before_send)  {
                if is_allow_pin {
                    self.openPincode(for :vc,rule: rule_key.voidـorder_before_send) {
                            self.openVoidResonVC(void_lines: [line],vc: vc,completion: completion)
                        }
                    return
                }
//                else{
//                    guard  rules.check_access_rule(rule_key.voidـorder_before_send) else {
//                        return
//                    }
//                }
            }
        }
            self.openVoidResonVC(void_lines: [line],vc: vc,completion: completion )
        }
    }
    func premission_for_void_order(order:pos_order_class, vc:UIViewController, completion:@escaping()->()){
        DispatchQueue.main.async{
            if !MWMasterIP.shared.isOnLine(){
                messages.showAlert( "Check master device".arabic("  تحقق من اتصال الجهاز الرئيسي"), title:"")
                return
            }
        let pos = self.posConfig()
        let is_allow_pin = pos.allow_pin_code
        if  order.is_send_toKDS() || order.isSendToMultisession()
        {
            //voidـorder_after_send
//            if !rules.check_access_rule(rule_key.voidـorder_after_send,show_msg: false) {
                if !self.activeUser().canAccess(for: rule_key.voidـorder_after_send)  {

                if is_allow_pin {
                        
                    self.openPincode(order:order,for :vc,rule:.voidـorder_after_send){
                            self.openVoidResonVC(void_lines: order.pos_order_lines ,vc: vc,completion: completion)
                        }
                    return
                }
//                    else{
//                    guard  rules.check_access_rule(rule_key.voidـorder_after_send) else {
//                        return
//                    }
//                }
            }

        }
        else
        {
            //voidـorder_before_send
//            if !rules.check_access_rule(rule_key.voidـorder_before_send,show_msg: false) {
                if !self.activeUser().canAccess(for: .voidـorder_before_send)  {

                if is_allow_pin {
                    self.openPincode(order:order,for :vc,rule:rule_key.voidـorder_before_send){
                            self.openVoidResonVC(void_lines: order.pos_order_lines ,vc: vc,completion: completion)
                        }
                    return
                }
//                    else{
//                    guard  rules.check_access_rule(rule_key.voidـorder_before_send) else {
//                        return
//                    }
//                }
            }
        }
            self.openVoidResonVC(void_lines: order.pos_order_lines,vc: vc,completion: completion)
        }
    }
    func premission_for_decrease_qty(line:pos_order_line_class, vc:UIViewController, completion:@escaping()->()){
        DispatchQueue.main.async{
            let pos = self.posConfig()
            let is_allow_pin = pos.allow_pin_code
            if  line.is_send_toKDS() || line.isSendToMultisession()
            
            //if  order.is_send_toKDS() || order.isSendToMultisession()
            {
                //voidـorder_after_send
                rules.check_access_rule(rule_key.voidـorder_after_send,for: vc) {
                    DispatchQueue.main.async {
                        
                    self.openVoidResonVC(void_lines: [line], vc: vc,completion: completion)
                }

//                    if is_allow_pin {
//                        self.openPincode(for :vc){
//                            self.openVoidResonVC(void_lines: [line], vc: vc,completion: completion)
//                        }
//                        return
//                    }else{
//                        guard  rules.check_access_rule(rule_key.voidـorder_after_send) else {
//                            return
//                        }
//                    }
                }
                
//                else {
//                    self.openVoidResonVC(void_lines: [line], vc: vc,completion: completion)
//                }
                
            } else {
                /* else
                 {
                 //voidـorder_before_send
                 if !rules.check_access_rule(rule_key.voidـorder_before_send,show_msg: false) {
                 if is_allow_pin {
                 self.openPincode(order:order,for :vc, completion:completion)
                 return
                 }else{
                 guard  rules.check_access_rule(rule_key.voidـorder_before_send) else {
                 return
                 }
                 }
                 }
                 }
                 */
                // self.openVoidResonVC(void_lines: [line], vc: vc,completion: completion)
                completion()
            }
        }
    }
    func openPincode(for vc:UIViewController, title:String? = nil,rule:rule_key, completion:@escaping()->()){
        DispatchQueue.main.async{
            let storyboard = UIStoryboard(name: "loginStoryboard", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "pinCode") as! pinCode
            controller.mode_get_only = true
            controller.title_vc = title ?? "Please enter pin code .".arabic("من فضلك ادخل الرقم السرى")
            controller.completionEnterPin = { [weak vc] (_ code) in
                guard let _ = vc else {
                    return
                }
                let pos = self.posConfig()
                if pos.pin_code != code {
                    self.printLog("\( pos.pin_code )",force: true)
                    loadingClass.show()
                    
                    //                if let viewVC = vc?.view{
                    //                    loadingClass.show(view:viewVC)
                    //
                    //                }
                    OTPInteractor.shared.checkOtp("\(code)") { result in
                        if let viewVC = vc?.view{
                            loadingClass.hide(view:viewVC)
                            
                        }
                        if !result {
                            //                        messages.showAlert("invalid pin code".arabic("الرقم السرى خطأ"))
                            SharedManager.shared.initalBannerNotification(title:  "Not Allowed".arabic("غير مسموح"), message: "You don't have a permission for  \(rule.rawValue)".arabic("ليس لديك إذن \(rule.getOtherLang())"), success: false, icon_name: "")
                            SharedManager.shared.banner?.dismissesOnTap = true
                            SharedManager.shared.banner?.show(duration: 3)
                            self.printLog(pos.pin_code)
                            return
                        }else{
                            self.completeLineValidOTP(completion:completion)
                        }
                        return
                    }
                    return
                }
                self.completeLineValidOTP(completion:completion)
            }
            vc.present(controller, animated: true, completion: nil)
        }
    }
    func openPincode(order:pos_order_class?,for vc:UIViewController,rule:rule_key? = nil, completion:@escaping()->()){
        if let order = order{
        if self.order_void_id == order.id {
            completion()
            return
        }}
        let storyboard = UIStoryboard(name: "loginStoryboard", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "pinCode") as! pinCode
        controller.mode_get_only = true
        controller.title_vc = "Please enter pin code .".arabic("من فضلك ادخل الرقم السرى")
        controller.completionEnterPin = { [weak vc] (_ code) in
            guard let _ = vc else {
                return
            }
            let pos = self.posConfig()
            if pos.pin_code != code {
                self.printLog("\( pos.pin_code )",force: true)
                if let viewVC = vc?.view{
                    loadingClass.show(view:viewVC)

                }
                OTPInteractor.shared.checkOtp("\(code)") { result in
                    if let viewVC = vc?.view{
                        loadingClass.hide(view:viewVC)

                    }
                    if !result {
                       // messages.showAlert("invalid pin code".arabic("الرقم السرى خطأ"))
                        if let rule = rule{
                            SharedManager.shared.initalBannerNotification(title:  "Not Allowed".arabic("غير مسموح"), message: "You don't have a permission for  \(rule.rawValue)".arabic("ليس لديك إذن \(rule.getOtherLang())"), success: false, icon_name: "")
                            SharedManager.shared.banner?.dismissesOnTap = true
                            SharedManager.shared.banner?.show(duration: 3)
                        }else{
                            messages.showAlert("invalid pin code".arabic("الرقم السرى خطأ"))
                        }
                        self.printLog(pos.pin_code)
                    }else{
                        self.completeValidOTP(order:order,completion:completion)
                    }
                    return
                }
                return
            }
            self.completeValidOTP(order:order,completion:completion)
        }
        vc.present(controller, animated: true, completion: nil)
    }
    func completeValidOTP(order:pos_order_class?,completion:@escaping()->()){
        if let order = order{
        if self.order_void_id != order.id {
            self.order_void_id = order.id
        }
        }
        completion()
    }
    func completeLineValidOTP(completion:@escaping()->()){
        
        completion()
    }
    func reset_order_void_id(){
        self.order_void_id = nil
    }
    
  public  func multipeerSession() -> MultiPeerManager?
    {
        return  self.multiPeerSession
    }
    
    func initalMultipeerSession(){
       if appSetting().enable_sequence_orders_over_wifi {
        DispatchQueue.main.async {
            self.multiPeerSession = MultiPeerManager()
            self.multiPeerSession?.multiPeerSession()
        }
        }
    }
    func disCounectMultiPeer(){
//        if mwIpPos {
//            return
//        }
        DispatchQueue.main.async {
            if let multiPeerSession = self.multiPeerSession {
            multiPeerSession.mcSession.disconnect()
            multiPeerSession.mcSession = nil
            self.multiPeerSession = nil
            }
        }
    }
    func getSequenceFromMultipeer() -> Int?{
        if appSetting().enable_sequence_orders_over_wifi {

        if let multiPeerSession = self.multiPeerSession {
            return multiPeerSession.sequenseNumber
        }
            return nil

        }
        return nil
    }
    func resetSequenceFromMultipeer()  {
        if appSetting().enable_sequence_orders_over_wifi {

        if let multiPeerSession = self.multiPeerSession {
              multiPeerSession.sequenseNumber = 1
        }
 
        }
     
    }
    func sendNewSeqToPeers(nextSeq:Int){
//        if mwIpPos {
//            return
//        }
        if appSetting().enable_sequence_orders_over_wifi {
            let currentSeq = self.multiPeerSession?.sequenseNumber ?? 1
            if nextSeq > currentSeq {
                self.multiPeerSession?.sequenseNumber = nextSeq
            }else{
                self.multiPeerSession?.sequenseNumber+=1
            }
            multiPeerSession?.sendNewSeqToPeers()

        }
    }
    private func saveDeviceInfo(){
        DispatchQueue.main.async {
        let modelName = UIDevice.modelName
        let totalDiskSpaceInGiga = Double(UIDevice.current.totalDiskSpaceInBytes)  / Double(pow(1024.0, 3.0))
        let freeDiskSpace  = Double((UIDevice.current.freeDiskSpaceInBytes))/Double(pow(1024.0, 3.0))
        let usedDiskSpace = Double(UIDevice.current.usedDiskSpaceInBytes) / Double(pow(1024.0, 3.0))
        cash_data_class.set(key: "device_model_Name", value: modelName)
        cash_data_class.set(key: "total_disk_space_in_giga", value: "\(totalDiskSpaceInGiga)")
        cash_data_class.set(key: "free_disk_space_in_giga", value: "\(freeDiskSpace)")
        cash_data_class.set(key: "used_disk_space_in_giga", value: "\(usedDiskSpace)")
        }
    }
    func isFreeSpaceLow1GB() -> Bool{
        if let free_space = Double(cash_data_class.get(key: "free_disk_space_in_giga") ?? "2.0") , free_space < 1.0 {
           return true
        }
        return false
    }
    func initalBannerNotification(title:String,message:String,success:Bool, icon_name:String)  {
//        let red = UIColor(red:198.0/255.0, green:26.00/255.0, blue:27.0/255.0, alpha:1.000)
           let green = UIColor(red:48.00/255.0, green:174.0/255.0, blue:51.5/255.0, alpha:1.000)
         let yellow = #colorLiteral(red: 0.9682098031, green: 0.5096097589, blue: 0.1061020121, alpha: 1)//UIColor(red:255.0/255.0, green:204.0/255.0, blue:51.0/255.0, alpha:1.000)
        banner?.dismiss()
         banner = Banner(title: title,
                           subtitle: message,
                           image: UIImage(named: icon_name),
                           backgroundColor: success ? green:yellow )
    }
    
    func report_memory(prefix:String) {
        var taskInfo = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &taskInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        var memory_in_bytes:String = "0";
        if kerr == KERN_SUCCESS {
            memory_in_bytes = "Memory used in bytes: \(taskInfo.resident_size)"
           self.printLog("Memory used in bytes: \(taskInfo.resident_size)")
        }
        else {
            memory_in_bytes = "Error with task_info(): " +
                (String(cString: mach_error_string(kerr), encoding: String.Encoding.ascii) ?? "unknown error")
           self.printLog("Error with task_info(): " +
                (String(cString: mach_error_string(kerr), encoding: String.Encoding.ascii) ?? "unknown error"))
        }
        let error = NSError(domain: "ReceiveMemoryWarning", code: 5004, userInfo:
            [
                "prefix:" :  "ReceiveMemoryWarning \(prefix)",
                "error:" : self.reportMemory(), //memory_in_bytes,
            ])
      
        Crashlytics.crashlytics().record(error: error)
    }
    func pathFireBase() -> String? {
        var path = ""
        var domainName = ""
        let pos = self.posConfig()
        guard let domainURL = URL(string:api.getDomain().lowercased())else{
            return nil
        }
        guard let hostName = domainURL.host else{
            return nil
        }
        let subStrings = hostName.components(separatedBy: ".")
        let count = subStrings.count
        if count > 2 {
            guard let subDomain = subStrings.first else{
                return nil
            }
            domainName = subDomain
        } else if count == 2 {
            domainName = hostName
        }
        SharedManager.shared.printLog(domainName)
        path += domainName.lowercased().replacingOccurrences(of: ".", with: "_")
        if  let pos_name = pos.name, !pos_name.isEmpty {
            let pos_id = pos.id
        path += "/" + "_\(pos_id)"
        }else{
            return nil
        }

//        if let brand_name = pos.brand_name {
//            path += "/" + brand_name
//        }
//        if let company_name = pos.company_name {
//            path += "/" + company_name
//        }
//        if let pos_name = pos.name, !pos_name.isEmpty  {
//            let name = pos_name.replacingOccurrences(of:"/", with: "_").replacingOccurrences(of: "[", with: "(").replacingOccurrences(of: "]", with: ")")
//            path += "/" + (name)
//        }else{
//            return nil
//        }
        return path.replacingOccurrences(of:" ", with: "_")
    }
    func pathFireBase(_ pos_id:Int,_ hostName:String) -> String? {
        var path = ""
        var domainName = hostName
        SharedManager.shared.printLog(domainName,force: true)
        path += domainName.lowercased().replacingOccurrences(of: ".", with: "_")
        path += "/" + "_\(pos_id)"
        return path.replacingOccurrences(of:" ", with: "_")
    }
    func getPosName() -> String?{
        let pos = self.posConfig()
        if  let pos_name = pos.name, !pos_name.isEmpty {
            return pos_name
        }
        return nil
    }
    func get_count_pending_orders()->Int{
       return pos_order_helper_class.getCountPrndingOrders()
    }
    func get_pending_orders() -> [pos_order_class]{
        let arr = pos_order_helper_class.getOrders_status_sorted(options: pendding_options())
        return arr
    }

    func pendding_options() -> ordersListOpetions
    {
        let opetions = ordersListOpetions()
        opetions.Closed = true
        opetions.Sync = false
        opetions.void = false
        opetions.LIMIT = 20
        opetions.write_pos_id = self.posConfig().id
        return opetions
    }
    

    func setInvoiceComposer(orderPrintBuilder:orderPrintBuilderClass){
            invoiceComposer = InvoiceComposer(orderPrintBuilder)
    }
    func resetInvoiceComposer(){
        invoiceComposer = nil
    }
    func setInsuranceComposer(order:pos_order_class){
        insuranceComposer = InsuranceBondReportComposer(order,printerName: "insurance")
        SharedManager.shared.printLog(insuranceComposer?.objecPrinter)
    }
    func resetInsuranceComposer(){
        insuranceComposer = nil
    }
    func printOrder(_ order:pos_order_class, _ insurance_order:pos_order_class?,openDeawer:Bool = true)
    {
        var openDeawer = openDeawer
        let setting = self.appSetting()
        if setting.open_drawer_only_with_cash_payment_method == true
        {
        let is_paid_cash = order.list_account_journal.filter({$0.code == "CSH1"})
            if is_paid_cash.count == 0
            {
                openDeawer = false
            }
        }
        
        if order.amount_total == 0
        {
            openDeawer = false
        }
        pos_order_helper_class.increment_print_count(order_id: order.id!)
        DispatchQueue.global(qos: .background).async {
            let copy_numbers = self.appSetting().receipt_copy_number
            if copy_numbers > 0
            {
                let setting_printer = settingClass.getSetting()

                for _ in 1...copy_numbers
                {
                    self.epson_queue.add_job_printer(id:0,IP: setting_printer.ip,printer_name: (setting_printer.name ?? ""), order: order ,print_items_only: false ,openDeawer: openDeawer,index: 0,master: true)
                }
                if let insurance_order = insurance_order {
                    self.printInsuranceBill(insurance_order)
                }
                self.epson_queue.run()
            }
        }
    }
    func printInsuranceBill(_ order:pos_order_class)
    {
        let setting_printer = settingClass.getSetting()
        pos_order_helper_class.increment_print_count(order_id: order.id!)
        self.epson_queue.add_job_printer(id:-1,
                                                         IP: setting_printer.ip,
                                                         printer_name: setting_printer.name ?? "insurannce",
                                                         printer_type: "insurannce",
                                                         order:order ,
                                                         print_items_only:
                                                        true ,openDeawer: false,index: 0,master:false)
        
    }
    func is_account_journal_suport_geidea(id:Int) -> Bool{
        let support_geidea_ids = cash_data_class.get(key: "journal_accounts_support_geidea")
        let ids = support_geidea_ids?.components(separatedBy: ",") ?? []
        return ids.contains("\(id)")
    }
    var LogQueue = DispatchQueue(label: "LogQueue", qos: .background)

    func printLog(_ log:Any?,force:Bool = false){
        LogQueue.async {
            #if DEBUG
            if !force {
                return
            }
            guard let log = log else{
                print("nil")
                return
            }
            print("----------printLog----------------")
            print(log)
            print("--------------------------------------")
            #endif
        }
        
    }
    func createLogFile(){
#if DEBUG

           if let dir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first{
           let fileName = "\(Date()).log"
               let logPath = (dir as NSString).appendingPathComponent(fileName)
               freopen(logPath.cString(using:String.Encoding.ascii)!, "a+", stderr)
           }
#endif

       }

     func timeFor(problemTag:String , problemBlock: () -> ()){
#if DEBUG

           NSLog("Evaluating problem \(problemTag) ==== ")
           SharedManager.shared.printLog("Evaluating problem \(problemTag) ==== ")
           do {
           let info = ProcessInfo.processInfo
           let begin = info.systemUptime
           // do something
           problemBlock()
           let diff = (info.systemUptime - begin)
           // where diff:NSTimeInterval is the elapsed time by seconds.
           NSLog("Time to evaluate problem \(problemTag) === : \(diff) seconds")
           SharedManager.shared.printLog("Time to evaluate problem \(problemTag) === : \(diff) seconds")
       }
#endif

       }
    
    func reportMemory() -> String {
        var taskInfo = task_vm_info_data_t()
        var count = mach_msg_type_number_t(MemoryLayout<task_vm_info>.size) / 4
        let result: kern_return_t = withUnsafeMutablePointer(to: &taskInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), $0, &count)
            }
        }
        let usedMb = Float(taskInfo.phys_footprint) / 1048576.0
        let totalMb = Float(ProcessInfo.processInfo.physicalMemory) / 1048576.0
        return  result != KERN_SUCCESS ? "Memory used: ? of \(totalMb)" : "Memory used: \(usedMb) of \(totalMb)"
        
    }
    
    func updateMessagesIpBadge(afterSecand:Int = 0 , completeHandle:(()->())? = nil){
        if !self.appSetting().enable_resent_failure_ip_kds_order_automatic{
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(afterSecand), execute: {
                NotificationCenter.default.post(name: Notification.Name("show_hide_faliure_kds_message"), object: nil)
                completeHandle?()
            })
        }else{
            completeHandle?()

        }
    }
   
    func updateCashSessionSequence(){
        MWQueue.shared.mwSessionSequence.async {            
             cash_data_class.set(key: "sequence_session_ip_current", value: "\(sequence_session_ip.shared.currentSeq)")
//             cash_data_class.set(key: "sequence_session_ip_next", value: "\(sequence_session_ip.shared.nextSeq)")
         }
     }
    
    func reportTaxIdFR(posLine:pos_order_line_class?,productId:Int )
    {
        let error = NSError(domain: "TaxID", code: 6000, userInfo:
            [
                "error:" : "Empty Tax ID",
                "product_id" :  posLine?.product_id ?? productId,
                "line_uid" :  posLine?.uid ?? "productId \(productId)",
                "order_uid" : posLine?.order_id ?? 0
            ])
        Crashlytics.crashlytics().record(error: error)
    }
    func cannotPrintKDS()->Bool{
        if SharedManager.shared.mwIPnetwork {
            if SharedManager.shared.posConfig().isWaiterTCP(){
                return true
            }
            if SharedManager.shared.posConfig().isMasterTCP(){
                return false
            }
            if SharedManager.shared.posConfig().isAddtionalCashierTCP(){
                return true
            }
        }
        return false
    }
    func cannotPrintBill()->Bool{
        if SharedManager.shared.mwIPnetwork {
            if SharedManager.shared.posConfig().isWaiterTCP(){
                return true
            }
            if SharedManager.shared.posConfig().isMasterTCP(){
                return false
            }
            if SharedManager.shared.posConfig().isAddtionalCashierTCP(){
                return false
            }
        }
        return false
    }
    var countCheckIfSequenceTakeBefore = 0
    func checkIfSequenceTakeBefore(seq:Int? = nil)->Bool{
        if countCheckIfSequenceTakeBefore >= 4{
            countCheckIfSequenceTakeBefore = 0
            return false
        }
        let nextSequ = seq ?? sequence_session_ip.shared.currentSeq
//        let masterDevice = device_ip_info_class.getMasterStatus()
//        let sequanceMaster = masterDevice?.order_sequces
        if let activeSession = pos_session_class.getActiveSession(){
            let sessionDate = activeSession.start_session ?? ""
            if !sessionDate.isEmpty{
                let count:[String:Any] = database_class(connect: .database).get_row(sql: "select count(*) as cnt from pos_order where create_date > '\(sessionDate)' and sequence_number = \(nextSequ)") ?? [:]
                let isTaken = (count["cnt"] as? Int ?? 0) > 0
                if isTaken {
                    countCheckIfSequenceTakeBefore += 1
                    //MWMessageQueueRun.shared.removeTaskInQueu(.REQUEST_SEQ)
                }else{
                    countCheckIfSequenceTakeBefore = 0
                }
                return isTaken
            }
        }
        return false
    }
    func isSequenceAtMasterOnly() -> Bool{
        let isWaiter = SharedManager.shared.posConfig().isWaiterTCP()
        let isSubCasher = SharedManager.shared.posConfig().isAddtionalCashierTCP()
        let isDeviceSupport = (isWaiter || isSubCasher)
        let isMasterOnly = SharedManager.shared.appSetting().enable_sequence_at_master_only
        return isDeviceSupport && isMasterOnly
    }
    
    func generateInviceID(session_id:Int? ) -> Int {
 
        guard let session_id = session_id else { return 0 }
        if SharedManager.shared.appSetting().enable_enter_containous_sequence{
            return generateContainousSequenceAccordingSetting()
        }
 
        if SharedManager.shared.appSetting().enable_enter_sessiion_sequence_order{
            return generateSequenceAccordingSetting(session_id )
        }
        let sql = "select max(sequence_number) as sequence_number from pos_order where session_id_local =?  and order_sync_type != 2"
        var count = 1
        
        let semaphore = DispatchSemaphore(value: 0)
        SharedManager.shared.database_db!.inDatabase { (db:FMDatabase) in
            
            let resutl:FMResultSet = try! db.executeQuery(sql, values: [session_id ])
            if resutl.next()
            {
                count = Int(resutl.int(forColumn: "sequence_number"))
                count += 1
                resutl.close()
            }
            db.close()
            semaphore.signal()
        }
        
        semaphore.wait()
        sequence_session_ip.shared.shareIncreaseSequence()
        return count
    }
    private func generateSequenceAccordingSetting(_ session_id:Int ) -> Int {
        let start_session_sequence_order =  SharedManager.shared.appSetting().start_session_sequence_order.toInt()
        let end_sessiion_sequence_order =  SharedManager.shared.appSetting().end_sessiion_sequence_order.toInt()
        let create_pos_id = SharedManager.shared.posConfig().id
        var sessionQuery = "session_id_local = \(session_id)"
        if SharedManager.shared.mwIPnetwork{
            let native_session_id = session_id * -1
            sessionQuery = "session_id_local in (\(session_id),\(native_session_id))"
        }
        let sql = "SELECT sequence_number as sequence_number FROM pos_order Where create_pos_id = \(create_pos_id) and  \(sessionQuery) and order_menu_status = 0  ORDER BY ID DESC LIMIT 1"
        var count = start_session_sequence_order
        
        let semaphore = DispatchSemaphore(value: 0)
        SharedManager.shared.database_db!.inDatabase { (db:FMDatabase) in
            
            let resutl:FMResultSet = try! db.executeQuery(sql, values: [session_id ])
            if resutl.next()
            {
                count = Int(resutl.int(forColumn: "sequence_number"))
                if count >= start_session_sequence_order && count < end_sessiion_sequence_order {
                    count += 1
                }else{
                    
                    count = start_session_sequence_order
                }
                
                resutl.close()
                
                
                
            }
            db.close()
            semaphore.signal()
        }
        
        
        semaphore.wait()
        
        return count
    }
    private func generateContainousSequenceAccordingSetting() -> Int {
        let start_session_sequence_order =  SharedManager.shared.appSetting().start_value_containous_sequence
        if start_session_sequence_order <= 1 {
            SharedManager.shared.appSetting().start_value_containous_sequence = 2
            SharedManager.shared.appSetting().save()
            return 1
        }
        let nextSeq = start_session_sequence_order + 1
        SharedManager.shared.appSetting().start_value_containous_sequence = nextSeq
        SharedManager.shared.appSetting().save()
        return nextSeq
    }
    
    static func get_max_sequence_for_active_session() -> Int?{
    guard let active_sesstion = pos_session_class.getActiveSession()?.id else {return nil}
        let sql = "select max(sequence_number) as sequence_number from pos_order where session_id_local =?  and order_sync_type != 2 "
        var count = 1
        
        let semaphore = DispatchSemaphore(value: 0)
        SharedManager.shared.database_db!.inDatabase { (db:FMDatabase) in
            
            let resutl:FMResultSet = try! db.executeQuery(sql, values: [active_sesstion ])
            if resutl.next()
            {
                count = Int(resutl.int(forColumn: "sequence_number"))
                resutl.close()
            }
            db.close()
            semaphore.signal()
        }
        semaphore.wait()
        return count
    }
    
}
