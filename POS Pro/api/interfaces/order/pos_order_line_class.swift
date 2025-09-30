//
//  posOrderLineClass.swift
//  pos
//
//  Created by Khaled on 4/20/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import UIKit

enum updated_status_enum : Int{
    case none = 0 ,last_update_from_local ,last_update_from_server , sending_update_to_server ,sended_update_to_server,insurance_order
}

enum kitchen_status_enum :Int{
    case none =  0 , send = 1 ,done = 2 ,returned = 3
}

enum ptint_status_enum :Int{
    case none =  0 , printed = 1,pending = 2
}


enum discountType:String {
    case percentage = "percentage" , fixed = "fixed" , free = "free"
}

class pos_order_line_class: NSObject {
    var dbClass:database_class?
    
    
    var id:Int = 0
    var parent_line_id:Int = 0

    
    var order_id:Int = 0
    
    var combo_id:Int?{
        didSet{
            SharedManager.shared.printLog("combo_id = \(combo_id)")
        }
    }
    var product_id:Int?
    var product_tmpl_id:Int?
 
    var last_product_id:Int?

    var parent_product_id:Int?
    var auto_select_num:Int? = 0
    var pos_categ_id:Int? = 0

    
   var pos_category_sequence :Int? = 0
    
    var create_user_id : Int?
    var write_user_id : Int?
    var create_pos_id : Int?
    var write_pos_id : Int?
    
    var printed : ptint_status_enum = .none

    
    
    
    var uid : String = ""
    var create_user_name : String?
    var write_user_name : String?
    var create_pos_name : String?
    var write_pos_name : String?
    
    var write_pos_code : String?
    var create_pos_code : String?
    
    var qty:Double  = 0
    var last_qty:Double  = 0

     
    var discount:Double? = 0
    var discount_type:discountType = .percentage
    var discount_display_name:String?

    var kds_preparation_item_time : Int?

 
    var custom_price:Double?

    var price_unit:Double? = 0
    
    
    var price_subtotal:Double? = 0
    var price_subtotal_incl:Double? = 0
    var extra_price:Double? = 0
//    var tax_amount:Double? = 0

    
    var create_date:String?
    var write_date:String?
    var pos_multi_session_write_date : String?

    var def_date:Int = 0

    var note:String?
    
    var discount_program_id:Int = 0

    
    
    var is_combo_line:Bool? = false
    var is_void:Bool? = false{
        didSet{
            if let is_void = is_void{
                updateVoidState(comingIsVoid:is_void )
                if is_void {
                    updateQtyAvaliableAfterVoid()
                }
            }
          
        }
    }
    var is_scrap:Bool? = false
    
    var write_info:Bool  = false
    var is_promotion:Bool = false
    
    var attribute_value_id:Int?

    
    var pos_multi_session_status : updated_status_enum?
    var kitchen_status: kitchen_status_enum = .none
    
    // ============================
   private var product_local:product_product_class?
    var product : product_product_class!
     {
        get
        {
            let p = product_product_class.getProduct(ID: product_id!)

                            return p
            
//            if product_local == nil
//            {
//                let p = product_product_class.getProduct(ID: product_id!)
//
//                if product_lst_price != nil
//                   {
//                               p.lst_price = product_lst_price!
//
//                 }
//                       product_local = p
//
//                   return p
//            }
//            else
//            {
//                return product_local
//            }
//
        }

        set(new_product)
        {
            product_id = new_product.id
        }
    }
    
    var  product_lst_price : Double?
   // ============================

    
    
    var priceList :product_pricelist_class?
    
    
    var products_InCombo:[String:[product_product_class]] = [:]
    var selected_products_in_combo:[pos_order_line_class] = []

    var products_InCombo_avalibale_total_items:Double = 0
    var combo_edit : Bool = false
    var combo_pos_category_id:Int?
    
    
    var scrap_reason : String  = ""
    var tag_temp:String?
    var max_qty_app : Double?
    
    var custome_price_app : Bool = false
    //    var price_total_app : Double  = 0
    var default_product_combo   : Bool = false
    
    var app_require : Bool = false
    var app_selected : Bool = false
    
    var index : Int = 0
    var section : Int = 0
    var section_color : Int = 0

    
    ///==========================================================================================
    // promotion
    var promotion_row_parent : Int?
    var pos_promotion_id : Int?
    var pos_conditions_id : Int?
    ///==========================================================================================
    var void_status:void_status_enum?
    var line_repeat : Int = 0
    var sync_void: Int = 0
    var note_kds : String  = ""
    var discount_extra_fees:Double = 0.0
    var priceListAddOn:[product_combo_price_line_class]?
    var price_list_value:Double?
    var product_combo_id:Int?

    var return_reason : String  = ""



     
    
    init(fromDictionary dictionary: [String:Any],with comboLines:Bool = false){
        super.init()
        
        id = dictionary["id"] as? Int ?? 0
        parent_line_id = dictionary["parent_line_id"] as? Int ?? 0

        product_combo_id = dictionary["product_combo_id"] as? Int ?? 0

        
        parent_product_id = dictionary["parent_product_id"] as? Int ?? 0
        combo_id = dictionary["combo_id"] as? Int ?? 0
        auto_select_num = dictionary["auto_select_num"] as? Int ?? 0
        
        create_user_id = dictionary["create_user_id"] as? Int ?? 0
        write_user_id = dictionary["write_user_id"] as? Int ?? 0
        create_pos_id = dictionary["create_pos_id"] as? Int ?? 0
        write_pos_id = dictionary["write_pos_id"] as? Int ?? 0
        pos_categ_id = dictionary["pos_categ_id"] as? Int ?? 0
        pos_category_sequence = dictionary["pos_category_sequence"] as? Int ?? 0
        discount_program_id = dictionary["discount_program_id"] as? Int ?? 0
        kds_preparation_item_time = dictionary["kds_preparation_item_time"] as? Int ?? 0

        
        printed = ptint_status_enum.init(rawValue:  dictionary["printed"] as? Int ?? 0)!

        
        
        pos_multi_session_status = updated_status_enum.init(rawValue:  dictionary["pos_multi_session_status"] as? Int ?? 0)
        kitchen_status = kitchen_status_enum.init(rawValue:  dictionary["kitchen_status"] as? Int ?? 0)!

        discount_type = discountType.init(rawValue:  dictionary["discount_type"] as? String ?? "") ?? discountType.percentage

        discount_display_name = dictionary["discount_display_name"] as? String ?? ""

        uid = dictionary["uid"] as? String ?? ""
        create_user_name = dictionary["create_user_name"] as? String ?? ""
        write_user_name = dictionary["write_user_name"] as? String ?? ""
        create_pos_name = dictionary["create_pos_name"] as? String ?? ""
        write_pos_name = dictionary["write_pos_name"] as? String ?? ""
        scrap_reason = dictionary["scrap_reason"] as? String ?? ""
        pos_multi_session_write_date = dictionary["pos_multi_session_write_date"] as? String ?? ""
        write_pos_code = dictionary["write_pos_code"] as? String ?? ""
        create_pos_code = dictionary["create_pos_code"] as? String ?? ""

        
        order_id = dictionary["order_id"] as? Int ?? 0
        product_id = dictionary["product_id"] as? Int ?? 0
        product_tmpl_id = dictionary["product_tmpl_id"] as? Int ?? 0
        qty = dictionary["qty"] as? Double ?? 0
        last_qty = dictionary["last_qty"] as? Double ?? 0

        price_unit = dictionary["price_unit"] as? Double ?? 0
        price_subtotal = dictionary["price_subtotal"] as? Double ?? 0
        price_subtotal_incl = dictionary["price_subtotal_incl"] as? Double ?? 0
        discount = dictionary["discount"] as? Double ?? 0
        extra_price = dictionary["extra_price"] as? Double ?? 0
        custom_price = dictionary["custom_price"] as? Double ?? 0

        
        
        create_date = dictionary["create_date"] as? String ?? ""
        write_date = dictionary["write_date"] as? String ?? ""
        note = dictionary["note"] as? String ?? ""
        
        is_combo_line = dictionary["is_combo_line"] as? Bool ?? false
        is_void = dictionary["is_void"] as? Bool ?? false
        is_scrap = dictionary["is_scrap"] as? Bool ?? false
        is_promotion = dictionary["is_promotion"] as? Bool ?? false
        
        if !write_date!.isEmpty
        {
            def_date   = baseClass.compareTwoDate(create_date!, dt2_new: write_date!, formate: baseClass.date_formate_database)
        }

        
        ///==========================================================================================
        // promotion
        promotion_row_parent = dictionary["promotion_row_parent"] as? Int ?? 0
        pos_promotion_id = dictionary["pos_promotion_id"] as? Int ?? 0
        pos_conditions_id = dictionary["pos_conditions_id"] as? Int ?? 0
        ///==========================================================================================
        void_status = void_status_enum(rawValue:dictionary["void_status"] as? Int ?? 0)
        line_repeat = dictionary["line_repeat"] as? Int ?? 0
        sync_void = dictionary["sync_void"] as? Int ?? 0

        if comboLines {
            self.selected_products_in_combo = (dictionary["selected_products_in_combo"] as? [[String:Any]] ?? []).map({pos_order_line_class(fromDictionary: $0)})
        }

        note_kds = dictionary["note_kds"] as? String ?? ""
        return_reason = dictionary["return_reason"] as? String ?? ""

        discount_extra_fees = dictionary["discount_extra_fees"] as? Double ?? 0.0
        dbClass = database_class(table_name: "pos_order_line", dictionary: self.toDictionary(),id: id,id_key:"id")
        
    }
    
    func toDictionary(with comboLine:Bool = false) -> [String:Any]
    {
        var dictionary:[String:Any] = [:]
        
        dictionary["id"] = id
        dictionary["parent_line_id"] = parent_line_id
        dictionary["return_reason"] = return_reason

        
        
        dictionary["order_id"] = order_id
        dictionary["product_id"] = product_id
        dictionary["product_tmpl_id"] = product_tmpl_id
        dictionary["qty"] = qty
        dictionary["last_qty"] = last_qty

        dictionary["price_unit"] = price_unit
        dictionary["price_subtotal"] = price_subtotal
        dictionary["price_subtotal_incl"] = price_subtotal_incl
        dictionary["discount"] = discount
        dictionary["create_date"] = create_date
        dictionary["write_date"] = write_date
        dictionary["is_combo_line"] = is_combo_line
        dictionary["is_void"] = is_void
        dictionary["is_scrap"] = is_scrap
        dictionary["parent_product_id"] = parent_product_id
        dictionary["extra_price"] = extra_price
        dictionary["combo_id"] = combo_id
        dictionary["auto_select_num"] = auto_select_num
        
        dictionary["create_user_id"] = create_user_id
        dictionary["write_user_id"] = write_user_id
        dictionary["create_pos_id"] = create_pos_id
        dictionary["write_pos_id"] = write_pos_id
        
        dictionary["uid"] = uid
        dictionary["create_user_name"] = create_user_name
        dictionary["write_user_name"] = write_user_name
        dictionary["create_pos_name"] = create_pos_name
        dictionary["write_pos_name"] = write_pos_name
        dictionary["write_pos_code"] = write_pos_code
        dictionary["create_pos_code"] = create_pos_code

        dictionary["pos_categ_id"] = pos_categ_id
        dictionary["scrap_reason"] = scrap_reason
        dictionary["discount_display_name"] = discount_display_name
        dictionary["printed"] = printed.rawValue
        dictionary["discount_program_id"] = discount_program_id
        dictionary["pos_multi_session_write_date"] = pos_multi_session_write_date
        dictionary["kds_preparation_item_time"] = kds_preparation_item_time

        
        
        dictionary["note"] = note
        
        dictionary["pos_multi_session_status"] = pos_multi_session_status?.rawValue
        dictionary["kitchen_status"] = kitchen_status.rawValue
        dictionary["discount_type"] = discount_type.rawValue

        ///==========================================================================================
        // promotion
        dictionary["promotion_row_parent"] = promotion_row_parent
        dictionary["pos_promotion_id"] = pos_promotion_id
        dictionary["pos_conditions_id"] = pos_conditions_id
        dictionary["is_promotion"] = is_promotion

        ///==========================================================================================
        dictionary["custom_price"] = custom_price
        ///==========================================================================================
        dictionary["void_status"] = void_status?.rawValue
        dictionary["line_repeat"] = line_repeat
        dictionary["sync_void"] = sync_void
        if comboLine {
            dictionary["selected_products_in_combo"] = self.selected_products_in_combo.map({$0.toDictionary()})

        }
        dictionary["note_kds"] = note_kds
        dictionary["discount_extra_fees"] = discount_extra_fees
        dictionary["product_combo_id"] = product_combo_id

        
         
        return   baseClass.fillterProperties(dictionary: dictionary, excludeProperties: ["pos_categ_id"])
    }
    func writeInfo(){
        let user = SharedManager.shared.activeUser()
        self.write_user_id = user.id
        self.write_user_name = user.name
        
        let pos = SharedManager.shared.posConfig()
        self.write_pos_id = pos.id
        self.write_pos_name = pos.name
        self.write_pos_code = pos.code
        
        self.write_date = baseClass.get_date_now_formate_datebase()
    }
    func save(write_info:Bool = false,updated_session_status:updated_status_enum? = nil, kitchenStatus:kitchen_status_enum? = nil)  -> Int
    {
        if write_info == true
        {
            self.write_info = false
            self.writeInfo()
//            let user = SharedManager.shared.activeUser()
//            self.write_user_id = user.id
//            self.write_user_name = user.name
//
//            let pos = SharedManager.shared.posConfig()
//            self.write_pos_id = pos.id
//            self.write_pos_name = pos.name
//            self.write_pos_code = pos.code
//
//            self.write_date = baseClass.get_date_now_formate_datebase()
             
        }
        
        if updated_session_status != nil
                  {
                     self.pos_multi_session_status = updated_session_status

                  }
        
        if kitchenStatus != nil
                {
                    self.kitchen_status = kitchenStatus!
                }
        
        if self.uid == ""
               {
                   self.uid = baseClass.getTimeINMS()
               }
        
        
        dbClass?.dictionary = self.toDictionary()
        dbClass?.id = self.id
        dbClass?.insertId = false
        
        
        
        let row_id =  dbClass!.save()
        if row_id != 0
        {
            self.id = row_id
        }
        
        return row_id
    }
    
    static func get_or_create(order_id:Int,product:product_product_class) -> pos_order_line_class
    {
        var cls = get(order_id: order_id, product_id: product.id,is_void: false )
        if cls == nil
        {
            cls = create(order_id: order_id, product: product)
        
            
        }
//        else
//        {
//            cls?.is_void = false
//        }
        
        
        return cls!
    }
    
    static func create(order_id:Int,product:product_product_class ) -> pos_order_line_class
       {
           let cls = pos_order_line_class(fromDictionary: [:])
        
        cls.order_id = order_id
        cls.product_id = product.id
        cls.product_tmpl_id = product.product_tmpl_id
        cls.price_unit = product.price
        cls.is_combo_line = product.is_combo
                   
                   let user = SharedManager.shared.activeUser()
        cls.create_user_id = user.id
        cls.create_user_name = user.name
                   
                   let pos = SharedManager.shared.posConfig()
        cls.create_pos_id = pos.id
        cls.create_pos_name = pos.name
        cls.create_pos_code = pos.code
                   
        if  cls.create_date == ""
                   {
                    cls.create_date = baseClass.get_date_now_formate_datebase()
                   }
                   
        return cls
       }
    
    static func get(uid:String) -> pos_order_line_class?
     {
         let cls = pos_order_line_class(fromDictionary: [:])
         let where_sql = " where uid='\(uid)'  "
          
         let item  = cls.dbClass!.get_row(whereSql: where_sql)
         if item != nil
         {
             return pos_order_line_class(fromDictionary: item!)
         }

         return nil
     }
    
    
    static func get_line_promotion(order_id:Int ,_pos_promotion_id:Int ,_pos_conditions_id:Int    ) ->  pos_order_line_class?
    {
        let cls = pos_order_line_class(fromDictionary: [:])
        let where_sql = " where  order_id = \(order_id) and is_void = 0   and pos_promotion_id = \(_pos_promotion_id) and pos_conditions_id = \(_pos_conditions_id)"
        
     
        
        let items  = cls.dbClass!.get_rows(whereSql: where_sql)
        
        if (items.count > 0 )
        {
            return pos_order_line_class(fromDictionary: items[0])
        }
       

        return nil
    }
    
    
    static func get_line_promotions(order_id:Int,_promotion_row_parent:Int,_pos_promotion_id:Int? = nil ,_pos_conditions_id:Int? = nil  ) -> [pos_order_line_class]
    {
        let cls = pos_order_line_class(fromDictionary: [:])
        var where_sql = " where promotion_row_parent=\(_promotion_row_parent)  and order_id = \(order_id) and is_void = 0"
        
        if _pos_promotion_id != nil
        {
            where_sql = where_sql + " and pos_promotion_id = \(_pos_promotion_id!)"
        }
        
        if _pos_conditions_id != nil
        {
            where_sql = where_sql + " and pos_conditions_id = \(_pos_conditions_id!)"
        }
        
        let items  = cls.dbClass!.get_rows(whereSql: where_sql)
        
        var list_rows: [pos_order_line_class] = []
        for row in items
        {
            list_rows.append(pos_order_line_class(fromDictionary: row))
        }
        
//        if item != nil
//        {
//            return pos_order_line_class(fromDictionary: item!)
//        }

        return list_rows
    }
    
    
    static func get_lines_promotions(_promotion_row_parent:Int ) -> [pos_order_line_class]
    {
        let cls = pos_order_line_class(fromDictionary: [:])
        let where_sql = " where promotion_row_parent=\(_promotion_row_parent)  and is_void = 0"
        
       
        let items  = cls.dbClass!.get_rows(whereSql: where_sql)
        
        var list_rows: [pos_order_line_class] = []
        for row in items
        {
            list_rows.append(pos_order_line_class(fromDictionary: row))
        }
        

        return list_rows
    }
    
    
    static func get(order_id:Int,product_id:Int ,is_void:Bool? = nil   ) -> pos_order_line_class?
    {
        let cls = pos_order_line_class(fromDictionary: [:])
        var where_sql = " where order_id=\(order_id) and product_id = \(product_id) "
        if is_void != nil
        {
            if is_void == true
            {
                where_sql = where_sql + " and is_void = 1"

            }
            else
            {
                where_sql = where_sql + " and is_void = 0"

            }
        }
        
        let item  = cls.dbClass!.get_row(whereSql: where_sql)
        if item != nil
        {
            return pos_order_line_class(fromDictionary: item!)
        }

        return nil
    }
    
    static func get_all(order_id:Int,product_id:Int ,is_void:Bool? = nil   ) -> [pos_order_line_class]
       {
           let cls = pos_order_line_class(fromDictionary: [:])
           var where_sql = " where order_id=\(order_id) and product_id = \(product_id) "
           if is_void != nil
           {
               if is_void == true
               {
                   where_sql = where_sql + " and is_void = 1"

               }
               else
               {
                   where_sql = where_sql + " and is_void = 0"

               }
           }
           
        var rows:[pos_order_line_class] = []
           let arr  = cls.dbClass!.get_rows(whereSql: where_sql)
           for item in arr
           {
            rows.append(pos_order_line_class(fromDictionary: item))
           }

           return rows
       }
    
    static func void_lines_combo(line_id:Int,order_id:Int,void_status:void_status_enum)
       {
 
        
         let sql = " update pos_order_line set is_void = 1, void_status = \(void_status.rawValue) where parent_line_id  =  \(line_id) and order_id = \(order_id) and is_void = 0"
                
               _ = database_class().runSqlStatament(sql: sql)
           
       }
    
    static func void_all(order_id:Int,order_uid:String?,void_status:void_status_enum,with_ms_write_date:Bool)
       {
           var condationID = "order_id = \(order_id)"
           if let posOrder = pos_order_class.get(uid:  order_uid ?? "") {
               condationID = "order_id = \(posOrder.id ?? 0)"
           }
           
           var contadition = ""
           if !with_ms_write_date {
               contadition = "and (pos_multi_session_write_date != '' or kitchen_status = 0)"
           }
           let sql = "update pos_order_line set is_void = 1,void_status = \(void_status.rawValue)  where \(condationID)  \(contadition) and is_void = 0 "
           
       
           
           _ = database_class().runSqlStatament(sql: sql)
           
       }
    
    static func void_all_execlude(lines ids:String,order_id:Int,order_uid:String?,_delete_discount:Bool,void_status:void_status_enum)
    {
        var condationID = "order_id = \(order_id)"
        if let posOrder = pos_order_class.get(uid:  order_uid ?? "") {
            condationID = "order_id = \(posOrder.id ?? 0)"
        }
        let delete_discount = _delete_discount ? "" : " and discount = 0"
        let sql = "update pos_order_line set is_void = 1, void_status = \(void_status.rawValue) where  id not in (\(ids)) and is_void = 0  and   \(condationID) \(delete_discount)"
        
    
        
        _ = database_class().runSqlStatament(sql: sql)
        
    }
    static func void_all_include(uids:String,order_id:Int,order_uid:String?,void_status:void_status_enum,with_ms_write_date:Bool)
    {
        var condationID = "order_id = \(order_id)"
        if let posOrder = pos_order_class.get(uid:  order_uid ?? "") {
            condationID = "order_id = \(posOrder.id ?? 0)"
        }
        var contadition = ""
        if !with_ms_write_date {
            contadition = "and (pos_multi_session_write_date != '' or kitchen_status = 0)"
        }
        let sql = "update pos_order_line set is_void = 1, void_status = \(void_status.rawValue) where  uid in (\(uids)) and \(condationID) \(contadition) and is_void = 0"



        _ = database_class().runSqlStatament(sql: sql)

    }
    
    static func void_all_execlude(uids:String,order_id:Int,order_uid:String?,void_status:void_status_enum,with_ms_write_date:Bool)
    {
        var condationID = "order_id = \(order_id)"
        if let posOrder = pos_order_class.get(uid:  order_uid ?? "") {
            condationID = "order_id = \(posOrder.id ?? 0)"
        }
        var contadition = ""
        if !with_ms_write_date {
            contadition = "and (pos_multi_session_write_date != '' or kitchen_status = 0)"
        }
        let sql = "update pos_order_line set is_void = 1, void_status = \(void_status.rawValue) where  uid not in (\(uids)) and  \(condationID) \(contadition) and is_void = 0"



        _ = database_class().runSqlStatament(sql: sql)

    }
    
    static func void_all_execlude(products ids:String,order_id:Int,order_uid:String?,parent_product_id:Int,pos_multi_session_status:updated_status_enum?,parent_line_id:Int,void_status:void_status_enum)
    {
        var condationID = "order_id = \(order_id)"
        if let posOrder = pos_order_class.get(uid:  order_uid ?? "") {
            condationID = "order_id = \(posOrder.id ?? 0)"
        }
        var sql = "update pos_order_line set is_void = 1, void_status = \(void_status.rawValue) where  \(condationID) and parent_product_id = \(parent_product_id) and product_id not in (\(ids)) and parent_line_id =\(parent_line_id) "

        if pos_multi_session_status != nil
        {
            sql = sql + " and pos_multi_session_status != \(pos_multi_session_status!.rawValue)"
        }


        _ = database_class().runSqlStatament(sql: sql)

    }
    
    static func delelte_all_execlude(products ids:String,order_id:Int,order_uid:String?,parent_product_id:Int,parent_line_id:Int)
    {
        var condationID = "order_id = \(order_id)"
        if let posOrder = pos_order_class.get(uid:  order_uid ?? "") {
            condationID = "order_id = \(posOrder.id ?? 0)"
        }
        let sql = "delete from pos_order_line  where  \(condationID) and parent_product_id = \(parent_product_id) and product_id not in (\(ids)) and pos_multi_session_status != \(updated_status_enum.last_update_from_local.rawValue)  and parent_line_id =\(parent_line_id) "
        
        _ = database_class().runSqlStatament(sql: sql)
        
    }
    
    static func delete_order_lines(order_id:Int)
    {
        
        _ = database_class().runSqlStatament(sql: "delete from pos_order_line where order_id = \(order_id) " )
        
    }
    
    static func update_order_status(order_id:Int,status:updated_status_enum!)
    {
        
        _ = database_class().runSqlStatament(sql: "update pos_order_line set pos_multi_session_status =\(status.rawValue) where order_id = \(order_id) " )
        if status == .sended_update_to_server {
            var userInfo:[String:Any]  = [:]
                userInfo["pos_multi_session_status"] = status.rawValue
            userInfo["order_id"] = order_id

           
            NotificationCenter.default.post(name: Notification.Name("update_pos_multisession_status"), object: order_id,userInfo:userInfo )
        }
    }
    
    
    static func delete_all()
    {
        
        _ = database_class().runSqlStatament(sql: "delete from pos_order_line " )
        
    }
      
    static func delete_line(line_id:Int)
       {
           
           _ = database_class().runSqlStatament(sql: "delete from pos_order_line WHERE id =\(line_id)"  )
           
       }
         
    
    
    static  func get_lines_in_combo(order_id:Int,product_id:Int,parent_line_id:Int) ->[pos_order_line_class]
    {
        let sql = """
        select pos_order_line.*  FROM pos_order_line
        WHERE order_id= \(order_id) and  is_void = 0 and is_scrap = 0 and parent_product_id = \(product_id) and parent_line_id = \(parent_line_id)
        """
        
        var products_in_combo:[pos_order_line_class]  = []
        
        let arr = database_class().get_rows(sql: sql)
        for row in arr
        {
            let line = pos_order_line_class(fromDictionary: row)
            
            products_in_combo.append(line)
        }
        
        return products_in_combo
    }
    
    static  func get_all_lines_in_combo(order_id:Int,product_id:Int,parent_line_id:Int,get_lines_void_from_ui:Bool? = nil) ->[pos_order_line_class]
    {
        var void_lines_query = ""
        if get_lines_void_from_ui == true
        {
            void_lines_query = "and void_status not in" + void_status_enum.getNotVoidFromUIStatusQuery()

//            void_lines_query = "and void_status not in (3,4)"
        }
        let sql = """
        select pos_order_line.*  FROM pos_order_line
        WHERE order_id= \(order_id)  and parent_product_id = \(product_id) and parent_line_id = \(parent_line_id) \(void_lines_query)
        """
        
        var products_in_combo:[pos_order_line_class]  = []
        
        let arr = database_class().get_rows(sql: sql)
        for row in arr
        {
            let line = pos_order_line_class(fromDictionary: row)
            
            products_in_combo.append(line)
        }
        
        return products_in_combo
    }
    
    
    func checISSendToMultisession() -> Bool{
        if let order_object = pos_order_class.get(order_id: self.order_id){
            return order_object.checISSendToMultisession()
        }
        return false
    }
    
    func get_max_line_repeat() -> Int?{
        guard let product_id = self.product_id else {
            return nil
        }
        let sql = "select max(line_repeat) as line_repeat from pos_order_line where product_id =? and order_id = ?"
        var count = 0
        
        let semaphore = DispatchSemaphore(value: 0)
        SharedManager.shared.database_db!.inDatabase { (db:FMDatabase) in
            
            let resutl:FMResultSet = try! db.executeQuery(sql, values: [product_id,self.order_id])
            if resutl.next()
            {
                count = Int(resutl.int(forColumn: "line_repeat"))
                resutl.close()
            }
            
            semaphore.signal()
        }
        semaphore.wait()
        return count
    }
    
    func is_sent_to_kitchen()->Bool{
//        if checISSendToMultisession(){
            if self.qty == self.last_qty && self.is_void == false && self.printed == .printed{
                return true
            }
//        }
        return false
    }
    static func get_void_lines(in session:pos_session_class, for orders_id:[Int])->[pos_product_void]{
        let ids_string = "(" + orders_id.map(){"\($0)"}.joined(separator: ",") + ")"
        let sql = """
        select pos_order_line.*  FROM pos_order_line
        WHERE order_id in \(ids_string)
        and (void_status in (1,2) or void_status ISNULL)
        and sync_void = 0
        and write_pos_id != 0
        and is_void = 1
        """
        
        var products_lines:[pos_order_line_class]  = []
        var products_void:[pos_product_void]  = []

        let arr = database_class().get_rows(sql: sql)
        products_lines.append(contentsOf: arr.map(){pos_order_line_class(fromDictionary: $0)})
        products_void.append(contentsOf:products_lines.map(){pos_product_void(from: session, line: $0)} )
        return products_void
    }
    static func set_sync_void_lines(in session:pos_session_class, for orders_id:[Int]){
        let ids_string = "(" + orders_id.map(){"\($0)"}.joined(separator: ",") + ")"
        let sql = "update pos_order_line set sync_void = 1  where  order_id in \(ids_string) and void_status in (1,2)"
        _ = database_class().runSqlStatament(sql: sql)
    }
    
    func isVoidFromUI()->Bool{
        return (self.is_void == true && self.void_status != void_status_enum.update_from_query)
    }
    func updateVoidState(comingIsVoid:Bool){
        if !(discount_display_name?.isEmpty ?? true) {
            setVoidForDiscountLine(comingIsVoid)
        }else{
            setVoidStatusLine(comingIsVoid)
        }
    }
    func updateQtyAvaliableAfterVoid(){
        if let ptemp = self.product{
        
            ptemp.updateQtyAvaliable(by:self.qty , with: .PLUS) { newAvaliableQty in
               
            }
        }
    }
    func setVoidStatusLine(_ comingIsVoid:Bool){
        if comingIsVoid{
            if self.void_status != void_status_enum.split_order &&
                self.void_status != void_status_enum.update_from_query &&
                self.void_status != void_status_enum.insurance_order &&
                self.void_status != void_status_enum.move_line &&
                self.void_status != void_status_enum.cancel_customer &&
                self.void_status != void_status_enum.cancel_delivery
            {
            if SharedManager.shared.appSetting().hide_sent_to_kitchen_btn {
                if self.void_status == void_status_enum.none{
                    self.void_status = .before_sent_to_kitchen
                    return
                }
            }
            if self.pos_multi_session_status == updated_status_enum.last_update_from_local {
                    self.void_status = .before_sent_to_kitchen
            }else{
                if checISSendToMultisession(){
                    if self.void_status != .before_sent_to_kitchen {
                        self.void_status = .after_sent_to_kitchen
                    }
                }else{
                    self.void_status = .before_sent_to_kitchen
                }
            }
        }
    }else{
        self.void_status = void_status_enum.none
    }
    }
    func setVoidForDiscountLine(_ comingIsVoid:Bool){
        if comingIsVoid == true{
            if SharedManager.shared.appSetting().hide_sent_to_kitchen_btn {
                if self.void_status == void_status_enum.none{
                    self.void_status = void_status_enum.discount_line_before
                    return
                }
            }
            if self.pos_multi_session_status == updated_status_enum.last_update_from_local {
                self.void_status = .discount_line_before
            }else{
                if checISSendToMultisession(){
                    if self.void_status != .discount_line_before {
                        self.void_status = .discount_line_after
                    }
                }else{
                    self.void_status = .discount_line_before
                }
            }
        }else{
            self.void_status = void_status_enum.none
        }
    }
    func setPriceListAddOn(){
        DispatchQueue.global(qos: .background).async {
        if let productTmpID = self.product_tmpl_id,  (self.priceListAddOn?.count ?? 0) <= 0  {
            let items:[product_combo_price_line_class] = product_combo_price_line_class.getPriceList(for:productTmpID )
            self.priceListAddOn?.removeAll()
            self.priceListAddOn = []
            self.priceListAddOn?.append(contentsOf: items)
        }
        }
    }
    func setPriceListValue(for orderType:delivery_type_class?) {
        self.price_list_value = nil
        if let priceListAddOn = priceListAddOn, let orderType = orderType, priceListAddOn.count > 0{
            let priceListID = orderType.pricelist_id
            if let priceListValue = priceListAddOn.filter({$0.price_list_id == priceListID }).first?.price{
                self.price_list_value = priceListValue
            }
        }
    }
    func isSendToMultisession() -> Bool{
        let isSentMultisession = (!(self.pos_multi_session_write_date ?? "").isEmpty  )
                              || self.create_pos_id != SharedManager.shared.posConfig().id
         if (!(self.pos_multi_session_write_date ?? "").isEmpty )
             || self.create_pos_id != SharedManager.shared.posConfig().id {
            return true
         }
        return false
    }
    func is_send_toKDS() -> Bool
    {
        
        let pos = SharedManager.shared.posConfig()
        
        let sql = """
        SELECT count(*) from pos_order_line where order_id = \(self.order_id)
        and pos_order_line.pos_multi_session_status in (2,4)
        and pos_order_line.write_pos_id = \(pos.id)
        """
        
        //and pos_order_line.pos_multi_session_status = 1
        
        
        var changed:Bool = false
        
        let semaphore = DispatchSemaphore(value: 0)
        SharedManager.shared.database_db!.inDatabase { (db:FMDatabase) in
            
            let resutl:FMResultSet = try! db.executeQuery(sql, values: [])
            
            if resutl.next()
            {
                let count:Int = Int(resutl.int(forColumnIndex: 0))
                
                if count > 0
                {
                    resutl.close()
                    changed =  true
                }
            }
            
            resutl.close()
            
            semaphore.signal()
        }
        
        
        semaphore.wait()
        
        
        return changed
        
    }
    
}
