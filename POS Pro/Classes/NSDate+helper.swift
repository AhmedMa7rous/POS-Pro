//
//  NSDate+helper.swift
//  pos
//
//  Created by khaled on 8/16/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

extension  Date {
    
    static let  dateformat_default = "yyyy-MM-dd"

  static  func currentDateTimeMillis() -> Int64 {
        return Int64(Date().timeIntervalSince1970 * 1000)
        
//        return  Int(Date().timeIntervalSinceReferenceDate)
    }
    
//    func toMillis() -> Int64! {
//        return Int64(self.timeIntervalSince1970 * 1000)
//    }

    init(millis: Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(millis / 1000))
        self.addTimeInterval(TimeInterval(Double(millis % 1000) / 1000 ))
    }
    
    
    init(strDate:String,formate:String =  dateformat_default, UTC:Bool  )
    {
        self.init()
        
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar.init(identifier: .gregorian)

        dateFormatter.dateFormat = formate
         dateFormatter.locale = Locale(identifier: "en_US")

        if UTC == false
        {
//            dateFormatter.calendar = NSCalendar.current

            dateFormatter.timeZone = TimeZone.current
        }
        else
        {
            dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        }
        
        let dt = dateFormatter.date(from: strDate)
        if dt != nil
        {
                 self = dt!
        }
        
    }
 
  
    func localDate() -> Date {
        let nowUTC = Date()
        let timeZoneOffset = Double(TimeZone.current.secondsFromGMT(for: nowUTC))
        guard let localDate = Calendar.current.date(byAdding: .second, value: Int(timeZoneOffset), to: nowUTC) else {return Date()}

         return localDate
    }
    
      func from(year: Int, month: Int, day: Int) -> Date {
          let gregorianCalendar = NSCalendar(calendarIdentifier: .gregorian)!

          var dateComponents = DateComponents()
          dateComponents.year = year
          dateComponents.month = month
          dateComponents.day = day

          let date = gregorianCalendar.date(from: dateComponents)!
          return date
      }

        func toDate(_ string: String, format: String = dateformat_default) -> Date {
            if string.isEmpty {
                return Date()
            }
          let dateFormatter = DateFormatter()
         // dateFormatter.timeZone = NSTimeZone.default
            dateFormatter.timeZone = TimeZone(identifier: "UTC")

          dateFormatter.dateFormat = format
            dateFormatter.locale = Locale(identifier: "en_US")

          let date = dateFormatter.date(from: string)!
          return date
      }
    
    func toString( dateFormat format  : String = dateformat_default, UTC:Bool = false) -> String
    {
 
        let date = self
        
       let str = Date.get_date_in_gregorian(date: date, return_format: format, UTC: UTC)
        
        return str
    }
    
    
    
    
    /// Returns a Date with the specified amount of components added to the one it is called with
       func add(years: Int = 0, months: Int = 0, days: Int = 0, hours: Int = 0, minutes: Int = 0, seconds: Int = 0) -> Date? {
           let components = DateComponents(year: years, month: months, day: days, hour: hours, minute: minutes, second: seconds)
           return Calendar.current.date(byAdding: components, to: self)
       }

       /// Returns a Date with the specified amount of components subtracted from the one it is called with
       func subtract(years: Int = 0, months: Int = 0, days: Int = 0, hours: Int = 0, minutes: Int = 0, seconds: Int = 0) -> Date? {
           return add(years: -years, months: -months, days: -days, hours: -hours, minutes: -minutes, seconds: -seconds)
       }
    
    
    /*
     10000.asString(style: .positional)  // 2:46:40
     10000.asString(style: .abbreviated) // 2h 46m 40s
     10000.asString(style: .short)       // 2 hr, 46 min, 40 sec
     10000.asString(style: .full)        // 2 hours, 46 minutes, 40 seconds
     10000.asString(style: .spellOut)    // two hours, forty-six minutes, forty seconds
     10000.asString(style: .brief)       // 2hr 46min 40sec
     */
    static func second_to_duration (seconds:Int,style: DateComponentsFormatter.UnitsStyle) -> String {
      let formatter = DateComponentsFormatter()
      formatter.allowedUnits = [.hour, .minute, .second, .nanosecond]
      formatter.unitsStyle = style
      guard let formattedString = formatter.string(from: Double( seconds)) else { return "" }
      return formattedString
    }
    
    
   static func get_day_name(date:Date) ->String
    {
       
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        dateFormatter.locale = Locale(identifier: "en_US")

        let dayInWeek = dateFormatter.string(from: date)
        
        return dayInWeek
    }
    
    static func get_hours(date:Date) ->String
      {
         
          let dateFormatter = DateFormatter()
          dateFormatter.dateFormat = "HH"
        dateFormatter.locale = Locale(identifier: "en_US")

          let dayInWeek = dateFormatter.string(from: date)
          
          return dayInWeek
      }
    
    
    static func get_date_in_gregorian(date:Date,return_format : String = dateformat_default, UTC:Bool = false) -> String
        {
     
            
            
            let dt_str = get_date_string(date:date,dateFormat: return_format, UTC: UTC)
            
            
//            let calander_type = Calendar.current.identifier
//            if calander_type == .islamic || calander_type == .islamicUmmAlQura || calander_type == .islamicTabular
//            {
//                return convert_isalmic_to_gregorian(date: dt_str,format: return_format   , UTC: UTC)
//            }
            
            
            
            return dt_str
        }
    
    
    static func get_date_string (date:Date, dateFormat format  : String = dateformat_default, UTC:Bool = false) -> String
        {
            
    
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = format
    
        dateFormatter.calendar = Calendar(identifier: .gregorian) // NSCalendar.current
//        let gregorian = NSCalendar(identifier: NSCalendar.Identifier.gregorian)

            if UTC == false
            {
    
                dateFormatter.timeZone = TimeZone.current
            }
            else
            {
                dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
            }
    
           dateFormatter.locale = Locale(identifier: "en_US")
    
            let str = dateFormatter.string(from: date)
            
 
            return str
        }
        
      static  func convert_isalmic_to_gregorian(date:String, format : String = dateformat_default, UTC:Bool = false) -> String
        {
            let dateFormatter = DateFormatter()
     
            
            dateFormatter.dateFormat = format

            dateFormatter.locale = Locale(identifier: "ar_SA")

            let islamicDate = dateFormatter.date(from: date)
            
             if islamicDate == nil
             {
                return date
            }

            let gregorian = NSCalendar(identifier: NSCalendar.Identifier.gregorian)
             if UTC == false
             {
//                 gregorian.calendar = NSCalendar.current

                 gregorian?.timeZone = TimeZone.current
             }
             else
             {
                gregorian?.timeZone = TimeZone(abbreviation: "UTC")!
             }
             
            dateFormatter.locale = Locale(identifier: "en_US")
            

            let components = gregorian?.components(NSCalendar.Unit(rawValue: UInt.max), from: islamicDate!)

            let dt:String = "\(String(components!.year!))-\(String(components!.month!))-\(String(components!.day!))"
            
            return dt
    //       SharedManager.shared.printLog("\(components!.year) - \(components!.month) - \(components!.day)")
        }
    
    public static func daysBetween(start: Date, end: Date) -> Int {
       Calendar.current.dateComponents([.day], from: start, to: end).day!
    }
    
    
    public static func time_to_minutes(time:String,dateFormat :String) ->  Int
    {
//        let time = "07:10 AM"
         let formatter = DateFormatter()
         formatter.dateFormat = dateFormat //"hh:mm a"
        formatter.locale = Locale(identifier: NSLocale.current.identifier)


         let date = formatter.date(from: time)
         let calendar = Calendar(identifier: .gregorian)


        let currentDateComponent = calendar.dateComponents([.hour, .minute], from: date!)
         let numberOfMinutes = (currentDateComponent.hour! * 60) + currentDateComponent.minute!
        SharedManager.shared.printLog("numberOfMinutes :: \(numberOfMinutes)"  )
        return numberOfMinutes
    }
}
