//
//  OrderSrockRquestListVM.swift
//  pos
//
//  Created by M-Wageh on 18/05/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation
import UIKit
import MMDrawerController


class OrderSrockRquestListVM{
    enum StateOrderSrockRquestList{
        case empty
        case loading
        case populated
        case error
        case fetchDetails
        case emptyDeails
        case reportPrinter
    }
    var state: StateOrderSrockRquestList = .empty {
        didSet {
            self.updateLoadingStatusClosure?(state, message, isSucess)
        }
    }
    var updateLoadingStatusClosure: ((StateOrderSrockRquestList, String?, Bool) -> Void)?
    private var message: String?
    private var isSucess: Bool = false
    //MARK:- Result Variables for In Stock State Types
    private var stockMovesResult: [StockRequestOrderMoveModel]?
    var stockDetailsResult: [StockRequestOrderDetailsModel]?

    var API:api?
    private var inStockReport:InStockReport?
    private var select_order_id:Int?
    init(with API:api){
        self.API = API
    }
     func printReport(at index:IndexPath){
        guard let moveModel = getItem(at: index)  else {return}
        inStockReport = InStockReport(inStockMoveModel:InStockMoveModel(from:moveModel) )
        if let inStockReport = self.inStockReport,
           
            let lines = stockDetailsResult?.map({ item in
                return OperationLineModel(from: item)
            }) {
            inStockReport.setOperationLinesData(with:lines )
            let htmlReport = inStockReport.renderInStock()
            self.message = htmlReport
            state = .reportPrinter
        }
    }
    //MARK:- call Get In Operations
    func getStockRequestOrder(){
        stockMovesResult?.removeAll()
        stockMovesResult = []
        guard let API = self.API else {
            return
        }
        self.state = .loading
        API.hitGetStockRequestOrderAPI() { (results) in
            if results.success
            {
                let response = results.response
                if let dic:[String:Any]  = response , dic.count > 0 {
                    do {
                        let data = try JSONSerialization.data(withJSONObject: dic)
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        let obj: Odoo_Base<[StockRequestOrderMoveModel]> = try JSONDecoder().decode(Odoo_Base<[StockRequestOrderMoveModel]>.self, from: data )
                        if let result = obj.result {
                            self.appendResult(result)
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
    //MARK:- call Get In Operations
    func getStockRequestOrderDetails(at index:IndexPath){
        let moveStock = self.getItem(at: index)
        guard let order_id = moveStock?.id  else {
            self.state = .emptyDeails

            return
        }
        if self.state == .loading && order_id == (select_order_id ?? 0) {
            return
        }
        select_order_id = order_id
        stockDetailsResult?.removeAll()
        stockDetailsResult = []
        guard let API = self.API else {
            self.state = .emptyDeails

            return
        }
        self.state = .loading
        API.hitGetStockRequestOrderDetailsAPI(for:  order_id ) { (results) in
            if results.success
            {
                let response = results.response
                if let dic:[String:Any]  = response , dic.count > 0 {
                    do {
                        let data = try JSONSerialization.data(withJSONObject: dic)
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        let obj: Odoo_Base<[StockRequestOrderDetailsModel]> = try JSONDecoder().decode(Odoo_Base<[StockRequestOrderDetailsModel]>.self, from: data )
                        if let result = obj.result {
                            self.stockDetailsResult?.append(contentsOf: result)
                            self.state = (self.stockDetailsResult?.count ?? 0) > 0 ? .fetchDetails : .emptyDeails
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
    func getResultCount() -> Int{
        return stockMovesResult?.count ?? 0
    }
    func getItem(at indexPath:IndexPath) -> StockRequestOrderMoveModel?{
        return stockMovesResult?[indexPath.row]

    }
    func appendResult(_ items:[StockRequestOrderMoveModel]){
        stockMovesResult?.append(contentsOf: items)
    }
    
  
}
class OrderSrockRquestListRouter{
    var viewController:UIViewController?
    static func createModule() -> OrderSrockRquestListVC{
        let vc = OrderSrockRquestListVC()
        vc.orderSrockRquestListVM = OrderSrockRquestListVM(with: api())
        let router = OrderSrockRquestListRouter()
        router.viewController = vc
        vc.orderSrockRquestListRouter = router
        return vc
    }
    func openViewReportVC(htmlReport:String){
            let viewReportVC = ViewAndPrintReportVCRouter.createModule(htmlReport:htmlReport)
        viewReportVC.modalPresentationStyle = .pageSheet
        viewReportVC.modalTransitionStyle = .coverVertical
            viewController?.present(viewReportVC, animated: true, completion: nil)
        
    }
}
extension AppDelegate{
    func loadStockRequest(){
        DispatchQueue.main.async {
            
            let controller = OrderSrockRquestListRouter.createModule()
            self.centerNav = UINavigationController(rootViewController: controller)
            self.centerNav?.isNavigationBarHidden = true
            
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "appStoryboard", bundle: nil)
            let leftSideNav = mainStoryboard.instantiateViewController(withIdentifier: "LeftMenuNavigationController") as! menu_left
//            leftSideNav.delegate = controller
            leftSideNav.parentViewConroller =   self.centerNav
            leftSideNav.parentName = "Stock Request"
            
            
            self.centerContainer = MMDrawerController(center: self.centerNav, leftDrawerViewController: leftSideNav,rightDrawerViewController:nil)
            
            //            self.centerContainer!.openDrawerGestureModeMask = MMOpenDrawerGestureMode.panningCenterView;
            self.centerContainer!.closeDrawerGestureModeMask = MMCloseDrawerGestureMode.tapCenterView;
            self.centerContainer!.maximumLeftDrawerWidth = 210
            
            
            self.centerContainer?.shouldStretchDrawer = false
            
            
            
            self.window!.rootViewController =  self.centerContainer
            self.window!.makeKeyAndVisible()
        }
    }
}
