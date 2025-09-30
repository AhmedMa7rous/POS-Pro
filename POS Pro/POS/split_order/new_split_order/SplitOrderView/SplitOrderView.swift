//
//  SplitOrderView.swift
//  pos
//
//  Created by M-Wageh on 28/01/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import UIKit

class SplitOrderView: UIView {

    @IBOutlet weak var orderTable: UITableView!
    @IBOutlet weak var selectAllBtn: UIButton!
    
    @IBOutlet weak var orderSelectTableBtn: KButton!
    var newSplitOrderVM:NewSplitOrderVM?
    var orderStatus:NewSplitOrderVM.OrderStatusEnum?
    
    class func getViewInstance(newSplitOrderVM:NewSplitOrderVM,orderStatus:NewSplitOrderVM.OrderStatusEnum)->SplitOrderView {
            let view = UINib(nibName: "SplitOrderView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! SplitOrderView
        view.setupView(newSplitOrderVM:newSplitOrderVM,orderStatus:orderStatus)
            return view
     }
    
    fileprivate func setupView(newSplitOrderVM:NewSplitOrderVM,orderStatus:NewSplitOrderVM.OrderStatusEnum) {
            // do your setup here
        self.newSplitOrderVM = newSplitOrderVM
        self.orderStatus = orderStatus
        if orderStatus == .CURRENT {
            self.orderSelectTableBtn.isEnabled = false
            self.orderSelectTableBtn.isUserInteractionEnabled = false
        }
        self.updateTableName()
        setupTable()
    }
    private func setupTable(){
        orderTable.register(UINib(nibName: "split_orderTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
        orderTable.dataSource = self
        orderTable.delegate = self
//        orderTable.estimatedRowHeight = 150
        orderTable.rowHeight = UITableView.automaticDimension
    }
    
    @IBAction func tapOnSelectAllBtn(_ sender: UIButton) {
        self.newSplitOrderVM?.moveAll(from: orderStatus!)
    }
    
    
    @IBAction func tapOnOrderSelectTable(_ sender: KButton) {
        guard let orderStatus = orderStatus else { return  }
        self.newSplitOrderVM?.changeTable(for: orderStatus)
    }
    
    func updateTableName(){
        guard let orderStatus = orderStatus else { return  }
       let titleTable =  self.newSplitOrderVM?.getTableName(for: orderStatus) ?? ""
        self.orderSelectTableBtn.setTitle(titleTable, for: UIControl.State.normal)
    }
}
extension SplitOrderView:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newSplitOrderVM?.getNumerRows(for:orderStatus!) ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: split_orderTableViewCell! = tableView.dequeueReusableCell(withIdentifier: "Cell") as? split_orderTableViewCell
        cell.img_select.isHidden = true
        cell.lblPrice.isHidden = true
        if let itme =  newSplitOrderVM?.getProductLine(at:indexPath.row , for :orderStatus!){
            cell.updateCell(with: itme)
            if (itme.tag_temp ?? "") == "returned"
            {
                cell.selectionStyle = .none
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        newSplitOrderVM?.moveItem(at:indexPath.row,from :orderStatus! )
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
