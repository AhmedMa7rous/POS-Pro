//
//  StockRequestVM.swift
//  pos
//
//  Created by M-Wageh on 22/05/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation
import UIKit
protocol StockRequestDelegate{
    func updateItems(_ items:[StorableProductModel])
}
class CreateStockRequestVM:LinesListDelegate{
    enum CreateStockRequestState{
        case empty,updated,loading,error,populated
    }
    var state: CreateStockRequestState = .empty {
        didSet {
            self.updateLoadingStatusClosure?(state)
        }
    }
    var updateLoadingStatusClosure: ((CreateStockRequestState) -> Void)?
    var errorMessage:String?
    var sechadualDate:String?
    var API:api = api()

    //MARK:- Result Variables for In Stock State Types
    private var productsResult: [StorableItemModel] = []

    func changeUOM(at index:IndexPath , with new_UOM_id:[String]){
        if  productsResult.count > 0 {
            productsResult[index.row].select_uom_id = new_UOM_id
            state = .updated
        }
    }
    func getResultCount() -> Int{
        return productsResult.count
    }
    func getItem(at indexPath:IndexPath) -> StorableItemModel?{
        return productsResult[indexPath.row]

    }
    func setQty(for index:Int,with qty:Double)  {
        if qty <= 0 {
            productsResult.remove(at: index)
            state =  productsResult.count <= 0 ? .empty : .updated
            return
        }
        productsResult[index].qty = qty
    }
    //MARK:- Get In-Stock Move Model  for In Stock State Types
    func getQty(for index:Int) -> Double {
        return productsResult[index].qty
    }

    func updateItems(_ items:[StorableItemModel]){
        guard let selectItem = items.first else {return}
       if let current_index = productsResult.firstIndex { item in
            selectItem.id == item.id
       }{
           productsResult[current_index].qty += 1
       }else{
           productsResult.append(contentsOf: items)
       }
        state =  productsResult.count <= 0 ? .empty : .updated
    }
    func hitCreateStockRequest(updateProduct:product_product_class? = nil){
        if validDate() {
            guard let param = StockRequestOrderModel(with: productsResult, expectedDate: sechadualDate ?? "").toDictionary() else {
                return
            }
            self.state = .loading
            API.hitCreateStockRequestAPI(param:param ) { (results) in
                if results.success
                {
                    let response = results.response
                    if let dic:[String:Any]  = response , dic.count > 0 {
                        do {
                            let setQty = self.productsResult.first?.qty ?? 1
                            self.errorMessage =  ""
                            self.sechadualDate = ""
                            self.productsResult.removeAll()
                            if let updateProduct = updateProduct{
                                updateProduct.updateQtyAvaliable(by:setQty ,with :OPERATION_QTY_TYPES.PLUS) { newQty in
                                    SharedManager.shared.printLog("newQty====\(newQty)")
                                    self.state = .populated

                                }
                            }else{
                                self.state = .populated
                            }
                        } catch {
                             SharedManager.shared.printLog(error)
                            self.errorMessage =  "pleas, try again later".arabic("من فضلك حاول في وقت لاحق")
                            self.state = .error
                        }
                    }else{
                        self.errorMessage =  "No Data Found".arabic("لم يتم العثور علي بيانات")
                        self.state = .error
                    }
                    return
                }else{
                    self.errorMessage = results.message ?? ""
                    self.state = .error
                    
                }
            };
        }
        
    }
    func validDate()->Bool{
        if sechadualDate == nil || (sechadualDate?.isEmpty ?? true){
            errorMessage = "You should select schedule date".arabic("يجب تحديد تاريخ الاستلام")
            state = .error
            return false
        }
        if productsResult.count <= 0{
            errorMessage = "You should select request stock items ".arabic("يجب عليك تحديد طلب عناصر المخزون")
            state = .error
            return false
        }
        return true
        
    }
}
