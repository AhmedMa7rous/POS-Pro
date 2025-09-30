//
//  AddDeviceVC.swift
//  pos
//
//  Created by M-Wageh on 04/06/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import UIKit
import StarIO10

class AddDeviceVC: UIViewController {
    @IBOutlet weak var fieldsTable: UITableView!
    @IBOutlet weak var titleLbl: KLabel!
    var addDeviceVM: AddDeviceVM?
    var completeHandler:(()->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initalState()
        setupTable()
        titleLbl.text = "Add new Device".arabic("اضافة جهاز جديد")
    }
    
    @IBAction func tapOnCancel(_ sender: KButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func tapOnAddBtn(_ sender: KButton) {
        self.addDeviceVM?.saveEditPrinter()
    }
    
    //MARK:- inital State
    func initalState() {
        self.addDeviceVM?.updateLoadingStatusClosure = { (state) in
            
            switch state {
            case .EMPTY:
                DispatchQueue.main.async {
                    loadingClass.hide(view: self.view)
                }
                return
            case .ERROR(let error):
                DispatchQueue.main.async {
                    loadingClass.hide(view: self.view)
                    messages.showAlert(error)
                }
                return
            case .LOADING:
                DispatchQueue.main.async {
                    loadingClass.show(view: self.view)
                }
                return
            case .RELOAD:
                DispatchQueue.main.async {
                    self.fieldsTable.reloadData()
                    loadingClass.hide(view: self.view)
                }
                return
            case .RELOAD_ROW(let row):
                DispatchQueue.main.async {
                    loadingClass.hide(view: self.view)
                    self.fieldsTable.reloadRows(at: [IndexPath(row: row, section: 0)], with: .none)
                }
                return
            case .SAVED:
                DispatchQueue.main.async {
                    loadingClass.hide(view: self.view)
                    self.dismiss(animated: true, completion: self.completeHandler)

                }
                return
            }
            
        }
    }
    
    static func  createModule(with device:AddDevicesFactorProtocol?) -> AddDeviceVC {
        let vc = AddDeviceVC()
        vc.addDeviceVM = AddDeviceVM(from: device)
        return vc
    }
    
    func show_ip_picker(_ sender:UIView,selectIp:String, isFromGeidea: Bool = false)
    {
        let vc = IPPickerVC.createModule(sender, selectIP: selectIp)
        vc.isForGeidea = isFromGeidea
        self.present(vc, animated: true, completion: nil)
        vc.selectIPClosure = { [weak self] (ip1,ip2,ip3,ip4) in
            guard let self = self else { return }
            let fullIp = "\(ip1).\(ip2).\(ip3).\(ip4)"
            self.addDeviceVM?.handlingSetValue(for: sender.tag, value: fullIp)
        }
    }
    
    func show_categoris_view(_ sender: UIView, index: Int) {
        let vc = SelectCategoriesVC.createModule(self.fieldsTable, selectDataList: self.addDeviceVM?.getCategoriesSelectList() ?? [])
        self.present(vc, animated: true, completion: nil)
        vc.completionBlock = { [weak self] selectDataList in
            guard let self = self else { return }
            let value = selectDataList.map(){$0.display_name}.joined(separator: ", ")
            let valuesDic = selectDataList.map(){$0.toDictionary()}
            self.addDeviceVM?.handlingSetValue(for: index, value: value, valuesDic: valuesDic)
            
        }
    }
    
    func show_BLE_SSD_view(_ sender: UIView, index: Int) {
        let vc = SelectBleVC.createModule(self.fieldsTable, selectDataList: self.addDeviceVM?.getResturantPrinter(), isBluetooth: true)
        self.present(vc, animated: true, completion: nil)
        vc.completionBlock = { [weak self] selectResturnat in
            guard let self = self else { return }
            let value = selectResturnat.printer_ip
            self.addDeviceVM?.handlingSetValue(for: index, value: value)
        }
    }
    
    func show_USBPort_view(_ sender: UIView, index: Int) {
        let vc = SelectBleVC.createModule(self.fieldsTable, selectDataList: self.addDeviceVM?.getResturantPrinter(), isBluetooth: false)
        self.present(vc, animated: true, completion: nil)
        vc.completionBlock = { [weak self] selectResturnat in
            guard let self = self else { return }
            let value = selectResturnat.printer_ip
            SharedManager.shared.printLog(value)
            self.addDeviceVM?.handlingSetValue(for: index, value: value)
        }
    }
    
    func show_order_types_view(_ sender: UIView, index: Int) {
        let vc = SelectOrderTypesVC.createModule(self.fieldsTable, selectDataList: self.addDeviceVM?.getOrderTypeSelectList() ?? [])
        self.present(vc, animated: true, completion: nil)
        vc.completionBlock = { [weak self] selectDataList in
            guard let self = self else { return }
            let value = selectDataList.map(){$0.display_name}.joined(separator: ", ")
            let valuesDic = selectDataList.map(){$0.toDictionary()}
            self.addDeviceVM?.handlingSetValue(for: index, value: value, valuesDic: valuesDic)
        }
    }
    func show_payment_methods(_ sender:UIView, index:Int)
    {
        let vc = SelectJournalTypeVC.createModule(self.fieldsTable, selectDataList: self.addDeviceVM?.getPaymentMethodsList())
        self.present(vc, animated: true, completion: nil)
        vc.completionBlock = { selectDataList in
            let value = selectDataList.map(){$0.display_name}.joined(separator: ", ")
            let valuesDic = selectDataList.map(){$0.toDictionary()}
            self.addDeviceVM?.handlingSetValue(for: index, value: value, valuesDic: valuesDic, selecDataList: selectDataList)
        }
    }
    func show_pos_config_view(_ sender:UIView, index:Int)
    {
        let vc = SelectPosVC.createModule(self.fieldsTable, selectDataList: self.addDeviceVM?.getPosSelectList() ?? [])
        self.present(vc, animated: true, completion: nil)
        vc.completionBlock = { [weak self] selectDataList in
            guard let self = self else { return }
            let value = selectDataList.map(){$0.name ?? ""}.joined(separator: ", ")
            let valuesDic = selectDataList.map(){$0.toDictionary()}
            self.addDeviceVM?.handlingSetValue(for: index, value: value, valuesDic: valuesDic)
        }
    }
    
    func show_chose_connection_type_view(_ sender:UIView,
                                          index:Int,
                                          selectDataList:[String],
                                          viewType:SelectBrandModullesPrinterVC.SELECT_VIEW_TYPES,
                                          connectionType:ConnectionTypes?) {
        let vc = SelectBrandModullesPrinterVC.createModule(self.fieldsTable,
                                                           selectDataList: selectDataList,viewType: viewType,connectionType: connectionType)
        self.present(vc, animated: true, completion: nil)
        vc.completionBlock = { [weak self] selectDataList in
            DispatchQueue.main.async {
//                if selectDataList[0] == "USB" {
//                    MWUsbPrinterInteractor.shared.discoverPrinter()
//                }
                self?.addDeviceVM?.handlingSetValue(for: index, value: selectDataList.joined(separator: ", "), valuesDic: nil)
            }
        }
    }
    
    func show_chose_brand_model_type_view(_ sender:UIView,
                                          index:Int,
                                          selectDataList:[String],
                                          viewType: SelectBrandModullesPrinterVC.SELECT_VIEW_TYPES,
                                          brand: PRINTER_BRAND_TYPES?) {
        let vc = SelectBrandModullesPrinterVC.createModule(self.fieldsTable,
                                                           selectDataList: selectDataList,viewType: viewType,brand: brand)
        self.present(vc, animated: true, completion: nil)
        vc.completionBlock = { [weak self] selectDataList in
            guard let self = self else { return }
            self.addDeviceVM?.handlingSetValue(for: index, value: selectDataList.joined(separator: ", "), valuesDic: nil)
        }
    }
    
    func show_choose_device_status_view(_ sender: UIView,index: Int, selectDataList: [String]) {
        let vc = SelectDeviceStatusVC.createModule(sender,selectDataList:selectDataList.map({SOCKET_DEVICE_STATUS.get(value: $0)}))
        self.present(vc, animated: true, completion: nil)
        vc.completionBlock = { [weak self] selectDataList in
            guard let self = self else { return }
            self.addDeviceVM?.handlingSetValue(for: index,
                                               value: selectDataList.first?.getDescription(),
                                               valuesDic: nil)
        }
    }
}
extension AddDeviceVC:UITableViewDelegate,UITableViewDataSource{
    func setupTable() {
        fieldsTable.delegate = self
        fieldsTable.dataSource = self
        fieldsTable.rowHeight = UITableView.automaticDimension
        fieldsTable.estimatedRowHeight = 80
        fieldsTable.register(UINib(nibName: "DeviceFieldCell", bundle: nil), forCellReuseIdentifier: "DeviceFieldCell")
    }
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addDeviceVM?.fieldsCount ?? 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceFieldCell", for: indexPath) as! DeviceFieldCell
        cell.selectBtn.tag = indexPath.row
        cell.searchBtn.tag = indexPath.row
        cell.ipTF.tag = indexPath.row
        cell.switchBtn.tag = indexPath.row
        
        cell.selectBtn.addTarget(self, action: #selector(tapOnSelectBtn(_:)), for: .touchUpInside)
        cell.searchBtn.addTarget(self, action: #selector(tapOnDiscoverBtn(_:)), for: .touchUpInside)
        
        cell.switchBtn.addTarget(self, action: #selector(tapOnSwitchTogle), for: .valueChanged)
        // Configure the cell...
        cell.deviceFieldModel = addDeviceVM?.getDeviceField(at:indexPath)
        cell.ipTF.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    @objc func tapOnSwitchTogle(_ sender:UISwitch) {
        view.endEditing(true)
        let item = addDeviceVM?.getDeviceField(at:IndexPath(row: sender.tag , section: 0))
        if item?.fieldType == .SOCKET_STATUS_DEVICE{
            let value =  sender.isOn ?  "1" : "2"
            self.addDeviceVM?.handlingSetValue(for: sender.tag, value: value)
            return
        }else if item?.fieldType == .BLE_CON{
            let value =  sender.isOn ?  "1" : "0"
            self.addDeviceVM?.handlingSetValue(for: sender.tag, value: value)
            return
        }
        
    }
    
    @objc func tapOnDiscoverBtn(_ sender:UIView) {
        
    }
    
    @objc func tapOnSelectBtn(_ sender:UIView) {
        view.endEditing(true)
        let item = addDeviceVM?.getDeviceField(at:IndexPath(row: sender.tag , section: 0))
        if item?.fieldType == .BLE_SSD {
            self.show_BLE_SSD_view(sender,index:sender.tag)
            return
        }
        if item?.fieldType == .IP {
            self.show_ip_picker(sender,selectIp:  item?.value ?? "")
            return
        }
        
        if item?.fieldType == .USBPort {
            self.show_USBPort_view(sender, index: sender.tag)
            return
        }
        
        if item?.fieldType == .CATEGORY {
            self.show_categoris_view(sender,index:sender.tag)
            return
        }
        if item?.fieldType == .ORDER_TYPES {
            self.show_order_types_view(sender,index:sender.tag)
            return
        }
        if item?.fieldType == .GEIDEA_IP{
            self.show_ip_picker(sender,selectIp:  item?.value ?? "", isFromGeidea: true)
            return
        }
        if item?.fieldType == .PAYMENT_METHODS{
            self.show_payment_methods(sender,index:sender.tag)
            return
        }
        if item?.fieldType == .POS_CONFIG{
            self.show_pos_config_view(sender,index:sender.tag)
            return
        }
        if item?.fieldType == .BRAND_PRINTER {
            self.show_chose_brand_model_type_view(sender,
                                                  index:sender.tag,
                                                  selectDataList:self.addDeviceVM?.getSelectStringList(fieldType: .BRAND_PRINTER) ?? [],
                                                  viewType:SelectBrandModullesPrinterVC.SELECT_VIEW_TYPES.BRAND,
                                                  brand:nil)
            return
        }
        
        if item?.fieldType == .ConnectionType {
            self.show_chose_connection_type_view(sender,
                                                 index: sender.tag,
                                                 selectDataList: self.addDeviceVM?.getSelectStringList(fieldType: .ConnectionType) ?? [],
                                                 viewType: SelectBrandModullesPrinterVC.SELECT_VIEW_TYPES.ConnectionType,
                                                 connectionType: nil)
            return
        }
        
        if item?.fieldType == .MODEL_PRINTER {
            if let brandString = self.addDeviceVM?.devicesFactorProtocol?.getValue(for: .BRAND_PRINTER) as String?,
                let brand = PRINTER_BRAND_TYPES(rawValue:brandString){
                self.show_chose_brand_model_type_view(sender,
                                                      index:sender.tag,
                                                      selectDataList:self.addDeviceVM?.getSelectStringList(fieldType: .MODEL_PRINTER) ?? [],
                                                      viewType:SelectBrandModullesPrinterVC.SELECT_VIEW_TYPES.Model,
                                                      brand:brand)
            }
            return
        }
        if item?.fieldType == .TYPE_PRINTER{
            self.show_chose_brand_model_type_view(sender,
                                                  index:sender.tag,
                                                  selectDataList:self.addDeviceVM?.getSelectStringList(fieldType: .TYPE_PRINTER)  ?? [],
                                                  viewType:SelectBrandModullesPrinterVC.SELECT_VIEW_TYPES.TYPE,
                                                  brand:nil)
            return
        }
        if item?.fieldType == .SOCKET_STATUS_DEVICE{
            self.show_choose_device_status_view(sender,
                                                  index:sender.tag,
                                                  selectDataList:self.addDeviceVM?.getSelectStringList(fieldType: .SOCKET_STATUS_DEVICE)  ?? [] )
            return
        }
    }
}

extension AddDeviceVC:UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        let item = addDeviceVM?.getDeviceField(at:IndexPath(row: textField.tag , section: 0))
        if item?.fieldType == .NAME {
            self.addDeviceVM?.handlingSetValue(for: textField.tag, value: textField.text )
        }
    }
}
