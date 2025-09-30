//
//  baseViewController.swift
//  pos
//
//  Created by Khaled on 8/5/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import UIKit
 
class baseViewController: UIViewController,UIViewControllerTransitioningDelegate  {

     var scrollView: zoom_scrollView = zoom_scrollView()
    var stop_zoom:Bool = false
    var navigation_message:navigation_message_view?
    var testMode:test_mode_view?
    var trainingModeView:test_mode_view?

    var errorModeView:test_mode_view?
    override func viewDidLoad() {
        super.viewDidLoad()

        baseViewController.reAssignImage(mainView: self.view)

        if stop_zoom == false
        {
            scrollView.zoom(viewController: self)

        }

        initView_alert_notificationCenter_popup()
    
//        setNeedsStatusBarAppearanceUpdate()
        init_alert_notificationCenter()
        
        init_test_mode()
        init_traing_mode()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        init_error_mode_view()
    }
    func init_error_mode_view(){
       if let casherCompanyId =  SharedManager.shared.activeUser().company_id ,
          let posCompanyID = SharedManager.shared.posConfig().company_id,
          let userCompanyID = Int(api.getItem(name: userLogin.company_id.rawValue))
           {
        if (casherCompanyId != posCompanyID) && casherCompanyId != 0 && posCompanyID != 0 {
            showErrorModeView(message:"The Current casher not at same pos company".arabic("الكاشر الحالي ليس في نفس شركة نقاط البيع"))
        } else {
            if (userCompanyID != posCompanyID ) && userCompanyID != 0 && posCompanyID != 0 {
                showErrorModeView(message:"The Current user not at same pos company".arabic("المستخدم الحالي ليس في نفس شركة نقاط البيع"))
            }else{
                hideErrorModeView()
            }
        }
       }
    }
    func showErrorModeView(message:String){
        let screenRect =  UIScreen.main.bounds
        errorModeView =  test_mode_view()
        errorModeView?.lblText = message
        errorModeView?.view.frame = CGRect.init(x: 0, y: 0, width: screenRect.width   , height: 8)
        errorModeView?.view.autoresizingMask = [.flexibleBottomMargin,.flexibleWidth,.flexibleHeight,.flexibleLeftMargin,.flexibleRightMargin,.flexibleTopMargin]
        self.view.addSubview( (errorModeView?.view)!)
    }
    func hideErrorModeView(){
        errorModeView?.view.removeFromSuperview()
        errorModeView = nil
    }
    
    func init_test_mode()
    {
        let screenRect =  UIScreen.main.bounds
        
        if SharedManager.shared.appSetting().enable_testMode && testMode == nil
        {
            
            testMode = test_mode_view()
            trainingModeView?.lblText = "Test Mode - وضع التجريبي"
            testMode?.view.frame = CGRect.init(x: 0, y: 0, width: screenRect.width   , height: 8)
          
            testMode?.view.autoresizingMask = [.flexibleBottomMargin,.flexibleWidth,.flexibleHeight,.flexibleLeftMargin,.flexibleRightMargin,.flexibleTopMargin]

            self.view.addSubview( (testMode?.view)!)
        }
        else if  SharedManager.shared.appSetting().enable_testMode == false && testMode != nil
        {
            testMode?.view.removeFromSuperview()
            testMode = nil
        }
        
     

    }
    
    func init_traing_mode()
    {
        let screenRect =  UIScreen.main.bounds
        
        if SharedManager.shared.appSetting().enable_traing_mode && trainingModeView == nil
        {
            
            trainingModeView = test_mode_view()
            trainingModeView?.lblText = "Traing Mode"
            trainingModeView?.view.frame = CGRect.init(x: 0, y: 0, width: screenRect.width   , height: 8)
          
            trainingModeView?.view.autoresizingMask = [.flexibleBottomMargin,.flexibleWidth,.flexibleHeight,.flexibleLeftMargin,.flexibleRightMargin,.flexibleTopMargin]

            self.view.addSubview( (trainingModeView?.view)!)
        }
        else if  SharedManager.shared.appSetting().enable_traing_mode == false && trainingModeView != nil
        {
            trainingModeView?.view.removeFromSuperview()
            trainingModeView = nil
        }
        
     

    }
    
    func initView_alert_notificationCenter()
    {
        let screenRect =  UIScreen.main.bounds
        
        navigation_message = navigation_message_view()
        navigation_message?.view.frame = CGRect.init(x: 0, y: 0, width: screenRect.width   , height: 20)
        navigation_message?.view.isHidden = true
        navigation_message?.view.autoresizingMask = [.flexibleBottomMargin,.flexibleWidth,.flexibleHeight,.flexibleLeftMargin,.flexibleRightMargin,.flexibleTopMargin]

        self.view.addSubview( (navigation_message?.view)!)

        navigation_message?.check_expire_date()
    }
    
    
    func initView_alert_notificationCenter_popup()
    {
//        let screenRect =  UIScreen.main.bounds
        
        navigation_message = navigation_message_view(nibName: "navigation_message_view_popup", bundle: nil)
        navigation_message?.view.frame = CGRect.init(x: 500, y: 0, width: 500  , height: 100)
        navigation_message?.view.isHidden = true
        navigation_message?.view.autoresizingMask = [.flexibleBottomMargin,.flexibleWidth,.flexibleHeight,.flexibleLeftMargin,.flexibleRightMargin,.flexibleTopMargin]

        self.view.addSubview( (navigation_message?.view)!)

     }
    
    func showBanner(obj:notifications_messages_class){
        SharedManager.shared.initalBannerNotification(title: obj.title ,
                                                      message: obj.message,
                                                      success: obj.success, icon_name: obj.icon_name)
        SharedManager.shared.banner?.dismissesOnTap = true
        SharedManager.shared.banner?.show(duration: 3.0)
       
    }
   
    
    @objc func show_aleart(notification: Notification)
    {
         
            
        DispatchQueue.main.async {
            let type:notifications_messages_class = notification.object as! notifications_messages_class

      
            self.navigation_message?.updateView(obj:type)
//            self.navigation_message?.lblMessage.text = type.message
            if type.title.lowercased().contains("printer"){
                self.showBanner(obj:type)
            }else{
                if type.success
                {
                    self.navigation_message?.success()
                }
                else
                {
                    self.navigation_message?.failure()
                }
                self.navigation_message?.view.isHidden = false
                self.navigation_message?.view.alpha = 0
      
             
            UIView.animate(withDuration: 0.5, animations: {
                self.navigation_message?.view.alpha = 1
     
            }) { _ in
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                    UIView.animate(withDuration: 0.5) {
                        self.navigation_message?.view.alpha = 0

                    }
                }
                

            }
                
            }
            
        }
    }
    
    func init_alert_notificationCenter()
    {
         
        NotificationCenter.default.addObserver(self, selector: #selector( show_aleart(notification:)), name: Notification.Name("show_aleart"), object: nil)
 
    }
    
    func remove_alert_notificationCenter() {
         NotificationCenter.default.removeObserver(self, name: Notification.Name("show_aleart"), object: nil)
        
    }
 
    
    deinit {
        // Release all resources
        // perform the deinitialization
    }
    override func viewDidDisappear(_ animated: Bool) {
//        forceClearMemory(mainView: self.view)
        
        super.viewDidDisappear(animated)
        
        remove_alert_notificationCenter()
    }
    
   
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        

    }
    
    
   static func reAssignImage(mainView:UIView)
    {
        for view in mainView.subviews
        {
            if view .isKind(of: KSImageView.self)
            {
                
                
                let imageView:KSImageView?  = view as? KSImageView
                if imageView?.imageFileName != nil
                {
                    imageView?.image = UIImage.init(name: (imageView?.imageFileName)!)
                    
                }
                
                if imageView?.HighlightedFileName != nil
                {
                    
                    imageView?.highlightedImage = UIImage.init(name: (imageView?.HighlightedFileName!)!)
                    
                }
                
                
 
            }
            else  if view .isKind(of: UIView.self)
            {
                reAssignImage(mainView: view)
            }
    }
    }
    
    func reportMemory() {
        var taskInfo = task_vm_info_data_t()
        var count = mach_msg_type_number_t(MemoryLayout<task_vm_info>.size) / 4
        let result: kern_return_t = withUnsafeMutablePointer(to: &taskInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), $0, &count)
            }
        }
        let usedMb = Float(taskInfo.phys_footprint) / 1048576.0
        let totalMb = Float(ProcessInfo.processInfo.physicalMemory) / 1048576.0
        result != KERN_SUCCESS ?SharedManager.shared.printLog("Memory used: ? of \(totalMb)") :SharedManager.shared.printLog("Memory used: \(usedMb) of \(totalMb)")
    }
    
    
    func forceClearMemory(mainView:UIView)
    {
        for view in mainView.subviews
        {
            if view .isKind(of: KSImageView.self)
            {
                view.removeFromSuperview()
//                view = nil
                
//                var imageView:KSImageView?  = view as? KSImageView
//                imageView?.clear()
//                imageView?.removeFromSuperview()
//                imageView = nil
            }
            else  if view .isKind(of: UIView.self)
            {
                forceClearMemory(mainView: view)
            }
        }
    }

    
    func blurView(alpha:CGFloat = 1,style: UIBlurEffect.Style = .light)
    {
        let frm = CGRect.init(x: 0, y: 0, width: 1366, height: 1024)
        let visuaEffectView = UIVisualEffectView(effect: UIBlurEffect(style: style))
        
        visuaEffectView.frame = frm
        visuaEffectView.alpha = alpha
             
        self.view.insertSubview(visuaEffectView, at: 0)
    }
    
    func blurView(view:UIView)
      {
        let frm = view.bounds
          let visuaEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
          
          visuaEffectView.frame = frm
               
        view.addSubview(visuaEffectView)
//          self.view.insertSubview(visuaEffectView, at: 0)
      }
      
 

}
