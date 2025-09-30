//
//  TableBillViewController.swift
//  pos
//
//  Created by DGTERA on 27/10/2024.
//  Copyright © 2024 khaled. All rights reserved.
//

import UIKit
import WebKit

class TableBillViewController: UIViewController, WKNavigationDelegate, UIPopoverPresentationControllerDelegate {
    
    //MARK: - Outlet Connections
    @IBOutlet weak var printButton: KButton!
    @IBOutlet weak var editOrderButton: KButton!
    @IBOutlet weak var changeUserButton: KButton!
    @IBOutlet weak var closeButton: KButton!
    @IBOutlet weak var orderBillView: UIView!
    @IBOutlet weak var orderDetailsView: UIView!
    @IBOutlet weak var orderNumberLabelHeader: UILabel!
    @IBOutlet weak var orderNumberLabel: UILabel!
    @IBOutlet weak var tableNumberLabelHeader: UILabel!
    @IBOutlet weak var tableNumberLabel: UILabel!
    @IBOutlet weak var responsibilityUserLabelHeader: UILabel!
    @IBOutlet weak var responsibilityUserLabel: UILabel!
    @IBOutlet weak var orderTotalLabelHeader: UILabel!
    @IBOutlet weak var orderTotalLabel: UILabel!
    @IBOutlet weak var orderTimeLabelHeader: UILabel!
    @IBOutlet weak var orderTimeLabel: UILabel!
    
    //MARK: - Properties
    var webView: WKWebView?
//    var order_print:orderPrintBuilderClass!
    var html_temp = ""
    var orderSelected:pos_order_class?
    var editSelectedOrder: ((Bool) -> Void)?
    var availableUsers = res_users_class.getAll_available()
    var inVoice: MWInvoiceComposer?
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpUI()
        DispatchQueue.main.async {
            self.init_notificationCenter()
            self.setupWebView()
            if let orderSelected = self.orderSelected {
                self.updateUI(for: orderSelected)
            }
            self.loadSeletedOrder()
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.remove_notificationCenter()
        webView = nil
        html_temp = ""
        orderSelected = nil
    }
    
    //MARK: - Action Connections
    @IBAction func printButtonTapped(_ sender: Any) {
            self.orderSelected?.creatCopyBillQueuePrinter(rowType.order_table,hideLogo: false)
            MWRunQueuePrinter.shared.startMWQueue()
        
    }
    
    @IBAction func editOrderButtonTapped(_ sender: Any) {
        dismiss(animated: true) {
            self.editSelectedOrder?(true)
        }
    }
    
    @IBAction func changeUserButtonTapped(_ sender: Any) {
        let optionsVC = OptionsListViewController()
        optionsVC.options = availableUsers
        optionsVC.modalPresentationStyle = .popover
        optionsVC.preferredContentSize = CGSize(width: 300, height: 400)
        
        optionsVC.onSelectOption = { [weak self] user in
            self?.orderSelected?.table_control_by_user_name = user["name"] as? String ?? ""
            self?.orderSelected?.table_control_by_user_id = user["id"] as? Int ?? 0
            self?.orderSelected?.save()
            self?.responsibilityUserLabel.text = user["name"] as? String ?? ""
        }
        
        if let popoverController = optionsVC.popoverPresentationController, let sender = sender as? UIButton {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
            popoverController.permittedArrowDirections = .down
            popoverController.delegate = self
        }
        
        present(optionsVC, animated: true, completion: nil)
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
    static func createModule(selected_order: pos_order_class) -> TableBillViewController {
        let vc = TableBillViewController()
        vc.orderSelected = selected_order
        return vc
    }
    
    //MARK: - Services Functions
    func setUpUI() {
        editOrderButton.setTitle("View Order".arabic("استعراض الطلب"), for: .normal)
        changeUserButton.setTitle("Change User".arabic("تغيير المسؤول"), for: .normal)
        closeButton.setTitle("Close".arabic("إغلاق"), for: .normal)
        orderNumberLabelHeader.text = "Order Number".arabic("رقم الطلب")
        orderTimeLabelHeader.text = "Order Time".arabic("وقت الطلب")
        responsibilityUserLabelHeader.text = "Responsible User".arabic("مسؤول الطاولة")
        tableNumberLabelHeader.text = "Table Number".arabic("رقم الطاولة")
        orderTotalLabelHeader.text = "Total Price".arabic("إجمالي الطلب")
        let casher = SharedManager.shared.activeUser()
        let acccessChangeUser  = rules.access_rule(user_id:casher.id,key:rule_key.change_responsible_table)
        self.changeUserButton.isHidden = true //!acccessChangeUser
    }
    
    func updateUI(for order: pos_order_class) {
        
         let dateCreate = Date(strDate: order.create_date!, formate: baseClass.date_formate_database,UTC: true )
        let timeAgoSinceDate = date_base_class.timeAgoSinceDate(dateCreate, currentDate: Date(), numericDates: true)

            orderTimeLabel.text = timeAgoSinceDate
        if let userName = order.table_control_by_user_name {
            responsibilityUserLabel.text = userName
        } else {
            responsibilityUserLabel.text = order.create_user_name
        }
        orderNumberLabel.text = String(order.sequence_number)
        tableNumberLabel.text = order.table_name
        orderTotalLabel.text = String(order.amount_total)
    }
    
    
    func setupWebView()
    {
        
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame:orderBillView.bounds, configuration: webConfiguration)
        webView?.navigationDelegate = self
        webView?.frame.origin.x = -10
        webView?.autoresizingMask =  [.flexibleWidth,.flexibleHeight,.flexibleTopMargin,.flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
        if let webView = webView {
            orderBillView?.addSubview(webView)
            orderBillView.bringSubviewToFront(printButton)
        }
        webView?.sizeToFit()
    }
    
    func loadSeletedOrder() {
        DispatchQueue.main.async {
            self.inVoice = MWInvoiceComposer(order: self.orderSelected, printerName:"",fileType: .history)
            self.inVoice?.setOptionForTableView()
            self.html_temp = self.inVoice?.renderInvoice() ?? ""
            self.webView?.loadHTMLString(self.html_temp, baseURL: Bundle.main.bundleURL)
        }
    }
    
    func get_sub_orders() -> [pos_order_class] {
        let option = ordersListOpetions()
        option.void = false
        option.parent_orderID = orderSelected!.id
        option.LIMIT = Int(page_count)
        option.parent_product = true
        
        let list_sub = pos_order_helper_class.getOrders_status_sorted(options: option)
        
        return list_sub
    }
    @objc func poll_update_order(notification: Notification) {
        let option = ordersListOpetions()
        option.parent_product = true
        if let uid =  self.orderSelected?.uid {
            self.orderSelected = pos_order_class.get(uid:uid,options_order:option  )
            if  (self.orderSelected?.is_closed ?? false) ||  (self.orderSelected?.is_void ?? false)  ||  (self.orderSelected?.is_sync ?? false){
                DispatchQueue.main.async {
                    self.dismiss(animated: true)
                }
                return
            }
//            self.orderSelected?.reloadOrder(with:option )
            self.orderSelected?.calcAll()
            self.inVoice = MWInvoiceComposer(order: self.orderSelected, printerName:"",fileType: .history)
            self.inVoice?.setOptionForTableView()
            self.html_temp = self.inVoice?.renderInvoice() ?? ""
            DispatchQueue.main.async {
                self.webView?.loadHTMLString(self.html_temp, baseURL: Bundle.main.bundleURL)
            }
        }
    }
    @objc func poll_remove_order(notification: Notification) {
        
        DispatchQueue.main.async {
            self.dismiss(animated: true)
        }
    }
   
}
extension TableBillViewController{
    func init_notificationCenter()
    {
        
        NotificationCenter.default.addObserver(self, selector: #selector( poll_update_order(notification:)), name: Notification.Name("poll_update_order"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector( poll_remove_order(notification:)), name: Notification.Name("poll_remove_order"), object: nil)
    }
    
    func remove_notificationCenter() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("poll_update_order"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("poll_remove_order"), object: nil)
    }
}
