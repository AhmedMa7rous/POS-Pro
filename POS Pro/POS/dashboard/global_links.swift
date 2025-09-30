//
//  setting_home.swift
//  pos
//
//  Created by khaled on 9/30/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

class global_links: UIViewController {
    
     var posConfig:pos_configration?
    var addPrinter_page :addPrinter?
    var cls_load_all_apis = load_base_apis()
    
    var current_report:zReport!
    
    @IBOutlet var container: UIView!
    
    @IBOutlet var tableview: UITableView!
    var list_items:  [Any] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

      initList()
        
    }
    
    func btnPriceList(_ sender: Any)
    {
        
    }
    
    @IBAction func btnOpenMenu(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        appDelegate.centerContainer?.open(.left, animated: true, completion: nil)
    }
    
    func Inventory()
    {
        let storyboard = UIStoryboard(name: "dashboard", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "webViewController") as! webViewController
        controller.title_top = "Inventory"
        controller.url = "http://www.gofekra.com/web#action=195&model=stock.inventory&view_type=list&menu_id=98"
        
        controller.view.frame = container.bounds
        
        container.addSubview(controller.view)
    }
    
 
    
    
    func clearView()
    {
        
        if posConfig != nil {
            posConfig?.removeFromParent()
        }
     
    }
    
    
    @IBAction func btnPrint(_ sender: Any) {
     }
    
}


extension global_links: UITableViewDelegate ,UITableViewDataSource {
    
    func initList()
    {
        
        
        list_items = []
        
        
        list_items.append(["Inventory","icon_history.png"])
//          list_items.append(["Sync","icon_history.png"])
////        list_items.append(["Database","icon_history.png"])
//        list_items.append(["Printer","icon_history.png"])
//        list_items.append(["Setting","icon_history.png"])

//        list_items.append(["__ Find printer","icon_history.png"])

        
        
        self.tableview.reloadData()
        
    }
    
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
        let item = list_items[indexPath.row] as? [String]
        
        switch item![0] {
        case "Inventory":
            Inventory()
  
        default:
            break
            
        }
        
        
        
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list_items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! global_linksTableViewCell
        
        let item = list_items[indexPath.row] as? [String]
        
        
        cell.lblTitle.text = item?[0]
        cell.photo.image = UIImage(name: item![1])
        
        
        return cell
    }
    
    
}
