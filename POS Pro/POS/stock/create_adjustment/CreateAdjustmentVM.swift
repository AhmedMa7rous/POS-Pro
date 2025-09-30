//
//  CreateAdjustmentVM.swift
//  pos
//
//  Created by M-Wageh on 26/07/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation
class CreateAdjustmentVM{
    enum CreateAdjustmentState {
        case empty
        case loading
        case populated
        case error(message:String)
        case updateItems
    }
    var API:api?
    var updateLoadingStatusClosure: ((CreateAdjustmentState) -> Void)?

    var state: CreateAdjustmentState = .empty {
        didSet {
            self.updateLoadingStatusClosure?(state)
        }
    }
    var createAdjustmentModel:CreateAdjustmentModel?
    var delegate: AdjustmentDetailsVMProtocol?
    func hitCrateAdjustmentAPI(){
        if createAdjustmentModel?.isValidate() ?? false {
            self.state = .loading
            API?.hitCreateAdjustmentAPI(param:createAdjustmentModel?.toDictionary() ?? [:] ) { (results) in
                if results.success
                {
                    let response = results.response
                    if let dic:[String:Any]  = response , dic.count > 0 {
                        do {
                            self.state = .populated
                        } catch {
                            SharedManager.shared.printLog(error)
                            self.state = .error(message:"pleas, try again later".arabic("من فضلك حاول في وقت لاحق") )
                        }
                    }else{
                        self.state = .error(message:"No Data Found".arabic("لم يتم العثور علي بيانات"))
                    }
                    return
                }else{
                    self.state = .error(message:results.message ?? "")
                    
                }
            }
            
        }else{
            state = .error(message: "You must enter all required fields".arabic("يجب ادخال جميع البيانات بشكل صحيح"))
        }
    }
    func getCountItems() -> Int{
        if  createAdjustmentModel?.products != nil {
            return createAdjustmentModel?.products?.count ?? 0
        }else{
            return createAdjustmentModel?.categories?.count ?? 0
        }
    }
    
    func getItem(at index:IndexPath)->(StorableItemModel?,StorableCategoryModel?){
        if  createAdjustmentModel?.products != nil {
            return (createAdjustmentModel?.products?[index.row],nil)
        }else{
            return (nil,createAdjustmentModel?.categories?[index.row])
        }
    }
    func removeItem(at index:IndexPath){
        if  createAdjustmentModel?.products != nil {
            createAdjustmentModel?.products?.remove(at: index.row)
        }else{
            createAdjustmentModel?.categories?.remove(at: index.row)
        }
        self.state = .updateItems
    }
    
    
    
}
//MARK: - CreateAdjustmentVM + LinesListDelegate
extension CreateAdjustmentVM:LinesListDelegate{
    func updateItems(_ items: [StorableItemModel]) {
        if createAdjustmentModel?.products == nil {
            createAdjustmentModel?.products = []
        }
        if (createAdjustmentModel?.products?.filter({$0.id == items.first?.id}).count ?? 0) <= 0 {
        createAdjustmentModel?.products?.append(contentsOf: items)
        self.state = .updateItems
        }
    }
    func updateCategories(_ items:[StorableCategoryModel]){
        if createAdjustmentModel?.categories == nil {
            createAdjustmentModel?.categories = []
        }
        if (createAdjustmentModel?.categories?.filter({$0.categoryID == items.first?.categoryID}).count ?? 0) <= 0 {
        createAdjustmentModel?.categories?.append(contentsOf: items)
        self.state = .updateItems
        }
    }
    
    func restProducts(){
        createAdjustmentModel?.products?.removeAll()
        createAdjustmentModel?.products = nil
        self.state = .updateItems

    }
    func resetCategories(){
        createAdjustmentModel?.categories?.removeAll()
        createAdjustmentModel?.categories = nil
        self.state = .updateItems
    }
    func setAdjustmentType(with type:ADJUSTMENT_TYPE){
        self.createAdjustmentModel?.typeAdjustment = type
    }

    
}

    /*
    "name": "test ios 7",
                    "pos_config_id": 1,
                    "select_by": "products",
                    "product_ids": [
                            [
                               6,0,[42,45]
                            ]
                        ],
                    "exhausted": false
                }
     */

