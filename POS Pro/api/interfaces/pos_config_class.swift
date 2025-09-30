//
//  posConfigClass.swift
//  pos
//
//  Created by khaled on 8/22/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

class pos_config_class: NSObject {
    var dbClass:database_class?
    
    var id : Int = 0
    var multi_session_id : Int? = 0
    
    
    // default config
    // =================================
    var delivery_method_id : Int?
    var delivery_method_name : String?
    
    var stock_location_id : Int?
    var stock_location_name : String?
    
    var company_id : Int?
    var company_name : String?
    
    
    var pricelist_id : Int?
    var pricelist_name : String?
    
    var discount_program_product_id : Int?
    var discount_program_product_name : String?
    
    var currency_id : Int?
    var currency_name : String?
    
    var iface_start_categ_id : Int?
    var iface_start_categ_name : String?
    
    var slider_images : [Int] = []

    // =================================
    
    var name : String?
    var receipt_header : String?
    var receipt_footer : String?
    var product_restriction_type : String?
    var __last_update : String?
    var code : String = ""
    var pin_code : String = ""

    
    // =================================
    
    
    var allow_pin_code:Bool = true
    var pos_scrap:Bool = false
    var enable_delivery:Bool = false
    var allow_free_tax:Bool = false
    var allow_discount_program:Bool = false
    var pos_promotion:Bool = false
    var is_table_management:Bool = false
    var cash_control:Bool = false
    var active:Bool = false
    var multi_session_accept_incoming_orders:Bool = false

    
    
    // =================================
    var journal_ids : [Int] = []
    var delivery_method_ids : [Int] = []
    var available_pricelist_ids : [Int] = []
    var available_discount_program_ids : [Int] = []
    var printer_ids : [Int] = []
    var floor_ids : [Int] = []
    var product_tmpl_ids : [Int] = []
    // =================================
    // loyalty
    var enable_pos_loyalty:Bool = false
    var loyalty_journal_id : Int?
    var loyalty_journal_id_name : String?
 
    // =================================
    // extra fees
    var extra_fees:Bool = false
    var extra_product_id : Int?
    var extra_product_id_name : String?
    var extra_percentage : Int?

    // =================================
    // Restrict Category
    var exclude_pos_categ_ids : [Int] = []
    // =================================
    // Restrict Products
    var exclude_product_ids : [Int] = []
    var available_floors_ids: [Int] = []
    var pos_type : String?
    
    var fb_token: String?
    var logo: String = ""

    var brand_id : Int?
    var brand_name : String?
    var vat : String?
    var brand:res_brand_class?
    var company:res_company_class!
    var cloud_kitchen: [Int] = []
    var insurance_product_delivery_note : String?
    var company_default_tax_id : Int?
    var minimum_fees : Double?
    var minimum_item_price : Double?
    //MARK: -X509 Certification ["l10n_sa_production_csid_json"]
    var requestID:Int?
    var tokenType:String?
    var dispositionMessage:String?
    var binarySecurityToken:String?
    var secret:String?
    //MARK: - Bonat
    var loyalty_type:String?
    var bonat_api_key:String?
    var bonat_api_url:String?
    var api_url_type:String?
    var branch_id:Int?
    var force_update_journal_id:Int?
    var force_update_journal_name:String?


//    var last_chain_index:Int?


    func accountJournals_cash_default() -> account_journal_class?
    {
        
        return account_journal_class.get_cash_default()
    }
    
    func accountJournals_STC() -> account_journal_class?
    {
        
        return account_journal_class.get_stc_default()
    }
    
    
    func setCompany()
    {
        let current_company = res_company_class.get_company(id:self.company_id!)
        if let brand_object = self.brand{
            company = res_company_class(from: brand_object,company: current_company)
            return
        }
        company = current_company
    }
    
  
    
    
    init(fromDictionary dictionary: [String:Any]){
        super.init()
        
        id = dictionary["id"] as? Int ?? 0
        
        multi_session_id = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "multi_session_id", keyOfDatabase: "multi_session_id",Index: 0) as? Int ?? 0
        
        // =================================
        //        delivery_method_id = (dictionary["delivery_method_id"]as? [Any] ?? []).getIndex(0) as? Int ?? 0
        delivery_method_id = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "delivery_method_id", keyOfDatabase: "delivery_method_id",Index: 0) as? Int ?? 0
        delivery_method_name = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "delivery_method_id", keyOfDatabase: "delivery_method_name",Index: 1)as? String  ?? ""
        
        //        stock_location_id = (dictionary["stock_location_id"]as? [Any] ?? []).getIndex(0) as? Int ?? 0
        stock_location_id = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "stock_location_id", keyOfDatabase: "stock_location_id",Index: 0) as? Int ?? 0
        stock_location_name = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "stock_location_id", keyOfDatabase: "stock_location_name",Index: 1)as? String  ?? ""
        
        //        company_id = (dictionary["company_id"]as? [Any] ?? []).getIndex(0) as? Int ?? 0
        company_id = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "company_id", keyOfDatabase: "company_id",Index: 0) as? Int ?? 0
        company_name = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "company_id", keyOfDatabase: "company_name",Index: 1)as? String  ?? ""
        
        //        pricelist_id = (dictionary["pricelist_id"]as? [Any] ?? []).getIndex(0) as? Int ?? 0
        pricelist_id = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "pricelist_id", keyOfDatabase: "pricelist_id",Index: 0) as? Int ?? 0
        pricelist_name = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "pricelist_id", keyOfDatabase: "pricelist_name",Index: 1)as? String  ?? ""
        
        //        discount_program_product_id = (dictionary["discount_program_product_id"]as? [Any] ?? []).getIndex(0) as? Int ?? 0
        discount_program_product_id = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "discount_program_product_id", keyOfDatabase: "discount_program_product_id",Index: 0) as? Int ?? 0
        discount_program_product_name = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "discount_program_product_id", keyOfDatabase: "discount_program_product_name",Index: 1)as? String  ?? ""
        
        //        currency_id = (dictionary["currency_id"]as? [Any] ?? []).getIndex(0) as? Int ?? 0
        currency_id = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "currency_id", keyOfDatabase: "currency_id",Index: 0) as? Int ?? 0
        currency_name = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "currency_id", keyOfDatabase: "currency_name",Index: 1)as? String  ?? ""
        
        iface_start_categ_id = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "iface_start_categ_id", keyOfDatabase: "iface_start_categ_id",Index: 0) as? Int ?? 0
        iface_start_categ_name = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "iface_start_categ_id", keyOfDatabase: "iface_start_categ_name",Index: 1)as? String  ?? ""
        // =================================

        // extra fees
        extra_fees = dictionary["extra_fees"] as? Bool ?? false
        extra_product_id = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "extra_product_id", keyOfDatabase: "extra_product_id",Index: 0) as? Int ?? 0
        extra_product_id_name = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "extra_product_id", keyOfDatabase: "extra_product_id_name",Index: 1)as? String  ?? ""
        extra_percentage = dictionary["extra_percentage"] as? Int ?? 0

        // =================================
        

        // =================================
        code = dictionary["code"] as? String ?? ""
        __last_update = dictionary["__last_update"] as? String ?? ""
        name = dictionary["name"] as? String ?? ""
        receipt_header = dictionary["receipt_header"] as? String ?? ""
        receipt_footer = dictionary["receipt_footer"] as? String ?? ""
        product_restriction_type = dictionary["product_restriction_type"] as? String ?? ""
        pin_code = dictionary["pin_code"] as? String ?? ""
        
        // =================================
        pos_scrap = dictionary["pos_scrap"] as? Bool ?? false
        enable_delivery = dictionary["enable_delivery"] as? Bool ?? false
        allow_free_tax = dictionary["allow_free_tax"] as? Bool ?? false
        allow_discount_program = dictionary["allow_discount_program"] as? Bool ?? false
        pos_promotion = dictionary["pos_promotion"] as? Bool ?? false
        is_table_management = dictionary["is_table_management"] as? Bool ?? false
        cash_control = dictionary["cash_control"] as? Bool ?? false
        active = dictionary["active"] as? Bool ?? false
        allow_pin_code = true //dictionary["allow_pin_code"] as? Bool ?? false
        multi_session_accept_incoming_orders = dictionary["multi_session_accept_incoming_orders"] as? Bool ?? false

        
        // =================================
        
        journal_ids = dictionary["journal_ids"] as? [Int] ?? []
        available_pricelist_ids = dictionary["available_pricelist_ids"] as? [Int] ?? []
        delivery_method_ids = dictionary["delivery_method_ids"] as? [Int] ?? []
        available_discount_program_ids = dictionary["available_discount_program_ids"] as? [Int] ?? []
        printer_ids = dictionary["printer_ids"] as? [Int] ?? []
        floor_ids = dictionary["floor_ids"] as? [Int] ?? []
        product_tmpl_ids = dictionary["product_tmpl_ids"] as? [Int] ?? []
        slider_images = dictionary["slider_images"] as? [Int] ?? []
        // =================================
        // loyalty
        enable_pos_loyalty = dictionary["enable_pos_loyalty"] as? Bool ?? false
        loyalty_journal_id = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "loyalty_journal_id", keyOfDatabase: "loyalty_journal_id",Index: 0) as? Int ?? 0
        loyalty_journal_id_name = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "loyalty_journal_id", keyOfDatabase: "loyalty_journal_id_name",Index: 1)as? String  ?? ""
        // =================================
        // extra fees
        extra_fees = dictionary["extra_fees"] as? Bool ?? false
        extra_product_id = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "extra_product_id", keyOfDatabase: "extra_product_id",Index: 0) as? Int ?? 0
        extra_product_id_name = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "extra_product_id", keyOfDatabase: "extra_product_id_name",Index: 1)as? String  ?? ""
        extra_percentage = dictionary["extra_percentage"] as? Int ?? 0
        exclude_pos_categ_ids = dictionary["exclude_pos_categ_ids"] as? [Int] ?? []
        exclude_product_ids = dictionary["exclude_product_ids"] as? [Int] ?? []

        available_floors_ids = dictionary["available_floors_ids"] as? [Int] ?? []
        pos_type = dictionary["pos_type"] as? String ?? ""
        fb_token = dictionary["fb_token"] as? String ?? ""
        vat = dictionary["vat"] as? String ?? ""
        insurance_product_delivery_note = dictionary["insurance_product_delivery_note"] as? String ?? ""
        if let csidDic =  (dictionary["l10n_sa_production_csid_json"] as? String ?? "").toDictionary() {
            requestID = csidDic["requestID"] as? Int
            tokenType = csidDic["tokenType"] as? String ?? ""
            dispositionMessage = csidDic["dispositionMessage"] as? String ?? ""
            binarySecurityToken = csidDic["binarySecurityToken"] as? String ?? ""
            secret = csidDic["secret"] as? String ?? ""

        }else{
            requestID = dictionary["requestID"] as? Int
            tokenType = dictionary["tokenType"] as? String
            dispositionMessage = dictionary["dispositionMessage"] as? String
            binarySecurityToken = dictionary["binarySecurityToken"] as? String
            secret = dictionary["secret"] as? String
        }
//        last_chain_index = dictionary["last_chain_index"] as? Int
        brand_id =  baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "brand_id", keyOfDatabase: "brand_id",Index: 0) as? Int
        brand_name =  baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "brand_id", keyOfDatabase: "brand_id",Index: 1) as? String

        if let base64String = dictionary["logo"] as? String, !base64String.isEmpty {
            let name_Image = "\(id)" + ".png"
            if base64String != name_Image{
                self.logo = name_Image
                FileMangerHelper.shared.saveBase64AsImage(base64String, in :.pos_config,with:name_Image)
            }else{
                logo = name_Image
            }
        }else{
            logo = ""
        }
        // =================================
        if let brandID = self.brand_id{
            brand = res_brand_class.get_brand(id:brandID)
        }
        setCompany()
        cloud_kitchen = dictionary["cloud_kitchen"] as? [Int] ?? []
        minimum_fees = dictionary["minimum_fees"] as? Double
        minimum_item_price = dictionary["minimum_item_price"] as? Double
        loyalty_type = dictionary["loyalty_type"] as? String ?? ""
        bonat_api_key = dictionary["bonat_api_key"] as? String ?? ""
        bonat_api_url = dictionary["bonat_api_url"] as? String ?? ""
        api_url_type = dictionary["api_url_type"] as? String ?? ""
        branch_id = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "branch_id", keyOfDatabase: "branch_id",Index: 0) as? Int ?? 0
        force_update_journal_id = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "force_update_journal_id", keyOfDatabase: "force_update_journal_id",Index: 0) as? Int ?? 0
        force_update_journal_name = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "force_update_journal_id", keyOfDatabase: "force_update_journal_name",Index: 1)as? String  ?? ""

        
        dbClass = database_class(table_name: "pos_config", dictionary: self.toDictionary(),id: id,id_key:"id")
        
        
        
    }
    
    func toDictionary() -> [String:Any]
    {
        var dictionary:[String:Any] = [:]
        
        dictionary["branch_id"] = branch_id
        dictionary["id"] = id
        dictionary["multi_session_id"] = multi_session_id
        // =================================
        dictionary["delivery_method_id"] = delivery_method_id
        dictionary["delivery_method_name"] = delivery_method_name
        
        dictionary["stock_location_id"] = stock_location_id
        dictionary["stock_location_name"]  = stock_location_name
        
        dictionary["company_id"] = company_id
        dictionary["company_name"] = company_name
        
        dictionary["pricelist_id"] = pricelist_id
        dictionary["pricelist_name"] = pricelist_name
        
        dictionary["discount_program_product_id"] = discount_program_product_id
        dictionary["discount_program_product_name"] = discount_program_product_name
        
        dictionary["currency_id"] = currency_id
        dictionary["currency_name"] = currency_name
        
        dictionary["iface_start_categ_id"] = iface_start_categ_id
        dictionary["iface_start_categ_name"] = iface_start_categ_name
        // =================================
        
        dictionary["__last_update"] = __last_update
        dictionary["code"] = code
        
        dictionary["name"] = name
        dictionary["receipt_header"] = receipt_header
        dictionary["receipt_footer"] = receipt_footer
        dictionary["product_restriction_type"] = product_restriction_type
        dictionary["pin_code"] = pin_code

        // =================================
        dictionary["pos_scrap"] = pos_scrap
        dictionary["enable_delivery"] = enable_delivery
        dictionary["allow_free_tax"] = allow_free_tax
        dictionary["allow_discount_program"] = allow_discount_program
        dictionary["pos_promotion"] = pos_promotion
        dictionary["is_table_management"] = is_table_management
        dictionary["cash_control"] = cash_control
        dictionary["active"] = active
        dictionary["allow_pin_code"] = allow_pin_code
        // =================================
        
        dictionary["journal_ids"] = journal_ids
        dictionary["available_pricelist_ids"] = available_pricelist_ids
        dictionary["delivery_method_ids"] = delivery_method_ids
        dictionary["available_discount_program_ids"] = available_discount_program_ids
        dictionary["printer_ids"] = printer_ids
        dictionary["floor_ids"] = floor_ids
        dictionary["product_tmpl_ids"] = product_tmpl_ids
        dictionary["slider_images"] = slider_images
        // =================================
        dictionary["multi_session_accept_incoming_orders"] = multi_session_accept_incoming_orders
        // =================================
        dictionary["extra_fees"] = extra_fees
        dictionary["extra_product_id"] = extra_product_id
        dictionary["extra_product_id_name"] = extra_product_id_name
        dictionary["extra_percentage"] = extra_percentage

        // =================================
 
        dictionary["exclude_pos_categ_ids"] = exclude_pos_categ_ids
        dictionary["exclude_product_ids"] = exclude_product_ids
        dictionary["available_floors_ids"] = available_floors_ids
        dictionary["pos_type"] = pos_type
        dictionary["fb_token"] = fb_token
        dictionary["logo"] = logo
        
        dictionary["brand_id"] = brand_id
        dictionary["brand_name"] = brand_name
        dictionary["vat"] = vat
        dictionary["cloud_kitchen"] = cloud_kitchen
        dictionary["insurance_product_delivery_note"] = insurance_product_delivery_note
        dictionary["enable_pos_loyalty"] = enable_pos_loyalty

        dictionary["minimum_fees"] = minimum_fees
        dictionary["minimum_item_price"] = minimum_item_price
        //MARK: - X509 Certification l10n_sa_production_csid_json
        dictionary["requestID"] = requestID
        dictionary["tokenType"] = tokenType
        dictionary["dispositionMessage"] = dispositionMessage
        dictionary["binarySecurityToken"] = binarySecurityToken
        dictionary["secret"] = secret
        dictionary["loyalty_type"] = loyalty_type
        dictionary["bonat_api_key"] = bonat_api_key
        dictionary["bonat_api_url"] = bonat_api_url
        dictionary["api_url_type"] = api_url_type
//        dictionary["last_chain_index"] = last_chain_index
        dictionary["force_update_journal_id"] = force_update_journal_id
        dictionary["force_update_journal_name"] = force_update_journal_name
        

        
        return baseClass.fillterProperties(dictionary: dictionary, excludeProperties: ["journal_ids","available_pricelist_ids","delivery_method_ids","available_discount_program_ids","printer_ids","floor_ids","product_tmpl_ids","active","exclude_pos_categ_ids","exclude_product_ids","available_floors_ids","slider_images","cloud_kitchen"])
        
    }
    func updateFromBrand(){
        if self.cloud_kitchen.count <= 0 {
        if let brand_object = self.brand{
            if let brand_header = brand_object.header , !brand_header.isEmpty{
                self.receipt_header = brand_header + "<br />" + (self.receipt_header ?? "")
            }
            if let brand_footer = brand_object.footer , !brand_footer.isEmpty{
                self.receipt_footer = brand_footer + "<br />" + (self.receipt_footer ?? "")
            }
            if self.logo.isEmpty {
                       self.logo = brand_object.logo ?? ""
                   }
                   
               }
        }
    }
    
    func reset()
    {
       
    }
    
    func setActive()
    {
        _ =  database_class().runSqlStatament(sql: "update pos_config set active = 1")
        
        dbClass?.dictionary = self.toDictionary()
        dbClass?.dictionary["active"] = true
        dbClass?.id = self.id
        dbClass?.insertId = true

        _ =  dbClass!.save()
        
    }
    
    func save(temp:Bool = false)
    {
        dbClass?.dictionary = self.toDictionary()
        dbClass?.id = self.id
        
        if temp
        {
            dbClass!.table_name =  "temp_" + dbClass!.table_name
        }
        
        
        _ =  dbClass!.save()
        
        
        
        relations_database_class(re_id1: self.id, re_id2: journal_ids, re_table1_table2: "pos_config|account_journal").save()
        relations_database_class(re_id1: self.id, re_id2: available_pricelist_ids, re_table1_table2: "pos_config|product_pricelist").save()
        relations_database_class(re_id1: self.id, re_id2: delivery_method_ids, re_table1_table2: "pos_config|delivery_type").save()
        relations_database_class(re_id1: self.id, re_id2: available_discount_program_ids, re_table1_table2: "pos_config|available_discount_program_ids").save()
        relations_database_class(re_id1: self.id, re_id2: printer_ids, re_table1_table2: "pos_config|restaurant_printer").save()
        relations_database_class(re_id1: self.id, re_id2: floor_ids, re_table1_table2: "pos_config|restaurant_floor").save()
        relations_database_class(re_id1: self.id, re_id2: product_tmpl_ids, re_table1_table2: "pos_config|product_template").save()
        relations_database_class(re_id1: self.id, re_id2: exclude_pos_categ_ids, re_table1_table2: "pos_config|exclude_pos_categ_ids").save()
        relations_database_class(re_id1: self.id, re_id2: exclude_product_ids, re_table1_table2: "pos_config|exclude_product_ids").save()
        relations_database_class(re_id1: self.id, re_id2: available_floors_ids, re_table1_table2: "pos_config|available_floors_ids").save()
        relations_database_class(re_id1: self.id, re_id2: slider_images, re_table1_table2: "pos_config|slider_images").save()

        relations_database_class(re_id1: self.id, re_id2: cloud_kitchen, re_table1_table2: "pos_config|res_brand").save()


        
        
    }
    
    static func reset()
    {
        let cls = restaurant_table_class(fromDictionary: [:])
      _ =  cls.dbClass?.runSqlStatament(sql: "delete from pos_config")
        
        _ =  database_class().runSqlStatament(sql: "delete from relations where re_table1_table2='pos_config|account_journal' ")
        _ =  database_class().runSqlStatament(sql: "delete from relations where re_table1_table2='pos_config|product_pricelist' ")
        _ =  database_class().runSqlStatament(sql: "delete from relations where re_table1_table2='pos_config|delivery_type' ")
        _ =  database_class().runSqlStatament(sql: "delete from relations where re_table1_table2='pos_config|available_discount_program_ids' ")
        _ =  database_class().runSqlStatament(sql: "delete from relations where re_table1_table2='pos_config|restaurant_printer' ")
        _ =  database_class().runSqlStatament(sql: "delete from relations where re_table1_table2='pos_config|restaurant_floor' ")
        _ =  database_class().runSqlStatament(sql: "delete from relations where re_table1_table2='pos_config|product_template' ")
        _ =  database_class().runSqlStatament(sql: "delete from relations where re_table1_table2='pos_config|exclude_pos_categ_ids' ")
        //exclude_product_ids
        _ =  database_class().runSqlStatament(sql: "delete from relations where re_table1_table2='pos_config|exclude_product_ids' ")
        _ =  database_class().runSqlStatament(sql: "delete from relations where re_table1_table2='pos_config|available_floors_ids' ")
        _ =  database_class().runSqlStatament(sql: "delete from relations where re_table1_table2='pos_config|slider_images' ")
        _ =  database_class().runSqlStatament(sql: "delete from relations where re_table1_table2='pos_config|res_brand' ")

        
    }
    
    
    static func saveAll(arr:[[String:Any]],temp:Bool = false)
    {
        for item in arr
        {
            let pos = pos_config_class(fromDictionary: item)
            pos.dbClass?.insertId = true
            pos.save(temp: temp)
        }
    }
    
    static func getDefault() -> pos_config_class {
        
        
        var cls = pos_config_class(fromDictionary: [:])
        
        let row:[String:Any]?   = cls.dbClass!.get_row(whereSql: "where active = 1")
        
        if row != nil
        {
            
            cls = pos_config_class(fromDictionary: row!)
            cls.journal_ids = cls.dbClass!.get_relations_rows(re_id1: cls.id, re_table1_table2: "pos_config|account_journal")
            cls.available_pricelist_ids = cls.dbClass!.get_relations_rows(re_id1: cls.id, re_table1_table2: "pos_config|product_pricelist")
            cls.delivery_method_ids = cls.dbClass!.get_relations_rows(re_id1: cls.id, re_table1_table2: "pos_config|delivery_type")
            cls.available_discount_program_ids = cls.dbClass!.get_relations_rows(re_id1: cls.id, re_table1_table2: "pos_config|available_discount_program_ids")
            cls.printer_ids = cls.dbClass!.get_relations_rows(re_id1: cls.id, re_table1_table2: "pos_config|restaurant_printer")
            cls.floor_ids = cls.dbClass!.get_relations_rows(re_id1: cls.id, re_table1_table2: "pos_config|restaurant_floor")
            cls.product_tmpl_ids = cls.dbClass!.get_relations_rows(re_id1: cls.id, re_table1_table2: "pos_config|product_template")
            cls.exclude_pos_categ_ids = cls.dbClass!.get_relations_rows(re_id1: cls.id, re_table1_table2: "pos_config|exclude_pos_categ_ids")
            cls.exclude_product_ids = cls.dbClass!.get_relations_rows(re_id1: cls.id, re_table1_table2: "pos_config|exclude_product_ids")
            cls.available_floors_ids = cls.dbClass!.get_relations_rows(re_id1: cls.id, re_table1_table2: "pos_config|available_floors_ids")
            cls.slider_images = cls.dbClass!.get_relations_rows(re_id1: cls.id, re_table1_table2: "pos_config|slider_images")
            cls.cloud_kitchen = cls.dbClass!.get_relations_rows(re_id1: cls.id, re_table1_table2: "pos_config|res_brand")

            cls.updateFromBrand()


            
        }
            
            
        
        //        let current_post = posConfigClass(fromDictionary: cls   )
        //        let updated_pos = getPos(posPass: current_post)
        
        return cls
        
    }
    
    static func getPos(posID:Int) -> pos_config_class
    {
        var cls = pos_config_class(fromDictionary: [:])
        
        let row:[String:Any]?  = cls.dbClass!.get_row(whereSql: "where id =" + String(posID))
        if row != nil
        {
            cls = pos_config_class(fromDictionary: row!)
        }
        
        return cls
    }
    
    
     static func getAllFromDB() ->  [[String:Any]] {
           
           let cls = pos_config_class(fromDictionary: [:])
           let arr  = cls.dbClass!.get_rows(whereSql: "")
           return arr
           
       }
    static func hitGetAllPOSAPI(completeHandler:@escaping ((_ posList:[pos_config_class]?,_ message:String) -> Void)) {
         let branchID = SharedManager.shared.posConfig().brand_id
            SharedManager.shared.conAPI().get_point_of_sale(at:branchID ) { result in 
                if let list:[[String:Any]]  = result.response?["result"] as? [[String:Any]] {
                    completeHandler(list.map({pos_config_class(fromDictionary: $0)}),"")
                }else{
                    completeHandler(nil,result.message ?? "Error happen")
                }
            }
      }
    
    static func get(ids:[Int]) ->  [[String:Any]] {
        if ids.count == 0
        {
            return []
        }
        
        var str_ids = ""
        for i in ids
        {
            str_ids = str_ids + "," + String(i)
        }
        
        str_ids.removeFirst()
        
        let cls = pos_config_class(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(whereSql: "where id in (\(str_ids)) ")
        return arr
        
    }
    
    static func getAllFromDB() -> [pos_config_class] {
        
         
        let arr:[[String:Any]] = pos_config_class.getAllFromDB()
        var list_products :[pos_config_class] = []
        
        for item in arr
        {
            let cls:pos_config_class = pos_config_class(fromDictionary: item  )
            
                 list_products.append(cls)
          
            
        }
        
        
        return  list_products
    }
    
    
    //    static func getPos(posPass:posConfigClass) -> posConfigClass?
    //    {
    //
    //        let pos = api.get_last_cash_result(keyCash:"get_point_of_sale")
    //
    //        for item in pos
    //        {
    //            let cls = posConfigClass(fromDictionary: item as! [String : Any])
    //            if cls.id == posPass.id
    //            {
    //                let company_id = cls.company_id ?? 0
    //                cls.company = getCompany(co_id: company_id)
    //                cls.accountJournals_cash_default = posPass.accountJournals_cash_default
    //                cls.accountJournals_STC = posPass.accountJournals_STC
    //
    //                return cls
    //
    //            }
    //        }
    //
    //        return posPass
    //    }
    //
    //    static func getCompany(co_id:Int) ->companiesClass
    //    {
    //        let companies = api.get_last_cash_result(keyCash:"get_companies")
    //
    //        for item in companies
    //        {
    //
    //            let comp = companiesClass(fromDictionary: item as! [String : Any])
    //            if co_id == comp.id
    //            {
    //                let currencies_list = api.get_last_cash_result(keyCash: "get_currencies")
    //                for  currency_dic in  currencies_list
    //                {
    //                    let currency = currenciesClass(fromDictionary: currency_dic as! [String : Any])
    //                    if comp.currency_id.count > 0
    //                    {
    //                        let currency_id = comp.currency_id[0] as? Int ?? 0
    //                        if currency_id == currency.id
    //                        {
    //                            comp.currency = currency
    //                        }
    //                    }
    //
    //
    //                }
    //
    //
    //                return comp
    //            }
    //
    //        }
    //
    //        return companiesClass()
    //    }
    
//    static func get_categories_excluded_query()->String{
//        var sql_limit_cateries = ""
//        let posConfig =  SharedManager.shared.posConfig()
//        if posConfig.exclude_pos_categ_ids.count > 0 {
//            let restrict_categories = posConfig.exclude_pos_categ_ids
//            let restrict_categories_string = "\(restrict_categories)".replacingOccurrences(of: "[", with: "(").replacingOccurrences(of: "]", with: ")")
//            sql_limit_cateries = "and pos_category.id not in \(restrict_categories_string)"
//        }
//        return sql_limit_cateries
//    }
//    static func get_products_restrict_query()->String{
//        var sql_limit_products = ""
//        var exclude_category_query = ""
//        let posConfig =  SharedManager.shared.posConfig()
//        let exclude_pos_categ_ids = posConfig.exclude_pos_categ_ids
//        let restrict_products = posConfig.exclude_product_ids
//
//        if exclude_pos_categ_ids.count > 0 {
//            let exclude_pos_categ_ids_string = "\(exclude_pos_categ_ids)".replacingOccurrences(of: "[", with: "(").replacingOccurrences(of: "]", with: ")")
//            exclude_category_query = " and product_product.pos_categ_id not in \(exclude_pos_categ_ids_string)"
//        }
//        if restrict_products.count > 0 {
//            let restrict_products_string = "\(restrict_products)".replacingOccurrences(of: "[", with: "(").replacingOccurrences(of: "]", with: ")")
//            let query_condation = "not in"
//            sql_limit_products = "and product_product.id \(query_condation) \(restrict_products_string)"
//        }
//        return exclude_category_query + " " + sql_limit_products
//    }
    func getVatNumber() -> String{
        if (self.vat ?? "").isEmpty{
           return company.vat 
        }else{
           return self.vat ?? ""
        }
    }
    func isMasterTCP()->Bool {
        let typePos = self.pos_type ?? ""
//        SharedManager.shared.printLog("typePos == \(typePos)")
        let isWaiter = typePos.lowercased().contains("waiter")
        let isAddtional = typePos.lowercased().contains("add_cashier")

        return  !isWaiter && !isAddtional
    }
    func isWaiterTCP()->Bool {
        let typePos = self.pos_type ?? ""
        return typePos.lowercased().contains("waiter")
    }
    func isAddtionalCashierTCP()->Bool {
        let typePos = self.pos_type ?? ""
//        SharedManager.shared.printLog("typePos == \(typePos)")
        return  typePos.lowercased().contains("add_cashier")
    }
    func getDeviceType() -> String {
        let typePos = self.pos_type ?? ""

        if typePos.lowercased().contains("waiter"){
            return DEVICES_TYPES_ENUM.WAITER.getLocalizeName()
        }
        if typePos.lowercased().contains("add_cashier"){
            return DEVICES_TYPES_ENUM.SUB_CASHER.getLocalizeName()
        }
        return DEVICES_TYPES_ENUM.MASTER.getLocalizeName()
    }

    func isSupportEvoice() -> Bool{
        return !((self.binarySecurityToken ?? "").isEmpty )
    }
}
