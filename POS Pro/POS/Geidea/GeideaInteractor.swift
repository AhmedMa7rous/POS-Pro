//
//  GeideaInteractor.swift
//  pos
// fba
//  Created by M-Wageh on 21/03/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation

import GeideaParsingLib

enum PaymentDeviceState {
    case empty
    case loading
    case check
    case receiveResponse
    case error
    case update_status(message:String)
}


class GeideaInteractor:PaymentDeviceProtocol{
    var updateStatusClosure: ((PaymentDeviceState, String?, Device_payment_order_class?) -> Void)?
    //MARK:- State Enum
    static let shared:GeideaInteractor = GeideaInteractor()
    private var geideaRequestModel:GeideaRequestModel!
    //MARK:- variables Geidea State
    private var geideaState: PaymentDeviceState = .empty {
        didSet {
            self.updateStatusClosure?(geideaState,message,data)
        }
    }
    var message:String?
    var data:Device_payment_order_class?
//    weak var geideaParsingManager:GeideaParsingManager?
    private var orderUid:String?
    private var orderId:Int?
    private var journalId:Int?

    var jsonResponseTransaction:Transaction?
    var jsonResponseReconiliation:Reconciliation?
     private init(){
        // NOTE :-  old_SDK

//        GeideaParsingManager.shared.tcpDelegate = self // NOTE : - new_SDK v2.0.0
//        GeideaParsingManager.shared.uploadLogs = false
        geideaRequestModel = GeideaRequestModel()
    }
    func stop(){
//        GeideaParsingManager.shared.Reconciliation()
//        GeideaParsingManager.shared.delegate = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300), execute: {
//            GeideaParsingManager.shared = nil
//        GeideaParsingManager.shared.uploadLogs = false
       // GeideaParsingManager.shared.hostAddress = ""
       // GeideaParsingManager.shared.port = 0
//            GeideaParsingManager.shared.delegate = nil
//            GeideaParsingManager.shared.tcpDelegate = nil // NOTE : - new_SDK v2.0.0

//        GeideaParsingManager.shared.Payment(amount:"0")
            
//        GeideaParsingManager.shared
        }
)
    }
    func checkConnection(with ip: String = "") {
//       GeideaParsingManager.shared.delegate = self // NOTE :-  old_SDK
        GeideaParsingManager.shared.tcpDelegate = self // NOTE : - new_SDK v2.0.0
//        GeideaParsingManager.shared.uploadLogs = false
       if let connectionIp = ip.isEmpty ? geideaRequestModel?.device_ip : ip,
          let connectionPort =  geideaRequestModel?.device_port{
           setPort(with:connectionPort)
           GeideaParsingManager.shared.hostAddress = connectionIp
//           GeideaParsingManager.shared.checkCommunication()
           self.message = connectionIp
           geideaState = .check
           let data = getLogData("Connection To  \(connectionIp)")
           self.addToLog( key: "checkConnection" + "(\(geideaRequestModel?.device_ip ?? ""))" , prefix: "check", data: data)
       }
    }
    func setPort(with port:Int){
        GeideaParsingManager.shared.port = port
    }
    func setTerminalID(with terminal:String){
//        GeideaParsingManager.shared.terminalID = geideaRequestModel?.device_terminal
    }
    func startPayment(){
        DispatchQueue.main.async {
            self.geideaState = .loading
            if let amountString = self.geideaRequestModel?.amount.trimmingCharacters(in: .whitespacesAndNewlines),
               let amountDouble = Double(amountString)?.rounded(value: 2){
                if amountDouble < 0.01{
                    self.amountLessThan01()
                    return
                }else{
                    if let connectionIp =  (self.geideaRequestModel?.device_ip)?.trimmingCharacters(in: .whitespacesAndNewlines),
                       let connectionPort =  (self.geideaRequestModel?.device_port){
                        GeideaParsingManager.shared.tcpDelegate = nil
                        GeideaParsingManager.shared.transactionDelegate = nil
                        
                        GeideaParsingManager.shared.tcpDelegate = self
                        GeideaParsingManager.shared.transactionDelegate = self
                        
                        GeideaParsingManager.shared.hostAddress = connectionIp
                        GeideaParsingManager.shared.port = connectionPort
                        let valueAmount = String(format: "%.2f", (amountDouble).rounded(value: 2)) as NSString
                        GeideaParsingManager.shared.Payment(amount:valueAmount)
                        /*
                         if let ammountInt = Double(ammount as String){
                         //                GeideaParsingManager.shared.Payment(amount:"\(0.01 * 10 )" as NSString)
                         GeideaParsingManager.shared.Payment(amount:"\(ammountInt * 10 )" as NSString)
                         }else{
                         //                GeideaParsingManager.shared.Payment(amount:"\(0.01 * 10 )" as NSString)
                         GeideaParsingManager.shared.Payment(amount:ammount)
                         }
                         */
                    }
                }
            }
        }
    }
    func reconciliation(){
        GeideaParsingManager.shared.Reconciliation()
    }
    func setTotalAmount(_ amount:String ){
        geideaRequestModel?.amount = amount
       }
    func setEcrWith(ecr_no:String, ecr_receipt_no:String){
        geideaRequestModel?.ecr_no = ecr_no
       // ingenicoRequestModel?.ecr_receipt_no = ecr_receipt_no
    }
    func setOrderUid(_ orderUid:String,for Id:Int, journal_id:Int ){
        self.orderUid = orderUid
        self.orderId = Id
        self.journalId = journal_id
    }
    func isTimoOutRequest(){
           switch geideaState.self  {
           case .loading:
               let data = getLogData("Connection Time Out")
               self.addToLog( key: "ConnectionTimeOut" + "(\(geideaRequestModel?.device_ip ?? ""))" , prefix: "error", data: data)
               self.message = "Connection time out".arabic("انتهى وقت محاولة الاتصال")
               self.geideaState = .error
               return
           default:
               return
           }
       }
    func amountLessThan01(){
           switch geideaState.self  {
           case .loading:
               let data = getLogData("Connection Ended")
               self.addToLog( key: "Connection Ended" + "(\(geideaRequestModel?.device_ip ?? ""))" , prefix: "error", data: data)
               self.message = "Connection Ended".arabic("تم انهاء الاتصال")
               self.geideaState = .error
               return
           default:
               return
           }
       }
    private func getLogData(_ messag:Any?)->String{
           var param:[String:Any] = [:]
           if let id_order =  self.orderId{
               param["id_order"] = id_order
           }
           if let uid_order =  self.orderUid{
               param["uid_order"] = uid_order
           }
           if let message =  messag{
               param["message"] = message
           }
           return param.jsonString() ?? ""
       }
    func addToLog(ingenico_id:Int? = nil,key:String? = nil,prefix:String? = nil, data:String? = nil){
            let ingenico_log:ingenico_log_class = ingenico_log_class(fromDictionary: [:])
           ingenico_log.ingenico_id = ingenico_id
           ingenico_log.key = key
           ingenico_log.prefix = prefix
           ingenico_log.data = data
           ingenico_log.save()
       }
   
    func completePayment(transaction:Transaction){
        var obj = Device_payment_order_class(from: transaction)
        //SAR 175.00

        if let ammountPaiedByGeidea = Double(transaction.purchaseLabelEn.replacingOccurrences(of: "\(SharedManager.shared.getCurrencyName())", with: "").replacingOccurrences(of: " ", with: "")) {
            
        }
        self.data = obj
        if let code = obj.auth_code , !code.isEmpty{
            let connectionIp = geideaRequestModel?.device_ip
            obj.setOrderWith(Uid: self.orderUid!,id:self.orderId!,account_journal_id:self.journalId!)
            saveDevicePaymentOrder(obj)
//            obj.saveToDB()
            let dataCheck = getLogData(transaction.toDictionary().description)
            self.addToLog(ingenico_id: obj.id , key: "receiveResponse" + "(\(connectionIp))" , prefix: "receiveResponse", data: dataCheck)
            geideaState = .receiveResponse
        }
    }
    
    func manulePaymentComplete(ammount:String){
        guard let id_order = self.orderId else {return}
        guard let uid_order = self.orderUid else {return}

        var obj = Device_payment_order_class()
        obj.card_scheme = "Manual - " + "يدوي"
        obj.card_type = "Manual"
        obj.rRN = "Manual"
        obj.response_code = "Manual"
        obj.information = "Manual"
        obj.ecr_receipt = "Manual"
        obj.card_no = "Manual"
        obj.auth = "Manual"
        obj.amount = ammount
        obj.auth_code = "Manual"
        
        if let code = obj.auth_code , !code.isEmpty{
            let connectionIp = geideaRequestModel?.device_ip
            obj.setOrderWith(Uid: uid_order,id:id_order,account_journal_id:self.journalId!)
//            obj.saveToDB()
            saveDevicePaymentOrder(obj)
            let dataCheck = getLogData(["SKIP":"SKIP BY Cashier"].description)
            self.addToLog(ingenico_id: obj.id , key: "receiveResponse" + "(\(connectionIp))" , prefix: "receiveResponse", data: dataCheck)
            geideaState = .receiveResponse
        }
    }
    func saveDevicePaymentOrder(_ objc:Device_payment_order_class){
        guard let order_id =  objc.order_id  else {return}
        var new_objc:Device_payment_order_class = objc
        if var exit_item = Device_payment_order_class.get(orderId: order_id) {
            if exit_item.card_type == "Manual"{
                if !( Device_payment_order_class.remove(orderId: order_id) ) {
                    return
                }
            }
        }
        new_objc.saveToDB()
        
    }
    

}

extension GeideaInteractor:GeideaTCPDelegate{
    func checkCommStatus(_ status: Bool) {
        print("checkCommStatus ==== \(status)")
        geideaState = .update_status(message: status ? "Connecting" : "Not Connecting")

        self.addToLog( key: "checkCommStatus" + "(\(status))" , prefix: "checkCommStatus", data: "")

    }
    
    
    
    func reconciliationResponseHTML(_ htmlString:String){
        let data = getLogData(htmlString)
        self.addToLog( key: "reconciliationResponseHTML" + "(\(geideaRequestModel?.device_ip ?? ""))" , prefix: "receiveResponse", data: data)

    }
    func reconciliationResponseJSON(_ jsonResponse:Reconciliation){
        let data = getLogData(jsonResponse.toDictionary().description)
        self.addToLog( key: "reconciliationResponseJSON" + "(\(geideaRequestModel?.device_ip ?? ""))" , prefix: "receiveResponse", data: data)

        self.message = jsonResponse.toDictionary().description
        geideaState = .receiveResponse

    }
    func updateStatus(message:String){
        print("updateStatus ==== \(message)")
        geideaState = .update_status(message: message)

        self.message = message
        let data = getLogData(" \(message)")
        self.addToLog( key: "updateStatus" + "(\(geideaRequestModel?.device_ip ?? ""))" , prefix: "Status", data: data)
//        if message.lowercased().contains("closed"){
//            geideaState = .error
//        }

    }
    func didFailWithError(_ errorCode:Int , errorMessage:String){
        print("didFailWithError ========= errorMessage ========= \(errorMessage)")

        let data = getLogData("Fail error_code \(errorCode) error_message \(errorMessage)")
        self.addToLog( key: "didFailWithError" + "(\(geideaRequestModel?.device_ip ?? ""))" , prefix: "error", data: data)
        self.message = errorMessage
        geideaState = .error
    }
}
extension GeideaInteractor:GeideaTCPTransactionDelegate {
    func transactionResponseHTML(_ htmlString:String){
        let data = getLogData(htmlString)
        self.addToLog( key: "transactionResponseHTML" + "(\(geideaRequestModel?.device_ip ?? ""))" , prefix: "receiveResponse", data: data)

    }
    func transactionResponseJSON(_ jsonResponse:Transaction){
        let data = getLogData(jsonResponse.toDictionary().description)
        self.message = jsonResponse.toDictionary().description
        if jsonResponse.transactionStatus != .APPROVED{
                self.message = "Credit card verification error"
                geideaState = .error
                self.addToLog( key: "transactionResponseJSON" + "(\(geideaRequestModel?.device_ip ?? ""))" , prefix: "error", data: data)
        }else{
            
                self.addToLog( key: "transactionResponseJSON" + "(\(geideaRequestModel?.device_ip ?? ""))" , prefix: "receiveResponse", data: data)
                self.completePayment(transaction:jsonResponse)
            
        }
      //  self.reconciliation()
        self.stop()
        
    }
}
