//
//  CreateAdjustmentModel.swift
//  pos
//
//  Created by M-Wageh on 03/08/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation
enum ADJUSTMENT_TYPE:Int{
    case PRODUCT = 0, CATEGORY
}
class CreateAdjustmentModel{
    
    var name:String?
    var pos_config_id:Int?
    var select_by:String?
    var exhausted:Bool?
    var products: [StorableItemModel]?
    var categories:[StorableCategoryModel]?
    var typeAdjustment:ADJUSTMENT_TYPE = .PRODUCT
    func toDictionary() -> [String:Any]?{
        guard let name = name,
              let exhausted = exhausted
              else { return nil }
        
        var dic:[String:Any] =  [
            "name": name,
            "pos_config_id": pos_config_id ?? 0,
            "exhausted": exhausted
        ]
        if let products = products , (products.count) > 0 , typeAdjustment == .PRODUCT{
            var product_ids:[Any] = []
            product_ids.append([6,0,products.map({$0.id})])
            dic["product_ids"] = product_ids
            dic["select_by"] = "products"

        }
        if let categories = categories ,  (categories.count) > 0 , typeAdjustment == .CATEGORY {
            var category_ids:[Any] = []
            category_ids.append([6,0,categories.map({$0.categoryID})])
            dic["category_ids"] = category_ids
            dic["select_by"] = "categories"


        }
        return dic
    
    }
    init(with name:String = "",exhaustedFlag:Bool = false){
        let posID = SharedManager.shared.posConfig().id
        pos_config_id = posID
        exhausted = exhaustedFlag
    }
    
    func isValidate()->Bool{
        if name?.isEmpty ?? true{
            return false
        }
//        let products = self.products ?? []
        if typeAdjustment == .CATEGORY{
            let categories = self.categories ?? []
            if categories.count <= 0 {
                return false
            }
            
        }
        
        return true
    }
    func getNameSelectedItems()->String{
        if let products = products, products.count > 0 {
            return products.map({$0.display_name ?? ""}).joined(separator: ",").trunc(length: 40)
        }else{
            if let categories = categories,  categories.count > 0{
                return categories.map({$0.categoryName ?? ""}).joined(separator: ",").trunc(length: 40)
            }else{
                if typeAdjustment == .PRODUCT{
                    return "All".arabic("الكل")
                }else{
                    return "Select...".arabic("اختر...")
                }

            }
        }
    }
}
