//
//  selectPointOfSale.swift
//  pos
//
//  Created by khaled on 9/19/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

protocol selectPointOfSale_delegate {
    func pos_selected(pos:pos_config_class)
}

class selectPointOfSale: baseViewController {

    var delegate:selectPointOfSale_delegate?

    var refreshControl_tableview = UIRefreshControl()
    @IBOutlet var tableview: UITableView!
    
    @IBOutlet var btnBack: UIButton!
//    public var hideBack :Bool = true
    
    var list_items:  [Any] = []
    let con = SharedManager.shared.conAPI()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

//         btnBack.isHidden = hideBack
        
         init_refresh()
         getList()
    }
    
    func init_refresh()   {
        
        refreshControl_tableview.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl_tableview.addTarget(self, action: #selector(refreshOrder(sender:)), for: UIControl.Event.valueChanged)
        tableview.addSubview(refreshControl_tableview) // not required when using UITableViewContr
    }
    
    @IBAction func btnBack(_ sender: Any) {
//        self.navigationController?.popViewController(animated: true)
        
            AppDelegate.shared.logOut()
    }
    
    @objc func refreshOrder(sender:AnyObject) {
        // Code to refresh table view
        getList()
    }
    
    
    func getList()
    {
        loadingClass.show(view: self.view)
        
        
        con.get_point_of_sale_old { (results) in
            self.refreshControl_tableview.endRefreshing()
            loadingClass.hide()
            
            if !results.success
            {
                printer_message_class.show(results.message ?? "internal error")
                return;
            }
            
            let response = results.response
            //            let header = results.header
            
            let list:[[String:Any]]  = response?["result"] as? [[String:Any]] ?? []
            
            pos_config_class.saveAll(arr: list)
            
            self.list_items.removeAll()
            self.list_items.append(contentsOf:list )
            
            
            self.tableview?.reloadData()
            
        }
    }

}


extension selectPointOfSale: UITableViewDelegate ,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let dic = list_items[indexPath.row] as? [String : Any]
        
        let pos = pos_config_class(fromDictionary: dic!)
    
    
        if delegate == nil
        {
            pos.setActive()

            AppDelegate.shared.loadLoading()
        }
        else
        {
            self.delegate?.pos_selected(pos: pos)
            self.dismiss(animated: true, completion: nil)
        }
 
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list_items.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! selectPointOfSaleTableViewCell
        
        let obj = list_items[indexPath.row]
        let cls = pos_config_class(fromDictionary: obj as! [String : Any])
        
        cell.object = cls
        cell.updateCell()
        
        
        return cell
    }
}
