//
//  AdjustmentRootVM.swift
//  pos
//
//  Created by M-Wageh on 31/08/2021.
//  Copyright © 2021 khaled. All rights reserved.
//

import Foundation
protocol AdjustmentRootVMProtocol  {
    func didSelect(_ item:StockInventoryModel)
    func didSelectInventoryState(_ to:AdjustmentRootVM.AdjustmentStateTypes)
}

extension AdjustmentRootVM {
    enum StateAdjustment {
        case empty
        case loading
        case populated
        case error
    }
    
    enum AdjustmentStateTypes:String{
        case DRAFT = "draft" ,WAITING = "confirm",DONE = "done",ALL = "all"
        
        func getBackEndName() -> String{
            switch self {
            case .DRAFT:
                return "draft"
            case .WAITING:
                return "confirm"
            case .DONE:
                return "done"
            case .ALL:
                return ""
            }
        }
    }
}
class AdjustmentRootVM:AdjustmentDetailsVMProtocol {
    var state: StateAdjustment = .empty {
        didSet {
            self.updateLoadingStatusClosure?(state, message, isSucess)
        }
    }
    var updateLoadingStatusClosure: ((StateAdjustment, String?, Bool) -> Void)?
    private var message: String?
    private var isSucess: Bool = false
    var API:api?
    var adjustmentStateTypes:AdjustmentStateTypes = .ALL
    var delegate:AdjustmentRootVMProtocol?
    //MARK:- Offest Variables for In Stock State Types
    private var draftOffest:Int?
    private var waitingOffest:Int?
    private var readyOffest:Int?
    private var doneOffest:Int?
    private var cancelOffest:Int?
    //MARK:- Result Variables for In Stock State Types
    private var draftResult: [StockInventoryModel]?
    private var waitingResult: [StockInventoryModel]?
    private var allResult: [StockInventoryModel]?
    private var doneResult: [StockInventoryModel]?
    private var cancelResult: [StockInventoryModel]?
    //MARK:- Is Fetch All data for In Stock State Types
    private var isFetchAllDraft: Bool = false
    private var isFetchAllWaiting: Bool  = false
    private var isFetchAllEnd: Bool  = false
    private var isFetchAllDone: Bool = false
    private var isFetchAllCancel: Bool = false

    func updateOralidateItems()
    {
        refershInventoryStateTypes()
    }
    func didSelectInStockState(_ to:AdjustmentRootVM.AdjustmentStateTypes){
        adjustmentStateTypes = to
        if self.getResultCount() > 0 {
            self.state =  .populated
        }else{
            refershInventoryStateTypes()
        }
        self.delegate?.didSelectInventoryState(to)
    }
    func refershInventoryStateTypes(){
        resetResult()
        hitGetInventory()
    }
    //MARK:- call Get Inventory
    func hitGetInventory(){
        if getIsAllFetch() {
            return
        }
        guard let API = self.API else {
            return
        }
        self.state = .loading
        API.hitGetInventoryAPI(for:adjustmentStateTypes.getBackEndName(), with: getNextOffest()) { (results) in
            if results.success
            {
                let response = results.response
                if let dic:[String:Any]  = response , dic.count > 0 {
                    do {
                        let data = try JSONSerialization.data(withJSONObject: dic)
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        let obj: Odoo_Base<[StockInventoryModel]> = try JSONDecoder().decode(Odoo_Base<[StockInventoryModel]>.self, from: data )
                        if let result = obj.result {
                            self.setIsAllFetch(for:result.count)
                            self.appendResult(with:result)
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
    //MARK:- Get In-Stock Move Model  for In Stock State Types
    func getItem(at index:Int) -> StockInventoryModel?{
        switch adjustmentStateTypes {
        case .DRAFT:
            if let result = draftResult {
               return result[index]
            }
            return nil
        case .WAITING:
            if let result = waitingResult {
                return result[index]
            }
            return nil
        case .ALL:
            if let result = allResult {
                return result[index]
            }
            return nil
        case .DONE:
            if let result = doneResult {
                return result[index]
            }
            return nil
        }
    }
    func isEnded() -> Bool{
        switch adjustmentStateTypes {
        case .DRAFT:
            return isFetchAllDraft
        case .WAITING:
            return isFetchAllWaiting
        case .ALL:
            return isFetchAllEnd
        case .DONE:
            return isFetchAllDone
        }
    }
    //MARK:- Get Result Count for In Stock State Types
    func getResultCount() -> Int{
        var count = 0
        switch adjustmentStateTypes {
        case .DRAFT:
            if let result = draftResult {
                count = result.count
            }
        case .WAITING:
            if let result = waitingResult {
                count = result.count
            }
        case .ALL:
            if let result = allResult {
                count = result.count
            }
        case .DONE:
            if let result = doneResult {
                count = result.count
            }
       
        }
        return count
    }
    //MARK:- Append Items  for In Stock State Types Result
    private func appendResult(with items:[StockInventoryModel]){
        switch adjustmentStateTypes {
        case .DRAFT:
            if let _ = draftResult {
                draftResult?.append(contentsOf: items)
            }else{
                draftResult = []
                draftResult?.append(contentsOf: items)
            }
            return
        case .WAITING:
            if let _ = waitingResult {
                waitingResult?.append(contentsOf: items)
            }else{
                waitingResult = []
                waitingResult?.append(contentsOf: items)
            }
            return
        case .ALL:
            if let _ = allResult {
                allResult?.append(contentsOf: items)
            }else{
                allResult = []
                allResult?.append(contentsOf: items)
            }
            return
        case .DONE:
            if let _ = doneResult {
                doneResult?.append(contentsOf: items)
            }else{
                doneResult = []
                doneResult?.append(contentsOf: items)
            }
            return
        }
    }
    //MARK:- Get Next Offest for In Stock State Types
    private func getNextOffest() -> Int {
        switch adjustmentStateTypes {
        case .DRAFT:
            if let nextOffest = draftOffest {
                return nextOffest + 40
            }
            return 0
        case .WAITING:
            if let nextOffest = waitingOffest {
                return nextOffest + 40
            }
            return 0
        case .ALL:
            if let nextOffest = readyOffest {
                return nextOffest + 40
            }
            return 0
        case .DONE:
            if let nextOffest = doneOffest {
                return nextOffest + 40
            }
            return 0
        }
    }
    private func setIsAllFetch(for count:Int){
        if count < 40 {
            switch adjustmentStateTypes {
            case .DRAFT:
                isFetchAllDraft = true
            case .WAITING:
                isFetchAllWaiting = true
            case .ALL:
                isFetchAllEnd = true
            case .DONE:
                isFetchAllDone = true

           
            }
        }
    }
    private func getIsAllFetch() -> Bool{
            switch adjustmentStateTypes {
            case .DRAFT:
               return isFetchAllDraft
            case .WAITING:
                return isFetchAllWaiting
            case .ALL:
                return isFetchAllEnd
            case .DONE:
                return isFetchAllDone
          
            }
    }
    //MARK:- Reset Result for In Stock State Types
    private func resetResult() {
        switch adjustmentStateTypes {
        case .DRAFT:
            draftResult?.removeAll()
            draftOffest = nil
            isFetchAllDraft = false
        case .WAITING:
           waitingResult?.removeAll()
            waitingOffest = nil
            isFetchAllWaiting = false
        case .ALL:
            allResult?.removeAll()
            readyOffest = nil
            isFetchAllEnd = false
        case .DONE:
            doneResult?.removeAll()
            doneOffest = nil
            isFetchAllDone = false
        

        }
        state = .populated
    }
}
