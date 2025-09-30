//
//  SelectDeviceStatusVC.swift
//  pos
//
//  Created by M-Wageh on 22/08/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import UIKit

class SelectDeviceStatusVC: UIViewController {

  
    @IBOutlet weak var selectDeviceStatusTable: UITableView!

    var dataList:[SOCKET_DEVICE_STATUS]?
    var selectDataList:[SOCKET_DEVICE_STATUS]?
    var completionBlock:(([SOCKET_DEVICE_STATUS])->())?

    override func viewDidLoad() {
        super.viewDidLoad()
        initalList()
        setupTable()
    }
    func initalList(){
        dataList = []
        self.dataList?.append(contentsOf: SOCKET_DEVICE_STATUS.getAll())
    }
    
    func isItemSelect(_ item:SOCKET_DEVICE_STATUS)->Bool{
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
    static func createModule(_ sender:UIView?,selectDataList:[SOCKET_DEVICE_STATUS]) -> SelectDeviceStatusVC {
        let vc:SelectDeviceStatusVC = SelectDeviceStatusVC()
        vc.selectDataList =  selectDataList
        if let sender = sender{
            vc.modalPresentationStyle = .popover
//            vc.preferredContentSize = CGSize(width: 120, height: 120)
            vc.popoverPresentationController?.sourceView = sender
            vc.popoverPresentationController?.sourceRect = sender.bounds
        }
        return vc
    }
    

}
extension SelectDeviceStatusVC:UITableViewDelegate,UITableViewDataSource{
    func setupTable(){
//        selectDeviceStatusTable.rowHeight = UITableView.automaticDimension
//        selectDeviceStatusTable.estimatedRowHeight = 70
        selectDeviceStatusTable.register(UINib(nibName: "SelectCell", bundle: nil), forCellReuseIdentifier: "SelectCell")
        selectDeviceStatusTable.delegate = self
        selectDeviceStatusTable.dataSource = self
        self.selectDeviceStatusTable.reloadData()
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
                 
             
             cell.bindData(text: item.getDescription(), hideImage: !isItemSelect(item))
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
