//
//  EInvoiceFRModel.swift
//  pos
//
//  Created by M-Wageh on 15/04/2024.
//  Copyright © 2024 khaled. All rights reserved.
//

import Foundation
struct EInvoiceFRModel: Codable, Hashable  {
    var timeStamp: Int? = Int(Date().timeIntervalSince1970 * 1000)
    var pih: String? = ""
    var order_uid:String? = ""
    var last_chain_index:Int? = -1


    init(pih:String,order_uid:String){
        self.pih = pih
        self.order_uid = order_uid
        self.last_chain_index = Int(cash_data_class.get(key: "last_chain_index") ?? "-1")
    }
}
