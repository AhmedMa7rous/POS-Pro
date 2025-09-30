//
//  pos_e_invoice_class.swift
//  pos
//
//  Created by M-Wageh on 15/04/2024.
//  Copyright © 2024 khaled. All rights reserved.
//

import Foundation
class pos_e_invoice_class:NSObject {
    var id : Int = 0
    var order_id : Int?
    var order_uid : String?
    var pih : String?
    var base64_content : String?
    var base64_content_unsgin : String?

    var un_sgin_xml_hash : String?
    var sgin_xml_hash : String?
    var signing_time : String?
    var signature : String?
    var signedPropertiesHash : String?
    var x509_signature : String?
    var x509_public_key : String?
    var l10n_sa_uuid:String?
    var l10n_sa_chain_index:Int?
    var qr_code_value:String?
    var is_sync:Bool?
    var certificate_str:String?
    var dbClass:database_class?

    override init() {
        dbClass = database_class(connect: .database)
    }
    
    init(from tlvModel: InvoiceTlvModel,_ order:pos_order_class,_ pih:String, _ qrValue:String,_ sginXmlContent:String,_ sgin_xml_hash:String,signedPropertiesHash:String,base64_content_unsgin:String,signing_time:String){
        super.init()
        certificate_str = SharedManager.shared.posConfig().binarySecurityToken
        order_id = order.id
        order_uid = order.uid
        self.pih = pih
        if let data = sginXmlContent.replacingOccurrences(of: "#QR_CODE_TLV#", with: qrValue).data(using: .utf8) {
            base64_content = data.base64EncodedString()
        } else {
            base64_content = sginXmlContent
        }
        self.signedPropertiesHash = signedPropertiesHash
        un_sgin_xml_hash = tlvModel.xmlInvoice
        self.sgin_xml_hash = sgin_xml_hash
        signature = tlvModel.signature
        x509_signature = tlvModel.x509Signature?.base64EncodedString()
        x509_public_key = tlvModel.x509PublicKey?.base64EncodedString()
        l10n_sa_uuid = order.l10n_sa_uuid
        l10n_sa_chain_index = order.l10n_sa_chain_index
        qr_code_value = qrValue
        is_sync =  false
        self.signing_time = signing_time
        self.base64_content_unsgin = base64_content_unsgin.toBase64()
        if SharedManager.shared.phase2InvoiceOffline ?? false {
            self.is_sync = order.is_sync
        }
        dbClass = database_class(table_name: "pos_e_invoice", dictionary: self.toDictionary(),id: id,id_key:"id",connect: .database)

    }
    init(fromDictionary dictionary: [String:Any]){
        super.init()
        
        id = dictionary["id"] as? Int ?? 0
        order_id = dictionary["order_id"] as? Int ?? 0
        order_uid = dictionary["order_uid"] as? String ?? ""
        pih = dictionary["pih"] as? String ?? ""
        base64_content = dictionary["base64_content"] as? String ?? ""
        base64_content_unsgin = dictionary["base64_content_unsgin"] as? String ?? ""

        un_sgin_xml_hash = dictionary["un_sgin_xml_hash"] as? String ?? ""
        sgin_xml_hash = dictionary["sgin_xml_hash"] as? String ?? ""

        signature = dictionary["signature"] as? String ?? ""
        x509_signature = dictionary["x509_signature"] as? String ?? ""
        x509_public_key = dictionary["x509_public_key"] as? String ?? ""
        l10n_sa_uuid = dictionary["l10n_sa_uuid"] as? String ?? ""
        l10n_sa_chain_index = dictionary["l10n_sa_chain_index"] as? Int ?? 1
        qr_code_value = dictionary["qr_code_value"] as? String ?? ""
        is_sync = dictionary["is_sync"] as? Bool ?? false
        certificate_str = dictionary["certificate_str"] as? String ?? ""
        signedPropertiesHash = dictionary["signedPropertiesHash"] as? String ?? ""
        signing_time = dictionary["signing_time"] as? String ?? ""

        dbClass = database_class(table_name: "pos_e_invoice", dictionary: self.toDictionary(),id: id,id_key:"id",connect: .database)
    }
    
    
    func toDictionary() -> [String:Any]
    {
        var dictionary:[String:Any] = [:]
        
        dictionary["id"] = id
        dictionary["order_id"] = order_id
        dictionary["order_uid"] = order_uid
        dictionary["pih"] = pih
        dictionary["un_sgin_xml_hash"] = un_sgin_xml_hash
        dictionary["sgin_xml_hash"] = sgin_xml_hash
        dictionary["signature"] = signature ?? ""
        dictionary["x509_signature"] = x509_signature ?? ""
        dictionary["x509_public_key"] = x509_public_key ?? ""
        dictionary["l10n_sa_uuid"] = l10n_sa_uuid ?? ""
        dictionary["l10n_sa_chain_index"] = l10n_sa_chain_index ?? ""
        dictionary["qr_code_value"] = qr_code_value ?? ""
        dictionary["is_sync"] = is_sync ?? ""
        dictionary["base64_content"] = base64_content ?? ""
        dictionary["certificate_str"] = certificate_str ?? ""
        dictionary["signedPropertiesHash"] = signedPropertiesHash ?? ""
        dictionary["base64_content_unsgin"] = base64_content_unsgin ?? ""
        dictionary["signing_time"] = signing_time ?? ""

        return dictionary
    }
    
    
    
    func save()
    {
        dbClass?.dictionary = self.toDictionary()
//        dbClass?.id = self.id
//        dbClass?.insertId = false
        
        self.id =  dbClass!.save()
        
        
    }
    static func getCountOrderLessThan(_ hour:Int = 12) -> Int{
        let sql = """
SELECT *
FROM pos_e_invoice
WHERE is_sync = 0 and updated_at  <= datetime('now', '-\(hour) hours');
"""
        let count = database_class(connect: .database).get_count(sql: sql)
        
        return count

    }
    static func getBy(_ order_uid:String ) -> pos_e_invoice_class?{
        let sql = """
SELECT *
FROM pos_e_invoice
WHERE order_uid = '\(order_uid)';
"""
        if let rowDic = database_class(connect: .database).get_row(sql: sql){
            
            return pos_e_invoice_class(fromDictionary: rowDic)
        }
        return nil

    }
   
    
}



