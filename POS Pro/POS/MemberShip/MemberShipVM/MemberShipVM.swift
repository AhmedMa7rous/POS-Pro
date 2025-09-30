//
//  MemberShipVM.swift
//  pos
//
//  Created by M-Wageh on 26/02/2023.
//  Copyright © 2023 khaled. All rights reserved.
//

import Foundation
class MemberShipVM {
    enum MemberShipState{
        case empty,loading,error(_ message:String),searchSuccess,detailsSuccess(_ orderDetails:pos_order_class),restView,changeDate
    }
    var state: MemberShipState = .empty {
        didSet {
            self.updateLoadingStatusClosure?(state)
        }
    }
    var updateLoadingStatusClosure: ((MemberShipState) -> Void)?
    var API:api?
    private var searchMemberShipParam:SearchMemberShipParam?
    private var searchResult:[MemberShipSearchModel] = []
    private var selectSearchItem:MemberShipSearchModel?
    private var posMS:pos_multi_session_sync_class?
     var selectOrder:pos_order_class?

    init() {
        API = SharedManager.shared.conAPI()
        searchMemberShipParam = SearchMemberShipParam()
        posMS = pos_multi_session_sync_class()
    }
    func completePayment(){
        self.selectOrder?.is_closed = true
        self.selectOrder?.is_sync = false
        self.selectOrder?.membership_sale_order_id = selectSearchItem?.id
        self.selectOrder?.save_and_send_to_kitchen(forceSend:true,with:.PAYIED_ORDER, for: [.KDS,.NOTIFIER])
        self.removeSelectItem()
    }
    func didSelectDay(selectDate:Date){
        let selectDate = selectDate.toString(dateFormat:baseClass.date_fromate_satnder_date)
        let currentDate =  searchMemberShipParam?.date ?? ""
        if selectDate != currentDate {
        searchMemberShipParam?.date = selectDate
        self.removeSearchList()
        state = .changeDate
        }

    }
    func clearDay(){
        searchMemberShipParam?.date = Date().toString(dateFormat: baseClass.date_fromate_satnder_date, UTC: false)
        state = .changeDate
    }
    func getDateSearch()->String{
        return searchMemberShipParam?.date ?? "Select date".arabic("اختر التاريخ")
    }
    func didSelectItem(at index:Int){
        if (searchResult.count > index) {
            self.removeSelectItem()
            self.selectSearchItem = getItem(at: index)
            self.hitGetDetailsSearchMemberShip()
        }
    }
    func searchWith(_ word:String){
        self.searchMemberShipParam?.search = word
        self.removeSelectItem()
        self.hitSearchMemberShip()
    }
    func getItem(at index:Int) -> MemberShipSearchModel?{
        if (searchResult.count > index) {
            return searchResult[index]
        }
        return nil
    }
    func getCountItems() -> Int?{
        return searchResult.count
       
    }
   
    func hitSearchMemberShip(){
        guard let searchMemberShipParam = searchMemberShipParam else {
            self.errorHappen()
            return
        }
        let validationParams = searchMemberShipParam.validation()
        if !validationParams.isValid {
            self.errorHappen(validationParams.message)
            return
        }
        self.state = .loading
        API?.hitGetMemberShipOrdersAPI(with:searchMemberShipParam ) { (results) in
            if results.success
            {
                let response = results.response
                if let dic:[String:Any]  = response , dic.count > 0 {
                    self.completeSearchResult(with: dic)
                }else{
                    self.errorHappen( "No Data Found".arabic("لم يتم العثور علي بيانات"))
                }
            }else{
                self.errorHappen( results.message ?? "")
            }
        }
        
    }
    private func hitGetDetailsSearchMemberShip(){
        guard let selectSearchItem = selectSearchItem else {
            return
        }
        self.state = .loading

        let ordersListOpetions = ordersListOpetions()
        ordersListOpetions.parent_product = true
        ordersListOpetions.get_lines_void = true
        if let memberShip_id = selectSearchItem.id,
           let order = pos_order_class.get(memberShip_id: memberShip_id,options_order:ordersListOpetions)
        {
            self.selectOrder = order
            self.state = .detailsSuccess(order)
            return

        }
        API?.hitGetMemberShipOrderDetailsAPI(for:selectSearchItem.id) { (results) in
            if results.success
            {
                let response = results.response
                let result = response?["result"] as? [String:Any]
                let messages = result?["message"] as? [String:Any]
                if let dic = messages?["data"] as? [String:Any]  , dic.count > 0 {
                    self.completeGetDetails(with :dic)
                }else{
                    self.errorHappen( "No Data Found".arabic("لم يتم العثور علي بيانات"))
                }
            }else{
                self.errorHappen( results.message ?? "")
            }
        }
        
    }
    
    private func completeGetDetails(with dic:[String:Any]){
        let lines = dic["lines"] as? [Any] ?? []
        if let orderDetails = posMS?.create_new_order(data: dic, needSave: false) {
            let products = posMS?.read_products(lines: lines,order_id:0,is_new_order: true)
            orderDetails.pos_order_lines = products?.arr ?? []
            self.selectOrder = orderDetails
            self.state = .detailsSuccess(orderDetails)
        }
    }
    
    private func reFillSearhResult(with data:[MemberShipSearchModel]){
        removeSearchList()
        self.searchResult.append(contentsOf:data )
        state = .searchSuccess
    }
    private func removeSearchList(){
        removeSelectItem()
        self.searchResult.removeAll()
        self.state = .restView
        state = .searchSuccess
    }
    private func removeSelectItem(){
        self.selectSearchItem = nil
        self.selectOrder = nil
        self.state = .restView
    }
    
    fileprivate func completeSearchResult(with dic:[String:Any]){
        do {
            let data = try JSONSerialization.data(withJSONObject: dic)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let obj: Odoo_Base<[MemberShipSearchModel]> = try JSONDecoder().decode(Odoo_Base<[MemberShipSearchModel]>.self, from: data )
            if let result = obj.result {
                self.reFillSearhResult(with: result)
            }else{
                self.errorHappen("No Data Found".arabic("لم يتم العثور علي بيانات"))
            }
        } catch {
            self.errorHappen("pleas, try again later".arabic("من فضلك حاول في وقت لاحق"))
        }
    }
    
    fileprivate func errorHappen(_ message:String = "Error happen duriing get search word"){
         state = .error(message)
     }
}
