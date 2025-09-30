//
//  UISearchBar+ext.swift
//  pos
//
//  Created by Khaled on 7/28/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import Foundation
extension UISearchBar {
    
    var textField: UITextField? {
        
        return subviews.map { $0.subviews.first(where: { $0 is UITextInputTraits}) as? UITextField }
            .compactMap { $0 }
            .first
    }
    
    func changeSearchBarColor(color : UIColor) {
           for subView in self.subviews {
               for subSubView in subView.subviews {
                   
                   if let _ = subSubView as? UITextInputTraits {
                       let textField = subSubView as! UITextField
                       textField.backgroundColor = color
                       break
                   }
                   
               }
           }
       }
    
}
