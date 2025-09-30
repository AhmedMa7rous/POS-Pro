//
//  PaymentDeviceProtocol.swift
//  pos
//
//  Created by M-Wageh on 12/06/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation

protocol PaymentDeviceProtocol:class {
    var updateStatusClosure: ((PaymentDeviceState,String?,Device_payment_order_class?) -> Void)? { get set }
    func checkConnection(with ip:String)

}

extension PaymentDeviceProtocol{
    func setPort(with port:Int){}
    func setTerminalID(with terminal:String){}
    func addToLog(ingenico_id:Int? = nil,key:String? = nil,prefix:String? = nil, data:String? = nil){}

}
