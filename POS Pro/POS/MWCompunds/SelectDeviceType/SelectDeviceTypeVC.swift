//
//  SelectDeviceTypeVC.swift
//  pos
//
//  Created by M-Wageh on 22/08/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import UIKit



class SelectDeviceTypeVC: UIViewController {

    @IBOutlet weak var selectDeviceTypeTable: UITableView!

    var dataList:[DEVICES_TYPES_ENUM]?
    var selectDataList:[DEVICES_TYPES_ENUM]?
    var completionBlock:(([DEVICES_TYPES_ENUM])->())?

    override func viewDidLoad() {
        super.viewDidLoad()
        //initalList()
        setupTable()
    }
    func initalList(){
        dataList = []
        self.dataList?.append(contentsOf: DEVICES_TYPES_ENUM.getAll())
    }
    
    func isItemSelect(_ item:DEVICES_TYPES_ENUM)->Bool{
        return false
    }

    func itemSelecte(at indexPath:IndexPath){
        if let item = self.dataList?[indexPath.row]{
            selectDataList?.removeAll()
            selectDataList?.append(item)
       }
        self.dismiss(animated: true, completion: {
            self.completionBlock?(self.selectDataList ?? [])
        })

        

    }
    
    @IBAction func tapOnCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)

    }
    
    @IBAction func tapOnDone(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            self.completionBlock?(self.selectDataList ?? [])
        })
    }
    static func createModule(_ sender:UIView?, dataList:[DEVICES_TYPES_ENUM]) -> SelectDeviceTypeVC {
        let vc:SelectDeviceTypeVC = SelectDeviceTypeVC()
        vc.selectDataList =  []
        vc.dataList = dataList
        if let sender = sender{
            vc.modalPresentationStyle = .popover
//            vc.preferredContentSize = CGSize(width: 120, height: 120)
            vc.popoverPresentationController?.sourceView = sender
            vc.popoverPresentationController?.sourceRect = sender.bounds
        }
        return vc
    }
    

}
extension SelectDeviceTypeVC:UITableViewDelegate,UITableViewDataSource{
    func setupTable(){
//        selectDeviceTypeTable.rowHeight = UITableView.automaticDimension
//        selectDeviceTypeTable.estimatedRowHeight = 70
        selectDeviceTypeTable.register(UINib(nibName: "SelectCell", bundle: nil), forCellReuseIdentifier: "SelectCell")
        selectDeviceTypeTable.delegate = self
        selectDeviceTypeTable.dataSource = self
        self.selectDeviceTypeTable.reloadData()
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
                 
             
             cell.bindData(text: item.getLocalizeName(), hideImage: !isItemSelect(item))
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
