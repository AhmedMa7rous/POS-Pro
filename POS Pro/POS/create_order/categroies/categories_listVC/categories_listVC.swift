//
//  Category s_listVC.swift
//  pos
//
//  Created by khaled on 8/19/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import UIKit

class categories_listVC: UIViewController {

    public var selectedCategory  : categoryClass!
    
    @IBOutlet var searchBar: UISearchBar!

    var refreshControl_tableview = UIRefreshControl()
    @IBOutlet var tableview: UITableView!

    let con = api()
    var list_Category:  [Any] = []
    var list_Category_search:  [Any] = []

    

    override func viewDidLoad() {
        super.viewDidLoad()

        let attributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20), NSAttributedString.Key.foregroundColor: UIColor.gray]
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = attributes

        // Do any additional setup after loading the view.
        selectedCategory  = nil
        
        initCategory()
            getCategory()
    }
    
    func initCategory()   {
        
        refreshControl_tableview.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl_tableview.addTarget(self, action: #selector(refreshOrder(sender:)), for: UIControl.Event.valueChanged)
        tableview.addSubview(refreshControl_tableview) // not required when using UITableViewContr
    }
    
    
    @objc func refreshOrder(sender:AnyObject) {
        // Code to refresh table view
        getCategory()
    }
    
   
    func getCategory()
    {
        loadingClass.show(view: self.view)
        
        
        con.get_pos_gategory { (results) in
            self.refreshControl_tableview.endRefreshing()
            loadingClass.hide()
            
            let response = results.response
            //            let header = results.header
            
            let list:Array<Any> = response?["result"] as! Array
            
            self.list_Category.removeAll()
            self.list_Category.append(contentsOf:list )
            
            self.list_Category_search.removeAll()
            self.list_Category_search.append(contentsOf:list )
            
            
            self.tableview?.reloadData()
            
        }
    }

    @IBAction func btnBack(_ sender: Any) {
        self .dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func btnAll(_ sender: Any) {
        
        selectedCategory = categoryClass()
        selectedCategory.id = 0
        btnBack(sender)
    }
    
}


typealias categories_list = categories_listVC

extension categories_list: UITableViewDelegate ,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
           let Category  = list_Category_search[indexPath.row] as? [String : Any]
  
        selectedCategory  = categoryClass(fromDictionary: Category!  )
        
         self.btnBack(!)
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
  
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list_Category_search.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! categoriesTableViewCell
        
        let obj = list_Category_search[indexPath.row]
        let Category  = categoryClass(fromDictionary: obj as! [String : Any])
        
        cell.category  = Category
        cell.updateCell()
        
        
        return cell
    }
}



typealias search_categories = categories_listVC
extension search_categories : UISearchBarDelegate
{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if(!(searchBar.text?.isEmpty)!){
            //reload your data source if necessary
            //            self.collectionView?.reloadData()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(!searchText.isEmpty){
            //reload your data source if necessary
            //            self.collectionView?.reloadData()
            
            let searchPredicate = NSPredicate(format: "name CONTAINS[c] %@", searchBar.text! )
            let array = (self.list_Category_search as NSArray).filtered(using: searchPredicate)
            list_Category_search = array
            
            self.tableview.reloadData()
            
            
        }
        else
        {
            list_Category_search = list_Category
//
            self.tableview.reloadData()
        }
        
        
    }
    
}
