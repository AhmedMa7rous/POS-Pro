//
//  change_pinCode.swift
//  pos
//
//  Created by Khaled on 2/25/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import UIKit

class change_pinCode: NSObject,pinCode_delegate {
    
    var parent_vc:UIViewController?
    var current_pin:String?
    var new_pin:String?
    
    let con = SharedManager.shared.conAPI()
    
    func change()
    {
        get_pin(title: "Please enter cureent pinCode")
    }
    
    
    @objc func get_pin(title:String)
    {
        let storyboard = UIStoryboard(name: "loginStoryboard", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "pinCode") as! pinCode
        controller.delegate = self
        controller.mode_get_only = true
        controller.title_vc = title
        parent_vc?.present(controller, animated: true, completion: nil)
    }
    func closeWith(pincode:String)
    {
        let casher = SharedManager.shared.activeUser()
   DispatchQueue.main.async {
    if self.current_pin == nil
        {
            
            if casher.pos_security_pin == pincode
            {
                if self.current_pin == nil
                {
                    self.current_pin = pincode
                    
                      
                            self.get_pin(title: "Please enter new pinCode")
                     
                    
//                    self.perform(#selector(get_pin(title:)), with: "Please enter new pinCode", afterDelay: 0.5)
                    
                }
                
                
            }
            else
            {
                
          
//                     MessageView.show("invalid Pic Code")
                    printer_message_class.show("invalid Pic Code",vc: self.parent_vc!)
            }
            
        }
        else if (self.new_pin == nil)
        {
            if pincode.count < 4
            {
//                  MessageView.show("Pic Code must to be at least 4 numbers.")
                printer_message_class.show("Pic Code must to be at least 4 numbers.", vc: self.parent_vc!)
            }
            else
            {
                                      self.changeCode(userid: casher.id, pinCode: pincode )
                          
            }
                  
        }
        
        }
        
    }
    
    
    func changeCode(userid:Int,pinCode:String)
    {
        loadingClass.show(view: parent_vc!.view)

         con.userCash = .stopCash
        
        con.change_pin_code(userid: userid, new_pin: pinCode) { (results) in
            loadingClass.hide(view: self.parent_vc!.view)
             
                          if results.success == false
                          {
                              printer_message_class.show(results.message ?? "")
                              return
                          }
            let casher = SharedManager.shared.activeUser()
            casher.pos_security_pin = pinCode
            casher.save()
            
            let helper = app_helper.getDefault()
            helper.force_reload_casher_list = true
            helper.save()
            
              printer_message_class.show("Pin Code changed successfully.")
        }
        
 
    }
    
    
}
