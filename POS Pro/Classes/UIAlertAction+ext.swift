//
//  UIAlertAction+ext.swift
//  pos
//
//  Created by Khaled on 1/27/21.
//  Copyright © 2021 khaled. All rights reserved.
//

import Foundation

extension UIAlertAction {
    var titleTextColor: UIColor? {
        get {
            return self.value(forKey: "titleTextColor") as? UIColor
        } set {
            self.setValue(newValue, forKey: "titleTextColor")
        }
    }
}
