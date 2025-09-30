//
//  MWComboVM.swift
//  pos
//
//  Created by M-Wageh on 09/05/2023.
//  Copyright © 2023 khaled. All rights reserved.
//

import Foundation
enum MWComboState{
    case EMPTY,CHANGE_QTY(_ qty:String),LOADING,POPULATED,CLOSE,SHOW_MESSAGE(_ msg:String),UPDATE_PRICE(_ price:String),VOID_DONE
}
class MWComboVM{
    let order:pos_order_class?
    var orderVc: order_listVc?
    
    private var multiProductObject:MultiProductObject?
    var doneCompleteComboHandler:((_ line:pos_order_line_class?,_ orginQty:Double?)->Void)?
    var updateLoadingStatusClosure: ((MWComboState) -> Void)?
    
    var state: MWComboState = .EMPTY {
        didSet {
            self.updateLoadingStatusClosure?(state)
        }
    }
    
    init(_ multiProductObject:MultiProductObject?,orderVc:order_listVc?){
        self.multiProductObject = multiProductObject
        self.orderVc = orderVc
        self.order = orderVc?.order
    }
    func isStateLoading()->Bool{
        switch self.state{
        case .LOADING :
            return true
        default:
            return false
            
        }
    }
    func getSelectedLine()->pos_order_line_class?{
        return multiProductObject?.line
    }
    func fetchSubProduct(){
        self.state = .LOADING
        DispatchQueue.global(qos: .background).async {
            self.multiProductObject?.setSubProducts(orderType: self.order?.orderType)
            self.updatePrice()
            self.state = .POPULATED
        }
    }
    func changeOrderType(){
        self.state = .LOADING
        DispatchQueue.global(qos: .background).async {
            self.multiProductObject?.changeOrderType(orderType: self.order?.orderType)
            self.updatePrice()
            self.state = .POPULATED
        }

    }
    func getNameProduct()->String{
        return self.multiProductObject?.nameMultiProduct ?? ""
    }
    
    func getSelectedQtyForCombo()->Int{
        return Int(self.multiProductObject?.selectQty ?? 1)
    }
    
    func getSubProductsCount() -> Int {
        return self.multiProductObject?.subProducts?.count ?? 0
    }
    func getSubProduct(at index:Int)->SubProbuctObject?{
        return self.multiProductObject?.subProducts?[index]
    }
    func getItemsProductCount(for section:Int)->Int{
        return self.getSubProduct(at: section)?.productItems?.count ?? 0
    }
    func getItemProduct(for section:Int, at index:Int)-> ItemProductObject?{
        return self.getSubProduct(at: section)?.productItems?[index]
    }
    func getSelectedVariantIds()-> [Int]{
        return self.multiProductObject?.getSelectedVariantIds() ?? []
    }
}
//MARK: - BUSSINESS LOGIC Functionality
extension MWComboVM {
    func makeNewMultiProduct(){
        
       if let product = self.multiProductObject?.productDB,
          let orderID = self.multiProductObject?.line?.order_id{
           self.state = .LOADING
           let newLine = pos_order_line_class.create(order_id: orderID, product: product)
           newLine.section = 0
           newLine.index = 0
           newLine.qty = 1
           newLine.last_qty = 0
           newLine.printed = .none
           newLine.pos_multi_session_write_date = ""
           newLine.is_void = false
           newLine.void_status = void_status_enum.none
           newLine.note = ""
           newLine.selected_products_in_combo.removeAll()
           self.multiProductObject = nil
           self.multiProductObject = MultiProductObject(from: newLine )
           self.fetchSubProduct()
           let newQtyString = "\(getSelectedQty().rounded_double(toPlaces: 3))"
           self.updatePrice()
           self.state = .CHANGE_QTY(newQtyString)

       }}
    //MARK: - [VOID] BUSSINESS LOGIC Functionality
    func voidAction(){
        self.state = .LOADING
        DispatchQueue.global(qos: .background).async {
            if let line = self.multiProductObject?.line {
                line.printed = .none
                line.is_void  = true
                line.selected_products_in_combo.forEach { addOnLine in
                    addOnLine.printed = .none
                    addOnLine.is_void  = true
                }
                self.doneCompleteComboHandler?(line,line.qty)
            }
            self.state = .VOID_DONE
        }
    }
    func void(vc:UIViewController){
        if let line = self.multiProductObject?.line{
            SharedManager.shared.premission_for_void_line(line: line, vc: vc) { [weak self] in
                DispatchQueue.main.async {
                    guard let self = self else {return}
                    self.voidAction()
                }
            }
        }else{
            voidAction()
        }
    }
    //MARK: - [DONE] BUSSINESS LOGIC Functionality
    func done(){
        if case .LOADING = self.state {
            return
        }
        if !(multiProductObject?.checkChoseRequire() ?? false){
            self.state = .SHOW_MESSAGE("You must choose from require items".arabic("يجب أن تختار من العناصر المطلوبة"))
            return
        }
        if !(multiProductObject?.checkHasUpdated() ?? false){
          //  self.state = .SHOW_MESSAGE("You must chose from require items".arabic("يجب أن تختار من العناصر المطلوبة"))
           // return
        }
        self.state = .LOADING
        self.multiProductObject?.convertToPosLine({ line,orginQty in
            self.doneCompleteComboHandler?(line,orginQty)
            self.state = .CLOSE
        })

    }
    func setNote(_ note:String){
        self.multiProductObject?.note = note
        
    }
    func getNote()->String?{
       return self.multiProductObject?.note
        
    }
    //MARK: - [AddON] BUSSINESS LOGIC Functionality
    // - [ADD][AddON] BUSSINESS LOGIC Functionality
    func addAddOnSelect(_ itemProductObject:ItemProductObject){
        DispatchQueue.global(qos: .background).async {
            self.resetSelectedItems(itemProductObject)
            if itemProductObject.type == .note {
                self.multiProductObject?.appendToNote(itemProductObject, isSelected: true)
            }else{
                self.multiProductObject?.appendToAddOn(itemProductObject, isSelected: true)
                self.updatePrice()
            }
        }
    }
    // - [REMOVE][AddON] BUSSINESS LOGIC Functionality
    func removeAddOnSelect(_ itemProductObject:ItemProductObject){
        DispatchQueue.global(qos: .background).async {
            self.resetSelectedItems(itemProductObject)
            if itemProductObject.type == .note {
                self.multiProductObject?.appendToAddOn(itemProductObject, isSelected: true)
            }else{
                self.multiProductObject?.appendToAddOn(itemProductObject, isSelected: false)
            }
        }
    }
    //MARK: - [Variant] BUSSINESS LOGIC Functionality
    func setSelect(for section:Int, at index:Int){
        self.resetNotMultiSelectedSection(for: section)
         self.getItemProduct(for :section, at :index)?.isSelect = !(self.getItemProduct(for :section, at :index)?.isSelect ?? false)
        if let itemProduct =  self.getItemProduct(for :section, at :index){
            self.resetSelectedItems(itemProduct)
            self.appendVariantSelected(itemProduct)
        }
    }
    //MARK: - [Quantity] BUSSINESS LOGIC Functionality
    func changeQty(operation:String){
        if operation == "+"{
            self.multiProductObject?.increaseQty()
        }
        if operation == "-"{
            self.multiProductObject?.decreaseQty()
        }
        let newQtyString = "\(getSelectedQty().rounded_double(toPlaces: 3))"
        self.updatePrice()
        self.state = .CHANGE_QTY(newQtyString)
    }
 
    func getSelectedQty()->Double{
        return self.multiProductObject?.selectQty ?? 1.0
    }
    func updateQtyManule(with newQty:Double){
        let newQtyString = "\(newQty.rounded_double(toPlaces: 3))"
        self.multiProductObject?.selectQty = newQty.rounded_double(toPlaces:3)
        self.multiProductObject?.updateAddOnQty()
        self.updatePrice()
        self.state = .CHANGE_QTY(newQtyString)

    }
    func canIncreaseQty(for section:Int)-> Bool?{
        return self.getSubProduct(at: section)?.canIncreaseQty()
    }
    func canSwitch(for section:Int)-> Bool{
        return self.getSubProduct(at: section)?.isRadioChosse() ?? false
    }
    func getQty(for section:Int)-> Double{
        return self.getSubProduct(at: section)?.getQtyProudctsItems() ?? 1.0
    }
    func showValidQtyMessage(for section:Int){
        self.getSubProduct(at: section)?.validtaMessageForIncreaseQty()
    }
}
//MARK: - HELPER Private Functionality
extension MWComboVM {
    private func resetNotMultiSelectedSection(for section:Int){
        if let subProduct = self.getSubProduct(at :section){
            let isSupportMultiSelect = subProduct.multiSelected ?? false
            if !isSupportMultiSelect{
                subProduct.productItems?.forEach({ itemProduct in
                    self.resetSelectedItems(itemProduct)
                    if  itemProduct.isSelect ?? false {
                        self.multiProductObject?.appendToVariant(itemProduct, isSelected: false)
                    }
                    itemProduct.isSelect = false
                })
//                for (index, _) in (subProduct.productItems ?? []).enumerated(){
//
//                    self.getItemProduct(for :section, at :index)?.isSelect = false
//                }
            }
        }
    }
    private func resetSelectedItems(_ itemProduct: ItemProductObject){
        if itemProduct.type == .combo {
            self.multiProductObject?.removeFromAddOn(itemProduct, isSelected: nil)
        }else{
            if itemProduct.type == .note {
                self.multiProductObject?.removeFromNote(itemProduct, isSelected: nil)
            }else{
                self.multiProductObject?.removeFromVariant(itemProduct, isSelected: nil)
            }
        }

    }
    private func appendVariantSelected(_ itemProduct: ItemProductObject){
        self.multiProductObject?.appendToVariant(itemProduct, isSelected: itemProduct.isSelect ?? false)
        //TODO: -refetch multiproducts
        self.multiProductObject?.filterSortSubProducts()
        self.updatePrice()
        self.state = .POPULATED
    }
   
    func resetAddOnSecion(at section:Int,excludeProduct: ItemProductObject) -> Bool{
        guard let subProduct = self.getSubProduct(at :section) else {return false}
        let isRadioSelect = subProduct.isRadioChosse()
        if isRadioSelect{
            subProduct.productItems?.forEach{ itemProduct in
                if itemProduct.idItem != excludeProduct.idItem &&  (itemProduct.getISelected()) {
                    self.resetSelectedItems(itemProduct) // remove from selected and unselected
                    itemProduct.isSelect = false
                    itemProduct.selectQty = 0
                    self.multiProductObject?.appendToAddOn(itemProduct, isSelected: false)
                   
                }
            }
        }
        return isRadioSelect
    }
    
    func updatePrice(){
        self.multiProductObject?.setPrice(for: self.getSelectedVariantIds())
        self.state = .UPDATE_PRICE("\(self.multiProductObject?.totalPrice ?? 1.0)")
    }
}

