//
//  SelectBleVC.swift
//  pos
//
//  Created by M-Wageh on 31/01/2024.
//  Copyright © 2024 khaled. All rights reserved.
//

import UIKit

class SelectBleVC: UIViewController {
   
    
    @IBOutlet weak var bleSSDTable: UITableView!
//Missing in merge
    var dataList:[restaurant_printer_class]?
    var selectDataList:restaurant_printer_class?
    var completionBlock:((restaurant_printer_class)->())?
    var mwPrinterBluetooth:MWPrinterBluetooth?
    var mwPrinterUsb: MWUsbPrinterInteractor?
    var isBluetooth: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.async {
            self.initialize()
            self.mwPrinterUsb?.discoverPrinter()
        }
        setupTable()
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mwPrinterBluetooth?.updateLoadingStatusClosure = nil
        mwPrinterBluetooth = nil
        mwPrinterUsb?.updateLoadingStatusClosure = nil
        mwPrinterUsb = nil
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isBluetooth {
            DispatchQueue.global(qos: .userInitiated).async {
                // DispatchQueue.main.async{
                self.mwPrinterBluetooth?.loadBLE()
            }
        } else {
            DispatchQueue.main.async {
                // DispatchQueue.main.async{
                self.setDataList()
            }
        }
    }
   
    func initialize(){
        if isBluetooth {
            initializeForBluetooth()
        } else {
            initializeForUsb()
        }
    }
    
    private func initializeForBluetooth() {
        mwPrinterBluetooth = MWPrinterBluetooth.shared
        mwPrinterBluetooth?.updateLoadingStatusClosure = {
            if let state = self.mwPrinterBluetooth?.state {
                switch state{
                case .NONE:
                    break
                case .Loading:
                    DispatchQueue.main.async {
                        loadingClass.show(view: self.view)
                    }
                    return
                case .Populate:
                    DispatchQueue.main.async {
                        loadingClass.hide(view:self.view)
                        self.setDataList()
                        self.bleSSDTable.reloadData()
                    }
                case .Selected(let resturantPrinter):
                    DispatchQueue.main.async {
                        loadingClass.hide(view:self.view)
                        self.selectDataList = resturantPrinter
                    }
                case .Error(let error):
                    DispatchQueue.main.async {
                        loadingClass.hide(view:self.view)
                        SharedManager.shared.initalBannerNotification(title: "Error".arabic("حدث خطاء"), message: error, success: false, icon_name: "icon_error")
                        SharedManager.shared.banner?.dismissesOnTap = true
                                        SharedManager.shared.banner?.show(duration: 3.0)
                    }
                    
                
                }
            }
        }
    }
    
    private func initializeForUsb() {
        mwPrinterUsb = MWUsbPrinterInteractor.shared
        mwPrinterUsb?.updateLoadingStatusClosure = {
            if let state = self.mwPrinterUsb?.state {
                switch state{
                case .NONE:
                    break
                case .Loading:
                    DispatchQueue.main.async {
                        loadingClass.show(view: self.view)
                    }
                    return
                case .Populate:
                    DispatchQueue.main.async {
                        loadingClass.hide(view:self.view)
                        self.setDataList()
                        self.bleSSDTable.reloadData()
                    }
                case .Selected(let resturantPrinter):
                    DispatchQueue.main.async {
                        loadingClass.hide(view:self.view)
                        self.selectDataList = resturantPrinter
                    }
                case .Error(let error):
                    DispatchQueue.main.async {
                        loadingClass.hide(view:self.view)
                        SharedManager.shared.initalBannerNotification(title: "Error".arabic("حدث خطاء"), message: error, success: false, icon_name: "icon_error")
                        SharedManager.shared.banner?.dismissesOnTap = true
                                        SharedManager.shared.banner?.show(duration: 3.0)
                    }
                    
                
                }
            }
        }
    }
    
    func setDataList() {
        self.dataList?.removeAll()
        self.dataList = []
        
        if isBluetooth {
            let foundDevices = mwPrinterBluetooth?.getFoundDevices() ?? []
            if ((foundDevices.count ) > 0) {
                self.dataList?.append(contentsOf: foundDevices)
            }
        } else {
            let foundDevices = mwPrinterUsb?.getFoundDevices() ?? []
            if ((foundDevices.count ) > 0) {
                self.dataList?.append(contentsOf: foundDevices)
            }
        }
        bleSSDTable.reloadData()
    }
    
    func isItemSelect(_ itemIdentifier: String)->Bool{
        if let selectDataList = self.selectDataList {
            return (selectDataList.printer_ip) == itemIdentifier
        }
        return false
    }

    func itemSelecte(at indexPath:IndexPath){
        if let item = self.dataList?[indexPath.row]{
            selectDataList = item
            if let selectDevice = selectDataList {
                self.dismiss(animated: true, completion: {
                    self.completionBlock?(selectDevice)
                })
            }else{
                self.dismiss(animated: true, completion:nil)
            }
            
        }
        //         self.bleSSDTable.reloadData()
        //         self.completionBlock?(selectDataList ?? [])
    }
    
    @IBAction func tapOnCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)

    }
    
    @IBAction func tapOnDone(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            if let selectDevice = self.selectDataList{
                self.completionBlock?(selectDevice)
            }
        })
    }
    static func createModule(_ sender:UIView?,selectDataList:restaurant_printer_class?, isBluetooth: Bool) -> SelectBleVC {
       let vc:SelectBleVC = SelectBleVC()
       vc.dataList = []
        vc.isBluetooth = isBluetooth
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
extension SelectBleVC:UITableViewDelegate,UITableViewDataSource{
    func setupTable(){
//        bleSSDTable.rowHeight = UITableView.automaticDimension
//        bleSSDTable.estimatedRowHeight = 70
        bleSSDTable.register(UINib(nibName: "SelectCell", bundle: nil), forCellReuseIdentifier: "SelectCell")
        bleSSDTable.delegate = self
        bleSSDTable.dataSource = self
        self.bleSSDTable.reloadData()
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
            cell.bindData(text: item.printer_ip , hideImage: !isItemSelect(item.printer_ip))
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

