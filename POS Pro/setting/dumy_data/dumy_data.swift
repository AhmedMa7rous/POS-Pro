//
//  dumy_data.swift
//  pos
//
//  Created by Khaled on 9/1/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import UIKit

class dumy_data: UIViewController {
    
    @IBOutlet var btn_stop: UIButton!
    @IBOutlet var btn_start: UIButton!
    @IBOutlet var lbl_progress: UILabel!
    @IBOutlet var progress: UIProgressView!
    @IBOutlet var txt_orders_number: UITextField!
    @IBOutlet var txt_session_number: UITextField!

    var stop_create:Bool = false
    
    let cash_defalut = account_journal_class.get_cash_default()!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        active_view(active: true)
        
        
    }
    
    @IBAction func btn_clear_database(_ sender: Any) {
        clear_database()
    }
    
    func clear_database()
    {
       _ = database_class(connect: .database).runSqlStatament(sql: "delete from pos_order_account_journal")
       _ =  database_class(connect: .database).runSqlStatament(sql: "delete from pos_order_line")
      _ =   database_class(connect: .database).runSqlStatament(sql: "delete from pos_order")
        _ =   database_class(connect: .database).runSqlStatament(sql: "delete from pos_session")
        UserDefaults.standard.removeObject(forKey: "version_user_default")

        AppDelegate.shared.vacuum_database()
        
    }
    
    @IBAction func btn_create(_ sender: Any) {
        self.view.endEditing(true)
        
        let alert = UIAlertController(title: "Delete", message: "this action will remove all orders and clear data base Are you sure ?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes" , style: .default, handler: { (action) in
            
            
            self.run_create()
            
            
            alert.dismiss(animated: true, completion: nil)
            
        }))
        
        alert.addAction(UIAlertAction(title: "NO" , style: .cancel, handler: { (action) in
            
            alert.dismiss(animated: true, completion: nil)
            
        }))
        
        
        
        self .present(alert, animated: true, completion: nil)
        
    }
    @IBAction func btn_stop(_ sender: Any) {
        self.stop_create = true
        active_view(active: false)
        
    }
    
    @IBAction func btn_close(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func active_view(active:Bool)
    {
        DispatchQueue.main.async {
            
            self.btn_start.isEnabled = active
            self.btn_stop.isEnabled = !active
            self.txt_orders_number.isEnabled = active
            
            self.progress.progress = 0
           self.lbl_progress.text = ""
        }
    }
    
    func run_create()
    {
        clear_database()
        
        stop_create = false
        
        var numbers_to_create:Int = 0
        //        DispatchQueue.main.async {
        numbers_to_create = Int( self.txt_orders_number.text  ?? "0") ?? 0
        
        //        }
        
        let number_of_session:Double = Double(self.txt_session_number.text ?? "1") ?? 1
        
        if numbers_to_create != 0
        {
            DispatchQueue.global(qos: .background).async
                {
                    
                    self.active_view(active: false)
                    
                    for i in 0...numbers_to_create - 1
                    {
                        if self.stop_create == true
                        {
                            self.active_view(active: true)
                            
                            continue
                        }
                        
                        
                        DispatchQueue.main.async {
                            let p:Float =  Float(i ) / Float(numbers_to_create)
                            self.progress.progress = p
                            self.lbl_progress.text = "\(i)/\(numbers_to_create)"
                            
                        }
                        
                        if i == 0
                        {
                            self.close_session()
                            self.open_session()
                        }
                        else
                        {
                            if number_of_session > 1
                            {
                                let create_new_session:Double = Double(i) / number_of_session
                                if create_new_session.isInteger()
                                {
                                    self.close_session()
                                    self.open_session()
                                }
                            }
                        
                        }
                        
                        self.create_order()
                    }
                    
                    self.active_view(active: true)
            }
            
            
            
            
        }
    }
    
    
    
    func get_bankStatement(order:pos_order_class) ->  [account_journal_class]
    {
        var list:[account_journal_class] = []
        let statments:[pos_order_account_journal_class] = order.get_bankStatement()
        for cls in statments
        {
            let account = account_journal_class(fromDictionary: [:])
            account.id = cls.account_Journal_id
            account.changes =  cls.changes!
            account.tendered =  cls.tendered!
            account.due =  cls.due!
            account.rest = cls.rest!
            
            list.append( account)
            
        }
        
        return list
    }
    
    func open_session()
    {
        let session = pos_session_class()
               session.id = 0
               session.start_session = baseClass.get_date_now_formate_satnder()
               session.start_Balance = 0
               session.cashierID = SharedManager.shared.activeUser().id
               
               //        pos.shift_current = posSessionClass()
               //        pos.shift_current.casher = cashierClass.getDefault()
               session.posID = SharedManager.shared.posConfig().id
              
              let session_id = session.saveSession()
        pos_session_class.open_session(session_id: session_id)
               
    }
    
    func close_session()
    {
        let lastSession = pos_session_class.getActiveSession()
        
        if lastSession != nil
        {
//            lastSession!.end_session = baseClass.get_date_now_formate_satnder() // must to be UTC  as server online
//            lastSession!.end_Balance =   0
//
//
//            let session_id = lastSession!.saveSession()
            pos_session_class.close_session(session_id: lastSession!.id,end_session: baseClass.get_date_now_formate_satnder(),end_Balance: 0)
        }

    }
    
    
    func  create_order()  {
        let order = pos_order_helper_class.creatNewOrder()
        order.save(write_info: true)
        
        let arr_products:[product_product_class] = get_rnd_products()
        
        for product  in arr_products
        {
            let line = pos_order_line_class.create(order_id: order.id!, product: product)
            line.qty = Double(Int.random(in: 1..<20))
            line.update_values()
            
            order.pos_order_lines.append(line)
        }
        
        order.calcAll()
        
        let n = Float.random(in: 0..<2)
        
        if n > 1
        {
            order.is_closed = true
        }
        else
        {
            order.is_closed = false
        }
        
        if order.is_closed
        {
            let account = cash_defalut
            account.due = order.amount_total
            account.tendered = order.amount_total.toIntString()
            
            order.list_account_journal.append(account)
        }
        
        var status:updated_status_enum = .last_update_from_local
        let status_s = Float.random(in: 0..<2)
        if status_s > 1
        {
            status = .sending_update_to_server
        }
        
        order.save(write_info: true, updated_session_status: status)
        
    }
    
    
    func get_rnd_products() -> [product_product_class]
    {
        let limit = Int.random(in: 1..<10)
        
        var arr:[product_product_class] = []
        let sql = "SELECT * FROM product_product  ORDER BY random() LIMIT \(limit)"
        let rows = database_class(connect: .database).get_rows(sql: sql)
        
        for row in rows
        {
            let prodcut = product_product_class(fromDictionary: row)
            arr.append(prodcut)
        }
        
        return arr
    }
    
    
}
