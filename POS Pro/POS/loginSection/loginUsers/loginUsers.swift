//
//  loginUsers.swift
//  pos
//
//  Created by khaled on 9/21/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

class loginUsers: baseViewController ,load_base_apis_delegate {


    var refreshControl_tableview = UIRefreshControl()
    @IBOutlet var tableview: UITableView!
    
    @IBOutlet var view_keyboard: UIView!
    @IBOutlet var lblPin: KLabel!
    
    
    @IBOutlet var btnBack: UIButton!
    public var hideBack :Bool = true
    
    @IBOutlet weak var posInfoLbl: UILabel!
    var list_items:  [Any] = []
    let con = SharedManager.shared.conAPI()
    
    var cls_load_all_apis = load_base_apis()

    var user_selected:res_users_class?
    
    var pin:String! = ""
    
    var errorInLoadUsers:Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnBack.isHidden = hideBack
           view_keyboard.isHidden = true
        
        init_refresh()
        
        let helper = app_helper.getDefault()
        if helper.force_reload_casher_list == true
          {
            helper.force_reload_casher_list  = false
            helper.save()
            
                  con.userCash = .stopCash
        }
        
        let users = res_users_class.getAll_available()
        if users.count == 0
        {
               getList()
        }
        else
        {
            self.handel_response( )
        }
        let name_pos = SharedManager.shared.getPosName() ?? ""
        let name_company = SharedManager.shared.posConfig().company_name ?? ""

        self.posInfoLbl.text =  api.getDatabase() + " - " + name_company + " - " + name_pos
        self.posInfoLbl.textColor =  #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
 
    }
    
    func init_refresh()   {
        
        refreshControl_tableview.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl_tableview.addTarget(self, action: #selector(refreshOrder(sender:)), for: UIControl.Event.valueChanged)
        tableview.addSubview(refreshControl_tableview) // not required when using UITableViewContr
    }
    
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btnReloadAllApis(_ sender: Any) {
     
        let storyboard = UIStoryboard(name: "apis", bundle: nil)
        cls_load_all_apis = storyboard.instantiateViewController(withIdentifier: "load_base_apis") as! load_base_apis
 
            cls_load_all_apis.delegate = self
            cls_load_all_apis.userCash = .stopCash
           
            self.present(cls_load_all_apis, animated: true, completion: nil)
     
               cls_load_all_apis.runQueue()
        }
    func isApisLoaded(status:Bool)
       {
           cls_load_all_apis.dismiss(animated: true, completion: nil)
       }
       
    @IBAction func btnGetAllUsers(_ sender: Any) {
//        getListOnline()
        getList()
    }
    
    @objc func refreshOrder(sender:AnyObject) {
        // Code to refresh table view
          con.userCash = .stopCash
        getList()
    }
    
    func handel_response( )
    {
        
        DispatchQueue.main.async {
             
            var list  = res_users_class.getAllHavePin()
            if list.count == 0
            {
                list = res_users_class.getAllHavePin()
                if list.count == 0
                {
                    return
                }
                
            }
            
            
            let pos = SharedManager.shared.posConfig()
            var list_new:[[String:Any]] = []
            
            for i in 0...list.count-1
            {
                let dic :[String:Any]  = list[i]
                let user = res_users_class(fromDictionary: dic)
                
                var is_in_pos:Bool = true
                
                let pos_config_ids = user.get_pos_config_ids() //item["pos_config_ids"] as? [Int] ?? []
                if pos_config_ids.count > 0
                {
                    let is_esxit = pos_config_ids.firstIndex(of:pos.id)
                    if is_esxit == nil
                    {
                        is_in_pos = false                                   }
                    
                }
                
                if is_in_pos == true
                {
                    let lastlogin:String = user.fristLogin ?? "" //item["fristLogin"] as? String ?? "" //= myuserdefaults.getitem(String(id), prefix:  "lastlogin_casher") as? String ?? ""
                    if lastlogin != ""
                    {
    //                    item["lastLogin"] = lastlogin
                        user.lastLogin = lastlogin
                        list[i] = user.toDictionary()
                    }
                    
                    list_new.append( user.toDictionary())
                }
                
                
                
            }
            
            if list_new.count == 0
            {
                let list  = res_users_class.getAllHavePin()
                list_new.append(contentsOf: list)
                
                self.errorInLoadUsers = true

            }
 
            
            self.list_items.removeAll()
            self.list_items.append(contentsOf:list_new )
            
            
            self.tableview?.reloadData()
        }
        
       
        
        
    }

    func handel_response_old( )
    {
        var list  = res_users_class.getAll_available()
        if list.count == 0
        {
            return
        }
        
        let pos = SharedManager.shared.posConfig()
        var list_new:[[String:Any]] = []
        
        for i in 0...list.count-1
        {
            var item :[String:Any]  = list[i]
            
            let active = item["active"] as? Bool ?? true
            let pos_security_pin = item["pos_security_pin"] as? String ?? ""
            
            if active == true && pos_security_pin != ""
            {
                
                
                //                    let id = item["id"] as? Int ?? 0
                
                var is_in_pos:Bool = true
                
                let pos_config_ids = item["pos_config_ids"] as? [Int] ?? []
                if pos_config_ids.count > 0
                {
                    let is_esxit = pos_config_ids.firstIndex(of:pos.id)
                    if is_esxit == nil
                    {
                        is_in_pos = false
                    }
                    
                }
                
                if is_in_pos == true
                {
                    let lastlogin:String = item["fristLogin"] as? String ?? "" //= myuserdefaults.getitem(String(id), prefix:  "lastlogin_casher") as? String ?? ""
                    if lastlogin != ""
                    {
                        item["lastLogin"] = lastlogin
                        list[i] = item
                    }
                    
                    list_new.append(item)
                }
            }
            
            
        }
        
        
//          list_new = Sort.sort_array_(of_dic_bykey: list_new, key: "lastLogin", ascending: false) as? [[String : Any]] ?? []
        
        
        self.list_items.removeAll()
        self.list_items.append(contentsOf:list_new )
        
        
        self.tableview?.reloadData()
    }
    
    
    func getList()
    {
        loadingClass.show(view: self.view)
        
        let pos = SharedManager.shared.posConfig()
 
 
         con.get_pos_users(posID: pos.id) { (results) in
            self.refreshControl_tableview.endRefreshing()
            loadingClass.hide(view: self.view)
            
            
            let response = results.response
            //            let header = results.header
            
         
            let list:[[String:Any]] = response?["result"] as? [[String:Any]] ?? []
             let cls = res_users_class(fromDictionary: [:])
             pos_base_class.create_temp(  cls.dbClass!)
//                pos_base_class.rest_temp( cls.dbClass!)

             res_users_class.reset(temp:true)
             res_users_class.saveAll(arr: list,excludeProperties: ["is_login","fristLogin","lastLogin"],temp: true)
             pos_base_class.copy_temp( cls.dbClass!)
             SharedManager.shared.removeNotUsesFiles(from: .images, in: .res_users,
                                                     filesName: list.map({"\($0["id"] as? Int ?? 0 ).png"}))

//            res_users_class.saveAll(arr: list,excludeProperties: ["is_login","fristLogin","lastLogin"])

            self.handel_response( )
            
           
            
        }
    }
    
    func getListOnline()
    {
        loadingClass.show(view: self.view)
        
        let pos = SharedManager.shared.posConfig()
 
 
         con.get_pos_users(posID: pos.id) { (results) in
            self.refreshControl_tableview.endRefreshing()
            loadingClass.hide(view: self.view)
            
            
            let response = results.response
         
            var list:[[String:Any]] = response?["result"] as? [[String:Any]] ?? []

            
            DispatchQueue.main.async {
                 
                var list_new:[[String:Any]] = []
                
                if list.count > 0 {
                for i in 0...list.count-1
                {
                    let dic :[String:Any]  = list[i]
                    let user = res_users_class(fromDictionary: dic)
                    
                    var is_in_pos:Bool = true
                    
                    let pos_config_ids = user.get_pos_config_ids()
                    if pos_config_ids.count > 0
                    {
                        let is_esxit = pos_config_ids.firstIndex(of:pos.id)
                        if is_esxit == nil
                        {
                            is_in_pos = false
                            
                        }
                        
                    }
                    
                    if is_in_pos == true && user.company_id == pos.company_id
                    {
                        let lastlogin:String = user.fristLogin ?? ""
                        if lastlogin != ""
                        {
                             user.lastLogin = lastlogin
                            list[i] = user.toDictionary()
                        }
                        
                        if user.active ?? false && !(user.pos_security_pin ?? "").isEmpty {
                        list_new.append( user.toDictionary())
                        }
                    }
                    
                    
                    
                }
                }
                
                 if list_new.count == 0
                {
                    if list.count != 0
                    {
                        for i in 0...list.count-1
                        {
                            let dic :[String:Any]  = list[i]
                            let user = res_users_class(fromDictionary: dic)
                            let pos_security_pin = user.pos_security_pin ?? ""
                            if !pos_security_pin.isEmpty {
                                list_new.append(user.toDictionary())
                            }
                        }
                    }
                  
 
                    self.errorInLoadUsers = true

                }
     
                
                if list_new.count == 0
                {
                    self.handel_response( )
                }
                else
                {
                    self.list_items.removeAll()
                    self.list_items.append(contentsOf:list_new )
                    self.tableview?.reloadData()
                }
        
           
            
        }
    }
    
}
}

extension loginUsers: UITableViewDelegate ,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! loginUsersTableViewCell
//        cell.view_cell.backgroundColor = UIColor.init(hexString: "#5F2A8B")

        let dic = list_items[indexPath.row] as? [String : Any]
 
        user_selected = res_users_class(fromDictionary: dic!)
        
        
        if user_selected?.pos_security_pin == ""
        {
               loadApp()
//            view_keyboard.isHidden = true
        }
        else{
               view_keyboard.isHidden = false
        }
        
//        pos.save()
//
//
        
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list_items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! loginUsersTableViewCell
        
        let obj = list_items[indexPath.row]
        let cls = res_users_class(fromDictionary: obj as! [String : Any])
        
        cell.object = cls
        cell.updateCell()
        
//        let view = UIView()
//        view.frame = cell.bounds
        cell.view_cell.backgroundColor = UIColor.white
//        cell.selectedBackgroundView = view
        
        if errorInLoadUsers == true
        {
            cell.photo.image = UIImage.init(name: "icon_error.png")
        }
        
        return cell
    }
    
    @IBAction func btn_keyboardAction(_ sender: Any) {
        lblPin.textColor = UIColor.black

        let btn :UIButton = sender as! UIButton
        let newNumber = btn.tag
        
        if newNumber == 10
        {
            pin = ""
            
        }
        else
        {
            pin = String(format: "%@%d", pin , newNumber)

        }
        
        drawPin()
    }
    
    func drawPin()
    {
   
      
        lblPin.text = ""
        
        if pin.count  ==  0 {return}
        
        for _ in 0...pin.count - 1 {
            lblPin.text = String(format: "%@%@", lblPin.text! , "*")
        }

        
        
    }
    
    @IBAction func btn_login(_ sender: Any) {
         
            login()
      
    }
    
    func  login()  {
 
        let userPin = user_selected?.pos_security_pin
        
       SharedManager.shared.printLog("userPin :\(userPin)",force: true )
        if pin == userPin
        {
            loadApp()
        }
        else
        {
            messages.showAlert("invaled pinCode")
        }
        
         pin = ""
         drawPin()
    }
    
    func loadApp()
    {
        user_selected?.fristLogin = ""
        user_selected?.lastLogin = String( Date.currentDateTimeMillis()  ) // ClassDate.getTimeINMS()
//        user_selected?.save(toLogin: true)
        user_selected?.setLogin()
        
        AppDelegate.shared.loadLoading()
    }

}
