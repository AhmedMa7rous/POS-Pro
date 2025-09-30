//
//  InStockDetailsVM.swift
//  pos
//
//  Created by  Mahmoud Wageh on 5/17/21.
//  Copyright © 2021 khaled. All rights reserved.
//

import Foundation
protocol InStockDetailsVMProtocol {
    func updateOralidateItems()
}
class InStockDetailsVM:InStockRootVMProtocol,LinesListDelegate{
    func updateItems(_ items: [StorableItemModel]) {
        selectedItems.removeAll()
        selectedItems.append(contentsOf: items.reversed())
    }
    func saveAddItems() {
        if selectedItems.count > 0 {
            hitAddOperationLine()
        }
    }
    
    enum StateInStockDetails {
        case empty
        case loading
        case populated
        case error
        case report
        case addOperationLineSucess
        case setTitle
    }
    var state: StateInStockDetails = .empty {
        didSet {
            self.updateLoadingStatusClosure?(state, message, isSucess)
        }
    }
    var updateLoadingStatusClosure: ((StateInStockDetails, String?, Bool) -> Void)?
    var delegate:InStockDetailsVMProtocol?
    private var message: String?
    private var isSucess: Bool = false
    var API:api?
    private var linesResult:[OperationLineModel] = []
    private var lines:[Int] = []
    var inStockMove:Int?
    private var inStockReport:InStockReport?
    var selectedItems:[StorableItemModel] = []
    var inStockStateTypes:InStockRootVM.InStockStateTypes?
    
    func hitCancelMovement(){
        guard let inStockMove = self.inStockMove,let API = self.API  else {
            return
        }
        let moveLinesDic = getMoveLines()

        self.state = .loading
        API.hitCancelMovementInstockAPI(for:inStockMove) { (results) in
            if results.success
            {
                let response = results.response
                if let dic:[String:Any]  = response , dic.count > 0 {
                    if let result = dic["result"] as? Bool {
                        if result {
                            self.isSucess = true
                            self.message =  "Operation has been cancel successfully".arabic("تم إلغاء العمليه بنجاح")
//                            self.state = .error
                            self.delegate?.updateOralidateItems()
                            self.printReport()

                        }else{
                            self.isSucess = false
                            self.message =  "pleas, try again later".arabic("من فضلك حاول في وقت لاحق")
                            self.state = .error
                        }
                    }else{
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
    func didSelect(_ item:InStockMoveModel)
    {
        if self.state == .loading && ((item.id ?? 0) == inStockMove) {
            return
        }
        resetResult()
        inStockReport = InStockReport(inStockMoveModel: item)
        self.lines = item.move_lines ?? []
        inStockMove = item.id ?? 0
        self.message =  item.name
        self.state = .setTitle
        self.inStockStateTypes = InStockRootVM.InStockStateTypes(rawValue: item.state ?? "draft")
        self.hitGetInOperations()
        
    }
    func didSelectInStockState(_ to:InStockRootVM.InStockStateTypes){
        self.inStockStateTypes = to

        self.message = to.rawValue
        self.state = .setTitle

        resetResult()
    }
    private func getMoveLines() ->[[Any]]{
        if selectedItems.count > 0 {
            guard let inStockMoveModel = self.inStockReport?.inStockMoveModel else {
                return []
            }
            var move_lines: [[Any]] = []
            selectedItems.forEach { (item) in
                let param:[String : Any] = [
                    "product_id": item.id ?? 0,
                    "product_uom_qty": item.qty,
                    "name": item.name ?? "",
                    "product_uom": Int(item.uom_id.first ?? "0") ?? 0,
                    "location_id": Int(inStockMoveModel.location_id.first ?? "0") ?? 0,
                    "location_dest_id": Int(inStockMoveModel.location_dest_id.first ?? "0") ?? 0
                ]
                move_lines.append([0,0,param])
            }
            return move_lines
        }
        return []
    }
    //MARK:- call Update Qty And Validate
    func hitAddOperationLine(){
        guard let inStockMove = self.inStockMove else {
            return
        }
        let moveLinesDic = getMoveLines()
       
        guard let API = self.API else {
            return
        }
        self.state = .loading
        API.hitAddOperationLineAPI(operationID:inStockMove, param:moveLinesDic) { (results) in
            if results.success
            {
                let response = results.response
                if let dic:[String:Any]  = response , dic.count > 0 {
                    if let result = dic["result"] as? Bool {
                        if result {
                            if let lineId = dic["id"] as? Int{
                                self.lines.append(lineId)
                            }
                            self.isSucess = true
                            self.message =  "Operation has Add successfully".arabic("تمت إضافة العملية بنجاح")
                            self.delegate?.updateOralidateItems()
                            self.state = .addOperationLineSucess
                        }else{
                            self.isSucess = false
                            self.message =  "pleas, try again later".arabic("من فضلك حاول في وقت لاحق")
                            self.state = .error
                        }
                    }else{
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
    //MARK:- call Get In Operations
    func hitGetInOperations(){
        guard let API = self.API else {
            return
        }
        self.state = .loading
        API.hitGetOperationLinesAPI(for:lines) { (results) in
            if results.success
            {
                let response = results.response
                if let dic:[String:Any]  = response , dic.count > 0 {
                    do {
                        let data = try JSONSerialization.data(withJSONObject: dic)
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        let obj: Odoo_Base<[OperationLineModel]> = try JSONDecoder().decode(Odoo_Base<[OperationLineModel]>.self, from: data )
                        if let result = obj.result {
                            self.inStockReport?.setOperationLinesData(with:result )
                            self.linesResult.append(contentsOf: result)
                            self.state = self.getResultCount() > 0 ? .populated : .empty
                        }else{
                            self.isSucess = false
                            self.message =  "No Data Found".arabic("لم يتم العثور علي بيانات")
                            self.state = .error
                        }
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
    //MARK:- call Update Qty And Validate
    func hitUpdateQtyAndValidate(){
        guard let inStockMove = self.inStockMove else {
            return
        }
        let updatedDic = getUpdateQtyDic()
       
        guard let API = self.API else {
            return
        }
        self.state = .loading
        API.hitUpdateQtyAndValidateAPI(for:inStockMove,with: updatedDic) { (results) in
            if results.success
            {
                let response = results.response
                if let dic:[String:Any]  = response , dic.count > 0 {
                    if let result = dic["result"] as? Bool {
                        if result {
                            self.isSucess = true
                            self.message =  "Quantity has been updated and verified successfully".arabic("تم تحديث الكمية والتحقق بنجاح")
//                            self.state = .error
                            self.delegate?.updateOralidateItems()
                            self.printReport()

                        }else{
                            self.isSucess = false
                            self.message =  "pleas, try again later".arabic("من فضلك حاول في وقت لاحق")
                            self.state = .error
                        }
                    }else{
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
    func printReport(restResult:Bool = true){
        if let inStockReport = self.inStockReport {
            inStockReport.setOperationLinesData(with:linesResult )
            let htmlReport = inStockReport.renderInStock()
            if restResult{
            self.resetResult()
            }
            self.message = htmlReport
            state = .report
        }
    }
    private func getUpdateQtyDic() -> [[String:Any]] {
        var productUpdated:[[String:Any]] = []
       /*let updatedItemArray =  linesResult.filter { (item) -> Bool in
            item.isQtyUpdated
        }*/
        linesResult.forEach { (item) in
            let dic = [
                "id": item.id ?? 0,
                "qty": item.product_uom_qty ?? 0
            ] as [String : Any]
            productUpdated.append(dic)
        }
        return productUpdated
        
    }
    func getResultCount() -> Int {
        return linesResult.count 
    }
    func getItem(at index:Int) -> OperationLineModel {
        return linesResult[index]
    }
    func resetResult(){
        linesResult.removeAll()
        inStockMove = nil
        state = .populated
    }
    func resetTitleResult(){
        self.inStockStateTypes = .DRAFT

        message = ""
        linesResult.removeAll()
        inStockMove = nil
        state = .setTitle
    }
    func setQty(for index:Int,with qty:Double)  {
         linesResult[index].product_uom_qty = qty
        linesResult[index].isQtyUpdated = true
    }
    func changeUOM(at index:Int,with uom:[String])  {
        linesResult[index].product_uom = uom
       linesResult[index].isQtyUpdated = true
   }
    func getQty(for index:Int) -> Double {
         return linesResult[index].product_uom_qty ?? 0
    }
    func isEnded() -> Bool{
            return true
    }
    
}
