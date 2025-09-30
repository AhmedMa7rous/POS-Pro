//
//  SelectBleVC.swift
//  pos
//
//  Created by M-Wageh on 31/01/2024.
//  Copyright © 2024 khaled. All rights reserved.
//

import UIKit

class SelectZebraScannerBleVC: UIViewController {
   
    
    @IBOutlet weak var bleSSDTable: UITableView!
//Missing in merge
    var dataList:[ScannerInfo]?
    var selectDataList:ScannerInfo?
    var completionBlock:((ScannerInfo)->())?
    var zebraBarCodeHelper:ZebraBarCodeHelper?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        zebraBarCodeHelper = ZebraBarcodeDeviceInteractor.shared.zebraBarCodeHelper
        self.initializeForBluetooth()
        self.initialize()
        setupTable()
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.stopDiscovery()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
      
//            DispatchQueue.global(qos: .userInitiated).async {
                // DispatchQueue.main.async{
                self.setDataList()
//            }
    }
    func stopDiscovery(){
        zebraBarCodeHelper?.stopDiscoveryOnly()
        zebraBarCodeHelper?.updateLoadingStatusClosure = nil
        zebraBarCodeHelper = nil

    }
   
    func initialize(){
        zebraBarCodeHelper?.startDiscoveryOnly()
        ZebraBarcodeDeviceInteractor.shared.startDiscoveryOrConnect()

    }
    
    private func initializeForBluetooth() {
        zebraBarCodeHelper?.updateLoadingStatusClosure = {
            if let state = self.zebraBarCodeHelper?.stateZebra {
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
                        self.reloadTable()
                    }
                case .Selected(let scannerInfo):
                    DispatchQueue.main.async {
                        loadingClass.hide(view:self.view)
                        self.selectDataList = scannerInfo
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
        
        let foundDevices = zebraBarCodeHelper?.availableScannerList ?? []
            if ((foundDevices.count ) > 0) {
                self.dataList?.append(contentsOf: foundDevices)
            }
        reloadTable()
    }
    func reloadTable(){
        DispatchQueue.main.async{
            self.bleSSDTable.reloadData()
        }
    }
    
    func isItemSelect(_ itemIdentifier: String)->Bool{
        if let selectDataList = self.selectDataList {
            return (selectDataList.scannerName) == itemIdentifier
        }
        return false
    }

    func itemSelecte(at indexPath:IndexPath){
        if let item = self.dataList?[indexPath.row]{
            self.stopDiscovery()
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
    static func createModule(_ sender:UIView?,selectDataList:ScannerInfo?) -> SelectZebraScannerBleVC {
       let vc:SelectZebraScannerBleVC = SelectZebraScannerBleVC()
       vc.dataList = []
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
extension SelectZebraScannerBleVC:UITableViewDelegate,UITableViewDataSource{
    func setupTable(){
//        bleSSDTable.rowHeight = UITableView.automaticDimension
//        bleSSDTable.estimatedRowHeight = 70
        bleSSDTable.register(UINib(nibName: "SelectCell", bundle: nil), forCellReuseIdentifier: "SelectCell")
        bleSSDTable.delegate = self
        bleSSDTable.dataSource = self
        reloadTable()
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
            cell.bindData(text: item.scannerName , hideImage: !isItemSelect(item.scannerName))
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

