//
//  IngenicoInteractor.swift
//  pos
//
//  Created by M-Wageh on 06/06/2021.
//  Copyright © 2021 khaled. All rights reserved.
//

import Foundation
//import Alhamrani
 

//class IngenicoInteractor:AlhamraniDelegate {
class IngenicoInteractor:PaymentDeviceProtocol {
    var updateStatusClosure: ((PaymentDeviceState, String?, Device_payment_order_class?) -> Void)?
    static let shared:IngenicoInteractor = IngenicoInteractor()
    private var ingenicoRequestModel:IngenicoRequestModel!
 

    //MARK:- variables ingenico State
    private var ingenicoState: PaymentDeviceState = .empty {
        didSet {
            self.updateIngenicoStatusClosure?(ingenicoState,message,data)
        }
    }
    var updateIngenicoStatusClosure: ((PaymentDeviceState,String?,Device_payment_order_class?) -> Void)?
    var message:String?
    var data:Device_payment_order_class?
    private var orderUid:String?
    private var orderId:Int?

    private init(){
//        alhamrani = Alhamrani()
//        alhamrani.delegate = self
        ingenicoRequestModel = IngenicoRequestModel()
    }
    func setIp(_ ip:String ){
        ingenicoRequestModel?.device_ip = ip
    }
    func setOrderUid(_ orderUid:String,for Id:Int ){
        self.orderUid = orderUid
        self.orderId = Id
    }
    func setTotalAmount(_ amount:String ){
        ingenicoRequestModel?.amount = amount
    }
    func setEcrWith(ecr_no:String, ecr_receipt_no:String){
        ingenicoRequestModel?.ecr_no = ecr_no
       // ingenicoRequestModel?.ecr_receipt_no = ecr_receipt_no
    }
    func isTimoOutRequest(){
        switch ingenicoState.self  {
        case .loading:
            let data = getLogData("Connection Time Out")
            self.addToLog( key: "ConnectionTimeOut" + "(\(ingenicoRequestModel?.device_ip ?? ""))" , prefix: "error", data: data)
            self.message = "Connection time out".arabic("انتهى وقت محاولة الاتصال")
            self.ingenicoState = .error
            return
        default:
            return
        }
    }
    //MARK:- Alhamrani check Ingenico Connection
    func checkConnection(with ip: String){
        let connectionIp = ip.isEmpty ? ingenicoRequestModel.device_ip : ip
        let data = getLogData("check Ingenico Connection")
        self.addToLog( key: "LoadingConnect" + "(\(connectionIp))" , prefix: "loading", data: data)
        self.ingenicoState = .loading
//        let result = alhamrani.checkDevice(device_ip:connectionIp)
    //    message = result
        if message?.count == 19 {
            let dataCheck = getLogData(message)
            self.addToLog( key: "CheckConnect" + "(\(connectionIp))" , prefix: "check", data: dataCheck)
        }else{
            let dataCheck = getLogData(message)
            self.addToLog( key: "CheckConnect" + "(\(connectionIp))" , prefix: "error", data: dataCheck)
        }
        ingenicoState = .check
    }
    //MARK:- Alhamrani sendECRRequest
    func sendECRRequest(){
        if  self.ingenicoRequestModel.amount.isEmpty {
            message = "pleas, check The device ip and the paied ammount".arabic("يرجي التحقق من ال ipوالقيمه المراد دفعها ")
            let connectionIp = ingenicoRequestModel.device_ip
            let dataCheck = getLogData(message)
            self.addToLog( key: "SendRequest" + "(\(connectionIp))" , prefix: "error", data: dataCheck)
            self.ingenicoState = .error
            return
            
        }
        self.ingenicoState = .loading
        /*
        alhamrani.sendECRRequest(device_ip: ingenicoRequestModel.device_ip,
                                 msg_id: ingenicoRequestModel.msg_id,
                                 amount: ingenicoRequestModel.amount,
                                 ecr_no: ingenicoRequestModel.ecr_no,
                                 ecr_receipt_no: ingenicoRequestModel.ecr_receipt_no,
                                 field1: ingenicoRequestModel.field1,
                                 field2: ingenicoRequestModel.field2,
                                 field3: ingenicoRequestModel.field3,
                                 field4: ingenicoRequestModel.field4,
                                 field5: ingenicoRequestModel.field5)
 */
    }
    
    //MARK:- AlhamraniDelegate did Receive Response
    func didReceiveResponse(_response: [Dictionary<String, String>]) {
        let connectionIp = ingenicoRequestModel.device_ip
        let dataCheck = ["order_uid":self.orderUid ?? "","response":_response].jsonString()
        self.addToLog( key: "Response" + "(\(connectionIp))" , prefix: "Response", data: dataCheck)
        
        var jsonResponse:[String:String] = [:]
        _response.forEach { item in
            item.forEach { dic in
                jsonResponse[dic.key] = dic.value
            }
        }
        do{
        let data = try JSONSerialization.data(withJSONObject: jsonResponse)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let obj: Device_payment_order_class = try JSONDecoder().decode(Device_payment_order_class.self, from: data )
            if ((obj.auth?.lowercased().contains("cancel") ?? false) ){
                self.message = "Transaction Decline as Timeout or Cancelled by User".arabic("رفض المعاملة باعتبارها مهلة أو ألغاها المستخدم")
                let dataCheck = getLogData(message)
                self.addToLog( key: "Cancelled" + "(\(connectionIp))" , prefix: "cancelled", data: dataCheck)
                self.ingenicoState = .error
            }else{
                if ((obj.auth?.lowercased().contains("absent") ?? false) ){
                    self.message = "Transaction Decline as enter wrong pin or invalid card ".arabic("رفض المعاملة بسبب إدخال رقم تعريف شخصي خاطئ أو بطاقة غير صالحة")
                    let dataCheck = getLogData(message)
                    self.addToLog( key: "WrongPin" + "(\(connectionIp))" , prefix: "error", data: dataCheck)
                    self.ingenicoState = .error
                    
                }else{
                    if let code = obj.auth_code , !code.isEmpty{
                        self.data = obj
                        self.data?.setOrderWith(Uid: self.orderUid!,id:self.orderId!, account_journal_id: 0)
                       self.data?.saveToDB()
                        let dataCheck = getLogData(obj.toDictionary?.jsonString())
                        self.addToLog(ingenico_id:  self.data?.id , key: "receiveResponse" + "(\(connectionIp))" , prefix: "receiveResponse", data: dataCheck)

                ingenicoState = .receiveResponse
                    }
                }
            }
          }
        catch{
             SharedManager.shared.printLog(error)
            self.message = "Invalid transaction!".arabic("المعاملة غير صالحة")
            let dataCheck = getLogData(message)
            self.addToLog( key: "InvalidTransaction" + "(\(connectionIp))" , prefix: "error", data: dataCheck)
            self.ingenicoState = .error
            
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
    
    
}
struct IngenicoRequestModel {
    var device_ip: String {
        set{
            
        }
        get{
            return SharedManager.shared.appSetting().ingenico_ip
        }
    }
    var amount:String = ""
    var msg_id:String = "PUR"
    var ecr_no:String = ""
    var ecr_receipt_no:String = ""
    var field1:String = ""
    var field2:String = ""
    var field3:String = ""
    var field4:String = ""
    var field5:String = ""
    
}
/*
 
 [["response_code": "000"], ["ecr_no": "123"], ["ecr_receipt": "0123456789"], ["amount": "000000000050"], ["card_no": "588848******3013"], ["card_expire": "1812"], ["card_type": "SPAN"], ["auth": "467041"], ["txt_date": "0606"], ["txt_time": "212158"], ["RRN": "062121001539"], ["TID": "5599057500000575"], ["start_date_and_time": "210606212223"], ["information": "RAJB123412341234   55990575000005755411000151AU.01K062121001539"], ["card_scheme": "P1SPAN"], ["card_details_number_and_expiry": "588848******3013           12/18"], ["auth_code": "467041"], ["txn_end_date_and_time": "210606212224"], ["emv_data": "SWIPED 000 "]]
 
 line["card_number"] = ingenico_objc.card_no
 line["card_type"] = ingenico_objc.card_type
 line["response_code"] = ingenico_objc.response_code
 line["rrn"] = ingenico_objc.rRN
 **/

extension Encodable {

  var toDictionary: [String: Any]? {
    guard let data = try? JSONEncoder().encode(self) else { return nil }
    return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
  }

}
