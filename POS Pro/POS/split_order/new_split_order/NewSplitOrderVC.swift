//
//  NewSplitorderVc?.swift
//  pos
//
//  Created by M-Wageh on 28/01/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import UIKit


class NewSplitOrderVC: UIViewController {
        //MARK:- Variables
        var newSplitOrderVM:NewSplitOrderVM?
        var newSplitOrderRouter:NewSplitOrderRouter?
        var complete: ((pos_order_class) -> Void)?
        //MARK:- OutLets
        @IBOutlet weak var currentOrderView: UIView!
        @IBOutlet weak var newOrderView: UIView!
        weak var splitCurrentOrderView: SplitOrderView?
        weak var splitNewOrderView: SplitOrderView?
        
        //MARK:- LifeCyle
        override func viewDidLoad() {
            super.viewDidLoad()
            blurBgView()
            addSplitOrderView(for:self.currentOrderView,with :NewSplitOrderVM.OrderStatusEnum.CURRENT)
            addSplitOrderView(for:self.newOrderView,with :NewSplitOrderVM.OrderStatusEnum.NEW)
            initalState()
            
            //        newSplitOrderVM?.reloadData()
        }
        //MARK:- inital State Lines List  screen
        func initalState(){
            self.newSplitOrderVM?.updateStatusClosure = { (state) in
                switch state {
                case .openChangeTable(let state):
                    DispatchQueue.main.async {
                        self.openChangeTable(for:state)
                    }
                    return
                case .populated:
                    DispatchQueue.main.async {
                        self.splitCurrentOrderView?.orderTable.reloadData()
                        self.splitNewOrderView?.orderTable.reloadData()
                    }
                    return
                case .doneSplit:
                    self.newSplitOrderRouter?.goBack(completion: {
                        if let newOrder = self.newSplitOrderVM?.newOrder{
                            self.complete?(newOrder)
                        }
                    })
                }
                
            }
        }
//    func showLoading(){
//        DispatchQueue.main.async {
//            loadingClass.show(view: self.view )
//        }
//    }
//    func hideLoading(){
//        DispatchQueue.main.async {
//            loadingClass.hide(view: self.view )
//        }
//    }
    func getSequenceOrderSplit(complete:@escaping (Int?)->Void) {
        if SharedManager.shared.appSetting().enable_sync_order_sequence_wifi{
//            if !(SharedManager.shared.posConfig().isMasterTCP() ){
//                self.showLoading()
//            }
            sequence_session_ip.shared.getSequenceForNextOrder(for: self.view)  { result in
//                if !(SharedManager.shared.posConfig().isMasterTCP() ){
//                    self.hideLoading()
//                }
                if result {
                    let ipSequence = sequence_session_ip.shared.completeGetSequenceFromMaster()
                    complete(ipSequence)
                }else{
                    messages.showAlert( "Check master device".arabic("  تحقق من اتصال الجهاز الرئيسي"), title:"")
                    complete(nil)

                    
                }
            }
        }else{
            complete(-1)
        }
    }
    func openChangeTable(for status:NewSplitOrderVM.OrderStatusEnum ){
        if SharedManager.shared.appSetting().auto_arrange_table_default {
            let vc = TableManagementVC(nibName: "TableManagementVC", bundle: nil)
            vc.isSplitOrMove = true
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true, completion: nil)
            vc.didSelect = { resturantTable in
                self.newSplitOrderVM?.didSelectTable(for:status , with: resturantTable)
                self.splitCurrentOrderView?.updateTableName()
               self.splitNewOrderView?.updateTableName()
            }
        } else {
            let vc = posTableMangent(nibName: "posTableMangement", bundle: nil)
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true, completion: nil)
            vc.didSelect = { resturantTable in
                self.newSplitOrderVM?.didSelectTable(for:status , with: resturantTable)
                self.splitCurrentOrderView?.updateTableName()
               self.splitNewOrderView?.updateTableName()
            }
        }
        
        /*
         self.splitCurrentOrderView?.updateTableName()
        self.splitNewOrderView?.updateTableName()
         */

    }
        //MARK:- IBAction
        @IBAction func tapOnCancelBtn(_ sender: KButton) {
            newSplitOrderRouter?.goBack()
        }
        
        @IBAction func tapOnDoneBtn(_ sender: KButton) {
            self.getSequenceOrderSplit { sequence in
                if let sequence = sequence {
                    if sequence == -1 {
                        self.newSplitOrderVM?.doSplit()

                    }else{
                        self.newSplitOrderVM?.doSplit(with: sequence)

                    }
                }
            }
        }
        
        //MARK:- UI Setup
        private func addSplitOrderView(for sideView:UIView,with orderStatus:NewSplitOrderVM.OrderStatusEnum){
            guard let newSplitOrderVM = self.newSplitOrderVM  else {
                return
            }
            let splitOrderView = SplitOrderView.getViewInstance(newSplitOrderVM: newSplitOrderVM, orderStatus: orderStatus)
            if orderStatus == NewSplitOrderVM.OrderStatusEnum.CURRENT {
                self.splitCurrentOrderView = splitOrderView
                addConstraint(for :sideView,with: self.splitCurrentOrderView!)
            }else{
                self.splitNewOrderView = splitOrderView
                addConstraint(for :sideView,with: self.splitNewOrderView!)
            }
            
        }
        private func addConstraint(for sideView:UIView,with splitOrderView:SplitOrderView){
            sideView.addSubview(splitOrderView)
            splitOrderView.translatesAutoresizingMaskIntoConstraints = false
            splitOrderView.topAnchor.constraint(equalTo: sideView.topAnchor, constant: 0).isActive = true
            splitOrderView.bottomAnchor.constraint(equalTo: sideView.bottomAnchor, constant: 0).isActive = true
            splitOrderView.leftAnchor.constraint(equalTo: sideView.leftAnchor, constant: 0).isActive = true
            splitOrderView.rightAnchor.constraint(equalTo: sideView.rightAnchor, constant: -20).isActive = true
            
        }
        private func blurBgView(){
            view.backgroundColor = UIColor.clear
            
            let blurBgView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
            blurBgView.translatesAutoresizingMaskIntoConstraints = false
            
            view.insertSubview(blurBgView, at: 0)
            
            NSLayoutConstraint.activate([
                blurBgView.heightAnchor.constraint(equalTo: view.heightAnchor),
                blurBgView.widthAnchor.constraint(equalTo: view.widthAnchor),
            ])
        }
    }
