//
//  pos_order_builder_class.swift
//  pos
//
//  Created by Khaled on 4/28/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import UIKit

class pos_order_builder_class: NSObject {
    static  func bulid_order_data(order:pos_order_class, for_pool:pos_multi_session_sync_class?) -> [String:Any]
    {
        // ==================================================================
        // Calac
        
        var lines: [Any] = []
        
        let lines_products = get_products_lines(order: order,for_pool:for_pool)
        lines.append(contentsOf: lines_products)
        
        let line_delivery_amount = check_delivery_amount(order:order)
        if line_delivery_amount != nil
        {
            lines.append(line_delivery_amount!)
        }
        
        let line_check_discount = check_discountProgram(order: order,for_pool: for_pool)
        if line_check_discount != nil
        {
           
            lines.append(line_check_discount!)
        }
        
        let line_check_extrafees = check_extra_fees(order: order,for_pool: for_pool)
        if line_check_extrafees != nil
        {
           
            lines.append(line_check_extrafees!)
        }
        let line_check_service_charge = check_service_charge_amount(order: order,for_pool: for_pool)
        if line_check_service_charge != nil
        {
           
            lines.append(line_check_service_charge!)
        }
        
        var statement_ids:[Any] = []
            
        if for_pool == nil
        {
            statement_ids =  get_statement_ids(order: order)
        }
        
        let tax_discount:Decimal = get_tax_discount(order: order)
        
        // ==================================================================
        // values
        let order_total = order.amount_total //.rounded_formated()
        let order_amount_paid = order.amount_paid //.rounded_formated()

        let order_name:String! =  order.name
        let orderID:String! =  order.uid
        let amount_tax = order.amount_tax //.rounded_formated()
        
        //        let amount_paid = order.amount_paid.rounded_formated()
        let amount_return = 0 //  order.amount_return.rounded_formated()
        
        let pos_session_id = order.session_id_server
        let pos_delivery_method_id = order.orderType?.id ?? 0
        
        let pricelistID = order.priceList?.id  ?? 0
        let pricelist_id = (pricelistID > 0) ? pricelistID : 1
        
        let partner_id = order.customer?.id ?? 0
        //        let partner_id:Any = (partnerId > 0) ? partnerId : false
        var user_id = order.cashier?.id ?? 0
        var user_create_id = order.create_user_id ?? 0
        var user_create_name = order.create_user_name ?? ""

        if let userIdWrite =  order.write_user_id{
            user_id = userIdWrite
        }
        let sequence_number = order.sequence_number
        let creation_date:String =  order.create_date! //"2019-08-21T00:31:11.926Z"
        let guests_number = order.guests_number

        let fiscal_position_id = false
        
        
        var return_reason_id:Any = false

        
        if order.return_reason_id != nil
        {
            if order.return_reason_id != 0
            {
                return_reason_id = order.return_reason_id!
            }
        }
   
        // ==================================================================
        // Bulid
        
        let version = Bundle.main.fullVersion
        
        var dic:[String:Any] = [
            "bill_uid": order.bill_uid ?? "",
            "name": order_name!,
            "user_id": SharedManager.shared.getCashDomainUserId(),
            "return_reason_id" : return_reason_id,
            "amount_paid": order_amount_paid,
            "amount_total": order_total ,
            "amount_tax": amount_tax,
            "tax_discount": tax_discount,
            "amount_return":  amount_return,
            "statement_ids": statement_ids ,
            "pos_session_id": pos_session_id!,
            "delivery_method_id":  pos_delivery_method_id,
            "pricelist_id": pricelist_id,
            "pos_customer_id": partner_id,
           // "partner_id": partner_id,
            "pos_user_id": user_id,
            "uid": orderID!,
            "sequence_number": sequence_number,
            "guests_number": guests_number,
            "creation_date": creation_date,
            "fiscal_position_id": fiscal_position_id,
            "lines":  lines ,
            "ios_version" : version ,
            "ios_notes" : "",
            "note": order.note,
            "loyalty_earned_point": order.loyalty_earned_point,
            "loyalty_earned_amount": order.loyalty_earned_amount,
            "loyalty_redeemed_point": order.loyalty_redeemed_point,
            "loyalty_redeemed_amount": order.loyalty_redeemed_amount,
            "pos_promotion_code" : order.promotion_code,
            "preparation_total_time" : order.kds_preparation_total_time ?? 0,
            "waiter_user_id": user_create_id,
            "created_by_device_id": order.create_pos_id ?? 0
            
        ]
        if let sourceOrder = pos_order_integration_class.get(order_uid: order.uid ?? "")?.online_order_source{
            dic["online_order_source"] = sourceOrder
            dic["platform_name"] = order.platform_name ?? ""

        }
        //Check Geidea payment method
        if let ingenico_objc = Device_payment_order_class.get(orderId:order.id! ){
            dic["retrieval_reference_number"] = ingenico_objc.rRN ?? ""
            dic["transaction_status_en"] = ingenico_objc.response_code ?? ""
            dic["card_acceptor_business_code"] = ingenico_objc.information ?? ""
            dic["systems_trace_audit_number"] = ingenico_objc.ecr_receipt ?? ""
            dic["card_number"] = ingenico_objc.card_no ?? ""
            dic["pin_verified_status_en"] = ingenico_objc.auth ?? ""
        }
        if order.driver_id != nil && order.driver_id != 0 {
            dic["driver_id"]  = order.driver_id

        }
        if let typeReference = order.delivery_type_reference , !typeReference.isEmpty{
            dic["order_type_reference"]  = typeReference
        }

        if order.table_id != nil && order.table_id != 0 {
            dic["floor_name"]  = order.floor_name
            dic["table_name"]  = order.table_name
            dic["table_id"]  = order.table_id

        }
        //MemberShip order
        if order.membership_sale_order_id != nil && order.membership_sale_order_id != 0 {
            dic["membership_sale_order_id"]  = order.membership_sale_order_id

        }
        //brand_id
        if order.brand_id != nil && order.brand_id != 0 {
            dic["brand_id"]  = order.brand_id

        }
        //
        if SharedManager.shared.phase2InvoiceOffline ?? false {
            if for_pool == nil
            {
                if let chainIndex = order.l10n_sa_chain_index{
                    dic["l10n_sa_chain_index"]  = chainIndex
                }
                if let zakaUUID = order.l10n_sa_uuid{
                    dic["l10n_sa_uuid"]  = zakaUUID
                }
            }
        }
        if order.parent_order_id != 0 {
            dic["return_reference"] = pos_order_class.get(order_id: order.parent_order_id)?.name ?? ""
        }
        if SharedManager.shared.phase2InvoiceOffline ?? false {
            if for_pool == nil
            {
                
                let posEinvoice = pos_e_invoice_class.getBy(order.uid ?? "")
                if let posEinvoice = posEinvoice {
                    dic["l10n_sa_invoice_signature"] = posEinvoice.signature ?? ""
                    dic["invoice_hash_hex"] = (posEinvoice.un_sgin_xml_hash ?? "") //.toBase64()
                    dic["xml_content"] = posEinvoice.base64_content ?? ""
                    dic["l10n_sa_qr_code_str"] = posEinvoice.qr_code_value ?? ""
                    dic["certificate_str"] = posEinvoice.certificate_str ?? "" //binary
                    dic["log_ids"] = false
                    dic["is_return"] = (order.amount_total < 0) || ((order.return_reason_id ?? 0 ) != 0)
                }
                if order.parent_order_id != 0 {
                    dic["return_reference"] = pos_order_class.get(order_id: order.parent_order_id)?.name ?? ""
                }
            }else{
                if let qr_code_value = pos_e_invoice_class.getBy(order.uid ?? "")?.qr_code_value {
                    dic["qr_code_value_offline"] = qr_code_value

                }

            }
        }

        
        if for_pool != nil
        {
            let is_printed = pos_order_helper_class.get_order_is_printed(order_id: order.id!)
            let print_count = pos_order_helper_class.get_print_count(order_id: order.id!)
            
            if order.parent_order_id != 0 {
                dic["return_reference"] = pos_order_class.get(order_id: order.parent_order_id)?.name ?? ""
            }
            
            dic["pos_id"] = order.pos_id
            dic["order_on_server"] = for_pool?.order_on_server
            dic["new_order"] = for_pool?.new_order
            dic["nonce"] =  for_pool?.nonce()
            dic["revision_ID"] = for_pool?.revision_ID
            dic["run_ID"] = for_pool?.run_ID
            dic["note"]  = order.note
            dic["create_date"]  = order.create_date
            dic["write_date"]  = order.write_date
//            dic["floor_name"]  = order.floor_name
//            dic["table_name"]  = order.table_name
//            dic["table_id"]  = order.table_id
//            dic["driver_id"]  = order.driver_id
            dic["is_closed"]  = order.is_closed
            dic["is_void"]  = order.is_void
            dic["is_sync"]  = order.is_sync
            dic["is_printed"]  = is_printed
            dic["print_count"]  = print_count
            dic["delivery_type_reference"]   = order.delivery_type_reference
            dic["sequence_multisession"]  = sequence_number
            dic["menu_status"] = "\(order.order_menu_status)"
            if (order.is_closed) && (!order.is_void) && (order.get_bankStatement().count > 0){
                dic["payment_status"] = "Paid"
            }else{
                dic["payment_status"] = "unPaid"
            }

            dic["order_sync_type"] = order.order_sync_type.rawValue
            dic["pickup_user_id"] = order.pickup_user_id
            dic["pickup_write_date"] = order.pickup_write_date
            dic["pickup_write_user_id"] = order.pickup_write_user_id
            var voidUids:[String] = []
            order.pos_order_lines.forEach{ line in
                if line.is_void ?? false {
                    voidUids.append(line.uid)
                }
                if line.is_combo_line ?? false {
                    voidUids.append(contentsOf: line.selected_products_in_combo.filter({$0.is_void ?? false}).compactMap({$0.uid}))
                }
            }
            
            dic["void_uid_lines"] = voidUids


            var ms_info:[String:Any] = [:]
            
            let created = [
                "user": [
                    "id": order.create_user_id  ?? 0,
                    "name":  order.create_user_name ?? ""
                ],
                "pos": [
                    "id":  order.create_pos_id ?? 0,
                    "name": order.create_pos_name ?? "",
                    "code": order.create_pos_code ?? ""

                ]
            ]
            
            
            ms_info["created"] = created
            
            if order.write_user_id != nil
            {
                let changed = [
                    "user": [
                        "id": order.write_user_id ?? 0,
                        "name": order.write_user_name ?? ""
                    ],
                    "pos": [
                        "id": order.write_pos_id ?? 0,
                        "name": order.write_pos_name ?? "",
                        "code": order.write_pos_code ?? ""

                    ]
                ]
                
                ms_info["changed"] = changed
                
                
            }
            
            
            
            dic["ms_info"] = ms_info
            
        }
        SharedManager.shared.printLog(dic.jsonString() ?? "")
        return dic
    }
    
    
    static func get_ms_info(line:pos_order_line_class,for_pool:pos_multi_session_sync_class?) -> [String:Any]
    {
        var ms_info:[String:Any] = [:]
        
        if for_pool != nil
        {
            
            let created = [
                "user": [
                    "id": line.create_user_id  ?? 0,
                    "name":  line.create_user_name ?? ""
                ],
                "pos": [
                    "id":  line.create_pos_id ?? 0,
                    "name": line.create_pos_name ?? ""
                ]
            ]
            
            
            ms_info["created"] = created
            
            if line.write_user_id != nil
            {
                let changed = [
                    "user": [
                        "id": line.write_user_id ?? 0,
                        "name": line.write_user_name ?? ""
                    ],
                    "pos": [
                        "id": line.write_pos_id ?? 0,
                        "name": line.write_pos_name ?? ""
                    ]
                ]
                
                ms_info["changed"] = changed
                
                
            }
            
        }
        
        return ms_info
    }
    static func get_products_lines(order:pos_order_class,  for_pool:pos_multi_session_sync_class?) -> [Any]
    {
        var lines: [Any] = []
        
        let pos = SharedManager.shared.posConfig()
        

        var writeDateMultisessionLine =  baseClass.get_date_now_formate_datebase()
        var writeDateMultisessionAddOn =  baseClass.get_date_now_formate_datebase()

        for line in order.pos_order_lines {
            if !(line.pos_multi_session_write_date ?? "").isEmpty{
                writeDateMultisessionLine = line.pos_multi_session_write_date ?? ""
            }
            
//            let line = pos_order_line_class.get(order_id: order.id!, product_id: p.product_id!)
//
//            if  line == nil   {
//                return []
//            }
           
            // force validate line discount
            if line.is_void == false && line.product_id! != pos.discount_program_product_id
            {
                
                
                let product_id  = line.product_id!
                let product_name  = line.product.display_name ?? ""

                let product_tmpl_id  = line.product_tmpl_id ?? 0

                var price_unit:Decimal  =  line.price_unit?.rounded_formated() ?? 0 // product.price_app_priceList.rounded_formated()
                
                
                var discount =  line.discount //product.discount
                let isNotPool = for_pool == nil
                
                let qty = line.qty  // product.qty_app
                let price_subtotal  =  line.price_subtotal  // product.tax_total_excluded_app.rounded_formated()
                let price_subtotal_incl  = line.price_subtotal_incl //product.tax_total_included_app.rounded_formated()
                
                let tax_id:[Any] =   [[ 6, false, line.product.get_taxes_id(posLine: line) ]]
                
                var combo_ext_line_info:[Any] = []
                var total_extra_price = 0.0
                
                let line_uid = line.uid //String(format: "%@-%d", order.uid!,line.product_id!)
                
                let ms_info:[String:Any] = get_ms_info(line: line,for_pool: for_pool)
                
                let discount_display_name = line.discount_display_name ?? ""
                let pos_promotion_id = line.pos_promotion_id ?? 0
                let pos_conditions_id = line.pos_conditions_id ?? 0
                
                var promotion_discount_amount = 0.0
                if pos_promotion_id != 0
                {
                    promotion_discount_amount = discount ?? 0
                }
                
  
                if line.is_combo_line == true
                {
                    var lines_in_combo:[pos_order_line_class] = []
                    if for_pool != nil
                    {
                        lines_in_combo = pos_order_line_class.get_all_lines_in_combo(order_id: order.id!, product_id: product_id,parent_line_id:line.id )
                    }
                    else
                    {
                        lines_in_combo = pos_order_line_class.get_lines_in_combo(order_id: order.id!, product_id: product_id,parent_line_id:line.id)
                        
                    }
                    
                    if lines_in_combo.count > 0
                    {
                        
                        for line_combo in lines_in_combo
                        {
                            if !(line_combo.pos_multi_session_write_date ?? "").isEmpty{
                                writeDateMultisessionAddOn = line_combo.pos_multi_session_write_date ?? ""
                            }
                            let ms_info:[String:Any] = get_ms_info(line: line_combo,for_pool: for_pool)

                            let extra_price = line_combo.extra_price ?? 0
                            total_extra_price = total_extra_price + extra_price
                            let parent_line_id =  line_combo.parent_line_id
                            let combo_name = line_combo.product.display_name ?? ""
                            let combo_row = [0, 0, [
                                "product_id": line_combo.product_id!,
                                "product_name": combo_name,
                                "qty": line_combo.qty ,
                                "id": line_combo.combo_id!,
                                "price_unit": line_combo.price_unit ?? 0 , //line_combo.extra_price ?? 0 ,
                                "price_subtotal":  line_combo.price_subtotal! ,
                                "price_subtotal_incl":  line_combo.price_subtotal_incl! ,
                                "product_tmpl_id" : line_combo.product_tmpl_id ?? 0,
                                "kitchen_status": line.kitchen_status.rawValue,
                                "create_date": (line.create_date ?? "")!,
                                "write_date": (line.write_date ?? "")!,
                                "auto_select_num": (line_combo.auto_select_num ?? 0),
                                "combo_id": (line_combo.combo_id ?? 0) ,
                                "is_void": (line_combo.is_void!.toInt  ),
                                "extra_price": extra_price,
                                "parent_line_id": parent_line_id,
                                "printed": ptint_status_enum.printed.rawValue,
                                "uid" : line_combo.uid,
                                "ms_info" : ms_info,
                                "last_qty":line_combo.last_qty,
                                "is_combo_line":line_combo.is_combo_line ?? false,

                                "pos_multi_session_write_date": writeDateMultisessionAddOn
                                ]] as [Any]
                            
                            combo_ext_line_info.append(combo_row)
                        }
                    }
                }
                
    
          
                let kds_preparation_item_time = (line.kds_preparation_item_time  ?? 0)
                
                if (pos_promotion_id != 0)
                {
                    price_unit = Decimal((price_subtotal_incl ?? 0) / qty)
                    discount = 0
                }

                if isNotPool{
                    discount = 0
                }

                let row:[Any] =
                    [0, 0,
                     [
                        "product_id":  product_id ,
                        "product_name": product_name,
                        "price_unit":  price_unit ,
                        "discount":  discount! ,
                        "pos_promotion_id" : pos_promotion_id,
                        "pos_conditions_id" : pos_conditions_id,
                        "promotion_discount_amount" : promotion_discount_amount,
                        "discount_display_name" : discount_display_name ,
                        "product_tmpl_id" : product_tmpl_id,
                        "qty":  qty ,
                        "price_subtotal":  price_subtotal! ,
                        "price_subtotal_incl":  price_subtotal_incl! ,
                        "tax_ids": tax_id,
                        "id": 1,
                        "uid" : line_uid ,
                        "pack_lot_ids": [],
                        "combo_ext_line_info" : combo_ext_line_info,
                        "ms_info" : ms_info,
                        "kitchen_status": line.kitchen_status.rawValue,
                        "combo_id": (line.combo_id ?? 0)!,
                        "extra_price": line.extra_price ?? 0,
                        "is_void": (line.is_void!.toInt ),
                        "is_combo_line":line.is_combo_line ?? false,
                        "printed":  ptint_status_enum.printed.rawValue, //line.printed.rawValue    ,
                       
                        "last_qty":line.last_qty,
                        "pos_multi_session_write_date": writeDateMultisessionLine,
                        
                        "note" : (line.note  ?? "")!,
                        "write_date": (line.write_date ?? "")!,
                        "create_date": (line.create_date ?? "")!,
                        "preparation_item_time" : kds_preparation_item_time ,

                        ]
                ]
                
                lines.append(row)
            }
            
        }
        
        return lines
    }
    
    static  func check_service_charge_amount(order:pos_order_class,for_pool:pos_multi_session_sync_class?) -> [Any]?
    {
        if for_pool != nil {
            return nil
        }
        
        
        var line:pos_order_line_class? = nil
        if let service_charge_line = order.get_service_charge_line() , (service_charge_line.is_void ?? false) == false
        {
            line = service_charge_line
            if line != nil
            {
                line!.product.lst_price = line?.price_subtotal_incl ?? 0.0
               // line!.update_values()
                
                let product_id = line!.product_id!
                let price_unit = line!.price_unit //product.lst_price //.rounded_formated()
                let price_subtotal = line!.price_subtotal//price_subtotal! //.rounded_formated()
                let price_subtotal_incl =  line!.price_subtotal_incl//price_subtotal_incl! //.rounded_formated()
                let line_uid = line!.uid
                let line_qty = 1

                let row:[Any] =
                    [0, 0,
                     [
                        "product_id":  product_id,
                        "price_unit":  price_unit ,
                        "qty":  line_qty ,
                        "price_subtotal": price_subtotal,
                        "price_subtotal_incl":price_subtotal_incl  ,
                        "uid" : line_uid ,

                        "id": 1,
                        "pack_lot_ids": [],
                        
                        ]
                ]
                
                return row
            }
        }
        
        return nil
    }
    
    static  func check_delivery_amount(order:pos_order_class) -> [Any]?
    {
        let order_type = order.orderType
        
        if order_type == nil
        {
            return nil
        }
        var line:pos_order_line_class? = nil
        if order_type!.delivery_amount != 0 && ( order_type!.order_type == "delivery" || ((order.customer?.pos_delivery_area_id ?? 0) != 0))
        {
            if   order_type?.delivery_product_id != nil
            {
                //                let product:product_product_class! = order.orderType?.delivery_product?.product
                //                let product  = product_product_class.get(id: order_type?.delivery_product_id)
                
                 line = pos_order_line_class.get(order_id:  order.id!, product_id: order_type!.delivery_product_id)
              
                
            }else{
                if let pos_delivery_area_id = order.customer?.pos_delivery_area_id,
                   let delivery_area = pos_delivery_area_class.getBy(id: pos_delivery_area_id){
                    line = pos_order_line_class.get(order_id:  order.id ?? 0, product_id: delivery_area.delivery_product_id)
                
            }

            }
            if line != nil
            {
                line!.product.lst_price = order_type!.delivery_amount
               // line!.update_values()
                
                let product_id = line!.product_id!
                let price_unit = line!.price_unit //product.lst_price //.rounded_formated()
                let price_subtotal = line!.price_subtotal//price_subtotal! //.rounded_formated()
                let price_subtotal_incl =  line!.price_subtotal_incl//price_subtotal_incl! //.rounded_formated()
                let line_uid = line!.uid
                let line_qty = line!.qty

                let row:[Any] =
                    [0, 0,
                     [
                        "product_id":  product_id,
                        "price_unit":  price_unit ,
                        "qty":  line_qty ,
                        "price_subtotal": price_subtotal,
                        "price_subtotal_incl":price_subtotal_incl  ,
                        "uid" : line_uid ,

                        "id": 1,
                        "pack_lot_ids": [],
                        
                        ]
                ]
                
                return row
            }
        }
        
        return nil
    }
    
    static  func check_extra_fees(order:pos_order_class,for_pool:pos_multi_session_sync_class?) -> [Any]?
    {
       
        let extra_product_id = SharedManager.shared.posConfig().extra_product_id
        
        if extra_product_id == nil
        {
            return nil
        }
        let isNotPool = for_pool == nil

 
        let line = pos_order_line_class.get(order_id:  order.id!, product_id: extra_product_id!)
                if line != nil
                {
                    
 
                    
                    let product_id = line!.product_id!
                    var price_unit = line!.price_unit ?? 0.0 //product.lst_price //.rounded_formated()
                    let price_subtotal = line!.price_subtotal! //.rounded_formated()
                    let price_subtotal_incl =  line!.price_subtotal_incl! //.rounded_formated()
                    let line_uid = line!.uid
                    if isNotPool{
                        if price_unit <= 0 {
                            price_unit = price_subtotal_incl
                        }
                    }
                    let row:[Any] =
                        [0, 0,
                         [
                            "product_id":  product_id,
                            "price_unit":  price_unit ,
                            "qty":  1 ,
                            "price_subtotal": price_subtotal,
                            "price_subtotal_incl":price_subtotal_incl  ,
                            "uid" : line_uid ,

                            "id": 1,
                            "pack_lot_ids": [],
                            
                            ]
                    ]
                    
                    return row
                }
                
            
    
        
        return nil
    }
    
    
    static func check_discountProgram(order:pos_order_class,for_pool:pos_multi_session_sync_class?) -> [Any]?
    {
        let isNotPool = for_pool == nil
        let line_discount = order.get_discount_line()
        if line_discount == nil {
            return nil
        }
        
        if line_discount!.price_unit != 0
        {
            let discount_product = line_discount!.product!
            //            discount_product.lst_price = discount_product.price_app_priceList
            //            discount_product.update_values()
            
            let tax_id_discount:[Any] =   [[ 6, false, discount_product.get_taxes_id(posLine: line_discount) ]]
            var disscount_value = 0.0
            if line_discount?.discount_type == discountType.percentage {
                disscount_value =  line_discount!.discount ?? 0/0 //.rounded_formated()
            }
            let product_id = line_discount!.product!.id
            let price_unit =  line_discount!.price_unit! //.rounded_formated()
            let price_subtotal =  line_discount!.price_subtotal! //.rounded_formated()
            let price_subtotal_incl = line_discount!.price_subtotal_incl! //.rounded_formated()
            
            let line_uid = line_discount!.uid //String(format: "%@-%d", order.uid!,product_id)
            let discount_program_id = line_discount!.discount_program_id
            
            let pos_promotion_id = line_discount!.pos_promotion_id ?? 0
            let pos_conditions_id = line_discount!.pos_conditions_id ?? 0
            
            var promotion_discount_amount = 0.0
            if pos_promotion_id != 0
            {
                promotion_discount_amount = Double("\(price_subtotal_incl ?? 0)") ?? 0
                promotion_discount_amount = abs(promotion_discount_amount)
            }
            
            var disscountValue =  line_discount?.discount ?? 0
            if isNotPool{
                disscountValue = 0
            }
            let row:[Any] =
                [0, 0,
                 [
                    "product_id":  product_id ,
                    "price_unit": price_unit ,
                    "discount_extra_fees":disscount_value,
                    "discount":  disscountValue,
                    "discount_program_id":  discount_program_id ,
                    "discount_display_name": line_discount?.discount_display_name ?? "",
                    "discount_type":  line_discount?.discount_type.rawValue ?? "" ,
                    "qty":  1 ,
                    "price_subtotal":  price_subtotal,
                    "price_subtotal_incl":  price_subtotal_incl ,
                    "tax_ids": tax_id_discount,
                    "id": 1,
                    "uid" : line_uid ,
                    "pos_promotion_id" : pos_promotion_id,
                    "pos_conditions_id" : pos_conditions_id,
                    "promotion_discount_amount" : promotion_discount_amount,
                    
                    "pack_lot_ids": []
                    
                    ]
            ]
            
            return row
        }
        
        return nil
    }
    
    static func get_statement_ids(order:pos_order_class) -> [Any]
    {
        let bankStatement_date:String = Date().toString(dateFormat: "yyyy-MM-dd HH:mm:ss", UTC: false) //ClassDate.getNow("yyyy-MM-dd HH:mm:ss")  //"2019-08-21T00:31:11.926Z"
        
        var statement_ids:[Any] = []
        for item in order.get_bankStatement()
        {
            let amount = item.tendered!.toDouble()! + item.changes!
            let amount_formated = amount //.rounded_formated()
            
            
            let statement = [
                0,
                0,
                [
                    "name":  bankStatement_date ,
                    "statement_id": 0,
                    "journal_id": item.account_Journal_id,
                    "amount": amount_formated
                ]
                ] as [Any]
            
            statement_ids.append(statement)
        }
        
        return statement_ids
    }
    
    static func get_tax_discount(order:pos_order_class) -> Decimal
    {
        let amount_tax = order.amount_tax //.rounded_formated()
        
        var tax_discount:Decimal =  0.0
        if order.pos?.allow_free_tax == true
        {
            tax_discount = Decimal(amount_tax)
        }
        
        return tax_discount
    }
}
