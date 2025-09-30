//
//  DriverListVC.swift
//  pos
//
//  Created by M-Wageh on 16/09/2021.
//  Copyright © 2021 khaled. All rights reserved.
//

import UIKit
class DriverListRouter{
    static func createModule(_ sender:UIView?,selectDriver:pos_driver_class?) -> DriverListVC {
        let vc:DriverListVC = DriverListVC()
        vc.selectDriver = selectDriver
        if let sender = sender{
            vc.modalPresentationStyle = .popover
//            vc.preferredContentSize = CGSize(width: 120, height: 120)
            vc.popoverPresentationController?.sourceView = sender
            vc.popoverPresentationController?.sourceRect = sender.bounds
        }
        return vc
    }
}
class DriverListVC: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var driversTable: UITableView!
    var driverList:[pos_driver_class] = []
    var driverListFilter:[pos_driver_class] = []
    var selectDriver:pos_driver_class? = nil
    var completionBlock:((pos_driver_class)->())?

    override func viewDidLoad() {
        super.viewDidLoad()
        driverList = pos_driver_class.getAll()
        driverListFilter.append(contentsOf:driverList )
        setupTable()
        if LanguageManager.currentLang() == .ar {
            searchBar.placeholder = "ابحث هنا..."
        }

    }
    
    @IBAction func tapOnBack(_ sender: KButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tapOnSearchBtn(_ sender: UIButton) {
    }
}
extension DriverListVC:UITableViewDelegate,UITableViewDataSource{
    func setupTable(){
        driversTable.rowHeight = UITableView.automaticDimension
        driversTable.estimatedRowHeight = 100
//        refreshControl.addTarget(self, action: #selector(refreshStoredItemTable), for: .valueChanged)
//        StoredItemTable.addSubview(refreshControl)
        driversTable.register(UINib(nibName: "DriverCell", bundle: nil), forCellReuseIdentifier: "DriverCell")
        self.driversTable.reloadData()
    }
   
    // MARK: - Table view data source
     func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return driverListFilter.count
    }

    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DriverCell", for: indexPath) as! DriverCell
        // Configure the cell...
        cell.driver = driverListFilter[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: true, completion: {
            self.completionBlock?(self.driverListFilter[indexPath.row])
        })
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
extension DriverListVC : UISearchBarDelegate
{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if(!(searchBar.text?.isEmpty)!){
            //reload your data source if necessary
            //            self.collectionView?.reloadData()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(!searchText.isEmpty){
            let word = (searchBar.text ?? "").lowercased()
            driverListFilter.removeAll()
            self.driversTable.reloadData()
            driverListFilter = self.driverList.filter { item in
              let isContainName =  item.name?.lowercased().contains(word) ?? false
                let isContaineCode =  item.code?.lowercased().contains(word) ?? false
                return (isContainName || isContaineCode)

            }
            self.driversTable.reloadData()
        }
        else
        {
            driverListFilter = driverList
            self.driversTable.reloadData()
        }
        
        
    }
    
}
