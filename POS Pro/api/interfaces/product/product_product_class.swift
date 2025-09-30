//
//  product.swift
//  pos
//
//  Created by khaled on 8/15/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

class product_product_class: NSObject {
    var dbClass:database_class?
    
    // =============================
    // dataBase fileds
    // =============================
    var id : Int = 0
    
    var sequence : Int = 0
    
    var list_price : Double = 0
    var lst_price : Double = 0
    
    var price: Double {
        return lst_price
    }
    
    
    var standard_price : Double = 0
    var calories : Double  = 0
    
    var display_name : String = ""
    var name : String = ""
    var barcode :  String = ""
    var default_code : String = ""
    var description_sale : String = ""
    var description_ : String = ""
    var tracking : String = ""
    var original_name : String = ""
    var name_ar : String = ""
    var __last_update : String = ""
    var attribute_names : String = ""
    var image : String = ""
    var image_small: String = ""
    var type: String = ""

    var is_combo : Bool = false
    var active : Bool = false
    var invisible_in_ui : Bool = false
    var deleted : Bool = false

    
    // =============================
    var categ_id : Int?
    var categ_name : String?
    
    var pos_categ_id :Int?
    var pos_categ_name :String?
    
    var uom_id : Int?
    var uom_name : String?
    
    var currency_id : Int?
    var currency_name : String?
    
    var product_tmpl_id:Int?
    var product_tmpl_name:String?
    var taxes_id_array_string:String?

        var variants_count:Int = 0
    var company_id:Int?
    var calculated_quantity:Double = 1

    
    
   var attribute_value_ids :[Int] = []
    // =============================
   private var taxes_id : [Int] = []
   private var product_combo_ids : [Int] = []
   private var product_variant_ids :[Int] = []
    
    // =============================
    // not added
    // =============================
    

//    var is_void:Bool = false
//
//    var tag_temp:String?
//
//    var index : Int = 0
//    var section : Int = 0
    
//    var productTmplId : [Any] = []
    
//    var scrap_reason : String  = ""
//    var notes_txt : String  = ""
//
//    var total_app : Double  = 0
//    var qty_app : Double = 0
//
//    var max_qty_app : Double?
//
//    var discount : Double  = 0
//
//    var custome_price_app : Bool = false
//    var sorted_ID : String = ""
//    var price_app_priceList : Double! = 0
//
//
//    var combo_edit : Bool = false
//    var default_product_combo   : Bool = false
//
//
//    var can_return : Bool = true
//
//    var price_total_app : Double  = 0
//    var tax_total_included_app : Double  = 0
//    var tax_total_excluded_app : Double  = 0
//    var tax_amount_app : Double  = 0
    

    
//    var products_InCombo:[String:[product_product_class]] = [:]
//    var products_InCombo_avalibale_total_items:Double = 0
    
//    var dictionary_values: [String:Any] = [:]
    
    
//    var priceList :product_pricelist_class?
    

    
//    var product_variant_lst:[Any] = []
    
    
    var default_product_combo   : Bool = false

    var combo:product_combo_class?
    var list_product_in_combo:[pos_order_line_class] = []
    var app_require : Bool = false
    var app_selected : Bool = false
    var comob_extra_price : Double  = 0
    var auto_select_num : Int = 0
    
    var title:String {
        get{
            
          
            var txt =  self.name
//            if self.original_name.isEmpty
//            {
//                txt = self.name
//            }
//            else
//            {
//                txt = self.original_name
//            }
            
            if LanguageManager.currentLang() == .ar
            {
                if !self.name_ar.isEmpty
                {
                    txt = self.name_ar
                }
            }
            
            
            return txt
        }
    }
    
    var cover_image:String
    {
        get{
            if self.image.isEmpty
            {
                return self.image_small
            }
            else
            {
                return self.image
            }
            
            
        }
    }
    var insurance_product: Bool = false

    
    // =====================================
       // for ui
       var section_name : String = ""
    
    var brand_id : Int?
    var brand_name : String?
    var select_weight:Bool?
    var allow_extra_fees: Bool = false
    var count_stock_available:Double?


    
    override init() {
        
    }
    
    init (fromDictionary dictionary: [String:Any]){
        super.init()
        
        id = dictionary["id"] as? Int ?? 0
        sequence = dictionary["sequence"] as? Int ?? 0
        variants_count = dictionary["variants_count"] as? Int ?? 0

        
        // =================================
        //        categ_id = (dictionary["categ_id"]as? [Any] ?? []).getIndex(0) as? Int ?? 0
        categ_id = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "categ_id", keyOfDatabase: "categ_id",Index: 0) as? Int ?? 0
        categ_name = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "categ_id", keyOfDatabase: "categ_name",Index: 1)as? String  ?? ""
        
        //        pos_categ_id = (dictionary["pos_categ_id"]as? [Any] ?? []).getIndex(0) as? Int ?? 0
        pos_categ_id = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "pos_categ_id", keyOfDatabase: "pos_categ_id",Index: 0) as? Int ?? 0
        pos_categ_name = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "pos_categ_id", keyOfDatabase: "pos_categ_name",Index: 1)as? String  ?? ""
        
        //        uom_id = (dictionary["uom_id"]as? [Any] ?? []).getIndex(0) as? Int ?? 0
        uom_id = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "uom_id", keyOfDatabase: "uom_id",Index: 0) as? Int ?? 0
        uom_name = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "uom_id", keyOfDatabase: "uom_name",Index: 1)as? String  ?? ""
        
        //        currency_id = (dictionary["currency_id"]as? [Any] ?? []).getIndex(0) as? Int ?? 0
        currency_id = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "currency_id", keyOfDatabase: "currency_id",Index: 0) as? Int ?? 0
        currency_name = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "currency_id", keyOfDatabase: "currency_name",Index: 1)as? String  ?? ""
        
        //        product_tmpl_id = (dictionary["product_tmpl_id"]as? [Any] ?? []).getIndex(0) as? Int ?? 0
        product_tmpl_id = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "product_tmpl_id", keyOfDatabase: "product_tmpl_id",Index: 0) as? Int ?? 0
        product_tmpl_name = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "product_tmpl_id", keyOfDatabase: "product_tmpl_name",Index: 1)as? String  ?? ""
        
        company_id = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "company_id", keyOfDatabase: "company_id",Index: 0) as? Int ?? 0

        
        // =================================
        list_price = dictionary["list_price"] as? Double ?? 0
        lst_price = dictionary["lst_price"] as? Double ?? 0
        standard_price = dictionary["standard_price"] as? Double ?? 0
        calories = dictionary["calories"] as? Double ?? 0
        
        // =================================
        display_name = dictionary["display_name"] as? String ?? ""
        /*
         odoo 12
         name = en
         name_ar = ar
         odoo 14
         orther language = en
         name = ar
         name_ar = ar or empty
         **/
        setNameFrom(dictionary)

        barcode = dictionary["barcode"] as? String ?? ""
        default_code = dictionary["default_code"] as? String ?? ""
        description_sale = dictionary["description_sale"] as? String ?? ""
        description_ = dictionary["description"] as? String ?? ""
        tracking = dictionary["tracking"] as? String ?? ""
        original_name = dictionary["original_name"] as? String ?? ""
        __last_update = dictionary["__last_update"] as? String ?? ""
        attribute_names = dictionary["attribute_names"] as? String ?? ""
       
        type = dictionary["type"] as? String ?? ""
        // =================================
        
        is_combo = dictionary["is_combo"] as? Bool ?? false
        active = dictionary["active"] as? Bool ?? false
        invisible_in_ui = dictionary["invisible_in_ui"] as? Bool ?? false
        // =================================
        taxes_id = dictionary["taxes_id"] as?  [Int] ?? []
        product_combo_ids = dictionary["product_combo_ids"] as?  [Int] ?? []
        product_variant_ids = dictionary["product_variant_ids"] as?  [Int] ?? []
        attribute_value_ids = dictionary["attribute_value_ids"] as?  [Int] ?? []
        //calculated_quantity
        calculated_quantity = dictionary["calculated_quantity"] as?  Double ?? 1
        if calculated_quantity == 0 {
            calculated_quantity = 1
        }
        insurance_product = dictionary["insurance_product"] as? Bool ?? false
        if let taxes_idSerlize = (dictionary["taxes_id"] as?  [Int] ) {
            let taxArraySerlize = taxes_idSerlize.map({"\($0)"}).joined(separator: ",")
            taxes_id_array_string = taxArraySerlize

        }else{
            if let taxArraySerlize = dictionary["taxes_id_array_string"] as?  String ,!taxArraySerlize.isEmpty{
                taxes_id_array_string = taxArraySerlize

            }
        }
        
        brand_id = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "brand_id", keyOfDatabase: "brand_id",Index: 0) as? Int
        if let base64String = dictionary["image_small"] as? String, !base64String.isEmpty {
            var name_Image = "\(id)"
            if let brandID = brand_id , brandID != 0 {
                name_Image += "_\(brandID)"
            }
            name_Image += ".png"
            if base64String != name_Image{
                self.image_small = name_Image
                FileMangerHelper.shared.saveBase64AsImage(base64String, in :.product_product,with:name_Image)
            }else{
                image_small = name_Image
            }
        }else{
            image_small = ""
        }
        brand_name = baseClass.getFromArrayOrObject(dictionary: dictionary, keyOfArray: "brand_id", keyOfDatabase: "brand_name",Index: 1) as? String
        select_weight = dictionary["select_weight"] as? Bool ?? false
        allow_extra_fees = dictionary["allow_extra_fees"] as? Bool ?? false
        count_stock_available = dictionary["count_stock_available"] as? Double
        dbClass = database_class(table_name: "product_product", dictionary: self.toDictionary_productsTable(),id: id,id_key:"id")
        
    }
    
    
    func toDictionary_productsTable() -> [String:Any]
    {
        var dictionary:[String:Any] = [:]
        
        dictionary["id"] = id
        
        dictionary["sequence"] = sequence
        
        
        dictionary["list_price"] = list_price
        dictionary["lst_price"] = lst_price
        dictionary["standard_price"] = standard_price
        dictionary["calories"] = calories
        dictionary["display_name"] = display_name
        dictionary["name"] = name
        dictionary["barcode"] = barcode
        dictionary["default_code"] = default_code
        dictionary["description_sale"] = description_sale
        dictionary["description"] = description_
        dictionary["tracking"] = tracking
        dictionary["original_name"] = original_name
        dictionary["name_ar"] = name_ar
        dictionary["__last_update"] = __last_update
        dictionary["attribute_names"] = attribute_names
        dictionary["image_small"] = image_small
        dictionary["is_combo"] = is_combo
        dictionary["active"] = active
        dictionary["invisible_in_ui"] = invisible_in_ui
        dictionary["categ_id"] = categ_id
        dictionary["categ_name"] = categ_name
        dictionary["pos_categ_id"] = pos_categ_id
        dictionary["pos_categ_name"] = pos_categ_name
        dictionary["uom_id"] = uom_id
        dictionary["uom_name"] = uom_name
        dictionary["currency_id"] = currency_id
        dictionary["currency_name"] = currency_name
        dictionary["product_tmpl_id"] = product_tmpl_id
        dictionary["product_tmpl_name"] = product_tmpl_name
        dictionary["deleted"] = deleted
        dictionary["type"] = type
        dictionary["company_id"] = company_id
        dictionary["calculated_quantity"] = calculated_quantity
        dictionary["brand_id"] = brand_id
        dictionary["brand_name"] = brand_name
        dictionary["insurance_product"] = insurance_product
        dictionary["select_weight"] = select_weight
        dictionary["allow_extra_fees"] = allow_extra_fees
        
        dictionary["taxes_id_array_string"] = taxes_id_array_string
        dictionary["count_stock_available"] = count_stock_available

        
        
        
        return dictionary
    }
    
    
    func toDictionary() -> [String:Any]
    {
        let dictionary:[String:Any] = self.toDictionary_productsTable()
        
 
        
        return dictionary
    }
    
    func setNameFrom(_ dictionary:[String:Any]){
        var variantName =  ""
        var otherLangVariantNames = ""
        if let variant_names = dictionary["variant_names"] as? String, !variant_names.isEmpty {
            variantName = " - " + variant_names + ""
        }
        if let other_lang_variant_names = dictionary["other_lang_variant_names"] as? String, !other_lang_variant_names.isEmpty {
            otherLangVariantNames = " - " + other_lang_variant_names + ""
        }
        
        if LanguageManager.currentLang() == .en || LanguageManager.currentLang() == .notSet{
            name = (dictionary["name"] as? String ?? "") + variantName

            if let ar_name = dictionary["name_ar"] as? String , !ar_name.isEmpty{
                // odoo 12
                name_ar = (dictionary["name_ar"] as? String ?? "") + otherLangVariantNames
            }else{
                // odoo 14
                name_ar = (dictionary["other_lang_name"] as? String ?? "") + otherLangVariantNames
            }
        }else{
            // Is Arabic Language
           
            if let ar_name = dictionary["name_ar"] as? String , !ar_name.isEmpty{
                // oddo 12
                name_ar = (dictionary["name_ar"] as? String ?? "") + variantName
                name = (dictionary["name"] as? String ?? "") + otherLangVariantNames
            }else{
                //odoo 14
                name = (dictionary["other_lang_name"] as? String ?? "") + otherLangVariantNames
                name_ar = (dictionary["name"] as? String ?? "") + variantName
            }
        }
    }
    
    func save(temp:Bool = false)
    {
        dbClass?.dictionary = self.toDictionary_productsTable()
        dbClass?.id = self.id
        
        if temp
        {
            dbClass!.table_name =  "temp_" + dbClass!.table_name
        }
        
        
        
//        if let idx = product_variant_ids.firstIndex(of:self.id) {
//            product_variant_ids.remove(at: idx)
//        }
        
        relations_database_class(re_id1: self.id, re_id2: taxes_id, re_table1_table2: "products|taxes_id").save()
        relations_database_class(re_id1: self.id, re_id2: product_combo_ids, re_table1_table2: "products|product_combo_ids").save()
        relations_database_class(re_id1: self.id, re_id2: product_variant_ids, re_table1_table2: "products|product_variant_ids").save()
        relations_database_class(re_id1: self.id, re_id2: attribute_value_ids, re_table1_table2: "products|attribute_value_ids").save()

        _ =  dbClass!.save()
        
        
    }
     
     static func reset(temp:Bool = false)
        {
        var table = "product_product"
        if temp
        {
           table =   "temp_"  + table
        }
        
              let cls = product_product_class(fromDictionary: [:])
           _ =   cls.dbClass!.runSqlStatament(sql: "update \(table) set deleted = 1")
        
        relations_database_class.reset(  re_table1_table2: "products|taxes_id")
        relations_database_class.reset(  re_table1_table2: "products|product_combo_ids")
        relations_database_class.reset(  re_table1_table2: "products|product_variant_ids")
        relations_database_class.reset(  re_table1_table2: "products|attribute_value_ids")

        
       }
    static func resetBrandId(with brand_id:Int)
       {
       let table = "product_product"
        let cls = product_product_class(fromDictionary: [:])
        let ids =   cls.dbClass!.get_ids(sql: "Select id from \(table) where brand_id = \(brand_id)")
           if ids.count <= 0 {
               return
           }
        _ =   cls.dbClass!.runSqlStatament(sql: "update \(table) set deleted = 1 where brand_id = \(brand_id)")
       
        relations_database_class.delete(re_id1:ids,  re_table1_table2: "products|taxes_id")
       relations_database_class.delete(re_id1:ids, re_table1_table2: "products|product_combo_ids")
       relations_database_class.delete(re_id1:ids, re_table1_table2: "products|product_variant_ids")
       relations_database_class.delete(re_id1:ids, re_table1_table2: "products|attribute_value_ids")
      }
       
 
    static func delete()
       {
             let cls = product_product_class(fromDictionary: [:])
          _ =   cls.dbClass!.runSqlStatament(sql: "delete from product_product ")
      }
      

    
    static func saveAll(arr:[[String:Any]],temp:Bool = false)
    {
        for item in arr
        {
            let cls = product_product_class(fromDictionary: item)
            cls.deleted = false
            
            cls.dbClass?.insertId = true
            cls.save(temp: temp)
        }
    }
    
    

 func get_price(priceList :product_pricelist_class?) -> Double
    {
    if  priceList != nil
    {
        let calc :calculate_pricelist = calculate_pricelist()
       return   calc.get_price(product: self, rule:  priceList, quantity: 1)
        
    }
    else
    {
        return self.price //self.lst_price
    }
    }
   
    func getQtyAvaliable(complete: @escaping ((Double?) -> Void)){
        if !SharedManager.shared.appSetting().enable_local_qty_avaliblity {
            complete(nil)
            return
        }
        DispatchQueue.global(qos: .background).async {
            
            if let avaliableProduct = product_avaliable_class.getProductAvaliable(for: self.id){
                complete(avaliableProduct.avaliable_qty ?? 0)

            }else{
                complete(nil)

            }
        }
        /*
        if self.type == "product"{
            DispatchQueue.global(qos: .background).async {
              //  let old_sql = "SELECT storage_unit_qty_available from product_template pt WHERE pt.id = \(self.product_tmpl_id ?? 0)"
                let sql = "SELECT count_stock_available as stock_count from product_product  WHERE id = \(self.id )"
                if let result = self.dbClass?.get_row(sql: sql ){
                    if let qtyAvaliable = result["stock_count"] as? Double{
                        complete(qtyAvaliable)
                        return
                    }
                }
            }
    }
    complete(nil)
        */

        
    }
    func updateQtyAvaliable(by qty:Double = 1,with operation:OPERATION_QTY_TYPES,complete: @escaping ((Double?) -> Void)){
//        if !SharedManager.shared.appSetting().enable_local_qty_avaliblity {
//            complete(nil)
//            return
//        }
        DispatchQueue.global(qos: .background).async {
            let sql = "UPDATE product_avaliable SET avaliable_qty = avaliable_qty \(operation.rawValue) \(qty) WHERE  product_product_id = \(self.id )"
            let resutUpdate =  self.dbClass?.runSqlStatament(sql: sql)
              if resutUpdate ?? false {
                  self.getQtyAvaliable(complete: complete)
                  NotificationCenter.default.post(name: Notification.Name("update_qty_avaliable"), object: nil)
                  return
              }
              complete(nil)

           
        }
        /*
        if self.type == "product"{
            DispatchQueue.global(qos: .background).async {
//                let sql_old = "UPDATE product_template SET storage_unit_qty_available = storage_unit_qty_available \(operation.rawValue) \(qty) WHERE id =  id = \(self.product_tmpl_id ?? 0)"

                let sql = "UPDATE product_product SET count_stock_available = count_stock_available \(operation.rawValue) \(qty) WHERE  id = \(self.id )"
              let resutUpdate =  self.dbClass?.runSqlStatament(sql: sql)
                if resutUpdate ?? false {
                    self.getQtyAvaliable(complete: complete)
                    return
                }
                complete(nil)
              
            }
    }
        complete(nil)
        */

        
    }

  
    
}

enum OPERATION_QTY_TYPES:String{
    case PLUS = "+"
    case MINS = "-"
}
