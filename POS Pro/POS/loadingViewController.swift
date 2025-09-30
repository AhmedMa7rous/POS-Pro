//
//  loadingViewController.swift
//  pos
//
//  Created by khaled on 8/14/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit
import Firebase

class loadingViewController: baseViewController,load_base_apis_delegate {

    var cls_all_apis:load_base_apis!
    
    var con:api! = SharedManager.shared.conAPI()
    
    
    var forceSync:Bool = false
    var get_new:Bool = true
    
    
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//
//        cls_all_apis = nil
//        con = nil
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        Crashlytics.sharedInstance().crash()
        SharedManager.shared.setGloobalObject()

        self.navigationController?.isNavigationBarHidden = true
        
   
 //setVersion()

    init_apis()
        crashlyticsCustomValues()
    
        
        con.userCash = .stopCash
//        AppDelegate.shared.loadHome()
test()
        
        remove_log()
        NetWorkMonitor.shared.startMonitor()
        MWQueue.shared.firebaseQueue.async {
        FireBaseService.defualt.updatePresenceStatus()
        }

    }
    
    func setVersion()
    {
//        #if DEBUG
//
//        #else
       
        if AppDelegate.shared.enable_debug_mode_code() == false
        {
            let version = Bundle.main.fullVersion

            cash_data_class.set(key: "version", value: version)
            
            let date = Date().toString(dateFormat: baseClass.date_fromate_satnder_12h, UTC: true)

            cash_data_class.set(key: version , value: date)
        }
    

//        #endif
        
 
        
    }
    
    func crashlyticsCustomValues()
    {
        let username : String  = api.getItem(name: userLogin.username.rawValue)
        
        setcrashlyticsCustomValues(key: "domain", value: api.getDomain())
        setcrashlyticsCustomValues(key: "username", value: username)

        let user = SharedManager.shared.activeUser()
        if user.fristLogin! ==  ""
        {
            setcrashlyticsCustomValues(key: "userPos", value: user.name)
        }
        
        let pos = SharedManager.shared.posConfig()
        if pos.id !=  0
        {
            setcrashlyticsCustomValues(key: "pos", value: pos.name)
        }
        
        
        let session = pos_session_class.getActiveSession();
        if session != nil
        {
            setcrashlyticsCustomValues(key: "session", value: String( session!.id))
        }
        
        
 
    }
    
    func setcrashlyticsCustomValues(key:String,value:String?)
    {
        if value == nil
        {
            return
        }
 
        Crashlytics.crashlytics().setCustomValue(value!, forKey: key)

    }
    
    func test()
    {
//        let order = pos_order_class.get(order_id: 262)
//        let data = pos_order_builder_class.bulid_order_data(order: order!,for_pool: nil)
//
//        SharedManager.shared.printLog(data)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
            alter_database.check(.loadingApp)
            checkAuth()
//        DispatchQueue.global(qos: .background).async {
//        }

    }
    
    func checkAuth()  {
       if (api.isAuth())
       {
//        getProduct()
//        sessionInfo()
         let pos =  SharedManager.shared.posConfig()
 
        if pos.id == 0
        {
            
            AppDelegate.shared.loadSelectPointOfSale()
            
//            let storyboard = UIStoryboard(name: "loginStoryboard", bundle: nil)
//           let vc = storyboard.instantiateViewController(withIdentifier: "selectPointOfSale") as! selectPointOfSale
//
//            self.present(vc, animated: true, completion: nil)

        }else if (cash_data_class.get(key: "is_first_lanuch") ?? "").isEmpty || ((cash_data_class.get(key: "is_first_lanuch") ?? "") == "1"){
            let vc = PremissionRouter.createModule()
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
            return
        }
           /*
        else if settingClass.isSetPrinter() == false
        {
            let storyboard = UIStoryboard(name: "printer", bundle: nil)

            let vc = storyboard.instantiateViewController(
                withIdentifier: "DiscoveryViewController") as! DiscoveryViewController

            vc.hideBack = true
            vc.hideSkip = false

            
            let nav = UINavigationController(rootViewController: vc);
            nav.isNavigationBarHidden = true
            nav.modalPresentationStyle = .fullScreen

            self.present(nav, animated: true, completion: nil)

        }
            */
        else if SharedManager.shared.activeUser().id == 0
        {
            let storyboard = UIStoryboard(name: "loginStoryboard", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "loginUsers") as! loginUsers
            vc.hideBack = true
            vc.modalPresentationStyle = .fullScreen

            
            self.present(vc, animated: true, completion: nil)
        }
        else
        {
            
            load_apis()
            
            
      
        }
        

        
       }
        else
       {
        AppDelegate.shared.initialPinCodeVC()
         // AppDelegate.shared.loadLogin()
        
        }
        
    
        
    }
    
    
   func init_apis()
   {
//    cls_all_apis = load_base_apis()

    
    let storyboard = UIStoryboard(name: "apis", bundle: nil)
    cls_all_apis = storyboard.instantiateViewController(withIdentifier: "load_base_apis") as? load_base_apis
     cls_all_apis.delegate = self
    cls_all_apis.forceSync = forceSync
    cls_all_apis.get_new = get_new
    
 
    
 
   }

    func load_apis()
    {
        
  
        if cls_all_apis.check_run(return_delegate: false) == true
        {
            cls_all_apis.view.autoresizingMask = [.flexibleBottomMargin,.flexibleWidth,.flexibleHeight,.flexibleLeftMargin,.flexibleRightMargin,.flexibleTopMargin]

            cls_all_apis.view.frame = self.view.bounds
            
               self.view.addSubview(cls_all_apis.view)
            
                   cls_all_apis.userCash = .stopCash
             
                   cls_all_apis.startQueue()

        }
        else
        {
            isApisLoaded(status: true)
        }
        
    
        
    }
    
    func isApisLoaded(status:Bool)
    {
        
        if status == true
        {
            if cls_all_apis != nil
            {
                cls_all_apis.cleanMemory()
                cls_all_apis = nil
            }
          

        }
        
        if status == true
        {
//            if AppDelegate.shared.load_kds == true
//            {
//                AppDelegate.shared.loadKDS()
//
//                return
//            }
              
//            let activeSession = pos_session_class.getActiveSession()
//            if activeSession != nil
//            {
//             load_app()
//
//
//            }
//            else
//            {
//                load_app()
//
//            }
           
               load_app()
            
        }
    }
    
    
    func load_app()
    {
        let user = SharedManager.shared.activeUser()
        if user.fristLogin! ==  ""
        {
            if AppDelegate.shared.load_kds == true
            {
                AppDelegate.shared.loadKDS()
                 
            }
            else
            {
                AppDelegate.shared.loadDashboard()
                
            }
            
        }
        else
        {
           check_load_pin()
        }
    }
    
    func check_load_pin()  {
             let time_to_show_minutes = 15 // min
           
           let time:Int64  = baseClass.getTimeINMS()

           let last_login =  cash_data_class.get(key: "pin_code_last_login") ?? ""
           if !last_login.isEmpty
           {
               let last_time:Int64  = Int64(last_login) ?? 0
               var diff = (time - last_time) / 1000
               diff = diff / 60 // min
               
               if diff <= time_to_show_minutes
               {
                if AppDelegate.shared.load_kds == true
                {
                    AppDelegate.shared.loadKDS()
                     
                }
                else
                {
                    AppDelegate.shared.loadDashboard()
                    
                }
                
                   return
               }
               
               
           }
        
        AppDelegate.shared.loadPin()

        
    }
    
     
    func remove_log()
    {
//        #if DEBUG
//        return
//        #endif
        
        if AppDelegate.shared.enable_debug_mode_code() == true
        {
            //return
        }
        
        DispatchQueue.global(qos: .background).async {
       
             let setting = SharedManager.shared.appSetting()
            self.remove_error_printer_log()
            self.remove_multi_peer_log()
            FileMangerHelper.shared.checkSizeDoucment()
            if setting.clear_log_everyDays != 0
            {

                let days =  SharedManager.shared.appSetting().clear_log_everyDays * -1
                
                let date_now:Date = Date()
                let minutes = Int( days * 24 * 60 );
                
                let calendar = Calendar.current
                let older_date = calendar.date(byAdding: .minute, value: minutes, to: date_now)
                

                
                let older_date_str =  older_date?.toString(dateFormat:baseClass.date_formate_database) ?? ""
                
                let count = logClass.countBefore(date: older_date_str)
                let countPrinterLog = printer_log_class.countBefore(date: older_date_str)

                if count > 0
                {
                    
                    logClass.deleteBefore(date: older_date_str)
 
                    logClass.init().dbClass?.vacuum_database()
 
                }
                if countPrinterLog > 0
                {
                    
                    printer_log_class.deleteBefore(date: older_date_str)
                    queue_log_class.deleteBefore(date: older_date_str)
                    printer_log_class.init().dbClass?.vacuum_database()

                }
                     }
       
        
          }
        
    }
    func remove_error_printer_log(){
        let setting = SharedManager.shared.appSetting()
       if setting.clear_error_log != 0 {
           if setting.clear_error_log == 1 {
               setting.clear_error_log = 2
               setting.save()
           }
           let days =  setting.clear_error_log  * -1
           let date_now:Date = Date()
           let minutes = Int( days * 24 * 60 );
           let calendar = Calendar.current
           let older_date = calendar.date(byAdding: .minute, value: minutes, to: date_now)
           let older_date_str =  older_date?.toString(dateFormat:baseClass.date_formate_database) ?? ""
           let count = printer_error_class.countBefore(date: older_date_str)
           if count > 0
           {
               printer_error_class.reset()
               printer_error_class.vacuum_database()

           }

       }
    }
    func remove_multi_peer_log(){
//           let days =  -3
//           let date_now:Date = Date()
//           let minutes = Int( days * 24 * 60 );
//           let calendar = Calendar.current
//           let older_date = calendar.date(byAdding: .minute, value: minutes, to: date_now)
//           let older_date_str =  older_date?.toString(dateFormat:baseClass.date_formate_database) ?? ""
           let count = MultiPeerLog.countBefore()
           if count > 500
           {
               MultiPeerLog.reset()
               MultiPeerLog.vacuum_database()
           }

    }
    

}
