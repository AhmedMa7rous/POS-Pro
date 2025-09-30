//
//  autoReLogin.swift
//  pos
//
//  Created by Khaled on 12/4/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

class autoReLogin: UIViewController {

        let con = SharedManager.shared.conAPI()
    var isShow :Bool = false
    @IBOutlet weak var btnlogin: KButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
  
        Login()
    }
    
    @IBAction func btnLogin(_ sender: Any) {
        guard !isShow else { return }
        Login( )
    }
    
    func  Login( ) {
        
        let username : String  = api.getItem(name: userLogin.username.rawValue)
        let ps :String =  api.getItem(name: userLogin.password.rawValue)
 
  

         if(username.isEmpty || ps.isEmpty)
        {
          
            btnlogin.setTitle("invalid username and password", for: .normal)
        }
        else
        {
            loadingClass.show(view: self.view)
                  isShow = true
           
            
            con.userCash = .stopCash
            con.authenticate(username: username, password: ps) { (results) in
                loadingClass.hide()
                
                //            let response = results.response
                let header = results.header  as NSDictionary
                
                //            let result = response!["result"] as! NSDictionary
                
                if (!results.success)
                {
                 
                   
                    self.btnlogin.setTitle(results.message, for: .normal)

                }
                else
                {
                    let Cookie :String = header.object(forKey: "Set-Cookie") as? String ?? ""

                    api.set_Cookie(Cookie: Cookie)
               
           
                    
                    AppDelegate.shared.loadLoading()
                }
                
                self.isShow = false
                
            };
        }
        
        
        
        
    }
    
    func  auto() {
           
           let username : String  = api.getItem(name: userLogin.username.rawValue)
           let ps :String =  api.getItem(name: userLogin.password.rawValue)
    
     

            if(username.isEmpty || ps.isEmpty)
           {
             
//               btnlogin.setTitle("invalid username and password", for: .normal)
           }
           else
           {
//               loadingClass.show(view: self.view)
//                     isShow = true
              
               
               con.userCash = .stopCash
               con.authenticate(username: username, password: ps) { (results) in
//                   loadingClass.hide()
                   
                   //            let response = results.response
                   let header = results.header  as NSDictionary
                   
                   //            let result = response!["result"] as! NSDictionary
                   
                   if (!results.success)
                   {
                    
                      
//                       self.btnlogin.setTitle(results.message, for: .normal)

                   }
                   else
                   {
                       let Cookie :String = header.object(forKey: "Set-Cookie") as? String ?? ""

                       api.set_Cookie(Cookie: Cookie)
                  
              
                       
//                       AppDelegate.shared.loadLoading()
                   }
                   
//                   self.isShow = false
                   
               };
           }
            
       }
    
    @IBAction func btnLogOut(_ sender: Any) {
        
        
        let alert = UIAlertController(title: "Alert", message: "Application will delete all data saved.", preferredStyle: .alert)
        
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            
            
            AppDelegate.shared.logOut()
            AppDelegate.shared.loadLoading()
            
        }))
        
        alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: { (action) in
            
        }))
        
     
        self.present(alert, animated: true, completion: nil)
        
        
        
        
    }

}
