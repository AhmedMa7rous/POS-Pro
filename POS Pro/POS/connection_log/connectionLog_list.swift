//
//  connectionLog_list.swift
//  pos
//
//  Created by Khaled on 12/10/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

class connectionLog_list: UIViewController ,UISearchBarDelegate {
    var refreshControl_tableview = UIRefreshControl()
    @IBOutlet weak var txt_search: UISearchBar!

    @IBOutlet var tableview: UITableView!
    
    var list_items_org:  [Any]! = []
    var list_items:  [Any]! = []

    @IBOutlet var seqError: UISegmentedControl!
    @IBOutlet weak var txt_log: UITextView!
    
    var last_cell_index:Int = 0
    var currentPage:Int = 0

    
    override func viewDidDisappear(_ animated: Bool) {
            super.viewDidDisappear(animated)
        
        list_items = nil
        list_items_org = nil
        tableview = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

      initRefresh()
        
        refreshOrder(sender: nil)
        
        txt_log.text = ""
        
     }
    
    @IBAction func seqChanged(_ sender: Any) {
        list_items.removeAll()
        list_items_org.removeAll()

        if seqError.selectedSegmentIndex == 0
        {
            list_items = logClass.getAll(limit: [0,1000])
     
  
        }
        else
        {
            let result  =  logClass.search(txt: "error", limit: [0,1000] )
             list_items.append(contentsOf: result)
        }
        
        list_items_org.append(contentsOf: list_items)

        self.tableview.reloadData()
        refreshControl_tableview.endRefreshing()
        
    }
    
    func initRefresh()   {
        
        refreshControl_tableview.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl_tableview.addTarget(self, action: #selector(refreshOrder(sender:)), for: UIControl.Event.valueChanged)
        tableview.addSubview(refreshControl_tableview) // not required when using UITableViewContr
    }
    
    
    @objc func refreshOrder(sender:AnyObject?) {
        // Code to refresh table view
//        list_items = logDB.lstitems("con_log" ,limit: [0,10000] , orderASC: false)
        list_items = logClass.getAll(limit: [0,1000])
 
        list_items_org.removeAll()
        list_items_org.append(contentsOf: list_items)
        
        self.tableview.reloadData()
        refreshControl_tableview.endRefreshing()
    }
    
    func getList()
    {
        list_items.append(contentsOf:logClass.getAll(limit: [currentPage * 1000 ,1000]))
 
        list_items_org.append(contentsOf: list_items)
        
        self.tableview.reloadData()
        refreshControl_tableview.endRefreshing()
    }
    
    
    
    @IBAction func btnBack(_ sender: Any) {
        self .dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnClearAll(_ sender: Any) {
//        logDB.deletelstitems("con_log"  )
        logClass.deleteAll(prefix: nil)
        
            refreshOrder(sender: nil)
        txt_log.text = ""
    }
    
    @IBAction func btnShare(_ sender: Any) {
        let activityVC = UIActivityViewController(activityItems: [txt_log.text ?? ""], applicationActivities: nil)
        activityVC.modalPresentationStyle = .popover
        activityVC.popoverPresentationController?.sourceView = sender as? UIView
        present(activityVC, animated: true, completion: nil)
        activityVC.completionWithItemsHandler = { (activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
            
            if completed  {
                activityVC.dismiss(animated: true, completion: nil)
            }
        }
    }
  
    
    func share() {
        let objectsToShare = [txt_log.text]

        let activity = UIActivityViewController(activityItems:objectsToShare as [Any], applicationActivities: nil)
        self.present(activity, animated: true, completion: nil)
    }
}



extension connectionLog_list: UITableViewDelegate ,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
        let dic =   list_items[indexPath.row] as! [String:Any]
        let log = logClass(fromDictionary: dic)
        
        if log.row_id != 0
        {
            self.txt_log.text = log.data?.replacingOccurrences(of: "\\n", with: "\n")
            self.txt_log.text = self.txt_log.text.replacingOccurrences(of: "\\", with: "")

        }
        else
        {
             var obj:[String:Any] = [:]
             obj = obj.toDictionary(json: log.data)
             
            self.txt_log.text = ""

            if obj.isEmpty
            {
                self.txt_log.text = log.data

            }
            else
            {
                    let time = obj["time"] as? Int ??  0
                            
                            let dt = Date(millis: Int64(time))
                            let time_str:String  = dt.toString(dateFormat: "dd/MM/yyyy hh:mm:ss a" , UTC: false)
                            
                //             let time_str =  ClassDate.convertTimeStampTodate(String( time) , returnFormate: "dd/MM/yyyy hh:mm:ss a" , timeZone: NSTimeZone.local)
                             let response_time = obj["response_time"] as? Double ??  0.0
                             
                             var response_time_str  = "\(response_time) ms"

                             if response_time >= 1000
                             {
                                 response_time_str  = "\(response_time / 1000) s"
                             }
                              
                             
                              
                          
                                 self.txt_log.text = """
                              Time : \(time_str ?? "" )
                             ----------------------------------
                             response_time : \(response_time_str )
                             ----------------------------------
                             Refs : \(obj["key"] ?? "")
                             ----------------------------------
                             url : \(obj["url"] ?? "")
                             ----------------------------------
                             header : \(obj["header"] ?? "")
                             ----------------------------------
                             request : \(obj["param"] ?? "")
                             ----------------------------------
                             response : \(obj["res"] ?? "")
                             """
            }
         
            
            
            
        }
 

        
     }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list_items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! connectionLog_listTableViewCell
        
        let obj =   list_items[indexPath.row] as! [String:Any]
        let log = logClass(fromDictionary: obj)
       
        log.req_count += 1
        
        
        cell.lbl_id.text =  String( log.id ?? 0) + "\n (" + String( log.req_count) + ")"
        cell.lblName.text = log.key!
        
        
        if (log.data ?? "").contains("error")
        {
            cell.layer.borderWidth = 1
            cell.layer.borderColor = UIColor.red.cgColor
            
        }
        else
        {
            cell.layer.borderColor = UIColor.clear.cgColor

        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if last_cell_index < indexPath.row
        {
            let lastItem = self.list_items.count - 1
            if lastItem >= page_count - 1
            {
                if indexPath.row == lastItem {
                   SharedManager.shared.printLog("IndexRow\(indexPath.row)")
                    currentPage += 1
                    last_cell_index = indexPath.row
                    
                    self.getList()
                }
            }
        }
        
        
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(!searchText.isEmpty){
            
//            let searchPredicate:NSPredicate = NSPredicate(format: "key CONTAINS[c] %@", searchText)
            
//                let searchPredicate = NSPredicate { (dic, _) -> Bool in
//                            let item = dic as? [String:Any] ?? [:]
//
//                            let  key = item["key"] as? String ?? ""
//                            let  cash_id = item["cash_id"] as? String ?? ""
//                            let  url = item["url"] as? String ?? ""
//
//                           let  header_dic = item["header"] as? [String:Any] ?? [:]
//                           let  param_dic =  item["param"] as? [String:Any] ?? [:]
//                           let  res_dic =  item["res"] as? [String:Any] ?? [:]
//
//                           let  header = header_dic.jsonString() ?? ""
//                            let  param = param_dic.jsonString()   ?? ""
//                            let  res =  res_dic.jsonString()  ?? ""
//
//                    let search_txt = String(format: "%@ %@ %@ %@ %@ %@", key.lowercased(),cash_id.lowercased(),url.lowercased(),header.lowercased(),param.lowercased(),res.lowercased())
//
//                    if  (search_txt  ).contains( searchText.lowercased())
//                                {
//                                    return true
//                                }
//
//
//                            return false
//                        }
//
//            let result  = (list_items as NSArray).filtered(using: searchPredicate)
            
            let result  =  logClass.search(txt: searchText ,limit: [0,1000] )
            list_items.removeAll()
            list_items.append(contentsOf: result)
        }
        else
        {
            list_items.removeAll()
            list_items.append(contentsOf: list_items_org)
        }
        
        tableview.reloadData()
    }
    
}
