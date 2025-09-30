//
//  network_printer.swift
//  pos
//
//  Created by Khaled on 3/1/21.
//  Copyright © 2021 khaled. All rights reserved.
//

import UIKit

class network_printer_cell: UITableViewCell {
   
    @IBOutlet weak var testConnectionBtn: KButton!
    @IBOutlet weak var testPrintBtn: KButton!
    var parent:network_printer!
    var printer:epson_printer_class!
 
    @IBOutlet weak var OutPrinterInfolbl: KLabel!
    
    @IBOutlet weak var errorImage: UIImageView!
    
    func doStyle(for status:TEST_PRINTER_Status){
        switch status {
        case .NONE:
            self.testPrintBtn.backgroundColor = #colorLiteral(red: 0.431372549, green: 0.431372549, blue: 0.431372549, alpha: 1)
        case .SUCCESS:
            self.testPrintBtn.backgroundColor = #colorLiteral(red: 0, green: 0.6274509804, blue: 0.6156862745, alpha: 1)
        case .FAIL:
            self.testPrintBtn.backgroundColor = #colorLiteral(red: 0.5294117647, green: 0.3529411765, blue: 0.4823529412, alpha: 1)
        }
    }
    
    @IBAction func btn_test_printer(_ sender: Any) {
        if SharedManager.shared.epson_queue.is_run {
            return
        }
   
        var HTMLContent = baseClass.get_file_html(filename: "test_print",showCopyRight: true)
//        let  image =  runner_print_class.htmlToImage(html:html)
//        let p = epson_printer_class(IP: printer.IP)
//      _ =   p.createReceiptData(imageData: image)
    
        let id = printer.printer_id
        let IP = printer.IP ?? ""
        let printer_name = ""
        
        let date = Date().toString(dateFormat: baseClass.date_fromate_satnder_12h, UTC: false)

        HTMLContent = HTMLContent.replacingOccurrences(of: "#PRINTER_NAME#", with: printer.printer_name ?? "")
        HTMLContent = HTMLContent.replacingOccurrences(of: "#PRINTER_IP#", with: IP)
        HTMLContent = HTMLContent.replacingOccurrences(of: "#REF_DATE#", with: date)
        HTMLContent = HTMLContent.replacingOccurrences(of: "#POS_NAME#", with: SharedManager.shared.posConfig().name ?? "")
        let cates = restaurant_printer_class.getCategoriesNames(for:id).joined(separator: "<br>")
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

    @IBAction func btn_test_connection(_ sender: Any) {
  

        parent?.check_printer(printer)
    }
    
}
class network_printer: baseViewController , UITableViewDataSource, UITableViewDelegate{

    @IBOutlet weak var printerView: UITableView!
    var all_printers: [[String:Any]]?
    var selected_printer:epson_printer_class!

    
    override func viewDidLoad() {
        super.viewDidLoad()

      
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        all_printers =  restaurant_printer_class.getAll()
       self.printerView.reloadData()
       
       init_notificationCenter()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        //       clearMemory()
        
        remove_notificationCenter()
    }
    
    
    func init_notificationCenter()
    {
        
//        let Epos_printer = AppDelegate.shared.getDefaultPrinter()
//
 
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("printer_status"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.test_printer_done(notification:)), name: Notification.Name("test_printer_done"), object: nil)


        
        
    }
    
    func remove_notificationCenter() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("printer_status"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("test_printer_done"), object: nil)

        
    }
    
    @objc func methodOfReceivedNotification(notification: NSNotification){
        // Take Action on Notification
        //        loadingClass.hide(view: self.view)
        
        let obj = notification.object as? epson_printer_class
        printer_status(printer: obj!)
    }
    
    @objc func test_printer_done(notification: NSNotification){
        DispatchQueue.main.async {
            self.all_printers =  restaurant_printer_class.getAll()
           self.printerView.reloadData()
        }
    }
    
    func check_printer(_ epos_printer:epson_printer_class)
    {
      
        loadingClass.show(view: self.view)
        
        selected_printer = epos_printer
        selected_printer.is_printer_online = false
       _ = epos_printer.initializePrinterObject()
        epos_printer.checkStatusPrinter()
    }
    
    
    func printer_status(printer:epson_printer_class)
    {
        DispatchQueue.main.async {
            loadingClass.hide(view: self.view)

        }
//
//         if selected_printer == printer
//         {
////            if printer.is_printer_online
////            {
////                printer_message_class.show("",true)
////
////            }
////            else
////            {
////                printer_message_class.show("",false)
////
////            }
//         }
        
    }
    
    @IBAction func btnAdd(_ sender: Any) {
        let storyboard = UIStoryboard(name: "printer", bundle: nil)
        
        let vc = storyboard.instantiateViewController(    withIdentifier: "addNetworkPrinter") as! addNetworkPrinter
        
 
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    func btn_show_categories(_ cats:[[String : Any]] ) {
        
        
        let list = options_listVC(nibName: "options_popup", bundle: nil)
        list.hideClearBtnFlag = true
        list.modalPresentationStyle = .overFullScreen
        list.modalTransitionStyle = .crossDissolve
        list.title = "Categories"
        
        
        for c in cats
        {
             let key_name = c["name"]  as? String ?? ""

            var dic:[String:Any] = [:]
 
            dic[options_listVC.title_prefex] = key_name
            list.list_items.append(dic)

        }
        
 
        
        options_listVC.show_option(list:list,viewController: self, sender: nil  )

    }
    
    
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
        
        return all_printers!.count
    }
      func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "network_printer_cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as! network_printer_cell

        let item = all_printers![indexPath.row]
          let printer = restaurant_printer_class(fromDictionary: item)

        cell.OutPrinterInfolbl?.text = printer.name + " / " + printer.printer_ip
        cell.parent = self
        cell.printer = epson_printer_class(IP: printer.printer_ip, printer_name: printer.name ,printer_id: printer.id  )
        cell.doStyle(for:TEST_PRINTER_Status(rawValue:printer.test_printer_status) ?? .NONE)
        cell.errorImage.isHidden = !printer.haveFailReport()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
        let item = all_printers![indexPath.row]
          let printer = restaurant_printer_class(fromDictionary: item)
 
        let storyboard = UIStoryboard(name: "printer", bundle: nil)
        
        let vc = storyboard.instantiateViewController(    withIdentifier: "addNetworkPrinter") as! addNetworkPrinter
        
        vc.printer = printer
    
        self.navigationController?.pushViewController(vc, animated: true)
        
//        let nav = UINavigationController(rootViewController: vc);
//        nav.isNavigationBarHidden = true
//        nav.modalPresentationStyle = .fullScreen
        
//        self!.present(nav, animated: true, completion: nil)

//        let cats_ids = printer.get_product_categories_ids()
//
//       let cats =  pos_category_class.get(ids: cats_ids)
//
//        btn_show_categories(cats)
     }

}
