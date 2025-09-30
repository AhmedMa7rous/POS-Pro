//
//  AddOperationVM.swift
//  pos
//
//  Created by  Mahmoud Wageh on 5/31/21.
//  Copyright © 2021 khaled. All rights reserved.
//

import Foundation
class AddOperationVM {
    enum SelectTypeEnum:Int{
        case PICKUP = 0 ,FROM,TO,PARTNER,SCHEDULED_DATE,MOVE_LINE
        func getModelName() -> String{
            if self == .FROM || self == .TO {
                return "stock.location"
            }
            if self == .PICKUP  {
                return "stock.picking.type"
            }
            if self == .PARTNER  {
                return "pos.customer"
            }
            return ""
        }
        func getFieldsName() -> [String]{
            if self == .FROM || self == .TO {
                return [ "id","display_name"]
            }
            if self == .PICKUP  {
                return ["id","display_name"]
            }
            if self == .PARTNER  {
                return ["display_name","id","image_128"]
            }
            return []
        }
        func getTitle() -> String{
            if self == .FROM {
                return "Select Location From".arabic("اختر الموقع من")
            }
            if self == .TO {
                return "Select Location To".arabic("اختر الموقع الي")
            }
            if self == .PICKUP  {
                return "Select Pickup Type".arabic("اختر  نوع العملية")
            }
            if self == .PARTNER  {
                return "Select Partner ".arabic("اختر  جهة الاتصال")
            }
            return ""
        }
    }
    enum AddOperationState {
        case empty
        case loading
        case populated
        case error
        case updateItems
        case pickerDataFetch
    }
    var state: AddOperationState = .empty {
        didSet {
            self.updateLoadingStatusClosure?(state, message, isSucess)
        }
    }
    var updateLoadingStatusClosure: ((AddOperationState, String?, Bool) -> Void)?
    private var message: String?
    private var isSucess: Bool = false
    var API:api?
    //MARK:- Offest Variables for Picker Select Types
    private var pickingTypeOffest:Int?
    private var locationOffest:Int?
    private var partnerOffest:Int?
    //MARK:- Result Variables for Picker Select Types
    var selectedItems:[StorableItemModel] = []
    var locationsResult:[LocationModel] = []
    var pickingTypeResult:[PickingTypeModel] = []
    var partnerResult:[PartnerModel] = []
    var selectTypeEnum:SelectTypeEnum?
    //MARK:- Is Fetch All data for Picker Select Types
    private var isFetchAllPickingType: Bool = false
    private var isFetchAllPartner: Bool  = false
    private var isFetchAllLocation: Bool  = false
    //MARK:-
    var selectFromIndex:Int?
    var selectToIndex:Int?
    var selectPickingTypeIndex:Int?
    var selectPartnerIndex:Int?
    var sechadualDate:String?
    let addOperationModel = AddOperationModel()

    
    func isEnded()->Bool{
        if self.selectTypeEnum == .FROM || self.selectTypeEnum == .TO {
            return isFetchAllLocation

        }
        if self.selectTypeEnum == .PICKUP {
            return isFetchAllPickingType

        }
        if self.selectTypeEnum == .PARTNER {
            return isFetchAllPartner
        }
        return true
    }
    
    
    private func getPickerData(){
        if self.selectTypeEnum == .FROM || self.selectTypeEnum == .TO {
            if let selectToIndex = selectToIndex {
                self.locationsResult[selectToIndex].isSelected = false
            }
            if let selectIndex = selectFromIndex {
                self.locationsResult[selectIndex].isSelected = false
            }
            if self.selectTypeEnum == .FROM  {
                if let selectIndex = selectFromIndex {
                    self.locationsResult[selectIndex].isSelected = true
                }
            }
            if self.selectTypeEnum == .TO  {
            if let selectToIndex = selectToIndex {
                self.locationsResult[selectToIndex].isSelected = false
            }
            }
            if isFetchAllLocation {
               
                self.state = .pickerDataFetch
                return
            }
        }
        if self.selectTypeEnum == .PICKUP {
            if isFetchAllPickingType {
                self.state = .pickerDataFetch
                return
            }
        }
        if self.selectTypeEnum == .PARTNER {
            if isFetchAllPartner {
                self.state = .pickerDataFetch
                return
            }
        }
        hitGetSelectPickerAPI()
        
    }
    
   private func parseResult(data: Data){
        if self.selectTypeEnum == .FROM || self.selectTypeEnum == .TO {
            parseLocation(data: data)
        }
        if self.selectTypeEnum == .PICKUP {
            parsePickingType(data: data)
        }
        if self.selectTypeEnum == .PARTNER {
            parsePartner(data: data)
        }
    }
    private func parsePartner(data: Data){
        do {
        let obj: Odoo_Base<[PartnerModel]> = try JSONDecoder().decode(Odoo_Base<[PartnerModel]>.self, from: data )
        if let result:[PartnerModel] = obj.result {
            self.state = .pickerDataFetch
            self.isFetchAllPartner = result.count < 40
            self.partnerResult.append(contentsOf: result)
        }
        } catch {
            SharedManager.shared.printLog(error)
            self.isSucess = false
            self.message =  "pleas, try again later".arabic("من فضلك حاول في وقت لاحق")
            self.state = .error
        }
    }
    private func parsePickingType(data: Data){
        do {
        let obj: Odoo_Base<[PickingTypeModel]> = try JSONDecoder().decode(Odoo_Base<[PickingTypeModel]>.self, from: data )
        if let result:[PickingTypeModel] = obj.result {
            self.state = .pickerDataFetch
            self.isFetchAllPickingType = result.count < 40
            self.pickingTypeResult.append(contentsOf: result)
        }
        } catch {
             SharedManager.shared.printLog(error)
            self.isSucess = false
            self.message =  "pleas, try again later".arabic("من فضلك حاول في وقت لاحق")
            self.state = .error
        }
    }
    private func parseLocation(data: Data){
        do {
        let obj: Odoo_Base<[LocationModel]> = try JSONDecoder().decode(Odoo_Base<[LocationModel]>.self, from: data )
        if let result:[LocationModel] = obj.result {
            self.state = .pickerDataFetch
            self.isFetchAllLocation = result.count < 40
            self.locationsResult.append(contentsOf: result)
        }
        } catch {
             SharedManager.shared.printLog(error)
            self.isSucess = false
            self.message =  "pleas, try again later".arabic("من فضلك حاول في وقت لاحق")
            self.state = .error
        }
    }
    
    
}
extension AddOperationVM {
    //MARK:- call h Locations
     func hitCreateOperationAPI(){
        guard let API = self.API else {
            return
        }
        self.state = .loading
        API.hitCreateOperationAPI(param:self.addOperationModel.toDictionary()! ) { (results) in
            if results.success
            {
                let response = results.response
                if let dic:[String:Any]  = response , dic.count > 0 {
                    do {
                        self.isSucess = true
                        self.message =  ""
                        self.state = .populated
                    } catch {
                         SharedManager.shared.printLog(error)
                        self.isSucess = false
                        self.message =  "pleas, try again later".arabic("من فضلك حاول في وقت لاحق")
                        self.state = .error
                    }
                }else{
                    self.isSucess = false
                    self.message =  "No Data Found".arabic("لم يتم العثور علي بيانات")
                    self.state = .error
                }
                return
            }else{
                self.isSucess = false
                self.message = results.message ?? ""
                self.state = .error
                
            }
        };
    }
    //MARK:- call Get Locations
     func hitGetSelectPickerAPI(){
        guard let API = self.API else {
            return
        }
       
        self.state = .loading
        let model =  self.selectTypeEnum?.getModelName() ?? ""
        let fields =  self.selectTypeEnum?.getFieldsName() ?? []

        API.hitGetSelectPickerAPI(for:model, fields:fields, with:getNextOffest()) { (results) in
            if results.success
            {
                let response = results.response
                if let dic:[String:Any]  = response , dic.count > 0 {
                    do {
                        let data = try JSONSerialization.data(withJSONObject: dic)
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        self.parseResult(data: data)
                       
                    } catch {
                         SharedManager.shared.printLog(error)
                        self.isSucess = false
                        self.message =  "pleas, try again later".arabic("من فضلك حاول في وقت لاحق")
                        self.state = .error
                    }
                }else{
                    self.isSucess = false
                    self.message =  "No Data Found".arabic("لم يتم العثور علي بيانات")
                    self.state = .error
                }
                return
            }else{
                self.isSucess = false
                self.message = results.message ?? ""
                self.state = .error
                
            }
        };
    }
}
extension AddOperationVM{
    func setSelectType(_ type:SelectTypeEnum) {
        self.selectTypeEnum = type
        getPickerData()
        
    }
    func createOperation(){
        guard let _ = self.selectPickingTypeIndex
         else {
            self.message = "You must choose Picking type".arabic("يجب عليك اختيار نوع العملية")
            self.state = .error
            return
        }
        guard let _ = self.selectFromIndex
         else {
            self.message = "You must choose location From".arabic("يجب عليك اختيار الموقع من ")
            self.state = .error
            return
        }
        guard let _ = self.selectToIndex
         else {
            self.message = "You must choose location To".arabic("يجب عليك اختيار الموقع الي ")
            self.state = .error
            return
        }
        guard let _ = self.selectPartnerIndex
         else {
            self.message = "You must choose partner ".arabic("يجب عليك اختيار جهة الاتصال ")
            self.state = .error
            return
        }
        guard let sechadualDate = self.sechadualDate
         else {
            self.message = "You must choose sechadual Date ".arabic("يجب عليك اختيار تاريخ محددة  ")
            self.state = .error
            return
        }
        if  selectedItems.count > 0 {
            addOperationModel.move_lines.removeAll()
            selectedItems.forEach { (item) in
                let param = [
                    "product_id": item.id ?? 0,
                    "product_uom_qty": item.qty,
                    "name": item.name ?? "",
                    "product_uom": Int(item.select_uom_id.first ?? "0") ?? 0
                ] as [String : Any]
                addOperationModel.move_lines.append([0,0,param])


            }
        }else{
            self.message = "You must choose operation move lines ".arabic("يجب عليك تحديد اصناف العملية  ")
            self.state = .error
            return
        }
        addOperationModel.scheduled_date = sechadualDate
        hitCreateOperationAPI()

    }
}
extension AddOperationVM {
    func didUpdatedSelectedItems( _ items:[StorableItemModel]){
        self.state = .loading
        selectedItems.removeAll()
        selectedItems.append(contentsOf: items.reversed())
        self.state = .updateItems
    }
    
    func getMoveLinesCount()->Int{
        return selectedItems.count
    }
    func getQty(for index:Int)-> Double?{
        if selectedItems.count > 0 {
        return selectedItems[index].qty
        }
        return nil
    }
    func setQty(for index:Int, with value:Double){
         selectedItems[index].qty = value
    }
    func getMoveLineItem(for index:Int)->StorableItemModel{
        return selectedItems[index]
    }
    func getSelectPickerCount()->Int{
        if self.selectTypeEnum == .PICKUP{
            return self.pickingTypeResult.count
        }
        if self.selectTypeEnum == .FROM ||  self.selectTypeEnum == .TO {
            return self.locationsResult.count
        }
        if self.selectTypeEnum == .PARTNER{
            return partnerResult.count
        }
        return 0
    }
    func getSelectPickerItem(for index:Int)->Codable?{
        if self.selectTypeEnum == .PICKUP{
            if pickingTypeResult.count > 0{
                return pickingTypeResult[index]
            }
        }
        if self.selectTypeEnum == .FROM ||  self.selectTypeEnum == .TO {
            if locationsResult.count > 0{
                return locationsResult[index]
            }
        }
        if self.selectTypeEnum == .PARTNER{
            if partnerResult.count > 0{
                return partnerResult[index]
            }
            
        }
        return nil
    }
    //MARK:- Get Next Offest for Select Picker Types
     func getNextOffest() -> Int {
        if self.selectTypeEnum == .PICKUP{
        if let _ = pickingTypeOffest {
            pickingTypeOffest! += 40
        }else{
            pickingTypeOffest = 0
        }
        return pickingTypeOffest!
        }
        if self.selectTypeEnum == .FROM ||  self.selectTypeEnum == .TO {
        if let _ = locationOffest {
            locationOffest!  += 40
        }else{
            locationOffest = 0
        }
        return locationOffest!
        }
        if self.selectTypeEnum == .PARTNER{
        if let _ = partnerOffest {
             partnerOffest! += 40
        }else{
            partnerOffest = 0
        }
        return partnerOffest!
        }
        return 0

    }
    func resetPickerSelect(){
        if self.selectTypeEnum == .PICKUP{
             self.pickingTypeResult.removeAll()
            self.state = .pickerDataFetch
        }
        if self.selectTypeEnum == .FROM ||  self.selectTypeEnum == .TO {
             self.locationsResult.removeAll()
            self.state = .pickerDataFetch
        }
        if self.selectTypeEnum == .PARTNER{
             partnerResult.removeAll()
            self.state = .pickerDataFetch
        }

    }
    func selectPickerItem(for index:Int){
        if self.selectTypeEnum == .PICKUP{
            if let currentSelect = self.selectPickingTypeIndex{
                pickingTypeResult[currentSelect].isSelected = false
            }
            self.selectPickingTypeIndex = index
            pickingTypeResult[index].isSelected = true
            
            addOperationModel.picking_type_id = self.pickingTypeResult[index].id ?? 0
        }
        if self.selectTypeEnum == .FROM ||  self.selectTypeEnum == .TO {
            if let currentFromSelect = self.selectFromIndex {
                locationsResult[currentFromSelect].isSelected = false
            }
            if let currentToSelect = self.selectToIndex {
                locationsResult[currentToSelect].isSelected = false
            }
            if self.selectTypeEnum == .FROM {
                self.selectFromIndex = index
                addOperationModel.location_id = self.locationsResult[index].id ?? 0

            }
            if self.selectTypeEnum == .TO {
                self.selectToIndex = index
                addOperationModel.location_dest_id = self.locationsResult[index].id ?? 0
            }
            locationsResult[index].isSelected = true
        }
        if self.selectTypeEnum == .PARTNER{
            if let currentSelect = self.selectPartnerIndex{
                partnerResult[currentSelect].isSelected = false
            }
            self.selectPartnerIndex = index
            partnerResult[index].isSelected = true
            addOperationModel.partner_id = self.partnerResult[index].id ?? 0

        }
        self.state = .pickerDataFetch
    }
    func getTitleSelectPickerItem(for index:Int)->String{
        if self.selectTypeEnum == .PICKUP{
            return pickingTypeResult[index].display_name ?? ""
        }
        if self.selectTypeEnum == .FROM ||  self.selectTypeEnum == .TO {
            return locationsResult[index].display_name ?? ""
        }
        if self.selectTypeEnum == .PARTNER{
            return partnerResult[index].display_name ?? ""
            
        }
        return ""
    }
    
}
