//
//  STCLogViewController.swift
//  pos
//
//  Created by Khaled on 1/9/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import UIKit

class STCLogViewController: UIViewController {

    var parent_vc:UIViewController?
    @IBOutlet var tableview: UITableView!
       var list_items:  [Any] = []
 
    let con = SharedManager.shared.conAPI()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        con.userCash = .stopCash

       loadData()
    
    }
    
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    func loadData()
    {
        list_items.removeAll()
        
     
        let arr:[String] = relations_database_class().get_relations_rows(  re_table1_table2: "pos_order|stc") //= myuserdefaults.lstitems("STC_log")
               
               for item   in arr
               {
                let list = [].to_array(json: item)  ?? []
                
                if list.count > 0
                {
                    let lastTransaction = list.last as? [String:Any] ?? [:]

                      list_items.append(lastTransaction)
                }
               
               }
               
//               list_items = Sort.sort_array_(of_dic_bykey: list_items, key: "PaymentDate", ascending: false)!

               self.tableview.reloadData()
        
    }
    
    
    @objc func checkPayment(ref:String)
        {
            let stcCls = STC_Class()
            stcCls.RefNum = ref

            
            loadingClass.show(view: self.view)
            con.stc_PaymentInquiry(STC: stcCls) { (reuslts) in
                loadingClass.hide(view: self.view)
      
                
                if reuslts.response != nil
                {
                    if reuslts.success
                    {
                  
                        let PaymentInquiryResponseMessage = reuslts.response?["PaymentInquiryResponseMessage"] as? [String:Any] ?? [:]
                        let TransactionList = PaymentInquiryResponseMessage["TransactionList"] as? [Any] ?? []
                        
                        self.saveLog(TransactionList: TransactionList,ref: ref)

                        self.loadData()
         

                    }
                    else
                    {
                        //                    let Code = reuslts.response!["Code"] as? Int ?? 0
                        let Text = reuslts.response!["Text"] as? String ?? ""
                        
 
                        if Text != ""
                        {
                            printer_message_class.show(Text)

                        }
                        
                    }
                    
                }
            }
        }
    
        func saveLog(TransactionList: [Any] ,ref:String)
        {
    //        var temp:[String:Any] = [:]
    //          temp[self.RefNum] = TransactionList
            
//            myuserdefaults.setitems(ref, setValue: TransactionList, prefix: "STC_log")

        }
    
}


 extension STCLogViewController: UITableViewDelegate ,UITableViewDataSource {
     
     func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
         return true
     }
     
     
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
     {
         
         let obj =   list_items[indexPath.row] as! [String:Any]

        let RefNum = obj["RefNum"] as? String ??  ""
        
        checkPayment(ref: RefNum)
        
        let storyboard = UIStoryboard(name: "OrdersDisplay", bundle: nil)
        let orderHistory = storyboard.instantiateViewController(withIdentifier: "order_history") as! order_history
        orderHistory.order_name = RefNum
        parent_vc?.navigationController?.pushViewController(orderHistory, animated: true)
       
      }
     
     
     func numberOfSections(in tableView: UITableView) -> Int {
         return 1
     }
     
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return list_items.count
     }
     
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! STCLogCell
         
        cell.dic =   list_items[indexPath.row] as? [String:Any]
        cell.parent_vc = self
        cell.updateCell()

         
         
         return cell
     }
     
     

}
