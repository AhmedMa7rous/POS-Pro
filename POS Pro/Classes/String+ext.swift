//
//  String+ext.swift
//  pos
//
//  Created by khaled on 8/18/19.
//  Copyright © 2019 khaled. All rights reserved.
//
import CryptoSwift

import Foundation
extension String {
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
    func padLeft(toSize: Int) -> String {
        let padded = String(repeating: "0", count: toSize - count) + self
        return padded
    }
    func toDouble() -> Double? {
        
        if self.isEmpty
        {
            return 0
        }
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
           numberFormatter.multiplier = 1
           numberFormatter.minimumFractionDigits = 0
           numberFormatter.maximumFractionDigits = 2
           numberFormatter.roundingMode = .down
        
         numberFormatter.locale = Locale(identifier: "en_US")
        
        let number  = numberFormatter.number(from: self)
        
        return number?.doubleValue ?? 0
//        return NumberFormatter().number(from: self)?.doubleValue ?? 0
        
    }
    
    func toInt() -> Int? {
        return NumberFormatter().number(from: self)?.intValue ?? 0
    }
    
    
    func toImage() -> UIImage? {
        if let data = Data(base64Encoded: self, options: .ignoreUnknownCharacters){
            return UIImage(data: data)
        }
        return nil
    }
    
    func isNumber() -> Bool {
        let numberCharacters = NSCharacterSet.decimalDigits.inverted
        return !self.isEmpty && self.rangeOfCharacter(from: numberCharacters) == nil
    }
    
    var isArabic: Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", "(?s).*\\p{Arabic}.*")
        return predicate.evaluate(with: self)
    }
    
    func htmlToAttributedString(font:UIFont?) -> NSAttributedString{
        var attribStr = NSMutableAttributedString()
        
        var html = self
        html = html.replacingOccurrences(of: "\n", with: "")
 
//        SharedManager.shared.printLog(html)
        do {//, allowLossyConversion: true
            let options = [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html ]
            if let htmlData = NSString(string: html).data(using: String.Encoding.utf8.rawValue) {
            
            attribStr = try NSMutableAttributedString(data: htmlData, options: options, documentAttributes: nil)
            }
//            attribStr.mutableString.replaceOccurrences(of: "\n\n", with: "\n", options: [], range: NSMakeRange(0, attribStr.length))

            if font != nil
            {
                let textRangeForFont : NSRange = NSMakeRange(0, attribStr.length)
                attribStr.addAttributes([NSAttributedString.Key.font : font!], range: textRangeForFont)
            }
            
            
        } catch {
             SharedManager.shared.printLog(error)
        }
        
        return attribStr
    }
    
    func toDictionary()  -> [String: Any]?
    {
        if let data = self.data(using: .utf8) {
            do {
                var dic:[String: Any]? = nil
                
                try autoreleasepool{
                    dic =  try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                }
                
                return dic
                
            } catch {
                SharedManager.shared.printLog(error.localizedDescription)
            }
        }
        
        return nil
        
    }
    
    func leftPadding(toLength: Int, withPad: String = " ") -> String {

           guard toLength > self.count else { return self }

           let padding = String(repeating: withPad, count: toLength - self.count)
           return padding + self
      }
    
    
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }

    func substring_ext(from: Int) -> String {
        let fromIndex = index(from: from)
        return String(self[fromIndex...])
    }

    func substring_ext(to: Int) -> String {
        let toIndex = index(from: to)
        return String(self[..<toIndex])
    }

    func substring_ext(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return String(self[startIndex..<endIndex])
    }
    
    func attributedTextUnderlined(rangeString:String) -> NSAttributedString {

        let string = self as NSString

        let attributedString = NSMutableAttributedString(string: string as String, attributes: [NSAttributedString.Key.font:UIFont.init(name: "HelveticaNeue-Medium", size: 20)])

        let customFontAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.thick.rawValue, NSAttributedString.Key.font: UIFont.init(name: "HelveticaNeue-Bold", size: 22)] as [NSAttributedString.Key : Any]

        // Part of string to be bold
        attributedString.addAttributes(customFontAttribute, range: string.range(of: rangeString))

        // 4
        return attributedString
    }
    
    func attributedTextBold(rangeString:String) -> NSAttributedString {

        let string = self as NSString

        let attributedString = NSMutableAttributedString(string: string as String, attributes: [NSAttributedString.Key.font:UIFont.init(name: "HelveticaNeue-Light", size: 18)])

        let customFontAttribute = [NSAttributedString.Key.font: UIFont.init(name: "HelveticaNeue-Bold", size: 18)] as [NSAttributedString.Key : Any]

        // Part of string to be bold
        attributedString.addAttributes(customFontAttribute, range: string.range(of: rangeString))

        // 4
        return attributedString
    }
    
    func arabic(_ txt:String) -> String {
        var str = LanguageManager.text(self, ar: txt)
        if str == nil
        {
            str = ""
        }
        
        return str
    }
    
   
    func slice(from: String, to: String) -> String? {
            guard let rangeFrom = range(of: from)?.upperBound else { return nil }
            guard let rangeTo = self[rangeFrom...].range(of: to)?.lowerBound else { return nil }
            return String(self[rangeFrom..<rangeTo])
        }
    func trunc(length: Int, trailing: String = "…") -> String {
       return (self.count > length) ? self.prefix(length) + trailing : self
     }
    
    func trim_html() -> String{
        if self.contains("#Print:"){
            if let index = self.range(of: "#Print:")?.lowerBound {
            let substring = self[..<index]
            return String(substring)
        }
            
        }
        return ""
    }
    func trim_before_item()-> String{
        var newString = self.trim_html()
        if newString.contains("Item"){
          
            if let index = self.range(of: "Item")?.lowerBound {
                newString.removeSubrange(self.startIndex ..< index)
            return newString
        }
            
        }
        return self
    }
    
    
    func toEnglishNumber() -> String
    {
        var txt = self
        txt = txt.replacingOccurrences(of: "٠", with: "0")
        txt = txt.replacingOccurrences(of: "١", with: "1")
        txt = txt.replacingOccurrences(of: "٢", with: "2")
        txt = txt.replacingOccurrences(of: "٣", with: "3")
        txt = txt.replacingOccurrences(of: "٤", with: "4")
        txt = txt.replacingOccurrences(of: "٥", with: "5")
        txt = txt.replacingOccurrences(of: "٦", with: "6")
        txt = txt.replacingOccurrences(of: "٧", with: "7")
        txt = txt.replacingOccurrences(of: "٨", with: "8")
        txt = txt.replacingOccurrences(of: "٩", with: "9")

        
        
        return txt
    }
    
    func verifyIP() -> Bool {
        let pattern_2 = "(25[0-5]|2[0-4]\\d|1\\d{2}|\\d{1,2})\\.(25[0-5]|2[0-4]\\d|1\\d{2}|\\d{1,2})\\.(25[0-5]|2[0-4]\\d|1\\d{2}|\\d{1,2})\\.(25[0-5]|2[0-4]\\d|1\\d{2}|\\d{1,2})"
        let regexText_2 = NSPredicate(format: "SELF MATCHES %@", pattern_2)
        let result_2 = regexText_2.evaluate(with: self)
        return result_2
    }
    
    private func regExprOfDetectingStringsBetween(str1: String, str2: String) -> String {
        return "(?:\(str1))(.*?)(?:\(str2))"
    }
    
    func replacingOccurrences(from subString1: String, to subString2: String, with replacement: String) -> String {
        let regExpr = regExprOfDetectingStringsBetween(str1: subString1, str2: subString2)
        return replacingOccurrences(of: regExpr, with: replacement, options: .regularExpression)
    }
    func removeParam() ->String{
        if let leftIdx = self.firstIndex(of: "("),
           let rightIdx = self.firstIndex(of: ")")
        {
            return String(self.prefix(upTo: leftIdx) + self.suffix(from: self.index(after: rightIdx)))
        }
        return self
    }

    
    // Returns the substring before the first “_”, or `nil` if absent.
    func partBeforeUnderscore() -> String? {
        guard let i = firstIndex(of: "_") else { return nil }
        return String(self[..<i])
    }
    
}
