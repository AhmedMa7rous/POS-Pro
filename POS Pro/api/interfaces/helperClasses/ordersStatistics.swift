//
//  ordersStatistics.swift
//  pos
//
//  Created by Khaled on 12/11/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

class ordersStatistics: NSObject {
    
    
    
    var number_of_orders:Double = 0
    var value_of_orders:Double = 0 // include all order expect void
    
    var number_of_return:Double = 0
    var value_of_return_orders:Double = 0
    
    
    var number_of_void_orders:Double = 0
    var value_of_void_orders:Double = 0
    
    var number_of_void_products:Double = 0
    var value_of_void_products:Double = 0
    
    
    
    private var orders_void:[[String : Any]]!
    private var orders:[[String : Any]]!
    private var checkDay = ""
    
    
    
    func getOrders_statistics(day:String = "" , formate:String = "" ) ->ordersStatistics
    {
        
        if day != ""
        {
            let dt = Date(strDate: day, formate: formate,UTC: true)
            checkDay = dt.toString(dateFormat: "yyyy-MM-dd", UTC: false) //ClassDate.getWithFormate(day, formate: formate , returnFormate: "yyyy-MM-dd",use_UTC: false)
            
        }
        
        
        
        let semaphore = DispatchSemaphore(value: 0)
        SharedManager.shared.database_db!.inDatabase { (db:FMDatabase) in
            
            
            // number_of_orders
            // ============================================================================
            let sql = "select orders.* from orders inner join sessions on orders.session_id = sessions.session_id where sessions.start_session like '\(checkDay)%'"
            
            let resutl:FMResultSet = try! db.executeQuery(sql, values: [])
            
            while (resutl.next())
            {
                    let data = resutl.string(forColumn: "data")
                    var dic =  data?.toDictionary() ?? [:]
                
                    let is_void = resutl.bool(forColumn: "is_void")
                    let sync = resutl.bool(forColumn: "sync")
                    let closed = resutl.bool(forColumn: "closed")
                
                  dic["isVoid"] = is_void
                 dic["isSync"] = sync
                dic["isClosed"] = closed

                calac_orders(item: dic)
            }
            
            resutl.close()
         
            
            
            semaphore.signal()
        }
        
        
        
        semaphore.wait()
        
        
        return self
    }
    
    
    //    func getOrders_statistics(day:String = "" , formate:String = "" ) ->ordersStatistics
    //    {
    //         if day != ""
    //         {
    //            checkDay = ClassDate.getOnly(day, formate: formate , returnFormate: "yyyy/MM/dd")
    //
    //         }
    //
    //          orders_void = myuserdefaults.lstitems(ordersListClass.voidOrdersPrefix) as? [[String : Any]] ?? [[:]]
    //          orders = myuserdefaults.lstitems(ordersListClass.ordersPrefix) as? [[String : Any]] ?? [[:]]
    //
    //
    //        calac_orders_void( )
    //        calac_orders( )
    //
    //        return self
    //    }
    
    func calac_orders_void( )
    {
        //        number_of_void_orders = Double(orders_void.count)
        for item in orders_void
        {
            let obj = pos_order_class(fromDictionary: item)
            if isDay(sessionID: obj.session!.id)
            {
                number_of_void_orders = number_of_void_orders + 1
                value_of_void_orders  = value_of_void_orders + obj.amount_total
            }
        }
        
    }
    
    
    func calac_orders(item:[String:Any] )
    {
        //        number_of_orders = Double(orders.count)
        
//        for item in orders
//        {
            let obj = pos_order_class(fromDictionary: item)
            
//            if isDay(sessionID: obj.session!.id)
//            {
        
       if obj.is_void == true
       {
        
        number_of_void_orders = number_of_void_orders + 1
        value_of_void_orders  = value_of_void_orders + obj.amount_total
        
        return
        }
                
                number_of_orders = number_of_orders + 1
                value_of_orders  = value_of_orders + obj.amount_total
                
                if obj.amount_total < 0
                {
                    number_of_return = number_of_return + 1
                    value_of_return_orders = value_of_return_orders +  obj.amount_total
                }
                
//                if obj.products_void.count > 0
//                {
//                    number_of_void_products = Double(obj.products_void.count)
//                    for void in obj.products_void
//                    {
//                        value_of_void_products = value_of_void_products + void.price_total_app
//                    }
//                }
        
        
       
                
//            }
            
//        }
    }
    
    
    
    func isDay(sessionID:Int) -> Bool
    {
        if checkDay == ""
        {
            return true
        }
        
        let dt = Date(millis: Int64(sessionID))
        
        let day = dt.toString(dateFormat: "yyyy/MM/dd" , UTC: false) //ClassDate.convertTimeStampTodate( String(sessionID), returnFormate:"yyyy/MM/dd" , timeZone:NSTimeZone.local  )
        if day == checkDay
        {
            return true
        }
        else
        {
            return false
        }
        
    }
    
}
