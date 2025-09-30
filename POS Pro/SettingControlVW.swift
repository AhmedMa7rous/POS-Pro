//
//  File.swift
//  Rabeh
//
//  Created by MAHMOUD AHMED on 9/12/1440 AH.
//  Copyright © 1440 MAHMOUD AHMED. All rights reserved.
//

import Foundation



class SettingControlVW: UIViewController
{


    
    
    @IBOutlet var txt_url: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.navigationController?.isNavigationBarHidden = false
        
        let setting =  settingClass.getSetting()

        txt_url.text = setting.url

        
    }
    
  
  
   
    @IBAction func btnSave(_ sender: Any) {
        self.view.endEditing(true)
        
//           let   setting =  "setting"
        
        cash_data_class.set(key: "setting_url", value: txt_url.text!)
//        myuserdefaults .setitems("url", setValue:txt_url.text, prefix: setting)
  
    }
    
    
}
