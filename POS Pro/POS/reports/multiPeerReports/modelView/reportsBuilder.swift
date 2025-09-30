//
//  reportsBuilder.swift
//  pos
//
//  Created by khaled on 03/02/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import UIKit

class reportsBuilder: NSObject {
    
    private var report:reportsList?
    private var businessDay:String?
    
    
    
    func requestReport(_report:reportsList,forDay:String) -> salesReportSummary?
    {
        var sessionsList = reportBuilderHelper.getSessionForDay(forDay)
        if sessionsList.count == 0
        {
            return nil
        }
        
        sessionsList.reverse()
        
        if _report == .salesReport || _report == .salesReportSummary
        {
            let rpt = getSalesReport(sessionsList )
            return rpt
        }
        
        return nil
    }
    
//    func build(_report:reportsList,forDay:String) -> String
//    {
//
//        report = _report
//        businessDay = forDay
//
//
//        let body:NSMutableString = NSMutableString()
////        body.append(openHtml())
//        //===================================================================
//        // build report
//
//        if report == .salesReport
//        {
//            let rpt = requestReport(_report: _report, forDay: forDay) //getSalesReport(sessionsList )
//
////            let sum_rpt = sumReports([rpt,rpt,rpt,rpt])
//
//            let html = printSalesReport(rpt!,isSummary: true)
//            body.append( html)
//        }
//
//        //===================================================================
////        body.append(closeHtml())
//
//        return String(body)
//
//
//
//    }
//
    
    
 
    
    func get_sessions_ids(_ sessionsList:[pos_session_class]) -> String
    {
        
        
        var ids = ""
        
        for item in sessionsList {
            ids =  ids + "," + String( item.id)
        }
        ids.removeFirst()
        
        return ids
    }
    
    //    func buildSalesReportSummary(_ sessionsList:[pos_session_class] ) -> (html:String,report:salesReportSummary)
    //    {
    //        let table:NSMutableString = NSMutableString()
    //
    //        let frist_session = sessionsList.first
    //        let last_session = sessionsList.last
    //
    //        let dt = Date(strDate: frist_session!.start_session!, formate: baseClass.date_fromate_satnder,UTC: true)
    //        let startDate = dt.toString(dateFormat: baseClass.date_fromate_satnder_12h, UTC: false)
    //
    //        var EndDate = ""
    //        if !last_session!.end_session!.isEmpty
    //        {
    //            let dt_l = Date(strDate: last_session!.end_session!, formate: baseClass.date_fromate_satnder,UTC: true)
    //              EndDate = dt_l.toString(dateFormat: baseClass.date_fromate_satnder_12h, UTC: false)
    //        }
    //
    //        let  posName = pos_config_class.getPos(posID: frist_session!.posID!).name!
    //
    //        let rptSummary = salesReportSummary(_startDate:startDate, _endDate: EndDate,_posID: frist_session!.posID!, _posName: posName)
    //
    //        var rptHtml = reportsHtml(rptSummary)
    //         table.append(rptHtml.reportInfo())
    //
    //        // ===========================================================================
    //        // All Sales summary
    //
    //        let sesstion_ids = get_sessions_ids(sessionsList)
    //        let totalOrderTax = reportsData.getTotal_order(sesstion_ids: sesstion_ids)
    //        let total = reportsData.get_Statistics(  sesstion_ids: sesstion_ids)
    //
    //
    //        for session in sessionsList
    //        {
    //            let  CN = res_users_class.get(id: session.cashierID)?.name ?? ""
    //
    //            let rptSession = salesReportSummary(_startDate:startDate, _endDate: EndDate,_posID: frist_session!.posID!, _posName: posName,_cashierID: session.cashierID,_cashierName: CN,_sessionID: session.id)
    //
    //            rptSession.ordersCount = reportsData.getOrderCount(session.id)
    //
    //            // ===========================================================================
    //            // get Total Statments
    //
    //            let v1 =   reportsData.getTotalStatment(session: session,rptSummary: rptSummary)
    //            rptSession.total_bankStatment = v1._total_bankStatment
    //            rptSession.total_bankStatment_summery = v1._total_bankStatment_summery
    //            rptSession.totalCash = v1._totalCash
    //            rptSession.allPayments = v1._allPayments
    //            // ===========================================================================
    //            // get Total deliveryType
    //
    //            let v2 = reportsData.getTotalOrderType_group_deliveryType(session: session,rptSummary: rptSummary)
    //            rptSession.total_deliveryType = v2._total_orderType
    //            rptSession.total_deliveryType_summery = v2._total_deliveryType_summery
    //
    //            let v3 = reportsData.getTotalOrderType_group_deliveryType_accountJournal(session: session,rptSummary: rptSummary)
    //            rptSession.total_deliveryType_accountJournal = v3._total_orderType_accountJournal
    //            rptSession.total_deliveryType_accountJournal_summery = v3._total_deliveryType_accountJournal_summery
    //            // ===========================================================================
    //            // set Balance
    //
    //            rptSession.startBalance = session.start_Balance
    //            rptSession.endBalance = session.end_Balance
    //            // ===========================================================================
    //            // get Total CashBox
    //
    //            let v4 = reportsData.cashBox(totalCash: rptSession.totalCash!, startBalance:( rptSession.startBalance ?? 0), cashbox_list: session.cashbox_list)
    //            rptSession.dif_total_cashbox_In = v4._dif_total_cashbox_In
    //            rptSession.dif_total_cashbox_out = v4._dif_total_cashbox_out
    //            rptSession.cash_difference = v4._cash_difference
    //            rptSession.totalCash = v4._total_cash
    //            // ===========================================================================
    //            // Sales summary
    //
    //            let totalOrderTax = reportsData.getTotal_order(sesstion_ids: String( session.id))
    //            let total = reportsData.get_Statistics(  sesstion_ids: String( session.id))
    //            // ===========================================================================
    //            // add session to report
    //
    //            rptSummary.subReports.append(rptSession)
    //            // ===========================================================================
    //            // print report
    //
    //            rptHtml = reportsHtml(rptSession)
    //            table.append(rptHtml.sessionInfo())
    //            table.append(rptHtml.openTable())
    //            table.append(rptHtml.addToTable(rptHtml.paymentMethod()))
    //            table.append(rptHtml.addToTable(rptHtml.totalDeliveryTypeAccountJournal()))
    //            table.append(rptHtml.addToTable(rptHtml.totalDeliveryType()))
    //            table.append(rptHtml.addToTable(rptHtml.totalCash()))
    //            table.append(rptHtml.addToTable(rptHtml.cashBox()))
    //            table.append( rptHtml.addToTable(rptHtml.total_order_tax_html(price_subtotal_incl:  totalOrderTax.price_subtotal_incl, price_subtotal: totalOrderTax.price_subtotal, amount_tax:  totalOrderTax.amount_tax )))
    //            table.append(rptHtml.addToTable( rptHtml.total_statistics_html(total_void: total.total_void, total_return: total.total_return, total_discount: total.total_discount ,total_delete: total.total_delete,total_reject:total.total_rejected)))
    //
    //
    //
    //            table.append( rptHtml.closeTable())
    //
    //        }
    //
    //        // ===========================================================================
    //        // print summary
    //
    //        rptHtml = reportsHtml(rptSummary)
    //        table.append(rptHtml.totalPaymentSummary())
    //        table.append(rptHtml.totalDeliveryTypeSummary())
    //        table.append(rptHtml.totalDeliveryTypeAccountJournalSummary())
    //
    //        // ===========================================================================
    //        // print All Sales summary
    //
    //        table.append(rptHtml.openTable())
    //        table.append( rptHtml.addToTable(rptHtml.total_order_tax_html(price_subtotal_incl:  totalOrderTax.price_subtotal_incl, price_subtotal: totalOrderTax.price_subtotal, amount_tax:  totalOrderTax.amount_tax )))
    //        table.append( rptHtml.closeTable())
    //
    //        table.append(rptHtml.openTable())
    //
    //        table.append( rptHtml.addToTable(rptHtml.total_statistics_html(total_void: total.total_void, total_return: total.total_return, total_discount: total.total_discount, total_delete: total.total_delete,total_reject: total.total_rejected)))
    //        table.append( rptHtml.closeTable())
    //
    //        return (String(table),rptSummary)
    //    }
    
    func getSalesReport(_ sessionsList:[pos_session_class] ) ->  salesReportSummary
    {
        
        let frist_session = sessionsList.first
        let last_session = sessionsList.last
        
        let dt = Date(strDate: frist_session!.start_session!, formate: baseClass.date_fromate_satnder,UTC: true)
        let startDate = dt.toString(dateFormat: baseClass.date_fromate_satnder_12h, UTC: false)
        
        var EndDate = ""
        if !last_session!.end_session!.isEmpty
        {
            let dt_l = Date(strDate: last_session!.end_session!, formate: baseClass.date_fromate_satnder,UTC: true)
            EndDate = dt_l.toString(dateFormat: baseClass.date_fromate_satnder_12h, UTC: false)
        }
        
        let  posName = pos_config_class.getPos(posID: frist_session!.posID!).name!
        
        let rptSummary = salesReportSummary(_startDate:startDate, _endDate: EndDate,_posID: frist_session!.posID!, _posName: posName,_sessionID: frist_session!.id)
        
        
        // ===========================================================================
        // All Sales summary
        
        let sesstion_ids = get_sessions_ids(sessionsList)
        let totalOrderTax = reportsData.getTotal_order(sesstion_ids: sesstion_ids)
        let total = reportsData.get_Statistics(  sesstion_ids: sesstion_ids)
        
        
        rptSummary.price_subtotal_incl = totalOrderTax.price_subtotal_incl
        rptSummary.price_subtotal = totalOrderTax.price_subtotal
        rptSummary.amount_tax = totalOrderTax.amount_tax
        
        rptSummary.total_void = total.total_void
        rptSummary.total_return = total.total_return
        rptSummary.total_discount = total.total_discount
        rptSummary.total_delete = total.total_delete
        rptSummary.total_rejected = total.total_rejected
        rptSummary.ordersCount = total.total_orders

        for session in sessionsList
        {
            let  CN = res_users_class.get(id: session.cashierID)?.name ?? ""
            
            let rptSession = salesReportSummary(_startDate:startDate, _endDate: EndDate,_posID: frist_session!.posID!, _posName: posName,_cashierID: session.cashierID,_cashierName: CN,_sessionID: session.id)
            
            rptSession.ordersCount = reportsData.getOrderCount(session.id)
            
            // ===========================================================================
            // get Total Statments
            
            let v1 =   reportsData.getTotalStatment(session: session,rptSummary: rptSummary)
            rptSession.total_bankStatment = v1._total_bankStatment
            rptSession.total_bankStatment_summery = v1._total_bankStatment_summery
            rptSession.totalCash = v1._totalCash
            rptSession.allPayments = v1._allPayments
            // ===========================================================================
            // get Total deliveryType
            
            let v2 = reportsData.getTotalOrderType_group_deliveryType(session: session,rptSummary: rptSummary)
            rptSession.total_deliveryType = v2._total_orderType
            rptSession.total_deliveryType_summery = v2._total_deliveryType_summery
            
            let v3 = reportsData.getTotalOrderType_group_deliveryType_accountJournal(session: session,rptSummary: rptSummary)
            rptSession.total_deliveryType_accountJournal = v3._total_orderType_accountJournal
            rptSession.total_deliveryType_accountJournal_summery = v3._total_deliveryType_accountJournal_summery
            // ===========================================================================
            // set Balance
            
            rptSession.startBalance = session.start_Balance
            rptSession.endBalance = session.end_Balance
            // ===========================================================================
            // get Total CashBox
            
            let v4 = reportsData.cashBox(totalCash: rptSession.totalCash, startBalance:( rptSession.startBalance ), cashbox_list: session.cashbox_list)
            rptSession.dif_total_cashbox_In = v4._dif_total_cashbox_In
            rptSession.dif_total_cashbox_out = v4._dif_total_cashbox_out
            rptSession.cash_difference = v4._cash_difference
            rptSession.totalCash = v4._total_cash
            // ===========================================================================
            // Sales summary
            
            let totalOrderTax_session = reportsData.getTotal_order(sesstion_ids: String( session.id))
            let total_session = reportsData.get_Statistics(  sesstion_ids: String( session.id))
            
            rptSession.price_subtotal_incl = totalOrderTax_session.price_subtotal_incl
            rptSession.price_subtotal = totalOrderTax_session.price_subtotal
            rptSession.amount_tax = totalOrderTax_session.amount_tax
            
            rptSession.total_void = total_session.total_void
            rptSession.total_return = total_session.total_return
            rptSession.total_discount = total_session.total_discount
            rptSession.total_delete = total_session.total_delete
            rptSession.total_rejected = total_session.total_rejected
            
            // ===========================================================================
            // add session to report
            
            rptSummary.subReports.append(rptSession)
            // ===========================================================================
            
        }
        
        
        return rptSummary
        
    }
    
    
    func printSalesReport(_ rptSummary:salesReportSummary,isSummary:Bool) -> String
    {
        let table:NSMutableString = NSMutableString()
        
        let rptHtmlMain = reportsHtml(rptSummary)

        table.append(rptHtmlMain.openHtml())
        table.append(rptHtmlMain.title(.salesReport))

 
        if isSummary
        {
            table.append(rptHtmlMain.reportInfoDate())

            
            
        }
        
        if !isSummary
        {
            
            for rptSession in rptSummary.subReports
            {
               let  rptHtml = reportsHtml(rptSession)
                
                table.append(rptHtml.reportInfo())
//                table.append(rptHtml.sessionInfo())
                table.append(rptHtml.openTable())
                table.append(rptHtml.addToTable(rptHtml.paymentMethod()))
//                table.append(rptHtml.addToTable(rptHtml.totalDeliveryTypeAccountJournal()))
//                table.append(rptHtml.addToTable(rptHtml.totalDeliveryType()))
//                table.append(rptHtml.addToTable(rptHtml.totalCash()))
//                table.append(rptHtml.addToTable(rptHtml.cashBox()))
//                table.append(rptHtml.addToTable(rptHtml.totalCashOnly()))
                table.append( rptHtml.addToTable(rptHtml.total_order_tax_html(price_subtotal_incl:  rptSession.price_subtotal_incl, price_subtotal: rptSession.price_subtotal, amount_tax:  rptSession.amount_tax )))
//                table.append(rptHtml.addToTable( rptHtml.total_statistics_html(total_void: rptSession.total_void, total_return: rptSession.total_return, total_discount: rptSession.total_discount ,total_delete: rptSession.total_delete,total_reject:rptSession.total_rejected)))
                
                table.append( rptHtml.closeTable())
            }
            
        }
        // ===========================================================================
        // print summary
        
         if isSummary
        {
            table.append("<div style=\"width: 80%;margin: auto;\">")
             table.append(rptHtmlMain.separator())

             table.append(rptHtmlMain.reportTotalTable(rptSummary))

           table.append(rptHtmlMain.titleTotal())
             
             table.append(rptHtmlMain.totalPaymentSummarySummary())
             table.append(rptHtmlMain.totalDeliveryTypeSummarySummary())
             table.append(rptHtmlMain.separator())

             table.append(  rptHtmlMain.total_order_tax_html(price_subtotal_incl:  rptSummary.price_subtotal_incl, price_subtotal: rptSummary.price_subtotal, amount_tax:  rptSummary.amount_tax ,hideTitle: true,withBorder: true))
             table.append(rptHtmlMain.separator())

         }
        else
        {
            table.append(rptHtmlMain.separator())
   
        
//        rptHtml = reportsHtml(rptSummary)
        
      
        table.append(rptHtmlMain.totalPaymentSummary())
    
        
//        table.append(rptHtmlMain.totalDeliveryTypeSummary())
//        table.append(rptHtmlMain.totalDeliveryTypeAccountJournalSummary())
        
        // ===========================================================================
        // print All Sales summary
        
        table.append(rptHtmlMain.openTable())
        table.append( rptHtmlMain.addToTable(rptHtmlMain.total_order_tax_html(price_subtotal_incl:  rptSummary.price_subtotal_incl, price_subtotal: rptSummary.price_subtotal, amount_tax:  rptSummary.amount_tax )))
        table.append( rptHtmlMain.closeTable())
        
//        table.append(rptHtmlMain.openTable())
//        table.append( rptHtmlMain.addToTable(rptHtmlMain.total_statistics_html(total_void: rptSummary.total_void, total_return: rptSummary.total_return, total_discount: rptSummary.total_discount, total_delete: rptSummary.total_delete,total_reject: rptSummary.total_rejected)))
//        table.append( rptHtmlMain.closeTable())
            
        }
        

        if isSummary
       {
           table.append("</div>")
          
       }
        table.append(rptHtmlMain.closeHtml())

        return String(table)
    }
    
    
    func sumReports(_ reports:[salesReportSummary]) -> salesReportSummary
    {
        
        let fristReport = reports.first
        let lastReport = reports.last
        let posNames = getPosNames(reports)
        
        let reportTotal = salesReportSummary(_startDate:fristReport!.startDate!, _endDate: lastReport!.endDate!,_posID:0, _posName: posNames,_sessionID: 0)
        
        
        for rpt in reports
        {
            reportTotal.price_subtotal_incl += rpt.price_subtotal_incl
            reportTotal.price_subtotal += rpt.price_subtotal
            reportTotal.amount_tax += rpt.amount_tax
            
            reportTotal.total_void += rpt.total_void
            reportTotal.total_return += rpt.total_return
            reportTotal.total_discount += rpt.total_discount
            reportTotal.total_delete += rpt.total_delete
            reportTotal.total_rejected += rpt.total_rejected
            
            for subRpt in rpt.subReports
            {
                
                reportTotal.ordersCount += subRpt.ordersCount
                
                // ===========================================================================
                // get Total Statments
                
                reportTotal.total_bankStatment = sumTotalStatment(reportTotal.total_bankStatment ,sub_total_bankStatment: subRpt.total_bankStatment)
                reportTotal.total_bankStatment_summery = sumTotalStatmentSummary(reportTotal.total_bankStatment_summery ,sub_total_bankStatment_summery: subRpt.total_bankStatment_summery)
                
                reportTotal.totalCash += subRpt.totalCash
                reportTotal.allPayments += subRpt.allPayments
                // ===========================================================================
                // get Total deliveryType
                
                reportTotal.total_deliveryType =   sumTotal_deliveryType(reportTotal.total_deliveryType, sub_total_deliveryType: subRpt.total_deliveryType)
                reportTotal.total_deliveryType_summery = sumTotal_deliveryType(reportTotal.total_deliveryType_summery, sub_total_deliveryType: subRpt.total_deliveryType_summery)
                //
                reportTotal.total_deliveryType_accountJournal = sumTotal_deliveryType(reportTotal.total_deliveryType_accountJournal, sub_total_deliveryType: subRpt.total_deliveryType_accountJournal)
                reportTotal.total_deliveryType_accountJournal_summery = sumTotal_deliveryType(reportTotal.total_deliveryType_accountJournal_summery, sub_total_deliveryType: subRpt.total_deliveryType_accountJournal_summery)
                // ===========================================================================
                // set Balance
                
                
                // ===========================================================================
                // get Total CashBox
                
                
            }
            
        }
        
        
        
        return reportTotal
        
    }
    
    
    func getPosNames(_ reports:[salesReportSummary]) -> String
    {
        let names:NSMutableString = NSMutableString()
        
        for rpt in reports
        {
            names.append(rpt.posName!)
            names.append(" ,")
        }
        
        return String(names)
        
    }
    
    func sumTotalStatment(_ _total_bankStatment:[String:[String:Any]] , sub_total_bankStatment:[String:[String:Any]]) ->  [String:[String:Any]]
    {
        
        var sum_total_bankStatment = _total_bankStatment
        
        for (key,value) in sub_total_bankStatment
        {
            
            let sub_map:[String:Any] = value
            let display_name = sub_map [ "display_name"] ?? ""
            let type = sub_map ["type"] ?? ""
            let sub_total:Double = sub_map ["total"] as? Double ?? 0
            let sub_count:Double = sub_map[ "count"] as? Double ?? 0
            
            var report_map = sum_total_bankStatment[key] ?? [:]
            var report_total:Double = report_map ["total"] as? Double ?? 0
            var report_count:Double = report_map[ "count"] as? Double ?? 0
            
            report_total += sub_total
            report_count += sub_count
            
            report_map["display_name"] = display_name
            report_map["type"] = type
            report_map["total"] = report_total
            report_map["count"] = report_count
            sum_total_bankStatment[key]  = report_map
            
        }
        
        
        return sum_total_bankStatment
        
    }
    
    func sumTotalStatmentSummary(_ _total_bankStatment_summery:  [String:Double], sub_total_bankStatment_summery:  [String:Double]  ) ->  [String:Double]
    {
        var sum_total_bankStatment_summery = _total_bankStatment_summery
        
        for (key,value) in sub_total_bankStatment_summery
        {
            
            var total_summary = sum_total_bankStatment_summery[key] ?? 0
            total_summary += value
            sum_total_bankStatment_summery[key] = total_summary
            
        }
        
        return sum_total_bankStatment_summery
    }
    
    
    func sumTotal_deliveryType(_ _total_deliveryType:[String:[String:Any]] , sub_total_deliveryType:[String:[String:Any]]) ->  [String:[String:Any]]
    {
        
        var sumTotal_deliveryType = _total_deliveryType
        
        for (key,value) in sub_total_deliveryType
        {
            
            let sub_map:[String:Any] = value
            let payment_method = sub_map [ "payment_method"] ?? ""
            let delivery_type = sub_map ["delivery_type"] ?? ""
            let sub_total:Double = sub_map ["total"] as? Double ?? 0
            let sub_count:Double = sub_map[ "count"] as? Double ?? 0
            
            var report_map = sumTotal_deliveryType[key] ?? [:]
            var report_total:Double = report_map ["total"] as? Double ?? 0
            var report_count:Double = report_map[ "count"] as? Double ?? 0
            
            report_total += sub_total
            report_count += sub_count
            
            report_map["payment_method"] = payment_method
            report_map["delivery_type"] = delivery_type
            report_map["total"] = report_total
            report_map["count"] = report_count
            sumTotal_deliveryType[key]  = report_map
            
        }
        
        
        return sumTotal_deliveryType
        
    }
    
}
