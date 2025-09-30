//
//  MemberShipVC.swift
//  pos
//
//  Created by M-Wageh on 26/02/2023.
//  Copyright © 2023 khaled. All rights reserved.
//

import UIKit
import WebKit

class MemberShipVC: UIViewController {
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var rightDetailsView: UIView!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var printBtn: KButton!
    @IBOutlet weak var payBtn: KButton!
    @IBOutlet weak var badgePrinterLbl: KLabel!
    @IBOutlet weak var emptyView: UIView!
    
    @IBOutlet weak var dateSearchBtn: UIButton!
    @IBOutlet weak var searchTF: kTextField!
    @IBOutlet weak var searchBtn: KButton!
    
    var memberShipVM:MemberShipVM?
    var calendar: calendarVC?
    var order_print:orderPrintBuilderClass?
    var html_temp:String?
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTable()
        self.resetViewUI()

        self.initalState()
        DispatchQueue.main.async {
            self.changeDateUI()
        }
    }
    func resetViewUI(){
        searchTF.placeholder = "Search by name,phone number....".arabic("البحث باسم او رقم جوال .......")
        dateSearchBtn.setTitle(memberShipVM?.getDateSearch() ?? "Select date".arabic("اختر التاريخ"), for: .normal)
        self.rightDetailsView.isHidden = true

    }
   
    //MARK: - inital State Lines List  screen
    func initalState(){
        self.memberShipVM?.updateLoadingStatusClosure = { (state) in
           
            switch state {
            case .empty:
                DispatchQueue.main.async {
                    loadingClass.hide(view:self.view)
                    self.emptyView.isHidden = false
                }
                return
            case .error (let message):
                DispatchQueue.main.async {
                    loadingClass.hide(view:self.view)
                    messages.showAlert(message)
                }
                return
            case .loading:
                DispatchQueue.main.async {
                    loadingClass.show(view: self.view)
                }
                return
            case .searchSuccess:
                DispatchQueue.main.async {
                    self.emptyView.isHidden = (self.memberShipVM?.getCountItems() ?? 0)  > 0
                    self.table.reloadData()
                    loadingClass.hide(view:self.view)
                }
                return
            case .detailsSuccess(let detailsOrder):
                DispatchQueue.main.async {
                    self.payBtn.isHidden = detailsOrder.is_closed
                    self.loadSeletedOrder(orderSelected: detailsOrder)
                    self.rightDetailsView.isHidden = false
                    loadingClass.hide(view:self.view)
                }
                return
            case .restView:
                DispatchQueue.main.async {
                    self.emptyView.isHidden = true
                    self.rightDetailsView.isHidden = true
                    loadingClass.hide(view:self.view)
                }
                return
            //changeDate
            case .changeDate:
                DispatchQueue.main.async {
                    self.changeDateUI()
                    self.emptyView.isHidden = true
                    loadingClass.hide(view:self.view)
                }
                return
            }
            
        }
    }
    
    
    
    @IBAction func tapOnSelectSearchDate(_ sender: UIButton) {
        guard let calendar = self.calendar else{return}
        self.present(calendar, animated: true, completion: nil)
    }
    
    
    @IBAction func tapOnSearchBtn(_ sender: KButton) {
        self.memberShipVM?.searchWith(self.searchTF.text ?? "")
    }
    
    
    @IBAction func tapOnPrinterLogo(_ sender: Any) {
          //  self.check_printer()
        var vc:UIViewController = PrinterErrorVC()
        if SharedManager.shared.appSetting().enable_support_multi_printer_brands{
            // vc = DevicesMangmentVC.createModule()
            if let segmentVC = MWSegmentRouter.createMWprinterMangerWithErrorPrinter() {
                vc = segmentVC
            }
        }
        vc.modalPresentationStyle = .formSheet
        vc.preferredContentSize = CGSize(width: 900, height: 700)

 //        vc.popoverPresentationController?.sourceView = sender as? UIView
        self.present(vc, animated: true, completion: nil)
        
     }
    
  
    
    @IBAction func tapOnMenuBtn(_ sender: UIButton) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.centerContainer?.open(.left, animated: true, completion: nil)
    }
    
   
    @IBAction func tapOnPrint(_ sender: KButton) {
        /*
        guard let order = self.orderSelected else {return}
        DispatchQueue.global(qos: .background).async {
            runner_print_class.runPrinterReceipt_image(  html: self.getPosHTML(false), openDeawer: false,row_type: .history)
        }
        let printer_status_vc = printer_status()
        printer_status_vc.modalPresentationStyle = .overCurrentContext
        self.present(printer_status_vc, animated: true) {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5), execute: {
                self.checkErrorPrinter()
            })

        }
         */
        
    }
    @IBAction func tapOnPay(_ sender: KButton) {
        
        openPayment()
       
    }
    func openPayment()
    {
        guard let activeSession = pos_session_class.getActiveSession() else{
            messages.showAlert("You must sart session first".arabic("يجب ان تبداء جلسه اولا"))
return
        }

        let storyboard = UIStoryboard(name: "payment", bundle: nil)
        if  let paymentVC = storyboard.instantiateViewController(withIdentifier: "paymentVc") as? paymentVc{
            paymentVC.completePayment = self.memberShipVM?.completePayment
            paymentVC.parent_vc = self
            paymentVC.clearHome = false
            paymentVC.orderVc!.order =  self.memberShipVM?.selectOrder
            paymentVC.orderVc!.order.session_id_local = activeSession.id
            paymentVC.viewDidLoad()
            paymentVC.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
            self.present(paymentVC, animated: true)
        }
    }
}

extension MemberShipVC:menu_left_delegate{
    func changeDateUI(){
        self.dismissCalenderView()
        dateSearchBtn.setTitle(memberShipVM?.getDateSearch() ?? "Select date".arabic("اختر التاريخ"), for: .normal)
        self.memberShipVM?.hitSearchMemberShip()
    }
    private func dismissCalenderView(){
        calendar?.dismiss(animated: true, completion: nil)
    }
    func btnPriceList(_ sender: Any)
    {
        
    }
}



extension MemberShipVC:UITableViewDelegate,UITableViewDataSource{

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
        return self.memberShipVM?.getCountItems() ?? 0
    }
    
   
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//         let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! invoicesListTableViewCell

        let cell = tableView.dequeueReusableCell(withIdentifier: "DriverOrderCell", for: indexPath) as! DriverOrderCell
         let tapGesture = UITapGestureRecognizer(target: self,
                                                 action: #selector(handleTapTableCell(recognizer:)))
         cell.contentView.tag = indexPath.row
         cell.contentView.isUserInteractionEnabled = true
         cell.contentView.addGestureRecognizer(tapGesture)

         cell.memberShipItem = self.memberShipVM?.getItem(at: indexPath.row)
         
         return cell
    }
   
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100//UITableView.automaticDimension
    }
 
    
  
    @objc func handleTapTableCell(recognizer:UITapGestureRecognizer){
        if let index = recognizer.view?.tag {
            self.memberShipVM?.didSelectItem(at: index)
        }
    }
    
}
extension MemberShipVC {
    
    func loadSeletedOrder(orderSelected:pos_order_class)
    {
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
