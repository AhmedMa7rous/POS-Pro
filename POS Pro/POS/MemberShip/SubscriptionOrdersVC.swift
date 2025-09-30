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
    @IBOutlet weak var lockBtn: KButton!
    @IBOutlet weak var printBtn: KButton!
    @IBOutlet weak var payBtn: KButton!
    @IBOutlet weak var seqment: UISegmentedControl!
    @IBOutlet weak var badgePrinterLbl: KLabel!
    @IBOutlet weak var emptyView: UIView!

    var memberShipVM:MemberShipVM?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initalState()
        // Do any additional setup after loading the view.
    }
    static func createModule(completeHandler:(()->())?) -> CreateStockRequestVC{
        let vc = CreateStockRequestVC()
        vc.modalPresentationStyle = .fullScreen
        vc.createStockRequestVM = CreateStockRequestVM()
        vc.completeHandler = completeHandler
        return vc
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
                    self.emptyView.isHidden = true
                    loadingClass.hide(view:self.view)
                }
                return
            case .detailsSuccess:
                DispatchQueue.main.async {
                    self.emptyView.isHidden = true
                    loadingClass.hide(view:self.view)
                }
                return
            case .restView:
                DispatchQueue.main.async {
                    self.emptyView.isHidden = true
                    loadingClass.hide(view:self.view)
                }
                return
            }
            
        }
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
    
    @IBAction func tapOnSeqment(_ sender: UISegmentedControl) {
      //  refersh()
    }
    
    @IBAction func tapOnMenuBtn(_ sender: UIButton) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.centerContainer?.open(.left, animated: true, completion: nil)
    }
    
    @IBAction func tapOnPickup(_ sender: KButton) {
        /*
        self.orderSelected?.pickup_user_id = sender.tag == 0 ? SharedManager.shared.activeUser().id : 0
        self.handleUI()
        self.orderSelected?.save(write_info: true, write_date: true, updated_session_status: .sending_update_to_server)
        refersh()
        AppDelegate.shared.run_poll_send_local_updates(force: true)
         */
        
        
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
        /*
        openPayment()
       */
    }
}
