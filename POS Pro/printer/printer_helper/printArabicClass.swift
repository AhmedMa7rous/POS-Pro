//
//  print_arabic.swift
//  pos
//
//  Created by khaled on 8/27/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import Foundation


class printArabicClass:NSObject
{
    
    var arabicChar :[String:[String]] = [:]
    
    func initArabic()
    {
        //      arabicChar["ا"] = ["Beginning","Middle","End"]
        arabicChar["ا"] = ["\u{FE8D}","\u{FE8E}","\u{FE8E}"]
        arabicChar["ب"] = ["\u{FE91}","\u{FE91}",""]
        arabicChar["ت"] = ["\u{FE97}","\u{FE97}",""]
        arabicChar["ث"] = ["\u{FE9B}","\u{FE9B}",""]
        arabicChar["ج"] = ["\u{FE9F}","\u{FE9F}",""]
        arabicChar["ح"] = ["\u{FEA3}","\u{FEA3}",""]
        arabicChar["خ"] = ["\u{FEA7}","\u{FEA7}",""]
        arabicChar["د"] = ["","",""]
        arabicChar["ذ"] = ["","",""]
        arabicChar["ر"] = ["","",""]
        arabicChar["ز"] = ["","",""]
        arabicChar["س"] = ["\u{FEB3}","\u{FEB3}",""]
        arabicChar["ش"] = ["\u{FEB7}","\u{FEB7}",""]
        arabicChar["ص"] = ["\u{FEBB}","\u{FEBB}",""]
        arabicChar["ض"] = ["\u{FEBF}","\u{FEBF}",""]
        arabicChar["ط"] = ["","",""]
        arabicChar["ظ"] = ["","",""]
        arabicChar["ع"] = ["\u{FECB}","\u{FECC}","\u{FECA}"]
        arabicChar["غ"] = ["\u{FECF}","\u{FED0}","\u{FECE}"]
        arabicChar["ف"] = ["\u{FED3}","\u{FED3}",""]
        arabicChar["ق"] = ["\u{FED7}","\u{FED7}",""]
        arabicChar["ك"] = ["\u{FEDB}","\u{FEDB}",""]
        arabicChar["ل"] = ["\u{FEDF}","\u{FEDF}",""]
        arabicChar["م"] = ["\u{FEE3}","\u{FEE3}",""]
        arabicChar["ن"] = ["\u{FEE7}","\u{FEE7}",""]
        arabicChar["ه"] = ["\u{FEEB}","\u{FEEC}","\u{FEE9}"]
        arabicChar["و"] = ["","",""]
        arabicChar["ي"] = ["\u{FEF3}","\u{FEF3}","\u{FEF2}"]
        arabicChar["ﺀ"] = ["\u{FE8B}","\u{FE8B}",""]
        arabicChar["ئ"] = ["\u{FE8B}","\u{FE8B}",""]

        
        arabicChar["\u{FEFB}"] = ["\u{FEFB}","\u{FEFC}","\u{FEFC}"] // "لا"
       
        
        
    }
    
    
    func connectWithlast(char:String , last_chr:String) -> Bool
    {
         if last_chr == "ا" || last_chr == "\u{FE8E}"
            || last_chr == "و"  || last_chr == "د" || last_chr == "ذ" || last_chr == "ر" || last_chr == "ز" || last_chr == "ﺓ"
          
         {
            
            
            return false
         }
        
        
        return true
    }
    
    func clearText(txt:String) -> String {
        var str = txt
        
        str = str.replacingOccurrences(of: "", with: "ا")
        str = str.replacingOccurrences(of: "أ", with: "ا")
        str = str.replacingOccurrences(of: "آ", with: "ا")
        str = str.replacingOccurrences(of: "إ", with: "ا")

        str = str.replacingOccurrences(of: "ﺄ", with: "ﺎ")
        str = str.replacingOccurrences(of: "ﺂ", with: "ﺎ")

        if str.contains("لا")
        {
            str = str.replacingOccurrences(of: "لا", with: "\u{FEFB}")
        }
        
        str = str.replacingOccurrences(of: "ى", with: "ي")

        
        
        return str
    }
    
    func getString(txt:String) -> String {
         
        
        if !txt.isArabic
        {
           return txt
        }
        
        if txt.contains("\n")
        {
            var newTxt = ""
            var lines = txt.split(separator: "\n")
            lines =  lines.reversed()

            for line in 0...lines.count - 1
            {
                let temp_line = String(lines[line])
                newTxt = String (format: "%@\n%@", newTxt ,getString(txt: temp_line))
            }
            
            return newTxt
        }
        
        var printedText = ""
        let str = clearText(txt:txt)
        
        
        var words = str.split(separator: " ")
         words =  words.reversed()
        let lenWords = words.count
        
        
        for wordIndex in 0...lenWords - 1
        {
            let word = String( words[wordIndex]  )
            
            let lenWord = word.count
            var newWord:String = ""
            
            for n in 0...lenWord - 1
            {
                let index = word.index(word.startIndex, offsetBy: n)
                let chr:String = String( word[index])
                 let map = arabicChar[chr]
                 var  charToReplace = ""

                 if map == nil
                 {
                    charToReplace = chr
                 }
                else
                 {
             
                
                if n == 0 // in start
                {
                   charToReplace  = map![0]
                   
                }
                else if n == lenWord - 1 // in end
                {
                    let index = word.index(word.startIndex, offsetBy: n-1)
                    let last_chr:String = String( word[index])
                    
                    if connectWithlast(char: chr, last_chr: last_chr) == false
                    {
                        if chr  ==  "\u{FEE9}" //"ه"
                        {
                            charToReplace  = map![2]
                        }
                        else
                        {
                            charToReplace  = chr //map![0]
                        }
                        
                    }
                    else
                    {
                         charToReplace  = map![2]
                    }
                }
                else
                {
                    let index = word.index(word.startIndex, offsetBy: n-1)
                    let last_chr:String = String( word[index])
                    
                    if connectWithlast(char: chr, last_chr: last_chr) == false
                    {
                           charToReplace  = map![0]
                    }
                    else
                    {
                           charToReplace  = map![1]
                    }
                 
                   
                }
                
                if charToReplace.isEmpty
                {
                    charToReplace = chr
                }
                
                    
                }
                
                
                newWord = newWord + charToReplace

            }
            
            
            
//            newWord = String(newWord.reversed())

            printedText =   newWord + " " + printedText
            
        }
 
//          let   last_words =  printedText.split(separator: " ")
        printedText = String(printedText.reversed())
        return printedText
    }
    
    
}
