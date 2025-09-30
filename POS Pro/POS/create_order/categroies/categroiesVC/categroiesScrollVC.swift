//
//  categroiesVC.swift
//  pos
//
//  Created by khaled on 9/14/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit


class categroiesScrollVC: UIViewController ,categoryTableViewCell_delegate {

       var delegate:categroiesScrollVC_delegate?

    
    @IBOutlet var tableview: UITableView!
    
  var view_collection_container: UIView!
    var view_container: UIView!

    
       let con = api()
    
    var categories:[Any]! = []
    var all_categories:[Any]! = []
    
    var last_categ_selected:[Int:[String:Int]] = [:] // id , level
    var last_categ_selected_level:Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

 
        
        
        self.tableview.register(categoryTableViewCell.self, forCellReuseIdentifier: "cell")

      getCategory()
        
    }

    func getCategory() {
         
        self.all_categories = api.get_last_cash_result(keyCash: "get_pos_gategory")
//        let response = results.response
//                   self.all_categories = response?["result"] as? [Any] ?? []
                   
                   var main_categ = categoryClass.getCategoryTopLevel(list: self.all_categories)
                   
                   let all = ["id": 0, "name": "All", "parent_id": false, "child_id": []] as [String : Any]
                   
                    main_categ.insert(all, at: 0)

                   self.categories.append(main_categ)
                   
                   self.tableview.reloadData()
        
//        con.get_pos_gategory { (results) in
//            if (!results.success)
//            {
//                return
//            }
//
//            let response = results.response
//            self.all_categories = response?["result"] as? [Any] ?? []
//
//            var main_categ = categoryClass.getCategoryTopLevel(list: self.all_categories)
//
//            let all = ["id": 0, "name": "All", "parent_id": false, "child_id": []] as [String : Any]
//
//             main_categ.insert(all, at: 0)
//
//            self.categories.append(main_categ)
//
//            self.tableview.reloadData()
//        }
    }
 
}

typealias tableViewDelegate_category = categroiesScrollVC
extension tableViewDelegate_category: UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
   
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        //        item_order_selected = list_orders[indexPath.row] as? [String : Any]
        //        item_indexPath_selected = indexPath
        
   
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //     func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    //        return "Section \(section)"
    //    }
    //
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! categoryTableViewCell
//
        let list:[Any] =  categories?[indexPath.row] as! [Any]
//        //        let product = productClass(fromDictionary: obj as! [String : Any])
//
//        cell.product = product
//        cell.priceList = priceListVC.selectedItem
//
         cell.last_categ_selected = last_categ_selected
        cell.last_categ_selected_level = last_categ_selected_level
         cell.delegate = self
         cell.list_categ = list
         cell.update()
        
        
        return cell
    }
    
//    func setLastSelectCateg(id:Int,level:Int)  {
//         last_categ_selected[0] = id
//        last_categ_selected[1] = level
//    }
//    func getLastSelected_id() -> Int {
//        return    last_categ_selected[0]
//    }
//
//    func getLastSelected_level() -> Int {
//        return    last_categ_selected[1]
//    }

    func get_child_categ(categ:categoryClass , didSelectItemAt indexPath: IndexPath)
    {
        delegate?.categorySelected(categ: categ)
        
        let categ_level = categ.getLevel()
        
        let num_level = categories.count - 1
 
         categories = reLevel(level: categ_level)
        
    
        var temp :[String:Int] = [:]
        temp["id"] = categ.id
        temp["level"] = categ_level
        temp["index_row"] = indexPath.row

        last_categ_selected_level = categ_level
        last_categ_selected[categ_level] = temp
        
        clearUpLevel(level: categ_level)
        
        
        let child:[Any] = categoryClass.getCategoryChild(categ: categ, list: all_categories)
        
        
        ExpandOrCollapse(categ_level: categ_level, child_count: child.count)
        
        
        
        if child.count > 0
        {
            
            categories.append(child)
            tableview.reloadData()
//            let range = NSMakeRange(0, self.tableview.numberOfSections)
//            let sections = NSIndexSet(indexesIn: range)
//            self.tableview.reloadSections(sections as IndexSet, with: .fade)
//
            tableview.scrollToLastCell( atscrollPosition: .bottom ,animated: true)
        }
        else
        {
//             tableview.reloadData()
            
            let range = NSMakeRange(0, self.tableview.numberOfSections)
            let sections = NSIndexSet(indexesIn: range)
//
            if num_level > categ_level
            {
//                 tableview.reloadData()
                self.tableview.reloadSections(sections as IndexSet, with: .fade)
//                tableview.scrollToLastCell(atscrollPosition: .middle , animated: true)

            }
            else
            {
                    tableview.reloadData()
 
            }
        
            
        }
        
        
       
        
    }
    
    
    func ExpandOrCollapse(categ_level: Int , child_count:Int)
    {
        let height = self.view_container.frame.height
        if height < 170 && child_count > 0
        {
            Expand()
        }
        else
        {
            if categ_level == 0
            {
                collapse()
            }
            
        }

    }
    
    
    func collapse()
    {
        
            let frm :CGRect = CGRect.init(x: self.view_container.frame.origin.x, y:  self.view_container.frame.origin.y
                , width:  self.view_container.frame.size.width , height: 75 + 75)
            
            UIView.animate(withDuration: 0.3) {
                //            self.view.frame = frm
                self.view_container.frame = frm
                
                self.view_collection_container.frame = CGRect.init(x: self.view_collection_container.frame.origin.x,
                                                                   y:  130 + 75
                    , width:  self.view_collection_container.frame.size.width , height: 638 - 75 )
            }
            
            
        
    }
    
    func Expand()
    {
       
            let frm :CGRect = CGRect.init(x: self.view_container.frame.origin.x, y:  self.view_container.frame.origin.y
                , width:  self.view_container.frame.size.width , height: 150 + 150)
            
            UIView.animate(withDuration: 0.3) {
                //            self.view.frame = frm
                self.view_container.frame = frm
                
                self.view_collection_container.frame = CGRect.init(x: self.view_collection_container.frame.origin.x,
                                                                   y:  self.view_collection_container.frame.origin.y + 75 + 75
                    , width:  self.view_collection_container.frame.size.width , height: self.view_collection_container.frame.size.height - 75 - 75 )
            }
            
            
        
    }
  
    
    func clearUpLevel(level:Int)  {
        
        for (item,_) in last_categ_selected
        {
            if item > level
            {
              last_categ_selected.removeValue(forKey: item)
            }
            
        }
        
    }
    
    
    func reLevel (level:Int) -> [Any] {
        var newCategories:[Any] = []
        
        for i in 0...level
        {
            newCategories.append(categories[i])
        }
        
        
        return newCategories
    }
    
}


protocol categroiesScrollVC_delegate {
    func categorySelected(categ:categoryClass)
}
