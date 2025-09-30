//
//  JSONAble.swift
//  pos
//
//  Created by M-Wageh on 12/06/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation
import GeideaParsingLib

protocol JSONAble {}

extension JSONAble {
    func toDictionary() -> [String:Any] {
        var dict = [String:Any]()
        let otherSelf = Mirror(reflecting: self)
        for child in otherSelf.children {
            if let key = child.label {
                dict[key] = child.value
            }
        }
        return dict
    }
}

extension Reconciliation:JSONAble {
}
extension Transaction:JSONAble{}
