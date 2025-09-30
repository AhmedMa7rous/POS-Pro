//
//  cash_in_out.swift
//  pos
//
//  Created by khaled on 10/24/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

class cash_in_out: UIViewController , keyboard_number_delegate {

    var cash_out:Bool = false
    @IBOutlet var lbltitle: KLabel!
    @IBOutlet var txt_amount: UITextField!
    @IBOutlet var txt_reason: UITextView!
    
    let con = SharedManager.shared.conAPI()
    var keyboard:keyboard_number! = keyboard_number()
    @IBOutlet var view_keyboard: UIView!
    
    override func viewDidDisappear(_ animated: Bool) {
            super.viewDidDisappear(animated)
        
        keyboard = nil
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupKeyboard()
        lbltitle.text = "Cash in"
        if cash_out == true
        {
               lbltitle.text = "Cash out"
        }
    }
    
    

    @IBAction func btnCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)

    }
    @IBAction func btnOk(_ sender: Any) {
        
        create_pos_cash_box()
        
//        self.dismiss(animated: true, completion: nil)
    }
    
    
    func create_pos_cash_box()
    {
        let session  = pos_session_class.getActiveSession()
        let casher = SharedManager.shared.activeUser()
//        let newID :Int = ClassDate.getTimeINMS()!.toInt()!

        
        let amount =  txt_amount.text?.toDouble() ?? 0
        
        let cash = cashbox_class(fromDictionary: [:])
        
        cash.cashbox_in_out = "in"
        if cash_out == true
        {
            cash.cashbox_in_out = "out"
        }
        
        cash.cashbox_reason = txt_reason.text
        cash.cashbox_amount =   amount
        cash.date = baseClass.get_date_now_formate_datebase()
        cash.sessionID = session?.id
        cash.save()
        
        // TODO : check this
//            session!.cashbox_list.removeAll()
//           session!.cashbox_list.append(cash)
        
//        let shift_current = posSessionClass.getCurrentShift (session_id: session!.id)
//        shift_current!.cashbox_list.append(cash.toDictionary())
//        shift_current!.save()
//
//
//        let shift_cash = posSessionClass.getCurrentShift (session_id: session!.id)
//        shift_cash!.cashbox_list.removeAll()
//        shift_cash!.cashbox_list.append(cash.toDictionary())

 
 
        
        let order:pos_order_class = pos_order_class(fromDictionary: [:])
        
 
//        order.orderID = String(newID)
        order.session = session
 
        order.cashier = casher
        order.session_id_local = session!.id
        order.session_id_server = session!.server_session_id
        order.order_sync_type = .cash_in_out
        order.pos = SharedManager.shared.posConfig()
 
        order.is_closed = true
        
        order.save()
        
        
        
        
        
        AppDelegate.shared.syncNow()
        self.dismiss(animated: true, completion: nil)

//        con.create_pos_cash_box(pos: session)  { (results) in
//            if (!results.success)
//            {
//                MessageView.show(results.message!)
//            }
//
//
//
//        }
    }
    
    
    func setupKeyboard()
    {
        keyboard.delegate = self;
        view_keyboard.addSubview(keyboard.view)
        
    }
    
    func keyboard_newValue(val:String)
    {
        txt_amount.text = val
    }
  
}
