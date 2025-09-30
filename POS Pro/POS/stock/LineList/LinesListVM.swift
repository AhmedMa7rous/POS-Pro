//
//  LinesListVM.swift
//  pos
//
//  Created by  Mahmoud Wageh on 5/30/21.
//  Copyright © 2021 khaled. All rights reserved.
//

import Foundation
extension Sequence {
    func group<U: Hashable>(by key: (Iterator.Element) -> U) -> [U:[Iterator.Element]] {
        return Dictionary.init(grouping: self, by: key)
    }
}
class StorableCategoryModel{
    var isExpended:Bool = false
    var categoryID:Int?
    var categoryName:String?
    var linesResult: [StorableItemModel]?
    init(from key:String?, array:[StorableItemModel]){
        linesResult = []
        if let key = key  {
            if  let id = Int(key) {
                categoryID = id
                categoryName = array.first?.categ_id.last
            }else{
                categoryName = key
            }
            linesResult?.append(contentsOf: array)
        }
    }
}
class LinesListVM {
    var state: InStockRootVM.StateInStock = .empty {
        didSet {
            self.updateLoadingStatusClosure?(state, message, isSucess)
        }
    }
    var updateLoadingStatusClosure: ((InStockRootVM.StateInStock, String?, Bool) -> Void)?
    private var message: String?
    private var isSucess: Bool = false
    var API:api?
    //MARK:- Offest Variables for In Stock State Types
    private var linesOffest:Int?
    //MARK:- Result Variables for In Stock State Types
    private var linesResult: [StorableItemModel]?
    private var categsResult: [StorableCategoryModel]?
    private var categsFilterResult: [StorableCategoryModel]?

    //MARK:- Is Fetch All data for In Stock State Types
    private var isFetchAllLines: Bool = false
    var updateItems:[IndexPath:StorableItemModel] = [:]
    var delegate:LinesListDelegate?
    var viewType:LINES_STORED_VIEW_TYPES?
    var filterCategoryIDs:[Int]?
    var productRequest:product_product_class?
    init(viewType:LINES_STORED_VIEW_TYPES,filterCategoryID:[Int]?,productRequest:product_product_class?){
        self.viewType = viewType
        self.filterCategoryIDs = filterCategoryID
        self.productRequest = productRequest
        if let categID = self.productRequest?.categ_id{
            self.filterCategoryIDs = [categID]
        }
    }
    //MARK:- call Get In Operations
    func hitGetStoredLinesAPI(){
        if isFetchAllLines {
            return
        }
        guard let API = self.API else {
            return
        }
        self.state = .loading
        API.hitGetAllStorableItemsAPI(with: getNextOffest(),limit: getLimit(), categID: self.filterCategoryIDs,product_tmpl_id: self.productRequest?.product_tmpl_id) { (results) in
            if results.success
            {
                let response = results.response
                if let dic:[String:Any]  = response , dic.count > 0 {
                    do {
                        let data = try JSONSerialization.data(withJSONObject: dic)
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        let obj: Odoo_Base<[StorableItemModel]> = try JSONDecoder().decode(Odoo_Base<[StorableItemModel]>.self, from: data )
                        if let result = obj.result {
                            self.setIsAllFetch(for:result.count)
                            self.appendResult(with:result)
                            if self.categsFilterResult?.count == 1{
                                self.categsFilterResult?.first?.isExpended = true
                            }
                            self.state = self.getCategoryResultCount() > 0 ? .populated : .empty
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
    
    //MARK:- Get Next Offest for In Stock State Types
    private func getLimit() -> Int {
        return 0
        /*
        if viewType == .VIEW_SELECT{
            return 0
        }
        return 40
         */

    }
    private func getNextOffest() -> Int {
        return 0

        /*
        if viewType == .VIEW_SELECT{
            return 0
        }
            if let _ = linesOffest {
                linesOffest! += 40
            }else{
        linesOffest = 0
            }
            return linesOffest!
        */
    }
    private func setIsAllFetch(for count:Int){
        if count < 40 {
            
            isFetchAllLines = true
            
        }
    }
    //MARK:- Append Items  for In Stock State Types Result
    private func appendResult(with items:[StorableItemModel]){
        let dataDic = items.group(by: \.categ_id.first)
        for (keyCategory,linesArray) in dataDic {
            if let _ = categsResult {
                categsResult?.append(StorableCategoryModel(from:keyCategory,array:linesArray))
                categsFilterResult?.append(StorableCategoryModel(from:keyCategory,array:linesArray))
            }else{
                categsResult = []
                categsFilterResult = []
                categsResult?.append(StorableCategoryModel(from:keyCategory,array:linesArray))
                categsFilterResult?.append(StorableCategoryModel(from:keyCategory,array:linesArray))
            }
            
        }
        
            if let _ = linesResult {
                linesResult?.append(contentsOf: items)
            }else{
                linesResult = []
                linesResult?.append(contentsOf: items)
            }
         
        }
    func togleExpanded(at section:Int){
        categsFilterResult?[section].isExpended = !(categsFilterResult?[section].isExpended ?? false)
        self.state = self.getCategoryResultCount() > 0 ? .populated : .empty

    }
    func getCategoryResultCount() -> Int{
            return categsFilterResult?.count ?? 0
        
    }
    func getCategoryItem(at section:Int) -> StorableCategoryModel?{
        if let result = categsFilterResult {
            return result[section]
        }
           /* if let result = linesResult {
               return result[index]
            }
            */
            return nil
        }
    //MARK:- Get Result Count for In Stock State Types
    func getLinesResultCount(for section:Int) -> Int{
      
        return categsFilterResult?[section].linesResult?.count ?? 0

       // return linesResult?.count ?? 0
    }
    func isEnded() -> Bool{
            return isFetchAllLines
    }
    func selectCategory(_ index:Int){
        if let selectCategory = categsFilterResult?[index]{
        delegate?.updateCategories([selectCategory])
        }
    }
    func setQty(for index:IndexPath,with qty:Double)  {
        let section = index.section
        let row = index.row
        categsFilterResult?[section].linesResult?[row].qty = qty
       // linesResult?[index].qty = qty
        updateItems[index] =  categsFilterResult?[section].linesResult?[row]
        if qty == 0 {
            updateItems.removeValue(forKey: index)
        }
        delegate?.updateItems(updateItems.values.compactMap{ $0 })
        if viewType == .VIEW_SELECT {
            categsFilterResult?[section].linesResult?[row].qty = 0
            updateItems.removeAll()
        }
    
//        linesResult[index].isQtyUpdated = true
    }
    //MARK:- Get In-Stock Move Model  for In Stock State Types
    func getItem(at index:IndexPath) -> StorableItemModel?{
        if let result = categsFilterResult {
            return result[index.section].linesResult?[index.row]
        }
           /* if let result = linesResult {
               return result[index]
            }
            */
            return nil
        }
    //MARK:- Reset Result for In Stock State Types
     func resetResult() {
         categsFilterResult?.removeAll()
         categsResult?.removeAll()
        linesResult?.removeAll()
        linesOffest = nil
        isFetchAllLines = false
        }
    func changeUOM(at index:IndexPath , with new_UOM_id:[String]){
        if let _ = categsFilterResult {
            categsFilterResult?[index.section].linesResult?[index.row].select_uom_id = new_UOM_id
            updateItems[index] =  categsFilterResult?[index.section].linesResult?[index.row]
            delegate?.updateItems(updateItems.values.compactMap{ $0 })
            state = .populated
        }

    }
    func saveAddOperationLine(){
        self.delegate?.saveAddItems()
    }
    func getQty(for index:IndexPath) -> Double {
        return  categsFilterResult?[index.section].linesResult?[index.row].qty ?? 0

//         return  linesResult?[index].qty ?? 0
    }
    func search(by searchText:String){
        if searchText.isEmpty {
            categsFilterResult?.removeAll()
            categsFilterResult?.append(contentsOf: categsResult ?? [])
            state = .populated
            return
        }
        categsFilterResult?.removeAll()
        
        if let entry = linesResult?.filter({return ($0.display_name?.lowercased().contains(searchText.lowercased())) ?? false}) {
            SharedManager.shared.printLog(entry)
            let result = StorableCategoryModel(from: "Search".arabic("بحث"), array: entry)
            result.isExpended = true
            categsFilterResult?.append(result)
        } else {
           SharedManager.shared.printLog("no match")
            let result = StorableCategoryModel(from: "Search".arabic("بحث"), array: [])
            result.isExpended = true

            categsFilterResult?.append(result)

        }
        state = .populated

        
        
    }
    
}
