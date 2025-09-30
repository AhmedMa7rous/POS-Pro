//
//  SelectBrandVC.swift
//  pos
//
//  Created by M-Wageh on 11/10/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import UIKit

class SelectBrandVC: UIViewController {

    @IBOutlet weak var selectBrandTable: UITableView!

    var dataList:[res_brand_class]?
    var selectDataList:[res_brand_class]?
    var completionBlock:(([res_brand_class])->())?
    var needSaveSelect:Bool = true
    override func viewDidLoad() {
        super.viewDidLoad()
        initalList()
        setupTable()
    }
    func initalList(){
        dataList = []
        if !needSaveSelect{
            var allBrands = res_brand_class.getAllObject()
            var dictionary:[String:Any] = [:]
            dictionary["id"] = -1
            dictionary["display_name"] = "All".arabic("الكل")
            dictionary["is_select"] = false
            self.dataList?.append(res_brand_class(fromDictionary: dictionary))
            allBrands.forEach { brand in
                brand.is_select = false
                self.dataList?.append(brand)

            }
//            self.dataList?.append(contentsOf: allBrands )
        }else{
            self.dataList?.append(contentsOf: res_brand_class.getAllObject() )
        }
        if let selectDataList = self.selectDataList {
            self.dataList?.forEach({ item in
                if selectDataList.first(where: {$0.id == item.id}) != nil {
                    item.is_select = true
                }
            })
        }else{
            if !needSaveSelect{
                self.dataList?.first(where: {$0.id == -1})?.is_select = true
            }
        }
    }
    func unSelectBrand(){
        self.dataList?.forEach({ brand in
            brand.is_select = false
            if needSaveSelect {
                brand.save()
            }
        })
    }

    func itemSelecte(at indexPath:IndexPath){
        self.unSelectBrand()
        self.dataList?[indexPath.row].is_select = true
        if needSaveSelect {
            self.dataList?[indexPath.row].save()
        }
      // res_company_class(from: <#T##res_brand_class#>, company: <#T##res_company_class#>)
        self.dismiss(animated: true, completion: {
            if let selectBrands =  self.dataList?[indexPath.row]{
                self.completionBlock?([selectBrands])
            }
        })

    }
    
    @IBAction func tapOnCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)

    }
    
    @IBAction func tapOnDone(_ sender: Any) {
        let selectBrands = self.dataList?.filter({$0.is_select}) ?? []
        self.dismiss(animated: true, completion: {
            self.completionBlock?(selectBrands)
        })
    }
    static func createModule(_ sender:UIView?,selectDataList:[res_brand_class]? = nil , option:enable_cloud_kitchen_option) -> SelectBrandVC? {
        let config = SharedManager.shared.posConfig()
        let setting = SharedManager.shared.appSetting()

        if config.cloud_kitchen.count > 0 &&  setting.enable_cloud_kitchen != .DISABLE && setting.enable_cloud_kitchen == option {

        let vc:SelectBrandVC = SelectBrandVC()
        vc.selectDataList = selectDataList
        if let sender = sender{
            vc.modalPresentationStyle = .popover
//            vc.preferredContentSize = CGSize(width: 120, height: 120)
            vc.popoverPresentationController?.sourceView = sender
            vc.popoverPresentationController?.sourceRect = sender.bounds
        }
        return vc
        }else{
            return nil
        }
    }
    static func createReportModule(_ sender:UIView?,selectDataList:[res_brand_class]? = nil ) -> SelectBrandVC? {
        let config = SharedManager.shared.posConfig()
        let setting = SharedManager.shared.appSetting()

        if config.cloud_kitchen.count > 0 {

        let vc:SelectBrandVC = SelectBrandVC()
        vc.selectDataList = selectDataList
        vc.needSaveSelect = false
        if let sender = sender{
            vc.modalPresentationStyle = .popover
//            vc.preferredContentSize = CGSize(width: 120, height: 120)
            vc.popoverPresentationController?.sourceView = sender
            vc.popoverPresentationController?.sourceRect = sender.bounds
        }
        return vc
        }else{
            return nil
        }
    }
    

}
extension SelectBrandVC:UITableViewDelegate,UITableViewDataSource{
    func setupTable(){
//        selectBrandTable.rowHeight = UITableView.automaticDimension
//        selectBrandTable.estimatedRowHeight = 70
        selectBrandTable.register(UINib(nibName: "SelectCell", bundle: nil), forCellReuseIdentifier: "SelectCell")
        selectBrandTable.delegate = self
        selectBrandTable.dataSource = self
        self.selectBrandTable.reloadData()
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
         if let brand = self.dataList?[indexPath.row]{
             cell.bindData(text: brand.display_name ?? "", hideImage: !brand.is_select)
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
