//
//  SingleInvocieItem.swift
//  pos
//
//  Created by  Mahmoud Wageh on 4/1/21.
//  Copyright © 2021 khaled. All rights reserved.
//

import Foundation
class SingleInvocieItem{
    var qty = ""
    var des = ""
    var price = ""
    var returnStyle = ""
    var price_unite = ""
    var price_additional_tax = ""

    init(qt:String, des:String, price:String,returnStyle:String, price_unite:String, price_additional_tax:String ) {
        self.qty = qt
        if SharedManager.shared.appSetting().enable_show_unite_price_invoice  && !price.isEmpty {
            self.price = price + " \(SharedManager.shared.getCurrencySymbol())"
        }else{
            self.price = price
        }
        self.des = des
        self.returnStyle = returnStyle
        self.price_unite = price_unite
        self.price_additional_tax = price_additional_tax
    }
}
