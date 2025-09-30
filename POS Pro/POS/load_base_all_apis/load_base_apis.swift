//
//  load_base_apis.swift
//  pos
//
//  Created by khaled on 8/23/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

class load_base_apis: baseViewController {
    
    var refreshControl_tableview = UIRefreshControl()
    
    
    var delegate:load_base_apis_delegate?
    
    @IBOutlet private weak var tableview: UITableView!
    @IBOutlet private weak var img_customers: KSImageView!
    @IBOutlet private weak var img_product_category: KSImageView!
    @IBOutlet private weak var img_account_tax: KSImageView!
    @IBOutlet private weak var img_productlist_items: KSImageView!
    @IBOutlet private weak var img_productlist: KSImageView!
    @IBOutlet private weak var img_bankStatment: KSImageView!
    @IBOutlet private weak var img_products: KSImageView!
    @IBOutlet private weak var img_orderType: KSImageView!
    @IBOutlet private weak var img_productCombo: KSImageView!
    @IBOutlet private weak var img_scrap_reason: KSImageView!
    
    @IBOutlet private weak var btnSkip: UIButton!
    
    @IBOutlet private weak var viewTable: UIView!
    @IBOutlet private weak var viewLoading: ShadowView!
    @IBOutlet private weak var progressView: UIProgressView!
    @IBOutlet private weak var viewSuccess: UIView!
    @IBOutlet private weak var viewFail: UIView!
    @IBOutlet weak var lbl_DGTERA_Message: UILabel!
    @IBOutlet weak var lblShowErrors: UILabel!

    @IBOutlet   weak var bg_image: KSImageView!
    @IBOutlet private weak var lbl_loading_title_progress: UILabel!
    
    var con:api? = SharedManager.shared.conAPI()
    public var userCash:cashStatus? = .useCash
    
    
    //    var list_queue:[()->()] = []
    var list_items:[String:[Any]]! = [:]
    var list_keys:[String]! = []
    var index = 0
    
    var start:Bool = false
    var stop:Bool = false

    var forceSync:Bool = false
    var get_new:Bool = true
    
    var  localCash:cash_data_class?
    
 
        override func viewDidDisappear(_ animated: Bool) {
            
            stop = true
            super.viewDidDisappear(animated)

          
            cleanMemory()
    
        
        }
    
    
    func cleanMemory()
    {
 
 
        
        if bg_image != nil
        {
            bg_image.image = nil

        }
        bg_image = nil
        list_items = nil
        list_keys = nil
        localCash = nil
        userCash = nil
        con = nil
    }
    
    override func viewDidLoad() {
        self.stop_zoom = true
        super.viewDidLoad()
        
 
//        forceSync = true
        
         lblShowErrors.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.lblShowErrorsTapped)))
 
        lblShowErrors.attributedText = "Sync Problem Please Click Here For more Details".attributedTextUnderlined(rangeString: "Click Here")

         
        
        initTable()
        initFunc()
        
        
 
        let isApisLoaded:String = cash_data_class.get(key: "load_base_apis_ApisLoaded") ?? ""
        if isApisLoaded == "true"
        {
            btnSkip.isHidden = false
        }
        else
        {
            btnSkip.isHidden = true
        }
        if let cash_need_sync =  cash_data_class.get(key: "need_to_sync"), cash_need_sync == "1"  {
            btnSkip.isHidden = true
        }

        
    }
    
    @objc
    func lblShowErrorsTapped(sender:UITapGestureRecognizer) {
        viewLoading.isHidden = true
        viewTable.isHidden = false
    }
    
    var index_order = -1
    func getIndex() -> Int
    {
        index_order = index_order + 1
        
        return index_order
    }
    
    @IBAction func btnSkip(_ sender: Any) {
        SharedManager.shared.setGloobalObject()

        stop = true

        if delegate != nil
        {
            delegate?.isApisLoaded(status: true)
        }
        
    }
    
    
    
    func check_run(return_delegate:Bool) -> Bool
    {
 
        let CashTime = SharedManager.shared.appSetting().cash_time
               localCash = cash_data_class( CashTime )
        localCash?.enableCash = false

        if forceSync == false
        {
       
            localCash?.enableCash = true

            let check =  localCash?.isTimeTopdate("api_loaded")
            if  check == false
            {
                if return_delegate
                {
                    delegate?.isApisLoaded(status: true)
                    
                }
                return false
            }
            
        }
        
        
        return true
    }
    
    
    func initFunc()
    {
        
        // name , isDone,func_name,?,index,isRequired
        list_items["get_point_of_sale"] = ["get point of sale",false,get_point_of_sale,"",getIndex(),true]
        list_items["get_pos_category"] = ["get category",false,get_pos_category,"",getIndex(),true]
        list_items["get_product_product"] = ["get products",false,get_product_product,"",getIndex(),true]
        list_items["get_product_pricelist"] = ["get product pricelist",false,get_product_pricelist,"", getIndex(),true]
        list_items["get_product_pricelist_item"] = ["get product pricelist item",false,get_product_pricelist_item,"",getIndex(),true]
        list_items["get_account_tax"] = ["get account tax",false,get_account_tax,"",getIndex(),true]
        
        list_items["get_account_Journals"] = ["get bank statment",false,get_account_Journals,"",getIndex(),true]
        list_items["get_currencies"] = ["get currencies",false,get_currencies,"",getIndex(),true]
        list_items["get_brands"] = ["get brands",false,get_brands,"",getIndex(),false]
        list_items["get_companies"] = ["get companies",false,get_companies,"",getIndex(),true]
        list_items["get_countries"] = ["get countries",false,get_countries,"",getIndex(),true]
        list_items["get_users"] = ["get users",false,get_users ,"",getIndex(),true]
        list_items["get_pos_delivery_area"] = ["get pos_delivery_area",false,get_pos_delivery_area,"",getIndex(),false]

        
        list_items["restaurant_floor"] = ["Restaurant floors", false, restaurant_floor, "", getIndex(), false]
        list_items["restaurant_table"] = ["Restaurant tables", false, restaurant_table, "", getIndex(), false]
        list_items["get_order_type"] = ["get order type",false,get_order_type,"",getIndex(),false]
        
        list_items["get_order_type_category"] = ["get order type category",false,get_order_type_category,"",getIndex(),false]
        
        list_items["get_product_template_attribute_line"] = ["get product template attribute line",false,get_product_template_attribute_line,"",getIndex(),true]
        list_items["get_product_template_attribute_value"] = ["get product template attribute value",false,get_product_template_attribute_value,"",getIndex(),true]
        
        list_items["get_product_attribute_value"] = ["get product attribute value",false,get_product_attribute_value,"",getIndex(),true]
        list_items["get_product_attribute"] = ["get product attribute",false,get_product_attribute,"",getIndex(),true]
        list_items["get_ir_translation"] = ["get translation",false,get_ir_translation,"",getIndex(),true]
        
      
        
        list_items["check_rules"] = ["check rules",false,check_rules,"",getIndex(),true]
        list_items["get_rules"] = ["get rules",false,get_rules,"",getIndex(),true]
        list_items["get_groups"] = ["get groups",false,get_groups,"",getIndex(),true]
        list_items["create_settings"] = ["create setting",false,create_settings,"",getIndex(),false]
        list_items["create_pos_settings"] = ["create pos setting",false,create_pos_settings,"",getIndex(),false]
        list_items["get_setting"] = ["get setting",false,get_settings,"",getIndex(),false]
        list_items["load_loyalty_config_settings"] = ["load loyalty onfig settings",false,load_loyalty_config_settings,"",getIndex(),false]

        
        
        
        if AppDelegate.shared.load_kds == false
        {
            
            // optioanl
//            list_items["get_customers"] = ["get customers",false,get_customers,"",getIndex(),false]
//            list_items["get_customers"] = ["get customers",false,get_customers_last_sync,"",getIndex(),false]
            list_items["get_scrap_reason"] = ["get scrap reason",false,get_scrap_reason,"",getIndex(),false]
            list_items["get_product_combo"] = ["get product combo",false,get_product_combo,"",getIndex(),false]
            list_items["get_product_combo_prices"] = ["get product combo prices",false,get_product_combo_prices,"",getIndex(),false]
            list_items["get_product_combo_price_line"] = ["get product combo price line",false,get_product_combo_price_line,"",getIndex(),false]

            list_items["get_discount_program"] = ["get discount program",false,get_discount_program,"",getIndex(),false]
            list_items["get_pos_printers"] = ["get pos printers",false,get_pos_printers,"",getIndex(),false]
            list_items["get_pos_product_notes"] = ["get pos product note",false,get_pos_product_notes,"",getIndex(),false]
            list_items["get_porduct_template"] = ["get pos product template",false,get_porduct_template,"",getIndex(),false]
            
            list_items["pos_conditions"] = ["get pos conditions",false,pos_conditions,"",getIndex(),false]
            list_items["pos_promotion"] = ["get pos_promotion",false,pos_promotion,"",getIndex(),false]
            list_items["day_week"] = ["get day_week",false,day_week,"",getIndex(),false]
            list_items["get_discount"] = ["get get_discount",false,get_discount,"",getIndex(),false]
            list_items["quantity_discount"] = ["get quantity_discount",false,quantity_discount,"",getIndex(),false]
            list_items["quantity_discount_amt"] = ["get quantity_discount_amt",false,quantity_discount_amt,"",getIndex(),false]
            list_items["discount_multi_products"] = ["get discount_multi_products",false,discount_multi_products,"",getIndex(),false]
            list_items["discount_multi_categories"] = ["get discount_multi_categories",false,discount_multi_categories,"",getIndex(),false]
            list_items["discount_above_price"] = ["get discount_above_price",false,discount_above_price,"",getIndex(),false]
            list_items["get_pos_return_reason"] = ["get pos return reason",false,get_pos_return_reason,"",getIndex(),false]
            list_items["get_drivers"] = ["get drivers",false,get_drivers,"",getIndex(),false]

            
       
            
        }
        
        
        for _  in 0...index_order
        {
            list_keys.append("")
        }
        
        for (key, value) in list_items {
            //            arr.append([keyIndex[key]!: value])
            let index = value[4]  as! Int
            
            list_keys.remove(at: index)
            list_keys.insert(key, at: index)
        }
        
        
        //        list_keys = Array( list_items.keys)
        
        
        
        tableview.reloadData()
    }
    public func startQueue()
    {
     
        SharedManager.shared.resetGloobalObject()
        if check_run(return_delegate: true) == false
        {
            return
        }
         
        
        index = 0
        start = true
        runQueue()
    }
    
    public func runQueue()
    {
         
            runQueueDo()
        
    }
    
    func is_frist_time_load() -> Bool
    {
        
        let sql = """
                    select
                    (select count(*) from pos_category) as pos_category,
                    (select count(*) from product_product) as product_product,
                    (select count(*) from product_pricelist) as product_pricelist,
                    (select count(*) from product_pricelist_item) as product_pricelist_item,
                    (select count(*) from account_tax) as account_tax,
                    (select count(*) from account_Journal) as account_Journal,
                    (select count(*) from res_users ) as res_users
        """
        
        let data:[[String : Any]] =  database_class(connect: .database).get_rows(sql: sql)

        if data.count > 0
        {
            let row = data[0]
            let pos_category = row["pos_category"] as? Int ?? 0
            let product_product = row["product_product"] as? Int ?? 0
            let product_pricelist = row["product_pricelist"] as? Int ?? 0
            let product_pricelist_item = row["product_pricelist_item"] as? Int ?? 0
            let account_tax = row["account_tax"] as? Int ?? 0
            let res_users = row["res_users"] as? Int ?? 0

            if pos_category != 0 &&  product_product != 0 &&  product_pricelist != 0 &&  product_pricelist_item != 0 &&  account_tax != 0 &&  res_users != 0
            {
                return false
            }
            

        }
         
        
        return true
    }
    
    public func runQueueDo()
    {
        if stop
        {
            return
        }
        
        refreshControl_tableview.isEnabled = false
        tableview.reloadData()
        
        con!.userCash = userCash!
        
        
        
        let count = list_keys.count
        if count   == index
        {
            refreshControl_tableview.isEnabled = true
            refreshControl_tableview.endRefreshing()
            start = false
            
            var all_done = true
            for (_, value) in list_items
            {
                let isRequired = value[5] as? Bool
                if isRequired == true
                {
                    let v = value[1] as? Bool
                    if v  == false
                    {
                        
                        all_done = false
                        break
                    }
                }
            }
            
            
            
            //                 initAppClac.forceToRun()
            
            //            let clac = initAppClac()
            //            clac.loadGuides()
            
            localCash?.setTimelastupdate("api_loaded")
            
            cash_data_class.set(key: "load_base_apis_ApisLoaded", value: "true")
            if all_done {
                cash_data_class.set(key: "lastupdate" +  "_"  + "api_loaded_fail", value: "")
                cash_data_class.set(key: "need_to_sync", value: "0")
                MWQueue.shared.firebaseQueue.async {
//              DispatchQueue.global(qos: .background).async {
                    FireBaseService.defualt.updatePresenceStatus()
                    FireBaseService.defualt.updateInfoPOS()
                    FireBaseService.defualt.updateForceSync()
                    FireBaseService.defualt.updateInfoTCP("load_apis")
                    FireBaseService.defualt.setLastChainIndexFromFR()

                }
            }else{
                localCash?.setTimelastupdate("api_loaded_fail")
            }
            AppDelegate.shared.vacuum_database()
            
                        
            if !all_done  {
                if is_frist_time_load() == true
                {
                    viewSuccess.isHidden = true
                    viewFail.isHidden = false
                }
                else
                {
                    btnSkip(AnyClass.self)
                }
             
            }
            
            delegate?.isApisLoaded(status: all_done)
            
        }
        else if index < count
        {
       
            let key = list_keys[index]
            getLastUpdate(key: key)
            
            let title = list_items[key]![0] as? String ?? ""
            lbl_loading_title_progress.text = "Sync data /  " + title + " ..."
            
            let fnc = list_items[key]![2] as? ()->()
            
            if fnc != nil
            {
                index += 1
                
                progressView.setProgress((Float(index) / Float(list_keys.count)), animated: true)
                fnc!()
            }
           
        }
        
        
        
    }
    
    func getLastUpdate(key:String)
    {
        con!.lastUpdate = "1970-1-1 00:00:00"
        
//        if get_new == true
//        {
//            let timelastupdate = self.localCash?.getTimelastupdate(key) ?? "0"
//            con!.lastUpdate = Date.init(millis: Int64(timelastupdate) ?? 0).toString(dateFormat: "yyyy-MM-dd HH:mm:ss", UTC: true)
//        }
        
        
    }
    
    func handleUI(item_key:String,result:  api.api_Results?) -> Bool
    {
  
    
    
        
        
        if self.list_items == nil
        {
            return false
        }
        
        if stop == true
        {
            return false
        }
        
        if result == nil
        {
            self.list_items[item_key]![1] = true
            return false
        }
        
        
        if (result?.success ?? false)
        {
            
            self.list_items[item_key]![1] = true
            
            return true
            
            
        }
        else
        {
            let Required =  self.list_items[item_key]![5] as? Bool ?? true
            if Required == true
            {
                self.list_items[item_key]![1] = false
                
            }
            else
            {
                self.list_items[item_key]![1] = true
                
            }
            
            self.list_items[item_key]![2] = result?.message ?? "error"
            
        }
        
        
        return false
    }
    
    func load_loyalty_config_settings()
    {
        let item_key = "load_loyalty_config_settings" ;
        if localCash?.isTimeTopdate(item_key) == false  {
            _ = self.handleUI(item_key: item_key, result: nil)
            self.runQueue()
            return
        }
        
        let pos = SharedManager.shared.posConfig()

        con!.load_loyalty_config_settings(company_id: pos.company_id!) { (result) in
            let saveInDataBase = self.handleUI(item_key: item_key, result: result)
            if saveInDataBase
            {
                let item:[String:Any]  = result.response?["result"] as? [String:Any] ?? [:]
                
                 loyalty_config_settings_class.reset()

                let cls = loyalty_config_settings_class(fromDictionary: item)
                cls.dbClass?.insertId = false
                cls.save()
                
                self.localCash?.setTimelastupdate(item_key)
                
            }
            
            self.runQueue()
            
        }
    }
    
    func get_pos_printers()
    {
        
        let item_key = "get_pos_printers" ;
        if localCash?.isTimeTopdate(item_key) == false  {
            _ = self.handleUI(item_key: item_key, result: nil)
            self.runQueue()
            return
        }
        
        
        let pos = SharedManager.shared.posConfig()
        
        con!.get_pos_printers(printer_ids: pos.printer_ids)  { (result) in
            let saveInDataBase = self.handleUI(item_key: item_key, result: result)
            if saveInDataBase
            {
                let list:[[String:Any]]  = result.response?["result"] as? [[String:Any]] ?? []
                
                let cls = restaurant_printer_class(fromDictionary: [:])
                
                pos_base_class.create_temp(  cls.dbClass!)
                restaurant_printer_class.reset(temp: true)
                restaurant_printer_class.saveAll(arr: list,temp: true)
                pos_base_class.copy_temp( cls.dbClass!)
                
                self.localCash?.setTimelastupdate(item_key)
                
            }
            
            self.runQueue()        }
        
    }
    
    func get_countries()
    {
        let item_key = "get_countries" ;
        if localCash?.isTimeTopdate(item_key) == false  {
            _ = self.handleUI(item_key: item_key, result: nil)
            self.runQueue()
            return
        }
        
        con!.get_countries { (result) in
            let saveInDataBase = self.handleUI(item_key: item_key, result: result)
            if saveInDataBase
            {
                let list:[[String:Any]]  = result.response?["result"] as? [[String:Any]] ?? []
                
                let cls = res_country_class(fromDictionary: [:])

                pos_base_class.create_temp(  cls.dbClass!)
                res_country_class.reset(temp: true)
                res_country_class.saveAll(arr: list,temp: true)
                pos_base_class.copy_temp( cls.dbClass!)

                self.localCash?.setTimelastupdate(item_key)
                
            }
            
            self.runQueue()
            
        }
    }
    func get_pos_delivery_area()
    {
        let item_key = "get_pos_delivery_area" ;
        if localCash?.isTimeTopdate(item_key) == false  {
            _ = self.handleUI(item_key: item_key, result: nil)
            self.runQueue()
            return
        }
        
        con!.get_pos_delivery_area_api() { (result) in
            let saveInDataBase = self.handleUI(item_key: item_key, result: result)
            if saveInDataBase
            {
                let list:[[String:Any]]  = result.response?["result"] as? [[String:Any]] ?? []
                
                let cls = pos_delivery_area_class(fromDictionary: [:])
                pos_base_class.create_temp(cls.dbClass!)
                pos_base_class.rest_temp(cls.dbClass!)

                pos_delivery_area_class.reset(temp:true)
                pos_delivery_area_class.saveAll(arr: list,temp: true)
                pos_base_class.copy_temp( cls.dbClass!)

                
                self.localCash?.setTimelastupdate(item_key)
                
            }
            
            self.runQueue()
            
        }
    }
    
    func get_users()
    {
        let item_key = "get_users" ;
        if localCash?.isTimeTopdate(item_key) == false  {
            _ = self.handleUI(item_key: item_key, result: nil)
            self.runQueue()
            return
        }
        
        let pos = SharedManager.shared.posConfig()
        con!.get_pos_users(posID: pos.id) { (result) in
            let saveInDataBase = self.handleUI(item_key: item_key, result: result)
            if saveInDataBase
            {
                let list:[[String:Any]]  = result.response?["result"] as? [[String:Any]] ?? []
                
                let cls = res_users_class(fromDictionary: [:])
                pos_base_class.create_temp(  cls.dbClass!)
//                pos_base_class.rest_temp( cls.dbClass!)

                res_users_class.reset(temp:true)
                res_users_class.saveAll(arr: list,excludeProperties: ["is_login","fristLogin","lastLogin"],temp: true)
                pos_base_class.copy_temp( cls.dbClass!)
                SharedManager.shared.removeNotUsesFiles(from: .images, in: .res_users,
                                                        filesName: list.map({"\($0["id"] as? Int ?? 0 ).png"}))

                
                self.localCash?.setTimelastupdate(item_key)
                
            }
            
            self.runQueue()
            
        }
    }
     
    func get_discount_program()
    {
        let item_key = "get_discount_program" ;
        if localCash?.isTimeTopdate(item_key) == false  {
            _ = self.handleUI(item_key: item_key, result: nil)
            self.runQueue()
            return
        }
        
        con!.get_discount_program { (result) in
            let saveInDataBase = self.handleUI(item_key: item_key, result: result)
            if saveInDataBase
            {
                let list:[[String:Any]]  = result.response?["result"] as? [[String:Any]] ?? []
                
                let cls = pos_discount_program_class(fromDictionary: [:])
                pos_base_class.create_temp(  cls.dbClass!)
//                pos_base_class.rest_temp( cls.dbClass!)
                pos_discount_program_class.reset(temp:true)
                pos_discount_program_class.saveAll(arr: list,temp: true)
                pos_base_class.copy_temp( cls.dbClass!)

                self.localCash?.setTimelastupdate(item_key)
                
            }
            
            self.runQueue()
            
        }
    }
     
    func get_point_of_sale()
    {
        let item_key = "get_point_of_sale" ;
        if localCash?.isTimeTopdate(item_key) == false  {
            _ = self.handleUI(item_key: item_key, result: nil)
            self.runQueue()
            return
        }
        if let pos_ID = Int(cash_data_class.get(key: "pinInfo_pos_ID") ?? "0") , pos_ID != 0{
            let domain:[Any] = [ ["id","=",pos_ID]]
            
            con!.get_info_point_of_sale( domain) { (result) in
                let saveInDataBase = self.handleUI(item_key: item_key, result: result)
                if saveInDataBase
                {
                    let list:[[String:Any]]  = result.response?["result"] as? [[String:Any]] ?? []
                    
                    let cls = pos_config_class(fromDictionary: [:])
                    pos_base_class.create_temp(  cls.dbClass!)
                    //                pos_config_class.reset()
                    pos_config_class.saveAll(arr: list,temp: true)
                    pos_base_class.copy_temp( cls.dbClass!)
                    SharedManager.shared.setGloobalObject()
                    self.appendSyncCloudKitchenAPIS()
                    
                    MWQueue.shared.firebaseQueue.async {
                        FireBaseService.defualt.setLastChainIndexFromFR()
                    }
                    self.localCash?.setTimelastupdate(item_key)
                    
                }
                
                self.runQueue()
                
            }
        }else{
            self.runQueue()
            return

        }
    }
     
    func restaurant_floor() {
        let item_key = "restaurant_floor" ;
        if localCash?.isTimeTopdate(item_key) == false  {
            _ = self.handleUI(item_key: item_key, result: nil)
            self.runQueue()
            return
        }
        let pos = SharedManager.shared.posConfig()
        let available_floors_ids = pos.available_floors_ids
        if (available_floors_ids.count) <= 0 {
            _ = self.handleUI(item_key: item_key, result: nil)
            self.runQueue()
            return
        }
        
        con!.restaurant_floor { (result) in
            let saveInDataBase = self.handleUI(item_key: item_key, result: result)
            if saveInDataBase
            {
                let list:[[String:Any]]  = result.response?["result"] as? [[String:Any]] ?? []
                
                let cls = restaurant_floor_class(fromDictionary: [:])
                pos_base_class.create_temp(  cls.dbClass!)
                restaurant_floor_class.reset(temp: true)
                restaurant_floor_class.saveAll(arr: list,temp: true)
                pos_base_class.copy_temp( cls.dbClass!)

                self.localCash?.setTimelastupdate(item_key)
                
            }
            
            self.runQueue()
            
        }
        
    }
    
    func restaurant_table() {
        
        let item_key = "restaurant_table" ;
        if localCash?.isTimeTopdate(item_key) == false  {
            _ = self.handleUI(item_key: item_key, result: nil)
            self.runQueue()
            return
        }
        
        con!.restaurant_table { (result) in
            let saveInDataBase = self.handleUI(item_key: item_key, result: result)
            if saveInDataBase
            {
                let list:[[String:Any]]  = result.response?["result"] as? [[String:Any]] ?? []
                
                let cls = restaurant_table_class(fromDictionary: [:])
                pos_base_class.create_temp(  cls.dbClass!)
                restaurant_table_class.reset(temp: true)
                restaurant_table_class.saveAll(arr: list,temp: true)
                pos_base_class.copy_temp( cls.dbClass!)

                
                self.localCash?.setTimelastupdate(item_key)
                
            }
            
            self.runQueue()
            
        }
        
        
    }
     
    func get_currencies()
    {
        let item_key = "get_currencies" ;
        if localCash?.isTimeTopdate(item_key) == false  {
            _ = self.handleUI(item_key: item_key, result: nil)
            self.runQueue()
            return
        }
        
        
        con!.get_currencies { (result) in
            let saveInDataBase = self.handleUI(item_key: item_key, result: result)
            if saveInDataBase
            {
                let list:[[String:Any]]  = result.response?["result"] as? [[String:Any]] ?? []
                
                let cls = res_currency_class(fromDictionary: [:])
                pos_base_class.create_temp(  cls.dbClass!)
                res_currency_class.reset(temp: true)
                res_currency_class.saveAll(arr: list,temp: true)
                pos_base_class.copy_temp( cls.dbClass!)

                self.localCash?.setTimelastupdate(item_key)
                
            }
            
            self.runQueue()
            
        }
    }
    
    func get_pos_product_notes()
    {
        let item_key = "get_pos_product_notes" ;
        if localCash?.isTimeTopdate(item_key) == false  {
            _ = self.handleUI(item_key: item_key, result: nil)
            self.runQueue()
            return
        }
        
        
        con!.get_pos_product_notes { (result) in
            let saveInDataBase = self.handleUI(item_key: item_key, result: result)
            if saveInDataBase
            {
                let list:[[String:Any]]  = result.response?["result"] as? [[String:Any]] ?? []
                
                let cls = pos_product_notes_class(fromDictionary: [:])
                pos_base_class.create_temp(  cls.dbClass!)
                pos_product_notes_class.reset(temp: true)
                pos_product_notes_class.saveAll(arr: list,temp: true)
                pos_base_class.copy_temp( cls.dbClass!)

                self.localCash?.setTimelastupdate(item_key)
                
            }
            
            self.runQueue()
            
        }
    }
    
    func get_porduct_template()
    {
        let item_key = "get_porduct_template" ;
        if localCash?.isTimeTopdate(item_key) == false  {
            _ = self.handleUI(item_key: item_key, result: nil)
            self.runQueue()
            return
        }
        
        con!.get_porduct_template { (result) in
            let saveInDataBase = self.handleUI(item_key: item_key, result: result)
            if saveInDataBase
            {
                let list:[[String:Any]]  = result.response?["result"] as? [[String:Any]] ?? []
                
                let cls = product_template_class(fromDictionary: [:])
                pos_base_class.create_temp(  cls.dbClass!)
//                pos_base_class.rest_temp( cls.dbClass!)
                product_template_class.reset(temp:true)
                product_template_class.saveAll(arr: list,temp: true)
                pos_base_class.copy_temp( cls.dbClass!)

                
                self.localCash?.setTimelastupdate(item_key)
                
            }
            
            self.runQueue()
            
        }
    }
    //get_brands
    func get_brands()
    {
        let item_key = "get_brands" ;
        if localCash?.isTimeTopdate(item_key) == false  {
            _ = self.handleUI(item_key: item_key, result: nil)
            self.runQueue()
            return
        }
        
        con!.get_brands { (result) in
            let saveInDataBase = self.handleUI(item_key: item_key, result: result)
            if saveInDataBase
            {
                let list:[[String:Any]]  = result.response?["result"] as? [[String:Any]] ?? []
                
                let cls = res_brand_class(fromDictionary: [:])
                pos_base_class.create_temp(  cls.dbClass!)
                res_brand_class.saveAll(arr: list,temp: true)
                pos_base_class.copy_temp( cls.dbClass!)
                SharedManager.shared.removeNotUsesFiles(from: .images, in: .res_brand,
                                                        filesName: list.map({"\($0["id"] as? Int ?? 0 ).png"}))
                res_brand_class.setDefultSelect()
                self.localCash?.setTimelastupdate(item_key)
                
            }
            
            self.runQueue()
            
        }
    }
    func get_companies()
    {
        let item_key = "get_companies" ;
        if localCash?.isTimeTopdate(item_key) == false  {
            _ = self.handleUI(item_key: item_key, result: nil)
            self.runQueue()
            return
        }
        
        con!.get_companies { (result) in
            let saveInDataBase = self.handleUI(item_key: item_key, result: result)
            if saveInDataBase
            {
                let list:[[String:Any]]  = result.response?["result"] as? [[String:Any]] ?? []
                
                let cls = res_company_class(fromDictionary: [:])
                pos_base_class.create_temp(  cls.dbClass!)
//                pos_base_class.rest_temp( cls.dbClass!)
                res_company_class.reset(temp:true)
                res_company_class.saveAll(arr: list,temp: true)
                pos_base_class.copy_temp( cls.dbClass!)
                SharedManager.shared.removeNotUsesFiles(from: .images, in: .res_company,
                                                        filesName: list.map({"\($0["id"] as? Int ?? 0 ).png"}))
                self.localCash?.setTimelastupdate(item_key)
                
            }
            
            self.runQueue()
            
        }
    }
    
    func get_product_combo_prices()
    {
        let item_key = "get_product_combo_prices" ;
        if localCash?.isTimeTopdate(item_key) == false  {
            _ = self.handleUI(item_key: item_key, result: nil)
            self.runQueue()
            return
        }
        
        con!.get_product_combo_prices { (result) in
            let saveInDataBase = self.handleUI(item_key: item_key, result: result)
            if saveInDataBase
            {
                let list:[[String:Any]]  = result.response?["result"] as? [[String:Any]] ?? []
                
                let cls = product_combo_price_class(fromDictionary: [:])
                pos_base_class.create_temp(  cls.dbClass!)
//                pos_base_class.rest_temp( cls.dbClass!)
                product_combo_price_class.reset(temp: true)
                product_combo_price_class.saveAll(arr: list,temp: true)
                pos_base_class.copy_temp( cls.dbClass!)

                self.localCash?.setTimelastupdate(item_key)
                
            }
            
            self.runQueue()
            
        }
    }
    
    func get_order_type_category()
    {
        let item_key = "get_order_type_category" ;
        if localCash?.isTimeTopdate(item_key) == false  {
            _ = self.handleUI(item_key: item_key, result: nil)
            self.runQueue()
            return
        }
        
        con!.get_delivery_type_category { (result) in
            let saveInDataBase = self.handleUI(item_key: item_key, result: result)
            if saveInDataBase
            {
                let list:[[String:Any]]  = result.response?["result"] as? [[String:Any]] ?? []
                
                let cls = delivery_type_category_class(fromDictionary: [:])
                pos_base_class.create_temp(  cls.dbClass!)
//                pos_base_class.rest_temp( cls.dbClass!)
                delivery_type_category_class.reset(temp: true)
                delivery_type_category_class.saveAll(arr: list,temp: true)
                pos_base_class.copy_temp( cls.dbClass!)

                self.localCash?.setTimelastupdate(item_key)
                
            }
            
            self.runQueue()
            
        }
    }

    
    func get_order_type()
    {
        let item_key = "get_order_type" ;
        if localCash?.isTimeTopdate(item_key) == false  {
            _ = self.handleUI(item_key: item_key, result: nil)
            self.runQueue()
            return
        }
        
        con!.get_order_type { (result) in
            let saveInDataBase = self.handleUI(item_key: item_key, result: result)
            if saveInDataBase
            {
                let list:[[String:Any]]  = result.response?["result"] as? [[String:Any]] ?? []
                
                let cls = delivery_type_class(fromDictionary: [:])
                pos_base_class.create_temp(  cls.dbClass!)
//                pos_base_class.rest_temp( cls.dbClass!)
                delivery_type_class.reset(temp: true)
                delivery_type_class.saveAll(arr: list,temp: true)
                pos_base_class.copy_temp( cls.dbClass!)

                self.localCash?.setTimelastupdate(item_key)
                
            }
            
            self.runQueue()
            
        }
    }
    
    func get_product_combo()
    {
        let item_key = "get_product_combo" ;
        if localCash?.isTimeTopdate(item_key) == false  {
            _ = self.handleUI(item_key: item_key, result: nil)
            self.runQueue()
            return
        }
        
        con!.get_porduct_combo { (result) in
            let saveInDataBase = self.handleUI(item_key: item_key, result: result)
            if saveInDataBase
            {
                let list:[[String:Any]]  = result.response?["result"] as? [[String:Any]] ?? []
                
                let cls = product_combo_class(fromDictionary: [:])
                pos_base_class.create_temp(  cls.dbClass!)
//                pos_base_class.rest_temp( cls.dbClass!)
                product_combo_class.reset(temp: true)
                product_combo_class.saveAll(arr: list,temp: true)
                pos_base_class.copy_temp( cls.dbClass!)

                
                self.localCash?.setTimelastupdate(item_key)
                
            }
            
            self.runQueue()
            
        }
    }
    
    func get_scrap_reason()
    {
        let item_key = "get_scrap_reason" ;
        if localCash?.isTimeTopdate(item_key) == false  {
            _ = self.handleUI(item_key: item_key, result: nil)
            self.runQueue()
            return
        }
        
        con!.get_scrap_reason { (result) in
            let saveInDataBase = self.handleUI(item_key: item_key, result: result)
            if saveInDataBase
            {
                let list:[[String:Any]]  = result.response?["result"] as? [[String:Any]] ?? []
                
                let cls = scrap_reason_class(fromDictionary: [:])
                pos_base_class.create_temp(  cls.dbClass!)
                scrap_reason_class.reset(temp: true)
                scrap_reason_class.saveAll(arr: list,temp: true)
                pos_base_class.copy_temp( cls.dbClass!)

                self.localCash?.setTimelastupdate(item_key)
                
            }
            
            self.runQueue()
            
        }
    }
    
    func get_customers()
    {
        let item_key = "get_customers" ;
        if localCash?.isTimeTopdate(item_key) == false  {
            _ = self.handleUI(item_key: item_key, result: nil)
            self.runQueue()
            return
        }
        
        con!.get_customers { (result) in
            let saveInDataBase = self.handleUI(item_key: item_key, result: result)
            if saveInDataBase
            {
                let list:[[String:Any]]  = result.response?["result"] as? [[String:Any]] ?? []
                
                let cls = res_partner_class(fromDictionary: [:])
                pos_base_class.create_temp(  cls.dbClass!)
                res_partner_class.reset(temp: true)
                res_partner_class.saveAll(arr: list,temp: true)
                pos_base_class.copy_temp( cls.dbClass!)

                
                self.localCash?.setTimelastupdate(item_key)
                
            }
            
            self.runQueue()
            
        }
    }
    func get_drivers()
    {
        let item_key = "get_drivers" ;
        if localCash?.isTimeTopdate(item_key) == false  {
            _ = self.handleUI(item_key: item_key, result: nil)
            self.runQueue()
            return
        }
        
        con!.get_drivers { (result) in
            let saveInDataBase = self.handleUI(item_key: item_key, result: result)
            if saveInDataBase
            {
                let list:[[String:Any]]  = result.response?["result"] as? [[String:Any]] ?? []
                
                let cls = pos_driver_class(fromDictionary: [:])
                pos_base_class.create_temp(  cls.dbClass!)
                pos_driver_class.reset(temp: true)
                pos_driver_class.saveAll(arr: list,temp: true)
                pos_base_class.copy_temp( cls.dbClass!)

                self.localCash?.setTimelastupdate(item_key)
                
            }
            
            self.runQueue()
            
        }
    }
    func get_product_pricelist()
    {
        
        let item_key = "get_product_pricelist" ;
        if localCash?.isTimeTopdate(item_key) == false  {
            _ = self.handleUI(item_key: item_key, result: nil)
            self.runQueue()
            return
        }
        
        
        con!.get_product_pricelist { (result) in
            let saveInDataBase = self.handleUI(item_key: item_key, result: result)
            if saveInDataBase
            {
                let list:[[String:Any]]  = result.response?["result"] as? [[String:Any]] ?? []
                
                let cls = product_pricelist_class(fromDictionary: [:])
                pos_base_class.create_temp(  cls.dbClass!)
//                pos_base_class.rest_temp( cls.dbClass!)
                product_pricelist_class.reset(temp: true)
                product_pricelist_class.saveAll(arr: list,temp: true)
                pos_base_class.copy_temp( cls.dbClass!)

                self.localCash?.setTimelastupdate(item_key)
                
            }
            
            self.runQueue()
        }
        
    }
    
    func get_product_pricelist_item()
    {
        
        
        let item_key = "get_product_pricelist_item" ;
        if localCash?.isTimeTopdate(item_key) == false  {
            _ = self.handleUI(item_key: item_key, result: nil)
            self.runQueue()
            return
        }
        
        con!.get_product_pricelist_item { (result) in
            let saveInDataBase = self.handleUI(item_key: item_key, result: result)
            if saveInDataBase
            {
                let list:[[String:Any]]  = result.response?["result"] as? [[String:Any]] ?? []
                
                let cls = product_pricelist_item_class(fromDictionary: [:])
                pos_base_class.create_temp(  cls.dbClass!)
//                pos_base_class.rest_temp( cls.dbClass!)
                product_pricelist_item_class.reset(temp: true)
                product_pricelist_item_class.saveAll(arr: list,temp: true)
                pos_base_class.copy_temp( cls.dbClass!)

                self.localCash?.setTimelastupdate(item_key)
                
            }
            
            self.runQueue()
            
            
        }
    }
    
    func get_account_tax()
    {
        
        let item_key = "get_account_tax" ;
        if localCash?.isTimeTopdate(item_key) == false  {
            _ = self.handleUI(item_key: item_key, result: nil)
            self.runQueue()
            return
        }
        
        
        con!.get_account_tax { (result) in
            let saveInDataBase = self.handleUI(item_key: item_key, result: result)
            if saveInDataBase
            {
                let list:[[String:Any]]  = result.response?["result"] as? [[String:Any]] ?? []
                
                let cls = account_tax_class(fromDictionary: [:])
                pos_base_class.create_temp(  cls.dbClass!)
//                pos_base_class.rest_temp( cls.dbClass!)
                account_tax_class.reset(temp: true)
                account_tax_class.saveAll(arr: list,temp: true)
                pos_base_class.copy_temp( cls.dbClass!)

                self.localCash?.setTimelastupdate(item_key)
                
            }
            
            self.runQueue()
        }
    }
    
    func get_pos_category()
    {
        let item_key = "get_pos_category"
        if localCash?.isTimeTopdate(item_key) == false  {
            _ = self.handleUI(item_key: item_key, result: nil)
            self.runQueue()
            return
        }
        
 
        
        con!.get_pos_category { (result) in
            
            let saveInDataBase = self.handleUI(item_key: item_key, result: result)
            if saveInDataBase
            {
                let list:[[String:Any]]  = result.response?["result"] as? [[String:Any]] ?? []
                
                let cls = pos_category_class(fromDictionary: [:])
                
                pos_base_class.create_temp(  cls.dbClass!)
                pos_category_class.reset(temp: true)
                pos_category_class.saveAll(arr: list,temp: true)
                pos_base_class.copy_temp( cls.dbClass!)
                SharedManager.shared.removeNotUsesFiles(from: .images, in: .pos_category,
                                                        filesName: list.map({"\($0["id"] as? Int ?? 0 ).png"}))

                self.localCash?.setTimelastupdate(item_key)
                
            }
            
            self.runQueue()
        }
        
        
    }
    
    func get_product_product()
    {
        
        let item_key = "get_product_product"
        if localCash?.isTimeTopdate(item_key) == false {
            _ = self.handleUI(item_key: item_key, result: nil)
            self.runQueue()
            return
            
        }
        
        
        con!.get_product_product { (result) in
            
            let saveInDataBase = self.handleUI(item_key: item_key, result: result)
            if saveInDataBase
            {
                let list:[[String:Any]]  = result.response?["result"] as? [[String:Any]] ?? []
                
                let cls = product_product_class(fromDictionary: [:])
                
                pos_base_class.create_temp(  cls.dbClass!)
                product_product_class.reset(temp: true  )
                product_product_class.saveAll(arr: list,temp: true)
                pos_base_class.copy_temp( cls.dbClass!)
                
                SharedManager.shared.removeNotUsesFiles(from: .images, in: .product_product,
                                                        filesName: list.map({"\($0["id"] as? Int ?? 0 ).png"}))
                self.localCash?.setTimelastupdate(item_key)
                
            }
            
            self.runQueue()
        }
        
    }
    
    func get_account_Journals()
    {
        
        let item_key = "get_account_Journals" ;
        if localCash?.isTimeTopdate(item_key) == false  {
            _ = self.handleUI(item_key: item_key, result: nil)
            self.runQueue()
            return
        }
        
        
        let pos = SharedManager.shared.posConfig()
        
        con!.get_account_Journals(journal_ids: pos.journal_ids)  { (result) in
            
            let saveInDataBase = self.handleUI(item_key: item_key, result: result)
            if saveInDataBase
            {
                let list:[[String:Any]]  = result.response?["result"] as? [[String:Any]] ?? []
                
                let cls = account_journal_class(fromDictionary: [:])
                
                pos_base_class.create_temp(  cls.dbClass!)
//                pos_base_class.rest_temp( cls.dbClass!)
                account_journal_class.reset(temp: true)
                account_journal_class.saveAll(arr: list,temp: true)
                pos_base_class.copy_temp( cls.dbClass!)

                self.localCash?.setTimelastupdate(item_key)
                
            }
            
            self.runQueue()
            
            
        }
        
    }
    
    func initTable()   {
        
        refreshControl_tableview.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl_tableview.addTarget(self, action: #selector(refreshOrder(sender:)), for: UIControl.Event.valueChanged)
        tableview.addSubview(refreshControl_tableview) // not required when using UITableViewContr
        
        
    }
    @objc func refreshOrder(sender:AnyObject) {
        if start == false
        {
            initFunc()
            startQueue()
        }
        
    }
    
}

typealias promotionApis = load_base_apis
extension promotionApis
{
    func pos_conditions()
    {
        let item_key = "pos_conditions" ;
        if localCash?.isTimeTopdate(item_key) == false  {
            _ = self.handleUI(item_key: item_key, result: nil)
            self.runQueue()
            return
        }
        
        con!.pos_conditions { (result) in
            let saveInDataBase = self.handleUI(item_key: item_key, result: result)
            if saveInDataBase
            {
                let list:[[String:Any]]  = result.response?["result"] as? [[String:Any]] ?? []
                
                let cls = pos_conditions_class(fromDictionary: [:])
                
                pos_base_class.create_temp(  cls.dbClass!)
                pos_conditions_class.reset(temp: true)
                pos_conditions_class.saveAll(arr: list,temp: true)
                pos_base_class.copy_temp( cls.dbClass!)

                self.localCash?.setTimelastupdate(item_key)
                
            }
            
            self.runQueue()
            
        }
    }
    
    func pos_promotion()
    {
        let item_key = "pos_promotion" ;
        if localCash?.isTimeTopdate(item_key) == false  {
            _ = self.handleUI(item_key: item_key, result: nil)
            self.runQueue()
            return
        }
        
        con!.pos_promotion { (result) in
            let saveInDataBase = self.handleUI(item_key: item_key, result: result)
            if saveInDataBase
            {
                let list:[[String:Any]]  = result.response?["result"] as? [[String:Any]] ?? []
                
                let cls = pos_promotion_class(fromDictionary: [:])
                
                pos_base_class.create_temp(  cls.dbClass!)
                pos_promotion_class.reset(temp: true)
                pos_promotion_class.saveAll(arr: list,temp: true)
                pos_base_class.copy_temp( cls.dbClass!)

                self.localCash?.setTimelastupdate(item_key)
                
            }
            
            self.runQueue()
            
        }
    }
    
    func day_week()
    {
        let item_key = "day_week" ;
        if localCash?.isTimeTopdate(item_key) == false  {
            _ = self.handleUI(item_key: item_key, result: nil)
            self.runQueue()
            return
        }
        
        con!.day_week { (result) in
            let saveInDataBase = self.handleUI(item_key: item_key, result: result)
            if saveInDataBase
            {
                let list:[[String:Any]]  = result.response?["result"] as? [[String:Any]] ?? []
                
                let cls = day_week_class(fromDictionary: [:])
                
                pos_base_class.create_temp(  cls.dbClass!)
                day_week_class.reset(temp: true)
                day_week_class.saveAll(arr: list,temp: true)
                pos_base_class.copy_temp( cls.dbClass!)

                self.localCash?.setTimelastupdate(item_key)
                
            }
            
            self.runQueue()
            
        }
    }
    
    func get_discount()
    {
        let item_key = "get_discount" ;
        if localCash?.isTimeTopdate(item_key) == false  {
            _ = self.handleUI(item_key: item_key, result: nil)
            self.runQueue()
            return
        }
        
        con!.get_discount { (result) in
            let saveInDataBase = self.handleUI(item_key: item_key, result: result)
            if saveInDataBase
            {
                let list:[[String:Any]]  = result.response?["result"] as? [[String:Any]] ?? []
                
                let cls = get_discount_class(fromDictionary: [:])
                
                pos_base_class.create_temp(  cls.dbClass!)
//                pos_base_class.rest_temp( cls.dbClass!)
                get_discount_class.reset(temp: true)
                get_discount_class.saveAll(arr: list,temp: true)
                pos_base_class.copy_temp( cls.dbClass!)

                self.localCash?.setTimelastupdate(item_key)
                
            }
            
            self.runQueue()
            
        }
    }
    
    func quantity_discount()
    {
        let item_key = "quantity_discount" ;
        if localCash?.isTimeTopdate(item_key) == false  {
            _ = self.handleUI(item_key: item_key, result: nil)
            self.runQueue()
            return
        }
        
        con!.quantity_discount { (result) in
            let saveInDataBase = self.handleUI(item_key: item_key, result: result)
            if saveInDataBase
            {
                let list:[[String:Any]]  = result.response?["result"] as? [[String:Any]] ?? []
                
                let cls = quantity_discount_class(fromDictionary: [:])
                
                pos_base_class.create_temp(  cls.dbClass!)
                quantity_discount_class.reset(temp: true)
                quantity_discount_class.saveAll(arr: list,temp: true)
                pos_base_class.copy_temp( cls.dbClass!)

                self.localCash?.setTimelastupdate(item_key)
                
            }
            
            self.runQueue()
            
        }
    }
    
    func quantity_discount_amt()
    {
        let item_key = "quantity_discount_amt" ;
        if localCash?.isTimeTopdate(item_key) == false  {
            _ = self.handleUI(item_key: item_key, result: nil)
            self.runQueue()
            return
        }
        
        con!.quantity_discount_amt { (result) in
            let saveInDataBase = self.handleUI(item_key: item_key, result: result)
            if saveInDataBase
            {
                let list:[[String:Any]]  = result.response?["result"] as? [[String:Any]] ?? []
                
                let cls = quantity_discount_amt_class(fromDictionary: [:])
                
                pos_base_class.create_temp(  cls.dbClass!)
                quantity_discount_amt_class.reset(temp: true)
                quantity_discount_amt_class.saveAll(arr: list,temp: true)
                pos_base_class.copy_temp( cls.dbClass!)

                self.localCash?.setTimelastupdate(item_key)
                
            }
            
            self.runQueue()
            
        }
    }
    
    func discount_multi_products()
    {
        let item_key = "discount_multi_products" ;
        if localCash?.isTimeTopdate(item_key) == false  {
            _ = self.handleUI(item_key: item_key, result: nil)
            self.runQueue()
            return
        }
        
        con!.discount_multi_products { (result) in
            let saveInDataBase = self.handleUI(item_key: item_key, result: result)
            if saveInDataBase
            {
                let list:[[String:Any]]  = result.response?["result"] as? [[String:Any]] ?? []
                
                let cls = discount_multi_products_class(fromDictionary: [:])
                
                pos_base_class.create_temp(  cls.dbClass!)
                discount_multi_products_class.reset(temp: true)
                discount_multi_products_class.saveAll(arr: list,temp: true)
                pos_base_class.copy_temp( cls.dbClass!)

                self.localCash?.setTimelastupdate(item_key)
                
            }
            
            self.runQueue()
            
        }
    }
    
    func discount_multi_categories()
    {
        let item_key = "discount_multi_categories" ;
        if localCash?.isTimeTopdate(item_key) == false  {
            _ = self.handleUI(item_key: item_key, result: nil)
            self.runQueue()
            return
        }
        
        con!.discount_multi_categories { (result) in
            let saveInDataBase = self.handleUI(item_key: item_key, result: result)
            if saveInDataBase
            {
                let list:[[String:Any]]  = result.response?["result"] as? [[String:Any]] ?? []
                
                let cls = discount_multi_categories_class(fromDictionary: [:])
                
                pos_base_class.create_temp(  cls.dbClass!)
                discount_multi_categories_class.reset(temp: true)
                discount_multi_categories_class.saveAll(arr: list,temp: true)
                pos_base_class.copy_temp( cls.dbClass!)

                self.localCash?.setTimelastupdate(item_key)
                
            }
            
            self.runQueue()
            
        }
    }
    
    func discount_above_price()
    {
        let item_key = "discount_above_price" ;
        if localCash?.isTimeTopdate(item_key) == false  {
            _ = self.handleUI(item_key: item_key, result: nil)
            self.runQueue()
            return
        }
        
        con!.discount_above_price { (result) in
            let saveInDataBase = self.handleUI(item_key: item_key, result: result)
            if saveInDataBase
            {
                let list:[[String:Any]]  = result.response?["result"] as? [[String:Any]] ?? []
                
                let cls = discount_above_price_class(fromDictionary: [:])
                
                pos_base_class.create_temp(  cls.dbClass!)
                discount_above_price_class.reset(temp: true)
                discount_above_price_class.saveAll(arr: list,temp: true)
                pos_base_class.copy_temp( cls.dbClass!)

                self.localCash?.setTimelastupdate(item_key)
                
            }
            
            self.runQueue()
            
        }
    }
    
    func get_pos_return_reason()
    {
        let item_key = "get_pos_return_reason" ;
        if localCash?.isTimeTopdate(item_key) == false  {
            _ = self.handleUI(item_key: item_key, result: nil)
            self.runQueue()
            return
        }
        
        con!.get_pos_return_reason { (result) in
            let saveInDataBase = self.handleUI(item_key: item_key, result: result)
            if saveInDataBase
            {
                let list:[[String:Any]]  = result.response?["result"] as? [[String:Any]] ?? []
                
                let cls = pos_return_reason_class(fromDictionary: [:])
                
                pos_base_class.create_temp(  cls.dbClass!)
                pos_return_reason_class.reset(temp: true)
                pos_return_reason_class.saveAll(arr: list,temp: true)
                pos_base_class.copy_temp( cls.dbClass!)

                self.localCash?.setTimelastupdate(item_key)
                
            }
            
            self.runQueue()
            
        }
    }
    
    func get_product_template_attribute_line()
    {
        let item_key = "get_product_template_attribute_line" ;
        if localCash?.isTimeTopdate(item_key) == false  {
            _ = self.handleUI(item_key: item_key, result: nil)
            self.runQueue()
            return
        }
        
        con!.get_product_template_attribute_line { (result) in
            let saveInDataBase = self.handleUI(item_key: item_key, result: result)
            if saveInDataBase
            {
                let list:[[String:Any]]  = result.response?["result"] as? [[String:Any]] ?? []
                
                let cls = product_template_attribute_line_class(fromDictionary: [:])
                
                pos_base_class.create_temp(  cls.dbClass!)
                product_template_attribute_line_class.reset(temp: true)
                product_template_attribute_line_class.saveAll(arr: list,temp: true)
                pos_base_class.copy_temp( cls.dbClass!)

                
                self.localCash?.setTimelastupdate(item_key)
                
            }
            
            self.runQueue()
            
        }
    }
    
    func get_product_template_attribute_value()
    {
        let item_key = "get_product_template_attribute_value" ;
        if localCash?.isTimeTopdate(item_key) == false  {
            _ = self.handleUI(item_key: item_key, result: nil)
            self.runQueue()
            return
        }
        
        con!.get_product_template_attribute_value { (result) in
            let saveInDataBase = self.handleUI(item_key: item_key, result: result)
            if saveInDataBase
            {
                let list:[[String:Any]]  = result.response?["result"] as? [[String:Any]] ?? []
                
                let cls = product_template_attribute_value_class(fromDictionary: [:])
                
                pos_base_class.create_temp(  cls.dbClass!)
                product_template_attribute_value_class.reset(temp: true)
                product_template_attribute_value_class.saveAll(arr: list,temp: true)
                pos_base_class.copy_temp( cls.dbClass!)

                self.localCash?.setTimelastupdate(item_key)
                
            }
            
            self.runQueue()
            
        }
    }
    
    func get_product_attribute_value()
    {
        let item_key = "get_product_attribute_value" ;
        if localCash?.isTimeTopdate(item_key) == false  {
            _ = self.handleUI(item_key: item_key, result: nil)
            self.runQueue()
            return
        }
        
        con!.get_product_attribute_value { (result) in
            let saveInDataBase = self.handleUI(item_key: item_key, result: result)
            if saveInDataBase
            {
                let list:[[String:Any]]  = result.response?["result"] as? [[String:Any]] ?? []
                
                let cls = product_attribute_value_class(fromDictionary: [:])
                
                pos_base_class.create_temp(  cls.dbClass!)
                product_attribute_value_class.reset(temp: true)
                product_attribute_value_class.saveAll(arr: list,temp: true)
                pos_base_class.copy_temp( cls.dbClass!)

                self.localCash?.setTimelastupdate(item_key)
                
            }
            
            self.runQueue()
            
        }
    }
    
    func get_product_attribute()
    {
        let item_key = "get_product_attribute" ;
        if localCash?.isTimeTopdate(item_key) == false  {
            _ = self.handleUI(item_key: item_key, result: nil)
            self.runQueue()
            return
        }
        
        con!.get_product_attribute { (result) in
            let saveInDataBase = self.handleUI(item_key: item_key, result: result)
            if saveInDataBase
            {
                let list:[[String:Any]]  = result.response?["result"] as? [[String:Any]] ?? []
                
                let cls = product_attribute_class(fromDictionary: [:])
                
                pos_base_class.create_temp(  cls.dbClass!)
                product_attribute_class.reset(temp: true)
                product_attribute_class.saveAll(arr: list,temp: true)
                pos_base_class.copy_temp( cls.dbClass!)

                self.localCash?.setTimelastupdate(item_key)
                
            }
            
            self.runQueue()
            
        }
    }
    
    
    
    func check_rules()
    {
        let item_key = "check_rules" ;
        if localCash?.isTimeTopdate(item_key) == false  {
            _ = self.handleUI(item_key: item_key, result: nil)
            self.runQueue()
            return
        }
        
        con!.create_rules { (result) in
            let saveInDataBase = self.handleUI(item_key: item_key, result: result)
            if saveInDataBase
            {
 
                
                self.localCash?.setTimelastupdate(item_key)
                
            }
            
            self.runQueue()
            
        }
    }
    
    func get_ir_translation()
    {
        let item_key = "get_ir_translation" ;
        if localCash?.isTimeTopdate(item_key) == false  {
            _ = self.handleUI(item_key: item_key, result: nil)
            self.runQueue()
            return
        }
        
        con!.get_irـtranslation { (result) in
            let saveInDataBase = self.handleUI(item_key: item_key, result: result)
            if saveInDataBase
            {
                let result: [[String:Any]]   =  result.response?["result"] as? [[String:Any]] ?? []
                
//                let list:[[String:Any]]  = result["records"]  as? [[String:Any]]  ?? []
                let cls = ir_translation_class(fromDictionary: [:])
                
                pos_base_class.create_temp(  cls.dbClass!)
                ir_translation_class.reset(temp: true)
                ir_translation_class.saveAll(arr: result,temp: true)
                pos_base_class.copy_temp( cls.dbClass!)

                self.localCash?.setTimelastupdate(item_key)
                
            }
            
            self.runQueue()
            
        }
    }
    
    func get_rules()
    {
        let item_key = "get_rules" ;
        if localCash?.isTimeTopdate(item_key) == false  {
            _ = self.handleUI(item_key: item_key, result: nil)
            self.runQueue()
            return
        }
        
        con!.get_rules { (result) in
            let saveInDataBase = self.handleUI(item_key: item_key, result: result)
            if saveInDataBase
            {
                let result: [[String:Any]]   =  result.response?["result"] as? [[String:Any]] ?? []
                
                let cls = ios_rule(fromDictionary: [:])
                
                pos_base_class.create_temp(  cls.dbClass!)
                ios_rule.reset(temp: true)
                ios_rule.saveAll(arr: result,temp: true)
                pos_base_class.copy_temp( cls.dbClass!)

                self.localCash?.setTimelastupdate(item_key)
                
            }
            
            self.runQueue()
            
        }
    }
    
    func get_groups()
    {
        let item_key = "get_groups"
        if localCash?.isTimeTopdate(item_key) == false  {
            _ = self.handleUI(item_key: item_key, result: nil)
            self.runQueue()
            return
        }
        
        con!.get_groups { (result) in
            let saveInDataBase = self.handleUI(item_key: item_key, result: result)
            if saveInDataBase
            {
                let result: [[String:Any]]   =  result.response?["result"] as? [[String:Any]] ?? []
                
                let cls = ios_group(fromDictionary: [:])
                
                pos_base_class.create_temp(  cls.dbClass!)
                ios_group.reset(temp: true)
                ios_group.saveAll(arr: result,temp: true)
                pos_base_class.copy_temp( cls.dbClass!)
                
                self.localCash?.setTimelastupdate(item_key)
                SharedManager.shared.setGloobalObject()

            }
            
            self.runQueue()
            
        }
    }
    
    
    
}

extension load_base_apis: UITableViewDelegate ,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list_keys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! load_base_apisCell
        
        if list_keys == nil
        {
            return cell
        }
        
        let arr = list_keys[indexPath.row]
        
        var name = list_items[arr]![0] as? String ?? ""
        let val = list_items[arr]![1] as! Bool
        let error = list_items[arr]![2] as? String ?? ""
        
        
        
        if !error.isEmpty
        {
            name = String(format: "%@\n%@", name , error)
            cell.img_status.image = UIImage(name: "icon_error")
        }
        else
        {
            cell.img_status.isHighlighted = val
            
        }
        
        cell.lblTtile.text = name
        
        
        
        return cell
    }
}
protocol load_base_apis_delegate {
    func isApisLoaded(status:Bool)
}


