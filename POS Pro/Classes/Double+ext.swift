//
//  Double+ext.swift
//  pos
//
//  Created by khaled on 8/25/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

extension Double {
    /// Rounds the double to decimal places value
    func rounded_double(toPlaces places:Double) -> Double {
     let divisor = pow(10.0, Double(places))
                var amount:Double = (self * divisor).rounded()
                amount = amount / divisor
              

        //          amount = Double(String(format: "%.\(places)f", self))!

        //      var amount = (self * 100).rounded()/100
                
                return amount
    }
    
//    func rounded_str() -> String
//    {
//
//        return String( rounded(value: self))
//    }
    
    func rounded_formated() -> Decimal
    {
        let txt = String(rounded(value: self))
         
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale(identifier: "en_US")

        let number = numberFormatter.number(from: txt)
        
        return number!.decimalValue
    }
    func rounded_formated_str(max_len:Int? = 0,  always_show_fraction:Bool = false,maximumFractionDigits:Int = 2) -> String
    {
        let txt = rounded(value: self)
 
//        let numberFormatter = NumberFormatter()
//        numberFormatter.numberStyle = .decimal
//        numberFormatter.multiplier = 1
//        numberFormatter.minimumFractionDigits = 0
//        numberFormatter.maximumFractionDigits = 2
//        numberFormatter.roundingMode = .down
//
////        let number = numberFormatter.number(from: txt)
//
//        var roundedPriceString = numberFormatter.string(for: txt)  ?? "?"
 
        var roundedPriceString  = baseClass.currencyFormate(txt,always_show_fraction: always_show_fraction,maximumFractionDigits:maximumFractionDigits)
        if max_len != 0
        {
            if roundedPriceString.count > max_len!
               {
                  let index = roundedPriceString.index(roundedPriceString.startIndex, offsetBy: max_len! - 3)
                       roundedPriceString = String(roundedPriceString[..<index])  + "..."

                  }
        }


        return roundedPriceString
    }
    
    
    func rounded_app() -> Double
    {
    
      return  rounded(value: self)
    }
    
    func rounded(value:Double) -> Double
    {
        let multiplier = pow(10, Double(6))
        return (multiplier * self).rounded()/multiplier
        //return  baseClass.round_precision(value_: self, precision_: 0.00001)

       /*
        if  let company = SharedManager.shared.posConfig().company{
 
            return   baseClass.round_precision(value_: self, precision_: company.currency().rounding)
            
        }
        return value
        */
    }
    
    func isInteger() -> Bool
    {
        let isInteger = floor(self) == self // true

        return isInteger
    }
    
    func toInt() -> Int
    {
        return Int(self)
    }
    
    func toIntString() -> String
    {
       if self.isInteger()
       {
         return String(format: "%.f", self)
       }
        else
       {
        return String(format: "%.2f", self)

        }
    }
    
    

}
