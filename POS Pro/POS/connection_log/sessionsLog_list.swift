//
//  connectionLog_list.swift
//  pos
//
//  Created by Khaled on 12/10/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

class sessionsLog_list: UIViewController {
    var refreshControl_tableview = UIRefreshControl()

    @IBOutlet var tableview: UITableView!
    var list_items:  [[String:Any]]! = []
    @IBOutlet weak var txt_log: UITextView!
    
    @IBOutlet var seqError: UISegmentedControl!

    
    override func viewDidDisappear(_ animated: Bool) {
            super.viewDidDisappear(animated)
        
        list_items = nil
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

      initRefresh()
        
        refreshOrder(sender: nil)
        
        txt_log.text = ""
        
     }
    
    func initRefresh()   {
        
        refreshControl_tableview.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl_tableview.addTarget(self, action: #selector(refreshOrder(sender:)), for: UIControl.Event.valueChanged)
        tableview.addSubview(refreshControl_tableview) // not required when using UITableViewContr
    }
    
    @IBAction func seqChanged(_ sender: Any) {
        list_items.removeAll()
 
        if seqError.selectedSegmentIndex == 0
        {
            let options = posSessionOptions()
              options.page = 0
            options.LIMIT = 1000
     
            list_items = pos_session_class.get_pos_sessions(options: options)
  
        }
        else
        {
            let result  =  logClass.search(txt: "error",prefix: "pos_session", limit: [0,1000] )
             list_items.append(contentsOf: result)
        }
        
 
        self.tableview.reloadData()
        refreshControl_tableview.endRefreshing()
        
    }
    
    @objc func refreshOrder(sender:AnyObject?) {
        // Code to refresh table view
        
        let options = posSessionOptions()
          options.page = 0
        options.LIMIT = 1000
 
        list_items = pos_session_class.get_pos_sessions(options: options)
 
        self.tableview.reloadData()
        refreshControl_tableview.endRefreshing()
    }
    
    
    
    @IBAction func btnBack(_ sender: Any) {
        self .dismiss(animated: true, completion: nil)
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



extension sessionsLog_list: UITableViewDelegate ,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let row =   list_items[indexPath.row]

        if seqError.selectedSegmentIndex == 0
        {
        let obj =  pos_session_class(fromDictionary:  row)

        
        let key = "session " +  String(obj.id)
        let log = logClass.get(key: key, prefix: "pos_session")
 
        self.txt_log.text = log.data?.replacingOccurrences(of: "\\n", with: "\n")
        self.txt_log.text = self.txt_log.text.replacingOccurrences(of: "\\", with: "")
        }
        else
        {
            let log = logClass(fromDictionary: row)
            
            self.txt_log.text = log.data?.replacingOccurrences(of: "\\n", with: "\n")
            self.txt_log.text = self.txt_log.text.replacingOccurrences(of: "\\", with: "")

        }
        
//        let bottom = self.txt_log.contentSize.height - self.txt_log.bounds.size.height
//        self.txt_log.setContentOffset(CGPoint(x: 0, y: bottom), animated: true)
        
        scrollTextViewToBottom(textView: self.txt_log)
        
     }
    
    func scrollTextViewToBottom(textView: UITextView) {
        if textView.text.count > 0 {
            let location = textView.text.count - 1
            let bottom = NSMakeRange(location, 1)
            textView.scrollRangeToVisible(bottom)
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
        let obj =   list_items[indexPath.row]

 
        
        if seqError.selectedSegmentIndex == 0
        {
            let obj =  pos_session_class(fromDictionary: obj)
            cell.lblName.text = String( obj.id) + " - " + String( obj.server_session_id) + " - " + obj.start_session!
        }
        else
        {
            let log = logClass(fromDictionary: obj)
            cell.lblName.text = String( log.row_id!) + " - " + String( log.key!)

        }
        
        
        
        return cell
    }
    
    
}
