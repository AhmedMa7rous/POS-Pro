//
//  addPrinter.swift
//  pos
//
//  Created by khaled on 7/25/19.
//  Copyright © 2019 khaled. All rights reserved.
//

import Foundation

class addPrinter: UIViewController
{
    @IBOutlet var txt_ip: UITextField!
    @IBOutlet var txt_name: UITextField!
   
    @IBOutlet var btnBack: UIButton!
    public var inStartApp :Bool = false
    
    
    var parent_vc:UIViewController?
    
      //var printerInfo: Epos2DeviceInfo?
    
    var printer_name:String?
    var printer_ip:String?
    var completionSave:((_ result: Bool) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        
     
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if printer_ip == nil {
            let setting = settingClass.getSetting()
            txt_ip.text = setting.ip
            txt_ip.text = txt_ip.text?.replacingOccurrences(of: "TCP:", with: "")
            txt_name.text = setting.name
        }
        else
        {
            txt_ip.text = printer_ip
            txt_ip.text = txt_ip.text?.replacingOccurrences(of: "TCP:", with: "")
            txt_name.text = printer_name
        }
    }
    
    
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSave(_ sender: Any) {
        self.view.endEditing(true)
        
 
        settingClass.savePrinter(name: txt_name.text, ip: txt_ip.text)
        
    
        printer_message_class.show("Printer saved successfully",true)
        SharedManager.shared.epson_queue.stop()
        
//        AppDelegate.shared.Epos = Epos2Class(load_printer: true)
//        AppDelegate.shared.setupDefaultPrinter()
        
        if inStartApp == true
        {
             AppDelegate.shared.loadLoading()
        }
        else
        {
            completionSave?(true)
            
            self.navigationController?.popViewController(animated: true)

        }
        
        
    }
    
    @IBAction func btn_test_print(_ sender: Any) {
        if SharedManager.shared.epson_queue.is_run {
            return
        }
        var HTMLContent = baseClass.get_file_html(filename: "test_print",showCopyRight: true)
 
        
        let printer = AppDelegate.shared.getDefaultPrinter()
        
//        let id = 0
//        let IP = txt_ip.text ?? ""
//        let printer_name = txt_name.text ?? ""
//
//        let printer = SharedManager.shared.printers_pson_print[id] ?? epson_printer_class(IP: IP,printer_name: printer_name )
        let IP = printer.IP ?? ""
        let printer_name = printer.printer_name ?? ""
        let date = Date().toString(dateFormat: baseClass.date_fromate_satnder_12h, UTC: false)

        HTMLContent = HTMLContent.replacingOccurrences(of: "#PRINTER_NAME#", with: printer_name)
        HTMLContent = HTMLContent.replacingOccurrences(of: "#PRINTER_IP#", with: IP)
        HTMLContent = HTMLContent.replacingOccurrences(of: "#REF_DATE#", with: date)
        HTMLContent = HTMLContent.replacingOccurrences(of: "#POS_NAME#", with: SharedManager.shared.posConfig().name ?? "")

        let cates = restaurant_printer_class.getCategoriesNames(for:0).joined(separator: "<br>")
        HTMLContent = HTMLContent.replacingOccurrences(of: "#CATEGORIES#", with: cates)

        let jobPrinter = job_printer()
        jobPrinter.type = .image
        jobPrinter.html = HTMLContent
        jobPrinter.time = baseClass.getTimeINMS()
        jobPrinter.row_type = .test

        
        printer.addToQueue(job: jobPrinter,index:0)

        
        SharedManager.shared.printers_pson_print[0] = printer
        SharedManager.shared.epson_queue.run()
        
    }
    
    
    @IBAction func btnDiscoveryPrinter(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "printer", bundle: nil)
        
        let vc = storyboard.instantiateViewController(
            withIdentifier: "DiscoveryViewController") as! DiscoveryViewController
        
        vc.hideBack = false
        vc.hideSkip = true
        
        let nav = UINavigationController(rootViewController: vc);
        nav.isNavigationBarHidden = true
        nav.modalPresentationStyle = .fullScreen
        
        parent_vc!.present(nav, animated: true, completion: nil)
    }
    
    
         @IBAction func btnShowAllPrinters(_ sender: Any) {
            
            let storyboard = UIStoryboard(name: "printer", bundle: nil)
            
            let vc = storyboard.instantiateViewController(
                withIdentifier: "network_printer") as! network_printer
            
       
            
            
            let nav = UINavigationController(rootViewController: vc);
            nav.isNavigationBarHidden = true
            nav.modalPresentationStyle = .fullScreen
            
            parent_vc!.present(nav, animated: true, completion: nil)
               
//               let list = options_listVC(nibName: "options_popup", bundle: nil)
//                  list.modalPresentationStyle = .overFullScreen
//                   list.modalTransitionStyle = .crossDissolve
//
//
//
//           let arr: [[String:Any]] =  restaurant_printer_class.getAll()
//               for item in arr
//               {
//                   var dic = item
//                   let printer = restaurant_printer_class(fromDictionary: item)
//
//
//                   dic[options_listVC.title_prefex] = printer.display_name + " - " + printer.printer_ip
//
//                   list.list_items.append(dic)
//
//               }
//
//
//
//               list.didSelect = { [weak self] data in
//
//               }
//
//
//               list.clear = {
//
//
//                           }
//
//               options_listVC.show_option(list:list,viewController: parent_vc!, sender: sender   )
//
////               parent_vc?.present(list, animated: true, completion: nil)
//
//            list.title_option.text = "Network printers"
////                 list.btn_clear.isHidden = true
//
           }
           
    
    
}
