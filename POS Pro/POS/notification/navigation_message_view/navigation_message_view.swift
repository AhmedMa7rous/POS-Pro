//
//  expire_date.swift
//  pos
//
//  Created by Khaled on 1/30/21.
//  Copyright © 2021 khaled. All rights reserved.
//

import UIKit



class navigation_message_view: UIViewController {
    @IBOutlet var lbl_date: UILabel!
    @IBOutlet var lbl_title: UILabel!
    @IBOutlet var lblMessage: UILabel!

    @IBOutlet var view_success: UIView?
    @IBOutlet var view_failure: UIView?
    @IBOutlet var bg_message: ShadowView?

    @IBOutlet var icon: UIImageView?

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
      
        
        failure()

    }
   
    func updateView(obj:notifications_messages_class)
    {
        lbl_title.text = obj.title
        lbl_date.text = obj.date
        lblMessage.text = obj.message
        
        icon?.image = UIImage(name: obj.icon_name)
        
        lbl_title.textColor = UIColor(hexFromString: "#434343")
        lbl_date.textColor = UIColor(hexFromString: "#434343")
        lblMessage.textColor = UIColor(hexFromString: "#434343")
    }
    
    func success()
    {
        view_success?.isHidden = false
        view_failure?.isHidden = true
        
        bg_message?.backgroundColor = UIColor.white
    }
    func failure()
    {
        view_success?.isHidden = true
        view_failure?.isHidden = false
        
        bg_message?.backgroundColor = UIColor(hexFromString: "#F55D55")
        
        lbl_title.textColor = UIColor.white
        lbl_date.textColor = UIColor.white
        lblMessage.textColor = UIColor.white

    }

    func check_expire_date()
    {
        
        let dt = "" // "25/1/2021"
        
        if dt == ""
        {
            return
        }
        
        self.view.isHidden = false

        let exp_date = Date(strDate: dt , formate: "dd/MM/yyyy", UTC: true)
        let delta = Date.daysBetween(start: exp_date, end: Date())
 
        if delta > 0
        {
            lblMessage.text = "Your license is expired"
            AppDelegate.shared.app_expire = true
        }
        else
        {
            lblMessage.text = "Your license will expire in \(delta * -1) days"
        }
    }
    
    
   
    
    @IBAction func btnClose(_ sender: Any) {
        DispatchQueue.main.async {
            if SharedManager.shared.appSetting().enable_play_sound_while_auto_accept_order_menu {
                baseClass.stopSound()
            }
        }
        UIView.animate(withDuration: 1) {
                       self.view.alpha = 0
       
                   }
    }
    
}
