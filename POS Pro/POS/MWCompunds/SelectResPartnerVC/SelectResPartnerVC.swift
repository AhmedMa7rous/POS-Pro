//
//  SelectResPartnerVC.swift
//  pos
//
//  Created by M-Wageh on 25/09/2023.
//  Copyright © 2023 khaled. All rights reserved.
//

import UIKit

class SelectResPartnerVC: UIViewController {

    
    @IBOutlet weak var selectUsersTable: UITableView!
//Missing in merge
    var dataList:[res_partner_class]?
    var selectDataList:[res_partner_class]?
    var completionBlock:(([res_partner_class])->())?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTable()
    }
   
    
    func isItemSelect(_ item:res_partner_class)->Bool{
        if let selectDataList = self.selectDataList {
            return selectDataList.filter { existItem in
               return existItem.id == item.id
            }.count > 0
            }
        return false
    }

    func itemSelecte(at indexPath:IndexPath){
        if let item = self.dataList?[indexPath.row]{
                if !isItemSelect(item) {
                    selectDataList?.removeAll()
                    selectDataList?.append(item)
                    self.dismiss(animated: true, completion: {
                        self.completionBlock?(self.selectDataList ?? [])
                    })
                }else{
                    self.dismiss(animated: true, completion:nil)
                }
            
       }
//         self.selectUsersTable.reloadData()
//         self.completionBlock?(selectDataList ?? [])
       

    }
    
    @IBAction func tapOnCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)

    }
    
    @IBAction func tapOnDone(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            self.completionBlock?(self.selectDataList ?? [])
        })
    }
   static func createModule(_ sender:UIView?,selectDataList:[res_partner_class]?,dataList:[res_partner_class]) -> SelectResPartnerVC {
        let vc:SelectResPartnerVC = SelectResPartnerVC()
       vc.dataList = dataList
        vc.selectDataList = selectDataList ?? []
        if let sender = sender{
            vc.modalPresentationStyle = .popover
//            vc.preferredContentSize = CGSize(width: 120, height: 120)
            vc.popoverPresentationController?.sourceView = sender
            vc.popoverPresentationController?.sourceRect = sender.bounds
        }
        return vc
    }
    

}
extension SelectResPartnerVC:UITableViewDelegate,UITableViewDataSource{
    func setupTable(){
//        selectUsersTable.rowHeight = UITableView.automaticDimension
//        selectUsersTable.estimatedRowHeight = 70
        selectUsersTable.register(UINib(nibName: "SelectCell", bundle: nil), forCellReuseIdentifier: "SelectCell")
        selectUsersTable.delegate = self
        selectUsersTable.dataSource = self
        self.selectUsersTable.reloadData()
    }
   
    // MARK: - Table view data source
     func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return dataList?.count ?? 0
    }

    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectCell", for: indexPath) as! SelectCell
        // Configure the cell...
         if let item = self.dataList?[indexPath.row]{
             var name = item.name

             var title = ""
             if  !item.pos_delivery_area_name.isEmpty{
                 title = item.pos_delivery_area_name
             }
             cell.bindData(text:  "[\(name)] " + "\r" + title, hideImage: !isItemSelect(item))
         }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        itemSelecte(at:indexPath)
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }

}
