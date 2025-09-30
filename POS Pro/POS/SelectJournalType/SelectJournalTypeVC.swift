//
//  SelectJournalTypeVC.swift
//  pos
//
//  Created by M-Wageh on 24/04/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import UIKit

class SelectJournalTypeVC: UIViewController {
    @IBOutlet weak var selectJournalTable: UITableView!

    var dataList:[account_journal_class]?
    var selectDataList:[account_journal_class]?
    var completionBlock:(([account_journal_class])->())?

    override func viewDidLoad() {
        super.viewDidLoad()
        initalList()
        setupTable()
    }
    func initalList(){
        dataList = []
        self.dataList?.append(contentsOf: account_journal_class.get_bank_account() ?? [])
        if let selectDataList = self.selectDataList {
            self.dataList?.forEach({ item in
                if selectDataList.first(where: {$0.id == item.id}) != nil {
                    item.is_select = true
                }
            })
        }
    }

    func itemSelecte(at indexPath:IndexPath){
        self.dataList?[indexPath.row].is_select = (!(self.dataList?[indexPath.row].is_select ?? false))
        self.selectJournalTable.reloadData()
        let selectJournals = self.dataList?.filter({$0.is_select}) ?? []
        self.completionBlock?(selectJournals)

    }
    
    @IBAction func tapOnCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)

    }
    
    @IBAction func tapOnDone(_ sender: Any) {
        let selectJournals = self.dataList?.filter({$0.is_select}) ?? []
        self.dismiss(animated: true, completion: {
            self.completionBlock?(selectJournals)
        })
    }
    static func createModule(_ sender:UIView?,selectDataList:[account_journal_class]?) -> SelectJournalTypeVC {
        let vc:SelectJournalTypeVC = SelectJournalTypeVC()
        vc.selectDataList = selectDataList
        if let sender = sender{
            vc.modalPresentationStyle = .popover
//            vc.preferredContentSize = CGSize(width: 120, height: 120)
            vc.popoverPresentationController?.sourceView = sender
            vc.popoverPresentationController?.sourceRect = sender.bounds
        }
        return vc
    }
    

}
extension SelectJournalTypeVC:UITableViewDelegate,UITableViewDataSource{
    func setupTable(){
//        selectJournalTable.rowHeight = UITableView.automaticDimension
//        selectJournalTable.estimatedRowHeight = 70
        selectJournalTable.register(UINib(nibName: "SelectCell", bundle: nil), forCellReuseIdentifier: "SelectCell")
        selectJournalTable.delegate = self
        selectJournalTable.dataSource = self
        self.selectJournalTable.reloadData()
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
         if let accout = self.dataList?[indexPath.row]{
             cell.bindData(text: accout.display_name, hideImage: !accout.is_select)
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
