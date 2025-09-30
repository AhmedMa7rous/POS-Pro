//
//  ItemProductObject.swift
//  pos
//
//  Created by M-Wageh on 30/05/2023.
//  Copyright © 2023 khaled. All rights reserved.
//

import Foundation
class ItemProductObject{
    var isSelect:Bool?
    var selectQty:Double = 0
    var nameItemProduct:String?
    var sortNumber:Int?
    var idItem:Int?
    var productAttribute:product_attribute_value_class?
    var type:section_type?
    var line:pos_order_line_class?
    var mwAddOnList:[MWComboAddOnObject]?
    var addOnID:Int?
    var comboRelationID:Int?
    var productComboID:Int?
    var attributeIdArray:[Int]?

    convenience init(from productAttribute:product_attribute_value_class,type:section_type?,selectedId:[Int]){
        self.init()
        self.productAttribute = productAttribute
        self.sortNumber = productAttribute.id
        self.nameItemProduct = productAttribute.name
        self.idItem = productAttribute.id
        self.type = type
        self.isSelect = selectedId.contains(productAttribute.id)
    }
    convenience init(from note:pos_product_notes_class,currentNote:String?) {
        self.init()
        self.type = .note
        self.nameItemProduct = note.display_name
        self.idItem = note.id
        self.sortNumber = note.sequence
        self.selectQty = 0
        if currentNote?.contains(note.display_name) ?? false{
            self.selectQty = 1
            self.isSelect = true
        }
    }
   
    convenience init(from mwAddOnList:[MWComboAddOnObject],
                     addOnID:Int? = nil,
                     idItem:Int,
                     attributeIdArray:[Int],
                     comingLine:pos_order_line_class?,
                     selectVariantIDS:[Int]){
        self.init()
        self.mwAddOnList = mwAddOnList
        self.sortNumber = mwAddOnList.first?.product_id
        self.nameItemProduct = mwAddOnList.first?.display_name_combo_price
        self.idItem = mwAddOnList.first?.product_id
        self.type = .combo
        self.addOnID = addOnID
        self.attributeIdArray = attributeIdArray.sorted()

        if let  comingLine = comingLine,
            let isVoid = comingLine.is_void,
           !isVoid {
            self.line = comingLine
            self.selectQty = comingLine.qty
            if (comingLine.product_combo_id ?? 0 ) != 0 {
                self.productComboID = comingLine.product_combo_id
            }else{
                if let productComboIDs = mwAddOnList.first?.products_ids  , productComboIDs != 0{
                    self.productComboID = productComboIDs
                }
        }
            if (comingLine.combo_id ?? 0 ) != 0 {
                self.comboRelationID = comingLine.combo_id
            }else{
                if let productComboID = comingLine.product_combo_id {
                    if let productID = comingLine.product_id, let products_in_combo_id = relations_database_class.get_relations_id(re_id1:productComboID,re_id2:productID,re_table1_table2:"product_combo|product_product").first{
                        self.comboRelationID = products_in_combo_id

                    }
                   

                }else{
                    if let products_in_combo_id = mwAddOnList.first?.products_in_combo_id  , products_in_combo_id != 0{
                        self.comboRelationID = products_in_combo_id
                        
                    }
                }
            }
        }else{
            if let fitstAddOn =  mwAddOnList.first{
                if let productComboIDs = fitstAddOn.products_ids  , productComboIDs != 0{
                    self.productComboID = productComboIDs

                }
                if let products_in_combo_id = fitstAddOn.products_in_combo_id  , products_in_combo_id != 0{
                    self.comboRelationID = products_in_combo_id

                }
            }
            
            self.setQtyDefault(selectVariantIDS)
        }
      
    }
    func resetSelectQty(){
        self.selectQty = 0
        self.isSelect = false
    }
    func setQtyDefault(_ selectVariantIDS:[Int]){
        var mwAddOnDefaultQty:[Int] = []
        if selectVariantIDS.count > 0 {
             /*mwAddOnDefaultQty = mwAddOnList?.filter({(
                ($0.auto_select_num ?? 0) > 0 ) &&
                selectVariantIDS.contains($0.attribute_value_id ?? 0)}).compactMap({$0.auto_select_num}) ?? []*/
            mwAddOnDefaultQty = mwAddOnList?.filter({(($0.auto_select_num ?? 0) > 0 ) }).compactMap({$0.auto_select_num}) ?? []
        }else{
            mwAddOnDefaultQty = mwAddOnList?.filter({(($0.auto_select_num ?? 0) > 0 ) }).compactMap({$0.auto_select_num}) ?? []
        }
        if let defaultQty = mwAddOnDefaultQty.max() , defaultQty > 0 {
            self.selectQty = Double(defaultQty)
            self.isSelect = nil
        }else{
            resetSelectQty()

        }
    }
    func increaseQty(){
        self.selectQty += 1
    }
    func decreaseQty(){
        if self.selectQty > 1{
            self.selectQty -= 1
        }else{
            self.selectQty = 0
        }
    }
    func getISelected() -> Bool{
        return (self.selectQty ) > 0
    }
    
    /// Convert Item to pos_order_line
    /// - Parameters:
    ///   - order_id: order_id
    ///   - parentLineId: parentLineId
    ///   - parentProductId: parentProductId
    ///   - attributedSelected: variant attributedSelected
    /// - Returns: pos_order_line?
    func mwConvertToPosLine(_ order_id:Int,
                            _ parentLineId:Int,
                            _ parentProductId:Int,
                            _ attributedSelected:[Int])->pos_order_line_class?{
        let priceLisIdsString = self.mwAddOnList?.map({$0.priceListAddOn?.map({"\($0.id)"}).joined(separator: ",") ?? ""}).joined(separator: "")
        let extraPrice = self.getExtraPrice(attributedSelected,includePriceList: false)
        if let mwAddOn = self.mwAddOnList?.first, let productsID = mwAddOn.product_id,
            let addOnProduct = product_product_class.get(id: productsID) {
            var addOnLine:pos_order_line_class? = nil
            if let line = self.line{
                addOnLine = line
            }else{
                 addOnLine =  pos_order_line_class.create(order_id: order_id, product:addOnProduct )
                addOnLine?.uid = baseClass.getTimeINMS()
            }
          //  if parentLineId != 0 {
                if let priceLisIdsString = priceLisIdsString{
                    pos_line_add_on_price_list_class.addOrUpdate(lineUID: addOnLine?.uid ?? "", product_combo_price_line_ids: priceLisIdsString,extraPrice: extraPrice)
                }
          //  }
            
            guard let addOnLine = addOnLine else {
                return nil
            }
            addOnLine.is_combo_line = true
            addOnLine.parent_line_id = parentLineId
            addOnLine.parent_product_id = parentProductId
            addOnLine.product_combo_id = self.productComboID
            addOnLine.combo_id = self.comboRelationID
            addOnLine.qty = self.selectQty
            addOnLine.auto_select_num = addOnProduct.auto_select_num
            addOnLine.default_product_combo = addOnProduct.default_product_combo
            addOnLine.write_info = true
            let extraPrice =  getExtraPrice(attributedSelected)
            addOnLine.extra_price = extraPrice
            addOnLine.price_list_value = extraPrice
            addOnLine.priceListAddOn = mwAddOn.priceListAddOn
            addOnLine.price_unit = extraPrice > 0 ? extraPrice : 0
            addOnLine.update_values(checkAddOnPriceList: false)
            return addOnLine
        }
        return nil
    }
    
    /// Extra price for item
    /// - Parameter attributedSelected: variant attributedSelected
    /// - Returns: Extra price
    func getExtraPrice(_ attributedSelected:[Int],includePriceList:Bool = true) -> Double{
        if attributedSelected.count > 0 {
            let productAddons = self.mwAddOnList?.filter({($0.attribute_id == nil) || (attributedSelected.contains( $0.attribute_id ?? 0))}) ?? []
            let extraPrice = productAddons.compactMap({$0.getExtraPrice(includePriceList)}).reduce(0, +)
            return extraPrice
        }else{
            let extraPrice = self.mwAddOnList?.compactMap({$0.getExtraPrice(includePriceList) ?? 0}).max() ?? 0
            return extraPrice
        }
    }
    
    /// Title Varian with price
    /// - Returns: itle Varian with price
    func getTitleVariant()->String{
        var titleBtn = (self.nameItemProduct ?? "")
        if let price_extra = self.productAttribute?.price_extra.rounded(value: 2) ,price_extra > 0 {
            titleBtn +=  " ( " + "\(price_extra)" + " \(SharedManager.shared.getCurrencyName()) )"
        }
        return titleBtn
    }
    /// Convert [pos_line] to [ItemProductObject]
    /// - Parameter addOnsLines: [pos_order_line_class]
    /// - Returns: [ItemProductObject]
    static func getItemProductArray(from addOnsLines:[pos_order_line_class])->[ItemProductObject]{
        var itemProductArray:[ItemProductObject] = []
        addOnsLines.filter({!($0.is_void ?? false)}).forEach { addOnLine in
            let attributeIdArray = addOnLine.attribute_value_id ?? 0
            let productId =  addOnLine.product_id ?? 0
           
            itemProductArray.append( ItemProductObject(from: [MWComboAddOnObject(from: addOnLine)],addOnID: addOnLine.product_id, idItem:productId, attributeIdArray: [attributeIdArray], comingLine: addOnLine,selectVariantIDS: []))
        }
        return itemProductArray
    }
    /// getUpdatedMWItemProductList by compare itemProductList fetch from database with selectedItemProductList
    /// - Parameters:
    ///   - itemProductList:  itemProductList fetch from database
    ///   - selectedItemProductList:  itemProductList fetch from order
    /// - Returns: updated [ItemProductObject]
    static func getUpdatedMWItemProductList(for itemProductList:[ItemProductObject],
                                            from selectedItemProductList:[ItemProductObject],
                                            isRadioChose:Bool)->[ItemProductObject]{
        if selectedItemProductList.count <= 0 {
            return itemProductList
        }
        if isRadioChose{
            itemProductList.forEach({$0.resetSelectQty()})
        }
        var updateItemProductList:[ItemProductObject] = []
        SharedManager.shared.printLog( "itemProductList comboRelationID = \(itemProductList.map({$0.comboRelationID}))")
        SharedManager.shared.printLog( "selectedItemProductList comboRelationID = \(selectedItemProductList.map({$0.comboRelationID}))")

        itemProductList.forEach { itemProduct  in
            if let index = selectedItemProductList.firstIndex(where: {$0.idItem == itemProduct.idItem}) {
                var updatedItemProductObject = ItemProductObject()
                updatedItemProductObject = selectedItemProductList[index]
                updatedItemProductObject.mwAddOnList = itemProduct.mwAddOnList
                updatedItemProductObject.nameItemProduct = itemProduct.nameItemProduct
                updatedItemProductObject.sortNumber = itemProduct.sortNumber
                updatedItemProductObject.isSelect = true
                updatedItemProductObject.addOnID = itemProduct.addOnID
                updatedItemProductObject.comboRelationID = itemProduct.comboRelationID
                updatedItemProductObject.selectQty = selectedItemProductList[index].selectQty
                updatedItemProductObject.line = selectedItemProductList[index].line
                updateItemProductList.append(updatedItemProductObject)
            }else{
                itemProduct.selectQty = 0
                updateItemProductList.append(itemProduct)

            }
        }
        
        return updateItemProductList
    }
    
    func changeOrderType(with orderType:delivery_type_class?){
        self.mwAddOnList?.forEach({ mwAddOn in
            mwAddOn.setPriceListValue(for:orderType )
        })
    }
    
}
extension ItemProductObject:Equatable{
    static func == (lhs: ItemProductObject, rhs: ItemProductObject) -> Bool {
        if let _ = lhs.mwAddOnList, let _ = rhs.mwAddOnList{
            if  lhs.addOnID != nil && rhs.addOnID != nil {
                return lhs.idItem == rhs.idItem && lhs.addOnID == rhs.addOnID
            }
            if  lhs.comboRelationID != nil && rhs.comboRelationID != nil {
                return lhs.comboRelationID == rhs.comboRelationID
            }
            
           return lhs.idItem == rhs.idItem && (lhs.addOnID == rhs.addOnID || lhs.comboRelationID == rhs.comboRelationID )
        }
        return lhs.idItem == rhs.idItem
    }
    
    
}
