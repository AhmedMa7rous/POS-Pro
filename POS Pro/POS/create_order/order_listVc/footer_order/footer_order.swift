//
//  options_listVC.swift
//  pos
//
//  Created by Khaled on 4/8/20.
//  Copyright © 2020 khaled. All rights reserved.
//
/**

 list.didSelect = { [weak self] data in
     let dic = data
     
     SharedManager.shared.printLog("%@" ,dic)
 }
 
 */

import UIKit

class footer_order: UIViewController , UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet var tableview: UITableView!
    
 
    var list_items:[String:String] = [:]
    
   private var all_keys:[String] = []
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
     }
    
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
       
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let title = all_keys[indexPath.row]

        if  title.lowercased().hasPrefix( "0notes")
        {
            let value = list_items[title] ?? ""
            if value.isEmpty
            {
                return 0
            }
            else
            {
                return 80

            }

        }
        return 60
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = all_keys.count
        return  count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var identifier = "cell"
        
        var cell_nib = "footer_order_listTableViewCell"
        let title = all_keys[indexPath.row]
        
        if  title.lowercased().hasPrefix( "0notes")
         {
                  cell_nib = "footer_order_notesTableViewCell"
                  identifier = "footer_order_notesTableViewCell"
            
            var cell: footer_order_notesTableViewCell! = tableView.dequeueReusableCell(withIdentifier: identifier) as? footer_order_notesTableViewCell
                         if cell == nil {
                          tableView.register(UINib(nibName: cell_nib, bundle: nil), forCellReuseIdentifier: identifier)
                          cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? footer_order_notesTableViewCell
                         }

                 
              
                  let value = list_items[title]

//                  cell.lblTtile?.text = title
                 cell.lbl_value?.text = value
              
                  if  title.lowercased().hasPrefix( "1total")
                  {
                      cell.bg_img.isHighlighted = false
                      cell.lblTtile?.textColor = UIColor.init(hexString: "#4B4B4B")
                      cell.lbl_value?.textColor = UIColor.init(hexString: "#4B4B4B")
                    cell.lblTtile?.text = LanguageManager.currentLang() == .ar ? "المجموع بدون ضريبة " : "Subtotal w/o"
                  }
                  else
                  {
                      cell.bg_img.isHighlighted = true
                      cell.lblTtile?.textColor = UIColor.init(hexString: "#767676")
                     cell.lbl_value?.textColor = UIColor.init(hexString: "#6E6E6E")

                  }
                return cell
         }
        else
        {
            var cell: footer_order_listTableViewCell! = tableView.dequeueReusableCell(withIdentifier: identifier) as? footer_order_listTableViewCell
                         if cell == nil {
                          tableView.register(UINib(nibName: cell_nib, bundle: nil), forCellReuseIdentifier: identifier)
                          cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? footer_order_listTableViewCell
                         }

                 
              
                  let value = list_items[title]

                  cell.lblTtile?.text = title
                 cell.lbl_value?.text = value
              
                  if  title.lowercased().hasPrefix( "1total")
                  {
                      cell.bg_img.isHighlighted = false
                      cell.lblTtile?.textColor = UIColor.init(hexString: "#4B4B4B")
                      cell.lbl_value?.textColor = UIColor.init(hexString: "#4B4B4B")
                    cell.lblTtile?.text =   title.replacingOccurrences(of: "1Total", with: LanguageManager.currentLang() == .ar ? "المجموع بدون ضريبة " : "Subtotal w/o").replacingOccurrences(of: "items", with: "items".arabic("منتج"))

                  }
                  else
                  {
                      cell.bg_img.isHighlighted = true
                      cell.lblTtile?.textColor = UIColor.init(hexString: "#767676")
                     cell.lbl_value?.textColor = UIColor.init(hexString: "#6E6E6E")

                  }
            
                return cell
        }
        
        
      
        
    
    }
    
    @IBAction func btnCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func  reload()   {
        
        all_keys.removeAll()
        tableview.reloadData()

        
                all_keys.append(contentsOf: list_items.keys)
        
        all_keys.sort(by: <)
        
        tableview.reloadData()

    }
    
}
