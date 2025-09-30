//
//  ReturnOrderByUIDVC.swift
//  pos
//
//  Created by M-Wageh on 04/09/2023.
//  Copyright © 2023 khaled. All rights reserved.
//

import UIKit
import WebKit

class ReturnOrderByUIDVC: UIViewController {
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var rightDetailsView: UIView!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var returnBtn: KButton!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var searchTF: kTextField!
    @IBOutlet weak var searchBtn: KButton!
    var orderList:[pos_order_class] = []
    var orderSelected:pos_order_class?
    var order_print:orderPrintBuilderClass!
    var html_temp = ""
    var returnorder =  return_orders()

    override func viewDidLoad() {
        super.viewDidLoad()
        if !SharedManager.shared.appSetting().enable_work_with_bill_uid_default{
            self.searchTF.text = "Order-"
        }
        setupTable()
        restVC()
        self.emptyView.isHidden =  self.orderList.count > 0
    }
    func restVC()
    {
        self.rightDetailsView.isHidden = true
        self.orderSelected = nil
        orderList.removeAll()
        self.table.reloadData()
    }
    func get_sub_orders() -> [pos_order_class]
    {
        guard let orderSelected = self.orderSelected else {return []}
        let option = ordersListOpetions()
        //        option.Closed = orderSelected!.is_closed
        option.void = false
        //        option.Sync = orderSelected!.is_sync
        option.parent_orderID = orderSelected.id
        option.LIMIT = Int(page_count)
        option.parent_product = true
        
        let list_sub = pos_order_helper_class.getOrders_status_sorted(options: option)
        
        return list_sub
    }
    func searchWith( _ name:String){
        restVC()
        if name.isEmpty{
            self.emptyView.isHidden = false
           return
        }
        DispatchQueue.main.async {
            loadingClass.show(view: self.view)
        }
        let option = ordersListOpetions()
        option.parent_product = true
        if SharedManager.shared.appSetting().enable_work_with_bill_uid_default{
            option.bill_uid = name
        }else{
            option.name = name
        }
        option.Closed = true
        let list = pos_order_helper_class.getOrders_status_sorted_for_search(options: option)
        if list.count > 0
        {
            self.orderList.append(contentsOf: list)
        }
        
        self.table.reloadData()
        DispatchQueue.main.async {
            self.emptyView.isHidden =  self.orderList.count > 0
            loadingClass.hide(view:self.view)
        }
    }
    func didSelectItem(at index:Int){
        self.view.endEditing(true)
        DispatchQueue.main.async {
            loadingClass.show(view: self.view)
        }
        self.orderSelected = self.orderList[index]
        DispatchQueue.main.async {
            self.loadSeletedOrder()
            self.rightDetailsView.isHidden = false
            loadingClass.hide(view:self.view)
        }

    }
    func getItem(at index:Int)->pos_order_class?{
        return self.orderList[index]
    }
    func getCountItems()->Int{
        return self.orderList.count
    }
    
    
    @IBAction func tapOnSearchBtn(_ sender: KButton) {
        self.searchWith(self.searchTF.text ?? "")
    }
    
    
  
    
    @IBAction func tapOnMenuBtn(_ sender: UIButton) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.centerContainer?.open(.left, animated: true, completion: nil)
    }
    
    @IBAction func tapOnReturn(_ sender: KButton) {
        let list_sub =   self.get_sub_orders()
        self.orderSelected?.sub_orders = list_sub
        if self.orderSelected?.able_to_return() == true
        {
            messages.showAlert("This order already returned .".arabic("تم استرجاع الطلب مسبقا"))
            return
            
        } else {
            
            var message = "Are you sure to return this invoice ?"
           
            let bankStatement = self.orderSelected?.get_bankStatement()
            
            if (bankStatement?.count ?? 1) > 1
            {
                
                if (self.orderSelected?.sub_orders.count ?? 0) > 0
                {
                    messages.showAlert("This order already returned .")
                    return
                    
                }
                
               // message = "This order have multi payment method , All order will return ?"
            }
        
            let alert = UIAlertController(title: "Return", message: message, preferredStyle: .alert)
            
            
            
            alert.addAction(UIAlertAction(title: "Yes" , style: .default, handler: { (action) in
                
                self.show_return_reason()
                
            }))
            
            
            
            alert.addAction(UIAlertAction(title: "NO", style: .cancel, handler: { (action) in
                
            }))
            
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    func show_return_reason()
    {
        
        let arr: [[String:Any]] =  pos_return_reason_class.getAll()
        if arr.count == 0
        {
            self.showOrderReturn(return_reason_id: nil)
            
            return
        }
        
        
        let list = options_listVC()
        list.modalPresentationStyle = .formSheet
        //        list.modalTransitionStyle = .crossDissolve
        
        list.preferredContentSize = CGSize.init(width: 300, height: 300)
        
        list.title = "Return reason".arabic("سبب المرتجع")
        
        for item in arr
        {
            var dic = item
            let cls = pos_return_reason_class(fromDictionary: item)
            
            dic[options_listVC.title_prefex] = cls.display_name
            
            list.list_items.append(dic)
            
        }
        
        
        
        list.didSelect = { [weak self] data in
            let dic = data
            
            let cls = pos_return_reason_class(fromDictionary: dic)
            
            
            self!.showOrderReturn(return_reason_id: cls.id)
            
            
            
        }
        
        
        list.clear = {
            
        }
        
        
        self.present(list, animated: true, completion: nil)
//        list.btn_clear.isHidden = true
        list.hideClearBtnFlag = true
        
    }
    func showOrderReturn(return_reason_id:Int?)
    {
        guard  let return_order = orderSelected else {return}
        
        let isNeedChoseBank = SharedManager.shared.appSetting().enable_chosse_account_journal_for_return_order
       
            var bankStatement = orderSelected?.get_bankStatement() ?? []
            
            
            
            returnorder =  return_orders()
            
            let option = ordersListOpetions()
            option.parent_product = true
            
            returnorder.parent_vc = self
            returnorder.order = return_order.copyOrder(option: option)
            returnorder.sub_orders =  orderSelected?.sub_orders ?? []
            returnorder.order!.return_reason_id = return_reason_id
            returnorder.order!.loyalty_earned_point  =  -1  * returnorder.order!.loyalty_earned_point
            returnorder.order!.loyalty_earned_amount = -1 *  returnorder.order!.loyalty_earned_amount

            returnorder.modalPresentationStyle = .overFullScreen
            
            returnorder.didSelectReturnOrder  = {  order in
                self.returnorder.updateKitchenStatus(for:order.pos_order_lines , in:return_order)
                if isNeedChoseBank {
                    self.openPayment(orderNeedToReturn:order,return_orders_vc:self.returnorder)
                }else{
                    self.returnorder.doReturn(order: order,list_bankStatement:bankStatement)
                    self.searchTF.text = ""
                    self.restVC()

                }
                
            }
        if isNeedChoseBank{
            self.present(returnorder, animated: true, completion: nil)

        }else{
            if (bankStatement.count) == 1
            {
                self.present(returnorder, animated: true, completion: nil)
                
            }
            else
            {
                let alert = UIAlertController(title: "Return", message: "Are you sure to return all items in this order ?", preferredStyle: .alert)
                
                
                
                alert.addAction(UIAlertAction(title: "Yes" , style: .default, handler: { (action) in
                    
                    self.returnorder.selectAll()
                    self.returnorder.returnOrder(parentVC: self)
                }))
                
                
                
                alert.addAction(UIAlertAction(title: "NO", style: .cancel, handler: { (action) in
                    
                }))
                
                self.present(alert, animated: true, completion: nil)
                
                
            }
        }
            
        
        
        
    }
    func openPayment(orderNeedToReturn:pos_order_class,return_orders_vc:return_orders)
    {
        var order = orderNeedToReturn.copyOrder()
        order.amount_paid = 0
        order.amount_total = order.amount_total * -1
        order.amount_return = 0
        let storyboard = UIStoryboard(name: "payment", bundle: nil)
        if  let paymentVC = storyboard.instantiateViewController(withIdentifier: "paymentVc") as? paymentVc{
            paymentVC.completeList = { bankStatement in
                if let bankStatement = bankStatement {
                    orderNeedToReturn.list_account_journal = bankStatement
                    //                orderNeedToReturn.amount_total = orderNeedToReturn.amount_total * -1
                    return_orders_vc.doReturn(order: orderNeedToReturn,list_bankStatement:[],checkListAccount: false)
                    self.searchTF.text = ""
                    self.restVC()
                }else{
                    return_orders_vc.dismiss(animated: false)
                }
                
            }
            paymentVC.showCashMethodOnly = true
            paymentVC.parent_vc = self
            paymentVC.clearHome = false
            paymentVC.orderVc!.order =  order
            paymentVC.pickup_user_id = SharedManager.shared.activeUser().id
            let activeSession = pos_session_class.getActiveSession()
            paymentVC.orderVc!.order.session_id_local = activeSession!.id
        
            paymentVC.viewDidLoad()
            paymentVC.modalPresentationStyle = .overFullScreen //or .overFullScreen for transparency
            return_orders_vc.present(paymentVC, animated: true)
        }
    }
}
extension ReturnOrderByUIDVC:UITableViewDelegate,UITableViewDataSource{

    func setupTable(){
        table.delegate = self
        table.dataSource = self
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 80
        table.register(UINib(nibName: "DriverOrderCell", bundle: nil), forCellReuseIdentifier: "DriverOrderCell")
    }

    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.getCountItems()
    }
    
   
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//         let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! invoicesListTableViewCell

        let cell = tableView.dequeueReusableCell(withIdentifier: "DriverOrderCell", for: indexPath) as! DriverOrderCell
         let tapGesture = UITapGestureRecognizer(target: self,
                                                 action: #selector(handleTapTableCell(recognizer:)))
         cell.contentView.tag = indexPath.row
         cell.contentView.isUserInteractionEnabled = true
         cell.contentView.addGestureRecognizer(tapGesture)

         cell.return_order_from_search = self.getItem(at: indexPath.row)
         
         return cell
    }
   
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100//UITableView.automaticDimension
    }
 
    
  
    @objc func handleTapTableCell(recognizer:UITapGestureRecognizer){
        if let index = recognizer.view?.tag {
            self.didSelectItem(at: index)
        }
    }
    
}
extension ReturnOrderByUIDVC {
    
    func loadSeletedOrder()
    {
        guard let orderSelected = self.orderSelected else {return}
        let list_sub:[pos_order_class]  = []
        orderSelected.sub_orders = list_sub
        if SharedManager.shared.appSetting().enable_support_multi_printer_brands {
            html_temp = orderSelected.getInvoiceHTML(.history, hideLogo: true)
        }else{
            order_print = orderPrintBuilderClass(withOrder: orderSelected,subOrder: list_sub)
            guard let order_print = self.order_print else {return}
            if AppDelegate.shared.load_kds == false
            {
                html_temp = getPosHTML()
            }
            else
            {
                order_print.hidePrice = true
                order_print.hideHeader = true
                order_print.hideFooter = true
                order_print.hideLogo = true
                order_print.hideRef = true
                order_print.hideVat = true
                order_print.hideCalories = true
                order_print.print_new_only = false
                order_print.for_kds = true
                order_print.isCopy = true
                order_print.showOrderReference = false
                
                
                let html = order_print.printOrder_html()
                
                html_temp = html
            }
        }
        webView.loadHTMLString(html_temp ?? "", baseURL: Bundle.main.bundleURL)
    }
    func getPosHTML(_ hideLogo:Bool = true) -> String{
        guard let order_print = self.order_print else {return ""}
        order_print.isCopy = true
        let setting = SharedManager.shared.appSetting()
        order_print.qr_print = true //setting.qr_enable
        order_print.qr_url = setting.qr_url
        order_print.hideLogo = hideLogo
        order_print.for_waiter = false
        order_print.showOrderReference = false
       
        return order_print.printOrder_html()
    }
}


extension ReturnOrderByUIDVC:menu_left_delegate{
    func btnPriceList(_ sender: Any) {
        
    }
}
