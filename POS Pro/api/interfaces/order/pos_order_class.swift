//
//  oneOrderClass.swift
//  pos
//
//  Created by khaled on 8/21/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit
enum ORDER_INTEGRATION : Int{
    case NONE = 0
    case POS  = 1
    case ONLINE = 2
    case DELIVERY = 3
}
enum void_status_enum:Int{
    case none = 0,before_sent_to_kitchen,after_sent_to_kitchen,split_order,update_from_query,update_from_multi_session,insurance_order,discount_line_after,discount_line_before,cancel_customer,move_line,from_ip,cancel_delivery,zero_service_charge,none_account_journal
    func isNotVoidLogic() -> Bool{
        return self == .none || self == .after_sent_to_kitchen || self == .before_sent_to_kitchen || self == .update_from_multi_session
    }
    static func getNotVoidFromUIStatusQuery()->String{
        return "(" + void_status_enum.getNotVoidFromUIStatusRawValue().map({"\($0)"}).joined(separator: ", ") + ")"
    }
    static func getNotVoidFromUIStatusRawValue()->[Int]{
        return  void_status_enum.getNotVoidFromUIStatus().map({$0.rawValue})
    }
    static func getNotVoidFromUIStatus()->[void_status_enum]{
        var statusArray = [void_status_enum.split_order,.update_from_query,.insurance_order,.cancel_delivery,.none_account_journal]
        if SharedManager.shared.appSetting().enable_hide_void_before_line{
            statusArray.append(.before_sent_to_kitchen)
        }
        return  statusArray
    }
}
enum orderSyncType : Int{
    case order  = 0
    case scrap = 1
    case cash_in_out = 2
    case all = 3
}


enum orderMenuStatus : Int{
    case none  = 0
    case pendding = 1
    case accepted = 2
    case rejected = 3
    case time_out = 4
    case cancelling = 5
    case cancelled = 6

}

class pos_order_class: NSObject {
    
    var dbClass:database_class?
    
    var url:String = ""
    var header: [String: String] = [:]
    var response: [String: Any] = [:]
    var request: [String: Any] = [:]
    
    
    
    // IDS
    var id:Int?
    var sequence_number:Int = 0
    //    var sequence_number_server:Int = 0
    
    
    
    
    var session_id_server:Int?
    var session_id_local:Int?
    var parent_order_id:Int = 0
    
    var name:String? //  "name": "Order 00979-018-0007",
    var uid:String?  //   "uid": "00979-018-0007",
    
    
    var parent_order_id_server:String?
    
    
    // order option
    var is_closed:Bool = false
    var is_sync:Bool  = false
    var is_void:Bool  = false{
        didSet{
            if is_void{
            if self.void_status != void_status_enum.split_order
                && self.void_status != void_status_enum.update_from_query
                &&  self.void_status != void_status_enum.insurance_order && self.void_status != void_status_enum.move_line {
                if SharedManager.shared.appSetting().hide_sent_to_kitchen_btn{
                    if self.void_status == void_status_enum.none {
                        self.void_status = .before_sent_to_kitchen
                        return

                    }
                }
            if checISSendToMultisession(){
                if self.void_status != .before_sent_to_kitchen {
                    self.void_status = .after_sent_to_kitchen
                }
            }else{
                self.void_status = .before_sent_to_kitchen
            }
            }
        }else{
            self.void_status = void_status_enum.none

        }
        }
    }
 
    var order_menu_status:orderMenuStatus  = .none
    
    var order_sync_type:orderSyncType = orderSyncType.order
    
    
 
    var return_reason_id:Int?

    
    // price
    var previous_table_id:Int?

    var table_id:Int?
    var total_items:Double = 0
    var amount_tax:Double = 0
    var amount_paid:Double = 0
    var amount_return:Double = 0
    var amount_total:Double = 0
    var delivery_amount:Double = 0
    
    
    var note:String = ""
    
    var create_date : String?
    var write_date : String?
    var pos_multi_session_write_date : String?{
        didSet{
            print("pos_multi_session_write_date === \(pos_multi_session_write_date)")
        }
    }

    var floor_name: String?
    var table_name: String?
    
 
    // =============================
    var pos_id:Int?
    var user_id:Int?
    
    
    var create_user_id : Int?
    var write_user_id : Int?
    var create_pos_id : Int?
    var write_pos_id : Int?
    
    var create_user_name : String?
    var write_user_name : String?
    var create_pos_name : String?
    var write_pos_name : String?
    
    var write_pos_code : String?
    var create_pos_code : String?

    
    var partner_id:Int?
    var partner_row_id:Int?
    
    
    var company_id:Int?
    var pricelist_id:Int?
    var delivery_type_id:Int?
    var payment_journal_id:Int?
    
    var skip_order:Bool?
    
    
    var delivery_type_reference : String?

    
    // =============================
    var pos_order_lines:[pos_order_line_class]  = []
    
    var sequence_number_full:String
    {
        get
        {
            
            let split = self.uid?.split(separator: "-")
            if split?.count == 3
            {
                let full_seq = String( split![1] ) +  "-" + String( split![2])
                
                return full_seq
            }
            
            return String( sequence_number)
            
        }
    }
    
    var customer:res_partner_class?
    {
        get
        {
            if partner_id == -1 ||  partner_id == 0
            {
                return res_partner_class.get(row_id: partner_row_id)

            }
            else
            {
                return res_partner_class.get(partner_id: partner_id)

            }
        }
        
        set(new)
        {
            partner_id = new?.id
            partner_row_id = new?.row_id
        }
    }
    var driver_id:Int?
    var driver_row_id:Int?

    var driver:pos_driver_class?
    {
        get
        {
            if driver_id != 0 {
                return pos_driver_class.get(driver_id: driver_id)
            }
            return nil
        }
        
        set(new)
        {
            driver_id = new?.id
            driver_row_id = new?.row_id
        }
    }
    
    var cashier:res_users_class?
    {
        get
        {
            return res_users_class.get(id: user_id)
        }
        
        set(new)
        {
            user_id = new!.id
        }
    }
    
    
    var pos:pos_config_class?
    {
        get
        {
            return pos_config_class.getPos(posID: pos_id!)
        }
        
        set(new)
        {
            pos_id = new!.id
        }
    }
    
    
    var session:pos_session_class?
    {
        get
        {
            return pos_session_class.getSession(sessionID: session_id_local!)
        }
        
        set(new)
        {
            session_id_local = new!.id
        }
    }
    
    
    var priceList :product_pricelist_class?
    {
        get
        {
            return product_pricelist_class.get_pricelist(pricelist_id: pricelist_id)
        }
        
        set(new)
        {
            pricelist_id = new!.id
        }
    }
    var orderTypeCashing :delivery_type_class?

    var orderType :delivery_type_class?
    {
        get
        {
            if let orderTypeCashing = orderTypeCashing {
                return orderTypeCashing
            }
            orderTypeCashing = delivery_type_class.get(id: delivery_type_id)
            return orderTypeCashing
        }
        
        set(new)
        {
            orderTypeCashing = nil
            delivery_type_id = new?.id
        }
    }
    
    //    var discountProgram:pos_discount_program_class?
    //    {
    //        get
    //        {
    //            return pos_discount_program_class.get(id: discount_program_id ?? 0)
    //        }
    //
    //        set(new)
    //        {
    //            discount_program_id = new?.id
    //        }
    //    }
    
    var list_account_journal:  [account_journal_class] = []
    var kds_preparation_total_time:Int?

    // =============================
    // loyalty
    
    var loyalty_earned_point:Double = 0.0
    var loyalty_earned_amount:Double = 0.0
    var loyalty_redeemed_point:Double = 0.0
    var loyalty_redeemed_amount:Double = 0.0

    var loyalty_points_remaining_partner:Double = 0.0
    var loyalty_amount_remaining_partner:Double = 0.0
    
    // =============================
    // for ui
    var sub_orders:[pos_order_class]  = []
    
    var total_product_qty :[Int:Double] = [:]
    //    var total_product_count :[Int:Int] = [:]
    var  section_ids :[pos_order_line_class] =  []
    
    var sub_orders_count:Int = 0
    var promotion_code:String = ""
    var coupon_id: Int = 0
    var coupon_code: String = ""
    
    var options:ordersListOpetions?
    var void_status:void_status_enum?
    var brand_id:Int?
    var brand:res_brand_class?{
        get{
              return res_brand_class.get_brand(id: self.brand_id)
        }
    }
    var order_integration:ORDER_INTEGRATION = ORDER_INTEGRATION.POS
    var pos_order_integration:pos_order_integration_class?{
        return pos_order_integration_class.get(order_uid: self.uid ?? "")
    }
    var pickup_user_id:Int?{
        didSet{
            if let pickup_user_id = pickup_user_id, pickup_user_id != 0 {
                pickup_write_date =  baseClass.get_date_now_formate_datebase()
                pickup_write_user_id = pickup_user_id
            }
        }
    }
    var pickup_write_date:String?
    var pickup_write_user_id:Int?
    var membership_sale_order_id:Int?
    var guests_number:Int?
    var bill_uid:String?
    var recieve_date : String?
    var sent_ip_date : String?{
        didSet{
            print("sent_ip_date = \(sent_ip_date ?? "")")
        }
    }
    var l10n_sa_uuid:String?
    var l10n_sa_chain_index:Int?
    //rewardCode
    var reward_bonat_code:String?
    
    var table_control_by_user_id: Int?
    var table_control_by_user_name: String?
    var force_update_order_owner:Bool?
    var need_print_bill:Bool?
    var platform_name:String?

    override init(){
        super.init()
    }
    
    
    init(fromDictionary dictionary: [String:Any] , options_order:ordersListOpetions? = nil,needProduct:Bool = true ,for_ip:Bool = false){
        super.init()
        
        self.options = options_order
        
        id = dictionary["id"] as? Int ?? 0
        sequence_number = dictionary["sequence_number"] as? Int ?? 0
        guests_number = dictionary["guests_number"] as? Int 

        //        sequence_number_server = dictionary["sequence_number_server"] as? Int ?? 0
        
        
        
        return_reason_id = dictionary["return_reason_id"] as? Int ?? 0

        session_id_server = dictionary["session_id_server"] as? Int ?? 0
        session_id_local = dictionary["session_id_local"] as? Int ?? 0
        parent_order_id = dictionary["parent_order_id"] as? Int ?? 0
        
        create_user_id = dictionary["create_user_id"] as? Int ?? 0
        write_user_id = dictionary["write_user_id"] as? Int ?? 0
        create_pos_id = dictionary["create_pos_id"] as? Int ?? 0
        write_pos_id = dictionary["write_pos_id"] as? Int ?? 0
        sub_orders_count = dictionary["sub_orders_count"] as? Int ?? 0
        kds_preparation_total_time = dictionary["kds_preparation_total_time"] as? Int ?? 0

        
        
        create_user_name = dictionary["create_user_name"] as? String ?? ""
        write_user_name = dictionary["write_user_name"] as? String ?? ""
        create_pos_name = dictionary["create_pos_name"] as? String ?? ""
        write_pos_name = dictionary["write_pos_name"] as? String ?? ""
        
        write_pos_code = dictionary["write_pos_code"] as? String ?? ""
        create_pos_code = dictionary["create_pos_code"] as? String ?? ""

        table_name = dictionary["table_name"] as? String ?? ""
        floor_name = dictionary["floor_name"] as? String ?? ""
        
        name = dictionary["name"] as? String ?? ""
        uid = dictionary["uid"] as? String ?? ""
        
        parent_order_id_server = dictionary["parent_order_id_server"] as? String ?? ""
        
 
        
        is_closed = dictionary["is_closed"] as? Bool ?? false
        is_sync = dictionary["is_sync"] as? Bool ?? false
        is_void = dictionary["is_void"] as? Bool ?? false
        

        order_menu_status = orderMenuStatus.init(rawValue:  dictionary["order_menu_status"] as? Int ?? 0)!
        order_sync_type = orderSyncType.init(rawValue:  dictionary["order_sync_type"] as? Int ?? 0)!
        
        total_items = dictionary["total_items"] as? Double ?? 0
        amount_tax = dictionary["amount_tax"] as? Double ?? 0
        table_id = dictionary["table_id"] as? Int ?? 0
        amount_paid = dictionary["amount_paid"] as? Double ?? 0
        amount_return = dictionary["amount_return"] as? Double ?? 0
        amount_total = dictionary["amount_total"] as? Double ?? 0
        delivery_amount = dictionary["delivery_amount"] as? Double ?? 0
 
        loyalty_earned_point = dictionary["loyalty_earned_point"] as? Double ?? 0
        loyalty_earned_amount = dictionary["loyalty_earned_amount"] as? Double ?? 0
        loyalty_redeemed_point = dictionary["loyalty_redeemed_point"] as? Double ?? 0
        loyalty_redeemed_amount = dictionary["loyalty_redeemed_amount"] as? Double ?? 0
        loyalty_points_remaining_partner = dictionary["loyalty_points_remaining_partner"] as? Double ?? 0
        loyalty_amount_remaining_partner = dictionary["loyalty_amount_remaining_partner"] as? Double ?? 0

        
        note = dictionary["note"] as? String ?? ""
        create_date = dictionary["create_date"] as? String ?? ""
        write_date = dictionary["write_date"] as? String ?? ""
        pos_multi_session_write_date = dictionary["pos_multi_session_write_date"] as? String ?? ""
        
        pos_id = dictionary["pos_id"] as? Int ?? 0
        user_id = dictionary["user_id"] as? Int ?? 0
        partner_id = dictionary["partner_id"] as? Int ?? 0
        partner_row_id = dictionary["partner_row_id"] as? Int ?? 0
        
        driver_id = dictionary["driver_id"] as? Int ?? 0
        driver_row_id = dictionary["driver_row_id"] as? Int ?? 0

        company_id = dictionary["company_id"] as? Int ?? 0
        pricelist_id = dictionary["pricelist_id"] as? Int ?? 0
        delivery_type_id = dictionary["delivery_type_id"] as? Int ?? 0
        payment_journal_id = dictionary["payment_journal_id"] as? Int ?? 0
        //        discount_program_id = dictionary["discount_program_id"] as? Int ?? 0
        
        delivery_type_reference = dictionary["delivery_type_reference"] as? String ?? ""
        void_status = void_status_enum(rawValue:dictionary["void_status"] as? Int ?? 0)
        
        promotion_code = dictionary["promotion_code"] as? String ?? ""
        coupon_id = dictionary["coupon_id"] as? Int ?? 0
        coupon_code = dictionary["coupon_code"] as? String ?? ""
        brand_id = dictionary["brand_id"] as? Int ?? res_brand_class.getSelectedBrandIfEnableSetting()?.id
        pickup_user_id = dictionary["pickup_user_id"] as? Int ?? 0
        order_integration = ORDER_INTEGRATION(rawValue:dictionary["order_integration"] as? Int ?? 0) ?? ORDER_INTEGRATION.POS
        pickup_write_date = dictionary["pickup_write_date"] as? String
        pickup_write_user_id = dictionary["pickup_write_user_id"] as? Int
        membership_sale_order_id = dictionary["membership_sale_order_id"] as? Int
        bill_uid = dictionary["bill_uid"] as? String
        l10n_sa_uuid = dictionary["l10n_sa_uuid"] as? String
        l10n_sa_chain_index = dictionary["l10n_sa_chain_index"] as? Int
        platform_name = dictionary["platform_name"] as? String ?? ""


        recieve_date = dictionary["recieve_date"] as? String ?? ""
        sent_ip_date = dictionary["sent_ip_date"] as? String ?? ""
        reward_bonat_code = dictionary["reward_bonat_code"] as? String ?? ""
        table_control_by_user_id = dictionary["table_control_by_user_id"] as? Int
        previous_table_id = dictionary["previous_table_id"] as? Int
        table_control_by_user_name = dictionary["table_control_by_user_name"] as? String
        force_update_order_owner = dictionary["force_update_order_owner"] as? Bool
        need_print_bill = dictionary["need_print_bill"] as? Bool
        dbClass = database_class(table_name: "pos_order", dictionary: self.toDictionary(),id: id!,id_key:"id")
        
        if id != 0
        {
            orderTypeCashing = delivery_type_class.get(id: delivery_type_id)
            if needProduct{
                get_products()
            }
        }
    }
    
    func toDictionary() -> [String:Any]
    {
        var dictionary:[String:Any] = [:]
        
        dictionary["id"] = id
        dictionary["sequence_number"] = sequence_number
        dictionary["reward_bonat_code"] = reward_bonat_code

        //        dictionary["sequence_number_server"] = sequence_number_server
        
        dictionary["session_id_server"] = session_id_server
        dictionary["session_id_local"] = session_id_local
        dictionary["parent_order_id"] = parent_order_id
        dictionary["name"] = name
        dictionary["uid"] = uid
        dictionary["parent_order_id_server"] = parent_order_id_server
        dictionary["is_closed"] = is_closed
        dictionary["is_sync"] = is_sync
        dictionary["is_void"] = is_void
        
         dictionary["order_menu_status"] = order_menu_status.rawValue
        
        dictionary["order_sync_type"] = order_sync_type.rawValue
        dictionary["total_items"] = total_items
        dictionary["amount_tax"] = amount_tax
        dictionary["table_id"] = table_id
        dictionary["amount_paid"] = amount_paid
        dictionary["amount_return"] = amount_return
        dictionary["amount_total"] = amount_total
        dictionary["note"] = note
        dictionary["create_date"] = create_date
        dictionary["write_date"] = write_date
        dictionary["pos_id"] = pos_id
        dictionary["user_id"] = user_id
        dictionary["partner_id"] = partner_id ?? 0
        dictionary["partner_row_id"] = partner_row_id
        dictionary["company_id"] = company_id
        dictionary["pricelist_id"] = pricelist_id ?? 0
        dictionary["delivery_type_id"] = delivery_type_id
        dictionary["payment_journal_id"] = payment_journal_id
        //        dictionary["discount_program_id"] = discount_program_id
        dictionary["delivery_amount"] = delivery_amount
        //        dictionary["discount"] = discount
        dictionary["floor_name"] = floor_name
        dictionary["table_name"] = table_name
        dictionary["pos_multi_session_write_date"] = pos_multi_session_write_date

        
        dictionary["create_user_id"] = create_user_id
        dictionary["write_user_id"] = write_user_id
        dictionary["create_pos_id"] = create_pos_id
        dictionary["write_pos_id"] = write_pos_id
        
        dictionary["create_user_name"] = create_user_name
        dictionary["write_user_name"] = write_user_name
        dictionary["create_pos_name"] = create_pos_name
        dictionary["write_pos_name"] = write_pos_name
        dictionary["delivery_type_reference"] = delivery_type_reference
        dictionary["return_reason_id"] = return_reason_id
        
        dictionary["write_pos_code"] = write_pos_code
        dictionary["create_pos_code"] = create_pos_code
        dictionary["driver_id"] = driver_id
        dictionary["driver_row_id"] = driver_row_id

        dictionary["loyalty_earned_point"] = loyalty_earned_point
        dictionary["loyalty_earned_amount"] = loyalty_earned_amount
        dictionary["loyalty_redeemed_point"] = loyalty_redeemed_point
        dictionary["loyalty_redeemed_amount"] = loyalty_redeemed_amount

        dictionary["loyalty_points_remaining_partner"] = loyalty_points_remaining_partner
        dictionary["loyalty_amount_remaining_partner"] = loyalty_amount_remaining_partner
        dictionary["void_status"] = void_status?.rawValue
        dictionary["promotion_code"] = promotion_code
        dictionary["coupon_id"] = coupon_id
        dictionary["coupon_code"] = coupon_code
        dictionary["kds_preparation_total_time"] = kds_preparation_total_time
        dictionary["brand_id"] = brand_id
        dictionary["pickup_user_id"] = pickup_user_id
        dictionary["pickup_write_date"] = pickup_write_date
        dictionary["pickup_write_user_id"] = pickup_write_user_id

        dictionary["order_integration"] = order_integration.rawValue
        dictionary["membership_sale_order_id"] = membership_sale_order_id
        dictionary["guests_number"] = guests_number
        dictionary["bill_uid"] = bill_uid
        
        dictionary["recieve_date"] = recieve_date
        dictionary["sent_ip_date"] = sent_ip_date
        dictionary["l10n_sa_uuid"] = l10n_sa_uuid
        dictionary["l10n_sa_chain_index"] = l10n_sa_chain_index
        dictionary["previous_table_id"] = previous_table_id
        dictionary["platform_name"] = platform_name

        dictionary["table_control_by_user_id"] = table_control_by_user_id
        dictionary["table_control_by_user_name"] =  table_control_by_user_name
        dictionary["force_update_order_owner"] = force_update_order_owner
        dictionary["need_print_bill"] = need_print_bill
        return dictionary
    }
    
    
    func toJson() ->String
    {
        var dic = self.toDictionary()
        
        var arr_lines:[String] = []
        for line in pos_order_lines
        {
            var dic_line = line.toDictionary()
            
            var combo_lines:[String] = []
            if line.is_combo_line!
            {
                for line_combo in line.selected_products_in_combo {
                    combo_lines.append(line_combo.toDictionary().jsonString() ?? "")

                }
            }
            
            dic_line["lines"] = combo_lines
            arr_lines.append(dic_line.jsonString() ?? "")

            
        }
        
        dic["lines"] = arr_lines
        
        return dic.jsonString() ?? ""
    }
    
    func reloadOrder(with customOptions:ordersListOpetions? = nil)
    {
        if let customOptions = customOptions {
            self.options = customOptions
        }else{
            options = ordersListOpetions()
            options?.get_lines_void = true
            options?.parent_product = true
        }
       self.pos_order_lines.removeAll()
    
        get_products()
    }
    /*
    func multiBrandPrinter(line:pos_order_line_class,printedStatus:ptint_status_enum,isDeleted:Bool = false){
        let is_line_void_and_printed = (line.is_void ?? false) && (line.printed == .printed) && isDeleted
                if !is_line_void_and_printed {
                line.printed = printedStatus
                }
                if line.kitchen_status != .done
                {
                    line.kitchen_status = .send
                }
                
                if lst_printers.count  > 0 && multi_session_id == 0
                {
                    line.pos_multi_session_status = .sended_update_to_server
                }else{
                    line.pos_multi_session_status = .sending_update_to_server
                }
                line.pos_multi_session_write_date = baseClass.get_date_now_formate_datebase()
                line.last_qty = line.qty


                if line.is_combo_line == true
                {
                    for line_combo in line.selected_products_in_combo {
                        let is_line_combo_void_and_printed = (line_combo.is_void ?? false) && (line_combo.printed == .printed) && isDeleted

                        if lst_printers.count  > 0 && multi_session_id == 0
                        {
                            line_combo.pos_multi_session_status = .sended_update_to_server
                        }else{
                            line_combo.pos_multi_session_status = .sending_update_to_server
                        }
                        line_combo.pos_multi_session_write_date = baseClass.get_date_now_formate_datebase()
                        if !is_line_combo_void_and_printed {
                        line_combo.printed = printedStatus
                        }
                        line_combo.last_qty = line_combo.qty
                        if line_combo.kitchen_status != .done
                        {
                            line_combo.kitchen_status = .send
                        }
                        
                        _ = line_combo.save(write_info: false)
    }
                    */
    private func updatePosMultisessionStatus(isDeleted:Bool = false,_ reRead:Bool,_ printedStatus:ptint_status_enum,_ multi_session_id:Int,_ lst_printers:[[String:Any]]){
        if reRead
        {
            options = ordersListOpetions()
         options?.get_lines_void = true
         options?.parent_product = true

           self.pos_order_lines.removeAll()
        
            get_products()
        
        }
    

        for line in  self.pos_order_lines
        {
            let is_line_void_and_printed = (line.is_void ?? false) && (line.printed == .printed) && isDeleted
            if !is_line_void_and_printed {
                if SharedManager.shared.mwIPnetwork && SharedManager.shared.cannotPrintKDS(){
                    line.printed = .none
                }else{
                    line.printed = printedStatus
                }
            }
            if line.kitchen_status != .done
            {
                line.kitchen_status = .send
            }
            
            if lst_printers.count  > 0 && multi_session_id == 0
            {
                line.pos_multi_session_status = .sended_update_to_server
            }else{
                line.pos_multi_session_status = .sending_update_to_server
            }
            line.pos_multi_session_write_date = baseClass.get_date_now_formate_datebase()
            line.last_qty = line.qty


            if line.is_combo_line == true
            {
                for line_combo in line.selected_products_in_combo {
                    let is_line_combo_void_and_printed = (line_combo.is_void ?? false) && (line_combo.printed == .printed) && isDeleted

                    if lst_printers.count  > 0 && multi_session_id == 0
                    {
                        line_combo.pos_multi_session_status = .sended_update_to_server
                    }else{
                        line_combo.pos_multi_session_status = .sending_update_to_server
                    }
                    line_combo.pos_multi_session_write_date = baseClass.get_date_now_formate_datebase()
                    if !is_line_combo_void_and_printed {
                        if SharedManager.shared.mwIPnetwork && SharedManager.shared.cannotPrintKDS(){
                            line_combo.printed = .none
                        }else{
                            line_combo.printed = printedStatus
                        }
                    }
//                    line_combo.printed = printedStatus
                    line_combo.last_qty = line_combo.qty
                    if line_combo.kitchen_status != .done
                    {
                        line_combo.kitchen_status = .send
                    }
                    _ = line_combo.save(write_info: false)

                }
            }
            
            _ = line.save(write_info: false)
        }
    }
   private func sendToKDS(isDeleted:Bool = false,printAll:Bool = false,forceSend:Bool = false,reRead:Bool = true)
    {
        let lst_printers = restaurant_printer_class.getAll()
        let multi_session_id = SharedManager.shared.posConfig().multi_session_id  ?? 0
        let printedStatus : ptint_status_enum =  printAll == true ? .none : .printed
        let kitchen_status =  self.get_order_status()
        if kitchen_status == .changed || kitchen_status == .new || isDeleted == true || forceSend == true
        {
            updatePosMultisessionStatus(isDeleted:isDeleted,reRead,printedStatus,multi_session_id,lst_printers)
           
        }
        
        
        if self.orderType == nil
        {
            
            
            let defalut_orderType = delivery_type_class.getDefault()
            if defalut_orderType != nil
            {
                self.orderType = defalut_orderType
                
                
            }
            
        }
        
    }
    func save_and_send_to_kitchen(forceSend:Bool = false,printAll: Bool = false,isDeleted:Bool = false,reRead:Bool = true,with ipMessageType: IP_MESSAGE_TYPES,for targets:[DEVICES_TYPES_ENUM])  {
        
        sendToKDS(isDeleted:isDeleted,printAll: printAll, forceSend:forceSend,reRead:reRead)
        if SharedManager.shared.appSetting().enable_support_multi_printer_brands{
            self.save(write_info: true,write_date:false, re_calc: false)
        }else{
            self.save(write_info: true, re_calc: false)
        }
        
        
        if SharedManager.shared.mwIPnetwork {
            self.sent_order_via_ip(with: ipMessageType)
        }
        AppDelegate.shared.run_poll_send_local_updates(force: true)
        
        
        
    }
    
    func save(write_info:Bool = true,write_date:Bool = true,updated_session_status:updated_status_enum? = nil,kitchenStatus:kitchen_status_enum? = nil,re_calc:Bool = true)
    {
        if re_calc
        {
            calcAll()
            
 
        }
        
        
        if write_info == true
        {
            let user = SharedManager.shared.activeUser()
            self.write_user_id = user.id
            self.write_user_name = user.name
            
            let pos = SharedManager.shared.posConfig()
            self.write_pos_id = pos.id
            self.write_pos_name = pos.name
            self.write_pos_code = pos.code
            if write_date || (self.write_date ?? "").isEmpty {
            self.write_date = baseClass.get_date_now_formate_datebase()
            }
            
        }
        
        
        
        
        
        
        dbClass?.dictionary = self.toDictionary()
        dbClass?.id = self.id ?? 0
        dbClass?.insertId = false
        
        let row_id =  dbClass?.save() ?? 0
        if row_id != 0
        {
            self.id = row_id
        }
        
        save_products(updated_session_status:updated_session_status,kitchenStatus:kitchenStatus)
        save_bankStatement()
        
        if skip_order != nil , let currentID = self.id
        {
            relations_database_class(re_id1:currentID, re_id2: [0], re_table1_table2: "pos_order|skip_order").save()
        }
        if (bill_uid ?? "").isEmpty{
            self.setBill_uid()
        }
        if (l10n_sa_uuid ?? "").isEmpty{
            self.setl10n_sa_uuid()
        }
        if (l10n_sa_chain_index ?? -1 ) == -1{
            self.setl10n_sa_chain_index()
        }
        DispatchQueue.main.async {
            let peer = SharedManager.shared.multipeerSession()
            if peer != nil
            {
     
               let json = peer!.message?.build(order: self)
                peer!.send(json)
            }
        }
        
    }
    
    func saveLog()
    {
        var do_save = SharedManager.shared.appSetting().enable_log_sync_success_orders
        if !do_save{
            if let error = self.response["error"] as? [String:Any],
               let message_error = error["message"] as? String {
                 if message_error.lowercased().contains("server error"){
                    do_save = true
                }
            }
        }
        if !do_save{
            return
        }
        var dic :[String:Any] = [:]
        dic["url"] =   self.url
        dic["header"] =   self.header
        dic["request"] =   self.request
        dic["response"] =   self.response
        
        
        let key = "order " + self.name!
        let log = logClass.get(key: key, prefix: "pos_order" )
        log.data = dic.jsonString()
        log.row_id = self.id
        log.key = key
        log.prefix = "pos_order"
        
        log.save()
    }
    
    static func get(order_id:Int ,  options_order:ordersListOpetions? = nil   ) -> pos_order_class?
    {
        let cls = pos_order_class(fromDictionary: [:])
        let where_sql = " where id=\(order_id)   "
        
        
        let item  = cls.dbClass!.get_row(whereSql: where_sql)
        if item != nil
        {
            return pos_order_class(fromDictionary: item!,options_order:options_order )
        }
        
        return nil
    }
    
    static func get(uid:String ,  options_order:ordersListOpetions? = nil   ) -> pos_order_class?
     {
         let cls = pos_order_class(fromDictionary: [:])
         let where_sql = " where uid = '\(uid)'   "
         
         
         let item  = cls.dbClass!.get_row(whereSql: where_sql)
         if item != nil
         {
             return pos_order_class(fromDictionary: item!,options_order:options_order )
         }
         
         return nil
     }
    static func get(memberShip_id:Int ,  options_order:ordersListOpetions? = nil   ) -> pos_order_class?
     {
         let cls = pos_order_class(fromDictionary: [:])
         let where_sql = " where membership_sale_order_id = \(memberShip_id)   "
         
         
         let item  = cls.dbClass!.get_row(whereSql: where_sql)
         if item != nil
         {
             return pos_order_class(fromDictionary: item!,options_order:options_order )
         }
         
         return nil
     }
    
    
    func get_products()
    {
        fillPosOrderLines(list:&self.pos_order_lines, with :self.options)
        /*
        //        let sql = """
        //        select pos_order_line.*  FROM pos_order_line
        //        WHERE order_id= \(self.id!) and pos_order_line.is_void = 0 and is_scrap = 0 and parent_product_id = 0
        //        """
        var has_extra_product = ""

        if !(options?.has_extra_product ?? false){
            has_extra_product = " and pos_order_line.product_id not in ( SELECT  extra_product_id FROM  pos_config  where extra_fees = 1)"
        }
        var void_lines = "and pos_order_line.is_void = 0"
        if options?.get_lines_void == true
        {
            void_lines = ""
        }
        if options?.get_lines_void_from_ui == true
        {
            void_lines = "and pos_order_line.void_status  not in" + void_status_enum.getNotVoidFromUIStatusQuery()

//            void_lines = "and pos_order_line.void_status not in (3,4)"
        }
            
        if options?.get_lines_void_only == true
        {
             void_lines = "and pos_order_line.is_void = 1"
        }
        var get_lines_promotion_condation = ""
        if options?.get_lines_promotion == false {
            get_lines_promotion_condation = " and pos_promotion_id = 0"
        }
        
        var where_lines = ""
        
        if options?.parent_product != nil
        {
            if options?.parent_product == true
            {
                where_lines = "and parent_product_id = 0"
            }
            else
            {
                where_lines = "and parent_product_id != 0"
                
            }
        }
        
        if options?.get_lines_scrap != nil
        {
            if options?.get_lines_scrap == true
            {
                where_lines = where_lines + " and is_scrap = 1"
                
            }
            else
            {
                where_lines = where_lines + " and is_scrap = 0 "
                
            }
            
            
        }
        
        if options?.printed != nil
        {
            if options?.printed == true
            {
                where_lines = where_lines + " and printed = 1"
                
            }
            else
            {
                where_lines = where_lines + " and printed = 0 "
                
            }
            
            
        }
        
        
        var order_by = "order by id"
        
        if options?.lines_sort_by_category_asc != nil
        {
            
            if options?.lines_sort_by_category_asc == true
            {
                order_by =  " order by pos_category.sequence asc"
                
            }
            else
            {
                order_by =   " order by pos_category.sequence desc"
                
            }
            
        }
        
        if options?.order_by_products != nil
        {
            if options?.order_by_products == true
            {
                order_by = " order by pos_order_line.product_id  "
            }
        }
        
        
        
        let pos_id = SharedManager.shared.posConfig().id
        
//        let sql = """
//        select pos_order_line.*,pos_category.id as pos_categ_id ,pos_category.sequence as pos_category_sequence  FROM pos_order_line
//        inner join product_product  on  product_product.id  = pos_order_line.product_id
//        left join pos_category on  product_product.pos_categ_id = pos_category.id
//        WHERE
//        pos_order_line.product_id != ( select discount_program_product_id from pos_config where id = \(pos_id) )
//        and
//        order_id= \(self.id!) \(void_lines)  \(where_lines) \(order_by)
//        """
        
        let sql = """
        select pos_order_line.*,pos_category.id as pos_categ_id ,pos_category.sequence as pos_category_sequence  FROM pos_order_line
        inner join product_product  on  product_product.id  = pos_order_line.product_id
        left join pos_category on  product_product.pos_categ_id = pos_category.id
        WHERE
         pos_order_line.product_id not in ( select discount_program_product_id from pos_config where id = \(pos_id) )
         and
        pos_order_line.product_id not in ( SELECT  delivery_type.delivery_product_id from delivery_type where order_type = "delivery")
         and
        pos_order_line.product_id not in ( SELECT  delivery_type.tip_product_id from delivery_type WHERE  delivery_type.tip_product_id NOTNULL)
         and
        pos_order_line.product_id not in ( SELECT  delivery_type.service_product_id from delivery_type WHERE  delivery_type.service_product_id NOTNULL)
        \(has_extra_product)
        and order_id= \(self.id!) \(void_lines) \(get_lines_promotion_condation) \(where_lines) \(order_by)
        """
    
 
//       SharedManager.shared.printLog(sql)
 
        
        let arr = dbClass?.get_rows(sql: sql) ?? []
        
        total_product_qty.removeAll()
        //        total_product_count = 0
        section_ids.removeAll()
        
        let priceList = self.priceList
        for row in arr
        {
            let line = pos_order_line_class(fromDictionary: row)
            
            if line.discount != 0 && line.pos_promotion_id == 0
            {
                continue
            }
            
            if line.is_combo_line == true
            {
                if options?.get_lines_void == true
                {
                    line.selected_products_in_combo = pos_order_line_class.get_all_lines_in_combo(order_id: self.id!, product_id: line.product_id!,parent_line_id: line.id,get_lines_void_from_ui: options?.get_lines_void_from_ui)
                }
                else
                {
                    line.selected_products_in_combo = pos_order_line_class.get_lines_in_combo(order_id: self.id!, product_id: line.product_id!,parent_line_id: line.id)
                    
                }
                
                section_ids.append(line)
            }
            else
            {
                var last_value = 0.0 //total_product_qty[line.product_id!] ?? 0
                if last_value == 0
                {
                    section_ids.append(line)
                }
                
                
                last_value = last_value + line.qty
                total_product_qty[line.product_id!] = last_value
            }
            
            
            line.section = section_ids.count - 1
            
            line.priceList = priceList
            self.pos_order_lines.append(line)
        }
        */
        
    }
    func fillPosOrderLines( list:inout [pos_order_line_class], with optionsParam:ordersListOpetions?){
        list.removeAll()
        var optionsObj = optionsParam
        if optionsParam == nil {
            optionsObj = self.options
        }
        var has_extra_product = ""

        if !(optionsObj?.has_extra_product ?? false){
            has_extra_product = " and pos_order_line.product_id not in ( SELECT  extra_product_id FROM  pos_config  where extra_fees = 1)"
        }
        var void_lines = "and pos_order_line.is_void = 0"
        if optionsObj?.get_lines_void == true
        {
            void_lines = ""
        }
        if optionsObj?.get_lines_void_from_ui == true
        {
            void_lines = "and pos_order_line.void_status  not in" + void_status_enum.getNotVoidFromUIStatusQuery()

//            void_lines = "and pos_order_line.void_status not in (3,4)"
        }
            
        if optionsObj?.get_lines_void_only == true
        {
             void_lines = "and pos_order_line.is_void = 1"
        }
        var get_lines_promotion_condation = ""
        if optionsObj?.get_lines_promotion == false {
            get_lines_promotion_condation = " and pos_promotion_id = 0"
        }
        
        var where_lines = ""
        
        if optionsObj?.parent_product != nil
        {
            if optionsObj?.parent_product == true
            {
                where_lines = "and parent_product_id = 0"
            }
            else
            {
                where_lines = "and parent_product_id != 0"
                
            }
        }
        
        if optionsObj?.get_lines_scrap != nil
        {
            if optionsObj?.get_lines_scrap == true
            {
                where_lines = where_lines + " and is_scrap = 1"
                
            }
            else
            {
                where_lines = where_lines + " and is_scrap = 0 "
                
            }
            
            
        }
        
        if optionsObj?.printed != nil
        {
            if optionsObj?.printed == true
            {
                where_lines = where_lines + " and printed = 1"
                
            }
            else
            {
                where_lines = where_lines + " and printed = 0 "
                
            }
            
            
        }
        
        
        var order_by = "order by id"
        
        if optionsObj?.lines_sort_by_category_asc != nil
        {
            
            if optionsObj?.lines_sort_by_category_asc == true
            {
                order_by =  " order by pos_category.sequence asc"
                
            }
            else
            {
                order_by =   " order by pos_category.sequence desc"
                
            }
            
        }
        
        if optionsObj?.order_by_products != nil
        {
            if optionsObj?.order_by_products == true
            {
                order_by = " order by pos_order_line.product_id  "
            }
        }
        
        guard self.id != nil else { return }
        
        
        let pos_id = SharedManager.shared.posConfig().id
        
//        let sql = """
//        select pos_order_line.*,pos_category.id as pos_categ_id ,pos_category.sequence as pos_category_sequence  FROM pos_order_line
//        inner join product_product  on  product_product.id  = pos_order_line.product_id
//        left join pos_category on  product_product.pos_categ_id = pos_category.id
//        WHERE
//        pos_order_line.product_id != ( select discount_program_product_id from pos_config where id = \(pos_id) )
//        and
//        order_id= \(self.id!) \(void_lines)  \(where_lines) \(order_by)
//        """
        
        let sql = """
        select pos_order_line.*,pos_category.id as pos_categ_id ,pos_category.sequence as pos_category_sequence  FROM pos_order_line
        inner join product_product  on  product_product.id  = pos_order_line.product_id
        left join pos_category on  product_product.pos_categ_id = pos_category.id
        WHERE
         pos_order_line.product_id not in ( select discount_program_product_id from pos_config where id = \(pos_id) )
         and
        pos_order_line.product_id not in ( SELECT  delivery_type.delivery_product_id from delivery_type where order_type = "delivery")
         and
        pos_order_line.product_id not in ( SELECT  delivery_type.tip_product_id from delivery_type WHERE  delivery_type.tip_product_id NOTNULL)
         and
        pos_order_line.product_id not in ( SELECT  delivery_type.service_product_id from delivery_type WHERE  delivery_type.service_product_id NOTNULL)
        \(has_extra_product)
        and order_id= \(self.id!) \(void_lines) \(get_lines_promotion_condation) \(where_lines) \(order_by)
        """
    
 
//       SharedManager.shared.printLog(sql)
 
        
        let arr = dbClass?.get_rows(sql: sql) ?? []
        
        total_product_qty.removeAll()
        //        total_product_count = 0
        section_ids.removeAll()
        
        let priceList = self.priceList
        for row in arr
        {
            let line = pos_order_line_class(fromDictionary: row)
            
            if line.discount != 0 && line.pos_promotion_id == 0
            {
                continue
            }
            
            if line.is_combo_line == true
            {
                if optionsObj?.get_lines_void == true
                {
                    line.selected_products_in_combo = pos_order_line_class.get_all_lines_in_combo(order_id: self.id!, product_id: line.product_id!,parent_line_id: line.id,get_lines_void_from_ui: options?.get_lines_void_from_ui)
                }
                else
                {
                    line.selected_products_in_combo = pos_order_line_class.get_lines_in_combo(order_id: self.id!, product_id: line.product_id!,parent_line_id: line.id)
                    
                }
                
                section_ids.append(line)
            }
            else
            {
                var last_value = 0.0 //total_product_qty[line.product_id!] ?? 0
                if last_value == 0
                {
                    section_ids.append(line)
                }
                
                
                last_value = last_value + line.qty
                total_product_qty[line.product_id!] = last_value
            }
            
            
            line.section = section_ids.count - 1
            
            line.priceList = priceList
            list.append(line)
        }
    }
    
    
    func save_bankStatement()
    {
        if self.id == 0
        {
            return
        }
        
        if get_bankStatement().count > 0
        {
            return
        }
        
        
        for account in self.list_account_journal
        {
            let cls = pos_order_account_journal_class(fromDictionary: [:])
            cls.mean_code = account.getPaymentMean()
            cls.account_Journal_id = account.id
            cls.order_id = self.id
            cls.changes = account.changes
            cls.tendered = account.tendered
            cls.due = account.due
            cls.rest = account.rest
            cls.save()
        }
    }
    
    func get_bankStatement() ->  [pos_order_account_journal_class]
       {
           if let id = self.id {
               return pos_order_account_journal_class.get(order_id: self.id!) ?? []
           }
           return []
       }
       
    
    func get_account_journal() ->  [account_journal_class]
    {
        var list:[account_journal_class] = []
        let statments:[pos_order_account_journal_class] = self.get_bankStatement()
        for cls in statments
        {
            let account = account_journal_class.get(id: cls.account_Journal_id)!
            account.id = cls.account_Journal_id
            account.changes =  cls.changes!
            account.tendered =  cls.tendered!
            account.due =  cls.due!
            account.rest = cls.rest!
           
            
            list.append( account)
            
        }
        
        return list
    }
    
    func save_products(updated_session_status:updated_status_enum? = nil,kitchenStatus:kitchen_status_enum? = nil)
    {
        if self.id == 0
        {
            return
        }
        
        for p in pos_order_lines
        {
            
            if p.product_id == 0
            {
                assert( p.product_id == 0 ,"must not be happen")
                
            }
            
            p.order_id = self.id!
            
            
            let  line_id = p.save(write_info:p.write_info,updated_session_status: updated_session_status,kitchenStatus:kitchenStatus)
            //           _ =  save_product(product: p )
            
            if p.selected_products_in_combo.count > 0
            {
                for p_in_combo in p.selected_products_in_combo
                {
                    p_in_combo.is_combo_line = true
                    p_in_combo.parent_line_id = line_id
                    p_in_combo.order_id = self.id!
                    _ = p_in_combo.save(write_info:p_in_combo.write_info,updated_session_status: updated_session_status,kitchenStatus:kitchenStatus)
                    // _ =  save_product(product: p_in_combo,parent_product_id: p.id,extra_price: p_in_combo.comob_extra_price )
                }
            }
        }
        
        //        for p in products_void
        //          {
        //            _ =  save_product(product: p,   is_void: true)
        //          }
        //
        
    }
    
    
    //    func save_product(product:product_product_class,parent_product_id:Int=0 , extra_price:Double = 0) -> Int
    //    {
    //        let line = pos_order_line_class.get(order_id: self.id!, product_id:  product.id) ??  pos_order_line_class(fromDictionary: [:])
    //        line.order_id  = self.id!
    //        line.product_id = product.id
    //        line.parent_product_id = parent_product_id
    //        line.qty = product.qty_app
    //        line.price_unit = product.price_app_priceList
    //        line.price_subtotal = product.tax_total_excluded_app
    //        line.price_subtotal_incl = product.tax_total_included_app
    //        line.discount = product.discount
    //        line.is_combo_line = product.is_combo
    //        line.is_void = product.is_void
    //        line.extra_price = extra_price
    //        line.combo_id = product.combo?.id
    //        line.auto_select_num = product.auto_select_num
    //         return line.save()
    //    }
    
    
}

extension pos_order_class
{
    
    //    func get_total()-> Double
    //    {
    //        var total = 0.0 // self.orderType?.delivery_amount ?? 0
    //        total = total + self.amount_total
    //
    //        return total
    //    }
    
    
    func clacTotalItems() -> Double {
        
        var count_total:Double = 0
        
        
        //        if  products.count > 0
        //        {return count_total}
        
        for line in  pos_order_lines
        {
            if line.is_void == false
            {
                count_total = count_total +  abs(line.qty)
                
            }
        }
        
        return (  count_total)
    }
    
    //    func subTotal()->Double   {
    //
    //        var total:Double = 0
    //
    //        for product in pos_order_lines {
    //
    //            //            let product = productClass(fromDictionary: item  )
    //
    //            total = total + product.calcTotal(price: product.price_based_on_priceList)
    //
    //        }
    //
    //        return total
    ////        return 0
    //    }
    
    func clacTaxes(lines:[pos_order_line_class],
                   line_discount_program:pos_order_line_class? = nil,service_charge_line:pos_order_line_class? = nil)-> (total_included:Double ,total_excluded:Double,tax_amount:Double )   {
        
        
        
        var total_included:Double = 0
        var total_excluded:Double = 0
        var tax_amount:Double = 0
        var line_discount_program = line_discount_program
        var service_charge_line = service_charge_line
        
        for line in lines {
            if line.is_void == false
            {
                if (line.discount != 0 && line.discount_type == .percentage) || (line.parent_line_id != 0) //&& line.pos_promotion_id == 0
                {
                    continue
                }
                
                
                
                total_included = total_included +   line.price_subtotal_incl!
                total_excluded = total_excluded +   line.price_subtotal!
                
                if line.is_combo_line == true
                {
                    for combo_line in line.selected_products_in_combo
                    {
                        if (combo_line.extra_price ?? 0 ) != 0
                        {
                            //Bug calculate order void line after add and void lines
                            //check if has promotion
                            //else check if not void
                            if (combo_line.pos_promotion_id == 0 && combo_line.is_void == false) || combo_line.pos_promotion_id != 0 {
                                total_included = total_included +   combo_line.price_subtotal_incl!
                                total_excluded = total_excluded +   combo_line.price_subtotal!
                            }
                        }
                        
                    }
                }
                
            }
        }
        
        // recal discount percentage
        var disscountPrecentageValue = 0.0
        if line_discount_program != nil && total_included != 0
        {
            if line_discount_program!.discount != 0 && line_discount_program!.discount_type == .percentage
            {
                disscountPrecentageValue = line_discount_program?.discount ?? 0.0
                // WARNING : -
                // TODO: - NEED TO Check discount program ids default values from company as odoo issue required from Omar
                /*if let current_taxes_ids = line_discount_program?.product.get_taxes_id(),
                 current_taxes_ids.count <= 0 {
                 if let default_taxes_ids = SharedManager.shared.posConfig().company.account_sale_tax_id,
                 let product_id = line_discount_program?.product_id {
                 relations_database_class(re_id1: product_id , re_id2: [default_taxes_ids], re_table1_table2: "products|taxes_id").save()
                 }
                 }*/
                //                var discount_value:Double  =  (total_included  * line_discount_program!.discount!) / 100
                let discount_value = get_discount_percentage_value(percentage_value: line_discount_program!.discount! )
                
                let price_subtotal_incl = discount_value.price_subtotal_incl * -1
                
                line_discount_program!.custom_price = price_subtotal_incl
                line_discount_program!.price_unit = price_subtotal_incl
                line_discount_program!.price_subtotal_incl = price_subtotal_incl
                
                //                line_discount_program!.update_values()
                
                line_discount_program?.price_subtotal = discount_value.price_subtotal * -1
                line_discount_program?.discount = disscountPrecentageValue
                var price_include = true
                let taxes =  line_discount_program!.product.get_taxes_id(posLine:line_discount_program )
                if taxes.count > 0
                {
                    let tax = taxes[0]
                    let clsTax:account_tax_class! = account_tax_class.get(tax_id: tax )
                    if clsTax.price_include == false
                    {
                        price_include = false
                    }
                    
                }
                
                if price_include == false
                {
                    let price_unit =  line_discount_program!.price_unit
                    let price_subtotal = line_discount_program!.price_subtotal
                    //                    let price_subtotal_incl = line_discount_program!.price_subtotal_incl
                    
                    
                    line_discount_program!.price_subtotal_incl = price_unit
                    line_discount_program!.price_unit = price_subtotal
                    line_discount_program!.price_subtotal = price_subtotal
                }
                
                
                
                _ =  line_discount_program!.save(write_info: true, updated_session_status: .last_update_from_local)
                
                total_included = total_included +    line_discount_program!.price_subtotal_incl!
                total_excluded = total_excluded +    line_discount_program!.price_subtotal!
            }
        }else{
            if line_discount_program == nil
            {
                line_discount_program?.custom_price = 0
                line_discount_program?.is_void = true
                line_discount_program?.update_values()
                _ = line_discount_program?.save()
            }
        }
        
        
        
        
        // ==================================
        let pos = SharedManager.shared.posConfig()
        let order_type = self.orderType
        var delivery_fees = 0.0
         if total_included == 0{
            if service_charge_line != nil
            {
                self.void_service_charge()

//                service_charge_line?.custom_price = 0
//                service_charge_line?.is_void = true
//                service_charge_line?.update_values()
//                _ = service_charge_line?.save()
            }
        }else{
        if let serviceChargeProductID = order_type?.service_product_id, let chargePrecentValue =  order_type?.service_charge,  chargePrecentValue > 0 {
            var multiPlyTax = Double((1 + Double(SharedManager.shared.getTaxValueInvoice())/100))
            if total_excluded == total_included {
                multiPlyTax = 1
            }
            let serviceChargeAmount = chargePrecentValue * total_excluded * multiPlyTax// price without tax

            if serviceChargeAmount <= 0{
                self.void_service_charge()
            }else{
                
                if let service_charge_line = service_charge_line{
                    //                let total_w_o_service = total_included - (service_charge_line.price_subtotal_incl ?? 0)
                    //                let serviceChargeAmount = chargePrecentValue * total_w_o_service
                    service_charge_line.custom_price = serviceChargeAmount
                    service_charge_line.product_id = serviceChargeProductID
                    service_charge_line.is_void = false
                    service_charge_line.update_values()
                    _ = service_charge_line.save()
                    
                    total_included = total_included +  service_charge_line.price_subtotal_incl!
                    total_excluded = total_excluded +  service_charge_line.price_subtotal!
                    
                    
                }else{
                    if let orderID = self.id,
                       let productSevice = product_product_class.get(id:serviceChargeProductID ){
                        var service_charge_line = pos_order_line_class.create(order_id: orderID, product:productSevice )
                        service_charge_line.custom_price = serviceChargeAmount
                        service_charge_line.product_id = serviceChargeProductID
                        service_charge_line.is_void = false
                        service_charge_line.update_values()
                        _ = service_charge_line.save()
                        
                        total_included = total_included +  service_charge_line.price_subtotal_incl!
                        total_excluded = total_excluded +  service_charge_line.price_subtotal!
                        
                    }
                    
                }
            }
        }
        }
        if order_type?.order_type == "delivery"
        {
            if ((customer?.pos_delivery_area_id ?? 0) != 0) {
                if let pos_delivery_area_id = customer?.pos_delivery_area_id,
                   let delivery_area = pos_delivery_area_class.getBy(id: pos_delivery_area_id){
                    
                    let line = pos_order_line_class.get(order_id:  self.id!, product_id: delivery_area.delivery_product_id)
                    if line != nil
                    {
                        delivery_fees = line!.price_subtotal_incl!
                        total_included = total_included +  line!.price_subtotal_incl!
                        total_excluded = total_excluded +  line!.price_subtotal!
                    }
                }
            }else{
                //            let delivery_product = product_product_class.get(id: self.orderType!.delivery_product_id)
                let amoutDeliveryFes = self.orderType?.delivery_amount ?? 0.0
                let line = pos_order_line_class.get(order_id:  self.id!, product_id: order_type!.delivery_product_id)
                if line != nil
                {
                    
                    line?.custom_price = amoutDeliveryFes
                    line!.is_void = false
                    line!.update_values()
                    _ = line!.save()
                    
                    
                    //            let line = pos_order_line_class(fromDictionary: [:])
                    //            line.product_id = order_type!.delivery_product_id
                    //            line.update_values()
                    
                    delivery_fees = line!.price_subtotal_incl!
                    total_included = total_included +  line!.price_subtotal_incl!
                    total_excluded = total_excluded +  line!.price_subtotal!
                    //            tax_amount = tax_amount +  self.orderType!.delivery_product!.tax_amount_app
                }else{
                    if SharedManager.shared.mwIPnetwork{
                        
                    }
                }
            }
            
        }
        //TODO: - line_extra_fees
        
        
        if  let extra_product_id =  pos.extra_product_id, pos.extra_fees // order_type?.order_type == "extra" ||
        {
            let min_fess = pos.minimum_fees
            let min_item_price = pos.minimum_item_price
            //            var extra_amount = total_included - delivery_fees
            //              extra_amount = ((extra_amount * Double( pos.extra_percentage!)) / 100 )
            var lines_extra_fees = self.pos_order_lines.filter({!($0.is_void ?? false) && $0.product.allow_extra_fees})
            let addon_extra_fees =  self.pos_order_lines.flatMap({$0.selected_products_in_combo}).filter({!($0.is_void ?? false) && $0.product.allow_extra_fees})
            lines_extra_fees.append(contentsOf: addon_extra_fees)
            let line_extra_fees = pos_order_line_class.get(order_id:  self.id!, product_id: extra_product_id)
            if lines_extra_fees.count > 0 {
                var extra_fees_price_unite = lines_extra_fees.compactMap({
                    let qty = $0.qty ?? 0.0
                    let priceUnitItem = $0.price_unit ?? 0.0
                    let priceItem = $0.price_subtotal_incl ?? 0.0
                    if let minItemPrice = min_item_price,let min_fess = min_fess , priceUnitItem <= minItemPrice{
                        return min_fess * qty
                    }
                    return priceItem
                    
                }).reduce(0.0, +)
                /*
                 if disscountPrecentageValue > 0 {
                 extra_fees_price_unite = extra_fees_price_unite - (extra_fees_price_unite * (disscountPrecentageValue / 100))
                 }else{
                 if let discount_program_product_id = pos.discount_program_product_id,
                 let discountLine =
                 self.pos_order_lines.filter({!($0.is_void ?? false) && $0.product_id == discount_program_product_id}).first{
                 disscountPrecentageValue = discountLine.discount_extra_fees ?? 0.0
                 extra_fees_price_unite = extra_fees_price_unite - (extra_fees_price_unite * (disscountPrecentageValue / 100))
                 }
                 }
                 */
                let extra_percentage = Double( pos.extra_percentage!) / 100
                extra_fees_price_unite = extra_fees_price_unite * extra_percentage
                //              extra_amount = ((extra_amount * Double( pos.extra_percentage!)) / 100 )
                
                //            let extra_fees_price_subtotal_incl = lines_extra_fees.map{ $0.price_subtotal_incl }.reduce(0, +)
                //            let extra_fees_price_subtotal = lines_extra_fees.map{ $0.price_subtotal }.reduce(0, +)
                
                if line_extra_fees != nil
                {
                    
                    line_extra_fees!.custom_price =  extra_fees_price_unite
                    line_extra_fees!.void_status = .none
                    line_extra_fees!.is_void = false
                    
                    line_extra_fees!.update_values()
                    _ = line_extra_fees!.save(write_info: true, updated_session_status: .last_update_from_local)
                    
                    total_included = total_included +  line_extra_fees!.price_subtotal_incl!
                    total_excluded = total_excluded +  line_extra_fees!.price_subtotal!
                }
                else
                {
                    let product = product_product_class.get(id:  pos.extra_product_id!)
                    if product != nil
                    {
                        
                        let  d_product = pos_order_line_class.create(order_id: self.id!, product: product!)
                        
                        d_product.custom_price =  extra_fees_price_unite
                        d_product.product_id = pos.extra_product_id!
                        d_product.is_void = false
                        d_product.update_values()
                        _ = d_product.save()
                        
                        total_included = total_included +  d_product.price_subtotal_incl!
                        total_excluded = total_excluded +  d_product.price_subtotal!
                        
                    }
                }
            }else{
                //line_extra_fees
                if let line_extra_fees_not_null = line_extra_fees {
                    line_extra_fees_not_null.custom_price =  0.0
                    line_extra_fees_not_null.void_status = .split_order
                    line_extra_fees_not_null.is_void = true
                    line_extra_fees_not_null.update_values()
                    _ = line_extra_fees_not_null.save(write_info: true, updated_session_status: .last_update_from_local)
                    total_included = total_included +  line_extra_fees_not_null.price_subtotal_incl!
                    total_excluded = total_excluded +  line_extra_fees_not_null.price_subtotal!
                }
            }
        }
        
 
//        total_included = total_included + extra_price
//        total_excluded = total_excluded + extra_price

        
        tax_amount = total_included - total_excluded
        
        
        return (total_included,total_excluded,tax_amount)
        
    }
    func remove_line_extra_fees(_ lines:[pos_order_line_class]) -> [pos_order_line_class]{
        var all_lines = lines
        
        let pos = SharedManager.shared.posConfig()
        if  let extra_product_id =  pos.extra_product_id, pos.extra_fees // order_type?.order_type == "extra" ||
        {
            all_lines.removeAll(where: {$0.product_id == extra_product_id})
        }
        return all_lines
        
    }
    
    func remove_get_line_service_charge(_ lines:[pos_order_line_class]) -> (filterLines:[pos_order_line_class],serviceLine:pos_order_line_class?){
        var all_lines = lines
        var line_service_product:pos_order_line_class? = nil
        if let orderType = self.orderType{
            let orderTypeID = orderType.id
            let serviceProduct_id = orderType.service_product_id //4 delivery_type_class.getServiceChargeProduct(for: orderTypeID).service_product_id
            if serviceProduct_id != 0 {
                if let lineServiceProduct = pos_order_line_class.get(order_id:  self.id!, product_id: orderType.service_product_id)
                {
                    line_service_product = lineServiceProduct
                    all_lines.removeAll(where:{ $0.product_id == (serviceProduct_id) } )
                    
                }
            }
        }
        return (all_lines,line_service_product)
        
    }
    
    func get_discount_percentage_value( percentage_value:Double) -> (price_subtotal:Double,price_subtotal_incl:Double)
    {
        var total_price_subtotal_incl:Double  = 0
        var total_price_subtotal:Double  = 0
        
        
        for line in self.pos_order_lines
        {
            if line.isInsuranceLine() == true
            {
                continue
            }
            if line.is_void == true
            {
                continue
            }
            if line.parent_line_id != 0
            {
                continue
            }
            if line.discount != 0 && line.discount_type == .percentage
            {
                continue
            }
            
            let price_subtotal_incl = line.price_subtotal_incl
            
            let percentage_subtotal_incl = (price_subtotal_incl! * percentage_value) / 100
            total_price_subtotal_incl = total_price_subtotal_incl + percentage_subtotal_incl
            
            let price_subtotal  = line.price_subtotal
            let percentage_subtotal = (price_subtotal! * percentage_value) / 100
            total_price_subtotal = total_price_subtotal + percentage_subtotal
            
            if line.is_combo_line!
            {
                for sub_line in line.selected_products_in_combo.filter({($0.price_subtotal_incl ?? 0.0) > 0})
                {
                    let price_subtotal_incl = sub_line.price_subtotal_incl
                    let sub_percentage = (price_subtotal_incl! * percentage_value) / 100
                    total_price_subtotal_incl = total_price_subtotal_incl + sub_percentage
                    
                    
                    let price_subtotal = sub_line.price_subtotal
                    let sub_percentage2 = (price_subtotal! * percentage_value) / 100
                    total_price_subtotal = total_price_subtotal + sub_percentage2
                    
                }
            }
        }
        
        return (total_price_subtotal,total_price_subtotal_incl )
    }
    
    
    func get_discount_line()->pos_order_line_class?
    {
        let pos = SharedManager.shared.posConfig()
        
        guard let _ = self.id else {
            return nil
        }
        
        guard let discount_program_product_id = pos.discount_program_product_id else {
            return nil
        }
        
        
        
        let line = pos_order_line_class.get(order_id: self.id!, product_id: discount_program_product_id,is_void: false)
        //        if line?.is_void == true
        //        {
        //            return nil
        //        }
        
        return line
    }
    
    func void_delivery_area_line(_ cancelCustomer:res_partner_class?,voidState:void_status_enum? = .cancel_customer)
    {
        guard let cancelCustomer = cancelCustomer else {return}
        if self.id == nil
        {
            return
        }
        if cancelCustomer.pos_delivery_area_id == 0
        {
            return
        }
        var line:pos_order_line_class? = nil
        let pos_delivery_area_id = cancelCustomer.pos_delivery_area_id
        if let delivery_area = pos_delivery_area_class.getBy(id: pos_delivery_area_id){
            if self.pos_order_lines.contains(where: {$0.product_id == delivery_area.delivery_product_id }) {
                line = pos_order_line_class.get(order_id:  self.id ?? 0, product_id: delivery_area.delivery_product_id)
                self.pos_order_lines.removeAll(where: {$0.product_id == delivery_area.delivery_product_id })
            }
        }
        if line != nil {
            line?.is_void = true
            if let voidState = voidState{
                line?.void_status = voidState
            }
            line?.save(write_info: true)
        }else{
            let deliveryLine = self.get_delivery_line()
            deliveryLine?.is_void = true
            if let voidState = voidState{
                deliveryLine?.void_status = voidState
            }
            deliveryLine?.save(write_info: true)
        }
        /*
        if let orderTypeID = self.orderType?.id {
        let delivery_id = delivery_type_class.getDeliveryProduct(for: orderTypeID)
            if self.pos_order_lines.contains(where: {$0.product_id == delivery_id.delivery_product_id }) {
                line = pos_order_line_class.get(order_id: self.id!, product_id: delivery_id.delivery_product_id,is_void: false)
                self.pos_order_lines.removeAll(where: {$0.product_id == delivery_id.delivery_product_id })
            }
        }
        */
       
    }
    func get_delivery_line(wtCheckArea:Bool = true)->pos_order_line_class?
    {
 
        if self.id == nil
        {
            return nil
        }
        if wtCheckArea{
            if let pos_delivery_area_id = customer?.pos_delivery_area_id,
               let delivery_area = pos_delivery_area_class.getBy(id: pos_delivery_area_id){
                return pos_order_line_class.get(order_id:  self.id ?? 0, product_id: delivery_area.delivery_product_id)
                
            }
        }
        if let orderTypeID = self.orderType?.id {
            
        let delivery_id = delivery_type_class.getDeliveryProduct(for: orderTypeID)
        
         
        let line = pos_order_line_class.get(order_id: self.id!, product_id: delivery_id.delivery_product_id,is_void: false)
 
        
        return line
        }
        return nil
    }
    func get_service_charge_line(for productID:Int? = nil)->pos_order_line_class?
    {
        if self.id == nil
        {
            return nil
        } 
        if let productID = productID {
            return pos_order_line_class.get(order_id:  self.id!, product_id: productID)
        }else{
            if let orderType = self.orderType{
                let orderTypeID = orderType.id
                let serviceProduct_id = orderType.service_product_id
                if serviceProduct_id != 0 {
                    return pos_order_line_class.get(order_id:  self.id!, product_id: orderType.service_product_id)
                }
            }
        }
        return nil
    }
    func void_service_charge(){
        if let serviceLine = self.get_service_charge_line(){
            serviceLine.is_void = true
            serviceLine.void_status = .zero_service_charge
            serviceLine.save()
        }
    }
    
    func is_have_extra_fees() -> pos_order_line_class?
  {
      
     // return (self.pos_order_lines ).filter({($0.product_id ?? 0) == SharedManager.shared.posConfig().extra_product_id}).first
      
      let cls = pos_order_line_class(fromDictionary: [:])
      let sql = "  where  order_id = \(self.id ?? 0) and is_void = 0 and product_id in (\(SharedManager.shared.posConfig().extra_product_id ?? 0))"
      
        let items  = cls.dbClass!.get_rows(whereSql: sql)
        
        if (items.count > 0 )
        {
            return pos_order_line_class(fromDictionary: items[0])
        }
       

        return nil
      
    
  }
    
      func is_have_promotions(   ) -> Bool
    {
        let cls = pos_order_line_class(fromDictionary: [:])
        let where_sql = "select count(*) from pos_order_line  where pos_promotion_id != 0 and order_id = \(self.id ?? 0) and is_void = 0"
        
        
        
        let cnt  = cls.dbClass!.get_count(sql: where_sql)
        if cnt > 0
        {
            return true
        }
        
        return false
    }
    
    
    func check_discount()
    {
        
        /*
         if self.discount_program_id != 0
         {
         
         if self.discountProgram!.amount != 0 && self.discountProgram!.discount_product != nil
         {
         let pos = SharedManager.shared.posConfig()
         //                       let product = product_product_class.get(id: pos.discount_program_product_id!)
         
         let line_discount = pos_order_line_class(fromDictionary: [:])
         line_discount.product_id = pos.discount_program_product_id!
         
         if self.discountProgram!.dicount_type == "fixed"
         {
         
         line_discount.product_lst_price  = (-1) * self.discountProgram!.amount
         line_discount.update_values()
         
         }
         else  if self.discountProgram!.dicount_type == "percentage"
         {
         /*
         self.discountProgram.discount_product?.price_app_priceList   =   (-1) * ( ( self.discountProgram.amount *  self.amount_total ) / 100)
         self.discountProgram.discount_product?.tax_amount_app  =   (-1) * ( ( self.discountProgram.amount *  self.tax_order ) / 100)
         
         self.discountProgram.discount_product?.tax_total_included_app   =   (-1) * ( ( self.discountProgram.amount *   total.total_excluded ) / 100)
         
         let pre_tax = (self.tax_order * self.discountProgram.amount) / 100
         
         self.discountProgram.discount_product?.tax_total_excluded_app =   self.discountProgram.discount_product!.tax_total_included_app  + pre_tax
         */
         
         //                        SharedManager.shared.printLog(self.discountProgram.discount_product?.tax_total_excluded_app)
         
         line_discount.product_lst_price =  (-1) * ( ( self.discountProgram!.amount *  total.total_included) / 100)
         line_discount.update_values()
         
         }
         
         self.discount = line_discount.price_subtotal_incl!
         self.amount_total =  self.amount_total + self.discount
         //                self.amount_tax =  self.amount_tax +   self.discountProgram!.discount_product!.price_subtotal!
         
         }
         
         }
         else
         {
         self.amount_total =  self.amount_total + self.discount
         }
         */
    }
    func calcAll()
    {
        
        if self.pos_order_lines.count > 0
        {
            
            var all_lines = self.pos_order_lines
            let serviceLineData = self.remove_get_line_service_charge(all_lines)
            let serviceLine = serviceLineData.serviceLine
            all_lines = serviceLineData.filterLines

            
            var line_discount_program = get_discount_line()
            
            if line_discount_program != nil
            {
                all_lines.removeAll(where:{ $0.uid == (line_discount_program?.uid ?? "") } )
                all_lines.append(line_discount_program!)
                
            }else{
                line_discount_program = all_lines.filter({($0.discount ?? 0) != 0}).first
            }
            if let pos_delivery_area_id = customer?.pos_delivery_area_id{
                if let deliveryLine = get_delivery_line(){
                    all_lines.removeAll(where:{ $0.uid == (deliveryLine.uid) } )
                }
                
            }else{
                if let orderType = self.orderType{
                    if (orderType.order_type) == "delivery"
                    {
                        if let line = pos_order_line_class.get(order_id:  self.id!, product_id: orderType.delivery_product_id)
                        {
//                            let orderTypeID = orderType.id
//                            let delivery_id = delivery_type_class.getDeliveryProduct(for: orderTypeID).delivery_product_id
//                            all_lines.removeAll(where:{ $0.product_id == (delivery_id) } )
                            all_lines.removeAll(where:{ $0.uid == (line.uid) } )

                        }
                    }
                }
            }
        
            
            all_lines = self.remove_line_extra_fees(all_lines)
            self.total_items = self.clacTotalItems()
            
            let total = self.clacTaxes(lines: all_lines,line_discount_program: line_discount_program,service_charge_line: serviceLine)
            self.amount_total = total.total_included
            self.amount_tax = total.tax_amount
            /*
            if SharedManager.shared.appSetting().enable_show_price_without_tax {
                self.amount_total = total.total_excluded
                self.amount_tax = total.tax_amount

            }
            */
            let isTaxFree = SharedManager.shared.posConfig().allow_free_tax
            if isTaxFree == true
            {
                self.amount_total = total.total_excluded
                self.amount_tax = 0
            }
            
            
        }
        else
        {
            self.amount_total = 0
            self.amount_tax = 0
        }
        
        
    }
    
    func check_is_last_row(line:pos_order_line_class,check_last_row:Bool) -> Int {
        
        if check_last_row == false
        {
            let frist_index = pos_order_lines.firstIndex(where: {
                                                            $0.product_id == line.product_id
                                                                && $0.is_void == false
                                                                && $0.line_repeat == line.line_repeat
            })
            return frist_index ?? -1
        }
        
        if line.product.variants_count == 0 && line.product.is_combo == false
        {
            //                    self.pos_order_lines.sort{  $0.product_id! < $1.product_id!  }
            
            let last_row = self.pos_order_lines.last
            if last_row?.product_id == line.product_id
            {
                return self.pos_order_lines.count - 1
            }
        }
        
        return -1
    }
    
    func checkProductExist(line:pos_order_line_class,check_by_line:Bool,check_last_row:Bool) -> Int {
        
        
        
        if line.is_combo_line == true
        {
            return -1
        }
        
        if check_by_line == true
        {
            if line.product.variants_count == 0 && line.product.is_combo == false && line.is_promotion == false
            {
                let index = check_is_last_row(line: line,check_last_row: check_last_row)
                return index
            }
            else
            {
                let frist_index = pos_order_lines.firstIndex(where: {$0.id == line.id })
                return frist_index ?? -1
            }
            
        }
        else
        {
            let frist_index = pos_order_lines.firstIndex(where: {$0.product_id == line.product_id && $0.is_promotion == false})
            return frist_index ?? -1
        }
        
         
    }
    
    
    func is_return() -> Bool
    {
        if self.parent_order_id != 0 //|| self.sub_orders.count > 0
        {
            return true
        }
        
        return false
    }
    func able_to_return() -> Bool
    {
        var isReturned = false
        if self.parent_order_id != 0
        {
            isReturned = true
        }else{
            if self.sub_orders.count > 0{
                let returendPosLines = self.sub_orders.flatMap({$0.pos_order_lines})
                for orginLine in self.pos_order_lines {
                    let orginProductID = orginLine.product_id
                    let orginProductQty = orginLine.qty
                    let returnQty = returendPosLines.filter({$0.product_id == orginProductID }).map({abs($0.qty)}).reduce(0,+)
                    isReturned =  orginProductQty == returnQty
                    if returnQty <= 0 || orginProductQty != returnQty {
                        isReturned = false
                        break
                    }
                }
            }
        }
        
        return isReturned
    }
    
    func applyPriceList(for index:Int = -1)
    {
        if index != -1 && pos_order_lines.count > 0 {
                let line =  pos_order_lines[index]
                line.priceList = priceList
                line.update_values()
        }else{
            for line in pos_order_lines
            {
                if line.pos_promotion_id == 0 {
                    line.priceList = priceList
                    line.update_values()
                    if SharedManager.shared.appSetting().enable_new_combo {
                    if line.is_combo_line ?? false{
                        line.selected_products_in_combo.forEach { addOnLine in
                            addOnLine.priceList = priceList
                            addOnLine.update_values()
                            /*
                            if let priceExtra = product_combo_price_line_class.getExtraPrice(for:addOnLine.product_id ?? 0, price_list_id:priceList  ){
                                addOnLine.priceList = priceList
                                addOnLine.custom_price = priceExtra
                                addOnLine.update_values()

                            }else{
                                addOnLine.priceList = priceList
                                addOnLine.update_values()
                            }
                             */
                        }
                    }
                }
                }
            }
        }
        
        save(write_info: false,re_calc: true)
    }
    
    func saveForReport()
    {
        let semaphore = DispatchSemaphore(value: 0)
        SharedManager.shared.database_db!.inDatabase { (db:FMDatabase) in
            
            if self.orderType  == nil
            {
                self.orderType = delivery_type_class()
                self.orderType!.order_type = "default"
                self.orderType!.display_name = "default"
                self.orderType!.delivery_amount  = 0.0
            }
            // ==========================================================================================
            // order type
            let  order_type_success = db.executeUpdate(
                "insert into order_type (order_id,order_type,display_name,delivery_amount) VALUES(?,?,?,?)"
                , withArgumentsIn: [ self.id!, self.orderType!.order_type , self.orderType!.display_name  , self.orderType!.delivery_amount   ])
            
            if !order_type_success
            {
                let error = db.lastErrorMessage()
               SharedManager.shared.printLog("database Error : \(error)" )
            }
            // ==========================================================================================
            // payment method
            for payment in self.list_account_journal
            {
                let display_name = payment.display_name
                let tendered = payment.tendered.toDouble()!
                let changes = payment.changes
                let type = payment.type
                
                let payment_success = db.executeUpdate(
                    "insert into payment_method (order_id,display_name,tendered,changes,type) VALUES(?,?,?,?,?)"
                    , withArgumentsIn: [ self.id!, display_name ,  tendered , changes , type   ])
                
                if !payment_success
                {
                    let error = db.lastErrorMessage()
                   SharedManager.shared.printLog("database Error : \(error)" )
                }
            }
            
            // ==========================================================================================
            db.close()
            semaphore.signal()

        }
        semaphore.wait()

    }
    
    func getLastRow() -> Int
    {
        var id = 0
        let semaphore = DispatchSemaphore(value: 0)
        SharedManager.shared.database_db!.inDatabase { (db:FMDatabase) in
            
            let sql = "select max(id) from pos_order"
            let rows:FMResultSet = try!   db.executeQuery(sql, values: [])
            while (rows.next()) {
                id = Int(rows.int(forColumnIndex: 0))
            }
            db.close()
            semaphore.signal()
        }
        
        semaphore.wait()
        
        return id
    }
    
    
    //    func get_data_for_database() -> String
    //    {
    //        let temp_dic = self.toDictionary()
    //        let temp_order = posOrderClass(fromDictionary: temp_dic)
    //        temp_order.cashier?.image = ""
    //        temp_order.customer?.image = ""
    //        temp_order.session?.pos().company().logo = ""
    //        temp_order.pos?.company().logo = ""
    //
    //        if temp_order.is_closed == true
    //        {
    //            for item in temp_order.products
    //            {
    //                item.image = ""
    //                item.products_InCombo.removeAll()
    //
    //            }
    //
    //            for item in temp_order.products_void
    //            {
    //                item.image = ""
    //                item.products_InCombo.removeAll()
    //            }
    //        }
    //
    //        let data =   JsonToDictionary.jsonString(with: temp_order.toDictionary(), prettyPrinted: true)  ?? ""
    //
    //        return data
    //    }
    //
    
    //     func saveOrder()
    //     {
    //         //        myuserdefaults.setitems(String(orderID), setValue: self.toDictionary(), prefix: ordersListClass.ordersPrefix)
    //         let semaphore = DispatchSemaphore(value: 0)
    //
    //
    //
    //         let data =   get_data_for_database()
    //
    //
    //         SharedManager.shared.data_db!.inDatabase { (db:FMDatabase) in
    //
    //
    //             if checkShiftExit() == false
    //             {
    //                 let closed =  (self.is_closed == true ) ? 1:0
    //
    //
    //
    //
    //                 //                let success = db.executeUpdate(
    //                 //                    "insert into orders (shift_id,session_id,invoice_id,order_type,data,total,closed ,parent_order_id) VALUES (?,?,?,?,?,?,?,?) "
    //                 //                    , withArgumentsIn: [self.shift!.id, self.session!.id, self.invoiceID,self.orderSyncType.rawValue,data ,self.amount_total,closed,self.parent_orderID ?? NSNull()])
    //                 //
    //                 //                if !success
    //                 //                {
    //                 //                    let error = db.lastErrorMessage()
    //                 //                   SharedManager.shared.printLog("database Error : \(error)" )
    //                 //                }
    //             }
    //             else
    //             {
    //
    ////                 let is_void = ( self.is_void == true ) ? 1:0
    ////                 let sync = (self.is_sync == true ) ? 1:0
    ////                 let closed =  (self.is_closed == true ) ? 1:0
    ////                 let creation_date_db = ClassDate.getWithFormate(self.creation_date, formate: ClassDate.serverFromate(), returnFormate: ClassDate.satnderFromate(),use_UTC: false)
    ////
    ////                 // ==========================================================================================
    ////                 let success = db.executeUpdate(
    ////                     "update pos_order set parent_order_id =? ,order_type=?  ,is_void=?,sync=? ,closed =? , data=?  ,creation_date=? , total=? , discount=?   ,amount_paid=? ,amount_return=?   where id=?"
    ////                     , withArgumentsIn: [self.parent_order_id ?? NSNull() , self.order_sync_ype.rawValue,  is_void ,sync , closed , data   ,creation_date_db ?? NSNull(),self.get_total() , self.discountProgram.amount  , self.amount_paid ,self.amount_return   ,self.id! ])
    ////
    ////                 if !success
    ////                 {
    ////                     let error = db.lastErrorMessage()
    ////                    SharedManager.shared.printLog("database Error : \(error)" )
    ////                 }
    //
    //
    //
    //
    //             }
    //
    //             semaphore.signal()
    //         }
    //
    //         semaphore.wait()
    //
    //     }
    
    
 
                
                
 
    func generateInviceID(session_id:Int? ) -> Int {

        guard let session_id = session_id else { return 0 }
        if SharedManager.shared.appSetting().enable_enter_containous_sequence{
            return generateContainousSequenceAccordingSetting()
        }
        if SharedManager.shared.appSetting().enable_enter_sessiion_sequence_order{
            return generateSequenceAccordingSetting(session_id )
        }
        let sql = "select max(sequence_number) as sequence_number from pos_order where session_id_local =?  and order_sync_type != 2"
        var count = 1
        
        let semaphore = DispatchSemaphore(value: 0)
        SharedManager.shared.database_db!.inDatabase { (db:FMDatabase) in
            
            let resutl:FMResultSet = try! db.executeQuery(sql, values: [session_id ])
            if resutl.next()
            {
                count = Int(resutl.int(forColumn: "sequence_number"))
                count += 1
                resutl.close()
            }
            db.close()
            semaphore.signal()
        }
        
        semaphore.wait()
        
        return count
    }
    private func generateSequenceAccordingSetting(_ session_id:Int ) -> Int {
        let start_session_sequence_order =  SharedManager.shared.appSetting().start_session_sequence_order.toInt()
        let end_sessiion_sequence_order =  SharedManager.shared.appSetting().end_sessiion_sequence_order.toInt()
        let create_pos_id = SharedManager.shared.posConfig().id
        let sql = "SELECT sequence_number as sequence_number FROM pos_order Where create_pos_id = \(create_pos_id) and session_id_local = \(session_id)   ORDER BY ID DESC LIMIT 1"
        var count = start_session_sequence_order
        
        let semaphore = DispatchSemaphore(value: 0)
        SharedManager.shared.database_db!.inDatabase { (db:FMDatabase) in
            
            let resutl:FMResultSet = try! db.executeQuery(sql, values: [session_id ])
            if resutl.next()
            {
                count = Int(resutl.int(forColumn: "sequence_number"))
                if count >= start_session_sequence_order && count < end_sessiion_sequence_order {
                    count += 1
                }else{
                    
                    count = start_session_sequence_order
                }
                
                resutl.close()
                
                
                
            }
            db.close()
            semaphore.signal()
        }
        
        
        semaphore.wait()
        
        return count
    }
    private func generateContainousSequenceAccordingSetting() -> Int {
        let start_session_sequence_order =  SharedManager.shared.appSetting().start_value_containous_sequence
        if start_session_sequence_order <= 1 {
            SharedManager.shared.appSetting().start_value_containous_sequence = 2
            SharedManager.shared.appSetting().save()
            return 1
        }
        let nextSeq = start_session_sequence_order + 1
        SharedManager.shared.appSetting().start_value_containous_sequence = nextSeq
        SharedManager.shared.appSetting().save()
        return nextSeq - 1
    }
    
    static func get_max_sequence_for_active_session() -> Int?{
    guard let active_sesstion = pos_session_class.getActiveSession()?.id else {return nil}
        let sql = "select max(sequence_number) as sequence_number from pos_order where session_id_local =?  and order_sync_type != 2 "
        var count = 1
        
        let semaphore = DispatchSemaphore(value: 0)
        SharedManager.shared.database_db!.inDatabase { (db:FMDatabase) in
            
            let resutl:FMResultSet = try! db.executeQuery(sql, values: [active_sesstion ])
            if resutl.next()
            {
                count = Int(resutl.int(forColumn: "sequence_number"))
                resutl.close()
            }
            db.close()
            semaphore.signal()
        }
        semaphore.wait()
        return count
    }
    
    
    
    func copyOrder(option:ordersListOpetions? = nil) -> pos_order_class
    {
        let dic = self.toDictionary()
 
        let new_order = pos_order_class(fromDictionary: dic,options_order: option)
        
        
        return new_order
    }
    
    
    func checkShiftExit() -> Bool
    {
        if self.id == nil  {
            return false
        }
        
        let sql = "select count(*) from pos_order where id =?"
        var Exist:Bool = false
        
        let semaphore = DispatchSemaphore(value: 0)
        SharedManager.shared.database_db!.inDatabase { (db:FMDatabase) in
            
            let resutl:FMResultSet = try! db.executeQuery(sql, values: [self.id!])
            
            if resutl.next()
            {
                let count:Int = Int(resutl.int(forColumnIndex: 0))
                
                if count > 0
                {
                    resutl.close()
                    Exist =  true
                }
            }
            
            resutl.close()
            
            semaphore.signal()
        }
        
        
        semaphore.wait()
        
        return Exist
    }
    
    
    func get_order_status() -> kds_order_stauts
    {
        
        let pos = SharedManager.shared.posConfig()
        guard self.id != nil else {
            return kds_order_stauts.changed
        }
        let sql = """
        SELECT count(*) from pos_order inner join pos_order_line
        on pos_order.id = pos_order_line.order_id
        where order_id = \(self.id!)
        and  pos_order_line.write_date >= pos_order.write_date
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
        
        
        if changed == true
        {
            return kds_order_stauts.changed
            
        }
            
        else
        {
            return kds_order_stauts.new
        }
        
    }
    
    static func remove_pending_orders(isTCP:Bool = false,uid:String? = nil) {
        // and po.is_closed = 0
        guard let active_sesstion = pos_session_class.getActiveSession()?.id else {return}
        let pos = SharedManager.shared.posConfig()
        var queryMultiSession = ""
        var queryUidMultiSession = ""
        let posID = SharedManager.shared.posConfig().id
        var queryWritePOS = " and po.write_pos_id != \(posID)"

        var nagtive_session_id_local = isTCP ? (active_sesstion * -1) : -1
        if !isTCP {
            queryMultiSession = " and pol.pos_multi_session_status in (2, 4) "
        }else{
            queryMultiSession = " and po.sent_ip_date IS NOT NULL AND po.sent_ip_date != '' "
        }
        if let uid = uid
        {
            if !isTCP {
                queryMultiSession = ""
                queryUidMultiSession = " and po.uid in ('\(uid)') "
            }
        }
        let sql =  """
        UPDATE
            pos_order
        SET
            session_id_local = \(nagtive_session_id_local)
        WHERE
            id IN (
            SELECT
                po.id
            from
                pos_order as po
            inner join pos_order_line as pol on
                po.id = pol.order_id
                and po.is_closed = 0
                and po.is_void = 0
                and po.is_sync = 0
                and po.order_menu_status not in (4)
                \(queryMultiSession)
                \(queryUidMultiSession) and po.session_id_local = \(active_sesstion)
                group by
                    po.id );
        """

            
            let semaphore = DispatchSemaphore(value: 0)
            SharedManager.shared.database_db!.inDatabase { (db:FMDatabase) in
                
                let resutl =  db.executeStatements(sql)
                if !resutl
                {
                    let error = db.lastErrorMessage()
                   SharedManager.shared.printLog("database Error : \(error)" )
                }
                db.close()
                semaphore.signal()
            }
            semaphore.wait()
    }
    static func remove_pending_orders_not_in(isTCP:Bool = false,uids:[String]) {
        // and po.is_closed = 0
        guard let active_sesstion = pos_session_class.getActiveSession()?.id else {return}
        let pos = SharedManager.shared.posConfig()
        var queryMultiSession = ""
        var queryUidMultiSession = ""
        let posID = SharedManager.shared.posConfig().id
        var queryWritePOS = " and po.write_pos_id != \(posID)"

        var nagtive_session_id_local = isTCP ? (active_sesstion * -1) : -1
        if !isTCP {
            queryMultiSession = " and pol.pos_multi_session_status in (2, 4) "
        }else{
            queryMultiSession = " and po.sent_ip_date IS NOT NULL AND po.sent_ip_date != '' "
        }
        let uidsQuery = uids.map({"'\($0)'"}).joined(separator: ", ")
            if !isTCP {
                queryMultiSession = ""
                queryUidMultiSession = " and po.uid not in (\(uidsQuery)) and pol.pos_multi_session_status not in (0, 1) "

            }
        
        let sql =  """
        UPDATE
            pos_order
        SET
            session_id_local = \(nagtive_session_id_local)
        WHERE
            id IN (
            SELECT
                po.id
            from
                pos_order as po
            inner join pos_order_line as pol on
                po.id = pol.order_id
                and po.is_closed = 0
                and po.is_void = 0
                and po.is_sync = 0
                and po.order_menu_status not in (4)
                \(queryMultiSession)
                \(queryUidMultiSession) and po.session_id_local = \(active_sesstion)
                group by
                    po.id );
        """

            
            let semaphore = DispatchSemaphore(value: 0)
            SharedManager.shared.database_db!.inDatabase { (db:FMDatabase) in
                
                let resutl =  db.executeStatements(sql)
                if !resutl
                {
                    let error = db.lastErrorMessage()
                   SharedManager.shared.printLog("database Error : \(error)" )
                }
                db.close()
                semaphore.signal()
            }
            semaphore.wait()
    }
    
    func isSendToMultisession() -> Bool{
        let isSentMultisession = (!(self.pos_multi_session_write_date ?? "").isEmpty &&
                                  self.is_closed == false )
                              || self.create_pos_id != SharedManager.shared.posConfig().id
        if SharedManager.shared.mwIPnetwork {
            let isSentViaIP =  !(self.sent_ip_date ?? "").isEmpty ||  !(self.recieve_date ?? "").isEmpty
           return isSentMultisession || isSentViaIP
        }
         if (!(self.pos_multi_session_write_date ?? "").isEmpty &&
                 self.is_closed == false )
             || self.create_pos_id != SharedManager.shared.posConfig().id {
            return true
         }
        return false
    }
    func is_send_toKDS() -> Bool
    {
        
        let pos = SharedManager.shared.posConfig()
        
        let sql = """
        SELECT count(*) from pos_order inner join pos_order_line
        on pos_order.id = pos_order_line.order_id
        where order_id = \(self.id!)
        and  pos_order_line.pos_multi_session_status in (2,4)
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
    static func get_not_sync_orders(for session:pos_session_class) -> [pos_order_class]
    {
        let opetions = ordersListOpetions()
        opetions.Closed = true
        opetions.Sync = false
        opetions.orderDesc = false
        opetions.orderSyncType = .all
        opetions.sesssion_id = session.id
        opetions.page = 0
        opetions.LIMIT = 1
        opetions.parent_product = true
        opetions.write_pos_id = SharedManager.shared.posConfig().id
        opetions.void = false
        return pos_order_helper_class.getOrders_status_sorted(options: opetions)
        
    }
    static func get_not_closed_orders(for session:pos_session_class) -> [pos_order_class]
    {
        let opetions = ordersListOpetions()
//        opetions.Closed = true
        opetions.Sync = false
        opetions.orderDesc = false
        opetions.orderSyncType = .all
        opetions.sesssion_id = session.id
        opetions.page = 0
//        opetions.LIMIT = 1
        opetions.parent_product = true
        opetions.write_pos_id = SharedManager.shared.posConfig().id
//        opetions.void = false
        return pos_order_helper_class.getOrders_status_sorted(options: opetions)
        
    }
    static func get_not_closed_orders_mannule(for session:pos_session_class) -> [pos_order_class]
    {
        let opetions = ordersListOpetions()
//        opetions.Closed = true
//        opetions.Sync = false
        opetions.orderDesc = false
        opetions.orderSyncType = .all
        opetions.sesssion_id = session.id
        opetions.page = 0
//        opetions.LIMIT = 1
        opetions.parent_product = true
        opetions.write_pos_id = SharedManager.shared.posConfig().id
//        opetions.void = false
        return pos_order_helper_class.getOrders_status_sorted(options: opetions)
        
    }

    func checISSendToMultisession() -> Bool{
        if SharedManager.shared.mwIPnetwork {
            if ( !(self.sent_ip_date ?? "").isEmpty ||  !(self.recieve_date ?? "").isEmpty ) {
             return true
            }else{
                if self.order_integration == .NONE {
                    return false
                }
            }
           /* if let uid = self.uid{
                return messages_ip_log_class.isExist(body:uid )
            }
            */
        }
        
         if (!(self.pos_multi_session_write_date ?? "").isEmpty &&
                self.is_closed == false )
             || self.create_pos_id != SharedManager.shared.posConfig().id {
            return true
         }
        return false
    }
    func canReturnLineFromOrder()->Bool{
        if  let _ = self.get_discount_line() {
            return false
        }
        if let _ = self.is_have_extra_fees(){
            return false
        }
        if let _ = self.get_delivery_line() {
            return false
        }
        if self.get_bankStatement().count > 1{
          //  return false
        }
        return !self.is_have_promotions()
    }
    func voidAllLines( updated_session_status: updated_status_enum? = nil, kitchenStatus: kitchen_status_enum? = nil ){
        var posOrderLines:[pos_order_line_class] = []
       for line in self.getAllLines() {
               line.is_void = true
               if line.is_combo_line!
               {
                   if line.selected_products_in_combo.count > 0
                   {
                       for combo_line in line.selected_products_in_combo
                       {
                           combo_line.is_void = true
                           combo_line.write_info = true
                           combo_line.printed = .none

                       }
                   }
               }
        line.save(write_info: true, updated_session_status: updated_session_status, kitchenStatus: kitchenStatus)
           
//                if (line.pos_multi_session_status?.rawValue ?? 0 ) >= 2 {
//                    count_send_to_kitchen += 1
//                }
        posOrderLines.append(line)
    }
       self.pos_order_lines.removeAll()
       self.pos_order_lines.append(contentsOf: posOrderLines)
    }
    func checkIsOrderAcceptedBefor() -> Bool{
        let opetions = ordersListOpetions()
        opetions.uid = self.uid
        let arr = pos_order_helper_class.getOrders_status_sorted(options: opetions)
        if arr.count > 0 && (arr.first?.order_menu_status ?? .none) == .accepted {
           return true
        }
        return false
    }
    func isAllLinesInsurance() -> Bool{
        let LinesOnlyCount = pos_order_lines.filter ({!$0.isVoidFromUI()  }).count
        let inuranceLinesOnlyCount = pos_order_lines.filter ({ $0.isInsuranceLine() }).count
        return ( inuranceLinesOnlyCount > LinesOnlyCount )
    }
    func makeInsurancesLinesFilter(totalAmountInsurance:Double){
        self.pos_order_lines = self.pos_order_lines.filter({!$0.isInsuranceLine()})
//        self.amount_total =  self.amount_total - totalAmountInsurance
//        self.amount_paid = self.amount_paid - totalAmountInsurance
//        self.amount_return  = self.amount_paid - self.amount_total
    }
    func getAllLines(with comboLines:Bool = false)->[pos_order_line_class]{
        let cls = pos_order_line_class(fromDictionary: [:])
        let sql = "  where  order_id = \(self.id ?? 0) "
//        cls.price_unit
//        cls.price_subtotal
//        cls.price_subtotal_incl
//        cls.extra_price
        
          let items  = cls.dbClass!.get_rows(whereSql: sql)
          
        
        return items.map( {pos_order_line_class(fromDictionary: $0,with: comboLines)})
        
    }
    func getReturnOrderIntegration() -> pos_order_class?{
        let returnOrder = pos_order_class(fromDictionary: self.toDictionary())

        let activeSession = pos_session_class.getActiveSession()
        if activeSession == nil
        {
            //TODO: - If Paid Order Cancelled by deliverect and session was closed
            return nil

        }else{
            returnOrder.session = activeSession
            let sequence_number =  returnOrder.generateInviceID(session_id: activeSession?.id )
            returnOrder.sequence_number = sequence_number
        }
        let orderID_server =  pos_order_helper_class.get_new_order_id_server(sequence_number: returnOrder.sequence_number )
        
        
        returnOrder.name = String(format: "Order-%@",orderID_server )   //formateOrderID(orderID: orderID_server)
        returnOrder.uid = orderID_server
        
        returnOrder.id = nil
        returnOrder.is_sync = false
        returnOrder.is_closed = false
        returnOrder.parent_order_id = self.id ?? 0
        returnOrder.parent_order_id_server = self.name
        
        returnOrder.amount_return =  returnOrder.amount_total
        returnOrder.amount_paid = returnOrder.amount_total * -1
        
        returnOrder.cashier = SharedManager.shared.activeUser()
        
        
        
        
        return returnOrder
    }
    func getBill_uidStatic() -> String{
        if SharedManager.shared.appSetting().enable_work_with_bill_uid_default{
            if !(bill_uid ?? "").isEmpty {
                return bill_uid ?? (name ?? "")
            }
        }
        return self.name ?? ""
    }
    func setBill_uid(){
        if SharedManager.shared.appSetting().enable_work_with_bill_uid_default{
            if let dbID = self.id {
                DispatchQueue.global(qos: .background).async{
                    let staticValue = 123
                    let posID = SharedManager.shared.posConfig().id
                    let startPart = staticValue + posID
                    let endPart = String(format:"%05d", dbID )
                    let billNumber = "\(startPart)\(endPart)"
                    SharedManager.shared.printLog("endPart 123 + posID + 05d_dbID  ==== \(endPart)")
                    SharedManager.shared.printLog("billNumber ==== \(billNumber)")
                    self.bill_uid = billNumber
                    let sql = "Update pos_order set bill_uid = '\(self.bill_uid ?? "")' where id = \(dbID)"
                    let _ = self.dbClass?.runSqlStatament(sql: sql)
                }
            }
        }
        
           
    }
    func reFetchPosLines(){
        self.pos_order_lines.removeAll()
        self.get_products()
        
        
    }
    func setl10n_sa_uuid(){
        let uuid = UUID().uuidString
        self.l10n_sa_uuid = uuid
        if let dbID = self.id {
            DispatchQueue.global(qos: .background).async{
                let sql = "Update pos_order set bill_uid = '\(self.l10n_sa_uuid ?? "")' where id = \(dbID)"
                let _ = self.dbClass?.runSqlStatament(sql: sql)
            }
        }
    }
    func setl10n_sa_chain_index(){
       // DispatchQueue.global(qos: .background).async{
            var nextIndex:Int = 1
            if let lastIndexString = cash_data_class.get(key: "last_chain_index"){
                nextIndex = (Int(lastIndexString) ?? 0) + 1
            }
            cash_data_class.set(key: "last_chain_index", value: "\(nextIndex)")
            self.l10n_sa_chain_index = nextIndex
            if let dbID = self.id {
                let sql = "Update pos_order set l10n_sa_chain_index = \(nextIndex) where id = \(dbID)"
                let _ = self.dbClass?.runSqlStatament(sql: sql)
            }
        //}
    }
    static func checkIfSessionHaveEmptyOrder() -> Bool{
        if let sessionID = pos_session_class.getActiveSession()?.id {
            let sql = "select count(*) as cnt from pos_order where is_void = 0 and is_closed = 0 and session_id_local = \(sessionID) and total_items = 0 "
            let count:[String:Any] = database_class(connect: .database).get_row(sql: sql) ?? [:]
            
            return (count["cnt"] as? Int ?? 0) > 0

        }
        return false
        
    }
    func get_control_by_user_id() -> Int?{
        if let control_by_user_id = self.table_control_by_user_id , control_by_user_id != 0 {
            return control_by_user_id
        }
        return nil
    }
}
