//
//  paymentSuccessfullMessage.swift
//  pos
//
//  Created by khaled on 9/30/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

class paymentSuccessfullMessage: printView ,printView_delegate {

    weak var delegate:paymentSuccessfullMessage_delegate?
    
    @IBOutlet weak var lblTotal: KLabel!
    @IBOutlet weak var btn_Cancel: KButton!
    @IBOutlet weak var indicator: UIActivityIndicatorView!

    
    var total:String?
    var otherPrinter:printersNetworkAvalibleClass? = printersNetworkAvalibleClass()
    var needToPrint:Bool = false
    var returnOrder:Bool = false

//    var order_image:UIImage?
 

     var timer = Timer()
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    
        total = nil
        otherPrinter = nil
//        order_image = nil
        timer.invalidate()
     
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseViewController.reAssignImage(mainView: self.view)

        if order!.amount_return == 0
        {
                  lblTotal.text = ""

        }
        else
        {
            lblTotal.text = total

        }
        
//        let data:[String:Any] = pos_order_builder_class.bulid_order_data(order: self.order!, for_pool: nil)

        self.delegatePrintView = self

        
//        indicator.startAnimating()
 
        btn_Cancel.isEnabled = true
        
//        let str = orderPrintFormaterClass(withOrder: order!, subOrder: [])
//        EposPrint.runPrinterReceipt(aString: str.printOrder(), openDeawer: true)
        
//        EposPrint.runPrinterReceipt(html: html, openDeawer: true)
        
        let time_sec:Double = Double(SharedManager.shared.appSetting().timePaymentSuccessfullMessage)
        
        timer = Timer.scheduledTimer(timeInterval:time_sec, target: self, selector: #selector(btnCancel), userInfo: nil, repeats: false)

//         self.perform(#selector(close), with: nil, afterDelay: 5)
        
//        self.view.backgroundColor = UIColor.red
       
        blurView()
        
        
//
        if needToPrint {
            let openDeawer = check_if_open_deawer()
         printOrder(openDeawer: openDeawer)
        }
//
        
//        self.perform(#selector(printOrder(openDeawer:)), with: true)
        
//        if order!.amount_total > 0.0
//          {
//         printToOther()
//        }
     }
    
    
    func check_if_open_deawer() -> Bool
    {
        var openDeawer = true

        let setting = SharedManager.shared.appSetting()
        if setting.open_drawer_only_with_cash_payment_method == true
        {
        let is_paid_cash = order?.list_account_journal.filter({$0.code == "CSH1"})
            if is_paid_cash?.count == 0
            {
                openDeawer = false
            }
        }
        
        if order?.amount_total == 0
        {
            openDeawer = false
        }
        
        
        return openDeawer
    }
    
    
    @objc func printOrder(openDeawer:Bool)
    {
//        guard  rules.check_access_rule(rule_key.print_bill,show_msg:false) else {
//            SharedManager.shared.epson_queue.run()
//
//            return
//        }
        
        if SharedManager.shared.appSetting().enable_support_multi_printer_brands {
            if SharedManager.shared.appSetting().enable_cloud_qr_code {
                guard let order = self.order else { return  }
                order.creatKDSQueuePrinter(.kds)
                pos_order_helper_class.increment_print_count(order_id: order.id!)


                MWQueue.shared.mwCloudQRQueue.async {
                    pos_order_qr_code_class.save(from: order,with: .PENDING)

                    let syncInteractor = AppDelegate.shared.sync
                    if let lastSession = syncInteractor.get_last_session_onServer(){
                        order.session_id_server = lastSession.server_session_id
                        let _ = syncInteractor.sendOrder_normal(order:order )
                    }
                }
                QrCodeInteractor.shared.checkInternetConnection()
                MWRunQueuePrinter.shared.startMWQueue()
            }else{
                self.order!.printReturnOrderByMWqueue()
                if self.returnOrder{
                    
                }
                MWRunQueuePrinter.shared.startMWQueue()
            }
           
        }else{
        pos_order_helper_class.increment_print_count(order_id: self.order!.id!)
 
        DispatchQueue.global(qos: .background).async {
            
            let copy_numbers = SharedManager.shared.appSetting().receipt_copy_number
//            let journal =  self.order?.list_account_journal.first
//            if journal?.type == "bank"
//            {
//                copy_numbers = SharedManager.shared.appSetting().receipt_copy_number_journal_type_bank
//            }
            
            if copy_numbers > 0
            {
                let setting = settingClass.getSetting()
                for _ in 1...copy_numbers
                {
                    SharedManager.shared.epson_queue.add_job_printer(id:0,IP: setting.ip,printer_name: (setting.name ?? ""), order: self.order! ,print_items_only: false ,openDeawer: openDeawer,index: 0,master: true)
                }
                
  
                
                SharedManager.shared.epson_queue.run()
            }
            

            
            
        }
        }
         
        
    }
    
 
    
    @objc func close()
    {
        self.dismiss(animated: true, completion: nil)

    }
    
    @IBAction func btnCancel(_ sender: Any) {
        delegate?.goHome()
        close()
    }
    
    @IBAction func btnPrint(_ sender: Any) {
//        delegate?.rePrint()
//        self.print()
            printOrder(openDeawer: false)
        
    }
    
    func webpageLoaded()
    {
        indicator.stopAnimating()
 
//        self.perform(#selector(print_openDrawer), with: nil, afterDelay: 0.1)
 
        self.perform(#selector(btnCancel), with: nil, afterDelay: 5)

     
    }
    
    func screenShotLoaded(){
        enableCancel()
    }
    
    @objc func enableCancel()   {
           btn_Cancel.isEnabled = true
    }
    
    
    
  
}

protocol paymentSuccessfullMessage_delegate:class {
    func rePrint()
    func goHome()
}
