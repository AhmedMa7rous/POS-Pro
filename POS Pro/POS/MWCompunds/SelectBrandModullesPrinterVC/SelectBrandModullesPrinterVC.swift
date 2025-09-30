//
//  SelectBrandModullesPrinterVC.swift
//  pos
//
//  Created by M-Wageh on 05/06/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import UIKit

class SelectBrandModullesPrinterVC: UIViewController {

    @IBOutlet weak var selectTable: UITableView!
    enum SELECT_VIEW_TYPES{
        case BRAND , Model, TYPE, ConnectionType
    }
    var dataList:[String]?
    var selectDataList:[String]?
    var completionBlock:(([String])->())?
    var viewType:SELECT_VIEW_TYPES = SELECT_VIEW_TYPES.BRAND
    var brand:PRINTER_BRAND_TYPES?
    var connectionType: ConnectionTypes?
    override func viewDidLoad() {
        super.viewDidLoad()
        initalList()
        setupTable()
    }
    func initalList(){
        dataList = []
        switch viewType {
        case .BRAND:
            dataList?.append(contentsOf: PRINTER_BRAND_TYPES.getAllBrandString())
        case .Model:
            if let brand = brand {
                dataList?.append(contentsOf: brand.getAllModels())
            }

        case .TYPE:
            dataList?.append(contentsOf: DEVICES_TYPES_ENUM.getAllPrinterTypesString())

        case .ConnectionType:
            dataList?.append(contentsOf: ConnectionTypes.getAllConnectiontypesString())
        }
    }
    
    func isItemSelect(_ item:String)->Bool{
        if let selectDataList = self.selectDataList {
            return selectDataList.filter { existItem in
               return existItem == item
            }.count > 0
            }
        return false
    }

    func itemSelecte(at indexPath:IndexPath){
        if let item = self.dataList?[indexPath.row]{
            self.selectDataList?.removeAll()
            self.selectDataList?.append(item)
       }
//        self.selectTable.reloadData()
//        self.completionBlock?(selectDataList ?? [])
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
    static func createModule(_ sender:UIView?,selectDataList:[String]?,viewType:SELECT_VIEW_TYPES,brand:PRINTER_BRAND_TYPES?) -> SelectBrandModullesPrinterVC {
        let vc:SelectBrandModullesPrinterVC = SelectBrandModullesPrinterVC()
        vc.selectDataList = selectDataList ?? []
        vc.viewType = viewType
        vc.brand = brand
        if let sender = sender{
            vc.modalPresentationStyle = .popover
//            vc.preferredContentSize = CGSize(width: 120, height: 120)
            vc.popoverPresentationController?.sourceView = sender
            vc.popoverPresentationController?.sourceRect = sender.bounds
        }
        return vc
    }
    
    static func createModule(_ sender:UIView?,selectDataList:[String]?,viewType:SELECT_VIEW_TYPES,connectionType:ConnectionTypes?) -> SelectBrandModullesPrinterVC {
        let vc:SelectBrandModullesPrinterVC = SelectBrandModullesPrinterVC()
        vc.selectDataList = selectDataList ?? []
        vc.viewType = SELECT_VIEW_TYPES.ConnectionType
        vc.connectionType = connectionType
        if let sender = sender{
            vc.modalPresentationStyle = .popover
//            vc.preferredContentSize = CGSize(width: 120, height: 120)
            vc.popoverPresentationController?.sourceView = sender
            vc.popoverPresentationController?.sourceRect = sender.bounds
        }
        return vc
    }
    

}
extension SelectBrandModullesPrinterVC:UITableViewDelegate,UITableViewDataSource{
    func setupTable(){
//        selectTable.rowHeight = UITableView.automaticDimension
//        selectTable.estimatedRowHeight = 70
        selectTable.register(UINib(nibName: "SelectCell", bundle: nil), forCellReuseIdentifier: "SelectCell")
        selectTable.delegate = self
        selectTable.dataSource = self
        self.selectTable.reloadData()
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
                 
             
             cell.bindData(text: item, hideImage: !isItemSelect(item))
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
