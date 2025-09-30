//
//  STCClass.swift
//  pos
//
//  Created by Khaled on 1/8/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import UIKit


enum STC_PaymentStatus:Int {
    case none = 0 , Pending = 1 , Paid = 2 , Cancelled = 4 , Expired = 5  , requestedPayment = 10 , responsePayment = 11
}

class STC_Class: NSObject {
    var order_id:Int!
    var amount:Double = 0
     var MobileNo:String = ""
     var RefNum:String = ""
    var BillNumber:String = ""
    var AuthorizationReference = ""
    
    
}
