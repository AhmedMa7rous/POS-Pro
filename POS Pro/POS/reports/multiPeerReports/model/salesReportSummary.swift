//
//  salesReportData.swift
//  pos
//
//  Created by khaled on 02/02/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import UIKit

class salesReportSummary: NSObject {
 
    
    init(
        _startDate:String,
        _endDate:String,
        _posID:Int,
        _posName:String,
        _cashierID:Int? = nil,
        _cashierName:String? = nil,
        _sessionID:Int
    ) {
        
         
         startDate = _startDate
         endDate = _endDate
         posName = _posName
         posID = _posID
        
        cashierID = _cashierID
        cashierName = _cashierName
        
        let dt = Date(strDate: startDate!, formate: baseClass.date_fromate_satnder_12h,UTC: true)
        businessDate = dt.toString(dateFormat: "dd/MM/yyyy", UTC: false)
        
        sessionID = _sessionID
    }
    
    var subReports:[salesReportSummary] = []

    var sessionID:Int?
    var posID:Int?
    var posName:String?
    var startDate:String?
    var endDate:String?
    var businessDate:String?
    
    var ordersCount:Int = 0
    
    var cashierID:Int?
    var cashierName:String?
 
    var total_bankStatment:[String:[String:Any]] = [:]
    var total_bankStatment_summery:  [String:Double] = [:]
 
    var total_deliveryType:[String:[String:Any]] = [:]
    var total_deliveryType_summery: [String:[String:Any]] = [:]
    
    var total_deliveryType_accountJournal:[String:[String:Any]] = [:]
    var total_deliveryType_accountJournal_summery: [String:[String:Any]] = [:]
    
    
    var totalCash: Double = 0
    var allPayments: Double = 0
     
 

    var startBalance : Double = 0
    var endBalance : Double = 0
    var differenceBalance : Double = 0

    
    var dif_total_cashbox_In:Double = 0
    var dif_total_cashbox_out:Double = 0
    var cash_difference:Double = 0

    
    var  price_subtotal_incl:Double = 0
    var price_subtotal:Double = 0
    var amount_tax:Double = 0
    
    
    var total_void:Double = 0
    var total_return:Double = 0
    var total_discount:Double = 0
    var total_delete:Double = 0
    var total_rejected:Double = 0
  
 
    
    init(fromDictionary dictionary: [String:Any]){
        super.init()

        sessionID = dictionary["sessionID"] as? Int ?? 0
        posID = dictionary["posID"] as? Int ?? 0
        ordersCount = dictionary["ordersCount"] as? Int ?? 0

        

        posName = dictionary["posName"] as? String ?? ""
        startDate = dictionary["startDate"] as? String ?? ""
        endDate = dictionary["endDate"] as? String ?? ""
        businessDate = dictionary["businessDate"] as? String ?? ""

        cashierID  = dictionary["cashierID"] as? Int ?? 0
        cashierName  = dictionary["cashierName"] as? String ?? ""
        total_bankStatment  = dictionary["total_bankStatment"] as? [String:[String:Any]]  ?? [:]
        total_bankStatment_summery  = dictionary["total_bankStatment_summery"] as? [String:Double] ?? [:]
        total_deliveryType  = dictionary["total_deliveryType"] as? [String:[String:Any]] ?? [:]
        total_deliveryType_summery  = dictionary["total_deliveryType_summery"] as? [String:[String:Any]] ?? [:]
        total_deliveryType_accountJournal  = dictionary["total_deliveryType_accountJournal"] as? [String:[String:Any]] ?? [:]
        total_deliveryType_accountJournal_summery  = dictionary["total_deliveryType_accountJournal_summery"] as? [String:[String:Any]] ?? [:]
        totalCash  = dictionary["totalCash"] as? Double ?? 0
        allPayments  = dictionary["allPayments"] as? Double ?? 0
        startBalance  = dictionary["startBalance"] as? Double ?? 0
        endBalance  = dictionary["endBalance"] as? Double ?? 0
        differenceBalance  = dictionary["differenceBalance"] as? Double ?? 0
        dif_total_cashbox_In  = dictionary["dif_total_cashbox_In"] as? Double ?? 0
        dif_total_cashbox_out  = dictionary["dif_total_cashbox_out"] as? Double ?? 0
        cash_difference  = dictionary["cash_difference"] as? Double ?? 0
        price_subtotal_incl  = dictionary["price_subtotal_incl"] as? Double ?? 0
        price_subtotal  = dictionary["price_subtotal"] as? Double ?? 0
        amount_tax  = dictionary["amount_tax"] as? Double ?? 0
        total_void  = dictionary["total_void"] as? Double ?? 0
        total_return  = dictionary["total_return"] as? Double ?? 0
        total_discount  = dictionary["total_discount"] as? Double ?? 0
        total_delete  = dictionary["total_delete"] as? Double ?? 0
        total_rejected  = dictionary["total_rejected"] as? Double ?? 0
       
        
        let   list_rpt =  dictionary["subReports"] as? [[String:Any]]  ?? []
        for rpt in list_rpt {
            subReports.append(salesReportSummary(fromDictionary: rpt))
        }

        
    }


    func toDictionary() -> [String:Any]
    {
        var dictionary:[String:Any] = [:]


        dictionary["sessionID"] = sessionID
        dictionary["posID"] = posID
        dictionary["posName"] = posName
        dictionary["startDate"] = startDate
        dictionary["endDate"] = endDate
        dictionary["businessDate"] = businessDate
 
        dictionary["ordersCount"] = ordersCount
        dictionary["cashierID"] = cashierID
        dictionary["cashierName"] = cashierName
        dictionary["total_bankStatment"] = total_bankStatment
        dictionary["total_bankStatment_summery"] = total_bankStatment_summery
        dictionary["total_deliveryType"] = total_deliveryType
        dictionary["total_deliveryType_summery"] = total_deliveryType_summery
        dictionary["total_deliveryType_accountJournal"] = total_deliveryType_accountJournal
        dictionary["total_deliveryType_accountJournal_summery"] = total_deliveryType_accountJournal_summery
        dictionary["totalCash"] = totalCash
        dictionary["allPayments"] = allPayments
        dictionary["endBalance"] = endBalance
        dictionary["differenceBalance"] = differenceBalance
        dictionary["dif_total_cashbox_In"] = dif_total_cashbox_In
        dictionary["dif_total_cashbox_out"] = dif_total_cashbox_out
        dictionary["cash_difference"] = cash_difference
        dictionary["price_subtotal_incl"] = price_subtotal_incl
        dictionary["price_subtotal"] = price_subtotal
        dictionary["amount_tax"] = amount_tax
        dictionary["total_void"] = total_void
        dictionary["total_return"] = total_return
        dictionary["total_discount"] = total_discount
        dictionary["total_delete"] = total_delete
        dictionary["total_rejected"] = total_rejected
 
        var rpt_dictionary:[[String:Any]] = []

        for rpt in subReports
        {
            rpt_dictionary.append(rpt.toDictionary())
        }

        dictionary["subReports"] = rpt_dictionary


        return dictionary
    }

    
    
}
