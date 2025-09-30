//
//  new_customers_listVC.swift
//  pos
//
//  Created by Muhammed Elsayed on 02/04/2024.
//  Copyright © 2024 khaled. All rights reserved.
//

import UIKit
import Security

class new_customers_listVC: UIViewController ,addCustomer_delegate_new{
    //MARK: Outlets
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableview: UITableView!
    @IBOutlet weak var syncCustomer: UIButton!
    
    //MARK: Variables
    public var selectedCustomer : res_partner_class!
    var add_Customer:addCustomerNew!
    var completionBlock:((res_partner_class)->())?
    var refreshControl_tableview = UIRefreshControl()
    let con = SharedManager.shared.conAPI()
    var list_Customers:  [Any] = []
    var list_Customers_search:  [Any] = []
    var currentPage:Int = 0
    var limit:Int = 30
    var isLast:Bool = false
    var last_cell_index:Int = 0
    var searchWord:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedCustomer = nil
        setupTable()
        initCustomers()
        //getCustomers()
        
        refersh()
        if LanguageManager.currentLang() == .ar {
            searchBar.placeholder = "ابحث هنا..."
        }
        
       // removeBackground(from:  searchBar)
        
    }
    deinit {
        SharedManager.shared.printLog("new_customers_listVC is being deinitialized")
    }

    private func setupTable() {
        tableview.register(UINib(nibName: "newCustomerTableViewCell", bundle: nil), forCellReuseIdentifier: "newCustomerTableViewCell")
    }
 private func removeBackground(from searchBar: UISearchBar) {
     guard let BackgroundType = NSClassFromString("_UISearchBarSearchFieldBackgroundView") else { return }

     for v in searchBar.allSubViewsOf(type: UIView.self) where v.isKind(of: BackgroundType){
         v.removeFromSuperview()
     }
 }
    
    func initCustomers()   {
        
        refreshControl_tableview.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl_tableview.addTarget(self, action: #selector(refreshOrder(sender:)), for: UIControl.Event.valueChanged)
        tableview.addSubview(refreshControl_tableview) // not required when using UITableViewContr
    }
    
    
    @objc func refreshOrder(sender:AnyObject) {
        // Code to refresh table view
        con.userCash = .stopCash
        refersh()
        //getCustomers()
    }
    func refersh(){
        isLast = false
        last_cell_index = 0
        currentPage = 0
        self.list_Customers.removeAll()
        self.list_Customers_search.removeAll()
        getCustomersPagenation()
    }
    func reload_customers(customer:res_partner_class) {
        if customer.id == -1
        {
            selectedCustomer = customer
            
              self .dismiss(animated: true, completion: nil)
            
        }
        else
        {
            if let complete = self.completionBlock {
                complete(customer)
            }
            self.refersh()
        }
       
        
       
  
    }
    
    @IBAction func tapOnSyncCustomerBtn(_ sender: UIButton) {
        loadingClass.show(view: self.view)
        MWSyncCustomer.hitSyncCustomerAPI { result in
            SharedManager.shared.printLog(result?.response)
            loadingClass.hide(view: self.view)
            self.tableview?.reloadData()
            self.refersh()
//            self.getCustomers()

        }
        
    }
    func getCustomersPagenation(){
        if isLast{
            return
        }
        if currentPage == 0
        {
            last_cell_index = 0
            self.list_Customers_search.removeAll()
            self.tableview?.reloadData()
        }
        var pageCustomer: [[String : Any]] = []
        if self.searchWord.count > 0{
            pageCustomer = res_partner_class.search(by:self.searchWord ,page:self.currentPage,limit: self.limit )

        }else{
             pageCustomer = res_partner_class.get(page:self.currentPage,limit: self.limit )

        }
        if pageCustomer.count < limit {
            isLast = true
        }else{
            self.currentPage += 1
        }
        
        self.list_Customers_search.append(contentsOf:pageCustomer )
        
        self.tableview?.reloadData()
        self.refreshControl_tableview.endRefreshing()
    }
    func getCustomers()
    {
        
        self.list_Customers.removeAll()
        
         
        let list = res_partner_class.getAll() // api.get_last_cash_result(keyCash: "customers_list")
        
         self.list_Customers.append(contentsOf:list )
        
        self.list_Customers_search.removeAll()
        self.list_Customers_search.append(contentsOf:self.list_Customers )
        
        
        self.tableview?.reloadData()
        self.refreshControl_tableview.endRefreshing()
        
        
    }

    @IBAction func btnAddCustomer(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "customers", bundle: nil)
        add_Customer = storyboard.instantiateViewController(withIdentifier: "addCustomerNew") as? addCustomerNew
        add_Customer!.modalPresentationStyle = .formSheet
        add_Customer?.initalValue = self.searchWord
        add_Customer.delegate = self
        
        
        self.present(add_Customer!, animated: true, completion: nil)
    }
    
    
    @IBAction func btnBack(_ sender: Any) {
        DispatchQueue.main.async{
        self .dismiss(animated: true, completion: {
            if let complete = self.completionBlock,  let customer = self.selectedCustomer{
                complete(customer)
            }
        })
        }
    }
}



extension new_customers_listVC: UITableViewDelegate ,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
           let customer = list_Customers_search[indexPath.row] as? [String : Any]
        let customerObject = res_partner_class(fromDictionary: customer!)
        var deliveryContacts = customerObject.getDeliveryContacts()
        deliveryContacts.append(customerObject)
        if deliveryContacts.count > 1 {
            let selectUservc:SelectResPartnerVC = SelectResPartnerVC.createModule(tableView.cellForRow(at: indexPath),selectDataList:  [],dataList:deliveryContacts)
                selectUservc.completionBlock = { selectDataList in
                    if  selectDataList.count > 0{
                        if (selectDataList.first?.id ?? 0) == -1{
                            self.selectedCustomer = nil
                        }else{
                            self.selectedCustomer = selectDataList.first
                            self.btnBack(!)
                        }
                    }
                }
                self.present(selectUservc, animated: true, completion: nil)
            
        }else{
            selectedCustomer = res_partner_class(fromDictionary: customer!)
            
            self.btnBack(!)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
  
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list_Customers_search.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "newCustomerTableViewCell", for: indexPath) as! newCustomerTableViewCell
        
        let obj = list_Customers_search[indexPath.row]
        let customer = res_partner_class(fromDictionary: obj as! [String : Any])
        
        cell.parent = self
        cell.customer = customer
        cell.updateCell()
        
        
        return cell
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
      
       if last_cell_index < indexPath.row
        {
            let lastItem = self.list_Customers_search.count - 1
            if lastItem >= page_count - 1
            {
                if indexPath.row == lastItem {
//                    currentPage += 1
                    last_cell_index = indexPath.row
                    
                    self.getCustomersPagenation()
                }
            }
        }
        
        
    }
}

typealias search_new_customers = new_customers_listVC
extension search_new_customers : UISearchBarDelegate
{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchWord = searchBar.text ?? ""
        self.refersh()
        if(!(searchBar.text?.isEmpty)!){
            //reload your data source if necessary
            //            self.collectionView?.reloadData()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchWord = searchBar.text ?? ""
        self.refersh()
    }
    
}
