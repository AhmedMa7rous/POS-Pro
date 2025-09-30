//
//  Device_payment_order_class + extension.swift
//  pos
//
//  Created by M-Wageh on 12/06/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation
import GeideaParsingLib

struct Device_payment_order_class : Codable {
    var response_code : String?
    var ecr_no : String?
    var ecr_receipt : String?
    var amount : String?
    var card_no : String?
    var card_expire : String?
    var card_type : String?
    var auth : String?
    var txt_date : String?
    var txt_time : String?
    var rRN : String?
    var tID : String?
    var start_date_and_time : String?
    var information : String?
    var card_scheme : String?
    var card_details_number_and_expiry : String?
    var auth_code : String?
    var txn_end_date_and_time : String?
    var emv_data : String?
    var order_uid : String?
    var order_id : Int?
    var id : Int = 0
    var account_journal_id : Int?
    var dbClass:database_class?

    enum CodingKeys: String, CodingKey {

        case response_code = "response_code"
        case ecr_no = "ecr_no"
        case ecr_receipt = "ecr_receipt"
        case amount = "amount"
        case card_no = "card_no"
        case card_expire = "card_expire"
        case card_type = "card_type"
        case auth = "auth"
        case txt_date = "txt_date"
        case txt_time = "txt_time"
        case rRN = "RRN"
        case tID = "TID"
        case start_date_and_time = "start_date_and_time"
        case information = "information"
        case card_scheme = "card_scheme"
        case card_details_number_and_expiry = "card_details_number_and_expiry"
        case auth_code = "auth_code"
        case txn_end_date_and_time = "txn_end_date_and_time"
        case emv_data = "emv_data"
        case order_uid = "order_uid"
        case order_id = "order_id"
        case id = "id"
        case account_journal_id = "account_journal_id"


    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        response_code = try values.decodeIfPresent(String.self, forKey: .response_code)
        ecr_no = try values.decodeIfPresent(String.self, forKey: .ecr_no)
        ecr_receipt = try values.decodeIfPresent(String.self, forKey: .ecr_receipt)
        amount = try values.decodeIfPresent(String.self, forKey: .amount)
        card_no = try values.decodeIfPresent(String.self, forKey: .card_no)
        card_expire = try values.decodeIfPresent(String.self, forKey: .card_expire)
        card_type = try values.decodeIfPresent(String.self, forKey: .card_type)
        auth = try values.decodeIfPresent(String.self, forKey: .auth)
        txt_date = try values.decodeIfPresent(String.self, forKey: .txt_date)
        txt_time = try values.decodeIfPresent(String.self, forKey: .txt_time)
        rRN = try values.decodeIfPresent(String.self, forKey: .rRN)
        tID = try values.decodeIfPresent(String.self, forKey: .tID)
        start_date_and_time = try values.decodeIfPresent(String.self, forKey: .start_date_and_time)
        information = try values.decodeIfPresent(String.self, forKey: .information)
        card_scheme = try values.decodeIfPresent(String.self, forKey: .card_scheme)
        card_details_number_and_expiry = try values.decodeIfPresent(String.self, forKey: .card_details_number_and_expiry)
        auth_code = try values.decodeIfPresent(String.self, forKey: .auth_code)
        txn_end_date_and_time = try values.decodeIfPresent(String.self, forKey: .txn_end_date_and_time)
        emv_data = try values.decodeIfPresent(String.self, forKey: .emv_data)
        order_uid = nil
        order_id = nil
        id = 0
        account_journal_id = nil

    }
    init(){
        
    }
    init(from transaction:Transaction){
        response_code = transaction.transactionStatusEn
        ecr_no = transaction.retrievalReferenceNumber
        ecr_receipt = transaction.systemsTraceAuditNumber
        amount = transaction.purchaseAmountEn
        card_no = transaction.cardNumber
        card_expire = transaction.expiryDate
        card_type = transaction.cardSchemeEn
        auth = transaction.pinVerifiedStatusEn
        txt_date = transaction.transactionDate
        txt_time =  transaction.transactionTime
        rRN = transaction.retrievalReferenceNumber
        tID = transaction.terminalID
        start_date_and_time = transaction.transactionDueDate
        information = transaction.cardAcceptorBusinessCode
        card_scheme = transaction.cardSchemeEn + " - " + transaction.cardSchemeAr
        card_details_number_and_expiry = transaction.expiryDate
        auth_code = transaction.approvalCodeEn
        txn_end_date_and_time = transaction.transactionDueDate
        emv_data = transaction.merchantID
        order_uid = nil
        order_id = nil
        account_journal_id = nil
        id = 0
    }
    
    
    
    mutating func setOrderWith(Uid: String,id:Int,account_journal_id:Int) {
        self.order_uid = Uid
        self.order_id = id
        self.account_journal_id = account_journal_id
        let dic = self.toDictionary!
        dbClass = database_class(table_name: "ingenico_order_class", dictionary: dic,id: id,id_key:"id")
    }
    mutating func setIdWith(Id: Int) {
        self.id = Id
    }
    mutating func saveToDB(){
        dbClass?.dictionary = self.toDictionary!
        let row_id =  dbClass?.save() ?? 0
        if row_id != 0
        {
            setIdWith(Id: row_id)
        }
        

    }
    static func remove(orderId:Int) -> Bool  {
       return database_class(connect: .database).runSqlStatament(sql: "DELETE FROM ingenico_order_class  where order_id='\(orderId)'") 
    }
    static func get(orderId:Int) -> Device_payment_order_class?  {
        let dbClass = database_class(table_name: "ingenico_order_class", dictionary:[:],id: 0,id_key:"id")
        let dic =  dbClass.get_row(whereSql: " where order_id='\(orderId)'") ?? [:]
        if dic.count > 0 {
            do{
            let data = try JSONSerialization.data(withJSONObject: dic)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let obj: Device_payment_order_class = try JSONDecoder().decode(Device_payment_order_class.self, from: data )

               return obj
            }catch{
                SharedManager.shared.printLog(error)
                return nil

            }
        }
        return nil
   }
   
    

}
