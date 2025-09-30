//
//  customers_listVC.swift
//  pos
//
//  Created by khaled on 8/19/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

class order_type_list: UIViewController {

    var delegate:order_type_list_delegate?

    public var selectedItem: delivery_type_class!
    
    var refreshControl_tableview = UIRefreshControl()
    @IBOutlet var tableview: UITableView!

    let con = SharedManager.shared.conAPI()
    var list_items:  [delivery_type_class]! = []
    
    var category_id:Int?
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    
    list_items = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        // Do any additional setup after loading the view.
        selectedItem = nil
        
//        initLists()
            getLists()
        check_height()
    }
    
    func initLists()   {
        
        refreshControl_tableview.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl_tableview.addTarget(self, action: #selector(refreshOrder(sender:)), for: UIControl.Event.valueChanged)
        tableview.addSubview(refreshControl_tableview) // not required when using UITableViewContr
    }
    
    
    @objc func refreshOrder(sender:AnyObject) {
        // Code to refresh table view
        con.userCash = .stopCash
        getLists()
    }
    
    func check_height()
    {
        
        let max_h = 580
        var h = self.list_items.count * 60
        
        if h < max_h
        {
            h = h + 180
        }
        else
        {
            h = max_h
        }
        
        self.preferredContentSize = CGSize(width: 350, height: h)
        
        

    }
   
    func getLists()
    {
        loadingClass.show(view: self.view)
        
        var list:[delivery_type_class] = []
        
        if category_id == nil
        {
            list =   delivery_type_class.getAll()
        }
        else
        {
            list =   delivery_type_class.getAll(category_id: category_id)
        }
            
        
        
//        let none = orderTypeClass()
//        none.id = 0
//        none.name = "None"
 
        self.list_items.removeAll()
        
//        self.list_items.append(none)
        self.list_items.append(contentsOf:list )
        
        self.tableview?.reloadData()
        
        
        /*
        con.get_order_type { (results) in
            self.refreshControl_tableview.endRefreshing()
            loadingClass.hide()
            
            let response = results.response
            //            let header = results.header
            
            let list:Array<Any> = response?["result"] as! Array
            
            var none:[String:Any] = [:]
            none["id"] = 0
            none["name"] = "None"
            
            self.list_items.removeAll()
            
            self.list_items.append(none)
            self.list_items.append(contentsOf:list )
            
            self.tableview?.reloadData()
            
        }
 */
        
    }

    @IBAction func btnBack(_ sender: Any) {
        self .dismiss(animated: true, completion: nil)
    
       

    }
    
    @IBAction func btnPaymentDefault(_ sender: Any) {
        let defalut_orderType = delivery_type_class.getDefault()
        if defalut_orderType != nil
        {
            selectedItem = defalut_orderType
            delegate?.order_typeSelected()
           
        }
        else
        {
            let none = delivery_type_class()
            none.id = 0
            none.name = "None"
            
            selectedItem = none
        }
        
         self.btnBack(!)
    }
    
}

 

extension order_type_list: UITableViewDataSource  , UITableViewDelegate  {
    
      func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
          return false
      }
      
      func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
      {
        selectedItem = list_items[indexPath.row] as? delivery_type_class
    
//            selectedItem = orderTypeClass(fromDictionary: customer!)
        
          self.dismiss(animated: true,completion:{
              self.delegate?.order_typeSelected()
              
          })
//           self.btnBack(!)
      }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //     func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    //        return "Section \(section)"
    //    }
    //
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list_items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! order_type_listCell
        
        let cls = list_items[indexPath.row] as! delivery_type_class
//        let cls = orderTypeClass(fromDictionary: obj as! [String : Any])
        
        cell.row = cls
        cell.updateCell()
        
        
        return cell
    }
    
    
    
}

protocol order_type_list_delegate {
    func order_typeSelected()
}
