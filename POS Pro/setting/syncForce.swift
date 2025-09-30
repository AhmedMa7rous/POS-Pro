//
//  syncForce.swift
//  pos
//
//  Created by khaled on 11/6/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

class syncForce: UIViewController ,load_base_apis_delegate{
    var cls_load_all_apis = load_base_apis()
    
    var parent_vc: UIViewController!
    
    @IBOutlet var lblLastDateSync: KLabel!
    @IBOutlet var lblLastDateSyncSuccess: KLabel!
    
    
    @IBOutlet var lblOrder: KLabel!
    
    @IBOutlet var lblCash_in_out: KLabel!
    @IBOutlet var lblScrap: KLabel!
    @IBOutlet var lblSession: KLabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let lastDate = sync_class.getLastTimeSync()
        
        if lastDate != ""
        {
            let date = Date(millis: Int64(lastDate)!)
            let dt = date.toString(dateFormat: "yyyy-MM-dd hh:mm a" , UTC: false)
            
//            let dt = ClassDate.convertTimeStampTodate(  String( lastDate), returnFormate: "yyyy-MM-dd hh:mm a" , timeZone: NSTimeZone.local )
            lblLastDateSync.text = dt //String(format: "%@", baseClass.getDateFormate(date: lastDate ))
        }
        else
        {
            lblLastDateSync.text  = ""
        }
        
        
        let lastDateSuccess = sync_class.getLastTimeSyncSuccess()
        if lastDateSuccess != ""
        {
            let date = Date(millis: Int64(lastDateSuccess)!)
            let dtSuccess = date.toString(dateFormat: "yyyy-MM-dd hh:mm a" , UTC: false)
            
//            let dtSuccess = ClassDate.convertTimeStampTodate(  String( lastDateSuccess), returnFormate: "yyyy-MM-dd hh:mm a" , timeZone: NSTimeZone.local )
            
            lblLastDateSyncSuccess.text = dtSuccess // String(format: "%@", baseClass.getDateFormate(date: lastDateSuccess  ))
            
        }
        else
        {
            lblLastDateSyncSuccess.text =  ""
        }
        
        self.perform(#selector(load_stac), on: .current, with: nil, waitUntilDone: false)
        
    }
    
    @objc func load_stac()
    {
     
        loadingClass.show(view: self.view)
        DispatchQueue.global(qos: .default).async {
            
            
            let option_order = ordersListOpetions()
            //        option_order.Closed = true
            //        option_order.Sync = false
            option_order.void = false
            option_order.orderSyncType = .order
            option_order.write_pos_id = SharedManager.shared.posConfig().id
            
            let list_order = pos_order_helper_class.getOrders_status_sorted_count(options: option_order)
            
            
            let option_cash  = ordersListOpetions()
            option_cash.Closed = true
            option_cash.Sync = false
            option_cash.orderSyncType = .cash_in_out
            
            let list_cash = pos_order_helper_class.getOrders_status_sorted_count(options: option_cash)
            
            
            let option_Scrap  = ordersListOpetions()
            option_Scrap.Closed = true
            option_Scrap.Sync = false
            option_Scrap.orderSyncType = .scrap
            
            let list_Scrap = pos_order_helper_class.getOrders_status_sorted_count(options: option_Scrap)
            
            
            let options = posSessionOptions()
            options.getCount = true
            
            let list_session = pos_session_class.get_pos_session_count(options: options)
            
            DispatchQueue.main.async {
                
                self.lblCash_in_out.text = String(list_cash)
                self.lblOrder.text = String(list_order)
                self.lblScrap.text = String(list_Scrap)
                self.lblSession.text = String( list_session)
                
                loadingClass.hide(view: self.view)
            }
        }
        
    }
    
    
    
    @IBAction func btnSync(_ sender: Any) {
//        AppDelegate.shared.syncNow()
//        MWQueue.shared.syncOrdersQueue.async {
     DispatchQueue.global(qos: .background).async {
            AppDelegate.shared.sync.stop_sync()
             AppDelegate.shared.sync.syncOrders()
 
             }
        
        printer_message_class.show_in_view("Sync in running.",view: parent_vc.view)
    }
    
    @IBAction func btnDownload(_ sender: Any) {
        downloadApis()
    }
    
    func downloadApis()
    {
        
        //        initAppClac.forceToRun()
        
//        let storyboard = UIStoryboard(name: "apis", bundle: nil)
//        cls_load_all_apis = storyboard.instantiateViewController(withIdentifier: "load_base_apis") as! load_base_apis
//
//        cls_load_all_apis.delegate = self
//        cls_load_all_apis.userCash = .stopCash
//        cls_load_all_apis.forceSync = true
//        parent_vc.present(cls_load_all_apis, animated: true, completion: nil)
//
//        cls_load_all_apis.startQueue()
        
  
        AppDelegate.shared.loadLoading(forceSync: true, get_new: false)
    }
    
    func isApisLoaded(status:Bool)
    {
        cls_load_all_apis.dismiss(animated: true, completion: nil)
        
        menu_left.closeMenu()
        
    }
    
}
