//
//  setting_change_user.swift
//  pos
//
//  Created by Khaled on 1/21/21.
//  Copyright © 2021 khaled. All rights reserved.
//

import Foundation

class setting_change_user: UIViewController  {

    @IBOutlet var txtusername: UITextField!
    @IBOutlet var txtpassword: UITextField!
 
    var databseCls:selectDataBase!
    
    let con = SharedManager.shared.conAPI()
    
 
    override func viewDidLoad() {
        super.viewDidLoad()

        txtusername.text =   api.getItem(name:  userLogin.username.rawValue) 
        txtpassword.text =   api.getItem(name:  userLogin.password.rawValue)


     }
   
    @IBAction func btnLogin(_ sender: Any) {
         
        let username : String = txtusername.text ?? ""
        let ps :String = txtpassword.text ?? ""
        
        if(username.isEmpty || ps.isEmpty)
        {
           messages.showAlert("Please enter username and password")
        }
        else
        {
            loadingClass.show(view: self.view)

            con.userCash = .stopCash
            con.authenticate(username: username, password: ps) { (results) in
                loadingClass.hide(view: self.view)

                if results.success == false
                {
                    printer_message_class.show(results.message ?? "")
                    return
                }
                
                let response = results.response
                let header = results.header  as NSDictionary
                
                let result = response!["result"] as! NSDictionary
                
                let Cookie :String = header.object(forKey: "Set-Cookie") as? String ?? ""
                if Cookie == ""
                {
                    messages.showAlert("Can't login ,Please check username and password.")
                }
                else
                {
                    let company_id = result["company_id"] as? Int

                    
                    api.set_Cookie(Cookie: Cookie)
                    
                    api.saveItem(name: userLogin.username.rawValue , value: username)
                    api.saveItem(name: userLogin.password.rawValue , value: ps)
                    api.saveItem(name: userLogin.company_id.rawValue , value: "\(company_id ?? 0 )")

                    messages.showAlert("username and password saved.")

                   
                }
                
              
             
           
               
            };
        }
        
        
        
        
    }
 

    
    
}
