//
//  SelectReasonVoidVC.swift
//  pos
//
//  Created by M-Wageh on 25/09/2023.
//  Copyright © 2023 khaled. All rights reserved.
//

import UIKit
class void_reason_class {
    var id:Int?
    var name:String?
    static func get_all()->[void_reason_class]{
        var dataList:[void_reason_class] = []
        let arr: [[String:Any]] =  pos_return_reason_class.getAll()
        for item in arr{
            var void_reason = void_reason_class()
            void_reason.id = item["id"] as? Int ?? 0
            void_reason.name = item["display_name"] as? String ?? ""
            if !(void_reason.name?.isEmpty ?? true) {
                dataList.append(void_reason)
            }

        }
        return dataList
        

    }

}
class SelectReasonVoidVC: UIViewController {

    
    @IBOutlet weak var selectVoidReasonsTable: UITableView!
    
    @IBOutlet weak var titleLbl: UILabel!
    
    @IBOutlet weak var cancelBtn: KButton!
    
    @IBOutlet weak var doneBtn: KButton!
    
    @IBOutlet weak var reasonTF: UITextField!
    
    //Missing in merge
    var dataList:[void_reason_class]?
    var selectDataList:[void_reason_class]?
    var completionBlock:(([void_reason_class])->())?

    override func viewDidLoad() {
        super.viewDidLoad()
        setLabels()
       // updateTF()
        setupTable()
    }
    func setLabels(){
        self.titleLbl.text = "Choose or enter void reason".arabic("اختر او ادخل سبب االحذف")
        reasonTF.placeholder = "Enter void reason".arabic("ادخل سبب الحذف")
        doneBtn.layer.cornerRadius = 12
        cancelBtn.layer.cornerRadius = 12
       
    }
    func updateTF(){
        let voidReasonTF = selectDataList?.compactMap({$0.name}).joined(separator: "\n ")
        if !(voidReasonTF?.isEmpty ?? true){
            self.reasonTF.text = ""
            self.reasonTF.text = voidReasonTF
        }
    }
    
    func isItemSelect(_ item:void_reason_class)->Bool{
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
                    selectDataList?.removeAll(where: {$0.id != -1})
                    selectDataList?.append(item)
                }
            
       }
       // self.updateTF()
//         self.selectVoidReasonsTable.reloadData()
//         self.completionBlock?(selectDataList ?? [])
       

    }
    
    @IBAction func tapOnCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)

    }
    
    @IBAction func tapOnDone(_ sender: Any) {
        if !((self.reasonTF.text?.isEmpty) ?? true) {
            let void_reason = void_reason_class()
            void_reason.id = -1
            void_reason.name = self.reasonTF.text ?? ""
            self.selectDataList?.append(void_reason)
        }
        self.completionBlock?(self.selectDataList ?? [])

        self.dismiss(animated: true, completion: nil)
    }
   static func createModule(_ sender:UIView?,selectDataList:[void_reason_class]?,dataList:[void_reason_class]) -> SelectReasonVoidVC {
        let vc:SelectReasonVoidVC = SelectReasonVoidVC()
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
extension SelectReasonVoidVC:UITableViewDelegate,UITableViewDataSource{
    func setupTable(){
//        selectVoidReasonsTable.rowHeight = UITableView.automaticDimension
//        selectVoidReasonsTable.estimatedRowHeight = 70
        selectVoidReasonsTable.register(UINib(nibName: "SelectCell", bundle: nil), forCellReuseIdentifier: "SelectCell")
        selectVoidReasonsTable.delegate = self
        selectVoidReasonsTable.dataSource = self
        self.selectVoidReasonsTable.reloadData()
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
             cell.setLblCenter()
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
