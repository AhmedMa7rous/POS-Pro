//
//  ComboObject.swift
//  pos
//
//  Created by M-Wageh on 10/05/2023.
//  Copyright © 2023 khaled. All rights reserved.
//

import Foundation
/**
    [For Using in UI]
 */

class MultiProductObject{
    
    /// UI Attributes
    var showInfo:Bool?
    var showStock:Bool?
    var showPromotion:Bool?
    var sortNumber:Int?
    var nameMultiProduct:String?
    var selectQty:Double = 1.0
    var subProducts:[SubProbuctObject]?
    var allSubProducts:[SubProbuctObject]?
    var productDB:product_product_class?
    var line:pos_order_line_class?
    var allNotes:SubProbuctObject?
    var note:String?
    var totalPrice:Double?
    
    /// LOGIC Attributtes
    private var selectedVariant: [ItemProductObject] = []
    private var unSelectedVariant: [ItemProductObject] = []
    private var selectedAddOns: [ItemProductObject] = []
    private var unSelectedAddOns: [ItemProductObject] = []
    private var selectedNote: [ItemProductObject] = []
    private var unSelectedNote: [ItemProductObject] = []
    private var variantDetails: (mwVariantObject: [MWVariantObject], subProducts: [SubProbuctObject], selectedItemProducts: [ItemProductObject])?
    private var addOnsDetails: (mwComboAddOnObject: [MWComboAddOnObject], subProducts: [SubProbuctObject], selectedItemProducts: [ItemProductObject])?
    
    init(from line:pos_order_line_class ){
        self.line = line
        let product = line.product
        productDB = product
        selectQty = line.qty <= 0 ? 1.0 : line.qty
        if line.is_combo_line == true && line.parent_line_id != 0
        {
            showInfo = true
        }
        if product?.type != "product"
        {
            showStock = true
        }
        if let varientID = line.attribute_value_id , let product_id = line.product_id{
            if let attribute_value_class = product_attribute_value_class.get_product_attribute_value_class(product_id:product_id , attribute_value_id: varientID){
                ItemProductObject(from: attribute_value_class, type: section_type.variant, selectedId: [varientID])

            }
        }
        subProducts = []
        allSubProducts = []

        selectedVariant = []
        unSelectedVariant = []
        selectedAddOns = []
        unSelectedAddOns = []
        self.nameMultiProduct  = self.productDB?.display_name
        
        let tax = line.get_tax(price: line.get_price(),discount: 0)
        self.line?.price_subtotal_incl = tax.total_included
        self.line?.price_subtotal = tax.total_excluded
        
        self.totalPrice = self.line?.price_subtotal_incl ?? 1.0
       
    }
    func changeOrderType(orderType:delivery_type_class?){
        self.allSubProducts?.forEach({ subProduct in
            subProduct.changeOrderType(with: orderType)
        })
        self.subProducts?.forEach({ subProduct in
            subProduct.changeOrderType(with: orderType)
        })
        
        self.selectedAddOns.forEach({ addOn in
            addOn.changeOrderType(with: orderType)
        })
        
    }
    
    func sort() -> MultiProductObject {
        subProducts = subProducts?.map({$0.sort()}).sorted(by: {($0.sortNumber ?? 0) < ($1.sortNumber ?? 0) })
        return self
    }
    func setAddOnQtyDefault(){
        self.subProducts?.forEach({ subProduct in
            if subProduct.type == .combo {
                subProduct.productItems?.forEach({ itemProductObject in
                    
                    if itemProductObject.isSelect == nil {
                        itemProductObject.selectQty = 0
                        self.removeFromAddOn(itemProductObject, isSelected: nil)
                        self.appendToAddOn(itemProductObject, isSelected: false)
                    }
                    if (!itemProductObject.getISelected()){
                        itemProductObject.setQtyDefault(self.getSelectedVariantIds())
                        if itemProductObject.getISelected(){
                            self.removeFromAddOn(itemProductObject, isSelected: nil)
                            self.appendToAddOn(itemProductObject, isSelected: true)
                        }
                    }
                })
            }
        })
    }
    func filterSortSubProducts(){
        var selectedVariantids = getSelectedVariantIds()
//        selectedVariantids.append(0)
        let filterSubProducts = self.allSubProducts?.filter({ subProduct in
            if subProduct.type == .combo{
                return subProduct.checkAvaliablity(for: selectedVariantids)
            }
            return true
        }) ?? []
        if  (self.subProducts?.count ?? 0) > 0 {
            //Case When chose variant and filter selected addons
            let filterSubProductsIDS = filterSubProducts.map({$0.sectionID ?? 0})
            self.removeItemsDepandVariant(filterSubProductsIDS)
        }
//
       
        self.subProducts?.removeAll()
        self.subProducts?.append(contentsOf:filterSubProducts )
        self.sort()
        if let allNotes = self.allNotes{
            self.subProducts?.append(allNotes)
        }
        if (line?.id ?? 0) <= 0 {
            self.setAddOnQtyDefault()
        }
        
        
    }
    func removeItemsDepandVariant(_ filterSubProductsIDS: [Int]){
        if filterSubProductsIDS.count <= 0 {
            return
        }
        let unSelectAddOnItems = self.selectedAddOns.filter({!filterSubProductsIDS.contains( $0.addOnID ?? 0)})
        if unSelectAddOnItems.count > 0 {
            unSelectAddOnItems.forEach { unSelectAddOnItem in
                self.removeFromAddOn(unSelectAddOnItem, isSelected: nil)
                self.resetItemFromAllSubProduct(unSelectAddOnItem)
                self.appendToAddOn(unSelectAddOnItem, isSelected: false)
            }
        }
    }
    func resetItemFromAllSubProduct(_ itemProductObject:ItemProductObject){
        if let indexSubProduct = self.allSubProducts?.firstIndex(where: {$0.sectionID == itemProductObject.addOnID}),
           let indexItem = self.allSubProducts?[indexSubProduct].productItems?.firstIndex(where: {$0 == itemProductObject }){
            self.allSubProducts?[indexSubProduct].productItems?[indexItem].setQtyDefault(self.getSelectedVariantIds())
        }
    }
    func setSubProducts(orderType:delivery_type_class?){
        if let line = line, let product = productDB , let product_tmpl_id = product.product_tmpl_id {
            self.note = line.note
            variantDetails = MWVariantObject.getVariantDetails(productTmpID: product_tmpl_id , productId: product.id,selectLine: self.line)
            
            self.selectedVariant.append(contentsOf:  variantDetails?.selectedItemProducts ?? [])
           
            let defaultSelectedAddOns = ItemProductObject.getItemProductArray(from:line.selected_products_in_combo)
            
            addOnsDetails = MWComboAddOnObject.getComboDetails(productTmpID: product_tmpl_id,
                                                               selectedAddOns:defaultSelectedAddOns,
                                                               selectVariantIDS:variantDetails?.selectedItemProducts.compactMap({$0.idItem}) ?? [],
                                                               orderType:orderType, selectedQtyForCombo: self.selectQty, selectLine: self.line)

            selectedAddOns.append(contentsOf:  addOnsDetails?.selectedItemProducts ?? [])
            
            self.allSubProducts?.append(contentsOf: variantDetails?.subProducts ?? [])
            self.allSubProducts?.append(contentsOf: addOnsDetails?.subProducts ?? [])
            
            var list_notes:[pos_product_notes_class] =  pos_product_notes_class.get(for: productDB?.pos_categ_id)
            if list_notes.count > 0
            {
                if  let pos_categ_id = line.product?.pos_categ_id, pos_categ_id != 0
                {
                    for item in list_notes
                    {
                        let pos_category_ids = item.get_pos_category_ids() // item["pos_category_ids"] as? [Int]
                        let index =  pos_category_ids.firstIndex(of: pos_categ_id)
                        if index != nil
                        {
                            allNotes = SubProbuctObject(list_notes:list_notes,currentNote:self.note )
                            
                        }
                    }
                }
            }else{
                allNotes =  SubProbuctObject(list_notes:[],currentNote:self.note )
            }

            self.filterSortSubProducts()
             
        }
        
    }
    func appendToNote(_ itemProductObject:ItemProductObject,isSelected:Bool){
        if isSelected {
            self.selectedNote.append(itemProductObject)
        }else{
            self.unSelectedNote.append(itemProductObject)
        }
    }
    func removeFromNote(_ itemProductObject:ItemProductObject,isSelected:Bool?){
        if itemProductObject.type == .note  {
            if let isSelected = isSelected{
                if isSelected {
                    self.selectedNote.removeAll(where: {$0 == itemProductObject})
                }else{
                    self.unSelectedNote.removeAll(where: {$0 == itemProductObject})
                }
            }else{
                self.selectedNote.removeAll(where: {($0) == itemProductObject})
                self.unSelectedNote.removeAll(where: {($0) == itemProductObject })
            }
        }
    }
    func appendToAddOn(_ itemProductObject:ItemProductObject,isSelected:Bool){
        if isSelected {
            self.selectedAddOns.append(itemProductObject)
        }else{
            self.unSelectedAddOns.append(itemProductObject)
        }
    }
    func removeFromAddOn(_ itemProductObject:ItemProductObject,isSelected:Bool?){
        if itemProductObject.type == .combo  {
            if let isSelected = isSelected{
                if isSelected {
                    self.selectedAddOns.removeAll(where: {$0 == itemProductObject})
                }else{
                    self.unSelectedAddOns.removeAll(where: {$0 == itemProductObject})
                }
            }else{
                self.selectedAddOns.removeAll(where: {($0) == itemProductObject})
                self.unSelectedAddOns.removeAll(where: {($0) == itemProductObject })
            }
        }
    }
    func appendToVariant(_ itemProductObject:ItemProductObject,isSelected:Bool){
        if isSelected {
            self.selectedVariant.append(itemProductObject)
        }else{
            self.unSelectedVariant.append(itemProductObject)
        }
    }
    func removeFromVariant(_ itemProductObject:ItemProductObject,isSelected:Bool?){
        if let isSelected = isSelected{
            if isSelected {
                self.selectedVariant.removeAll(where: {($0.idItem ?? 0) == itemProductObject.idItem})
            }else{
                self.unSelectedVariant.removeAll(where: {($0.idItem ?? 0) == itemProductObject.idItem})
            }
        }else{
            self.selectedVariant.removeAll(where: {($0.idItem ?? 0) == itemProductObject.idItem})
            self.unSelectedVariant.removeAll(where: {($0.idItem ?? 0) == itemProductObject.idItem})
        }
    }
    func convertToPosLine(_ complete:@escaping(_ line:pos_order_line_class?,_ orginQty:Double?)->()){
        let orginQty = line?.qty
        let filterSubProductsIDS = subProducts?.compactMap({$0.sectionID ?? 0}) ?? []
        self.removeItemsDepandVariant(filterSubProductsIDS)
        DispatchQueue.global(qos: .background).async {
            if let line = self.line {
                let currentName = line.product.display_name
                let currentVariantID = line.product_id
                let currentQty = line.qty
                let isCurrentPrint = line.printed == .printed
               
                
                line.pos_multi_session_status = .last_update_from_local
                line.printed = .none
                line.qty  = self.selectQty
                line.note = self.note
                if let productTempId = self.get_variant_protduct_id(){
                    line.product_id = productTempId
                    if currentVariantID != productTempId && isCurrentPrint{
                        let newNote = String(format: "*** Void - %@ - %@","\(currentQty)", currentName )
                        line.note_kds =  newNote
                        line.last_qty = 0
                        line.printed = .none


                        
                    }
                }
                let currentSelectedAddOnLines = self.getSelectedAddOnLines(line.order_id ,line.id,line.product_id ,line.selected_products_in_combo).map({pos_order_line_class(fromDictionary: $0.toDictionary()) })
                
                if currentSelectedAddOnLines.count > 0{
                    line.selected_products_in_combo.forEach { selectaddOn in
                        selectaddOn.is_void = true
                        selectaddOn.save(write_info: true)
                    }
                    line.selected_products_in_combo.removeAll()
                    line.selected_products_in_combo.append(contentsOf:currentSelectedAddOnLines )
                    
                }
                line.writeInfo()
                line.update_values()
                complete(line,orginQty)
            }else{
                complete(self.line,orginQty)
            }
        
        }
    }
    func setPrice(for attributedSelected:[Int]){
        var totalSelectedPrice = self.productDB?.list_price ?? 1.0
        totalSelectedPrice = totalSelectedPrice * (self.selectQty)
        self.selectedAddOns.forEach { selectItem in
            totalSelectedPrice += selectItem.selectQty * selectItem.getExtraPrice(attributedSelected)
        }
        self.selectedVariant.forEach { selectVariant in
            if let price_variant_extra = selectVariant.productAttribute?.price_extra.rounded(value: 2) ,price_variant_extra > 0 {
                totalSelectedPrice +=  price_variant_extra
            }
        }
        self.totalPrice = totalSelectedPrice.rounded_double(toPlaces: 2)

    }
    private func getSelectedAddOnLines(_ order_id:Int,_ parentLineId:Int,_ parentProductId:Int?,_ comingSelectedProduct:[pos_order_line_class])->[pos_order_line_class]{
        var currentSelectedProduct = comingSelectedProduct
        if selectedAddOns.count > 0 {
            selectedAddOns.forEach { selectAddOnItem in
                if let addOnLine = selectAddOnItem.mwConvertToPosLine(order_id, parentLineId,  parentProductId ?? 0, getSelectedVariantIds())
                {
                    if !addOnLine.uid.isEmpty {
                        currentSelectedProduct.removeAll(where: {$0.uid == addOnLine.uid})
                    }
                    addOnLine.printed = .none
                    addOnLine.pos_multi_session_status = .last_update_from_local
                    addOnLine.combo_id = selectAddOnItem.comboRelationID
                    addOnLine.product_combo_id = selectAddOnItem.productComboID
                    currentSelectedProduct.append(addOnLine)
                }
                
            }
        }
        if unSelectedAddOns.count > 0 {
            unSelectedAddOns.forEach { itemProductObject in
                if let addOnLine = itemProductObject.line {
                    if !addOnLine.uid.isEmpty {
                        currentSelectedProduct.removeAll(where: {$0.uid == addOnLine.uid})
                    }
                    addOnLine.is_void = true
                    addOnLine.printed = .none
                    addOnLine.pos_multi_session_status = .last_update_from_local
                    currentSelectedProduct.append(addOnLine)
                }else{
                    if let linesExis = self.line?.selected_products_in_combo.filter({$0.product_id == itemProductObject.idItem}), linesExis.count > 0{
                        linesExis.forEach { lineEx in
                            lineEx.is_void = true
                            lineEx.printed = .none
                            lineEx.pos_multi_session_status = .last_update_from_local
                            lineEx.save(write_info: true)
                        }
                    }
                }
                
            }
        }
        return currentSelectedProduct
    }
    private func get_variant_protduct_id()-> Int?
    {
        let selected_ids = getSelectedVariantIds()
       for  mwVariantObject in (self.variantDetails?.mwVariantObject ?? []){
           if mwVariantObject.attributesIds?.sorted() == selected_ids.sorted() {
                return mwVariantObject.productID
            }
        }
        return nil
    }
    
    func checkHasUpdated()->Bool{
        let addOnCount = self.selectedAddOns.count
        let variantCount = self.selectedVariant.count
        let unSelectedAddOnCount = self.unSelectedAddOns.count
        let unSelectedVariantCount = self.unSelectedVariant.count
        return (addOnCount + variantCount + unSelectedAddOnCount + unSelectedVariantCount) > 0
    }
    func checkChoseRequire() -> Bool{
        var isRequireSelected = true
        if let requiredSubProduct = self.subProducts?.filter({$0.isRequire ?? false}),  requiredSubProduct.count > 0{
            //countItems
           
            requiredSubProduct.compactMap { $0.productItems?.compactMap({$0.idItem}) }.forEach { requireSubProduct in
                isRequireSelected = false
                requireSubProduct.forEach { requireID in
                    if self.selectedAddOns.filter({$0.idItem == requireID}).count > 0{
                        isRequireSelected = true
                    }
                }
            }
            
            if isRequireSelected {
                for subProbuctObject in requiredSubProduct {
                    if subProbuctObject.isRequire ?? false {
                        isRequireSelected = false
                        let countItems = subProbuctObject.countItems
                        let minQtyItems = subProbuctObject.minCountItems
                        let qtySub = subProbuctObject.getQtyProudctsItems()
                        if minQtyItems > 0 {
                            isRequireSelected = (qtySub >= minQtyItems) && (qtySub <= countItems)
                        }else{
                            isRequireSelected = qtySub == countItems
                        }
                        
                    }
                    if !isRequireSelected{
                        break
                    }
                }
            }
            
        }
        
        if !isRequireSelected {
            SharedManager.shared.initalBannerNotification(title: "", message: "You must choose from require quantity items".arabic("يجب أن تختار الكميه المحدده العناصر المطلوبة"), success: false, icon_name: "")
            SharedManager.shared.banner?.dismissesOnTap = true
            SharedManager.shared.banner?.show(duration: 3.0)
        }
        return isRequireSelected

    }
    func getSelectedVariantIds() -> [Int]{
       return selectedVariant.compactMap({$0.idItem})
    }
    func increaseQty(){
        self.selectQty += 1.0
        self.selectQty = self.selectQty.rounded_double(toPlaces: 2)
        self.updateAddOnQty()
    }
    func decreaseQty(){
        self.selectQty -= 1.0
        if  (self.selectQty ) <= 0.0 {
            self.selectQty = 1.0
        }
        self.selectQty = self.selectQty.rounded_double(toPlaces: 2)
        self.updateAddOnQty()
    }
    func updateAddOnQty(){
        self.subProducts?.forEach({ addOnSubProduct in
            if addOnSubProduct.type == .combo {
                addOnSubProduct.changeCountItems(by: self.selectQty)
                let selectedProducts = addOnSubProduct.productItems?.filter({$0.getISelected()}) ?? []
                selectedProducts.forEach({ addOnProduct in
                    var uniteFactory = addOnProduct.mwAddOnList?.first?.auto_select_num ?? 0
                    if uniteFactory <= 0 {
                        uniteFactory = 1
                    }
                    let comingQty = (Double(uniteFactory) * self.selectQty)
                    if (Double(selectedProducts.count) * comingQty) <=  Double(addOnSubProduct.countItems) {
                        addOnProduct.selectQty = comingQty
                        self.selectedAddOns.removeAll(where: {addOnProduct == $0})
                        self.selectedAddOns.append(addOnProduct)

                    }else{
                        //TODO: - in this case addons must increas mannule

                    }
                    
                })


            }
        })
            
    }
}





