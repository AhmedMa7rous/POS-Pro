//
//  rules.swift
//  pos
//
//  Created by Khaled on 1/24/21.
//  Copyright © 2021 khaled. All rights reserved.
//

import Foundation
enum rule_tables_key:String {
   case change_table_type = "change_table",
    cancle_table_type = "cancle_table",
    browse_table_type = "browse_table",
    new_order_table_type = "new_order_table"

    

}

enum rule_key:String {
    case  none = "",
          _return = "RETURN" ,
          open_drawer = "OPEN_DRAWER" ,
          show_history = "SHOW_HISTORY",
          table_management = "TABLE_MANAGEMENT",
          payment = "PAYMENT",
          setting = "SETTING",
          log = "LOG",
          discount = "DISCOUNT",
          print_bill = "PRINT_BILL",
          open_session = "OPEN_SESSION",
          customـdiscount = "CUSTOMـDISCOUNT",
          scrap = "SCRAP",
          voidـorder_before_send = "VOIDـORDER_BEFOR_SEND",
          voidـorder_after_send = "VOIDـORDER_AFTER_SEND",
          //          multiـorder = "MULTIـORDER",
          sales_report = "SALES_REPORT",
          sales_summary_report = "SALES_SUMMARY_REPORT",
          products_mix_range = "PRODUCTS_MIX_RANGE",
          category_summery_range = "CATEGORY_SUMMERY_RANGE",
          stc_payments = "STC_PAYMENTS",
          products_void = "PRODUCTS_VOID",
          products_waste = "PRODUCTS_WASTE",
          products_return = "PRODUCTS_RETURN",
          stock = "STOCK",
          till_operations = "TILL_OPERATIONS",
          sales_report_multi_pos = "SALES_REPORT_MULTI_POS",
          discount_report = "DISCOUNT_REPORT",
          journal_bank = "JOURNAL_BANK",
          journal_cash = "JOURNAL_CASH",
          open_price = "open_price",
          show_pos_promotion = "SHOW_POS_PROMOTION",
          driver_report = "DRIVER_REPORT",
          //          table_management_edit = "TABLE_MANAGEMENT_EDIT",
          in_stock_management = "IN_STOCK_MANAGEMENT",
          adjustment_stock_management = "ADJUSTMENT_STOCK_MANAGEMENT",
          request_stock_order_management = "REQUEST_STOCK_ORDER_MANAGEMENT",
          update_devices = "UPDATE_DEVICES",
          insurance_return = "INSURANCE_RETURN",
          admin_driver_lock = "admin_driver_lock",
          memberShips = "memberShips",
          printers_managment = "printers_managment",
          return_by_search = "return_by_search",
          select_table = "select_table",
          change_table = "change_table",
          cancle_table = "cancle_table",
          open_session_rule = "open_session_rule",
          resume_session = "resume_session",
          close_session = "close_session",
//          browse_table = "browse_table",
//          new_order_table = "new_order_table",
          change_responsible_table = "change_responsible_table",
          split_order = "split_order",
          move_order = "move_order",
          edit_after_sent_to_kitchen = "edit_after_sent_to_kitchen"
    
    
    
    
    
    //    driver_lock = "DRIVER_LOCK"
    //         add_customer = "ADD_CUSTOMER",
    //         select_customer = "SELECT_CUSTOMER",
    //         voidـitem = "VOIDـITEM",
    //         fixedـdiscount = "FIXEDـDISCOUNT",
    //         percentageـdiscount = "PERCENTAGEـDISCOUNT",
    //         pricelist = "PRICELIST",
    //         voidـorder = "VOIDـORDER",
    
    func getOtherLang()->String{
        switch self {
        case  .none: return ""
        case ._return : return "المرتجع"
        case .open_drawer : return "درج مفتوح"
        case .show_history : return "عرض الطلبيات"
        case .table_management : return "إدارة الطاولات"
        case .payment : return "الدفع"
        case .setting : return  "الاعدادات"
        case .log : return "السجل"
        case .discount : return "الخصم"
        case .print_bill : return "طباعة الفاتورة"
        case .open_session : return "فتح الجلسة"
        case .customـdiscount : return "خصم مخصص"
        case .scrap : return "الهالك"
        case .voidـorder_before_send : return "الغاء الطلب قبل الارسال"
        case .voidـorder_after_send : return "الغاء الطلب بعد الارسال"
        case .sales_report : return "تقرير المبيعات"
        case .sales_summary_report : return "تقرير ملخص المبيعات"
        case .products_mix_range : return "مجموعة مزيج المنتجات"
        case .category_summery_range : return "نطاق تلخيصي الفئة"
        case .stc_payments : return "الدفع ب stc"
        case .products_void : return "الغاء المنتج"
        case .products_waste : return  "هالك المنتجات"
        case .products_return : return "إرجاع المنتجات"
        case .stock : return "مخزون"
        case .till_operations : return "حتى العمليات"
        case .sales_report_multi_pos : return "تقرير مبيعات نقاط البيع المتعددة"
        case .discount_report : return "تقرير الخصم"
        case .journal_bank : return "دفتر اليومية"
        case .journal_cash : return "دفتر النقدية"
        case .open_price : return "تعديل السعر"
        case .show_pos_promotion : return "عروض نقطة البيع"
        case .driver_report : return "تقرير السائق"
//        case .table_management_edit : return "تعديل ترتيب الطاولات"
        case .in_stock_management : return "إدارة وارد المخزن"
        case .adjustment_stock_management : return "إدارة تعديلات المخزن"
        case .request_stock_order_management : return "إدارة طلب شراء المخزون"
        case .update_devices : return "إدارة تعدبل الاجهزة"
        case .insurance_return : return "إرجاع التآمين"
        case .admin_driver_lock : return "admin_driver_lock"
        case .memberShips : return "الاشتراكات"
        case .printers_managment : return "إدارة الطابعات"
        case .return_by_search : return "إرجاع الطلبات بالحث"
        case .select_table : return "اختيار الطاولات"
        case .change_table : return "تغير الطاولات"
        case .cancle_table : return "إلغاء الطاولات"
        case .open_session_rule : return "فتح جلسه"
        case .resume_session : return "استئناف الجلسه"
        case .close_session : return "إغلاق جلسه"
  //          browse_table = "browse_table",
  //          new_order_table = "new_order_table",
        case .change_responsible_table : return "التحكم في مسئول الطاوله"
        case .split_order : return "تقسييم الطلبات"
        case .move_order : return "نقل الطالبات"
        case .edit_after_sent_to_kitchen : return "تعديل بعد الارسال للمطبخ"

               }
    }

}

class rules: NSObject {
 
    static func rule(name: String, key: String,other_lang_name:String, description: String,default_value:Bool = true,force_assign_to_all:Bool = false) -> [String:Any] {
 
        var param:[String:Any] = [
            "name":name ,
            "key":key,
            "other_lang_name":other_lang_name,
            "description" : description,
            "default_value" : true //default_value
                ]
        if force_assign_to_all {
            param =  [
               "name":name ,
               "key":key,
               "other_lang_name":other_lang_name,
               "description" : description,
               "default_value" : true,
               "force_assign_to_all": true,//default_value
                   ]
        }
        return param
    }
      
    public static  let  list:[[String:Any] ] = [
        rule(name: "Edit after sent to kitchen",
             key: rule_key.edit_after_sent_to_kitchen.rawValue,
             other_lang_name:  "تعديل بعد الارسال للمطبخ",
             description: "",
             force_assign_to_all: true),
        
        rule(name: "Move orders",
             key: rule_key.move_order.rawValue,
             other_lang_name: "نقل الطالبات",
             description: ""),
        
        rule(name: "Split orders",
             key: rule_key.split_order.rawValue,
             other_lang_name: "تقسييم الطلبات",
             description: ""),
        
        rule(name: "change_responsible_table",
             key: rule_key.change_responsible_table.rawValue,
             other_lang_name: "التحكم في مسئول الطاوله",
             description: ""),
//        rule(name: "browse_table",
//             key: rule_key.browse_table.rawValue,other_lang_name: "استعراض الطاولات",
//             description: "" ),
//        rule(name: "new_order_table",
//             key: rule_key.new_order_table.rawValue,other_lang_name: "طلب جديد",
//             description: "" ),
      rule(name: "return",
           key: rule_key._return.rawValue,
           other_lang_name: "المرتجع",
           description: ""),
      
      rule(name: "open drawer",
           key: rule_key.open_drawer.rawValue,
           other_lang_name: "درج مفتوح",

           description: ""),
      
      rule(name: "show history",
           key:  rule_key.show_history.rawValue, other_lang_name: "عرض الطلبيات",
           description: ""),
      
      rule(name: "table management",
           key: rule_key.table_management.rawValue,other_lang_name: "إدارة الطاولات",
           description: ""),
      
      rule(name: "payment",
           key: rule_key.payment.rawValue, other_lang_name: "الدفع",
           description: ""),
      
      rule(name: "setting",
           key: rule_key.setting.rawValue, other_lang_name: "الاعدادات",
           description: "" ),
      
      rule(name: "log",
           key: rule_key.log.rawValue, other_lang_name: "السجل",
           description: ""),
      
//      rule(name: "add customer",
//           key: rule_key.add_customer.rawValue, other_lang_name: "إضافة عميل",
//           description: ""),
      
//      rule(name: "select customer",
//           key: rule_key.select_customer.rawValue,other_lang_name: "اختيار العميل",
//           description: ""),
      
      rule(name: "discount",
           key: rule_key.discount.rawValue,other_lang_name: "الخصم",
           description: ""),
      
//      rule(name: "pricelist",
//           key: rule_key.pricelist.rawValue,
//           other_lang_name: "قائمة الاسعار",
//           description: ""),
      
      rule(name: "print bill",
           key: rule_key.print_bill.rawValue,other_lang_name: "طباعة الفاتورة",
           description: ""),
      
//      rule(name: "open session",
//           key: rule_key.open_session.rawValue,other_lang_name: "فتح الجلسة",
//           description: ""),
   
        rule(name: "custom discount",
             key: rule_key.customـdiscount.rawValue,other_lang_name: "خصم مخصص",
             description: ""),
        
//        rule(name: "fixed discount",
//             key: rule_key.fixedـdiscount.rawValue,other_lang_name: "خصم ثابت",
//             description: ""),
        
//        rule(name: "percentage discount",
//             key: rule_key.percentageـdiscount.rawValue,
//             other_lang_name:"نسبة الخصم",
//             description: ""),
        
        rule(name: "scrap",
             key: rule_key.scrap.rawValue,other_lang_name: "الهالك",
             description: ""),
        
//        rule(name: "void order",
//             key: rule_key.voidـorder.rawValue,other_lang_name: "الغاء الطلب",
//             description: ""),
        
        rule(name: "void order before send",
             key: rule_key.voidـorder_before_send.rawValue,other_lang_name: "الغاء الطلب قبل الارسال",
             description: ""),
        
        rule(name: "void order after send",
             key: rule_key.voidـorder_after_send.rawValue,other_lang_name: "الغاء الطلب بعد الارسال",
             description: ""),
        
//        rule(name: "void item",
//             key: rule_key.voidـitem.rawValue,other_lang_name: "الغاء عنصر",
//             description: ""),
        
//        rule(name: "multi order",
//             key: rule_key.multiـorder.rawValue,other_lang_name: "متعدد الطلبات",
//             description: ""),

        rule(name: "sales_report",
             key: rule_key.sales_report.rawValue,other_lang_name:"تقرير المبيعات",
             description: ""),
        
        rule(name: "sales_summary_report",
             key: rule_key.sales_summary_report.rawValue,other_lang_name: "تقرير ملخص المبيعات",
             description: ""),
        
        rule(name: "products_mix_range",
             key: rule_key.products_mix_range.rawValue,other_lang_name: "مجموعة مزيج المنتجات",
             description: ""),
        
        rule(name: "category_summery_range",
             key: rule_key.category_summery_range.rawValue,other_lang_name: "نطاق تلخيصي الفئة",
             description: ""),
        
        rule(name: "stc_payments",
             key: rule_key.stc_payments.rawValue,other_lang_name: "الدفع ب stc",
             description: ""),
        
        rule(name: "products_void",
             key: rule_key.products_void.rawValue,other_lang_name:"الغاء المنتج",
             description: ""),
        
        rule(name: "products_waste",
             key: rule_key.products_waste.rawValue,other_lang_name: "هالك المنتجات",
             description: ""),
        
        rule(name: "products_return",
             key: rule_key.products_return.rawValue,other_lang_name: "إرجاع المنتجات",
             description: ""),
        
        rule(name: "stock",
             key: rule_key.stock.rawValue,other_lang_name: "مخزون",
             description: ""),
        
        rule(name: "till_operations",
             key: rule_key.till_operations.rawValue,other_lang_name: "حتى العمليات",
             description: ""),
        
        rule(name: "sales_report_multi_pos",
             key: rule_key.sales_report_multi_pos.rawValue,other_lang_name: "تقرير مبيعات نقاط البيع المتعددة",
             description: ""),
        
        rule(name: "discount_report",
             key: rule_key.discount_report.rawValue,other_lang_name: "تقرير الخصم",
             description: ""),
        
        rule(name: "journal_bank",
             key: rule_key.journal_bank.rawValue,other_lang_name: "دفتر اليومية",
             description: ""),
        
        rule(name: "journal_cash",
             key: rule_key.journal_cash.rawValue,other_lang_name: "دفتر النقدية",
             description: ""),
        
        
        rule(name: "open_price",
             key: rule_key.open_price.rawValue,other_lang_name: "تعديل السعر",
             description: ""),
        rule(name: "show_pos_promotion",
             key: rule_key.show_pos_promotion.rawValue,other_lang_name: "عروض نقطة البيع",
             description: ""),
        
      rule(name: "driver_report",
           key: rule_key.driver_report.rawValue,other_lang_name: "تقرير السائق",
           description: "" ),
      
//      rule(name: "table_management_edit",
//           key: rule_key.table_management_edit.rawValue,other_lang_name: "تعديل ترتيب الطاولات",
//           description: "" ),
      
      rule(name: "select_table",
           key: rule_key.select_table.rawValue,other_lang_name: "اختيار الطاولات",
           description: "" ),

      rule(name: "change_table",
           key: rule_key.change_table.rawValue,other_lang_name: "تغير الطاولات",
           description: "" ),

      rule(name: "cancle_table",
           key: rule_key.cancle_table.rawValue,other_lang_name: "إلغاء الطاولات",
           description: "" ),

      rule(name: "IN_STOCK_MANAGEMENT",
           key: rule_key.in_stock_management.rawValue,other_lang_name: "إدارة وارد المخزن",
           description: ""),
    
      rule(name: "ADJUSTMENT_STOCK_MANAGEMENT",
           key: rule_key.adjustment_stock_management.rawValue,other_lang_name: "إدارة تعديلات المخزن",
           description: "" ),
      
      rule(name: "REQUEST_STOCK_ORDER_MANAGEMENT",
           key: rule_key.request_stock_order_management.rawValue,other_lang_name: "إدارة طلب شراء المخزون",
           description: "" ),
      
      rule(name: "UPDATE_DEVICES",
           key: rule_key.update_devices.rawValue,other_lang_name: "إدارة تعدبل الاجهزة",
           description: "" ),
      rule(name: "insurance_return",
           key: rule_key.insurance_return.rawValue,other_lang_name: "إرجاع التآمين",
           description: "",default_value: false),
//      rule(name: "driver_lock",
//           key: rule_key.driver_lock.rawValue,other_lang_name: "driver_lock",
//           description: "",default_value: false),
      rule(name: "admin_driver_lock",
           key: rule_key.admin_driver_lock.rawValue,other_lang_name: "admin_driver_lock",
           description: "",default_value: false),
      
      rule(name: "memberShips",
           key: rule_key.memberShips.rawValue,other_lang_name: "الاشتراكات",
           description: ""),
      //printers_managment
      rule(name: "printers_managment",
           key: rule_key.printers_managment.rawValue,other_lang_name: "إدارة الطابعات",
           description: ""),
      //return_by_search
      rule(name: "return_by_search",
           key: rule_key.return_by_search.rawValue,other_lang_name: "إرجاع الطلبات بالحث",
           description: ""),
      rule(name: "open_session_rule",
           key: rule_key.open_session_rule.rawValue,other_lang_name: "فتح جلسه",
           description: ""),
      rule(name: "close_session",
           key: rule_key.close_session.rawValue,other_lang_name: "إغلاق جلسه",
           description: ""),
      rule(name: "resume_session",
           key: rule_key.resume_session.rawValue,other_lang_name: "استئناف الجلسه",
           description: ""),
        
      ]
    
    
    static func get_rules_for_user(user_id:Int) -> [ios_rule]
    {
        var arr_rules:[ios_rule] = []
      
        arr_rules = get_rules_for_user_has_group(user_id: user_id)
        if arr_rules.count == 0
        {
            arr_rules = get_rules_with_default_value()
            
            if arr_rules.count == 0
            {
                arr_rules = get_all_rules()
            }
        }
      
        
        return arr_rules
    }
    static func check_user_has_group(user_id:Int) -> Bool
    {
        let sql = """
            SELECT ios_rule.* from relations
            INNER JOIN ios_rule
            on ios_rule.id  = relations.re_id2
            where re_table1_table2 = "ios_group|ios_rule"
            and re_id1 = (SELECT re_id1  as group_id from relations where re_table1_table2 = "ios_group|res_users" and re_id2  = \(user_id))
        """
        
        let cls = ios_rule(fromDictionary: [:])
        let rows =  cls.dbClass?.get_rows(sql: sql) ?? []
 
        if rows .count > 0
        {
            let row = rows[0]
//            let default_value = row["default_value"] as? Bool ?? true
//            return default_value
            return true

        }
        
      
        
        return false
    }
    
    static func get_rules_for_user_has_group(user_id:Int) -> [ios_rule]
    {
        let sql = """
            SELECT ios_rule.* from relations
            INNER JOIN ios_rule
            on ios_rule.id  = relations.re_id2
            where re_table1_table2 = "ios_group|ios_rule"
            and re_id1 in (SELECT re_id1  as group_id from relations where re_table1_table2 = "ios_group|res_users" and re_id2  = \(user_id))
        """
        
        let cls = ios_rule(fromDictionary: [:])
        let rows =  cls.dbClass?.get_rows(sql: sql) ?? []
        var arr_rules:[ios_rule] = []

        if rows .count > 0
        {
            for rule in rows
            {
                let obj = ios_rule(fromDictionary: rule)
                obj.access = true
                arr_rules.append(obj)
            }
        }
        
      
        
        return arr_rules
    }
    
    static func get_rules_with_default_value() -> [ios_rule]
    {
        let sql = """
           SELECT ios_rule.* from ios_rule
        """
        var arr_rules:[ios_rule] = []

        let cls = ios_rule(fromDictionary: [:])
        let rows =  cls.dbClass?.get_rows(sql: sql) ?? []
        if rows.count > 0
        {
            for rule in rows
            {
                let obj = ios_rule(fromDictionary: rule)
//                if obj.default_value == true
//                {
                    obj.access = false
                    arr_rules.append(obj)
               // }
          
            }
 
        }
        
        return arr_rules
    }
    static func get_all_rules() -> [ios_rule]
    {
      
        var arr_rules:[ios_rule] = []
 
        for rule in rules.list
            {
                let obj = ios_rule(fromDictionary: rule)
//                if obj.default_value == true
//                {
                    obj.access = false
                    arr_rules.append(obj)
                //}
          
            }
  
        
        return arr_rules
    }
    
    
    static func access_rule(user_id:Int,key:rule_key) -> Bool {
        
      let activeCashier =  SharedManager.shared.activeUser()
        if activeCashier.id == user_id {
            return activeCashier.access_rules.first(where: {$0.key == key})?.access ?? false
        }else{
        
        let sql = """
            SELECT ios_rule.* from relations
            INNER JOIN ios_rule
            on ios_rule.id  = relations.re_id2
            where re_table1_table2 = "ios_group|ios_rule"
            and re_id1 in (SELECT re_id1  as group_id from relations where re_table1_table2 = "ios_group|res_users" and re_id2  = \(user_id))
            and ios_rule."key" = "\(key.rawValue)"
        """
        
        let cls = ios_rule(fromDictionary: [:])
        let rows =  cls.dbClass?.get_rows(sql: sql) ?? []
        if rows.count > 0
        {
//            let row = rows[0]
           // let default_value = row["default_value"] as? Bool ?? true
            
            
          //  return default_value
            return true
        }
        else
        {
            return false
            /*
            let has_group = check_user_has_group(user_id: user_id)
            if has_group == false
            {
                return get_default_rule(key: key)

            }
            else
            {
                return false
            }
             */
        }
        }
        
 
    }
    /*
    static func get_default_rule(key:rule_key) -> Bool {
        
        let sql = """
           SELECT ios_rule.* from ios_rule
            where  ios_rule."key" = "\(key.rawValue)"
        """
        
        let cls = ios_rule(fromDictionary: [:])
        let rows =  cls.dbClass?.get_rows(sql: sql) ?? []
        if rows.count > 0
        {
            let row = rows[0]
            let default_value = row["default_value"] as? Bool ?? true
            
            
            return default_value
 
        }
        
        
        
        return true
    }
    */
    
    static func check_access_rule(_ key:rule_key, for vc:UIViewController, title:String? = nil, completion:@escaping()->())  {
        
        
        #if DEBUG
       // return true

        #endif
    
    let user_id = SharedManager.shared.activeUser().id
    
        guard    access_rule(user_id: user_id, key: key) == true else {
           
               // messages.showAlert("You don't have permission to access".arabic("ليس لديك إذن للوصول"))
            SharedManager.shared.openPincode(for:vc,title: title,rule: key,completion: completion)

            return
        }
        
        completion()
    }
    
    static func check_access_rule_table(show_msg:Bool = true) -> Bool {
        let user_id = SharedManager.shared.activeUser().id
        let haveAccessSelectTable = access_rule(user_id: user_id, key: .select_table)
        let haveAccessCancelTable = access_rule(user_id: user_id, key: .cancle_table)
        let haveAccessChangeTable = access_rule(user_id: user_id, key: .change_table)
        
        if !haveAccessSelectTable && !haveAccessCancelTable && !haveAccessChangeTable {
                if show_msg == true
                {
                    messages.showAlert("You don't have permission to access Tables".arabic("ليس لديك إذن للوصول للطاولات"))

                }
            return false
        }
            return true

    }
    static func check_access_rule_select_change_table(show_msg:Bool = true) -> Bool {
        let user_id = SharedManager.shared.activeUser().id
        let haveAccessSelectTable = access_rule(user_id: user_id, key: .select_table)
        let haveAccessChangeTable = access_rule(user_id: user_id, key: .change_table)
        
        if !haveAccessSelectTable && !haveAccessChangeTable {
                if show_msg == true
                {
                    messages.showAlert("You don't have permission to access Tables".arabic("ليس لديك إذن للوصول للطاولات"))

                }
            return false
        }
            return true

    }
    
 
    
    
    
    
    
    
    
    
    
    
    
    
}
