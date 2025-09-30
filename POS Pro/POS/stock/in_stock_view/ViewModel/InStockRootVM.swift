//
//  InStockVM.swift
//  pos
//
//  Created by  Mahmoud Wageh on 5/3/21.
//  Copyright © 2021 khaled. All rights reserved.
//

import Foundation
protocol InStockRootVMProtocol  {
    func didSelect(_ item:InStockMoveModel)
    func didSelectInStockState(_ to:InStockRootVM.InStockStateTypes)
}

extension InStockRootVM {
    enum StateInStock {
        case empty
        case loading
        case populated
        case error
    }
    
    enum InStockStateTypes:String{
        case DRAFT = "draft" ,WAITING = "waiting",READY = "assigned",DONE = "done",CANCEL = "cancel"
        func getBackEndName() -> String{
            switch self {
            case .DRAFT:
                return "draft"
            case .WAITING:
                return "waiting"
            case .READY:
                return "assigned"
            case .DONE:
                return "done"
            case .CANCEL:
                return "cancel"
            }
        }
        func toString()->String{
            return "\(self)".lowercased()
        }
        func colorStaus()->UIColor{
            switch self {
            case .DRAFT :
                return #colorLiteral(red: 0.3254901961, green: 0.1529411765, blue: 0.5019607843, alpha: 1)
            case  .WAITING :
                return #colorLiteral(red: 0.9535716176, green: 0.4975310564, blue: 0.0882415846, alpha: 1)
            case .READY :
               return #colorLiteral(red: 0.08631695062, green: 0.7602397203, blue: 0.491546452, alpha: 1)
            case  .DONE :
                return #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            case .CANCEL:
                return #colorLiteral(red: 0.6910742521, green: 0.6861091256, blue: 0.6991057396, alpha: 1)
            }
        }
    }
}
class InStockRootVM:InStockDetailsVMProtocol {
    var state: StateInStock = .empty {
        didSet {
            self.updateLoadingStatusClosure?(state, message, isSucess)
        }
    }
    var updateLoadingStatusClosure: ((StateInStock, String?, Bool) -> Void)?
    private var message: String?
    private var isSucess: Bool = false
    var API:api?
    var inStockStateTypes:InStockStateTypes = .DRAFT
    var delegate:InStockRootVMProtocol?
    //MARK:- Offest Variables for In Stock State Types
    private var draftOffest:Int?
    private var waitingOffest:Int?
    private var readyOffest:Int?
    private var doneOffest:Int?
    private var cancelOffest:Int?
    private var stockRequestOrderOffest:Int?

    //MARK:- Result Variables for In Stock State Types
    private var draftResult: [InStockMoveModel]?
    private var waitingResult: [InStockMoveModel]?
    private var readyResult: [InStockMoveModel]?
    private var doneResult: [InStockMoveModel]?
    private var cancelResult: [InStockMoveModel]?
    private var allStatesResult: [InStockMoveModel]?

    //MARK:- Is Fetch All data for In Stock State Types
    private var isFetchAllDraft: Bool = false
    private var isFetchAllWaiting: Bool  = false
    private var isFetchAllReady: Bool  = false
    private var isFetchAllDone: Bool = false
    private var isFetchAllCancel: Bool = false
    private var isFetchAllStockRequestOrder: Bool = false

    var stock_type:STOCK_TYPES?

    func updateOralidateItems()
    {
        refershInStockStateTypes()
    }
    func didSelectInStockState(_ to:InStockRootVM.InStockStateTypes){
        inStockStateTypes = to
        if self.getResultCount() > 0 {
            self.state =  .populated
        }else{
            refershInStockStateTypes()
        }
        self.delegate?.didSelectInStockState(to)
    }
    func refershInStockStateTypes(){
        resetResult()
        if self.stock_type == .IN_STOCK_ALL {
            hitGetAllInOperations()
        }else{
            hitGetInOperations()
        }
    }
    private func handleResponseAPI( _ results: api.api_Results){
        if results.success
        {
            let response = results.response
            if let dic:[String:Any]  = response , dic.count > 0 {
                do {
                    let data = try JSONSerialization.data(withJSONObject: dic)
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                        let obj: Odoo_Base<[InStockMoveModel]> = try JSONDecoder().decode(Odoo_Base<[InStockMoveModel]>.self, from: data )
                        if let result = obj.result {
                            self.setIsAllFetch(for:result.count)
                            self.appendResult(with: result)
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
    }
    //MARK:- call Get In Operations
    func hitGetAllInOperations(){
        if getIsAllFetch() {
            return
        }
        guard let API = self.API else {
            return
        }
        self.state = .loading
        API.hitGetInOperationsAPI(for:"", with: getNextOffest()) { (results) in
            self.handleResponseAPI(results)
        };
    }
    //MARK:- call Get In Operations
    func hitGetInOperations(){
        if getIsAllFetch() {
            return
        }
        guard let API = self.API else {
            return
        }
        self.state = .loading
        API.hitGetInOperationsAPI(for:inStockStateTypes.getBackEndName(), with: getNextOffest()) { (results) in
            self.handleResponseAPI(results)
        };
    }
    //MARK:- Get In-Stock Move Model  for In Stock State Types
    func getItem(at index:Int) -> InStockMoveModel?{
        if self.stock_type == .IN_STOCK_ALL {
            if let result = allStatesResult {
               return result[index]
            }
            return nil
        }
        switch inStockStateTypes {
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
        case .READY:
            if let result = readyResult {
                return result[index]
            }
            return nil
        case .DONE:
            if let result = doneResult {
                return result[index]
            }
            return nil
        case .CANCEL:
            if let result = cancelResult {
                return result[index]
            }
            return nil
        }
    }
    func isEnded() -> Bool{
        if self.stock_type == .IN_STOCK_ALL {
        return isFetchAllStockRequestOrder
        }
        switch inStockStateTypes {
        case .DRAFT:
           return isFetchAllDraft
        case .WAITING:
            return isFetchAllWaiting
        case .READY:
            return isFetchAllReady
        case .DONE:
            return isFetchAllDone

        case .CANCEL:
            return isFetchAllCancel
        }
    }
    //MARK:- Get Result Count for In Stock State Types
    func getResultCount() -> Int{
        var count = 0
        if self.stock_type == .IN_STOCK_ALL {
            if let result = allStatesResult {
                count = result.count
            }
        }else{
        switch inStockStateTypes {
        case .DRAFT:
            if let result = draftResult {
                count = result.count
            }
        case .WAITING:
            if let result = waitingResult {
                count = result.count
            }
        case .READY:
            if let result = readyResult {
                count = result.count
            }
        case .DONE:
            if let result = doneResult {
                count = result.count
            }
        case .CANCEL:
            if let result = cancelResult {
                count = result.count
            }
        }
        }
        return count
    }
    //MARK:- Append Items  for In Stock State Types Result
    private func appendResult(with items:[InStockMoveModel]){
        if self.stock_type == .IN_STOCK_ALL {
            if let _ = allStatesResult {
                allStatesResult?.append(contentsOf: items)
            }else{
                allStatesResult = []
                allStatesResult?.append(contentsOf: items)
            }
            return
        }else{
        switch inStockStateTypes {
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
        case .READY:
            if let _ = readyResult {
                readyResult?.append(contentsOf: items)
            }else{
                readyResult = []
                readyResult?.append(contentsOf: items)
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
        case .CANCEL:
            if let _ = cancelResult {
                cancelResult?.append(contentsOf: items)
            }else{
                cancelResult = []
                cancelResult?.append(contentsOf: items)
            }
            return
        }
            
        }
    }
    //MARK:- Get Next Offest for In Stock State Types
    private func getNextOffest() -> Int {
        if self.stock_type == .IN_STOCK_ALL {
            if let nextOffest = stockRequestOrderOffest {
                return nextOffest + 40
            }
            return 0
        }
        switch inStockStateTypes {
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
        case .READY:
            if let nextOffest = readyOffest {
                return nextOffest + 40
            }
            return 0
        case .DONE:
            if let nextOffest = doneOffest {
                return nextOffest + 40
            }
            return 0
        case .CANCEL:
            if let nextOffest = cancelOffest {
                return nextOffest + 40
            }
            return 0
        }
    }
    private func setIsAllFetch(for count:Int){
        if count < 40 {
            if self.stock_type == .IN_STOCK_ALL {
                isFetchAllStockRequestOrder = true
            }else{
            switch inStockStateTypes {
            case .DRAFT:
                isFetchAllDraft = true
            case .WAITING:
                isFetchAllWaiting = true
            case .READY:
                isFetchAllReady = true
            case .DONE:
                isFetchAllDone = true

            case .CANCEL:
                isFetchAllCancel = true
            }
            }
        }
    }
    private func getIsAllFetch() -> Bool{
        if self.stock_type == .IN_STOCK_ALL {
            return isFetchAllStockRequestOrder

        }
            switch inStockStateTypes {
            case .DRAFT:
               return isFetchAllDraft
            case .WAITING:
                return isFetchAllWaiting
            case .READY:
                return isFetchAllReady
            case .DONE:
                return isFetchAllDone
            case .CANCEL:
               return isFetchAllCancel
            }
    }
    //MARK:- Reset Result for In Stock State Types
    private func resetResult() {
        if self.stock_type == .IN_STOCK_ALL {
            allStatesResult?.removeAll()
            stockRequestOrderOffest = nil
            isFetchAllStockRequestOrder = false
        }else{
        switch inStockStateTypes {
        case .DRAFT:
            draftResult?.removeAll()
            draftOffest = nil
            isFetchAllDraft = false
        case .WAITING:
           waitingResult?.removeAll()
            waitingOffest = nil
            isFetchAllWaiting = false
        case .READY:
            readyResult?.removeAll()
            readyOffest = nil
            isFetchAllReady = false
        case .DONE:
            doneResult?.removeAll()
            doneOffest = nil
            isFetchAllDone = false
        case .CANCEL:
           cancelResult?.removeAll()
            cancelOffest = nil
            isFetchAllCancel = false

        }
        }
        state = .populated
    }
}
