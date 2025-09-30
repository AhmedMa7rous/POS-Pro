//
//  paymentRowsViewController.swift
//  pos
//
//  Created by khaled on 9/25/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

class paymentRowsVc: UIViewController ,paymentRowsCell_delegate {

    var list_items:  [account_journal_class] = []
    weak var delegate:paymentRowsVc_delegate?
    
    var total:Double = 0
    
    @IBOutlet var tableview: UITableView!

    // loyalty
    var loyalty_amount_remaining:Double = 0
    var loyalty_amount_remaining_used:Double = 0

    
    override func viewDidLoad() {
        super.viewDidLoad()
 
    }
    
    func  loyaltyAmount( ) -> Double
    {
        let lst = self.list_items.filter({$0.payment_type == "loyalty" })
        var total_tendered:Double = 0
        for row in lst
        {
            total_tendered = total_tendered +  row.tendered.toDouble()!
        }
        
        
        return total_tendered
        
        
    }
    
    func loyaltyAvailable() -> Double
    {
        return self.loyalty_amount_remaining   - self.loyalty_amount_remaining_used
    }
    
    func calc()
    {
        if   list_items.count == 0   {
            self.delegate?.payment_status(amount_paid: 0, amount_return: 0)

            return
        }
        
        self.loyalty_amount_remaining_used = loyaltyAmount()

        
        var total_paid:Double = 0
        var total_changes:Double = 0

        
//        let multiCash = SharedManager.shared.appSetting().enable_multi_cash
        var multiCash = list_items.filter({($0.tendered.toDouble() ?? 0.0) > 0.0}).count > 0

        let totalTendered = list_items.compactMap({$0.tendered.toDouble()?.rounded(value: 2)}).reduce(0, +)
        let totalChanged = (list_items.compactMap({$0.changes}).reduce(0, -)) * -1
        let expectedChanged = (total - totalTendered)
        if expectedChanged > totalChanged {
            SharedManager.shared.printLog("expectedChanged = \(expectedChanged)")
        }

        for i in 0...list_items.count - 1
        {
            let item = list_items[i]
            if i == 0
            {

                item.due = baseClass.currencyFormate((total) ).toDouble() ?? 0
            }
            else
            {
                let lastRow = list_items[i-1]
                if lastRow.changes < 0
                {
                    if  multiCash == false
                    {
                        item.due = 0
                    }
                     
                }
                else
                {
                     item.due = lastRow.rest
                }
               
            }
            
//            item.due = item.due.rounded(toPlaces: 2)
//            let calc = (item.due - item.tendered.toDouble()!).rounded(toPlaces: 2)

            item.due = item.due.rounded_app()
            var tendered = item.tendered.toDouble() ?? 0
            if item.payment_type == "loyalty"
            {
//                if  i == list_items.count - 1
//                {
                    let loyalty = loyaltyAvailable()
                    if loyalty < 0
                    {
                        tendered = self.loyalty_amount_remaining   //tendered + loyalty
                        item.tendered = String(tendered)
                        item.rest = item.due - self.loyalty_amount_remaining
                    }
                   
                    total_paid = total_paid +  item.tendered.toDouble()!

//                }
              
 
            }
            else
            {
                total_paid = total_paid +  item.tendered.toDouble()!

            }
            
            
            let calc = (item.due - tendered).rounded_app()
            if  (item.type == "bank" && item.is_support_geidea) {

//            if (item.type == "bank" && multiCash == false) || (item.type == "bank" && item.is_support_geidea) {
                
                if self.list_items.count == 1
                {
                    
                    
                    item.tendered =   String(item.due)
                    
                    
                    total_paid =  item.tendered.toDouble()!
                    
                }
                else
                {
                    if calc <= 0
                    {
                        item.tendered =    item.due.rounded_formated_str()
                        
                    }
                    
                    else
                    {
                        item.tendered =   calc.toIntString()
                        
                    }
                    
                    item.changes = 0
                    
                    total_paid = total_paid +  item.tendered.toDouble()!
                }
                
                
                NotificationCenter.default.post(name : DisableKeyboardNotification, object : nil)
                //notification to disable the numbers
            }

            else if calc < 0
            {
                
                
                total_changes = total_changes + calc
                item.changes = total_changes
                item.rest = 0
                //notification to enable the numbers
                NotificationCenter.default.post(name : EnableKeyboardNotification, object : nil)
            }
            else
            {
                total_changes = 0
                item.changes = 0
                item.rest = calc
                //notification to enable the numbers
                NotificationCenter.default.post(name : EnableKeyboardNotification, object : nil)
            }
            
            
            
            list_items[i] = item
            
//            if item.payment_type == "loyalty"
//            {
//                self.delegate?.updateLoyalty(rowStatment: item)
//            }
        }
        
        self.delegate?.payment_status(amount_paid: total_paid, amount_return: total_changes)
        self.delegate?.updateLoyalty()
        
    }
    
    
    func reload()
    {
        tableview.reloadData()
        calc()
    }
    
    
}


extension paymentRowsVc: UITableViewDelegate ,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if indexPath.row == (list_items.count - 1){
            let obj = list_items[indexPath.row]
            obj.rowIndex = indexPath.row
            
            self.delegate?.paymentRowSelected(rowStatment:obj)
        }
        //        self.dismiss(animated: true, completion: nil)
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list_items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! paymentRowsCell
        
        let cls = list_items[indexPath.row]
//        let obj = bankStatementClass(fromDictionary: cls as! [String : Any])
        cls.rowIndex = indexPath.row
        cell.delegate = self
        cell.object = cls
        cell.updateCell()
        
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.frame = cell.bounds
        cell.selectedBackgroundView?  = view
        
        
        return cell
    }
    
    func deleteRow(row:account_journal_class)
    {
        list_items.remove(at: row.rowIndex)
        tableview.reloadData()
        calc()
        
        delegate?.paymentRowDeleted(rowStatment: row)
        
        
//
//        if  list_items.count > 1
//        {
//            list_items.remove(at: row.rowIndex)
//            tableview.reloadData()
//        }
//        else
//        {
//            messages.showAlert("You must have one payment method")
//        }
     
    }

}

protocol paymentRowsVc_delegate:class {
    func updateLoyalty( )
    func paymentRowSelected(rowStatment:account_journal_class)
    func paymentRowDeleted(rowStatment:account_journal_class)
    func payment_status(amount_paid:Double , amount_return:Double)
}
