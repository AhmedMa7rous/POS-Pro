//
//  notification_list.swift
//  pos
//
//  Created by khaled on 28/03/2021.
//  Copyright © 2021 khaled. All rights reserved.
//

import UIKit

class notification_list: baseViewController, UITableViewDelegate,UITableViewDataSource{

    @IBOutlet var tableview: UITableView!
    
    var list_notifications:[[String:Any]] = []

    var didSelect : ((pos_order_class) -> Void)?

    
    override func viewDidLoad() {
        super.viewDidLoad()

//        blurView()

        
        list_notifications.append(contentsOf: logClass.getAll(prefix: "notification", limit: [0,100]))
        self.tableview.reloadData()
    }

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
         
        return 150
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  list_notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "Cell"
        var cell: notification_list_cell! = tableView.dequeueReusableCell(withIdentifier: identifier) as? notification_list_cell
        if cell == nil {
            tableView.register(UINib(nibName: "notification_list_cell", bundle: nil), forCellReuseIdentifier: identifier)
            cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? notification_list_cell
        }
        
        let data_string = list_notifications[indexPath.row]["data"] as? String ?? ""
        let data = data_string.toDictionary() ?? [:]
         let type = notifications_messages_class(dic: data)
 
      cell.updateView(obj: type)
        
        let bg_view = UIView()
        bg_view.backgroundColor = UIColor.clear
        
        cell.selectedBackgroundView = bg_view
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let data_string = list_notifications[indexPath.row]["data"] as? String ?? ""
        let data = data_string.toDictionary() ?? [:]
         let type = notifications_messages_class(dic: data)
 
        if type.title == "Menu"
        {
            let option = self.pendding_options()
            option.uid = type.key
            
            let arr = pos_order_helper_class.getOrders_status_sorted(options:option)
            if arr.count > 0
            {
                self.dismiss(animated: true, completion: {
                    self.didSelect!(arr[0])

                })

            }
        }
        
    }
    
    func pendding_options() -> ordersListOpetions
    {
        let ActiveSession = pos_session_class.getActiveSession()
        
        let session_id = ActiveSession!.id
        
        let opetions = ordersListOpetions()
        opetions.Closed = false
        opetions.Sync = false
        opetions.void = false
        opetions.order_menu_status = [.pendding]
        
        
        opetions.sesssion_id = session_id
        opetions.parent_product = true
        
        opetions.LIMIT = 10
        opetions.orderDesc = true
        
 
       
        return opetions
    }
    
    @IBAction func btn_clear(_ sender: Any) {
       logClass.deleteAll(prefix: "notification")
        
        self.dismiss(animated: true, completion: nil)
    }
    
  
    
}
