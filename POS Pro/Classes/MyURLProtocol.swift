//
//  MyURLProtocol.swift
//  pos
//
//  Created by khaled on 7/23/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import Foundation

var requestCount = 0

class MyURLProtocol: URLProtocol {
    override open class func canInit(with request: URLRequest) -> Bool {
        // Print valuable request information.
       SharedManager.shared.printLog("? Running request: \(request.httpMethod ?? "") - \(request.url?.absoluteString ?? "")")
        
        // By returning `false`, this URLProtocol will do nothing less than logging.
        return false
    }
}
