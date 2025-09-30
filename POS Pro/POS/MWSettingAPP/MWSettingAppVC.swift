//
//  MWSettingAppVC.swift
//  pos
//
//  Created by M-Wageh on 09/07/2023.
//  Copyright © 2023 khaled. All rights reserved.
//

import UIKit

class MWSettingAppVC: UIViewController {

    @IBOutlet weak var table: UITableView!
    var mwSettingAppVM:MWSettingAppVM?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTable()
        initalState()
        self.mwSettingAppVM?.getAllSetting()
    }
    func initalState(){
        self.mwSettingAppVM?.updateStatusClosure = { (state) in
            switch state {
            case .loading:
                DispatchQueue.main.async {
                    loadingClass.show(view: self.view)
                }
                return
           
            case .reloadTable:
                DispatchQueue.main.async {
                    loadingClass.hide(view:self.view)
                    self.table.reloadData()
                }
                return
            case .show_alert(let settingKey):
                DispatchQueue.main.async {
                    loadingClass.hide(view:self.view)
                    self.showMessageAlert(for: settingKey)
                    self.table.reloadData()
                }
                return
            case .dismissKB:
               // DispatchQueue.main.async {
                    self.view.endEditing(true)
                //}
                return
            }
            
        }
    }
    func showMessageAlert(for setting:SETTING_KEY){
        if setting == .time_pass_to_go_lock_screen{
            messages.showAlert("Duration must be more than 30 secands".arabic("يجب أن تكون المدة أكثر من 30 ثانية"))
            return
        }
        if [SETTING_KEY.enable_add_kds_via_wifi,SETTING_KEY.disable_idle_timer].contains(setting){
            messages.showAlert("please restart your application to work with new feature".arabic("الرجاء إعادة تشغيل التطبيق الخاص بك للعمل مع ميزة جديدة"))
            return
        }
        if setting == .enable_force_longPolling_multisession{
            messages.showAlert("You must close app and open it again".arabic("يجب إغلاق التطبيق وفتحه مرة أخرى"))
            return
        }
        if setting == .font_size_for_kitchen_invoice{
            messages.showAlert("Invalid font size as font size must be between 30 and 70  .".arabic("حجم الخط غير صالح حيث يجب أن يكون حجم الخط بين 30 و 70."))
            return
            
        }
        if setting == .start_session_sequence_order{
            messages.showAlert( "Start sequence number must be less than end sequence number".arabic("يجب أن يكون رقم تسلسل البدء أقل من رقم تسلسل النهاية"))
            return
            
        }
        if setting == .end_sessiion_sequence_order{
            messages.showAlert( "End sequence number must be greater than end sequence number".arabic("يجب أن يكون رقم تسلسل النهاية أكبر من رقم تسلسل النهاية"))
            return
            
        }
        if setting == .enable_sequence_orders_over_wifi{
            messages.showAlert( "You must disable manual sequence first".arabic("يجب عليك ايقاف التسلسل اليدوي اولا"))
            return
            
        }
        if setting == .enable_enter_containous_sequence{
            messages.showAlert( "You must disable WIFI sequence first".arabic("يجب عليك ايقاف التسلسل عبر الشبكه اولا"))
            return
            
        }
        if setting == .enable_enter_sessiion_sequence_order{
            messages.showAlert( "You must disable WIFI sequence first".arabic("يجب عليك ايقاف التسلسل عبر الشبكه اولا"))
            return
            
        }
        messages.showAlert("invalid number .")
    }
    static func createModule() -> MWSettingAppVC {
        let vc:MWSettingAppVC = MWSettingAppVC()
        vc.mwSettingAppVM = MWSettingAppVM()
        return vc
    }

}

extension MWSettingAppVC:UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
            return self.mwSettingAppVM?.getSectionCount() ?? 0
      
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !(self.mwSettingAppVM?.getIsExpanded(at: section) ?? true){
            return 0
        }
        return self.mwSettingAppVM?.getItemCount(at: section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SettingCell! = tableView.dequeueReusableCell(withIdentifier: "SettingCell") as? SettingCell
        if let mwSettingAppVM = mwSettingAppVM{
            cell.configCell(mwSettingAppVM, indexPath)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        SharedManager.shared.printLog("didSelectRowAt === \(indexPath)")
//        SharedManager.shared.printLog("tableView === \(tableView.tag)")
        
    }
    func setupTable(){
        table.delegate = self
        table.dataSource = self
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 70
        table.register(UINib(nibName: "SettingCell", bundle: nil), forCellReuseIdentifier: "SettingCell")
     
        table.register(UINib(nibName: "SectionHeaderCell", bundle: nil), forCellReuseIdentifier: "SectionHeaderCell")

    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        //SectionHeaderCell
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "SectionHeaderCell") as! SectionHeaderCell
        headerCell.tapHeaterBtn.tag = section
        headerCell.tapHeaterBtn.addTarget(self, action: #selector(selectHeader(_ :)), for: .touchUpInside)
        headerCell.settingSectionModel = self.mwSettingAppVM?.getSectionObject(for: section)
       
        return headerCell
    }
    @objc func selectHeader(_ sender:UIButton){
        self.mwSettingAppVM?.togleSection(at:sender.tag)
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == (self.mwSettingAppVM?.getSectionCount() ?? 0) - 1 {
            let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50))
               let doneButton = UIButton(frame: CGRect(x: 0, y: 0, width: 300, height: 40))
               // here is what you should add:
               doneButton.center = footerView.center
            doneButton.layer.cornerRadius = 8
            doneButton.layer.borderWidth = 1
            doneButton.layer.borderColor =  #colorLiteral(red: 0.3254901961, green: 0.1529411765, blue: 0.5019607843, alpha: 1)
               doneButton.setTitle("Clear log", for: .normal)
            doneButton.titleLabel?.textColor = #colorLiteral(red: 0.3254901961, green: 0.1529411765, blue: 0.5019607843, alpha: 1)
            doneButton.setTitleColor( #colorLiteral(red: 0.3254901961, green: 0.1529411765, blue: 0.5019607843, alpha: 1), for: .normal)
               doneButton.addTarget(self, action: #selector(tapOnClearLog(sender:)), for: .touchUpInside)
               footerView.addSubview(doneButton)

               return footerView
        }
        return UIView(frame: CGRect.zero)
    }
    @objc func tapOnClearLog(sender:UIButton){
        AppDelegate.shared.removeDataBase_data(database: "log")
        AppDelegate.shared.removeDataBase_data(database: "printer_log")
        AppDelegate.shared.removeDataBase_data(database: "mesages_ip_log")
        AppDelegate.shared.removeDataBase_data(database: "multipeer_log")
        AppDelegate.shared.removeDataBase_data(database: "ingenico_log")
        printer_message_class.show("log cleard.", vc: self)
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == (self.mwSettingAppVM?.getSectionCount() ?? 0) - 1 {
            return 60
        }
        return 0
    }
}


