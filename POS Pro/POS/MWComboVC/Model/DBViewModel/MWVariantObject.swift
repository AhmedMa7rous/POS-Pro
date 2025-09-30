//
//  MWVariantObject.swift
//  pos
//
//  Created by M-Wageh on 17/05/2023.
//  Copyright © 2023 khaled. All rights reserved.
//

import Foundation
class MWVariantObject{
    var productID:Int?
    var attributesIds:[Int]?
    init(productID: Int? = nil, attributesIds: [Int]? = nil) {
        self.productID = productID
        self.attributesIds = attributesIds
    }
    static func getMWVariantObject(for productTmpID:Int ) -> [MWVariantObject]{
        var mwVariantObject:[MWVariantObject] = []
        let arr = product_attribute_value_class.get_all_attribute_value(product_tmpl_id: productTmpID)
        let productIDArray = arr.compactMap({$0["re_id1"] as? Int})
        productIDArray.forEach { productID in
            let attributesIds = arr.filter({($0["re_id1"] as? Int ?? 0)  == productID}).compactMap({$0["re_id2"] as? Int})
            if attributesIds.count > 0 {
                mwVariantObject.append(MWVariantObject(productID:productID,attributesIds:attributesIds))
            }
        }
        return mwVariantObject
    }
    static func getVariantDetails(productTmpID:Int,productId:Int,selectLine:pos_order_line_class?) -> (mwVariantObject:[MWVariantObject], subProducts:[SubProbuctObject], selectedItemProducts:[ItemProductObject]){
        var subProducts:[SubProbuctObject] = []
        var selectedItemProducts:[ItemProductObject] = []
        var mwVariantObject:[MWVariantObject] =  MWVariantObject.getMWVariantObject(for: productTmpID)
       
        let selectedID = mwVariantObject.filter({$0.productID == productId}).first?.attributesIds ?? []

        let varints_list = product_attribute_value_class.get_product_attribute_value(product_tmpl_id: (productTmpID))
        
        let list_attribute_id_id = Array(Set(varints_list.map({$0.attribute_id_id}))).sorted(by:<)
        
        list_attribute_id_id.forEach { attributeID in
            let variantList = varints_list.filter({$0.attribute_id_id == attributeID })
            let variantProducts = SubProbuctObject(from: variantList, multiSelected: false, type: .variant,selectedId:selectedID)
            subProducts.append(variantProducts)
            
            if  let selectedProduct = variantProducts.productItems?.filter({$0.isSelect ?? false}) , selectedProduct.count > 0 {
                selectedItemProducts.append(contentsOf: selectedProduct)
            }
            if let line = selectLine , let selectAttributeID = line.attribute_value_id{
                if  let selectedProduct = variantProducts.productItems?.filter({($0.productAttribute?.id ?? 0) == selectAttributeID }) , selectedProduct.count > 0 {
                    selectedItemProducts.append(contentsOf: selectedProduct)
                }
            }
            
        }
        
        return (mwVariantObject,subProducts,selectedItemProducts)
        
    }
}
