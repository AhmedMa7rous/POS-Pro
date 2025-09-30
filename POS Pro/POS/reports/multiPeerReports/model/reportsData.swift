//
//  reportsData.swift
//  pos
//
//  Created by khaled on 03/02/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import UIKit

class reportsData: NSObject {
    
    
     
    
    static func getOrderCount(_ sessionID:Int) -> Int
    {
        let option = ordersListOpetions()

        option.sesssion_id = sessionID
        option.orderSyncType = .order
        option.void = false
        option.Closed = true
        option.write_pos_id = SharedManager.shared.posConfig().id
        
        let countOrders = pos_order_helper_class.getOrders_status_sorted_count(options: option)
        return countOrders
    }
    
    
    static  func getTotalStatment(  session:pos_session_class,rptSummary:salesReportSummary) -> (
        _total_bankStatment:[String:[String:Any]],
        _total_bankStatment_summery:[String:Double],
        _totalCash :Double,
        _allPayments :Double
    )
    {
        
        var total_bankStatment:[String:[String:Any]] = [:]
        var total_bankStatment_summery:  [String:Double] = [:]
        
        
        var totalCash = 0.0
        var allPayments = 0.0
        
        // =====================================================================================
 
        
        let sql = """
                select account_journal.display_name ,account_journal.type  , \(MWConstants.selectTotalStatmentQry) , count(*) as count
                from pos_order
                inner join pos_order_account_journal on pos_order.id = pos_order_account_journal.order_id
                inner join account_journal on account_journal.id = pos_order_account_journal.account_Journal_id
        
                where   pos_order.session_id_local = \(session.id)

                group by account_journal.display_name
        
        
                    UNION
                        
                       SELECT  account_journal.display_name ,account_journal.type  , 0 as total , 0 as count  from account_journal WHERE  id not in (
                       
                        select account_journal.id
                        from pos_order
                          inner join pos_order_account_journal on pos_order.id = pos_order_account_journal.order_id
                        inner join account_journal on account_journal.id = pos_order_account_journal.account_Journal_id
                
                        where   pos_order.session_id_local = \(session.id)

                       
                       )
        
        """
        
        let semaphore = DispatchSemaphore(value: 0)
        SharedManager.shared.database_db!.inDatabase { (db:FMDatabase) in
            
            let rows:FMResultSet = try!   db.executeQuery(sql, values: [])
            while (rows.next()) {
                //retrieve values for each record
                let display_name = rows.string(forColumn: "display_name") ?? ""
                let type = rows.string(forColumn: "type") ?? ""
                let total = rows.double   (forColumn: "total")
                let count = rows.double   (forColumn: "count")

                var map:[String:Any] = [:]
                map["display_name"] = display_name
                map["type"] = type
                map["total"] = total
                map["count"] = count

                total_bankStatment[display_name] = map
                
                var total_summery = total_bankStatment_summery[display_name] ?? 0
                total_summery = total_summery  + total
                
                total_bankStatment_summery[display_name] = total_summery
                
                // =====================================================================================
                // add in main Report
                // =====================================================================================
                // increment bankStament
                var mainMap:[String:Any]  = rptSummary.total_bankStatment[display_name] ?? [:]
                mainMap["display_name"] = display_name
                mainMap["type"] = type
                mainMap["total"] = (mainMap["total"] as? Double ?? 0) + total
                mainMap["count"] = (mainMap["count"] as? Double ?? 0) + count
                
                rptSummary.total_bankStatment[display_name]  = mainMap
                
                
                // increment bankStament summery
                rptSummary.total_bankStatment_summery[display_name] = ( rptSummary.total_bankStatment_summery[display_name] ?? 0) + total_summery
                
                // =====================================================================================
                // check cash and Total
                // =====================================================================================
                if type == "cash"
                {
                    totalCash = totalCash + total
                    
                }
                else
                {
                    allPayments =  allPayments + total
                        
                }
                
                // =====================================================================================

            }
            
            rows.close()
            semaphore.signal()
        }
        
        
        semaphore.wait()
        // =====================================================================================
        
        
        
        return (total_bankStatment,total_bankStatment_summery,totalCash,allPayments)
    }
     
    static  func getTotalOrderType_group_deliveryType(  session:pos_session_class ,rptSummary:salesReportSummary) -> (_total_orderType:[String:[String:Any]],_total_deliveryType_summery: [String:[String:Any]])
    {
        var total_orderType:[String:[String:Any]] = [:]
        var total_deliveryType_summery: [String:[String:Any]] = [:]
      
        // =====================================================================================
 
 
        
        let sql = """

             select    payment_method ,delivery_type.display_name as delivery_type ,  ( delivery_type.display_name || ' - ' || payment_method )  as new_display_name ,
                                sum( due )    as total , total_orders.delivery_amount , count(*) as count
            from
            (
             SELECT count(*) as cnt ,(SUM(due) -  sum(rest)) as due ,order_id ,account_journal.display_name as payment_method ,pos_order.delivery_type_id,pos_order.delivery_amount as delivery_amount  from pos_order_account_journal
             inner join  pos_order   on pos_order.id = pos_order_account_journal.order_id
             inner join account_journal on account_journal.id = pos_order_account_journal.account_Journal_id
             where   pos_order.session_id_local =  \(session.id)
             group by  pos_order.id ) as total_orders
             inner join delivery_type on delivery_type.id =   delivery_type_id
                group by  delivery_type


            """
        
        let semaphore = DispatchSemaphore(value: 0)
        SharedManager.shared.database_db!.inDatabase { (db:FMDatabase) in
            
            let rows:FMResultSet = try!   db.executeQuery(sql, values: [])
            while (rows.next()) {
                //retrieve values for each record
                
                let payment_method = rows.string(forColumn: "payment_method") ?? ""
                let delivery_type = rows.string(forColumn: "delivery_type") ?? ""
                let new_display_name = delivery_type  //rows.string(forColumn: "new_display_name") ?? ""
                let total = rows.double (forColumn: "total")
                let count = rows.double (forColumn: "count")
                
                
                var temp:[String:Any] =    [:]
                temp["total"] = total
                temp["count"] = count
                temp["bankStatement"]  =  payment_method
                temp["delivery_type"]  =  delivery_type

                total_orderType[new_display_name] = temp
                
                
                
                var orderType_summery = total_deliveryType_summery[new_display_name] ??  [:]
                var total_summery = orderType_summery["total"] as? Double ?? 0
                var total_count = orderType_summery["count"] as? Double ?? 0
                
                total_summery = total_summery + total
                total_count = total_count + count
                
                
                
                orderType_summery["total"] = total_summery
                orderType_summery["count"] = total_count
                orderType_summery["bankStatement"] = payment_method
                
                
                
                total_deliveryType_summery[new_display_name] = orderType_summery
                 
                // =====================================================================================
                
                // =====================================================================================
                // add in main Report
                // =====================================================================================
                // increment bankStament
                var mainMap:[String:Any]  = rptSummary.total_deliveryType[new_display_name] ?? [:]
                mainMap["bankStatement"]  =  payment_method
                mainMap["delivery_type"]  =  delivery_type
                mainMap["total"] = (mainMap["total"] as? Double ?? 0) + total
                mainMap["count"] = (mainMap["count"] as? Double ?? 0) + count
                
                rptSummary.total_deliveryType[new_display_name]  = mainMap
                
                
                // increment bankStament summery
                var rpt_orderType_summery = rptSummary.total_deliveryType_summery[new_display_name] ??  [:]

                rpt_orderType_summery["total"] = (rpt_orderType_summery["total"] as? Double ?? 0) + total_summery
                rpt_orderType_summery["count"] = (rpt_orderType_summery["count"] as? Double ?? 0) + total_count
                rpt_orderType_summery["bankStatement"] =   payment_method
                 
                
                rptSummary.total_deliveryType_summery[new_display_name] = rpt_orderType_summery
                 
                // =====================================================================================
                
            }
            
            rows.close()
            semaphore.signal()
        }
        
        
        semaphore.wait()
        // =====================================================================================
        
        return (total_orderType,total_deliveryType_summery)
    }
    
    
   static func getTotalOrderType_group_deliveryType_accountJournal (session:pos_session_class ,rptSummary:salesReportSummary) ->
    (_total_orderType_accountJournal:[String:[String:Any]],_total_deliveryType_accountJournal_summery: [String:[String:Any]])
    {
        var total_orderType_accountJournal:[String:[String:Any]] = [:]
        var total_deliveryType_accountJournal_summery: [String:[String:Any]] = [:]
 
        // =====================================================================================
 
        
         let sql = """

                select  account_journal.display_name as payment_method ,delivery_type.display_name as delivery_type ,  ( delivery_type.display_name || ' - ' || account_journal.display_name)  as new_display_name ,
                \(MWConstants.selectTotalStatmentQry) ,pos_order.delivery_amount , count(*) as count
                from pos_order
                inner join pos_order_account_journal on pos_order.id = pos_order_account_journal.order_id
                inner join delivery_type on delivery_type.id =  pos_order.delivery_type_id
                inner join account_journal on account_journal.id = pos_order_account_journal.account_Journal_id

                where   pos_order.session_id_local = \(session.id)

                 group by  new_display_name
            """
        
        let semaphore = DispatchSemaphore(value: 0)
        SharedManager.shared.database_db!.inDatabase { (db:FMDatabase) in
            
            let rows:FMResultSet = try!   db.executeQuery(sql, values: [])
            while (rows.next()) {
                //retrieve values for each record
                
                let payment_method = rows.string(forColumn: "payment_method") ?? ""
                let delivery_type = rows.string(forColumn: "delivery_type") ?? ""
                let new_display_name = rows.string(forColumn: "new_display_name") ?? ""
                let total = rows.double (forColumn: "total")
                let count = rows.double (forColumn: "count")
                
                
                var temp:[String:Any] =    [:]
                temp["total"] = total
                temp["count"] = count
                temp["bankStatement"]  =  payment_method
                temp["delivery_type"]  =  delivery_type

                total_orderType_accountJournal[new_display_name] = temp
                
                
                
                var orderType_summery = total_deliveryType_accountJournal_summery[new_display_name] ??  [:]
                var total_summery = orderType_summery["total"] as? Double ?? 0
                var total_count = orderType_summery["count"] as? Double ?? 0
                
                total_summery = total_summery + total
                total_count = total_count + count
                
                
                
                orderType_summery["total"] = total_summery
                orderType_summery["count"] = total_count
                orderType_summery["bankStatement"] = payment_method
                
                
                
                total_deliveryType_accountJournal_summery[new_display_name] = orderType_summery
 
                // =====================================================================================
                // add in main Report
                // =====================================================================================
                // increment bankStament
                var mainMap:[String:Any]  = rptSummary.total_deliveryType_accountJournal[new_display_name] ?? [:]
                mainMap["bankStatement"]  =  payment_method
                mainMap["delivery_type"]  =  delivery_type
                mainMap["total"] = (mainMap["total"] as? Double ?? 0) + total
                mainMap["count"] = (mainMap["count"] as? Double ?? 0) + count
                
                rptSummary.total_deliveryType_accountJournal[new_display_name]  = mainMap
                
                
                // increment bankStament summery
                var rpt_orderType_summery = rptSummary.total_deliveryType_accountJournal_summery[new_display_name] ??  [:]

                rpt_orderType_summery["total"] = (rpt_orderType_summery["total"] as? Double ?? 0) + total_summery
                rpt_orderType_summery["count"] = (rpt_orderType_summery["count"] as? Double ?? 0) + total_count
                rpt_orderType_summery["bankStatement"] =   payment_method
                 
                
                rptSummary.total_deliveryType_accountJournal_summery[new_display_name] = rpt_orderType_summery
                 
                // =====================================================================================
                
                
            }
            
            rows.close()
            semaphore.signal()
        }
        
        
        semaphore.wait()
        // =====================================================================================
        
        return (total_orderType_accountJournal,total_deliveryType_accountJournal_summery)
    }
    
    
    static func cashBox(totalCash:Double,startBalance:Double,cashbox_list : [cashbox_class] ) ->
    (_dif_total_cashbox_In:Double,
     _dif_total_cashbox_out:Double,
     _cash_difference:Double,
     _total_cash:Double)
    {
        
        var total_cash =  totalCash +  startBalance

        var dif_total_cashbox_In = 0.0
        var dif_total_cashbox_out = 0.0
        
        if cashbox_list.count != 0
        {
           
            for item in  cashbox_list
            {
                
                let shift_cashbox = item //cashbox_class(fromDictionary: item  )
                if shift_cashbox.cashbox_in_out == "in"
                {
                    dif_total_cashbox_In = dif_total_cashbox_In + shift_cashbox.cashbox_amount
                }
                else
                {
                    
                    dif_total_cashbox_out = dif_total_cashbox_out + shift_cashbox.cashbox_amount
                }
                 
            }
            
            
        }
        
        total_cash = total_cash + dif_total_cashbox_In - dif_total_cashbox_out
        let cash_difference = dif_total_cashbox_In - dif_total_cashbox_out
        
        return (dif_total_cashbox_In,dif_total_cashbox_out,cash_difference,totalCash)
    }
    
    
    static func getTotal_order( sesstion_ids:String) -> (price_subtotal_incl:Double,price_subtotal:Double,amount_tax:Double)
    {
        
        
        var  price_subtotal_incl = 0.0
        var  price_subtotal = 0.0
        var  amount_tax = 0.0
        
        // =====================================================================================
        let pos = SharedManager.shared.posConfig()
        
        let sql = """
        SELECT  SUM(price_subtotal_incl) as price_subtotal_incl ,  SUM(price_subtotal) as price_subtotal
        ,( SELECT  SUM(amount_tax)    FROM  pos_order  where  session_id_local in (\(sesstion_ids))  and pos_order .is_void  = 0 and pos_order.is_closed = 1 and order_sync_type = 0 and pos_order.write_pos_id  = \(pos.id)) as amount_tax
         FROM  pos_order_line
        inner join pos_order on  pos_order_line.order_id  = pos_order.id
        where   pos_order_line.is_void = 0 and pos_order.order_menu_status != 3 and pos_order.is_closed = 1 and order_sync_type =0  and session_id_local in (\(sesstion_ids)) and pos_order.write_pos_id  = \(pos.id)
        """
        
        
        let semaphore = DispatchSemaphore(value: 0)
        SharedManager.shared.database_db!.inDatabase { (db:FMDatabase) in
            
            let rows:FMResultSet = try!   db.executeQuery(sql, values: [])
            if (rows.next()) {
                //retrieve values for each record
                price_subtotal_incl = rows.double(forColumn: "price_subtotal_incl")
                price_subtotal = rows.double(forColumn: "price_subtotal")
                amount_tax = rows.double   (forColumn: "amount_tax")
                
                
                // =====================================================================================
            }
            
            rows.close()
            semaphore.signal()
        }
        
        
        semaphore.wait()
        // =====================================================================================
        
        
        return (price_subtotal_incl,price_subtotal,amount_tax)
    }
    
    
    static func getTotalProductsSql(for sesstion_ids:String,as result:String, with condation:String) -> String{
        let sql = """
           SELECT
               SUM(price_subtotal_incl) as \(result)
           from
               (
               SELECT
                   SUM(price_subtotal_incl) as price_subtotal_incl
               from
                   (
                   SELECT
                       pos_order_line.price_subtotal_incl
                   from
                       pos_order
                   inner join pos_order_line on
                       pos_order.id = pos_order_line.order_id
                   where
                       pos_order.session_id_local in (\(sesstion_ids))
                      \(condation)
                       
                       )
                       
           )

        """
        
        return sql
    }
    static    func get_Statistics( sesstion_ids:String) -> (total_void:Double,total_return:Double,total_discount:Double,total_delete:Double,total_rejected:Double,total_orders:Int)
    {
        var posID = SharedManager.shared.posConfig().id
        let posWriteQuery = "pos_order.write_pos_id  = \(posID)"
        var  total_delete = 0.0
        var  total_void = 0.0
        var  total_return = 0.0
        var  total_discount  = 0.0
        var total_rejected = 0.0
        var total_orders = 0

        // =====================================================================================
        
         let sql_total_void = getTotalProductsSql( for:sesstion_ids,
                                                  as:"total_void",
                                                  with:"""
                                                        and pos_order_line.is_void = 1
                                                        and pos_order_line.void_status in (2)
                                                        and pos_order_line.discount_display_name = ""
                                                        and \(posWriteQuery)
                                                        """)
        let sql_total_delete = getTotalProductsSql( for:sesstion_ids,
                                                  as:"total_delete",
                                                  with:"""
                                                        and pos_order_line.is_void = 1
                                                        and pos_order_line.void_status in (0,1)
                                                        and pos_order_line.discount_display_name = ""
                                                        and \(posWriteQuery)
                                                        """)
        let sql_total_return = getTotalProductsSql( for:sesstion_ids,
                                                  as:"total_return",
                                                  with:"""
                                                        and amount_total < 0
                                                        and pos_order.is_closed  = 1
                                                        """)
        
     
        let sql_total_rejected = """
        SELECT  sum(pos_order.amount_total) as total_rejected  from pos_order
        where pos_order.session_id_local in (\(sesstion_ids)) and pos_order.is_void  = 1
        and id in (
        SELECT DISTINCT order_id from pos_order_line
        inner join pos_order
        on pos_order.id = pos_order_line.order_id
        WHERE  pos_order.order_menu_status = 3  and pos_order.session_id_local in (\(sesstion_ids))
        )
         
        """
        
        
        let sql_total_discount =  """
        SELECT sum (price_subtotal_incl) as total_discount from (
        SELECT (pos_order_line.price_subtotal_incl)   from pos_order
        inner join pos_order_line
        on pos_order.id = pos_order_line.order_id
        where session_id_local  in (\(sesstion_ids))  and pos_order_line.price_unit < 0 and pos_order_line.is_void  = 0 and pos_order.is_closed  = 1 GROUP BY pos_order.id )
        """
        
        let sql_total_orders =  """
        SELECT  count(*) as total_orders  from pos_order
        where session_id_local  in (\(sesstion_ids))  and   pos_order.is_void  = 0 and pos_order.is_closed  = 1
        """
     
        total_void = database_class(connect: .database).get_row(sql: sql_total_void)?["total_void"] as? Double ?? 0
        total_delete = database_class(connect: .database).get_row(sql: sql_total_delete)?["total_delete"] as? Double ?? 0
        total_rejected = database_class(connect: .database).get_row(sql: sql_total_rejected)?["total_rejected"] as? Double ?? 0

        total_return = database_class(connect: .database).get_row(sql: sql_total_return)?["total_return"] as? Double ?? 0
        total_discount = database_class(connect: .database).get_row(sql: sql_total_discount)?["total_discount"] as? Double ?? 0
        
        total_orders = database_class(connect: .database).get_row(sql: sql_total_orders)?["total_orders"] as? Int ?? 0

        
        return (total_void,total_return,total_discount,total_delete,total_rejected,total_orders)
    }

}
