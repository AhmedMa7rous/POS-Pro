//
//  MWComboAddOnObject.swift
//  pos
//
//  Created by M-Wageh on 17/05/2023.
//  Copyright © 2023 khaled. All rights reserved.
//

import Foundation
/// MWComboAddOnObject is Model represent view relation ship database
class MWComboAddOnObject{
    var id:Int?
    var display_name:String?
    var no_of_items:Int?
    var min_no_of_items:Int?
    var product_tmpl_id:Int?
    var product_tmpl_name:String?
    var require:Bool?
    var pos_category_id:Int?
    var pos_category_id_name:String?
    var __last_update:String?
    var sequence:Int?
    var deleted:Bool?
    var re_id1:Int?
    var attribute_id:Int?
    var products_in_combo_id:Int?
    var products_ids:Int?
    var products_ids2:Int?
    var attribute_value_id:Int?
    var auto_select_num:Int?
    var display_name_combo_price:String?
    var product_id:Int?
    var product_name:String?
    var product_tmpl_id_combo_price:Int?
    var product_tmpl_name_combo_price:String?
    private var extra_price:Double?
    var selectQty:Double?
    var priceListAddOn:[product_combo_price_line_class]?
    private var price_list_value:Double?


    init(from dictionary:[String:Any]){
        id = dictionary["id"] as? Int
        display_name = dictionary["display_name"] as? String
        no_of_items = dictionary["no_of_items"] as? Int
        min_no_of_items = dictionary["min_no_of_items"] as? Int
        product_tmpl_id = dictionary["product_tmpl_id"] as? Int
        product_tmpl_name = dictionary["product_tmpl_name"] as? String
        require = dictionary["require"] as? Bool
        pos_category_id = dictionary["pos_category_id"] as? Int
        pos_category_id_name = dictionary["pos_category_id_name"] as? String
        __last_update = dictionary["__last_update"] as? String
        sequence = dictionary["sequence"] as? Int
        deleted = dictionary["deleted"] as? Bool
        re_id1 = dictionary["re_id1"] as? Int
        attribute_id = dictionary["attribute_id"] as? Int
        products_in_combo_id = dictionary["products_in_combo_id"] as? Int
        products_ids = dictionary["products_ids"] as? Int
        products_ids2 = dictionary["products_ids2"] as? Int
        attribute_value_id = dictionary["attribute_value_id"] as? Int
        auto_select_num = dictionary["auto_select_num"] as? Int
        display_name_combo_price = dictionary["display_name_combo_price"] as? String
        product_id = dictionary["product_id"] as? Int
        product_name = dictionary["product_name"] as? String
        product_tmpl_id_combo_price = dictionary["product_tmpl_id_combo_price"] as? Int
        product_tmpl_name_combo_price = dictionary["product_tmpl_name_combo_price"] as? String
        extra_price = dictionary["extra_price"] as? Double
        selectQty = 0
        priceListAddOn = nil
        price_list_value = nil
        
        
    }
    convenience init(from line:pos_order_line_class) {
        self.init(from: [:])
        self.product_id = line.product_id
//        self.products_ids = line.parent_product_id
        self.products_in_combo_id = line.combo_id
        self.selectQty = line.qty
        self.auto_select_num = line.auto_select_num
        self.products_ids = line.product_combo_id
    }
    func getExtraPrice(_ includePriceList:Bool)->Double?{
        if includePriceList{
            if let price_list_value = price_list_value {
                return price_list_value
            }
        }
        return self.extra_price
    }
    
    func setPriceListAddOn(with items:[product_combo_price_line_class] ){
        self.priceListAddOn?.removeAll()
        self.priceListAddOn = []
        self.priceListAddOn?.append(contentsOf: items)
    }
    func setPriceListValue(for orderType:delivery_type_class?) {
        self.price_list_value = nil
        if let priceListAddOn = priceListAddOn, let orderType = orderType, priceListAddOn.count > 0{
            let priceListID = orderType.pricelist_id
            if let priceListValue = priceListAddOn.filter({$0.price_list_id == priceListID }).first?.price{
                self.price_list_value = priceListValue
            }
        }
    }
    static func fetchAddOnPriceList(for productTmpID:Int) -> [product_combo_price_line_class]{
       return product_combo_price_line_class.getPriceList(for:productTmpID )
    }
    /// get AddOns for productTmpID with attribute_value_id
    /// - Parameters:
    ///   - productTmpID: productTmpID
    ///   - attribute_value_id: attribute_value_id
    ///   - selectedAddOns: selectedAddOns
    ///   - selectVariantIDS: selectVariantIDS

    /// - Returns:mwComboAddOnObject:[MWComboAddOnObject], subProducts:[SubProbuctObject], selectedItemProducts:[ItemProductObject]
    static func getComboDetails(productTmpID:Int,
                                attribute_value_id_query:Int? = nil,
                                selectedAddOns:[ItemProductObject],
                                selectVariantIDS:[Int],orderType:delivery_type_class?, selectedQtyForCombo: Double,selectLine:pos_order_line_class?) -> (mwComboAddOnObject:[MWComboAddOnObject],
                                                                        subProducts:[SubProbuctObject],
                                                                        selectedItemProducts:[ItemProductObject]){
        //MARK: -Fetch from Database addOns for productTmpID
        let mwComboAddOnObject = MWComboAddOnObject.getMWComboAddOnObject(product_tmpl_id: productTmpID, attribute_value_id: attribute_value_id_query,orderType: orderType)
        let addOnsIds = Array(Set(mwComboAddOnObject.compactMap { $0.products_ids }))
        //MARK: -Convert [MWComboAddOnObject] to [SubProbuctObject]
        var subProducts:[SubProbuctObject] = []
        var selectedItemProducts:[ItemProductObject] = []
        addOnsIds.forEach { addOnID in
            let addOnObjects:[MWComboAddOnObject] = mwComboAddOnObject.filter({$0.products_ids ==  addOnID})
            let subProductSequence = addOnID
            let subProductName = addOnObjects.first?.pos_category_id_name ?? ""
            let subProductNomItems = addOnObjects.first?.no_of_items ?? 1
            let subProductRequired = addOnObjects.first?.require ?? false
            let subProductMiniQty = addOnObjects.first?.min_no_of_items ?? -1

            let addOnProductsIds:[Int] = Array(Set(addOnObjects.compactMap { $0.product_id }))
            let attributeIdArray = Array(Set(addOnObjects.compactMap({$0.attribute_value_id})))

            var mwItemProductList: [ItemProductObject] = []
            addOnProductsIds.forEach { addOnProductId in
                let addOnProductObject:[MWComboAddOnObject] = addOnObjects.filter({$0.product_id == addOnProductId })
                let addOnLine = selectLine?.selected_products_in_combo.filter({(($0.product_id ?? 0) == addOnProductId) && !($0.is_void ?? false)}).first
                mwItemProductList.append(ItemProductObject(from: addOnProductObject,
                                                           addOnID: addOnID,
                                                           idItem: addOnProductId,
                                                           attributeIdArray:attributeIdArray ,
                                                           comingLine: addOnLine,
                                                           selectVariantIDS:selectVariantIDS ))
            }

            let updatedMWItemProductList = ItemProductObject.getUpdatedMWItemProductList(for:mwItemProductList,
                                                                                         from: selectedAddOns,
                                                                                         isRadioChose: subProductNomItems <= 1)
            selectedItemProducts.append(contentsOf: updatedMWItemProductList.filter({$0.getISelected()}))
            if let selectLine = selectLine {
                let addOnSelected = selectLine.selected_products_in_combo
                if addOnSelected.count > 0 {
                    addOnSelected.forEach { addOn in
                        if let comboID = addOn.product_id , !(addOn.is_void ?? false){
                            let selectAddon = updatedMWItemProductList.filter({$0.idItem == comboID})
                            if selectAddon.count > 0 {
                                selectAddon.forEach { selectAddOns in
                                    selectAddOns.selectQty = addOn.qty
                                    selectedItemProducts.append(selectAddOns)
                                }
                            }
                        }
                    }
                }
            }

            let subProdutcAddOn = SubProbuctObject(from: updatedMWItemProductList,
                                                   multiSelected: false,
                                                   attributeValueId: attributeIdArray,
                                                   isRequire: subProductRequired,
                                                   sequence: subProductSequence,
                                                   min_no_of_items: subProductMiniQty,
                                                   no_of_items: subProductNomItems,
                                                   selectedQtyForCombo: Int(selectedQtyForCombo),
                                                   sectionID: subProductSequence,
                                                   name:subProductName )
            if (subProdutcAddOn.getQtyProudctsItems()) > (Double(subProductNomItems) * selectedQtyForCombo) {
                subProdutcAddOn.productItems?.forEach({ itemProduct in
                    if itemProduct.isSelect == nil && itemProduct.selectQty > 0{
                        itemProduct.selectQty = 0
                    }
                })
            }


            subProducts.append( subProdutcAddOn )


        }

        return (mwComboAddOnObject,subProducts,selectedItemProducts)
    }
   
    static func getMWComboAddOnObject(product_tmpl_id:Int,attribute_value_id:Int?,orderType:delivery_type_class?) -> [MWComboAddOnObject]
    {
        
        var sql_attribute_1 = ""
        var sql_attribute_2 = ""
        
        if  let attribute_value_id = attribute_value_id
        {
            sql_attribute_1 = " and re_id2 = \(attribute_value_id)"
            sql_attribute_2 = " and attribute_value_id = \(attribute_value_id)"
            
        }
        
        var sql = """
                 SELECT  * from
                    (SELECT * from product_combo where product_tmpl_id = \(product_tmpl_id) and product_combo.deleted = 0) as product_combo
                    inner join
                     (SELECT  re_id1 , re_id2 as attribute_id  FROM relations where re_table1_table2 = 'product_combo|attribute_value_ids'  and relations.deleted = 0 \(sql_attribute_1) ) as attribute_values
                     on product_combo.id  = attribute_values.re_id1
                     
                     INNER JOIN
                     (SELECT id as products_in_combo_id , re_id1  as products_ids ,re_id2  as products_ids2 from relations where re_table1_table2  = 'product_combo|product_product'  and relations.deleted = 0 )  as products_in_combo
                     on product_combo.id  = products_in_combo.products_ids
                     
                      inner join
                     ( select product_combo_price.attribute_value_id ,product_combo_price.auto_select_num ,product_combo_price.display_name as display_name_combo_price ,product_combo_price.product_id
                     ,product_combo_price.product_name ,product_combo_price.product_tmpl_id as product_tmpl_id_combo_price ,product_combo_price.product_tmpl_name as product_tmpl_name_combo_price,product_combo_price.extra_price  FROM product_combo_price
                     where    product_combo_price.product_tmpl_id  = \(product_tmpl_id)  \(sql_attribute_2) and product_combo_price.deleted = 0) as  combo_price
                    on  products_in_combo.products_ids2 = combo_price.product_id
                    and attribute_value_id =  attribute_values.attribute_id
        
                UNION
        
              SELECT * from (
                       SELECT  * from
                       (SELECT * from product_combo where product_tmpl_id = \(product_tmpl_id) and product_combo.deleted = 0) as product_combo
                       left join
                        (SELECT  re_id1 , re_id2 as attribute_id  FROM relations where re_table1_table2 = 'product_combo|attribute_value_ids'   and relations.deleted = 0 ) as attribute_values
                        on product_combo.id  = attribute_values.re_id1
                        where re_id1  is NULL ) as pp
                        
                        
                        INNER JOIN
                        (SELECT id as products_in_combo_id ,re_id1  as products_ids ,re_id2  as products_ids2 from relations where re_table1_table2  = 'product_combo|product_product'  and relations.deleted = 0 )  as products_in_combo
                        on pp.id  = products_in_combo.products_ids
                        
                         inner join
                        ( select product_combo_price.attribute_value_id ,product_combo_price.auto_select_num ,product_combo_price.display_name as display_name_combo_price ,product_combo_price.product_id
                        ,product_combo_price.product_name ,product_combo_price.product_tmpl_id as product_tmpl_id_combo_price ,product_combo_price.product_tmpl_name as product_tmpl_name_combo_price,product_combo_price.extra_price  FROM product_combo_price
                        where    product_combo_price.product_tmpl_id  = \(product_tmpl_id) and product_combo_price.deleted = 0 ) as  combo_price
                       on  products_in_combo.products_ids2 = combo_price.product_id
 """
        
        
        
        sql = sql + " ORDER by product_combo.'sequence' , products_in_combo.products_in_combo_id"
        
//               SharedManager.shared.printLog(sql)
        let addOnPriceList = fetchAddOnPriceList(for: product_tmpl_id)
        let arr =  database_class().get_rows(sql: sql)
        let mwComboAddOnObject = arr.map({MWComboAddOnObject(from: $0)})
         mwComboAddOnObject.forEach { mwComboAddOn  in
             let productID = mwComboAddOn.product_id
             if let attributeID = mwComboAddOn.attribute_id{
                 mwComboAddOn.setPriceListAddOn(with: addOnPriceList.filter({$0.product_id == productID && ($0.attribute_value_id == attributeID || $0.attribute_value_id == 0 ) }) )
             }else{
                 mwComboAddOn.setPriceListAddOn(with: addOnPriceList.filter({$0.product_id == productID }) )
             }
             mwComboAddOn.setPriceListValue(for: orderType)
         }

        return mwComboAddOnObject
    }
    
    func isSelected()->Bool{
        return (self.selectQty ?? 0) > 0
    }
    
    
}
extension MWComboAddOnObject:Equatable{
    static func == (lhs: MWComboAddOnObject, rhs: MWComboAddOnObject) -> Bool {
        return lhs.product_id == rhs.product_id  && lhs.products_in_combo_id == rhs.products_in_combo_id
    }
    
    
}
