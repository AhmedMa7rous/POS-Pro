//
//  SelectPrintersIPVC.swift
//  pos
//
//  Created by M-Wageh on 18/11/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import UIKit

class SelectPrintersIPVC: UIViewController {

    @IBOutlet weak var selectPrinterTable: UITableView!

    var dataList:[restaurant_printer_class]?
    var selectDataList:[restaurant_printer_class]?
    var completionBlock:(([restaurant_printer_class])->())?
    var printerType:DEVICES_TYPES_ENUM?
    override func viewDidLoad() {
        super.viewDidLoad()
        initalList()
        setupTable()
    }
    func initalList(){
        dataList = []
        if let printerType = printerType {
            self.dataList?.append(contentsOf: restaurant_printer_class.get(printer_type: printerType ))
        }else{
            self.dataList?.append(contentsOf: restaurant_printer_class.getAll().map(){restaurant_printer_class(fromDictionary: $0)})
        }
    }
    
    func isItemSelect(_ item:restaurant_printer_class)->Bool{
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
        self.selectPrinterTable.reloadData()
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
    static func createModule(_ sender:UIView?,
                             selectDataList:[restaurant_printer_class]?,
                             printerType:DEVICES_TYPES_ENUM?) -> SelectPrintersIPVC {
        let vc:SelectPrintersIPVC = SelectPrintersIPVC()
        vc.selectDataList = selectDataList ?? []
        vc.printerType = printerType
        if let sender = sender{
            vc.modalPresentationStyle = .popover
//            vc.preferredContentSize = CGSize(width: 120, height: 120)
            vc.popoverPresentationController?.sourceView = sender
            vc.popoverPresentationController?.sourceRect = sender.bounds
        }
        return vc
    }
    

}
extension SelectPrintersIPVC:UITableViewDelegate,UITableViewDataSource{
    func setupTable(){
//        selectPrinterTable.rowHeight = UITableView.automaticDimension
//        selectPrinterTable.estimatedRowHeight = 70
        selectPrinterTable.register(UINib(nibName: "SelectCell", bundle: nil), forCellReuseIdentifier: "SelectCell")
        selectPrinterTable.delegate = self
        selectPrinterTable.dataSource = self
        self.selectPrinterTable.reloadData()
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
