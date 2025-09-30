//
//  SelectOrderTypesVC.swift
//  pos
//
//  Created by M-Wageh on 05/06/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import UIKit

class SelectOrderTypesVC: UIViewController {

   
    @IBOutlet weak var selectOrderTypeTable: UITableView!

    var dataList:[delivery_type_class]?
    var selectDataList:[delivery_type_class]?
    var completionBlock:(([delivery_type_class])->())?

    override func viewDidLoad() {
        super.viewDidLoad()
        initalList()
        setupTable()
    }
    func initalList(){
        dataList = []
        self.dataList?.append(contentsOf: delivery_type_class.getAll().map(){delivery_type_class(fromDictionary: $0)})
    }
    
    func isItemSelect(_ item:delivery_type_class)->Bool{
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
        self.selectOrderTypeTable.reloadData()
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
    static func createModule(_ sender:UIView?,selectDataList:[delivery_type_class]?) -> SelectOrderTypesVC {
        let vc:SelectOrderTypesVC = SelectOrderTypesVC()
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
extension SelectOrderTypesVC:UITableViewDelegate,UITableViewDataSource{
    func setupTable(){
//        selectOrderTypeTable.rowHeight = UITableView.automaticDimension
//        selectOrderTypeTable.estimatedRowHeight = 70
        selectOrderTypeTable.register(UINib(nibName: "SelectCell", bundle: nil), forCellReuseIdentifier: "SelectCell")
        selectOrderTypeTable.delegate = self
        selectOrderTypeTable.dataSource = self
        self.selectOrderTypeTable.reloadData()
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
                 
             
             cell.bindData(text: item.display_name, hideImage: !isItemSelect(item))
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
