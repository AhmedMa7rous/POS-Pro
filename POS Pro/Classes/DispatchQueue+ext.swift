//
//  DispatchQueue+ext.swift
//  pos
//
//  Created by khaled on 21/10/2021.
//  Copyright © 2021 khaled. All rights reserved.
//

import Foundation

extension DispatchQueue {
    static var currentLabel: String {
        return String(validatingUTF8: __dispatch_queue_get_label(nil))!
    }
}
