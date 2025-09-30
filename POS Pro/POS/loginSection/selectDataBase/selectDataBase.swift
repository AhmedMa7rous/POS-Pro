//
//  selectPointOfSale.swift
//  pos
//
//  Created by khaled on 9/19/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit


class selectDataBase: UIViewController {

 
    var delegate:selectDataBase_delegate?
    
    var refreshControl_tableview = UIRefreshControl()
    @IBOutlet var tableview: UITableView!
    
 
    @IBOutlet weak var indc: UIActivityIndicatorView!
    
    
    var list_items:  [Any] = []
    let con = SharedManager.shared.conAPI()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        alter_database.check(.selectedDataBase)
        
 
        
         init_refresh()
         getList()
    }
    
    func init_refresh()   {
        
        refreshControl_tableview.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl_tableview.addTarget(self, action: #selector(refreshOrder(sender:)), for: UIControl.Event.valueChanged)
        tableview.addSubview(refreshControl_tableview) // not required when using UITableViewContr
    }
    
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func refreshOrder(sender:AnyObject) {
        // Code to refresh table view
        getList()
    }
    
    
    func getList()
    {

        indc.startAnimating()
        
        con.userCash = .stopCash
        con.get_databases { (results) in
            self.refreshControl_tableview.endRefreshing()
//            loadingClass.hide()
            
            self.indc.stopAnimating()
            
            let response = results.response
            //            let header = results.header
            
            let list:Array<Any> = response?["result"] as? Array ?? []
            
            
            
            self.list_items.removeAll()
            self.list_items.append(contentsOf:list )
            
            
            self.tableview?.reloadData()
            
        }
    }

}


extension selectDataBase: UITableViewDelegate ,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let dic = list_items[indexPath.row] as? String
 
        delegate?.databse_selected(name: dic!)
 
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list_items.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! selectDataBaseTableViewCell
        
        let dic = list_items[indexPath.row] as? String

        cell.lblNAme.text = dic
        
        
        return cell
    }
}

protocol selectDataBase_delegate {
    func databse_selected(name:String)
}
