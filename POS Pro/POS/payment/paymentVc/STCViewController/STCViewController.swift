//
//  STCViewController.swift
//  pos
//
//  Created by Khaled on 1/6/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import UIKit


protocol STC_Delegate {
    func STC_RequestStatus(status:STC_PaymentStatus)
}

class STCViewController: UIViewController ,enterBalance_delegate{
    
    let autoAcccept:Bool = false
    
    var order_id:Int!
    var amount:Double = 0
    var MobileNo:String = ""
    var RefNum:String = ""
    var BillNumber:String = ""
    var useQRCode:Bool = false
    var imageQRCode:UIImage?

    
    @IBOutlet var btnOk: KButton!
    @IBOutlet weak var view_keyboard: UIView!
    @IBOutlet weak var btnChangeMethod: KButton!
    @IBOutlet weak var indc: UIActivityIndicatorView!
    
    @IBOutlet weak var photoQR: KSImageView!
    var statusPayment:STC_PaymentStatus = .none
    var keyboard :enterBalanceNew!

    var delegate:STC_Delegate?
    
    let con = SharedManager.shared.conAPI()
    let stcCls = STC_Class()
    
    
    
    var timer = Timer()
    @IBOutlet weak var lblStatus: KLabel!
    
    var count_timer =  0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
 
        btnOk.isHidden = !SharedManager.shared.appSetting().STC_force_done
        
        photoQR.image = imageQRCode
        con.userCash = .stopCash
        
        
//        MobileNo = "+966 565551295"
        
        stcCls.order_id = order_id
        stcCls.amount = amount
        stcCls.MobileNo = MobileNo
        stcCls.RefNum = RefNum
        stcCls.BillNumber = BillNumber
        
 
        
        checkLastPayment()
 
    }
    
    func addKeyboard()
    {
        let storyboard = UIStoryboard(name: "dashboard", bundle: nil)
        keyboard = storyboard.instantiateViewController(withIdentifier: "enterBalanceNew") as? enterBalanceNew
        keyboard.title_vc = "Enter mobile number."
        keyboard.key = "mobile"
          keyboard.mobile_mode = true
          keyboard.initValue = "+966"
        keyboard.delegate = self
        keyboard.view.frame = CGRect.init(x: 0, y: 0, width: 300, height: 560)
        view_keyboard.addSubview(keyboard.view)
    }
    
    func startTimer()
    {
        timer = Timer.scheduledTimer(timeInterval:10, target: self, selector: #selector(checkLastPayment), userInfo: nil, repeats: false)
//        timer.fire()
    }
    
    func cancelTimer()
    {
        timer.invalidate()
       
    }
    
    func makePayment()
    {
//        if useQRCode == true
//        {
//            makePaymentWith_QR()
//        }
//        else
//        {
//            makePaymentWith_number()
//        }
        
    }
    
   
    
       func makePaymentWith_QR()
       {
            self.indc.startAnimating()
        
           con.stc_OnlinePaymentAuthorize(STC: stcCls ) { (reuslts) in
               if reuslts.response != nil
               {
                   if reuslts.success
                   {
                       self.lblStatus.text =  "Request send , Please accept transaction."
                    
                   

                    self.stcCls.AuthorizationReference =   (reuslts.response! as NSDictionary).value(forKeyPath: "OnlinePaymentAuthorizeResponseMessage.AuthorizationReference")as? String ?? ""
                    
                       self.statusPayment = .requestedPayment
                       self.checkPayment()
                  
                   }
                   else
                   {
                        let Text = reuslts.response!["Text"] as? String ?? ""
                       
                       self.lblStatus.text = Text
                       self.indc.stopAnimating()

    
                   }
                   
               }
           }
           
       }
    
    func makePaymentWith_number()
    {
        self.indc.startAnimating()

        con.stc_MobilePaymentAuthorize(STC: stcCls ) { (reuslts) in
            if reuslts.response != nil
            {
                if reuslts.success
                {
                    self.lblStatus.text =  "Request send , Please accept transaction."

                    self.stcCls.AuthorizationReference =   (reuslts.response! as NSDictionary).value(forKeyPath: "MobilePaymentAuthorizeResponseMessage.AuthorizationReference")as? String ?? ""
                    
                    self.statusPayment = .requestedPayment
                    self.checkPayment()
               
                }
                else
                {
                     let Text = reuslts.response!["Text"] as? String ?? ""
                    
                    self.lblStatus.text = Text
                    self.indc.stopAnimating()

 
                }
                
            }
        }
        
    }
    
    func cancelPayment()
       {
           con.stc_CancelPaymentAuthorize(STC: stcCls ) { (reuslts) in
               if reuslts.response != nil
               {
                   if reuslts.success
                   {
                    
                    self.lblStatus.text = "Cancelled , Please make new Request ."
                    
                       self.stcCls.AuthorizationReference =  ""
                     
                    self.indc.stopAnimating()
                  
                   }
                   else
                   {
                        let Text = reuslts.response!["Text"] as? String ?? ""
                       
                       self.lblStatus.text = Text
                       self.indc.stopAnimating()

    
                   }
                   
               }
           }
           
       }
    
    
    func saveLog(TransactionList: [Any])
    {
//        var temp:[String:Any] = [:]
//          temp[self.RefNum] = TransactionList
        
        relations_database_class(re_id1: stcCls.order_id, re_id2: [0], re_table1_table2: "pos_order|stc",data_str: TransactionList.toJsonString()).save()

//        myuserdefaults.setitems(self.RefNum, setValue: TransactionList, prefix: "STC_log")

    }
    
    
     @objc func checkLastPayment()
        {
             
        cancelTimer()
        
            con.stc_PaymentInquiry(STC: stcCls) { (reuslts) in
                
                self.startTimer()
                
                if reuslts.response != nil
                {
                    if reuslts.success
                    {
                        self.statusPayment = .responsePayment
                        let PaymentInquiryResponseMessage = reuslts.response?["PaymentInquiryResponseMessage"] as? [String:Any] ?? [:]
                        let TransactionList = PaymentInquiryResponseMessage["TransactionList"] as? [Any] ?? []
                        
                        self.saveLog(TransactionList: TransactionList)
                        
                        let count =  TransactionList.count
                        if count > 0
                        {
                            let lastTransaction = TransactionList[count - 1] as? [String:Any] ?? [:]
                            

                            let PaymentStatus = lastTransaction["PaymentStatus"] as? Int
                             
                            
                             if PaymentStatus == STC_PaymentStatus.Paid.rawValue
                             {
                                self.cancelTimer()

                                self.delegate?.STC_RequestStatus(status: .Paid)
                                self.dismiss(animated: true, completion: nil)

                             }
                             else if PaymentStatus == STC_PaymentStatus.Cancelled.rawValue || PaymentStatus == STC_PaymentStatus.Expired.rawValue
                             {
                                    self.makePayment()
                             }
                             else
                            {
                                self.statusPayment = .Pending
                                
                                self.checkPayment()
                            }
                        }
                        else
                       {
                             self.makePayment()
                       }
                        
       
                      

                    }
                    else
                    {
                        self.makePayment()
                    }
                    
                }
            }
        }
    
    @objc func checkPayment()
    {
        
        if autoAcccept == true
        {
            self.count_timer =  self.count_timer + 1

        }
        
        
       cancelTimer()
        
        con.stc_PaymentInquiry(STC: stcCls) { (reuslts) in
            
            self.startTimer()
            
            if reuslts.response != nil
            {
                if reuslts.success
                {
                    self.statusPayment = .responsePayment
                    let PaymentInquiryResponseMessage = reuslts.response?["PaymentInquiryResponseMessage"] as? [String:Any] ?? [:]
                    let TransactionList = PaymentInquiryResponseMessage["TransactionList"] as? [Any] ?? []
                    
                    self.saveLog(TransactionList: TransactionList)

                    let count =  TransactionList.count
                    if count > 0
                    {
                        let lastTransaction = TransactionList[count - 1] as? [String:Any] ?? [:]
                        
 
                        let PaymentStatus = lastTransaction["PaymentStatus"] as? Int
                         
                        
                         if PaymentStatus == STC_PaymentStatus.Paid.rawValue
                         {
                             self.statusPayment = .Paid
                         }
                         else if PaymentStatus == STC_PaymentStatus.Cancelled.rawValue
                         {
                             self.statusPayment = .Cancelled
                         }
                         else if PaymentStatus == STC_PaymentStatus.Expired.rawValue
                         {
                             self.statusPayment = .Expired
                         }
                         else
                        {
                            self.statusPayment = .Pending
                        }
                    }
                    
                    if self.autoAcccept == true
                      {
                    if self.count_timer > 3
                 {
//                    self.statusPayment = .Paid

                    }
                    }

                    
                    self.checkStatus()

                }
                else
                {
                    //                    let Code = reuslts.response!["Code"] as? Int ?? 0
                    let Text = reuslts.response!["Text"] as? String ?? ""
                    
                    self.lblStatus.text = Text
                    
//                    MessageView.show(Text,vc: self)
                    
                }
                
            }
        }
    }
    
    
    
    func checkStatus()
    {
        delegate?.STC_RequestStatus(status: statusPayment)

        if statusPayment == .Expired
        {
 
            lblStatus.text =  "Time Out , Please make new Request ."
            indc.stopAnimating()
 
//            self.perform(#selector(btnCancel(_:)), with: nil, afterDelay: 3.0)
        }
       else if statusPayment == .Cancelled
        {
                lblStatus.text = "Cancelled , Please make new Request ."
                indc.stopAnimating()
//            self.perform(#selector(btnCancel(_:)), with: nil, afterDelay: 3.0)
        }
        else if statusPayment == .Paid
        {
            btnCancel(AnyClass.self)
        }
        else
        {
            self.lblStatus.text =  "Request send , Please accept transaction."

//            self.perform(#selector(checkPayment), with: nil, afterDelay: 10.0)
 
        }
    }
    
  
    @IBAction func btn_ok(_ sender: Any) {
           
           cancelTimer()
           self.statusPayment = .Paid

               
               self.delegate?.STC_RequestStatus(status: .Paid)

               self.dismiss(animated: true, completion: nil)
       }
    @IBAction func btnCheck(_ sender: Any) {
        
        checkPayment()
    }
    
    @IBAction func btnCancel(_ sender: Any) {
        cancelTimer()
        
        self.delegate?.STC_RequestStatus(status: .Cancelled)

        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnChangeMethod(_ sender: Any) {
        cancelPayment()
        
        if useQRCode == true
        {
            useQRCode = false
            btnChangeMethod.setTitle("Use Qr Code", for: .normal)
            
            photoQR.isHidden = true
            addKeyboard()
        }
        else
        {
            useQRCode = true
            btnChangeMethod.setTitle("Use mobile number", for: .normal)
            
            photoQR.isHidden = false
            keyboard.view.removeFromSuperview()
            
             makePayment()
        }
    }
    
    func newBalance(key:String,value:String)
    {
        if !value.isEmpty
        {
            stcCls.MobileNo = value
              makePaymentWith_number()
        }
    }
    
}
