//
//  orders.swift
//  pos
//
//  Created by khaled on 8/16/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

class ordersListOpetions
{
    var Closed:Bool?
    var Sync:Bool?
    var void:Bool?
 
    var orderDesc:Bool?
    var order_by_products:Bool?
    var get_not_empty_orders:Bool?
    
    var page:Int = 0
    var LIMIT:Int = 0
    
    var orderSyncType:orderSyncType = .order
    var sesssion_id:Int  = 0
    var sesssion_ids:String?

    var pos_multi_session_status : updated_status_enum?
    var kitchen_status : kitchen_status_enum?
    
    var orderID:Int?
    var parent_orderID:Int?  // nil to get both with parent and no parent
    var parent_order:Bool? 
    var parent_product:Bool?
    
    
    var getCount:Bool? = false
    var get_lines_void:Bool? = false
    var get_lines_void_from_ui:Bool? = false
    var get_lines_void_only:Bool? = false
    var get_lines_promotion:Bool? = true

    var get_lines_scrap:Bool?
    var printed:Bool?

//    var is_menu:Bool?
    var order_integration:[ORDER_INTEGRATION]?

    var order_menu_status:[orderMenuStatus]?

    
    //    var get_products:Bool? = false
    
    var between_start_session:[String]?
    
    var name:String?
    var uid:String?
    var bill_uid:String?

    var fields:String?
    
    var write_date:String?
    var write_user_id:Int?
    
    
    // lines options
    var  lines_sort_by_category_asc:Bool?
    
    var create_pos_id : Int?
    var write_pos_id : Int?
    
    var creationDate: String? // db: "creation_date": "2020-04-08 07:23:00" ...
    var creationTime: String?
    var invoiceId: String? // db: invoice_id: 5 | "invoiceID": 5
    var orderTypeName: String? // "orderType": {"id": 1, "name": "Dine in" ...
    var customerName: String? // "customer": {"name": "Bryan Caffe", ...
    var paymentMethodName: String? // "list_bankStatement": [{"code": "BNK1", "display_name": "Bank (SAR)" | [{"code": "CSH1", "display_name": "Cash (SAR)" ...
    var cashierName: String? // "cashier": {"name": "Casher" ...
    //var sessionId: Int // db: session_id
    //    var businessDay: String? // "shift": { "start_shift" : "2020-04-08 07:22:46" ...
    var is_delivery_order: Bool?
    var driverName: String?
    var driverID : Int?
    var void_status:void_status_enum?
    var customerPhone: String?
    var customerEmail: String?
    var pickup_users_ids:[Int]?
    var has_pickup_users_ids:Bool?
    var has_write_pickup_users_ids:Bool?
    var brandIDS:[Int]?
    var deliveryTypesIDS:[Int]?
    var has_extra_product:Bool?
    var betweenDate:String?


    
}


class pos_order_helper_class: NSObject {
    
    
    static  let ordersPrefix:String = "orders"
    static  let voidOrdersPrefix:String = "void"
    
    
    static func getOrders_status_sorted_Sql_for_search(options:ordersListOpetions ,getCount:Bool  ) -> String
    {
        var fields = """
               pos_order.* ,
                (
                    select count(*) from pos_order as p  where
                    p.parent_order_id = pos_order.id  and p.is_sync = 0 and
                    p.is_closed = 1 and p.order_sync_type = 0
                ) as sub_orders_count
        """
        
        if  getCount == true
        {
            fields = "count(*) "
        }
         
        // ========================================================
        // where
        
        var list_where:[String] = []
        
        if options.sesssion_id != 0
        {
            list_where.append("pos_order.session_id_local = \(options.sesssion_id)")
        }
        
        if options.sesssion_ids != nil
        {
            list_where.append("pos_order.session_id_local in( \(options.sesssion_ids!))")
        }
        
        //        if options.shift_id != 0
        //        {
        //            list_where.append("pos_order.shift_id = \(options.shift_id)")
        //        }
        
        if options.parent_orderID != nil
        {
            list_where.append("pos_order.parent_order_id = \(options.parent_orderID!)")
            
        }
        else
        {
            if options.parent_order != nil
            {
                if options.parent_order == true
                {
                    list_where.append("pos_order.parent_order_id = 0")
                    
                }
                else
                {
                    list_where.append("pos_order.parent_order_id   != 0")
                    
                }
            }
            
        }
        
        if options.void != nil
        {
            list_where.append("pos_order.is_void = \(options.void!.toInt)")
            
        }
        
        if options.Sync != nil
        {
            list_where.append("pos_order.is_sync = \(options.Sync!.toInt)")
            
        }
        
        if options.Closed != nil
        {
            list_where.append("pos_order.is_closed = \(options.Closed!.toInt)")
            
        }
        
        
        if options.orderSyncType != .all
        {
            list_where.append("pos_order.order_sync_type = \(options.orderSyncType.rawValue)")
        }
        
        
        if options.between_start_session != nil
        {
            let fromDay = options.between_start_session![0]
            let toDay = options.between_start_session![1]
            
            if fromDay == toDay
            {
                list_where.append("pos_session.start_session like '\(fromDay)%' ")
            }
            else
            {
                list_where.append("pos_session.start_session between '\(fromDay)' and '\(toDay)'")
                
            }
            
        }
        
        if options.name != nil
        {
            
            
            list_where.append("pos_order.name = '\( options.name! )'")
            
            //            list_where.append("REPLACE(orders.data,' ','') like '%\"orderID_server\":\"\(options.orderID_server!)%'")
            
        }
        
        if options.uid != nil
        {
            
            
            list_where.append("pos_order.uid = '\( options.uid! )'")
            
            //            list_where.append("REPLACE(orders.data,' ','') like '%\"orderID_server\":\"\(options.orderID_server!)%'")
            
        }
        if options.bill_uid != nil
        {
            
            
            list_where.append("pos_order.bill_uid = '\( options.bill_uid! )'")
            
            //            list_where.append("REPLACE(orders.data,' ','') like '%\"orderID_server\":\"\(options.orderID_server!)%'")
            
        }
        
        if options.orderID != nil
        {
            list_where.append("pos_order.id = \( options.orderID! )")
        }
        
        if options.get_not_empty_orders != nil
        {
            if options.get_not_empty_orders == true
            {
                list_where.append("pos_order.amount_total != 0")
            }
        }
        
        if options.write_date != nil
        {
            list_where.append("pos_order.write_date  >= '\( options.write_date! )'")
        }
        
        if options.write_user_id != nil
        {
            list_where.append("pos_order.write_user_id  = \( options.write_user_id! )")
        }
        
        if options.create_pos_id != nil
        {
            list_where.append("pos_order.create_pos_id  = \( options.create_pos_id! )")
        }
        
        if options.write_pos_id != nil
        {
            list_where.append("pos_order.write_pos_id  = \( options.write_pos_id! )")
        }
        
        
        if options.pos_multi_session_status != nil && options.kitchen_status == nil
        {
            
            
            list_where.append(" pos_order.id IN  (SELECT order_id FROM  pos_order_line where  pos_order_line.pos_multi_session_status  = \( options.pos_multi_session_status!.rawValue  ) GROUP BY order_id ) " )
            
        }
        
        if options.pos_multi_session_status == nil && options.kitchen_status != nil
        {
            
            list_where.append(" pos_order.id IN  (SELECT order_id FROM  pos_order_line where  pos_order_line.kitchen_status  = \( options.kitchen_status!.rawValue  ) GROUP BY order_id ) " )
            
        }
        
        if options.pos_multi_session_status != nil && options.kitchen_status != nil
        {
            
            list_where.append(" pos_order.id IN  (SELECT order_id FROM  pos_order_line where  pos_order_line.kitchen_status  = \( options.kitchen_status!.rawValue  ) and pos_order_line.pos_multi_session_status  = \( options.pos_multi_session_status!.rawValue  ) GROUP BY order_id ) " )
            
        }
        var contaidation_customer:[String] = []
        if options.customerName != nil
        {
            let name_cusstomer = options.customerName!
            if !name_cusstomer.isEmpty{
                contaidation_customer.append(" name like '%\(name_cusstomer)%'")
            }
        }
        if options.customerPhone != nil{
            let phone_customer = options.customerPhone ?? ""
            if !phone_customer.isEmpty{
                contaidation_customer.append("phone like '%\(phone_customer)%'")
            }
        }
        if options.customerEmail != nil{
            let email_customer = options.customerEmail ?? ""
            if !email_customer.isEmpty{
                contaidation_customer.append("email like '%\(email_customer)%'")
            }
        }
        if contaidation_customer.count > 0{
            list_where.append("pos_order.partner_row_id  in (SELECT row_id from res_partner where " +  contaidation_customer.joined(separator: " and ") + " )")
        }
        if let betweenDate = options.betweenDate {
            list_where.append("strftime('%Y-%m-%d %H:%M', pos_order.create_date) BETWEEN \(betweenDate)")
        }
        
        
        if let creationDate = options.creationDate {
            list_where.append("pos_order.create_date like '\(creationDate)%'")
        }
        
        if let creationTime = options.creationTime {
            list_where.append("pos_order.create_date like '%\(creationTime)%'")
        }
        
        // other fields -- where
        if let invoiceId = options.invoiceId {
            list_where.append("(pos_order.name || ' ' || pos_order.id)  like '%\(invoiceId)%'")
        }
        
        if let cashierName = options.cashierName {
            list_where.append("pos_order.write_user_name like '%\(cashierName)%'")
        }
        if options.driverName != nil
        {
            list_where.append(" pos_order.driver_id  in (SELECT id from pos_driver_class where name like '%\(options.driverName!)%')" )

        }
        if options.driverID != nil
        {
            list_where.append(" pos_order.driver_id = \(options.driverID!) " )

        }
        
        
        // ========================================================
        
        var sql = ""
        
        var and = ""
        for wh in list_where
        {
            sql = String(format: "%@ %@ %@", sql , and , wh)
            
            if and == ""
            {
                and = "and"
            }
        }
        
        var join_session = ""
        
        if sql.contains("pos_session")
        {
            join_session = " inner join pos_session on pos_order.session_id_local = pos_session.id "
        }
        
        // other fields -- join
        if let orderTypeName = options.orderTypeName {
            join_session.append(" inner join delivery_type dt on dt.name LIKE '%\(orderTypeName)%' AND pos_order.delivery_type_id = dt.id  ")
        }
        
        if let paymentMethodName = options.paymentMethodName {
            join_session.append(" inner join account_journal aj on aj.display_name LIKE '%\(paymentMethodName)%' AND pos_order.payment_journal_id = aj.id  ")
        }
        
        sql = "select \(fields) from pos_order \(join_session) where " + sql
        
        
        
        
        
        if options.orderDesc == false
        {
            sql = String(format: "%@ %@", sql , " order by pos_order.id asc")
        }
        else
        {
            sql = String(format: "%@ %@", sql , " order by pos_order.id desc")
            
        }
        
        if options.LIMIT != 0
        {
            let start = options.page * options.LIMIT
            sql = String(format: "%@ LIMIT %d,%d", sql ,start, options.LIMIT)
            
        }
        
        return sql
    }
    
    
    

    static func getOrders_status_sorted_Sql(options:ordersListOpetions ,getCount:Bool  ) -> String
    {
        var fields = """
               pos_order.* ,
                (
                    select count(*) from pos_order as p  where
                    p.parent_order_id = pos_order.id   and
                    p.is_closed = 1 and p.order_sync_type = 0
                ) as sub_orders_count
        """

        if  getCount == true
        {
            fields = "count(*) "
        }

        // ========================================================
        // where

        var list_where:[String] = []
        if let has_pickup_users_ids = options.has_pickup_users_ids , has_pickup_users_ids {
            if let has_write_pickup_users_ids = options.has_write_pickup_users_ids , has_write_pickup_users_ids {
                list_where.append("(pos_order.pickup_user_id != 0 or pos_order.pickup_write_user_id != 0 )")

            }else{
                list_where.append("pos_order.pickup_user_id != 0")
            }
        }
        if let pickup_users_ids = options.pickup_users_ids {
            
            list_where.append("pos_order.pickup_user_id in ( \(pickup_users_ids.map({"\($0 )" }).joined(separator: ", ") ) )")
        }
        
        if options.sesssion_id != 0
        {
            list_where.append("pos_order.session_id_local = \(options.sesssion_id)")
        }

        if options.sesssion_ids != nil
        {
            list_where.append("pos_order.session_id_local in( \(options.sesssion_ids!))")
        }
        if let betweenDate = options.betweenDate {
            list_where.append("strftime('%Y-%m-%d %H:%M', pos_order.create_date) BETWEEN \(betweenDate)")
        }
        if let brandIds = options.brandIDS , brandIds.count > 0 {
            let brandIdsFilter = brandIds.filter({$0 > 0}).map({"\($0)"})
            if brandIdsFilter.count > 0{
                let brandIdsString = brandIdsFilter.joined(separator: ", ")
                list_where.append("pos_order.brand_id in( \(brandIdsString))")

            }
        }
        if let deliveryIds = options.deliveryTypesIDS , deliveryIds.count > 0 {
            let deliveryIdsFilter = deliveryIds.filter({$0 > 0}).map({"\($0)"})
            if deliveryIdsFilter.count > 0{
                let deliveryIdsString = deliveryIdsFilter.joined(separator: ", ")
                list_where.append("pos_order.delivery_type_id in( \(deliveryIdsString))")

            }
        }
        
        //        if options.shift_id != 0
        //        {
        //            list_where.append("pos_order.shift_id = \(options.shift_id)")
        //        }

        if options.parent_orderID != nil
        {
            list_where.append("pos_order.parent_order_id = \(options.parent_orderID!)")

        }
        else
        {
            if options.parent_order != nil
            {
                if options.parent_order == true
                {
                    list_where.append("pos_order.parent_order_id = 0")

                }
                else
                {
                    list_where.append("pos_order.parent_order_id   != 0")

                }
            }

        }

        if options.void != nil
        {
            list_where.append("pos_order.is_void = \(options.void!.toInt)")
            if options.void!.toInt == 0 {
                list_where.append("pos_order.void_status = 0")
            }

        }

        if options.Sync != nil
        {
            list_where.append("pos_order.is_sync = \(options.Sync!.toInt)")

        }
        
      
        
        

        if options.Closed != nil
        {
            list_where.append("pos_order.is_closed = \(options.Closed!.toInt)")

        }


        if options.orderSyncType != .all
        {
            list_where.append("pos_order.order_sync_type = \(options.orderSyncType.rawValue)")
        }


        if options.between_start_session != nil
        {
            let fromDay = options.between_start_session![0]
            let toDay = options.between_start_session![1]

            if fromDay == toDay
            {
                list_where.append("pos_session.start_session like '\(fromDay)%' ")
            }
            else
            {
                list_where.append("pos_session.start_session between '\(fromDay)' and '\(toDay)'")

            }

        }

        if options.name != nil
        {


            list_where.append("pos_order.name = '\( options.name! )'")

            //            list_where.append("REPLACE(orders.data,' ','') like '%\"orderID_server\":\"\(options.orderID_server!)%'")

        }

        if options.uid != nil
        {


            list_where.append("pos_order.uid = '\( options.uid! )'")

            //            list_where.append("REPLACE(orders.data,' ','') like '%\"orderID_server\":\"\(options.orderID_server!)%'")

        }

        if options.orderID != nil
        {
            list_where.append("pos_order.id = \( options.orderID! )")
        }

        if options.get_not_empty_orders != nil
        {
            if options.get_not_empty_orders == true
            {
                list_where.append("pos_order.amount_total != 0")
            }
        }

        if options.write_date != nil
        {
            list_where.append("datetime(pos_order.write_date)  >= '\( options.write_date! )'")
        }

        if options.write_user_id != nil
        {
            list_where.append("pos_order.write_user_id  = \( options.write_user_id! )")
        }

        if options.create_pos_id != nil
        {
            list_where.append("pos_order.create_pos_id  = \( options.create_pos_id! )")
        }

        if options.write_pos_id != nil
        {
            list_where.append("pos_order.write_pos_id  = \( options.write_pos_id! )")
        }


        if options.pos_multi_session_status != nil && options.kitchen_status == nil
        {


            list_where.append(" pos_order.id IN  (SELECT order_id FROM  pos_order_line where  pos_order_line.pos_multi_session_status  = \( options.pos_multi_session_status!.rawValue  ) GROUP BY order_id ) " )

        }

        if options.pos_multi_session_status == nil && options.kitchen_status != nil
        {

            list_where.append(" pos_order.id IN  (SELECT order_id FROM  pos_order_line where  pos_order_line.kitchen_status  = \( options.kitchen_status!.rawValue  ) GROUP BY order_id ) " )

        }

        if options.pos_multi_session_status != nil && options.kitchen_status != nil
        {

            list_where.append(" pos_order.id IN  (SELECT order_id FROM  pos_order_line where  pos_order_line.kitchen_status  = \( options.kitchen_status!.rawValue  ) and pos_order_line.pos_multi_session_status  = \( options.pos_multi_session_status!.rawValue  ) GROUP BY order_id ) " )

        }


        if let creationDate = options.creationDate {
            list_where.append("pos_order.create_date like '\(creationDate)%'")
        }

        if let creationTime = options.creationTime {
            list_where.append("pos_order.create_date like '%\(creationTime)%'")
        }

        if let invoiceId = options.invoiceId {
            list_where.append("pos_order.sequence_number = \(invoiceId)")
        }

        // ========================================================
        // Menu

        if let integration = options.order_integration
        {
            if options.order_menu_status != nil
            {
                let menuStatusIds = options.order_menu_status!.map({"\($0.rawValue)"}).joined(separator: ", ")
                
                list_where.append("pos_order.order_menu_status in ( \(menuStatusIds) ) and pos_order.order_integration in (\(integration.map({"\($0.rawValue)"}).joined(separator: ", ")))")

            }
        }
        else
        {
            if options.order_menu_status != nil
            {
                if  ((options.order_menu_status?.count ?? 0) == 1) && ((options.order_menu_status?.first ?? orderMenuStatus.none ) != orderMenuStatus.none)
                {
                    let menuStatusIds = options.order_menu_status!.map({"\($0.rawValue)"}).joined(separator: ", ")

                    list_where.append("pos_order.order_menu_status in ( 0,  \(menuStatusIds) ) ")
                }else{
                    let menuStatusIds = options.order_menu_status!.map({"\($0.rawValue)"}).joined(separator: ", ")

                    list_where.append("pos_order.order_menu_status in ( \(menuStatusIds) ) ")

                }

            }
        }
        
       
        if options.is_delivery_order != nil
        {
            if options.is_delivery_order == true
            {
                list_where.append("pos_order.delivery_type_id in (SELECT id from delivery_type where delivery_type.required_driver = 1)")
               
//                list_where.append("pos_order.driver_id != 0 OR pos_order.driver_id != null  ")

            }else{
                list_where.append("pos_order.delivery_type_id in (SELECT id from delivery_type where delivery_type.required_driver = 0)")

//                list_where.append("pos_order.driver_id == 0 OR pos_order.driver_id == null  ")
            }
        }
        if let driver_id = options.driverID {
            list_where.append("pos_order.driver_id = \(driver_id)  ")

        }
        
        
        // ========================================================

        var sql = ""

        var and = ""
        for wh in list_where
        {
            sql = String(format: "%@ %@ %@", sql , and , wh)

            if and == ""
            {
                and = "and"
            }
        }

        var join_session = ""

        if sql.contains("pos_session")
        {
            join_session = " inner join pos_session on pos_order.session_id_local = pos_session.id "
        }




        sql = "select \(fields) from pos_order \(join_session) where " + sql





        if options.orderDesc == false
        {
            sql = String(format: "%@ %@", sql , " order by pos_order.id asc")
        }
        else
        {
            sql = String(format: "%@ %@", sql , " order by pos_order.id desc")

        }

        if options.LIMIT != 0
        {
            let start = options.page * options.LIMIT
            sql = String(format: "%@ LIMIT %d,%d", sql ,start, options.LIMIT)

        }

        return sql
    }
    
    static func get_count(sql:String ) -> Int
    {
        
        
        var totalCount = 0
        let semaphore = DispatchSemaphore(value: 0)
        
        SharedManager.shared.database_db!.inDatabase { (db:FMDatabase) in
            
            let rows:FMResultSet = try!   db.executeQuery(sql, values: [])
            if (rows.next()) {
                //retrieve values for each record
                totalCount = Int(rows.int(forColumnIndex: 0))
                
            }
            
            rows.close()
            
            semaphore.signal()
        }
        
        
        semaphore.wait()
        
        
        return totalCount
    }
    
    static func getOrders_status_sorted_count(options:ordersListOpetions ) -> Int
    {
        
        let sql = getOrders_status_sorted_Sql(options:options ,getCount: true)
        let totalCount = get_count(sql: sql)
        
        
        
        return totalCount
    }
    
      func getOrders_status_sorted(options:ordersListOpetions ) -> [pos_order_class]
       {
           var list:[pos_order_class] = []
           
           // =====================================================================================
        let sql = pos_order_helper_class.getOrders_status_sorted_Sql(options: options,getCount: false)
           
           let cls = pos_order_class(fromDictionary: [:])
           let arr  = cls.dbClass!.get_rows(sql: sql)
           
           for item in arr
           {
               let cls:pos_order_class = pos_order_class(fromDictionary: item ,options_order: options )
               list.append(cls)
               
           }
           
         
           return list
       }
    static func getCountPrndingOrders() -> Int
    {
        let sql = """
                SELECT COUNT(*) as cnt from
                pos_order po WHERE
                po.is_sync = 0
                and po.is_closed = 1
                and po.is_void = 0
                and po.void_status = 0
                and po.order_sync_type = 0
                and po.write_pos_id = \(SharedManager.shared.posConfig().id)
            """
        let cls = pos_order_class(fromDictionary: [:])
        let count:[String:Any]  = cls.dbClass!.get_row(sql: sql) ?? [:]
        return count["cnt"] as? Int ?? 0
    }
    
    static func getOrders_status_sorted(options:ordersListOpetions,needProduct:Bool = true ) -> [pos_order_class]
    {
        var list:[pos_order_class] = []
        
        // =====================================================================================
        let sql = getOrders_status_sorted_Sql(options: options,getCount: false)
        
        let cls = pos_order_class(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(sql: sql)
        
        for item in arr
        {
            let cls:pos_order_class = pos_order_class(fromDictionary: item ,options_order: options,needProduct:needProduct )
            list.append(cls)
            
        }
        
        // =====================================================================================
        
        //        let semaphore = DispatchSemaphore(value: 0)
        //        SharedManager.shared.data_db!.inDatabase { (db:FMDatabase) in
        //
        //            let rows:FMResultSet = try!   db.executeQuery(sql, values: [])
        //            while (rows.next()) {
        //                //retrieve values for each record
        //                let data = rows.string(forColumn: "data")
        //                let dic =  data?.toDictionary() ?? [:]
        //
        //                let cls = posOrderClass(fromDictionary: dic)
        //
        //                cls.id = Int(rows.int(forColumn: "id"))
        //                cls.invoice_id = Int(rows.int(forColumn: "invoice_id"))
        //
        //
        //
        //                list.append(cls)
        //            }
        //
        //            rows.close()
        //
        //            semaphore.signal()
        //        }
        //
        //
        //        semaphore.wait()
        // =====================================================================================
        
        return list
    }
    
    static func getOrders_status_sorted_for_search(options:ordersListOpetions ) -> [pos_order_class]
    {
        var list:[pos_order_class] = []
        
        // =====================================================================================
        let sql = getOrders_status_sorted_Sql_for_search(options: options,getCount: false)
        
        let cls = pos_order_class(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(sql: sql)
        
        for item in arr
        {
            let cls:pos_order_class = pos_order_class(fromDictionary: item ,options_order: options )
            list.append(cls)
            
        }
        
        return list
    }
 
     
    static func get_new_order_id_server(sequence_number:Int) -> String
    {
        let pos = SharedManager.shared.posConfig()
        
        let newID   = baseClass.getTimeINMS() / 1000 //ClassDate.getTimeINMS()!.toInt()!

        var orderID_server = ""
        if pos.code.isEmpty
        {
            //        let orderID_server = String(format: "%@-%@-%@",String( newID) ,
            //                                    String(pos.id).leftPadding(toLength: 3, withPad: "0") ,
            //                                    String(sequence_number).leftPadding(toLength: 4, withPad: "0")   )
                      orderID_server = String(format: "%@-%@-%@",String( newID) ,
                                                String(pos.id)  ,
                                                String(sequence_number)   )
        }
        else
        {
            orderID_server = String(format: "%@-%@-%@",String( newID) ,
                                                        String(pos.code)  ,
                                                        String(sequence_number)   )
        }
        
  
        return orderID_server
    }
    static func creatNewOrder(lastOrderID:Int? = nil, isSave:Bool = true)-> pos_order_class   {
        //        let newID :Int = getLastID() + 1
        
        
        let activeSession = pos_session_class.getActiveSession()
        
        let orderNew:pos_order_class = pos_order_class(fromDictionary: [:])
        if SharedManager.shared.isSequenceAtMasterOnly(){
            orderNew.sequence_number =  MWConstantLocalNetwork.defaultSequence
        }else{
            if SharedManager.shared.appSetting().enable_sync_order_sequence_wifi{
                let ipSequence = sequence_session_ip.shared.completeGetSequenceFromMaster()
                orderNew.sequence_number =  ipSequence
            }else{
                let invoiceID = orderNew.generateInviceID(session_id: activeSession!.id )
                if let lastOrderID = lastOrderID , lastOrderID > invoiceID {
                    orderNew.sequence_number =  lastOrderID
                }else{
                    orderNew.sequence_number =  invoiceID
                }
            }
        }
        
        orderNew.is_closed = false
        orderNew.is_sync = false
        orderNew.session_id_local = activeSession?.id
        orderNew.user_id = SharedManager.shared.activeUser().id
        orderNew.pricelist_id = product_pricelist_class.getDefault()?.id
        
        let pos = SharedManager.shared.posConfig()
        orderNew.pos_id = pos.id
        orderNew.company_id = pos.company_id
        orderNew.delivery_type_id = pos.delivery_method_id
        
        orderNew.pos_order_lines = []
        
        //
        
        orderNew.create_date =  baseClass.get_date_now_formate_datebase()
        
        // date P(POSID) C(CasherID) I(InvoiceID) S(SessionID)
        //    let orderID = String(format: "%dP%dC%dI%dS%d", newID , orderNew.pos?.id ?? 0 ,orderNew.cashier?.id ?? 0  , orderNew.invoiceID , activeSession.id  )
        
        
        
        //     orderNew.orderID = orderID
        
        
        let user = SharedManager.shared.activeUser()
        orderNew.create_user_id = user.id
        orderNew.create_user_name = user.name
        
        orderNew.create_pos_id = pos.id
        orderNew.create_pos_name = pos.name
        orderNew.create_pos_code = pos.code
        
        
        //        eturn zero_pad(this.pos.pos_session.id,5) +'-'+
        //        zero_pad(this.pos.pos_session.login_number,3) +'-'+
        //        zero_pad(this.sequence_number,4);
        
        //          let newID   = baseClass.getTimeINMS() / 1000 //ClassDate.getTimeINMS()!.toInt()!
        //        let orderID_server = String(format: "%@-%@-%@",String( newID) ,
        //                                    String(user.id).leftPadding(toLength: 3, withPad: "0") ,
        //                                    String(orderNew.sequence_number).leftPadding(toLength: 4, withPad: "0")   )
        
        // pos_id-invoice_num  001-005
        
        //        let orderID_server = String(format: "%@-%@-%@",
        //                                          String(pos.id).leftPadding(toLength: 3, withPad: "0") ,
        //                                          String(user.id).leftPadding(toLength: 3, withPad: "0") ,
        //                                          String(orderNew.sequence_number).leftPadding(toLength:3, withPad: "0")   )
        
        let orderID_server =  get_new_order_id_server(sequence_number: orderNew.sequence_number )
        orderNew.name = String(format: "Order-%@",orderID_server )   //formateOrderID(orderID: orderID_server)
        orderNew.uid = orderID_server
        
        if isSave{
        orderNew.save()
        }
        
        //        myuserdefaults.setitems(  orderNew.orderID, setValue: orderNew.toDictionary(), prefix: ordersListClass.ordersPrefix)
        
        
        //        myuserdefaults.setitems("ID", setValue:  orderNew.orderID , prefix: "neworder")
        
        
        return orderNew
    }
     
    static func formateOrderID(orderID:String) -> String
    {
        var txt:String  = orderID
        if txt.count > 10 {
            txt.insert("-", at: txt.index(txt.startIndex, offsetBy: 5))
            txt.insert("-", at: txt.index(txt.startIndex, offsetBy: 10))
            
        }
        
        return txt
    }
     
    static func getOrders_void() -> [pos_order_class]
    {
        var list:[pos_order_class] = []
        
        //        var arr_dic = myuserdefaults.lstitems(ordersListClass.voidOrdersPrefix) as? [[String : Any]] ?? [[:]]
        //        arr_dic = Sort.sort_array_(of_dic_bykey: arr_dic, key: "invoiceID", ascending: false) as! [[String : Any]]
        //
        //        for item in arr_dic
        //        {
        //            let obj = orderClass(fromDictionary: item)
        //            if   obj.orderSyncType == order_Sync_Type.order
        //            {
        //                list.append(obj)
        //            }
        //
        //        }
        
        let sql = "select * from pos_order where is_void = 1 "
        
        let semaphore = DispatchSemaphore(value: 0)
        SharedManager.shared.database_db!.inDatabase { (db:FMDatabase) in
            
            let rows:FMResultSet = try! db.executeQuery(sql, values: [])
            while (rows.next()) {
                //retrieve values for each record
                let data = rows.string(forColumn: "data")
                let dic =  data?.toDictionary() ?? [:]
                
                let cls = pos_order_class(fromDictionary: dic)
                
                cls.id = Int(rows.int(forColumn: "id"))
                cls.sequence_number = Int(rows.int(forColumn: "sequence_number"))
                
                
                list.append(cls)
            }
            rows.close()
            
            semaphore.signal()
        }
        
        
        semaphore.wait()
        
        return list
    }
     
    static func readOrders(arr :[Any]) -> [pos_order_class]
    {
        var list:[pos_order_class] = []
        
        let arr_dic = arr as? [[String : Any]] ?? [[:]]
        //        arr_dic = Sort.sort_array_(of_dic_bykey: arr_dic, key: "invoiceID", ascending: false) as! [[String : Any]]
        
        for item in arr_dic
        {
            let obj = pos_order_class(fromDictionary: item)
            
            list.append(obj)
            
            
        }
        
        return list
    }
     
    static func clear()   {
        //        myuserdefaults.deletelstitems(ordersListClass.ordersPrefix)
        //        myuserdefaults.deletelstitems("neworder")
        
        
    }
    
    static func vacuum_database()
    {
        
        sql_database(sql: "vacuum")
    }
    static func sql_database(sql:String)
    {
        
        
        let semaphore = DispatchSemaphore(value: 0)
        SharedManager.shared.database_db!.inDatabase { (db:FMDatabase) in
            
            let success = db.executeUpdate(sql  , withArgumentsIn: [] )
            
            if !success
            {
                let error = db.lastErrorMessage()
               SharedManager.shared.printLog("database Error : \(error)" )
            }
            
            db.close()
            semaphore.signal()
        }
        
        
        semaphore.wait()
    }
    
    
    static  func getOrdersCount(session_id:Int ) -> Int {
        
        let sql = "select count(*) from pos_order where session_id_local =?   "
        var count = 0
        
        let semaphore = DispatchSemaphore(value: 0)
        SharedManager.shared.database_db!.inDatabase { (db:FMDatabase) in
            
            let resutl:FMResultSet = try! db.executeQuery(sql, values: [session_id ])
            if resutl.next()
            {
                count = Int(resutl.int(forColumnIndex: 0))
                
                resutl.close()
                
                
            }
            db.close()
            semaphore.signal()
        }
        
        
        semaphore.wait()
        
        return count
    }
    
    
    static func delete_all_order()
    {
        
        let remove_pos_order_sql = " delete from pos_order "
        
        let remove_pos_order_line_sql = "DELETE  FROM  pos_order_line  "
        
        let  remove_pos_order_account_journal = "delete from pos_order_account_journal "
        
        
        let semaphore = DispatchSemaphore(value: 0)
        
        SharedManager.shared.database_db!.inTransaction { db, rollback in
            do {
                try db.executeUpdate(remove_pos_order_line_sql, values: [])
                try db.executeUpdate(remove_pos_order_account_journal, values: [])
                try db.executeUpdate(remove_pos_order_sql, values: [])
                
                
                
            } catch {
                rollback.pointee = true
                 SharedManager.shared.printLog(error)
            }
            
            semaphore.signal()
        }
        
        
        
        semaphore.wait()
        
        vacuum_database()
        
    }
    
    static func delete_old_order(older_than_date:String,is_pendding:Bool = false)
    {
        
        //        sql_database(sql: "PRAGMA foreign_keys = ON;")
        
        var where_sql = "is_sync = 1 and create_date < ?  and  create_date != '' "
        
        var remove_pos_order_sql = " delete from pos_order  where  \(where_sql)"
        if is_pendding == true
        {
            where_sql = "is_closed = 0 and create_date < ? and  create_date != '' "
            remove_pos_order_sql = "delete from pos_order  where   \(where_sql)"
        }
        
        let remove_pos_order_line_sql = "DELETE  FROM  pos_order_line  where order_id  = (SELECT id FROM pos_order where  \(where_sql))"
        
        let  remove_pos_order_account_journal = "delete from pos_order_account_journal where order_id  = (SELECT id FROM pos_order where  \(where_sql))"
        
        
        let semaphore = DispatchSemaphore(value: 0)
        
        SharedManager.shared.database_db!.inTransaction { db, rollback in
            do {
                try db.executeUpdate(remove_pos_order_line_sql, values: [older_than_date])
                try db.executeUpdate(remove_pos_order_account_journal, values: [older_than_date])
                try db.executeUpdate(remove_pos_order_sql, values: [older_than_date])
                
                
                
            } catch {
                rollback.pointee = true
                 SharedManager.shared.printLog(error)
            }
            
            semaphore.signal()
        }
        
        
        
        semaphore.wait()
        
        vacuum_database()
    }
    
    static func delete_order(order_id:Int )
    {
        
        
        let remove_pos_order_sql = "delete from pos_order  where  id = \(order_id)"
        
        
        let remove_pos_order_line_sql = "DELETE  FROM  pos_order_line  where order_id  = (SELECT id FROM pos_order where id = \(order_id))"
        
        let  remove_pos_order_account_journal = "delete from pos_order_account_journal where order_id = (SELECT id FROM pos_order where id = \(order_id))"
        
        
        let semaphore = DispatchSemaphore(value: 0)
        
        SharedManager.shared.database_db!.inTransaction { db, rollback in
            do {
                try db.executeUpdate(remove_pos_order_account_journal, values: [order_id])
                try db.executeUpdate(remove_pos_order_line_sql, values: [order_id])
                try db.executeUpdate(remove_pos_order_sql, values: [order_id])
                
                
                
            } catch {
                rollback.pointee = true
                 SharedManager.shared.printLog(error)
            }
            
            semaphore.signal()
        }
        
        semaphore.wait()
    }
    
    
    static func set_order_is_printed(order_id:Int,printed:Int)
    {
         
       relations_database_class(re_id1: order_id, re_id2: [printed], re_table1_table2: "pos_order|is_printed").save()
    }
    
    static func get_order_is_printed(order_id:Int) -> Int
    {
        let arr = relations_database_class().get_relations_rows(re_id1: order_id, re_table1_table2: "pos_order|is_printed")
        if arr.count > 0
        {
            
            return  arr[0]
             
            
        }
 
        return 0
    }
    
    static func set_print_count(order_id:Int ,count:Int )
    {
 
       relations_database_class(re_id1: order_id, re_id2: [count], re_table1_table2: "pos_order|print_count").save()
    }
    
    static func increment_print_count(order_id:Int )
    {
         let count = get_print_count(order_id: order_id) + 1
        
       relations_database_class(re_id1: order_id, re_id2: [count], re_table1_table2: "pos_order|print_count").save()
    }
    
    static func get_print_count(order_id:Int ) -> Int
      {
           
         let maxCountPrint = relations_database_class().getMaxCountPrint(re_id1: order_id, re_table1_table2: "pos_order|print_count")
                return maxCountPrint
        
        
    }
    
    
    static func search(by word:String, page:Int,limit:Int = 30,options:ordersListOpetions) ->  [pos_order_class] {
            var list:[pos_order_class] = []

            let start = page * limit
            // " (row_parent_id = 0 or  row_parent_id is null) and (parent_id = 0 or parent_id is null) "
    let condation = " (is_closed = 0 and is_void = 0 and is_sync = 0  )"
            var sql = """
    SELECT * FROM (
    SELECT * FROM pos_order WHERE bill_uid like '%\(word)%' and \(condation)
              UNION
    SELECT * FROM pos_order WHERE sequence_number like '%\(word)%' and \(condation)
              UNION
    SELECT * FROM pos_order WHERE delivery_type_reference like '%\(word)%' and \(condation)
              UNION
    SELECT * from pos_order po where  partner_row_id in (
    SELECT row_id from res_partner  WHERE res_partner.name like '%\(word)%' or res_partner.phone like '%\(word)%' and (row_parent_id = 0 or  row_parent_id is null) and (parent_id = 0 or parent_id is null)
    ) and \(condation)
    )

    """
            sql = String(format: "%@ LIMIT %d,%d ;", sql ,start, limit)
            
           
            let cls = pos_order_class(fromDictionary: [:])
            let arr  = cls.dbClass!.get_rows(sql: sql)
            for item in arr
            {
                let cls:pos_order_class = pos_order_class(fromDictionary: item ,options_order: options )
                list.append(cls)
                
            }
            return list
            
        }
}
