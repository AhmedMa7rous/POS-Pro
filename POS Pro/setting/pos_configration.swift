//
//  pos_configration.swift
//  pos
//
//  Created by khaled on 9/30/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

class pos_configration: UIViewController ,selectDataBase_delegate,selectPointOfSale_delegate, UITextFieldDelegate {

    @IBOutlet weak var pinCodeTF: UITextField!
    var databseCls:selectDataBase!
    var posCls:selectPointOfSale!
    

    let con = SharedManager.shared.conAPI()
    
    var dataBase:String = api.getDatabase()
    var selected_pos = SharedManager.shared.posConfig()
    
    @IBOutlet var txtURl: UITextField!
    @IBOutlet var btnDatabase: UIButton!
    @IBOutlet var btnPos: UIButton!

    var pinCodeVM:PinCodeVM?
    override func viewDidLoad() {
        super.viewDidLoad()
        pinCodeVM = PinCodeVM()
        pinCodeVM?.API = SharedManager.shared.conAPI()
        pinCodeTF.delegate = self
        initalState()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
          txtURl.text = api.getDomain()
         btnDatabase.setTitle(dataBase, for: .normal)
        btnPos.setTitle(selected_pos.name, for: .normal)

    }
    // Use this if you have a UITextField
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // get the current text, or use an empty string if that failed
        var currentText = textField.text ?? ""
        if currentText.count == 3 || currentText.count == 7  || currentText.count == 11 {
            currentText += "-"
            textField.text = currentText
        }
        // attempt to read the range they are trying to change, or exit if we can't
        guard let stringRange = Range(range, in: currentText) else { return false }

        // add their new text to the existing text
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)

        // make sure the result is under 16 characters
        return updatedText.count <= 15
    }
    //MARK:- inital State Pin code screen
    func initalState(){
        self.pinCodeVM?.updateLoadingStatusClosure = { (state, message, isSucess) in
            switch state {
            case .empty:
                DispatchQueue.main.async {
                    loadingClass.hide()
                }
                return
            case .error:
                DispatchQueue.main.async {
                    loadingClass.hide()
                    messages.showAlert(message ?? "pleas, try again!")
                }
                return
            case .loading:
                DispatchQueue.main.async {
                    loadingClass.show(view: self.view)
                }
                return
            case .populated:
                DispatchQueue.main.async {
                    loadingClass.hide()
                    AppDelegate.shared.loadLoading()
                }
                return
            }
            
        }
    }
    
    @IBAction func tapOnRenewPinBtn(_ sender: KButton) {
//       let vc =  PinCodeRouter.createModule()
//        self.navigationController?.pushViewController(vc, animated: true)

        if let text = pinCodeTF.text {
            if ( !text.isEmpty && text.count == 15){
                view.endEditing(true)
                    pinCodeVM?.getPinInfoFor(code:text)
            }
       
        }
        
    }
    
    @IBAction func btnSelectPOS(_ sender: Any) {
        
        self.view.endEditing(true)
        
        let storyboard = UIStoryboard(name: "loginStoryboard", bundle: nil)
        posCls = storyboard.instantiateViewController(withIdentifier: "selectPointOfSalePopup") as? selectPointOfSale
        posCls.modalPresentationStyle = .popover
        //        invoices_List.delegate = self
        posCls.preferredContentSize = CGSize(width: 300, height: 300)
        posCls.delegate = self
        
        let popover = posCls.popoverPresentationController!
        //        popover.delegate = self
        popover.permittedArrowDirections = .up //UIPopoverArrowDirection(rawValue: 0)
        popover.sourceView = sender as? UIView
        popover.sourceRect =  (sender as AnyObject).bounds
        //        popover.sourceRect = CGRect.init(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        
        
        self.present(posCls, animated: true, completion: nil)
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
    
    func pos_selected(pos:pos_config_class)
    {
        selected_pos = pos
        btnPos.setTitle(selected_pos.name, for: .normal)

    }
    
    func databse_selected(name:String)
    {
        dataBase = name
        btnDatabase.setTitle(dataBase, for: .normal)
        
    }
  
    @IBAction func UrlDoneEditing(_ sender: UITextField ) {
   SharedManager.shared.printLog("Done editing the new url")
    setDomain()
        
    }
    
    @IBAction func btnLogin(_ sender: Any) {
        
        
        let alert = UIAlertController(title: "Alert", message: "Application will delete all data saved.", preferredStyle: .alert)
        
        
 

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            
//            self.deleteCashed()
            UserDefaults.standard.removeObject(forKey: "version_user_default")
            self.setDomain()
//            self.setDatabase()
            alter_database_enum.loadingApp.setIsDone(with: false)
            AppDelegate.shared.logOut()
            AppDelegate.shared.loadLoading()
            
        }))
        
        alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: { (action) in
            
        }))
        
 
        self.present(alert, animated: true, completion: nil)
        
        
        
        
    }
    
    @IBAction func btnChangeDatabasePOS(_ sender: Any) {
        
        
        let alert = UIAlertController(title: "Alert", message: "Application will delete all data saved.", preferredStyle: .alert)
        
        
 

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
           
            
            let Cookie = api.get_Cookie()
            let username : String  = api.getItem(name: userLogin.username.rawValue)
            let ps :String =  api.getItem(name: userLogin.password.rawValue)
            MWQueue.shared.firebaseQueue.async {
//            DispatchQueue.global(qos: .background).async {
                FireBaseService.defualt.updatePresenceStatus(.offline)
            }
            AppDelegate.shared.removeDatabases()
            alter_database.check(.changingDataBase)

            
            self.setDomain()
            api.setDatabase(url: self.dataBase)
            self.selected_pos.setActive()
             
            api.set_Cookie(Cookie: Cookie)
            api.saveItem(name: userLogin.username.rawValue , value: username)
            api.saveItem(name: userLogin.password.rawValue , value: ps)

            AppDelegate.shared.loadLoading()
           

            
        }))
        
        alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: { (action) in
            
        }))
        
 
        self.present(alert, animated: true, completion: nil)
        
        
        
        
    }
    
    
    func deleteCashed()
    {
//        myuserdefaults.deletelstitems("callApi")
//        myuserdefaults.deletelstitems("lastupdate")
//        myuserdefaults.deletelstitems("account_taxaccount_tax")
//        myuserdefaults.deletelstitems("apiDatabase")
//        myuserdefaults.deletelstitems("apidomain")
//        myuserdefaults.deletelstitems("cashiercashier")
//        myuserdefaults.deletelstitems("InviceIDID")
//        myuserdefaults.deletelstitems("neworderID")
//        myuserdefaults.deletelstitems("pospos")
//        myuserdefaults.deletelstitems("product_pricelist_itemproduct_pricelist_item")
//        myuserdefaults.deletelstitems("settingsaved")
    }
    
    
}
