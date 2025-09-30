//
//  loginVC.swift
//  pos
//
//  Created by khaled on 8/14/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

class loginVC: baseViewController ,selectDataBase_delegate {

    var databseCls:selectDataBase!
    
    let con = SharedManager.shared.conAPI()
    
    var re_login:Bool = false
    
    var dataBase:String = ""
    
    @IBOutlet var txtURl: UITextField!
    @IBOutlet var txtusername: UITextField!
    @IBOutlet var txtpassword: UITextField!
 
    @IBOutlet var btnDatabase: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        let mydom = api.getDomain()
        txtURl.text = mydom
        SharedManager.shared.printLog(mydom)
        
        if re_login
        {
            dataBase = api.getDatabase()
            btnDatabase.setTitle(dataBase, for: .normal)
            txtURl.isEnabled = false
            btnDatabase.isEnabled = false
            
            txtURl.textColor = UIColor.lightGray
            btnDatabase.setTitleColor(UIColor.lightGray, for: .normal)

        }
        
        if AppDelegate.shared.enable_debug_mode_code() == true
        {
//            #if DEBUG
//            dataBase = "https://zahab_test.dgtera.com" // "https://tomtom_test.dgtera.com" //  //"https://newport_test.dgtera.com"////"https://tomtom_test.dgtera.com"
//            #if DEBUG comu_test_theme
           // dataBase = "https://arev_test.dgtera.com"
            //"https://tomtom.dgtera.com"
            //"https://tanora.dgtera.com"
            //"https://arev_test.dgtera.com"
            //"https://comu_test_ios.dgtera.com"
            //"https://kilokabab_test.dgtera.com"
            //"https://comu_test_theme.dgtera.com"
            //"https://blinks_test2.dgtera.com"
            //"https://comu_test_ios.dgtera.com"
            //"https://atyab_test.dgtera.com"
            //"https://blinks_test.dgtera.com"
            //"https://comu_test_ios.dgtera.com"
            // "https://comu_test_tomtom.dgtera.com"
            //"https://test_zahab.dgtera.com"
            //"https://tomtom_test.dgtera.com"
            //"https://olio_test.dgtera.com"//
//            api.setDomain(url: dataBase)
//            txtURl.text = dataBase
//
//            txtusername.text = "superadmin"//"ipad@tomtom.tom"
//            txtpassword.text = "superadmin"//"ipad@tomtom.tom"
            
//            #endif
        }
    
        
     }
    
    @IBAction func DoneEditingURL(_ sender: UITextField) {
        setDomain()
    }
    @IBAction func btnSelectDatabase(_ sender: Any) {
        self.view.endEditing(true)
        
        let storyboard = UIStoryboard(name: "loginStoryboard", bundle: nil)
        databseCls = storyboard.instantiateViewController(withIdentifier: "selectDataBase") as? selectDataBase
        databseCls.modalPresentationStyle = .popover
        //        invoices_List.delegate = self
        databseCls.preferredContentSize = CGSize(width: 300, height: 300)
        databseCls.delegate = self
        
        let popover = databseCls.popoverPresentationController!
        //        popover.delegate = self
        popover.permittedArrowDirections = .up //UIPopoverArrowDirection(rawValue: 0)
        popover.sourceView = sender as? UIView
        popover.sourceRect =  (sender as AnyObject).bounds
        //        popover.sourceRect = CGRect.init(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        
        
        self.present(databseCls, animated: true, completion: nil)
    }
    
    
    func setDomain()
    {
        let url : String = txtURl.text ?? ""
        if url.isEmpty
        {
            messages.showAlert("Please enter url")
        }
        else
        {
            api.setDomain(url: url)
        }
    }
    
    func setDatabase()
    {
        let url : String = dataBase
        if url.isEmpty
        {
//            messages.showAlert("Please enter database")
        }
        else
        {
            api.setDatabase(url: url)
        }
    }
    
    
    func databse_selected(name:String)
    {
        dataBase = name
        btnDatabase.setTitle(dataBase, for: .normal)
        
    }
    
    @IBAction func btnLogin(_ sender: Any) {
        

       setDomain()
       setDatabase()
         
        let username : String = txtusername.text ?? ""
        let ps :String = txtpassword.text ?? ""
        
        
        if (dataBase.isEmpty)
        {
            messages.showAlert("Please select database")
        }
        else if(username.isEmpty || ps.isEmpty)
        {
           messages.showAlert("Please enter username and password")
        }
        else
        {
            loadingClass.show(view: self.view)

            con.userCash = .stopCash
            con.authenticate(username: username, password: ps) { (results) in
                loadingClass.hide()

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
                    messages.showAlert("Can't login , try later .")
                }
                else
                {
                    let company_id = result["company_id"] as? Int
                    if let user_context = result["user_context"] as? NSDictionary ,
                       let tz = user_context["tz"] as? String ,  let uid = user_context["uid"] as? Int {
                        api.set_tz(tz: tz)
                        api.set_uid(uid: "\(uid)")
                    }
                    api.set_Cookie(Cookie: Cookie)
                    
                    api.saveItem(name: userLogin.username.rawValue , value: username)
                    api.saveItem(name: userLogin.password.rawValue , value: ps)
                    api.saveItem(name: userLogin.company_id.rawValue , value: "\(company_id ?? 0 )")

                    //                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    //                appDelegate.loadHome()
                    
                    AppDelegate.shared.loadLoading()
                }
                
              
             
           
               
            };
        }
        
        
        
        
    }
 

    
}
