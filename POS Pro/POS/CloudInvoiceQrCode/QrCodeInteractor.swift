//
//  QrCodeInteractor.swift
//  pos
//
//  Created by M-Wageh on 26/03/2024.
//  Copyright © 2024 khaled. All rights reserved.
//

import Foundation

class QrCodeInteractor{
    enum StateQrCodeEnum {
        case empty
        case loading
        case populated
        case error(String)
        case reloading
    }
    static let shared:QrCodeInteractor = QrCodeInteractor()
    var state: StateQrCodeEnum = .empty {
        didSet {
            self.updateLoadingStatusClosure?(state)
        }
    }
    var updateLoadingStatusClosure: ((StateQrCodeEnum) -> Void)?
    var isStartGetQr:Bool = false
    var isStartPrint:Bool = false

    private init(){
        
    }
    func retryForFailure(){
        if SharedManager.shared.appSetting().enable_cloud_qr_code{
            self.getNeedToGetQr()
            self.getNeedToPrint()
        }
    }
    func getNeedToGetQr(){
        if isStartGetQr {
            return
        }
        if SharedManager.shared.appSetting().enable_cloud_qr_code{
            isStartGetQr = true
            let needToPrint = pos_order_qr_code_class.getNeedGetQr()
            if let first = needToPrint.first ,let order = first.getPosOrder() {
                self.hitGetInvoiceQrCodeAPI(orderUID:order.name ?? "")
            }else{
                isStartGetQr = false

            }
            

        }
    }
    func getNeedToPrint(){
        if isStartPrint {
            return
        }
        if SharedManager.shared.appSetting().enable_cloud_qr_code{
            isStartPrint = true
            let needToPrint = pos_order_qr_code_class.getNeedPrint()
            if let first = needToPrint.first ,let order = first.getPosOrder() {
                self.startPrint(with:first ,order:  order )
            }
            isStartPrint = false

        }
    }
    //Only Call in response createAPI
    func printBill(for order:pos_order_class,after_hit_api:Bool = false){
       SharedManager.shared.printLog("printBill === \(Date())")
        if SharedManager.shared.appSetting().enable_cloud_qr_code{
            if after_hit_api {
                if order.is_sync {
                    pos_order_qr_code_class.save(from: order,with:.START_GET_QR )
                    self.hitGetInvoiceQrCodeAPI(orderUID:order.name ?? "",needCallPrinter: true)
                }else{
                    pos_order_qr_code_class.save(from: order,with:.FAIL_SYNC )
                }
                return
            }else{
                if order.is_sync {
                    if let existCls = pos_order_qr_code_class.getBy(uid: order.name ?? ""),
                       !(existCls.qrCodeValue ?? "").isEmpty
                    {
                        self.startPrint(with:existCls ,order:order )
                    }else{
                        self.hitGetInvoiceQrCodeAPI(orderUID:order.name ?? "",needCallPrinter: true)
                    }
                    
                }else{
                    if let existCls = pos_order_qr_code_class.getBy(uid: order.name ?? ""){
                        if (existCls.status ?? .NONE != .FAIL_SYNC) {
                            pos_order_qr_code_class.updateQrValue(for: order.name ?? "", with: .FAIL_SYNC, value: MWConstants.generate_qr_phase_1)
                            self.getNeedToPrint()
                        }
                    }
                    
                }
            }
        }
        
    }
    func startPrint(with qrOrder:pos_order_qr_code_class,order:pos_order_class){
        if qrOrder.status == .START_PRINTER{
            return
        }
        pos_order_qr_code_class.updateStatus(for:order.uid ?? "" ,with: .START_PRINTER)
        qrOrder.status = .START_PRINTER
        var qrValue = qrOrder.qrCodeValue ?? ""
        if qrValue.isEmpty{
            return
        }
            let option = ordersListOpetions()
            option.parent_product = true
            var orgin_order = order
             var order_copy = orgin_order.copyOrder(option: option)
        if let orderOrginID = orgin_order.id{
            pos_order_helper_class.increment_print_count(order_id: orderOrginID)
            order_copy.id = orderOrginID
        }
            
//            if order_insurance != nil {
//                orgin_order = order
//                order_copy = order.copyOrder(option: option)
//            }
            order_copy.list_account_journal.append(contentsOf: orgin_order.list_account_journal)
            if SharedManager.shared.appSetting().enable_support_multi_printer_brands {
//                if let insurance_order = order_insurance {
//                    insurance_order.creatInsuranceQueuePrinter()
//                }
//                order_copy.printOrderByMWqueue()
                order_copy.creatBillQueuePrinter(.order)
                pos_order_helper_class.increment_print_count(order_id: order_copy.id!)
                pos_order_qr_code_class.save(from: order,with: .SUCCESS_SENT_TO_PRINTER)

                MWRunQueuePrinter.shared.startMWQueue()
            }
        
        
    }
    func checkInternetConnection(){
        if !NetworkConnection.isConnectedToNetwork()
        {
            WaringToast.shared.showWaringAlert(with: nil)

            return
        }
    }
    func hitGetInvoiceQrCodeAPI(orderUID:String,needCallPrinter:Bool = false){
        pos_order_qr_code_class.updateStatus(for:orderUID ,with: .START_GET_QR)

        if orderUID.isEmpty {
            pos_order_qr_code_class.updateStatus(for:orderUID ,with: .PENDING)
            return
        }
       
        SharedManager.shared.conAPI().hitGetInvoiceQrCodeAPI(for:orderUID) { results in
            self.isStartGetQr = false
            if results.success
            {
                let response = results.response
                if let dic:[String:Any]  = response , dic.count > 0 {
                    if let result = dic["result"] as? [[String : Any]] {
                        if result.count > 0{
                            let  qrCodeResponseData = result.map({QrCodeResponse(from: $0  )})
                            qrCodeResponseData.forEach { qrCodeResponse in
                                let qrValue = (qrCodeResponse.l10n_sa_qr_code_str ?? "")
                                pos_order_qr_code_class.updateQrValue(for: qrCodeResponse.pos_reference ?? "", with: .SUCCESS_GET_QR, value: qrValue.isEmpty ? MWConstants.generate_qr_phase_1 : qrValue)
                            }
                        }else{
                            pos_order_qr_code_class.updateQrValue(for: orderUID, with: .SUCCESS_GET_QR, value: MWConstants.generate_qr_phase_1)
                        }
                        if needCallPrinter{
                            self.getNeedToPrint()
                        }
                        
                        self.state = .populated
                    }else{
                        pos_order_qr_code_class.updateQrValue(for: orderUID, with: .FAIL_GET_QR, value: MWConstants.generate_qr_phase_1)

//                        pos_order_qr_code_class.updateStatus(for: orderUID, with: .FAIL_GET_QR)
                        if needCallPrinter{
                            self.getNeedToPrint()
                        }
                        self.state = .error("pleas, try again later".arabic("من فضلك حاول في وقت لاحق"))
                        
                    }
                    
                }else{
                    pos_order_qr_code_class.updateQrValue(for: orderUID, with: .FAIL_GET_QR, value: MWConstants.generate_qr_phase_1)

//                    pos_order_qr_code_class.updateStatus(for: orderUID, with: .FAIL_GET_QR)
                    if needCallPrinter{
                        self.getNeedToPrint()
                    }
                    self.state = .error("No Data Found".arabic("لم يتم العثور علي بيانات"))
                   
                }
                return
            }else{
                pos_order_qr_code_class.updateQrValue(for: orderUID, with: .FAIL_GET_QR, value: MWConstants.generate_qr_phase_1)

//                pos_order_qr_code_class.updateStatus(for: orderUID, with: .FAIL_GET_QR)
                if needCallPrinter{
                    self.getNeedToPrint()
                }
                self.state = .error(results.message ?? "")
                
            }
        }
    }
}

extension pos_order_class {
    func getCloudQRCodde() -> String?{
        return pos_order_qr_code_class.getBy(uid: self.name ?? "")?.qrCodeValue
    }
}

extension api {
    func hitGetInvoiceQrCodeAPI(for orderUID:String, completion: @escaping (_ result: api_Results) -> Void)  {
        if !NetworkConnection.isConnectedToNetwork()
        {
            completion(api_Results.getFailOffline())
            return
        }
        
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
        var context = get_context(display_default_code: true)
        context["display_zatca_xml"] = true
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params": [
                "model": "pos.order",
                "method": "get_zatca_qr_code",
                "args": [],
                "kwargs": [
                    "references_list": [orderUID],
                    "offset": 0,
                    "limit": false,
                "context": context
                ]
              ]
        ]
        let Cookie = api.get_Cookie()
        let header:[String:String] = [
            "Cookie" :  Cookie
        ]
        callApi(url: url,keyForCash: getCashKey(key:"get_invoice_qr_\(orderUID)"),header: header, param: param, completion: completion);
    }
}

class QrCodeResponse{
    var id:Int?
    var pos_reference:String?
    var l10n_sa_qr_code_str:String?
    init(from dic:[String:Any]){
        self.id = dic["id"] as? Int ?? 0
        self.pos_reference = dic["pos_reference"] as? String ?? ""
        self.l10n_sa_qr_code_str = dic["l10n_sa_qr_code_str"] as? String ?? ""
    }
    init(id: Int? = nil, pos_reference: String? = nil, l10n_sa_qr_code_str: String? = nil) {
        self.id = id
        self.pos_reference = pos_reference
        self.l10n_sa_qr_code_str = l10n_sa_qr_code_str
    }
}
