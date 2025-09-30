//
//  SubProbuctObject.swift
//  pos
//
//  Created by M-Wageh on 30/05/2023.
//  Copyright © 2023 khaled. All rights reserved.
//

import Foundation
class SubProbuctObject{
    var sectionID:Int?
    var sortNumber:Int?
    var nameSubProduct:String?
    var multiSelected:Bool?
    var type:section_type?
    var productItems:[ItemProductObject]?
    var countItems:Double = 1
    var isRequire:Bool?
    var attributeValueIdList:[Int]?
    var defaultCountItems:Double = 1
    var minCountItems:Double = -1
    var defaultName:String = ""

    var no_of_items: Int = 1
    
    //MARK: - intalize from variant
    convenience init(from varints_list:[product_attribute_value_class],multiSelected:Bool,type:section_type,selectedId: [Int]){
        self.init()
        self.type = type
        self.multiSelected = multiSelected
        self.sortNumber = varints_list.first?.attribute_id_id
        self.nameSubProduct = varints_list.first?.attribute_id_name
        self.productItems = varints_list.map({ItemProductObject(from: $0,type: type,selectedId: selectedId)})
    }
    //MARK: - intalize from AddOn
    convenience init(from productItems:[ItemProductObject],multiSelected:Bool,attributeValueId:[Int]?,isRequire:Bool?,sequence:Int,min_no_of_items:Int, no_of_items:Int,selectedQtyForCombo: Int,sectionID:Int,name:String){
        self.init()
        self.type = .combo
        self.multiSelected = multiSelected
        self.sortNumber = sequence
        self.defaultName = name
        self.minCountItems = Double(min_no_of_items).rounded_double(toPlaces: 2)
        self.productItems = productItems
        self.countItems = Double(no_of_items * selectedQtyForCombo).rounded_double(toPlaces: 2)
        self.defaultCountItems = Double(no_of_items * selectedQtyForCombo).rounded_double(toPlaces: 2)
        self.attributeValueIdList = attributeValueId
        self.isRequire = isRequire
        self.sectionID = sectionID
        if !name.isEmpty {
            self.nameSubProduct =  String(format: "%@ - \(name) %@".arabic("%@ - \(name) %@"), "" , "\(defaultCountItems)")
        }else{
            self.nameSubProduct =  String(format: "%@ - Choose Any %@".arabic("%@ - اختيار أي %@"), "" , "\(defaultCountItems)")
        }
        self.no_of_items = no_of_items
    }
    //
    convenience init(list_notes:[pos_product_notes_class],currentNote:String?) {
        self.init()
        self.type = .note
        self.multiSelected = true
        self.sortNumber = 3000
        self.nameSubProduct =  String(format: "%@ - Add Any %@".arabic("%@ - اضافه أي %@"), "" , "Note".arabic("ملاحظه"))
        self.productItems = list_notes.compactMap({ItemProductObject(from: $0,currentNote:currentNote)})
    }
    func sort() -> SubProbuctObject {
        productItems = productItems?.sorted(by: {($0.sortNumber ?? 0) < ($1.sortNumber ?? 0) })
        return self
    }
    func isRadioChosse()->Bool{
        if self.defaultCountItems <= 1{
            return true
        }
        return multiSelected ?? false
    }
    func checkAvaliablity(for attributesIDS:[Int]) ->Bool{
        guard let attributeValueIdList = attributeValueIdList else{return false}
        if attributeValueIdList.contains(0) {
            return true
        }
//        return attributesIDS.count == attributeValueIdList.count && attributesIDS.sorted() == attributeValueIdList.sorted()

        var isAvaliable = false
        for attributesID in attributesIDS {
            if (attributeValueIdList.contains(attributesID) ){
                isAvaliable = true
                break
            }
        }
        return isAvaliable
        
    }
    func getQtyProudctsItems()-> Double {
       return ( self.productItems?.compactMap({$0.selectQty}).reduce(0, +) ?? 0)
    }
    
    func canIncreaseQty()-> Bool?{
        if  countItems > 0 && type == .combo{
            if countItems == 1 {
                return true
            }
            let canIncrease = getQtyProudctsItems() < countItems
            if !canIncrease {
//                SharedManager.shared.initalBannerNotification(title: "", message: "Total item should be less \(countItems)".arabic("يجب أن يكون إجمالي العنصر أقل من \(countItems)"), success: false, icon_name: "")
//                SharedManager.shared.banner?.dismissesOnTap = true
//                SharedManager.shared.banner?.show(duration: 3.0)
            }
            return canIncrease
        }
        return true
    }
    func changeCountItems(by value:Double){
        self.countItems = (Double(self.no_of_items) * value).rounded_double(toPlaces: 2)
        if !defaultName.isEmpty {
            self.nameSubProduct =  String(format: "%@ - \(defaultName) %@".arabic("%@ - \(defaultName) %@"), "" , "\(countItems)")
        }else{
            self.nameSubProduct =  String(format: "%@ - Choose Any %@".arabic("%@ - اختيار أي %@"), "" , "\(countItems)")
        }

    }
    
    func validtaMessageForIncreaseQty(){
        SharedManager.shared.initalBannerNotification(title: "", message: "Total item should be less \(countItems)".arabic("يجب أن يكون إجمالي العنصر أقل من \(countItems)"), success: false, icon_name: "icon_error")
        SharedManager.shared.banner?.dismissesOnTap = true
        SharedManager.shared.banner?.show(duration: 3.0)
    }
    func changeOrderType(with orderType:delivery_type_class?){
        self.productItems?.forEach({ itemProduct in
            itemProduct.changeOrderType(with: orderType)
        })
    }
    
}
