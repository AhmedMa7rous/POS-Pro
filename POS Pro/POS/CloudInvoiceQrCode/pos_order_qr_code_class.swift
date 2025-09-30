//
//  pos_order_qr_code_class.swift
//  pos
//
//  Created by M-Wageh on 26/03/2024.
//  Copyright © 2024 khaled. All rights reserved.
//

import Foundation
enum QR_CODE_STATUS:Int{
    case NONE = 0,PENDING,SUCCESS_GET_QR,SUCCESS_SENT_TO_PRINTER,START_PRINTER,START_GET_QR,FAIL_SYNC,FAIL_PRINT,FAIL_GET_QR
    static func getGetQr()->[QR_CODE_STATUS]{
        return [QR_CODE_STATUS.PENDING]
//        return [QR_CODE_STATUS.PENDING,.FAIL_SYNC,.FAIL_GET_QR]
    }
    static func getSuccessGetQrString()->String{
        return QR_CODE_STATUS.getGetQr().map({"\($0.rawValue)"}).joined(separator: ",")
    }
    static func getPrint()->[QR_CODE_STATUS]{
        return [QR_CODE_STATUS.FAIL_PRINT,.SUCCESS_GET_QR,.FAIL_SYNC,.FAIL_GET_QR]
    }
    static func getPrintString()->String{
        return QR_CODE_STATUS.getPrint().map({"\($0.rawValue)"}).joined(separator: ",")
    }
}
class pos_order_qr_code_class:NSObject {
    
    static var  date_formate_database:String = "yyyy-MM-dd HH:mm:ss"
    
    
    var id : Int = 0
    var order_uid : String?
    var order_id : Int?
    var status : QR_CODE_STATUS?
    var qrCodeValue : String?
    var updated_at : String?
    var recieve_qr_date : String?
    var fileType:rowType?
    var openDrawer:Bool?
    
    var dbClass:database_class?

    override init() {
        dbClass = database_class(connect: .database)
    }
    
    
    init(fromDictionary dictionary: [String:Any]){
        super.init()
        
        id = dictionary["id"] as? Int ?? 0
        order_uid = dictionary["order_uid"] as? String ?? ""
        order_id = dictionary["order_id"] as? Int ?? 0
        status = QR_CODE_STATUS(rawValue: dictionary["status"] as? Int ?? 0) ?? .NONE
        qrCodeValue = dictionary["qrCodeValue"] as? String ?? ""
        recieve_qr_date = dictionary["recieve_qr_date"] as? String ?? ""
        updated_at = dictionary["updated_at"] as? String ?? ""
        fileType = rowType(rawValue: dictionary["fileType"] as? String ?? "") ?? .bill
        openDrawer = dictionary["openDrawer"] as? Bool ?? false
        
        dbClass = database_class(table_name: "pos_order_qr_code", dictionary: self.toDictionary(),id: id,id_key:"id",connect: .database)
    }
    
    
    func toDictionary() -> [String:Any]
    {
        var dictionary:[String:Any] = [:]
        dictionary["id"] = id
        dictionary["status"] = status
        dictionary["order_uid"] = order_uid
        dictionary["order_id"] = order_id
        dictionary["status"] = status?.rawValue
        dictionary["qrCodeValue"] = qrCodeValue ?? ""
        dictionary["recieve_qr_date"] = recieve_qr_date ?? ""
        dictionary["updated_at"] = updated_at ?? ""
        dictionary["fileType"] = fileType ?? ""
        dictionary["openDrawer"] = openDrawer ?? false

        return dictionary
    }
    
    
    
    func save()
    {
        dbClass?.dictionary = self.toDictionary()
        dbClass?.id = self.id
//        dbClass?.insertId = false
        
        self.id =  dbClass!.save()
        
        
    }
    static func save(from order:pos_order_class,with status:QR_CODE_STATUS = .PENDING,fileType:rowType = .bill, openDrawer:Bool = false){
        if let existCls = pos_order_qr_code_class.getBy(uid: order.name ?? ""){
            if existCls.status == status && existCls.fileType == fileType && existCls.openDrawer == openDrawer {
                return
            }
            existCls.status = status
            let recieve_date = baseClass.get_date_now_formate_datebase()
            existCls.recieve_qr_date = recieve_date
            existCls.fileType = fileType
            existCls.openDrawer = openDrawer
            existCls.save()
            return
        }else{
            let cls = pos_order_qr_code_class(fromDictionary: [:])
            cls.order_id = order.id
            cls.order_uid = order.name
            cls.status = status
            cls.fileType = fileType
            cls.openDrawer = openDrawer
            cls.save()
        }
    }
    static func getNeedGetQr() -> [pos_order_qr_code_class]{
        let cls = pos_order_qr_code_class(fromDictionary: [:])
        let rows  = cls.dbClass!.get_rows(whereSql: " where status in (\(QR_CODE_STATUS.getSuccessGetQrString()))  order by id desc limit 1 ").map({ pos_order_qr_code_class(fromDictionary:$0)})
        //TODO: - check if sync or not
        return rows
    }
    static func getNeedPrint() -> [pos_order_qr_code_class]{
        let cls = pos_order_qr_code_class(fromDictionary: [:])
        let rows  = cls.dbClass!.get_rows(whereSql: " where status in (\(QR_CODE_STATUS.getPrintString()))  order by id desc limit 1 ").map({ pos_order_qr_code_class(fromDictionary:$0)})
        //TODO: - check if sync or not
        return rows
    }
    
    static func updateStatus(for uid:String, with status:QR_CODE_STATUS){
        if let exist = pos_order_qr_code_class.getBy(uid: uid), (exist.status != status ){
            let cls = pos_order_qr_code_class(fromDictionary: [:])
            let recieve_date = baseClass.get_date_now_formate_datebase()
            let sql = "UPDATE pos_order_qr_code  set status = \(status.rawValue) , recieve_qr_date = '\(recieve_date)' WHERE order_uid in ('\(uid)') "
            _ = cls.dbClass?.runSqlStatament(sql: sql)
        }
    }
    static func updateQrValue(for uid:String, with status:QR_CODE_STATUS, value:String){
        if let exist = pos_order_qr_code_class.getBy(uid: uid), (exist.status != status ){
            if exist.qrCodeValue == value &&  exist.status == status {
                return
            }
            let cls = pos_order_qr_code_class(fromDictionary: [:])
            let recieve_date = baseClass.get_date_now_formate_datebase()
            let sql = "UPDATE pos_order_qr_code  set qrCodeValue = '\(value)' , status = \(status.rawValue) , recieve_qr_date = '\(recieve_date)' WHERE order_uid in ('\(uid)') "
            _ = cls.dbClass?.runSqlStatament(sql: sql)
        }
    }
    static func updateQrCode(for uid:String, with value:String){
        if let exist = pos_order_qr_code_class.getBy(uid: uid), (exist.qrCodeValue?.isEmpty ?? false){
            let cls = pos_order_qr_code_class(fromDictionary: [:])
            let recieve_date = baseClass.get_date_now_formate_datebase()
            let sql = "UPDATE pos_order_qr_code  set qrCodeValue = \(value) , recieve_qr_date = '\(recieve_date)' WHERE order_uid in ('\(uid)')  "
            _ = cls.dbClass?.runSqlStatament(sql: sql)
        }
    }
    
    static func getAll() ->  [[String:Any]] {
        let cls = pos_order_qr_code_class(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(whereSql: "")
        return arr
    }
     func getPosOrder() ->  pos_order_class? {
       
        let cls = pos_order_class(fromDictionary: [:])
         if let row  = cls.dbClass!.get_row(whereSql: " where  name = '\(order_uid ?? "")' order by id desc "){
             let option = ordersListOpetions()
             option.parent_product = true
             
              var order  = pos_order_class(fromDictionary: row,options_order:option )
             order.list_account_journal.append(contentsOf:  order.get_account_journal())
                 return order

        }
        return nil
        
    }
    
    static func getBy(uid:String) ->  pos_order_qr_code_class? {
        if uid.isEmpty {
            return nil
        }
        let cls = pos_order_qr_code_class(fromDictionary: [:])
        if let row  = cls.dbClass!.get_row(whereSql: " where  order_uid = '\(uid)' order by id desc "){
            return pos_order_qr_code_class(fromDictionary: row)
        }
        return nil
        
    }
  
   
    
    
}

