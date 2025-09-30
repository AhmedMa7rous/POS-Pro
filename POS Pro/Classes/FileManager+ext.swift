//
//  FileManager+ext.swift
//  pos
//
//  Created by khaled on 11/3/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import Foundation

extension FileManager {
    class func documentsDir() -> String {
        var paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as [String]
        return paths[0]
    }
    
    class func cachesDir() -> String {
        var paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true) as [String]
        return paths[0]
    }
}
