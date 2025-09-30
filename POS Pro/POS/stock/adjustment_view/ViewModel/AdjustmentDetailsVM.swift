//
//  AdjustmentDetailsVM.swift
//  pos
//
//  Created by M-Wageh on 31/08/2021.
//  Copyright © 2021 khaled. All rights reserved.
//

import Foundation

protocol AdjustmentDetailsVMProtocol {
    func updateOralidateItems()
}
class AdjustmentDetailsVM:AdjustmentRootVMProtocol,LinesListDelegate{
    func updateItems(_ items: [StorableItemModel]) {
        selectedItems.removeAll()
        selectedItems.append(contentsOf: items.reversed())
    }
    func saveAddItems() {
        if selectedItems.count > 0 {
            hitAddLinesToAdjustmentAPI()
        }
    }
    
    enum StateAdjustmentDetails {
        case empty
        case loading
        case populated
        case error
        case report
        case addLinesToAdjustmentSucess
        case setTitle
        case reloading
    }
    var state: StateAdjustmentDetails = .empty {
        didSet {
            self.updateLoadingStatusClosure?(state, message, isSucess)
        }
    }
    var updateLoadingStatusClosure: ((StateAdjustmentDetails, String?, Bool) -> Void)?
    var delegate: AdjustmentDetailsVMProtocol?
    private var message: String?
    private var isSucess: Bool = false
    var API:api?
    private var linesResult:[StockInventoryLineModle] = []
    private var lines:[Int] = []
    var inStockMove:Int?
    var selectedItems:[StorableItemModel] = []
    var adjustmentStateTypes:AdjustmentRootVM.AdjustmentStateTypes?
    var  selectStockInventoryModel:StockInventoryModel?
    private var adjustmentReport:AdjustmentReport?
    var filterCategoryIds:[Int]?
    func  showControlBtnsStack() -> Bool{
        //(self.adjustmentStateTypes != AdjustmentRootVM.AdjustmentStateTypes.DONE) ||
        let showControlBtnsStack = ((self.selectStockInventoryModel?.state?.lowercased().contains("confirm") ?? false))
        return showControlBtnsStack
    }
    func showStartBtnStack() -> Bool{
        //(self.adjustmentStateTypes != AdjustmentRootVM.AdjustmentStateTypes.DONE) ||
        let showStartBtnStack = ((self.selectStockInventoryModel?.state?.lowercased().contains("draft") ?? false))
        return showStartBtnStack
    }
    func didSelect(_ item:StockInventoryModel)
    {
        if self.state == .loading && ((item.id ?? 0) == inStockMove) {
            return
        }
        resetResult()
        adjustmentReport = AdjustmentReport(stockInventoryModel: item)
        self.lines = item.line_ids ?? []
        inStockMove = item.id ?? 0
        self.filterCategoryIds = item.category_ids
        self.message = (item.sequence ?? "") + " - " + (item.name ?? "")
        selectStockInventoryModel = item
        self.state = .setTitle

        self.hitGetInventoryLines()
 
        
    }
    func didSelectInventoryState(_ to:AdjustmentRootVM.AdjustmentStateTypes){
        self.adjustmentStateTypes = to

        self.message = to.rawValue
        self.state = .setTitle

        resetResult()
    }
    /*
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
 */
    private func getAddLinesArgs() ->[[Any]]{
        if selectedItems.count > 0 {
            guard let selectStockInventoryModel = self.selectStockInventoryModel else {
                return []
            }
            var move_lines: [[Any]] = []
            selectedItems.forEach { (item) in
                let param:[String : Any] = [
                    "product_id": item.id ?? 0,
                    "product_qty_uom": item.qty,
                    "inventory_id": selectStockInventoryModel.id,
                    "uom_id":Int(item.uom_id.first ?? "0") ?? 0,
                    "location_id":selectStockInventoryModel.location_ids?.first ?? 0,
                ]
                move_lines.append([param])
            }
            return move_lines
        }
        return []
    }
    //MARK: - call Update Qty And Validate
    func hitAddLinesToAdjustmentAPI(){
        
        guard let inStockMove = self.inStockMove else {
            return
        }
        let addLinesArgs = getAddLinesArgs()
       
        guard let API = self.API else {
            return
        }
        self.state = .loading
        API.hitAddLinesToAdjustmentAPI(for:inStockMove, with:addLinesArgs) { (results) in
            if results.success
            {
                let response = results.response
                if let dic:[String:Any]  = response , dic.count > 0 {
                    if let result = dic["result"] as? [Any] {
                        if let lineId = result.first as? Int{
                                self.lines.append(lineId)
                            }
                            self.isSucess = true
                            self.message =  "Products has Add successfully".arabic("تمت إضافة المنتجات بنجاح")
                            self.delegate?.updateOralidateItems()
                            self.state = .addLinesToAdjustmentSucess
                        
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
    //MARK:- call Get Inventory Lines
    func hitGetInventoryLines(){
        guard let API = self.API else {
            return
        }
        guard let inStockMove = self.inStockMove else {
            return
        }
        self.state = .loading
        API.hitInventoryLinesAPI(for:inStockMove) { (results) in
            if results.success
            {
                let response = results.response
                if let dic:[String:Any]  = response , dic.count > 0 {
                    do {
                        let data = try JSONSerialization.data(withJSONObject: dic)
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        let obj: Odoo_Base<[StockInventoryLineModle]> = try JSONDecoder().decode(Odoo_Base<[StockInventoryLineModle]>.self, from: data )
                        if let result = obj.result {
//                            self.inStockReport?.setOperationLinesData(with:result )
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
//        if updatedDic.count <= 0{
//            return
//        }
        guard let API = self.API else {
            return
        }
        self.state = .loading
        API.hitUpdateQtyAndValidateInventoryAPI(for:inStockMove,with: updatedDic) { (results) in
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
    //MARK:- call cancel inventory
    func hitCancelInventory(){
        guard let inStockMove = self.inStockMove else {
            return
        }
       
        guard let API = self.API else {
            return
        }
        self.state = .loading
        API.hitCancelInventoryAPI(for:inStockMove) { (results) in
            if results.success
            {
                let response = results.response
                if let dic:[String:Any]  = response , dic.count > 0 {
                    if dic.count == 2 {
                            self.isSucess = true
                            self.message =  "Inventory has been cancel successfully".arabic("تم إلغاء المخزون بنجاح")
//                            self.state = .error
                        self.resetResult()
                            self.delegate?.updateOralidateItems()
                            self.state = .reloading

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
    //MARK: - call Start inventory
    func hitStartInventory(){
        guard let inStockMove = self.inStockMove else {
            return
        }
       
        guard let API = self.API else {
            return
        }
        self.state = .loading
        API.hitStartInventoryAPI(for:inStockMove) { (results) in
            if results.success
            {
                let response = results.response
                if let dic:[String:Any]  = response , dic.count > 0 {
                    if let result = dic["result"] as? [String:Any] {
                        if let _ = result["view_id"] as? Int {
                            self.isSucess = true
                            self.message =  "Inventory has been Start successfully".arabic("بدأ الجرد بنجاح")
                            self.resetResult()
                            self.delegate?.updateOralidateItems()
                            self.state = .reloading
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
    
    private func printReport(){
        
        if let adjustmentReport = self.adjustmentReport {
            adjustmentReport.setstockInventoryLinesData(with:linesResult )
            let htmlReport = adjustmentReport.renderAdjustmentReport()
         self.message = htmlReport
        }
        self.resetResult()
        state = .report
    }
 
    private func getUpdateQtyDic() -> [[String:Any]] {
        if SharedManager.shared.appSetting().enable_initalize_adjustment_with_zero {
            return getUpdateWithZeroQtyDic()
        }
        var productUpdated:[[String:Any]] = []

       let updatedItemArray =  linesResult.filter { (item) -> Bool in
            item.isQtyUpdated
        }
        
        updatedItemArray.forEach { (item) in
            let dic = [
                "id": item.id ?? 0,
                "qty": item.getQty() ?? 0,
                "uom_id":Int(item.uom_id.first ?? "0") ?? 0
            ] as [String : Any]
            productUpdated.append(dic)
        }
        return productUpdated
        
    }
    private func getUpdateWithZeroQtyDic() -> [[String:Any]] {
        var productUpdated:[[String:Any]] = []
    
        linesResult.forEach { itemLine in
            var dic = [
                "id": itemLine.id ?? 0,
                "qty": 0,
                "uom_id":Int(itemLine.uom_id.first ?? "0") ?? 0
            ] as [String : Any]
            if itemLine.isQtyUpdated {
                dic["qty"] = itemLine.getQty() ?? 0
            }
            productUpdated.append(dic)
        }
       
        
        return productUpdated
        
    }
    func getResultCount() -> Int {
        return linesResult.count
    }
    func getItem(at index:Int) -> StockInventoryLineModle {
        let isConfirmState = showControlBtnsStack()
        var item = linesResult[index]
        if !isConfirmState {
            item.initalizeQty()
        }
        return item
    }
    func resetResult(){
        linesResult.removeAll()
        inStockMove = nil
        state = .populated
    }
    func resetLineResult(){
        linesResult.removeAll()
        state = .populated

    }
    func setQty(for index:Int,with qty:Double)  {
        linesResult[index].setQty(with: qty)
        linesResult[index].isQtyUpdated = true
        state = .populated

    }
    //setUOM
    func setUOM(for index:Int,with uom:UOMStrobleProduct)  {
        let uomArray = ["\(uom.id ?? 0 )",uom.name ?? "-"]
        linesResult[index].uom_id.removeAll()
        linesResult[index].uom_id.append(contentsOf: uomArray)
        linesResult[index].isQtyUpdated = true
        state = .populated

    }
    func getQty(for index:Int) -> Double {
         return linesResult[index].getQty() ?? 0
    }
    func isEnded() -> Bool{
            return true
    }
    
}
