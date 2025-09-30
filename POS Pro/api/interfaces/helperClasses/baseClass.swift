//
//  baseClass.swift
//  pos
//
//  Created by khaled on 8/25/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit
import AVFoundation

class baseClass: NSObject {
    
    static func currencyFormate(_ price: Double , always_show_fraction:Bool = false,maximumFractionDigits:Int = 2) -> String{
 
 
        
        let numberFormatter = NumberFormatter()
        numberFormatter.groupingSeparator = ","
        numberFormatter.groupingSize = 3
        numberFormatter.usesGroupingSeparator = true
        numberFormatter.decimalSeparator = "."
        numberFormatter.numberStyle = .decimal
        if always_show_fraction
        {
            numberFormatter.minimumFractionDigits = maximumFractionDigits

        }
        numberFormatter.maximumFractionDigits = maximumFractionDigits
        numberFormatter.locale = Locale(identifier: "en_US")

        return numberFormatter.string(from: (price.rounded_double(toPlaces: Double(maximumFractionDigits))) as NSNumber)!
    }
    
    
    
    
    
    public  static  func round_precision  (value_:Double, precision_:Double) -> Double {
        
        
        let value = value_
        var precision = precision_
        
        if ( precision <= 0) {
            precision = 1
        }
        
        var normalized_value = value / precision
        let epsilon_magnitude =  log( abs(normalized_value)) / log(2)
        let epsilon =  pow(2, epsilon_magnitude - 52)
        normalized_value += normalized_value >= 0 ? epsilon : -epsilon
        
        /**
         * Javascript performs strictly the round half up method, which is asymmetric. However, in
         * Python, the method is symmetric. For example:
         * - In JS, Math.round(-0.5) is equal to -0.
         * - In Python, round(-0.5) is equal to -1.
         * We want to keep the Python behavior for consistency.
         */
        let sign = normalized_value < 0 ? -1.0 : 1.0
        let rounded_value:Double = sign * round( abs(normalized_value))
        
        //        let round_r:Double =  rounded_value * precision
        
        //    let round_3:Decimal =  Decimal(rounded_value * precision)
        
        let round_2:Float =  Float(rounded_value * precision)
        let str = String(format: "%f", round_2)
        
        let round_r:Double = str.toDouble()!   //NSDecimalNumber(decimal: round_3).doubleValue
        
        
        //     SharedManager.shared.printLog(round_2)
        //     SharedManager.shared.printLog(round_3)
        
        
        
        return round_r
    }
    
    
    static  func get_file_html(filename:String, showCopyRight:Bool,isCopy:Bool = false) -> String
    {
        var html:String = ""
        let bundle = Bundle.main
        var path = bundle.bundlePath
        path = bundle.path(forResource: filename, ofType: "html" )!
        do {
            try html = String(contentsOfFile: path, encoding: .utf8)
//            return html
        } catch {
            //ERROR
        }
        
        var show_copy_right = SharedManager.shared.appSetting().copy_right
        
        if showCopyRight == false
        {
            show_copy_right = false
        }
        
        let user = SharedManager.shared.activeUser()
        var print_info = """
         <br />
        <p style=\"font-size:30px;text-align: center;\"  > Print by \(user.name ?? "")
         <br />
         Print at \(Date().toString(dateFormat: baseClass.date_fromate_satnder_12h, UTC: false)) </p>

        """
        
        if isCopy
        {
            print_info = ""
        }

        if show_copy_right
        {
            
            html = html.replacingOccurrences(of: "#copy_right", with: "  <p style=\"font-size:30px;text-align: center;\"  > Powered by DGTERA </p> \(print_info)")

        }
        else
        {
            html = html.replacingOccurrences(of: "#copy_right", with: print_info)

        }
        
        

        
        return html
    }
    
    
    // this handle value retrun from api and return from database
    static  func getFromArrayOrObject(dictionary: [String:Any],keyOfArray:String,keyOfDatabase:String,Index:Int) -> Any?
    {
        let object:Any?
        let value = dictionary[keyOfArray]
        if value is [Any]
        {
            object = (dictionary[keyOfArray]as? [Any] ?? []).getIndex(Index)
            return object
        }
        
        object = dictionary[keyOfDatabase]
        
        return object
    }
    
    
    static func fillterProperties(dictionary:[String:Any],excludeProperties:[String]) -> [String:Any]
    {
        var temp = dictionary
        if excludeProperties.count > 0
        {
            for key in excludeProperties
            {
                temp.removeValue(forKey: key)
            }
            
        }
        
        return temp
    }
    
    
}



typealias date_base_class = baseClass
extension date_base_class
{
    static var  date_formate_database:String = "yyyy-MM-dd HH:mm:ss"
    static var  date_formate_database_wt_secand:String = "yyyy-MM-dd HH:mm"
    static var  date_fromate_server:String = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    static var  date_fromate_app_store:String = "yyyy-MM-dd'T'HH:mm:ss'Z'"

    static var  date_fromate_satnder:String = "yyyy-MM-dd HH:mm:ss"
    static var  date_fromate_satnder_12h:String = "yyyy-MM-dd hh:mm a"
    static var  date_fromate_satnder_back_12h:String = "dd/MM/yyyy hh:mm a"
    static var  date_fromate_satnder_date:String = "yyyy-MM-dd"
    static var  date_fromate_time:String = "hh:mm a"
     static var  date_fromate_short:String = "dd MMM yy"
    static var  date_time_fromate_short:String = "dd MMM yyyy hh:mm a"

    
    static func get_date_local_to_search(DateOnly:String,format:String,returnFormate:String,addHours:Int = 0) -> String
    {
        // day in saudia end befor UTC , so need to convert date to last day
        let date = Date()
        var timeZoneOffset_h = Double(TimeZone.current.secondsFromGMT(for: date)) / 60 / 60
        timeZoneOffset_h = timeZoneOffset_h * -1
        timeZoneOffset_h = timeZoneOffset_h + Double(addHours)
        if addHours == 24 {
            timeZoneOffset_h =   Double(addHours)

        }
        var date_only = Date().toDate(DateOnly, format: format)
        date_only = date_only.add( hours: Int(timeZoneOffset_h))!
        
        return date_only.toString(dateFormat: returnFormate,UTC:true)
    }
    
    static func get_date_utc_to_search(DateOnly:String,format:String,returnFormate:String,addHours:Int = 0) -> String
    {
        // day in saudia end befor UTC , so need to convert date to last day
        let date = Date()
        var timeZoneOffset_h = Double(TimeZone.current.secondsFromGMT(for: date)) / 60 / 60
        timeZoneOffset_h = timeZoneOffset_h * -1
        timeZoneOffset_h = timeZoneOffset_h + Double(addHours)
        
        var date_only = Date().toDate(DateOnly, format: format)
        date_only = date_only.add( hours: Int(timeZoneOffset_h))!
        
        return date_only.toString(dateFormat: returnFormate)
    }
    
    static func getTimeINMS() -> String
    {
        let time:Int64 = getTimeINMS()
        return String(time)
    }
    
    
    static func getTimeINMS() -> Int64
    {
        return Int64(Date.currentDateTimeMillis())
    }
    
    public  static func get_date_now_formate_datebase() -> String {
        
        return Date().toString(dateFormat: date_formate_database, UTC: true)
        //        return  ClassDate.getNow(baseClass.date_formate_database ) // in utc
    }
    
    public  static func get_date_now_formate_satnder() -> String {
        
        return Date().toString(dateFormat: date_fromate_satnder , UTC: true)
        //        return  ClassDate.getNow(baseClass.date_formate_database ) // in utc
    }
    
 
//    public  static func getDateFormate(date:String?,formate:String? = date_fromate_satnder,returnFormate:String = "yyyy-MM-dd hh:mm a") -> String
//    {
//        if date == nil
//        {
//            return ""
//        }
//        
//        let dt = Date(strDate: date!, formate: formate!)
//        
//        var date_new = dt.toString(dateFormat: returnFormate, UTC: true) //ClassDate.getWithFormate(date, formate: formate, returnFormate: returnFormate, use_UTC: true) ?? ""
//        if date_new == ""
//        {
//            //            date_new = ClassDate.getWithFormate(date, formate: "yyyy-MM-dd HH:mm:ss", returnFormate: returnFormate, use_UTC: true) ?? ""
//            date_new =   dt.toString(dateFormat: "yyyy-MM-dd HH:mm:ss", UTC: true)
//        }
//        
//        return date_new
//        //        return  ClassDate.convertTimeStampTodate(  String( date), returnFormate: "yyyy-MM-dd hh:mm a" , timeZone: NSTimeZone.local )
//        
//    }
//    

    
    static func compareTwoDate(_ dt1_old:String,dt2_new:String,formate:String) -> Int
    {
        let dt1 = Date(strDate: dt1_old, formate: formate,UTC: true)
        let dt2 = Date(strDate: dt2_new, formate: formate,UTC: true)
        
        let t = Int(dt2.timeIntervalSince(dt1))
        
        return t
    }
    
   static var player: AVAudioPlayer?

    static  func playSound(soundName:String, numberOfLoops:Int = 0) {
        

        guard let url = Bundle.main.url(forResource: soundName, withExtension: "") else { return }

        do {
            if #available(iOS 10.0, *) {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            } else {
                // Fallback on earlier versions
            }
            try AVAudioSession.sharedInstance().setActive(true)

            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
//            player = try AVAudioPlayer(contentsOf: url )
            player?.prepareToPlay()
            /* iOS 10 and earlier require the following line:
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */

            guard let player = player else { return }
            player.numberOfLoops =  numberOfLoops
            stopSound()
            player.play()

        } catch let error {
            SharedManager.shared.printLog(error.localizedDescription)
        }
    }
    static  func stopSound() {
        guard let player = player else { return }
        if player.isPlaying {
            if ((player.url?.path.lowercased().contains("ring_tone.mp3")) ?? false) {
                player.stop()
            }
        }
    }
}
extension date_base_class
{
    class func getSecondDifferenceFromTwoDates(start: Date, end: Date = Date()) -> Int
    {
        let diff = Int(end.timeIntervalSince1970 - start.timeIntervalSince1970)
        let hours = diff / 3600
        let second = (diff - hours * 3600)
        return second
    }
class func timeAgoSinceDate(_ date:Date,currentDate:Date, numericDates:Bool) -> String {
    let calendar = Calendar.current
    let now = currentDate
    let earliest = (now as NSDate).earlierDate(date)
    let latest = (earliest == now) ? date : now
    let components:DateComponents = (calendar as NSCalendar).components([NSCalendar.Unit.minute , NSCalendar.Unit.hour , NSCalendar.Unit.day , NSCalendar.Unit.weekOfYear , NSCalendar.Unit.month , NSCalendar.Unit.year , NSCalendar.Unit.second], from: earliest, to: latest, options: NSCalendar.Options())
    
    if (components.year! >= 2) {
        return "\(components.year!) years ago"
    } else if (components.year! >= 1){
        if (numericDates){
            return "1 year ago"
        } else {
            return "Last year"
        }
    } else if (components.month! >= 2) {
        return "\(components.month!) months ago"
    } else if (components.month! >= 1){
        if (numericDates){
            return "1 month ago"
        } else {
            return "Last month"
        }
    } else if (components.weekOfYear! >= 2) {
        return "\(components.weekOfYear!) weeks ago".arabic("منذ \(components.weekOfYear!)  اسبوع")
    } else if (components.weekOfYear! >= 1){
        if (numericDates){
            return "1 week ago".arabic("منذ اسبوع")
        } else {
            return "Last week"
        }
    } else if (components.day! >= 2) {
        return "\(components.day!) days ago".arabic("منذ \(components.day!)  يوم")
    } else if (components.day! >= 1){
        if (numericDates){
            return "1 day ago".arabic("منذ يوم")
        } else {
            return "Yesterday"
        }
    } else if (components.hour! >= 2) {
        return "\(components.hour!) hours ago".arabic("منذ \(components.hour!)  ساعه")
    } else if (components.hour! >= 1){
        if (numericDates){
            return "1 hour ago".arabic("منذ ساعه")
        } else {
            return "An hour ago"
        }
    } else if (components.minute! >= 2) {
        return "\(components.minute!)  minutes ago".arabic("منذ \(components.minute!)  دقيقة")
    } else if (components.minute! >= 1){
        if (numericDates){
            return "1 minute ago".arabic("منذ دقيقة")
        } else {
            return "A minute ago"
        }
    } else if (components.second! >= 3) {
        return "\(components.second!) seconds ago"
    } else {
        return "Just now".arabic("الان")
    }
    
}
}
