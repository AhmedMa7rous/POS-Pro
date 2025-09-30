//
//  DevicesMangmentVC.swift
//  pos
//
//  Created by M-Wageh on 04/06/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import UIKit

class DevicesMangmentVC: UIViewController {

    @IBOutlet weak var deviceManagmentTable: UITableView!
    @IBOutlet weak var emptyView: UIView!

    var devicesMangmentVM:DeviceMangmentVM?
    var isStartPing:Bool?
    override func viewDidLoad() {
        super.viewDidLoad()
        initalState()
        setupTable()
        init_notificationCenter()
        isStartPing = false
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        remove_notificationCenter()
    }
    
    func init_notificationCenter()
    {
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.test_printer_done(notification:)), name: Notification.Name("test_printer_done"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.test_connection_done(notification:)), name: Notification.Name("test_connection_done"), object: nil)


    }
    
    func remove_notificationCenter() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("test_printer_done"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("test_connection_done"), object: nil)

    }
    //MARK:- inital State 
    func initalState(){
        self.devicesMangmentVM?.updateLoadingStatusClosure = { (state) in
           
            switch state {
            case .EMPTY:
                DispatchQueue.main.async {
                    loadingClass.hide(view:self.view)
                    self.emptyView.isHidden = false
                    
                }
                return
            case .ERROR(let error):
                DispatchQueue.main.async {
                    loadingClass.hide(view:self.view)
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
                    self.emptyView.isHidden = true
                    self.deviceManagmentTable.reloadData()
                    loadingClass.hide(view:self.view)
                }
                return
            }
            
        }
    }
    func openAddDeviceVC(deviceFactor:AddDevicesFactorProtocol){
        let vc = AddDeviceVC.createModule(with: deviceFactor)
        vc.completeHandler = {
            DispatchQueue.main.async {
                self.devicesMangmentVM?.reloadFetch()
            }

        }
        self.present(vc, animated: true)
    }
    @IBAction func tapOnAddNewPrinter(_ sender: KButton) {
        show_choose_device_type_view(sender)
    }
    func show_choose_device_type_view(_ sender:UIView)
    {
        let vc = SelectDeviceTypeVC.createModule(sender,dataList:self.devicesMangmentVM?.avaliableDevicesTypes ?? [])
        self.present(vc, animated: true, completion: nil)
        vc.completionBlock = { selectDataList in
            if let deviceType:DEVICES_TYPES_ENUM = selectDataList.first{
                if deviceType.canAcces(){
                    let factor = deviceType.getDeviceFactor()
                    self.openAddDeviceVC(deviceFactor:factor)
                }
                
            }

            
        }
    }
    static func  createModule(devicesTypes:[DEVICES_TYPES_ENUM]) -> DevicesMangmentVC{
        let vc = DevicesMangmentVC()
        vc.devicesMangmentVM = DeviceMangmentVM(devicesTypes:devicesTypes)
        return vc
    }
    
}
extension DevicesMangmentVC:UITableViewDelegate,UITableViewDataSource{
    func setupTable(){
        deviceManagmentTable.allowsSelection = true
        deviceManagmentTable.delegate = self
        deviceManagmentTable.dataSource = self
        deviceManagmentTable.rowHeight = UITableView.automaticDimension
        deviceManagmentTable.estimatedRowHeight = 80
        deviceManagmentTable.register(UINib(nibName: "DevicesManagementCell", bundle: nil), forCellReuseIdentifier: "DevicesManagementCell")
        //SectionHeaderCell
        deviceManagmentTable.register(UINib(nibName: "SectionHeaderCell", bundle: nil), forCellReuseIdentifier: "SectionHeaderCell")

        
    }

    // MARK: - Table view data source
     func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
         return devicesMangmentVM?.getSectionCount() ?? 0
    }

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
             return devicesMangmentVM?.getDeviceCount(for:section) ?? 0
           
    }
    
   
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DevicesManagementCell", for: indexPath) as! DevicesManagementCell
        // Configure the cell...
        cell.deviceDictionary = devicesMangmentVM?.getDevice(at:indexPath)
         let tapPingGesture = MWGesture(target: self, action: #selector(self.tapOnPingBtn(_:)))
         cell.pingBtn.addGestureRecognizer(tapPingGesture)
         tapPingGesture.indexPath = indexPath
        cell.delegate = self
        return cell
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let deviceDictionary = devicesMangmentVM?.getDevice(at:indexPath){
            let type = DEVICES_TYPES_ENUM(rawValue:deviceDictionary["type"] as? String ?? "")
            if type?.canAcces() ?? true{
                
                if type == DEVICES_TYPES_ENUM.POS_PRINTER ||  type == DEVICES_TYPES_ENUM.KDS_PRINTER{
                    if let deviceFactor = type?.getDeviceFactor(printer:restaurant_printer_class(fromDictionary:deviceDictionary )){               
                        openAddDeviceVC(deviceFactor:deviceFactor)
                    }
                }else{
                    if let deviceFactor = type?.getDeviceFactor( socketDevice:socket_device_class(from: deviceDictionary)){               
                        openAddDeviceVC(deviceFactor:deviceFactor)
                    }
                }
            }
        }

    }
    //MARK: - Section Header
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        //SectionHeaderCell
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "SectionHeaderCell") as! SectionHeaderCell
        headerCell.tapHeaterBtn.tag = section
        headerCell.tapHeaterBtn.addTarget(self, action: #selector(selectHeader(_ :)), for: .touchUpInside)
        headerCell.bind(with:devicesMangmentVM?.getTitle(for:section) ?? "")
        return headerCell

    }
    
    @objc func selectHeader(_ sender:UIButton){
       // linesListVM?.togleExpanded(at:sender.tag)
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }

    
}
extension DevicesMangmentVC:DevicesManagementProtocol{
    func deleteGeideaDevice(for device_socket: socket_device_class) {
        self.devicesMangmentVM?.removeDeviceAction(device_socket)
    }
    
    func deletSocketDevice(for device_socket: socket_device_class) {
        if self.isStartPing ?? false{
         
            return
        }
        self.devicesMangmentVM?.deletDevice(device_socket)

    }
    
    func testConnection(for printer:restaurant_printer_class){
        
        MWQueue.shared.mwPrintersQueue.async {
            if self.validateIfTestConnectionFinsih() && self.validateIfPrinterTaskNotWorking() {
            self.devicesMangmentVM?.isStaerTestConnection = true
            MWPrinterSDK.shared.setPrinterSDK(from: printer)
            MWPrinterSDK.shared.checkConnection(for:printer )
        }
        }
    }
    func testGeideaConnection(for device_socket: socket_device_class) {
        if let ip = device_socket.device_ip {
            self.devicesMangmentVM?.checkConnection(for: ip )
        }
    }
    func testPrinter(for printer:restaurant_printer_class){
        if validateIfTestConnectionFinsih(){
            SharedManager.shared.MWprintTestPrinter(for: printer)
            MWRunQueuePrinter.shared.startMWQueue()
        }
    }
    func deletPrinter(for printer:restaurant_printer_class){
        if validateIfTestConnectionFinsih() && validateIfPrinterTaskNotWorking() {
            self.devicesMangmentVM?.hitDeletPrinterAPI(printer)
        }
    }
    func openLogPrinter(for printer:restaurant_printer_class){
        
    }
    @objc func test_connection_done(notification: NSNotification){
        DispatchQueue.main.async {
            self.devicesMangmentVM?.isStaerTestConnection = false
            self.devicesMangmentVM?.reloadFetch()
        }
    }
    @objc func test_printer_done(notification: NSNotification){
        DispatchQueue.main.async {
            self.devicesMangmentVM?.reloadFetch()
        }
    }
   
    @objc func tapOnPingBtn(_ sender: MWGesture){
        if let indexPath = sender.indexPath {
            if let deviceDictionary = devicesMangmentVM?.getDevice(at:indexPath){
                loadingClass.show(view: self.view)
                self.isStartPing = true
                MWLocalNetworking.sharedInstance.ping(for:socket_device_class(from: deviceDictionary) , completionHandler: { result in
                    DispatchQueue.main.async {
                        self.isStartPing = false
                        loadingClass.hide(view:self.view)
                        self.devicesMangmentVM?.setPing(at:indexPath,with: (result.lowercased().contains("successfully")) ?  .SUCCESS : .FAIL)
                        messages.showAlert(result)
                    }
                })
            }
        }
    }
    func validateIfTestConnectionFinsih() -> Bool{
        if  self.devicesMangmentVM?.isStaerTestConnection ?? false{
           // SharedManager.shared.initalBannerNotification(title: "Waiting!", message: "please, Waiting until printer finish test connection".arabic("من فضلك ، في انتظار انتهاء الطابعة من اختبار الاتصال"), success: false, icon_name: "")
          //  SharedManager.shared.banner?.dismissesOnTap = true
           // SharedManager.shared.banner?.show(duration: 3)
            return false
        }
        return true
    }
    
    func validateIfPrinterTaskNotWorking() -> Bool{
        if MWRunQueuePrinter.shared.isRunning(){
           // SharedManager.shared.initalBannerNotification(title: "Waiting!", message: "please, Waiting until printer finish her tasks".arabic("من فضلك ، انتظر حتى تنهي الطابعة مهامها"), success: false, icon_name: "")
            //SharedManager.shared.banner?.dismissesOnTap = true
           // SharedManager.shared.banner?.show(duration: 3)
            return false
        }
        return true
    }
   
}

class MWGesture: UITapGestureRecognizer {
    var indexPath:IndexPath?
}

enum PING_STATUS:Int{
    case NONE = 0, SUCCESS,FAIL
    func getColor() -> UIColor{
        switch self {
        case .NONE:
            return  #colorLiteral(red: 0.986671865, green: 0.468683362, blue: 0, alpha: 1)
        case .SUCCESS:
           return #colorLiteral(red: 0, green: 0.6274509804, blue: 0.6156862745, alpha: 1)
        case .FAIL:
            return #colorLiteral(red: 0.5294117647, green: 0.3529411765, blue: 0.4823529412, alpha: 1)
        
        }
    }
}
