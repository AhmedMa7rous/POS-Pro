//
//  customers_listVC.swift
//  pos
//
//  Created by khaled on 8/19/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

class price_listVC: UIViewController {

    var delegate:price_listVC_delegate?

    public var selectedItem: product_pricelist_class!
    
    var refreshControl_tableview = UIRefreshControl()
    @IBOutlet var tableview: UITableView!

    let con = SharedManager.shared.conAPI()
    var pricelists:  [product_pricelist_class]! = []
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        pricelists  = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        selectedItem = nil
        
        initPricelists()
            getPricelists()
    }
    
    func initPricelists()   {
        
        refreshControl_tableview.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl_tableview.addTarget(self, action: #selector(refreshOrder(sender:)), for: UIControl.Event.valueChanged)
        tableview.addSubview(refreshControl_tableview) // not required when using UITableViewContr
    }
    
    
    @objc func refreshOrder(sender:AnyObject) {
        // Code to refresh table view
        con.userCash = .stopCash
        getPricelists()
    }
    
   
    func getPricelists()
    {
        loadingClass.show(view: self.view)
        
        self.pricelists.removeAll()
        self.pricelists.append(contentsOf:product_pricelist_class.getAll(deleted:false)  )
        
        self.tableview?.reloadData()
        
        /*
        con.get_product_pricelist { (results) in
            self.refreshControl_tableview.endRefreshing()
            loadingClass.hide()
            
            let response = results.response
            //            let header = results.header
            
            let list:Array<Any> = response?["result"] as! Array
            
            self.pricelists.removeAll()
            self.pricelists.append(contentsOf:list )
            
            self.tableview?.reloadData()
            
        }
 */
    }

    @IBAction func btnBack(_ sender: Any) {
        self .dismiss(animated: true, completion: nil)
    
       

    }
}



extension price_listVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        selectedItem = pricelists[indexPath.row]
  
//          selectedItem = product_pricelist(fromDictionary: customer!)
        
         delegate?.priceListSelected()
         self.btnBack(!)
    }
    
}

extension price_listVC: UITableViewDataSource   {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //     func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    //        return "Section \(section)"
    //    }
    //
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pricelists.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! priceListTableViewCell
        
        let cls = pricelists[indexPath.row]
//        let cls = product_pricelist(fromDictionary: obj as! [String : Any])
        
        cell.row = cls
        cell.updateCell()
        
        
        return cell
    }
    
    
    
}

protocol price_listVC_delegate {
    func priceListSelected()
}
