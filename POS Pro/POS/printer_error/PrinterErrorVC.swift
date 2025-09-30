//
//  PrinterErrorVC.swift
//  pos
//
//  Created by M-Wageh on 30/06/2021.
//  Copyright © 2021 khaled. All rights reserved.
//

import UIKit

class PrinterErrorVC: UIViewController {

    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    @IBOutlet weak var errorLbl: UITextView!
    @IBOutlet weak var printerErrorImage: UIImageView!
    @IBOutlet weak var printerInfo: UITextField!
    
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var clearPrintAllView: UIView!
    
    @IBOutlet weak var viewErrorPrinter: ShadowView!
    
    @IBOutlet weak var clearBtn: KButton!
    @IBOutlet weak var btnAddPrinter: KButton!
    
    @IBOutlet weak var printBtn: KButton!
    
    @IBOutlet weak var sentNoteBtn: KButton!
    var printerErrorData: [printer_error_class] = []
    var all_printers: [[String:Any]] = []
    var selected_printer:epson_printer_class!
    fileprivate let pickerView = ToolbarPickerView()
    var selected_restaurant_printer: restaurant_printer_class?
    var hideSegment:Bool?
    override func viewDidLoad() {
        super.viewDidLoad()
        if !SharedManager.shared.appSetting().enable_support_multi_printer_brands {
            sentNoteBtn.tag = -1
            self.setHidenSentNoteBtn(with: true)
        }
        self.segmentControl.isHidden = hideSegment ?? false
        init_notificationCenter()
        setupTable()
        if LanguageManager.currentLang() == .ar {
            segmentControl.setTitle("أخطاء الطابعة", forSegmentAt: 0)
            segmentControl.setTitle("كل الطابعات", forSegmentAt: 1)
        }
        segmentControl.selectedSegmentIndex = 0
        DispatchQueue.main.async {
            self.tapOnSegment(self.segmentControl)
            self.fetchAllPrinter()
            self.setupTF()
        }
        
        segmentControl.setSelectedSegmentForegroundColor(.white, andTintColor:  UIColor(hexFromString: "#e97726"));

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if segmentControl.selectedSegmentIndex == 1
        {
            self.fetchAllPrinter()
            self.table.reloadData()

        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        remove_notificationCenter()
    }
    func setupTF(){
        self.printerInfo.inputView = self.pickerView
//        self.printerInfo.delegate     = self

                self.printerInfo.inputAccessoryView = self.pickerView.toolbar

                self.pickerView.dataSource = self
                self.pickerView.delegate = self
                self.pickerView.toolbarDelegate = self

                self.pickerView.reloadAllComponents()
    }
    func showLoadinPrinter(){
        let printer_status_vc = printer_status()
        printer_status_vc.completion = { isDone in
            self.tapOnSegment(self.segmentControl)
        }
        printer_status_vc.modalPresentationStyle = .overCurrentContext
        self.present(printer_status_vc, animated: true, completion: nil)

    }
    func setHidenSentNoteBtn(with value:Bool){
        self.sentNoteBtn.isHidden = true
        /*
        if self.sentNoteBtn.tag != -1 {
            self.sentNoteBtn.isHidden = value

        }else{
            self.sentNoteBtn.isHidden = true
        }
        */
        
    }
    
    @IBAction func tapOnSendNoteBtn(_ sender: KButton) {
      //  let vc = SentNoteViaPrintersVC.createModule()
    // self.present(vc, animated: true, completion: nil)
    }
    @IBAction func tapOnClearAll(_ sender: KButton) {
        printer_error_class.reset()
        self.viewErrorPrinter.isHidden = true
        self.tapOnSegment(self.segmentControl)
    }
    @IBAction func tapOnPrintAllAll(_ sender: KButton) {
        printer_error_class.currentReTryPrintCount = 0
        if SharedManager.shared.appSetting().enable_support_multi_printer_brands{
            self.printerErrorData.forEach { item in
                item.addToErrorImageMWQueue()
            }
            MWRunQueuePrinter.shared.startMWQueue()
            self.showLoadinPrinter()
            
        }else{
        DispatchQueue.global(qos: .background).async() {
       if printer_error_class.reTryToPrintIsAvaliable(with: true){
        SharedManager.shared.epson_queue.run()
        
        }
//        self.dismiss(animated: true, completion: nil)
        }}
        tapOnClearAll(sender)
        self.showLoadinPrinter()
    }
    
    @IBAction func tapOnClearItem(_ sender: KButton) {
        self.viewErrorPrinter.isHidden = true

        let item = self.printerErrorData[sender.tag]
        item.clearErrorFromDB()
        item.deletImage()
        self.tapOnSegment(self.segmentControl)

    }
    
    @IBAction func tapOnPrintItem(_ sender: KButton) {
        self.viewErrorPrinter.isHidden = true
        if SharedManager.shared.appSetting().enable_support_multi_printer_brands{
            self.printerErrorData[sender.tag].addToErrorImageMWQueue()
            MWRunQueuePrinter.shared.startMWQueue()
        }else{
        self.printerErrorData[sender.tag].tryToPrint(resturantPrinter: self.selected_restaurant_printer)
        SharedManager.shared.epson_queue.run()
        }
        tapOnClearItem(sender)
        showLoadinPrinter()
    }
    
    @IBAction func tapOnSegment(_ sender: UISegmentedControl) {
        self.viewErrorPrinter.isHidden = true
        
 
        
        if self.segmentControl.selectedSegmentIndex == 0 {
            DispatchQueue.main.async {
                self.fetchPrinterErrorData()
                self.btnAddPrinter.isHidden = true
                self.setHidenSentNoteBtn(with :false)

            }
        }else{
            self.viewErrorPrinter.isHidden = true
            self.setHidenSentNoteBtn(with :true)
            DispatchQueue.main.async {
                self.fetchAllPrinter()
                self.table.reloadData()
                let casher = SharedManager.shared.activeUser()
                self.btnAddPrinter.isHidden = casher.canAccess(for: .update_devices) == false



            }
        }
        
        DispatchQueue.main.async {
        self.clearPrintAllView.isHidden =  self.segmentControl.selectedSegmentIndex != 0
        }

    }
    
    @IBAction func btnAddPrinter(_ sender: Any) {
        
//        let item = all_printers![indexPath.row]
//          let printer = restaurant_printer_class(fromDictionary: item)
 
        let storyboard = UIStoryboard(name: "printer", bundle: nil)
        
        let vc = storyboard.instantiateViewController(    withIdentifier: "addNetworkPrinter") as! addNetworkPrinter
        
        vc.reloadPrinters =  {
            self.fetchAllPrinter()
            self.table.reloadData()

        }
        
//        vc.printer = printer
        vc.modalPresentationStyle = .formSheet
        vc.preferredContentSize = CGSize(width: 900, height: 700)
        self.present(vc, animated: true, completion: nil)
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func fetchAllPrinter(){
        all_printers.removeAll()
        let cashName   = cash_data_class.get(key: "setting_name") ?? ""
        let cashIp  = cash_data_class.get(key: "setting_ip") ?? ""
        let test_printer_status  = cash_data_class.get(key: "test_printer_status") ?? "0"

        if !cashName.isEmpty && !cashIp.isEmpty{
        var dictionary:[String:Any] = [:]
        dictionary["id"] = 0
        dictionary["display_name"] = cashName
        dictionary["name"] = cashName
        dictionary["__last_update"] = ""
        dictionary["printer_ip"] = cashIp
        dictionary["proxy_ip"] = cashIp
        dictionary["epson_printer_ip"] = cashIp
        dictionary["test_printer_status"] = Int(test_printer_status) ?? 0
        all_printers.append(dictionary)
        }
        all_printers.append(contentsOf:restaurant_printer_class.getAll() )
    }
    func fetchPrinterErrorData(){
        printerErrorData.removeAll()
        self.table.reloadData()
        printerErrorData.append(contentsOf: printer_error_class.getAllObject(sql:" order by id desc"))
        self.table.reloadData()

    }
}
extension PrinterErrorVC : UITableViewDelegate,UITableViewDataSource{
    func setupTable(){
        //PrinterErrorCell
        table.register(UINib(nibName: "PrinterAvaliableCell", bundle: nil), forCellReuseIdentifier: "PrinterAvaliableCell")
        table.register(UINib(nibName: "PrinterErrorCell", bundle: nil), forCellReuseIdentifier: "PrinterErrorCell")


    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.segmentControl.selectedSegmentIndex == 0 {
            return printerErrorData.count
        }
        return all_printers.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.segmentControl.selectedSegmentIndex == 0 {
            let cell: PrinterErrorCell = tableView.dequeueReusableCell(withIdentifier: "PrinterErrorCell", for: indexPath) as! PrinterErrorCell
            cell.testPtinterBtn.isHidden = self.segmentControl.selectedSegmentIndex == 0
            let item = printerErrorData[indexPath.row]
            let timeAgoSinceDate = date_base_class.timeAgoSinceDate(Date(millis: item.time), currentDate: Date(), numericDates: true)

            if item.type_printer_error == rowType.order.rawValue {
                cell.orderNumberLbl.text = "Order:#\(item.order_id) - \(timeAgoSinceDate)"
            }else{
//                let strDate = Date(millis: item.time).toString(dateFormat: "dd/MM/yy hh:mm a" , UTC: false)
                cell.orderNumberLbl.text = "\(item.type_printer_error) - \(timeAgoSinceDate)"
            }
            cell.printerInfoLbl.text = item.printer_name
        
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "PrinterAvaliableCell") as! PrinterAvaliableCell
            if indexPath.row < all_printers.count {
            let item = all_printers[indexPath.row]
            let printer = restaurant_printer_class(fromDictionary: item)
            cell.OutPrinterInfolbl?.text = printer.name + " / " + printer.printer_ip
            cell.testPrintBtn.tag = indexPath.row
            cell.testConnectionBtn.tag = indexPath.row
            cell.testPrintBtn.addTarget(self, action: #selector(testPrinter(_:)), for: .touchUpInside)
            cell.testConnectionBtn.addTarget(self, action: #selector(testConnection(_:)), for: .touchUpInside)
            cell.doStyle(for:TEST_PRINTER_Status(rawValue: printer.test_printer_status) ?? .NONE )
            cell.errorView.isHidden = !printer.haveFailReport()
//            cell.printer = epson_printer_class(IP: printer.printer_ip, printer_name: printer.name ,printer_id: printer.id  )
            }
            return cell

        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.segmentControl.selectedSegmentIndex == 0 {
            self.selected_restaurant_printer = nil
            self.clearBtn.tag = indexPath.row
            self.printBtn.tag = indexPath.row
            self.printerInfo.tag = indexPath.row
            let item = printerErrorData[indexPath.row]
            self.printerInfo.text = (item.IP ?? "") + " - " + (item.printer_name ?? "")
            self.printerErrorImage.image = item.getPrinterImage().image
            self.errorLbl.text = item.error
            self.viewErrorPrinter.isHidden = false

        }
        else
        {
            /*
                    let item = all_printers[indexPath.row]
                      let printer = restaurant_printer_class(fromDictionary: item)
             
                    let storyboard = UIStoryboard(name: "printer", bundle: nil)
                    
                    let vc = storyboard.instantiateViewController(    withIdentifier: "addNetworkPrinter") as! addNetworkPrinter
                    
                    vc.printer = printer
            
            vc.reloadPrinters =  {
                self.fetchAllPrinter()
                self.table.reloadData()

            }
            
                    vc.modalPresentationStyle = .formSheet
                    vc.preferredContentSize = CGSize(width: 900, height: 700)
                    self.present(vc, animated: true, completion: nil)
             */
        }
    }
    @objc func testPrinter(_ sender:UIButton){
        if SharedManager.shared.epson_queue.is_run {
            return
        }
        let item = all_printers[sender.tag]
        let restaurantPrinter = restaurant_printer_class(fromDictionary: item)
        let testedPrinter = epson_printer_class(IP: restaurantPrinter.printer_ip, printer_name: restaurantPrinter.name ,printer_id: restaurantPrinter.id  )
        var HTMLContent = baseClass.get_file_html(filename: "test_print",showCopyRight: true)
       
//        let  image =  runner_print_class.htmlToImage(html:html)
//        let p = epson_printer_class(IP: printer.IP)
//      _ =   p.createReceiptData(imageData: image)
    
        let id = testedPrinter.printer_id
        let IP = testedPrinter.IP ?? ""
        let printer_name = testedPrinter.printer_name ?? ""
        let date = Date().toString(dateFormat: baseClass.date_fromate_satnder_12h, UTC: false)

        HTMLContent = HTMLContent.replacingOccurrences(of: "#PRINTER_NAME#", with: printer_name)
        HTMLContent = HTMLContent.replacingOccurrences(of: "#PRINTER_IP#", with: IP)
        HTMLContent = HTMLContent.replacingOccurrences(of: "#REF_DATE#", with: date)
        HTMLContent = HTMLContent.replacingOccurrences(of: "#POS_NAME#", with: SharedManager.shared.posConfig().name ?? "")
        let cates = restaurantPrinter.getCategoriesNamesArray().joined(separator: "<br>")
        HTMLContent = HTMLContent.replacingOccurrences(of: "#CATEGORIES#", with: cates)



        let printer = SharedManager.shared.printers_pson_print[id] ?? epson_printer_class(IP: IP,printer_name: printer_name,printer_id: id )
        
        
        let jobPrinter = job_printer()
        jobPrinter.type = .image
        jobPrinter.html = HTMLContent
        jobPrinter.time = baseClass.getTimeINMS()
        jobPrinter.row_type = .test

        printer.addToQueue(job: jobPrinter,index:0)
        SharedManager.shared.printers_pson_print[id] = printer
        SharedManager.shared.epson_queue.run()

    }
    @objc func testConnection(_ sender:UIButton){
        let item = all_printers[sender.tag]
        let printer = restaurant_printer_class(fromDictionary: item)
        check_printer(epson_printer_class(IP: printer.printer_ip, printer_name: printer.name ,printer_id: printer.id  ))
        
    }
    func check_printer(_ epos_printer:epson_printer_class)
    {
      
        loadingClass.show(view: self.view)
        
        selected_printer = epos_printer
        selected_printer.is_printer_online = false
       _ = epos_printer.initializePrinterObject()
        epos_printer.checkStatusPrinter()
    }
}
extension PrinterErrorVC: UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.all_printers.count
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let item = self.all_printers[row]
        let printer = restaurant_printer_class(fromDictionary: item)
        return printer.display_name + " - " + printer.printer_ip
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let item = self.all_printers[row]
        let printer = restaurant_printer_class(fromDictionary: item)
        self.printerInfo.text = printer.display_name + " - " + printer.printer_ip
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
}

extension PrinterErrorVC: ToolbarPickerViewDelegate {

    func didTapDone() {
        if self.all_printers.count > 0{
            let row = self.pickerView.selectedRow(inComponent: 0)
            self.pickerView.selectRow(row, inComponent: 0, animated: false)
            let item = self.all_printers[row]
            let printer = restaurant_printer_class(fromDictionary: item)
            let value = printer.display_name + " - " + printer.printer_ip
            if !value.isEmpty{
                self.selected_restaurant_printer = printer
                self.printerInfo.text = value
            }
        }
      
        self.printerInfo.resignFirstResponder()
    }

    func didTapCancel() {
//        self.printerInfo.text = nil
        self.printerInfo.resignFirstResponder()
    }
}
extension PrinterErrorVC{
    func init_notificationCenter()
    {
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("printer_status"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.test_printer_done(notification:)), name: Notification.Name("test_printer_done"), object: nil)

    }
    
    func remove_notificationCenter() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("printer_status"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("test_printer_done"), object: nil)
    }
    @objc func test_printer_done(notification: NSNotification){
        DispatchQueue.main.async {
        if self.segmentControl.selectedSegmentIndex != 0 {
            self.tapOnSegment(self.segmentControl)
        }
        }
    }
    @objc func methodOfReceivedNotification(notification: NSNotification){
        
        let obj = notification.object as? epson_printer_class
        printer_status_done(printer: obj!)
    }
    func printer_status_done(printer:epson_printer_class)
    {
        DispatchQueue.main.async {
            loadingClass.hide(view: self.view)
        }
    }
}
