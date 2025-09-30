//
//  tillOperation.swift
//  pos
//
//  Created by khaled on 10/5/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

class tillOperation: UIViewController {

    var refreshControl_tableview = UIRefreshControl()
      @IBOutlet var tableview: UITableView!
    
    var list_items:  [Any] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()

      initList()
        getList()
   }
    
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
  func initList()   {
         
         refreshControl_tableview.attributedTitle = NSAttributedString(string: "Pull to refresh")
         refreshControl_tableview.addTarget(self, action: #selector(refreshOrder), for: UIControl.Event.valueChanged)
         tableview.addSubview(refreshControl_tableview) // not required when using UITableViewContr
     }
     
    @objc func refreshOrder(){
        list_items.removeAll()
        self.tableview.reloadData()
        getList()
    }
    
     
    
       func getList()
        {
           
            
            let options = posSessionOptions()
            options.orderDesc = true

            let shifts_All:[[String:Any]] = pos_session_class.get_pos_sessions(options: options)
           
 
//            let shifts_All = pos_session_class.getAllShift(orderAsc: "desc")
            
              for shift in  shifts_All
                {
                    let shift_start = pos_session_class(fromDictionary: shift )
                    shift_start.show_as = showAs.start
                    list_items.append( shift_start)


                    var cashbox_list:[[String:Any]] = cashbox_class.get(session: shift_start.id)
                    cashbox_list.reverse()
                    
                    if  cashbox_list.count != 0
                    {
                        for obj in  cashbox_list
                        {
                            // TODO: fix it
                            let shift_cashbox = cashbox_class(fromDictionary: obj  )
                            shift_cashbox.cashier = shift_start.cashier()
//
//                            let shift = pos_session_class(fromDictionary: shift )
//                            shift.cashbox_list.removeAll()
//                            shift.cashbox_list.append(shift_cashbox.toDictionary())
//                            if shift_cashbox.cashbox_in_out == "in"
//                            {
//                                shift.show_as = showAs.cashIn
//
//                            }
//                            else
//                            {
//                                shift.show_as = showAs.cashOut
//                            }


                            list_items.append(shift_cashbox)
                        }

                    }


                    if shift_start.end_session != nil
                    {
                        let shift_end = pos_session_class(fromDictionary: shift )

                        shift_end.show_as = showAs.end
                        list_items.append(shift_end)
                    }


                }


//         list_items = list_items.sorted(by: {
//             $0.id < $1.id
//         })
//
//         list_items.reverse()
 

            refreshControl_tableview.endRefreshing()
            self.tableview?.reloadData()
        }
        
    
 
   
 }



 extension tillOperation: UITableViewDelegate ,UITableViewDataSource {
     
     func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
         return false
     }
     
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
     {
//            let customer = list_items[indexPath.row] as? [String : Any]
//
//           selectedCustomer = customerClass(fromDictionary: customer!)
//
//          self.btnBack(!)
     }
     
     
     func numberOfSections(in tableView: UITableView) -> Int {
         return 1
     }
   
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return list_items.count
     }
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! tillOperationCell
         
         let obj = list_items[indexPath.row]
 
        if obj is pos_session_class
        {
            cell.updateCell(shift: obj as! pos_session_class)

        }
        else if obj is cashbox_class
        {
            cell.updateCell(cash_box:   obj as! cashbox_class)

        }
      
         
         
         return cell
     }
 }

