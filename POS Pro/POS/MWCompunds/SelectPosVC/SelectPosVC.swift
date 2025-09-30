//
//  SelectPosVC.swift
//  pos
//
//  Created by M-Wageh on 05/06/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import UIKit

class SelectPosVC: UIViewController {

    
     @IBOutlet weak var selectPosTable: UITableView!

     var dataList:[pos_config_class]?
     var selectDataList:[pos_config_class]?
     var completionBlock:(([pos_config_class])->())?

     override func viewDidLoad() {
         super.viewDidLoad()
         initalList()
         setupTable()
     }
     func initalList(){
         dataList = []
         self.dataList?.append(contentsOf: pos_config_class.getAllFromDB())

//         self.dataList?.append(contentsOf: pos_config_class.getAll().map(){pos_config_class(fromDictionary: $0)})
     }
     
     func isItemSelect(_ item:pos_config_class)->Bool{
         if let selectDataList = self.selectDataList {
             return selectDataList.filter { existItem in
                return existItem.id == item.id
             }.count > 0
             }
         return false
     }

     func itemSelecte(at indexPath:IndexPath){
         if let item = self.dataList?[indexPath.row]{
                 if isItemSelect(item) {
                     if let index_select = selectDataList?.firstIndex(where: {return $0.id == item.id}) {
                     selectDataList?.remove(at: index_select)
                     }
                 }else{
                     selectDataList?.append(item)
                 }
             
        }
         self.selectPosTable.reloadData()
         self.completionBlock?(selectDataList ?? [])

     }
     
     @IBAction func tapOnCancel(_ sender: Any) {
         self.dismiss(animated: true, completion: nil)

     }
     
     @IBAction func tapOnDone(_ sender: Any) {
         self.dismiss(animated: true, completion: {
             self.completionBlock?(self.selectDataList ?? [])
         })
     }
     static func createModule(_ sender:UIView?,selectDataList:[pos_config_class]?) -> SelectPosVC {
         let vc:SelectPosVC = SelectPosVC()
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
 extension SelectPosVC:UITableViewDelegate,UITableViewDataSource{
     func setupTable(){
 //        selectPosTable.rowHeight = UITableView.automaticDimension
 //        selectPosTable.estimatedRowHeight = 70
         selectPosTable.register(UINib(nibName: "SelectCell", bundle: nil), forCellReuseIdentifier: "SelectCell")
         selectPosTable.delegate = self
         selectPosTable.dataSource = self
         self.selectPosTable.reloadData()
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
                  
              
              cell.bindData(text: item.name ?? "", hideImage: !isItemSelect(item))
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
