//
//  promotionValidate.swift
//  pos
//
//  Created by khaled on 17/03/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import UIKit

class promotionValidate: NSObject {

  static  func validate(_ promotion:pos_promotion_class) -> Bool
    {
        var avalible = false
        
 
            
             avalible =  check_availability(promotion: promotion)
            
         
            
            if avalible == true
            {
                return true
            }
    
        
        return avalible
  
    }
    
    static func check_availability(promotion:pos_promotion_class) -> Bool {
        
        guard check_date_availability(from_date: promotion.from_date, to_date: promotion.to_date) else {
            return false
        }
        
        guard  check_days_availability(days: promotion.get_day_of_week_ids()) else {
            return false
        }
        
        guard  check_time_availability(from_time: promotion.from_time, to_time: promotion.to_time) else {
            return false
        }
        
        
        return true
    }
    
   
    
    static  func check_date_availability(from_date:String , to_date:String) -> Bool
    {
        if  from_date.isEmpty && from_date.isEmpty
        {
            return true
        }
        
        let fromdate = Date.init(strDate: from_date, formate: "yyyy-MM-dd",UTC: true)
        let todate = Date.init(strDate: to_date, formate: "yyyy-MM-dd",UTC: true)
        let date_now_str = Date().toString(dateFormat: "yyyy-MM-dd", UTC: true)
        
        let date_now = Date.init(strDate: date_now_str, formate: "yyyy-MM-dd",UTC: true)
        if  date_now >= fromdate && date_now  <= todate {
            return true
        }
        else
        {
            return false
            
        }
        
    }
    
    static  func check_days_availability(days:[Int]) -> Bool
    {
        var pass = true
        
        let week_days = day_week_class.getAll()
        let day_name:String = Date.get_day_name(date:Date())
        
        let result =  week_days.filter{  $0["name"]! as? String == day_name }
        if result.count > 0
        {
            let day  = result[0]
            let day_id = day["id"] as? Int ?? 0
            
            let exsit = days.filter { $0 == day_id }
            if exsit.count > 0
            {
                pass = true
            }
            else
            {
                pass = false
            }
            
        }
        else
        {
            pass = false
        }
        
        return pass
        
    }
    
    static  func check_time_availability(from_time:String , to_time:String) -> Bool
    {
        if  from_time.isEmpty && to_time.isEmpty
        {
            return true
        }
        
        let houre:Int =  Date.get_hours(date: Date()).toInt() ?? 0
        let fromTime:Int = from_time.toInt() ?? 0
        let toTime:Int = to_time.toInt() ?? 0
        
        if houre > fromTime && houre < toTime
        {
            return true
        }
        else
        {
            return false
        }
        
        
    }
    
    
    static func pos_conditions_check(_ condtion:pos_conditions_class,line:pos_order_line_class) -> Bool
    {
        if line.qty >= condtion.quantity
        {
            return true
        }
        
        return false
    }
        
    static func get_discount_check(_ condtion:get_discount_class,line:pos_order_line_class) -> Bool
    {
        if line.qty >= condtion.qty
        {
            return true
        }
        
        return false
    }
        
 
    static func quantity_discount_check(_ condtion:quantity_discount_class,line:pos_order_line_class) -> Bool
    {
        if line.qty >= condtion.quantity_dis
        {
            return true
        }
        
        return false
    }
    
    
    static func quantity_discount_amt_check(_ condtion:quantity_discount_amt_class,line:pos_order_line_class) -> Bool
    {
        if line.qty >= condtion.quantity_amt
        {
            return true
        }
        
        return false
    }
    
    
    
    
    
    
}
