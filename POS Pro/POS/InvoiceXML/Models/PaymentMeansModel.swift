//
//  PaymentMeansModel.swift
//  pos
//
//  Created by M-Wageh on 01/04/2024.
//  Copyright © 2024 khaled. All rights reserved.
//

import Foundation
enum PAYMENT_MEANS_CODE:Int {
    case bank = 42
    case card = 48
    case cash = 10
    case transfer = 30
    case unknown = 1
}
class PaymentMeansModel{
    var Payment_Due_Date:String,Instruction_ID:String,Payment_ID:String,Payment_Means_Code:String,returnReson:String?
  
    init(order:pos_order_class,type:PAYMENT_MEANS_CODE){
        self.returnReson = nil
        if (order.parent_order_id ) != 0 {
            if let returnID = (order.return_reason_id ) {
                self.returnReson = pos_return_reason_class.get(by:returnID )?.name
            }else{
                self.returnReson = "Return reson note"
            }
        }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let date = formatter.date(from: order.write_date ?? "") {
            formatter.dateFormat = "yyyy-MM-dd"
            self.Payment_Due_Date  = formatter.string(from: date)
        }else{
            self.Payment_Due_Date = ""
        }
        
        
        self.Instruction_ID = order.name ?? ""
        self.Payment_ID = order.name ?? ""
        let accountJournals = order.get_account_journal()
        self.Payment_Means_Code = "\(type.rawValue)"
    }
}
