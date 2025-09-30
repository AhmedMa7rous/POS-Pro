//
//  receiptFormater.swift
//  pos
//
//  Created by khaled on 8/20/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

class receiptFormater: NSObject {

    enum align {
        case none
        case center
        case titleLeft_valRight
    }
    
    var line_length = 28
    var val_length = 0

 
    var receipt:String = ""
    
 
    func getTextLines(str:String, lineLength:Int) -> [String]
    {
        var txt:[String] = []
        
        let len_str = str.count
        if len_str < lineLength {return [str]}
        
        let arr_words = str.split(separator: " ")
        
        var newLine = ""
        for n in 0...arr_words.count - 1
        {
            let word = arr_words[n]
            
            if newLine.count + word.count < line_length
            {
                newLine = newLine + " " + String(word)
            }
            else
            {
              
                txt.append(newLine)
                newLine = String( word)
             
            }
            
            if n == arr_words.count - 1
            {
                 txt.append(newLine)
 
            }
        }
        
        
        return txt
    }
    
    func addLine(title:String ,  val:String,alignMode:align)   {
      
        let length_title = title.count
        var value = val
        
        if  value.isEmpty {
            value = addSpaces(spaceNumber: val_length)
        }
        
        let length_val = value.count
        let length_total = length_title + length_val
        
        if (length_total > line_length)
        {
            
            var avalible_length_title = line_length - length_val
 
            let count:Double = Double(length_title) / Double(avalible_length_title)
            
            let isInteger = count.truncatingRemainder(dividingBy: 1) == 0

            var  count_Lines:Int = Int(count)
            if (isInteger == false)
            {
                   count_Lines += 1
            }
         
    

            var str_lines:String = ""
            if count_Lines > 0
            {
                for n in 0...count_Lines-1
                {
                    var length_title_local = avalible_length_title
                    let lenght_cut_start = n * length_title_local
                    
                    // range
                    let start = title.index(title.startIndex, offsetBy: lenght_cut_start)
                    
                    if (lenght_cut_start + length_title_local > length_title)
                    {
                        length_title_local = length_title - lenght_cut_start
                    }
                    
                    let end = title.index(start, offsetBy: length_title_local   )
                    let range = start..<end
                    
                    let substring = title[range]
                    
                    
                    if (n == 0)
                    {
                        
                        receipt = receipt + "\n" + substring + " " + val
                        
                    }
                    else
                    {
                        let length_def = line_length - substring.count
                        
                        str_lines = str_lines +
                            "\n" + substring + addSpaces(spaceNumber: length_def)
                        
                        
                    }
                }
            }
           
            
            receipt = receipt + str_lines
            
        }
         else
        {
        

            if alignMode == .none
            {
                    receipt = receipt + "\n" + title + val
                
                let length_def = line_length - length_total
              
                
                receipt = receipt + addSpaces(spaceNumber: length_def)
            }
            else if (alignMode == .titleLeft_valRight)
            {
                 let length_def = line_length - length_total
                 receipt = receipt + "\n" + title + addSpaces(spaceNumber: length_def) + val
            }
            else
            {
                    receipt = receipt + "\n" + title + val
            }
            
        
        }
        
    }
    
    func addSpaces(spaceNumber:Int) -> String {
        
        if spaceNumber == 0
        {
        return ""
        }
        
        var spaces = ""
        
        for _ in 0...spaceNumber-1 {
            spaces = spaces + " "
        }
        
        return spaces
    }
    
}
