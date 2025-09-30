//
//  MultiAddressVC.swift
//  pos
//
//  Created by M-Wageh on 12/10/2023.
//  Copyright © 2023 khaled. All rights reserved.
//

import UIKit
enum MultiAddressUsesCAse{
    case NEW
    case EDIT
}

enum FIELD_TYPES{
    case INPUT_NAME,INPUT_CITY,INPUT_STREET,INPUT_PHONE,INPUT_VAT,INPUT_EMAIL,CHOOSE
    
}
extension res_partner_class {
    func updateParentWithIdServer(){
        if self.parent_id == 0 {
            let queryUpdate = "update res_partner set parent_id = \(self.id),parent_name = '\(self.name)' where row_parent_id = \(self.row_id) and (parent_id = 0 or parent_id is null) "
            let resut = self.dbClass?.runSqlStatament(sql: queryUpdate)
            SharedManager.shared.printLog(resut)
        }
    }
    func getDeliveryContacts() -> [res_partner_class]{
        var queryActive = "where  (active in (1) OR active IS NULL) and row_parent_id = \(self.row_id)"

        if self.id != 0 {
            queryActive = "where (active in (1) OR active IS NULL) and ( parent_id = \(self.id) or row_parent_id = \(self.row_id) )"

        }
        let cls = res_partner_class(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(whereSql: queryActive)
        if arr.count <= 0 {
            return self.getDeliveryContactsOldData()
        }
        return arr.map({res_partner_class(fromDictionary: $0)})
    }
    func getDeliveryContactsOldData() -> [res_partner_class]{
        var queryActive = "where  (active in (1) OR active IS NULL) and row_parent_id = \(self.row_id)"

        if let oldPartnerID = self.res_partner_id, oldPartnerID != 0 {
            queryActive = "where (active in (1) OR active IS NULL) and ( parent_partner_id = \(oldPartnerID) or row_parent_id = \(self.row_id) )"

        }
        let cls = res_partner_class(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(whereSql: queryActive)
        return arr.map({res_partner_class(fromDictionary: $0)})
    }
    static func intialResPartner(from fieldsList:[AddressField]) -> res_partner_class?{
        var partner = res_partner_class(fromDictionary: [:])
        fieldsList.forEach { addressField in
            if let value = addressField.value as? pos_delivery_area_class {
                partner.pos_delivery_area_id = value.id
                partner.pos_delivery_area_name = value.name
                
            }
            if let value = addressField.value as? String {
                if addressField.type == .INPUT_NAME {
                    partner.name = value
                }
                if addressField.type == .INPUT_CITY {
                    partner.city = value
                }
                if addressField.type == .INPUT_STREET {
                    partner.street = value
                }
                if addressField.type == .INPUT_EMAIL {
                    partner.email = value
                }
                if addressField.type == .INPUT_PHONE {
                    partner.phone = value
                }
                if addressField.type == .INPUT_VAT {
                    partner.vat = value
                }

            }
        }
        if partner.name.isEmpty {
            return nil
        }
        return partner
        
    }
}


class AddressField{
    var name: String = ""
    var type: FIELD_TYPES = .INPUT_NAME
    var value:Any? = nil
    init(_ name: String,_ type: FIELD_TYPES = .INPUT_NAME) {
        self.name = name
        self.type = type
    }
    func choseDeliveryArea(sender:UIView,vc:UIViewController,complete:@escaping (()->Void)){
        var selectedDeliveryArea:[pos_delivery_area_class] = []
        if let value = value as? pos_delivery_area_class {
            selectedDeliveryArea.append(value)
        }
        let selectUservc:SelectDeliveryAreaVC = SelectDeliveryAreaVC.createModule(sender,selectDataList:  selectedDeliveryArea,dataList:pos_delivery_area_class.getAll().map({pos_delivery_area_class(fromDictionary: $0)}))
            selectUservc.completionBlock = { selectDataList in
                if  selectDataList.count > 0{
                    if (selectDataList.first?.id ?? 0) == -1{
                        self.value = nil
                    }else{
                        self.value = selectDataList.first
                    }
                }
                complete()
            }
        vc.present(selectUservc, animated: true, completion: nil)
    }
}

class MultiAddressVC: UIViewController {

    @IBOutlet weak var fieldView: ShadowView!
    @IBOutlet weak var showTable: UITableView!
    @IBOutlet weak var fieldTable: UITableView!
    @IBOutlet weak var addAddressLbl: KLabel!
    var router:MultiAddressRouter?
    var completeAddAddress:((_ line:[res_partner_class]?)->Void)?
    var listConntectAddressAdded:[res_partner_class]?
    var parentCustomer:res_partner_class?
    var fieldsList:[AddressField] = []
    var editDeliveryContactIndex:IndexPath?
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTable()
        initalFieldsList()
        
    }
    func initalFieldsList(){
        fieldsList.append(AddressField("Name".arabic("الاسم"),.INPUT_NAME))
        fieldsList.append(AddressField("Phone".arabic("رقم التلفون"),.INPUT_PHONE))
        fieldsList.append(AddressField("VAT".arabic("رقم الضريبة"),.INPUT_VAT))
        fieldsList.append(AddressField("E-mail".arabic("البريد الالكتروني"),.INPUT_EMAIL))
        fieldsList.append(AddressField("City".arabic("المدينه"),.INPUT_CITY))
        fieldsList.append(AddressField("Street".arabic("الشارع"),.INPUT_STREET))
        fieldsList.append(AddressField("Delivery area".arabic("منطقة التسليم"),.CHOOSE))
    }
    func restFields(){
        fieldsList.forEach { field in
            field.value = nil
        }
    }
    func addDeliveryArea(_ complete:(()->Void)? = nil ){
        if var partner = res_partner_class.intialResPartner(from:fieldsList){
            if let editDeliveryContactIndex = editDeliveryContactIndex{
                let editPartner = self.listConntectAddressAdded?[editDeliveryContactIndex.row]
                partner.id = editPartner?.id ?? 0
                partner.row_id = editPartner?.row_id ?? 0
                partner.parent_id = editPartner?.parent_id ?? 0
                partner.parent_name = editPartner?.parent_name ?? ""
                partner.row_parent_id = editPartner?.row_parent_id ?? 0

                if (editPartner?.parent_id != 0) || (self.parentCustomer?.id != 0) {
                    self.hitUpdateCustomerAPI(partner,complete)
                    return
                }else{
                    self.listConntectAddressAdded?.remove(at: editDeliveryContactIndex.row)
                    self.editDeliveryContactIndex = nil
                }
            }else{
                    if let parentID = self.parentCustomer?.id, parentID != 0{
                        partner.parent_id = parentID
                        partner.parent_name = self.parentCustomer?.name ?? ""
                    }
                if let parentRowID = self.parentCustomer?.row_id, parentRowID != 0{
                    partner.row_parent_id = parentRowID
                }
//                    self.hitUpdateCustomerAPI(partner,complete)
//                    return
            }
            addDeliveryContact(partner)
        }
        complete?()
    }
    
    @IBAction func tapOnCloseBtn(_ sender: UIButton) {
        router?.closeVC()
    }
    
    @IBAction func tapOnAdd(_ sender: KButton) {
        self.addDeliveryArea()
//        self.router?.closeVC()
    }
    @IBAction func tapOnSave(_ sender: KButton) {
        self.addDeliveryArea {
            self.router?.closeVC(isCompleted: true)
        }

    }
    func addDeliveryContact(_ partner: res_partner_class){
        self.listConntectAddressAdded?.append(partner)
        self.restFields()
        self.reloadTables()
        SharedManager.shared.initalBannerNotification(title: "Added Successfully".arabic("تم الاضافه بنجاح"), message: "", success: true, icon_name: "")
    }
    func hitUpdateCustomerAPI(_ customer: res_partner_class,_ complete:(()->Void)? = nil ){
        let con = SharedManager.shared.conAPI()
        loadingClass.show(view: self.view)
            con.userCash = .stopCash

        con.update_customer(customer: customer) { result in
            loadingClass.hide(view: self.view)
            
            if result.success == true
            {
                if let index = self.editDeliveryContactIndex?.row{
                    self.listConntectAddressAdded?.remove(at: index)
                    self.editDeliveryContactIndex = nil
                }else{
                    if let parentID = self.parentCustomer?.id{
                        customer.parent_id = parentID
                    }
                }
                self.addDeliveryContact(customer)
                complete?()

            }
                else
            {
                 messages.showAlert(result.message ?? "")
                return

            }
            
        }
    }
    
    func reloadTables(){
        self.fieldTable.reloadData()
        self.showTable.reloadData()

    }
    
}
extension MultiAddressVC:UITableViewDelegate,UITableViewDataSource{

    func setupTable(){
        self.initTable(for: self.showTable)
        self.initTable(for: self.fieldTable)
        fieldTable.register(UINib(nibName: "addressFieldCell", bundle: nil), forCellReuseIdentifier: "addressFieldCell")
        showTable.register(UINib(nibName: "addressViewCell", bundle: nil), forCellReuseIdentifier: "addressViewCell")
    }
    func initTable(for table:UITableView){
        table.delegate = self
        table.dataSource = self
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 80
    }

    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 1 {
            return fieldsList.count

        }
        return self.listConntectAddressAdded?.count ?? 0
    }
    
   
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//         let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! invoicesListTableViewCell
         if tableView.tag == 1 {
             let cell = tableView.dequeueReusableCell(withIdentifier: "addressFieldCell", for: indexPath) as! addressFieldCell
             cell.fieldValueTF.tag = indexPath.row

             cell.fieldBtn.tag = indexPath.row
             cell.fieldValueTF.delegate = self
             cell.cellField = fieldsList[indexPath.row]
             cell.fieldBtn.addTarget(self, action: #selector(tapOnSelectDeliveryArea(_:)), for: .touchUpInside)
              return cell
         }
        let cell = tableView.dequeueReusableCell(withIdentifier: "addressViewCell", for: indexPath) as! addressViewCell
         cell.removeBtn.tag = indexPath.row
         cell.removeBtn.addTarget(self, action: #selector(tapOnRemoveDeliveryArea(_:)), for: .touchUpInside)
         cell.partner = listConntectAddressAdded?[indexPath.row]
         return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.tag == 1 {
            return
        }
        if let partner = listConntectAddressAdded?[indexPath.row]{
            self.editDeliveryContactIndex = indexPath
            fieldsList.forEach { addressField in
                if addressField.type == .CHOOSE {
                    if let pos_delivery_area = pos_delivery_area_class.getBy(id:partner.pos_delivery_area_id ){
                        addressField.value = pos_delivery_area
                    }
                }
                    if addressField.type == .INPUT_NAME {
                        addressField.value = partner.name
                    }
                    if addressField.type == .INPUT_CITY {
                        addressField.value =  partner.city
                    }
                    if addressField.type == .INPUT_STREET {
                        addressField.value =  partner.street
                    }
                    if addressField.type == .INPUT_EMAIL {
                        addressField.value =  partner.email
                    }
                    if addressField.type == .INPUT_PHONE {
                        addressField.value =  partner.phone
                    }
                    if addressField.type == .INPUT_VAT {
                        addressField.value =  partner.vat
                    }

            }
            self.fieldTable.reloadData()
        }
    }
   
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
//
//
//
//    @objc func handleTapTableCell(recognizer:UITapGestureRecognizer){
//        if let index = recognizer.view?.tag {
//            self.didSelectItem(at: index)
//        }
//    }
    @objc func tapOnSelectDeliveryArea(_ sender:UIButton){
        fieldsList[sender.tag].choseDeliveryArea(sender: sender, vc: self) {
            self.fieldTable.reloadData()
        }
    }
    @objc func tapOnRemoveDeliveryArea(_ sender:UIButton){
        listConntectAddressAdded?.remove(at: sender.tag)
        self.showTable.reloadData()
    }
    
}
extension MultiAddressVC:UITextFieldDelegate{
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.fieldsList[textField.tag].value = textField.text
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.fieldsList[textField.tag].value = textField.text
    }
}
