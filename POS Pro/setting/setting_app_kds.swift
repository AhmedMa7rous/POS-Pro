//
//  setting_app.swift
//  pos
//
//  Created by Khaled on 12/11/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

class setting_app_kds: UIViewController {
    @IBOutlet weak var sw_show_log: UISwitch!
    @IBOutlet weak var txt_clearPenddingOrders: kTextField!

    @IBOutlet var scroll: UIScrollView!

    var self_me: UIViewController! = nil

    let setting = SharedManager.shared.appSetting()

    override func viewDidLoad() {
        super.viewDidLoad()

        sw_show_log.isOn = setting.show_log
        sw_show_log.addTarget(self_me, action: #selector(show_log(_:)), for:UIControl.Event.valueChanged)
        txt_clearPenddingOrders.text = String( setting.clearPenddingOrders_every_hour  )

        
       
        
     }
    
    @IBAction func show_log(_ mySwitch: UISwitch) {
            
            setting.show_log = mySwitch.isOn
            
            setting.save()
        }
    
    @IBAction func txt_clearPenddingOrders_end_edit(_ sender: Any) {
        let time = txt_clearPenddingOrders.text ?? "0"
        let days = Double(time)
        setting.clearPenddingOrders_every_hour = days!
        setting.save()
    }
     
    @IBAction func btnClearLog(_ sender: Any) {
        
        AppDelegate.shared.removeDataBase_data(database: "log")
        AppDelegate.shared.removeDataBase_data(database: "printer_log")

//        logDB.initDataBase()
        
        printer_message_class.show("log cleard.", vc: self)
    }
     
    
}
