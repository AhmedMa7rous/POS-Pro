//
//  ViewAndPrintReportVC.swift
//  pos
//
//  Created by M-Wageh on 16/06/2021.
//  Copyright © 2021 khaled. All rights reserved.
//

import UIKit
import WebKit

class ViewAndPrintReportVC: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    var htmlReport:String!
    var router:ViewAndPrintReportVCRouter?
    override func viewDidLoad() {
        super.viewDidLoad()
        init_alert_notificationCenter()
        if htmlReport == "stock_report" {
            self.getSTock()
        }else{
            setWebView()
        }

    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        remove_alert_notificationCenter()
    }
    func setWebView(){
        webView.loadHTMLString(htmlReport, baseURL: Bundle.main.bundleURL)
        setupWebView()
    }
    func setupWebView()
    {
        webView.autoresizingMask =  [.flexibleWidth,.flexibleHeight,.flexibleTopMargin,.flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
        webView.contentMode = .scaleAspectFit
        webView.sizeToFit()
    }
    @IBAction func btnReturn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func btnPrint(_ sender: Any) {
        DispatchQueue.global(qos: .background).async {
            runner_print_class.runPrinterReceipt_image(  html: self.htmlReport, openDeawer: false)
        }
        let printer_status_vc = printer_status()
        printer_status_vc.modalPresentationStyle = .overCurrentContext
        self.present(printer_status_vc, animated: true, completion: nil)
    }
    func init_alert_notificationCenter()
    {
         
        NotificationCenter.default.addObserver(self, selector: #selector( showBanner(notification:)), name: Notification.Name("show_aleart"), object: nil)
 
    }
    
    func remove_alert_notificationCenter() {
         NotificationCenter.default.removeObserver(self, name: Notification.Name("show_aleart"), object: nil)
        
    }
    @objc func showBanner(notification: Notification){
        DispatchQueue.main.async {
            let obj:notifications_messages_class = notification.object as! notifications_messages_class

        SharedManager.shared.initalBannerNotification(title: obj.title ,
                                                      message: obj.message,
                                                      success: obj.success, icon_name: obj.icon_name)
        SharedManager.shared.banner?.dismissesOnTap = true
        SharedManager.shared.banner?.show(duration: 3.0)
        }
       
    }
}
extension ViewAndPrintReportVC{
    func getSTock()
    {
        let con = api()
        let pos = SharedManager.shared.posConfig()
        if pos.stock_location_id  != nil
        {
            con.userCash = .stopCash
            con.get_stock_by_location(loc_id:pos.stock_location_id!) { (result) in
                if (result.success)
                {
                    let stocks = result.response?["result"] as? [String:[String:Any]] ?? [:]
                    var rows:String = ""
                    for (code,value) in stocks
                    {
                        let name = value["name"] as? String ?? ""
                        var qty_available = value["qty_available"] as? String ?? ""
                        qty_available = qty_available.toDouble()?.rounded_formated_str()   ?? ""
                        let product_uom = value["product_uom"] as? String ?? ""
                        rows = rows + "<tr>" + "<td>" + code + "</td>" + "<td>" + name + "</td>" + "<td style=\"text-align:right\" >" + qty_available + "</td>" + "<td>" + product_uom + "</td></tr>"
                    }
                    self.loadReport(rows: rows)
                }else
                {
                    printer_message_class.show("Check your internet connection.", vc: self)
                }
            }
        }
    }
    
    func loadReport(rows:String)
    {
        var html = baseClass.get_file_html(filename: "stock",showCopyRight: true)
        html = printOrder_setHeader(html: html)
        html = html.replacingOccurrences(of: "#rows", with: rows)
        html = html.replacingOccurrences(of: "#font", with: app_font_name_printer + "-Regular")
        self.htmlReport = html
        setWebView()
    }
    
    func printOrder_setHeader(html: String) -> String {
        let rows_header:NSMutableString = NSMutableString()
        let pos = SharedManager.shared.posConfig()
        let date = Date().toString(dateFormat: baseClass.date_fromate_satnder_12h, UTC: false)
        rows_header.append(" <tr><td>"+"POS Name".arabic("نقطة البيع")+"</td><td>: </td><td> \(pos.name!)</td></tr>")
        rows_header.append(" <tr><td>"+"Date".arabic("التاريخ")+"</td><td>: </td><td> \(date )</td></tr>")
        return html.replacingOccurrences(of: "#rows_header", with: String(rows_header))
    }
}
class ViewAndPrintReportVCRouter{
    weak var viewController: ViewAndPrintReportVC?
    static func createModule(htmlReport:String) -> ViewAndPrintReportVC {
        let vc:ViewAndPrintReportVC = ViewAndPrintReportVC()
        let router = ViewAndPrintReportVCRouter()
        vc.htmlReport = htmlReport
        router.viewController = vc
    return vc
    }
}
