//
//  D1BarCodeModel.swift
//  pos
//
//  Created by M-Wageh on 12/04/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation
struct D1BarCodeModel {
    var weight:Double?
    var productID:Int?
    var d1barcode:String?

    
    init(D1barcode:String){
        self.d1barcode = D1barcode
        let setting = SharedManager.shared.appSetting()
        let start_value_for_bar_code = setting.start_value_for_bar_code
        let start_index_for_bar_code = setting.postion_start_id_for_bar_code == 0 ? 1 : setting.postion_start_id_for_bar_code

        if isEAN13(D1barcode) {
            let countBarCode = D1barcode.count
            let startIdIndex = start_index_for_bar_code - 1 
            let middleIndex = countBarCode - 6
            let endWeightIndex = countBarCode - 1
            let wString = D1barcode.substring_ext(with: middleIndex..<endWeightIndex)
            let idString = D1barcode.substring_ext(with: startIdIndex..<middleIndex)
            
            if let wDouble = Double(wString){
                weight = wDouble/1000
            }
            if let idInt = Int(idString){
                productID = idInt
            }
        }
    }
    func isEAN13(_ D1barcode:String)->Bool{
        let gtinRegex = "^(\\d{8}|\\d{12,14})$"
        let barcodeTest = NSPredicate(format: "SELF MATCHES %@", gtinRegex)
        return barcodeTest.evaluate(with: D1barcode)
    }
    
}
