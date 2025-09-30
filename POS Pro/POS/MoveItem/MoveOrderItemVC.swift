//
//  MoveOrderItemVC.swift
//  pos
//
//  Created by M-Wageh on 07/06/2023.
//  Copyright © 2023 khaled. All rights reserved.
//

import UIKit

class MoveOrderItemVC: UIViewController {
    var moveOrderItemVM:MoveOrderItemVM?
    
    @IBOutlet weak var moveOrderTableView: UITableView!
    @IBOutlet weak var orginOrderTableView: UITableView!
    var completeMoveItems:(()->())?
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTable()
        initalState()
        // Do any additional setup after loading the view.
    }
    func initalState(){
        self.moveOrderItemVM?.updateStatusClosure = { (state) in
            switch state {
            case .loading:
                DispatchQueue.main.async {
                    loadingClass.show(view: self.view)
                }
                return
            case .openChangeTable:
                DispatchQueue.main.async {
                    self.openChangeTable()
                }
                return
            case .saveMovement:
                DispatchQueue.main.async {
                    loadingClass.hide(view:self.view)
                    self.dismiss(animated: true,completion: self.completeMoveItems)
                }
                return
            case .reloadTables:
                DispatchQueue.main.async {
                    self.moveOrderTableView.reloadData()
                    self.orginOrderTableView.reloadData()
                }
                return
           
            }
            
        }
    }
    
    
    func openChangeTable(){
        if SharedManager.shared.appSetting().auto_arrange_table_default {
            let vc = TableManagementVC(nibName: "TableManagementVC", bundle: nil)
            vc.isSplitOrMove = true
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true, completion: nil)
            //        vc.didSelectOrder = { selectedOrder in
            //            self.moveOrderItemVM?.moveSelectedItem(to:selectedOrder )
            //
            //        }
            vc.didSelect = { resturantTable in
                if (resturantTable.order_id) <= 0 {
                    SharedManager.shared.initalBannerNotification(title: "Empty Table".arabic("طاولة فارغه"), message: "You should chose table contain order".arabic("يجب اختيار طاولة تحتوي علي طلب"), success: false, icon_name: "icon_error")
                    SharedManager.shared.banner?.dismissesOnTap = true
                    SharedManager.shared.banner?.show(duration: 3)
                    
                }else{
                    if let selectedOrder =  pos_order_class.get(order_id:resturantTable.order_id ){
                        self.moveOrderItemVM?.moveSelectedItem(to:selectedOrder )
                    }
                    
                }
            }
        } else {
            let vc = posTableMangent(nibName: "posTableMangement", bundle: nil)
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true, completion: nil)
            //        vc.didSelectOrder = { selectedOrder in
            //            self.moveOrderItemVM?.moveSelectedItem(to:selectedOrder )
            //
            //        }
            vc.didSelect = { resturantTable in
                if (resturantTable.order_id) <= 0 {
                    SharedManager.shared.initalBannerNotification(title: "Empty Table".arabic("طاولة فارغه"), message: "You should chose table contain order".arabic("يجب اختيار طاولة تحتوي علي طلب"), success: false, icon_name: "icon_error")
                    SharedManager.shared.banner?.dismissesOnTap = true
                    SharedManager.shared.banner?.show(duration: 3)
                    
                }else{
                    if let selectedOrder =  pos_order_class.get(order_id:resturantTable.order_id ){
                        self.moveOrderItemVM?.moveSelectedItem(to:selectedOrder )
                    }
                    
                }
            }
        }
    }
    
    
    @IBAction func tapOnMoveBtn(_ sender: KButton) {
        if self.moveOrderItemVM?.checkValidateMove() ?? false{
            openChangeTable()
        }
    }
    @IBAction func tapOnSelectAllBtn(_ sender: UIButton) {
        self.moveOrderItemVM?.selectAll(tag: sender.tag)
        let isSelect =  sender.tag == 0
        sender.tag = isSelect ? 1 : 0
        let selectAllString = "Select all".arabic("تحديد الكل")
        let unSelectAllString = "unselect all".arabic("الغاء الكل")
        sender.setTitle( isSelect ? unSelectAllString : selectAllString , for: .normal)
    }
    
    @IBAction func tapOnDoneBtn(_ sender: KButton) {
        self.moveOrderItemVM?.saveMoveItems()
    }
    @IBAction func tapOnCancelBtn(_ sender: KButton) {
        self.dismiss(animated: true)
    }
    
    
    static func createModule(_ order:pos_order_class,completeMoveItems:(()->())?) -> MoveOrderItemVC{
        let vc = MoveOrderItemVC()
        let moveOrderItemVM = MoveOrderItemVM(order: order)
        vc.moveOrderItemVM = moveOrderItemVM
        vc.completeMoveItems = completeMoveItems
        return vc
        /**
         
         vc.modalPresentationStyle = .formSheet
         vc.preferredContentSize = CGSize(width: 900, height: 700)

  //        vc.popoverPresentationController?.sourceView = sender as? UIView
         self.present(vc, animated: true, completion: nil)
         */
    }
}

extension MoveOrderItemVC:UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView.tag == 1 {
            return self.moveOrderItemVM?.getCountOrder() ?? 0
        }
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !(self.moveOrderItemVM?.getIsExpanded(for: tableView.tag, in: section) ?? true){
            return 0
        }
        return self.moveOrderItemVM?.getCountLine(for: tableView.tag, in: section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: split_orderTableViewCell! = tableView.dequeueReusableCell(withIdentifier: "Cell") as? split_orderTableViewCell
        let moveItemModel = self.moveOrderItemVM?.getLine(at: indexPath, for: tableView.tag)
        cell.moveItemModel = moveItemModel
        cell.img_select.isHidden = tableView.tag == 1
        cell.lblPrice.isHidden = false
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        SharedManager.shared.printLog("didSelectRowAt === \(indexPath)")
//        SharedManager.shared.printLog("tableView === \(tableView.tag)")
        if tableView.tag == 1 {return}
        self.moveOrderItemVM?.togleSelected(at: indexPath, for: tableView.tag)
        
    }
    func setupTable(){
        orginOrderTableView.delegate = self
        orginOrderTableView.dataSource = self
        orginOrderTableView.rowHeight = UITableView.automaticDimension
        orginOrderTableView.estimatedRowHeight = 300
        orginOrderTableView.register(UINib(nibName: "split_orderTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
        
        moveOrderTableView.dataSource = self
        moveOrderTableView.rowHeight = UITableView.automaticDimension
        moveOrderTableView.estimatedRowHeight = 300
       //        refreshControl.addTarget(self, action: #selector(refreshStoredItemTable), for: .valueChanged)
       //        StoredItemTable.addSubview(refreshControl)
        moveOrderTableView.register(UINib(nibName: "split_orderTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
        moveOrderTableView.register(UINib(nibName: "SectionHeaderCell", bundle: nil), forCellReuseIdentifier: "SectionHeaderCell")

    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView.tag == 0{return nil}
        //SectionHeaderCell
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "SectionHeaderCell") as! SectionHeaderCell
        headerCell.tapHeaterBtn.tag = section
        headerCell.tapHeaterBtn.addTarget(self, action: #selector(selectHeader(_ :)), for: .touchUpInside)
        headerCell.orginOrderMoveModel =    self.moveOrderItemVM?.getOrginOrderMoveModel(section)
       
        return headerCell
    }
    @objc func selectHeader(_ sender:UIButton){
        self.moveOrderItemVM?.togleExpanded(sender.tag)
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
}

