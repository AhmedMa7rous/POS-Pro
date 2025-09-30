//
//  WaitingPopUpVC.swift
//  pos
//
//  Created by M-Wageh on 12/05/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import UIKit

class GeideaPaymentVC: UIViewController {
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var messageLbl: UILabel!
    @IBOutlet weak var cancelBtn: KButton!
    @IBOutlet weak var reconnectBtn: KButton!

    
    @IBOutlet weak var widthView: NSLayoutConstraint!
    
    private var timeOutTask: DispatchWorkItem?
    private lazy var timeOutInseconds = 30


    var order:pos_order_class?
    var completionBlock:(()->())?
    var ammount: Double?
    var accountJournal:account_journal_class?
    let titleLblText = "Waiting".arabic("انتظار")

    override func viewDidLoad() {
        super.viewDidLoad()
        titleLbl.text = titleLblText
        if let ammountString = getAmmount() {
            messageLbl.text = "Waiting till complete from pay \(ammountString) \(SharedManager.shared.getCurrencyName())".arabic("الإنتظار حتى الاكتمال من دفع \(ammountString) \(SharedManager.shared.getCurrencyName(true)) ")
        }else{
            messageLbl.text = "Waiting till complete from pay".arabic("في انتظار اكتمال الدفع")
        }
        widthView.constant = 500
        initalGedieaDevice()
        checkGeideaDevice()
        

    }
    func handleHidenBtns(_ isHiden:Bool){
        widthView.constant = isHiden ? 500 : 650
        cancelBtn.isHidden = isHiden
        reconnectBtn.isHidden = isHiden
       
    }
    private func initalizeTimeOutTask(){
        timeOutTask = DispatchWorkItem {
            self.stopTimeOutTask()
            DispatchQueue.main.async{
                GeideaInteractor.shared.isTimoOutRequest()
            }
        }
    }
    func stopTimeOutTask(){
        timeOutTask?.cancel()
        timeOutTask = nil
    }
    func sartTimeOutTask(){
        /*
       if timeOutTask == nil {
           initalizeTimeOutTask()
       }
       DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(timeOutInseconds), execute: timeOutTask!)
         */
   }
    
    @IBAction func tapOnSkip(_ sender: KButton) {
        guard let order = self.order else{return}
        guard let ammount = getAmmount() else{return}
        GeideaInteractor.shared.manulePaymentComplete(ammount:ammount)
    }
    
    @IBAction func tapOnCancel(_ sender: KButton) {
        self.dismiss(animated: true, completion: nil)

    }
    
    @IBAction func tapOnReconnectBtn(_ sender: KButton) {
        checkGeideaDevice()
    }
    func resetGedieaDevice(){
        print("reset gedia device")
        /*
        GeideaInteractor.shared.updateStatusClosure = nil
        GeideaInteractor.shared.geideaRequestModel = nil
        GeideaInteractor.shared.geideaParsingManager?.delegate = nil
        GeideaInteractor.shared.geideaParsingManager = nil
         */

    }
    func initalGedieaDevice(){
        GeideaInteractor.shared.updateStatusClosure = { (stateIngenico,message,data) in
            switch stateIngenico {
            case .check:
                DispatchQueue.main.async {
                    self.handleHidenBtns(false)
                    loadingClass.hide(view: self.view)
                    /*
                    DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
                        GeideaInteractor.shared.isTimoOutRequest()
                        self.resetGedieaDevice()

                    }
                     */
                    return
                }
                
            case .error:
                DispatchQueue.main.async {
                    self.handleHidenBtns(false)
                    loadingClass.hide(view:    self.view)
                    //                        printer_message_class.show(message ?? "",vc: self)
                    self.showFailToastMessage(message:message ?? "")
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(700)) {
                    self.resetGedieaDevice()
                        self.stopTimeOutTask()
                    //self.dismiss(animated: true, completion: nil)
                    }

                }
                
                
            case .receiveResponse:
                DispatchQueue.main.async {
                    self.handleHidenBtns(true)

                    loadingClass.hide(view: self.view)
                    self.stopTimeOutTask()
                    self.dismiss(animated: true, completion:{
                        self.resetGedieaDevice()
                        self.completionBlock?()
                    })
                }
                return
            case .empty:
               SharedManager.shared.printLog("initalize IngenicoInteractor successfully")
                return
            case .loading:
                self.sartTimeOutTask()
                DispatchQueue.main.async {
                    self.handleHidenBtns(true)
                    loadingClass.show(view:  self.view)
                }
                
                
            case .update_status(message: let message):
                if message.lowercased().contains("closed") {
                    DispatchQueue.main.async {
                        loadingClass.hide(view: self.view)
                        self.handleHidenBtns(false)
                    }
                    return
                }
                if message.lowercased().contains("ecr busy") {
                    DispatchQueue.main.async {
                        self.titleLbl.text = "Gediea device is busy".arabic("جهاز جديا مشغول")
                        self.handleHidenBtns(false)
                    }
                }else{
                    DispatchQueue.main.async {
                        
                        self.handleHidenBtns(true)
                        let messageWaiting = "Please wait, while your request being processed".lowercased()
                        if messageWaiting == message.lowercased(){
                            
                        }
                        self.titleLbl.text = self.titleLblText + " " + message
                    }
                }
            }
        }
        
    }
    func checkGeideaDevice(){
        guard let order = self.order else{return}
        guard let ammount = getAmmount() else{return}
        guard let accountJournal_id = self.accountJournal?.id else{return}
        GeideaInteractor.shared.setTotalAmount(ammount)
        GeideaInteractor.shared.setEcrWith(ecr_no: "\(order.id ?? 0)", ecr_receipt_no: order.name ?? "")
        GeideaInteractor.shared.setOrderUid(order.uid ?? "",for:order.id ?? 0,journal_id:accountJournal_id )
//        GeideaInteractor.shared.checkConnection()
        GeideaInteractor.shared.startPayment()
    }
    func getAmmount()->String?{
        guard let ammount = self.ammount else{return nil}
        return "\((ammount).rounded_double(toPlaces: 2))"
    }
    func showFailToastMessage(message:String,isSucess:Bool = false,image:String = "icon_error"){
        DispatchQueue.main.async {
            SharedManager.shared.initalBannerNotification(title: "Fail payment".arabic("فشل الدفع") ,
                                                          message: message,
                                                          success: isSucess, icon_name: image)
            SharedManager.shared.banner?.dismissesOnTap = true
            SharedManager.shared.banner?.show(duration: 3.0)
        }
    }
    static func createModule(_ order:pos_order_class) -> GeideaPaymentVC {
        let vc:GeideaPaymentVC = GeideaPaymentVC()
        vc.order = order
        return vc
    }
}

extension paymentVc{
    
    func show_waiting_geidea_popup()
    {
        if let aj = paymentRows?.list_items.first(where: {$0.is_support_geidea}){
            let ammount = aj.due - aj.rest
            guard let order = self.orderVc?.order else{return}
            if !checkIfAllAmountPaidForOrder(){
                return
            }
            let vc = GeideaPaymentVC.createModule(order)
            vc.modalPresentationStyle = .overFullScreen
            vc.ammount = ammount
            vc.accountJournal = aj
            vc.completionBlock = {
                self.doPayment()
            }
            self.present(vc, animated: true, completion: nil)
        }
      
    }
}
