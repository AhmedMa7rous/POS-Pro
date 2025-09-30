//
//  paymentMethod.swift
//  pos
//
//  Created by khaled on 9/24/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

class paymentMethod: UIViewController {
    @IBOutlet var tableview: UITableView!

    var delegate:paymentMethod_delegate?
    
    var list_items:  [Any] = []
    let con = SharedManager.shared.conAPI()
    
    var filterby_journal_ids:[Int] = []
    
  

    
    override func viewDidLoad() {
        super.viewDidLoad()

      getPaymentMethod()
    }
    
    
    func getPaymentMethod() {
        
        let arr = account_journal_class.getAll()  // api.get_last_cash_result(keyCash: "get_account_Journals") as? [[String:Any]] ?? []
      
        self.list_items.removeAll()
 
                   if self.filterby_journal_ids.count == 0
                   {
                       self.list_items.append(contentsOf: arr)
                   }
                   else
                   {
                       for item:[String:Any] in arr
                       {
                           let id = item["id"] as? Int ?? 0
                        
                           if  self.filterby_journal_ids.contains(id) {
                                self.list_items.append(item)
                           }

                       }
                   }
                   
                   
                    self.tableview.reloadData()
        
//
//        let pos = posConfigClass.getDefault()
//
//         con.get_account_Journals(journal_ids: pos.journal_ids) { (results) in
//            if (!results.success)
//            {
//                return
//            }
//
//            let response = results.response
//
//             self.list_items.removeAll()
//            let arr = response?["result"] as? [[String:Any]] ?? []
//
//            if self.filterby_journal_ids.count == 0
//            {
//                self.list_items.append(contentsOf: arr)
//            }
//            else
//            {
//                for item:[String:Any] in arr
//                {
//                    let id = item["id"] as? Int ?? 0
//
//                    if  self.filterby_journal_ids.contains(id) {
//                         self.list_items.append(item)
//                    }
//
//                }
//            }
//
//
//             self.tableview.reloadData()
//
////            if  self.list_items.count > 0
////            {
////                self.tableview.selectRow(at: IndexPath.init(row: 0, section: 0), animated: true, scrollPosition: .none)
////                let obj = accountJournalsClass(fromDictionary: self.list_items[0] as! [String : Any])
////                self.delegate?.payment_selected(payment: obj)
////
////            }
//        }
    }

}


extension paymentMethod: UITableViewDelegate ,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
   
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
        let dic = list_items[indexPath.row]
        
        let obj = account_journal_class(fromDictionary: dic as! [String : Any])

        delegate?.payment_selected(payment: obj)
 
//        self.dismiss(animated: true, completion: nil)
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list_items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! paymentMethodTableViewCell
        
        let cls = list_items[indexPath.row]
        let obj = account_journal_class(fromDictionary: cls as! [String : Any])
        
        cell.object = obj
        cell.updateCell()
        
        
        return cell
    }
    
    
}

protocol  paymentMethod_delegate {
    func payment_selected(payment:account_journal_class)
}
