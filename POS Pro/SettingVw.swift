//
//  SettingVw.swift
//  Rabeh
//
//  Created by MAHMOUD AHMED on 9/11/1440 AH.
//  Copyright © 1440 MAHMOUD AHMED. All rights reserved.
//

import Foundation


 

class SettingVw: UIViewController  {
    
    
    
    
    var MainParentView :UIViewController? = nil
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
 
 
    }
    
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        
        
    }
 

override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
 }
    
    
    
    @IBAction func ShowSettingControl() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let settingStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)

         let vc = settingStoryboard.instantiateViewController(
            withIdentifier: "SettingControlVW") as! SettingControlVW
        
        appDelegate.centerNav?.pushViewController(vc, animated: true)
        
        closeMenu()
     }
    
    @IBAction func ShowHome() {
       closeMenu()
   }
    
    func closeMenu() {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    appDelegate.centerContainer?.closeDrawer(animated: true, completion: nil)
    
    }
    
     @IBAction func addprinter()
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let vc = self.storyboard?.instantiateViewController(
            withIdentifier: "DiscoveryViewController") as! DiscoveryViewController
        
        appDelegate.centerNav?.pushViewController(vc, animated: true)
        
           closeMenu()
    }
   
    
}

