import UIKit

protocol DiscoveryViewDelegate {
    func discoveryView(_ sendor:DiscoveryViewController, onSelectPrinterTarget target:String,printerName:String)
}
class PrinterInfolbl: UITableViewCell {
    
   
    @IBOutlet weak var OutPrinterInfolbl: KLabel!

}
class DiscoveryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, Epos2DiscoveryDelegate {
  
    private let refreshControl = UIRefreshControl()
    @IBOutlet var loading: UIActivityIndicatorView!
    
    @IBOutlet var lblCurrentPrinter: KLabel!
    @IBOutlet weak var printerView: UITableView!
 
    fileprivate var printerList: [Epos2DeviceInfo?] = []
    fileprivate var filterOption: Epos2FilterOption = Epos2FilterOption()
    
    @IBOutlet var btnBack: UIButton!
    public var hideBack :Bool = true
    public var hideSkip :Bool = false

    @IBOutlet var btnSkip: UIButton!
    
      var parent_vc: UIViewController?
    var delegate: DiscoveryViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
 
        self.btnBack?.isHidden = hideBack
        self.btnSkip?.isHidden = hideSkip
        
//        self.navigationController?.isNavigationBarHidden = false

        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPrinter))
 
        navigationItem.rightBarButtonItems = [add]
        
        

        
        printerView.delegate = self
        printerView.dataSource = self
        
        if #available(iOS 10.0, *) {
            printerView.refreshControl = refreshControl
        } else {
            printerView.addSubview(refreshControl)
        }
        refreshControl.tintColor = UIColor.white
        refreshControl.addTarget(self, action: #selector(restartDiscovery(_:)), for: .valueChanged)
 
        
     loading.startAnimating()
        
                filterOption.deviceType = EPOS2_TYPE_PRINTER.rawValue
        filterOption.deviceType = EPOS2_TYPE_ALL.rawValue
        filterOption.deviceModel = EPOS2_MODEL_ALL.rawValue
//        filterOption.portType = EPOS2_PORTTYPE_ALL.rawValue
//        filterOption.broadcast = "255.255.255.0"
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startPrinterDiscovery()

    }
    

    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnSkipe(_ sender: Any) {
        
//        self.btnBack(AnyClass.self)
       
         
        
        settingClass.setIsSetPrinter()

        AppDelegate.shared.loadLoading()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
   

     
    }
    func startPrinterDiscovery(){
       
        let result = Epos2Discovery.start(filterOption, delegate: self)
        if result != EPOS2_SUCCESS.rawValue {
            //ShowMsg showErrorEpos(result, method: "start")
            printer_message_class.show("Can't run discovery ", vc: self)
        }else{
            loading.stopAnimating()
        }
 
 
//        printerList.append(nil)
        printerView.reloadData()
 
 
  
 
 let setting =  settingClass.getSetting()
 
 lblCurrentPrinter.text = setting.name! + "\n" +  setting.ip
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        

        
        while Epos2Discovery.stop() == EPOS2_ERR_PROCESSING.rawValue {
            // retry stop function
        }
        
        printerList.removeAll()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rowNumber: Int = 0
        if section == 0 {
            rowNumber = printerList.count
        }
        else {
            rowNumber = 1
        }
        return rowNumber
    }
      func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "BookCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as! PrinterInfolbl
        
//        if cell == nil
//        {
//            cell = PrinterInfolbl(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: identifier)
//        }
       /* if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: identifier) as? PrinterInfolbl
        }*/
        
        if indexPath.section == 0 {
            if indexPath.row >= 0 && indexPath.row < printerList.count {
                
                   
                       
                       if printerList[indexPath.row] == nil
                       {
                      
                        
                        cell.OutPrinterInfolbl?.text = "192.168.1.100"

                       }
                else
                       {
                        
                        let deviceName = printerList[indexPath.row]?.deviceName  ?? ""
                        let target = printerList[indexPath.row]?.target ?? ""
                        
                        let tmp:String =  deviceName + " - " + target
                               
                               cell.OutPrinterInfolbl?.text = tmp
                }
                
       
//                cell.OutSelectPrinter?.tag = indexPath.row
//                 cell.OutSelectPrinter?.isHidden = false
                //printerList[indexPath.row].target
              //  cell!.detailTextLabel?.text = printerList[indexPath.row].target
            }
        }
        else {
             cell.OutPrinterInfolbl?.text = "other..."
//            cell.OutSelectPrinter?.isHidden = true
           // cell!.detailTextLabel?.text = ""
        }
        
        return cell
    }
    @IBAction func SelectPrinterClicked(_ sender: Any) {
        let currButton = sender as! UIButton
        let currId = currButton.tag
        if delegate != nil {
            delegate!.discoveryView(self, onSelectPrinterTarget: printerList[currId]?.target ?? "" ,printerName: printerList[currId]?.deviceName ?? "")
            delegate = nil
            navigationController?.popViewController (animated: true)
        }
        /// 
        //let currUmmaBook:TafsieerBook = self.BooksList [currId]
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var printer_name:String
        var printer_ip:String
        
        if printerList[indexPath.row] == nil
        {
            printer_name = "test"
               printer_ip = "192.168.1.100"
        }
        else
        {
            printer_name = printerList[indexPath.row]?.deviceName ?? ""
             printer_ip = printerList[indexPath.row]?.target ?? ""
        }
   

        if hideSkip == true
        {
            let storyboard = UIStoryboard(name: "printer", bundle: nil)

            let vc = storyboard.instantiateViewController(withIdentifier: "addPrinter") as! addPrinter
            vc.completionSave = { (result) in
                if result {
                    self.btnBack(self.btnBack ?? UIButton())
                }
            }
            if hideBack == true
            {
                vc.inStartApp = true
            }
            
            
            vc.printer_name = printer_name
            vc.printer_ip = printer_ip
            
            
            navigationController?.pushViewController(vc, animated: true)
        }
        else
        {
            
            settingClass.savePrinter(name: printer_name, ip: printer_ip)
//             AppDelegate.shared.setupDefaultPrinter()

            self.btnBack(AnyClass.self)
 
        }


 

    }
    @objc func connectDevice() {
        Epos2Discovery.stop()
        printerList.removeAll()
        
        let btConnection = Epos2BluetoothConnection()
        let BDAddress = NSMutableString()
        let result = btConnection?.connectDevice(BDAddress)
        if result == EPOS2_SUCCESS.rawValue {
         /*   delegate?.discoveryView(self, onSelectPrinterTarget: BDAddress as String, printerName: <#String#>)
            delegate = nil
            self.navigationController?.popToRootViewController(animated: true)*/
        }
        else {
            Epos2Discovery.start(filterOption, delegate:self)
            printerView.reloadData()
        }
    }
    @IBAction func restartDiscovery(_ sender: AnyObject) {
        var result = EPOS2_SUCCESS.rawValue;
        
        while true {
            result = Epos2Discovery.stop()
            
            if result != EPOS2_ERR_PROCESSING.rawValue {
                if (result == EPOS2_SUCCESS.rawValue) {
                    break;
                }
                else {
//                    printer_message_class.showErrorEpos(result, method:"stop")
                    let msg =   NSLocalizedString(printer_message_class.getEposErrorText(result),comment:"")
                    printer_message_class.show(msg, false)
                    return;
                }
            }
        }
        
        printerList.removeAll()
        printerView.reloadData()
      
        result = Epos2Discovery.start(filterOption, delegate:self)
        if result != EPOS2_SUCCESS.rawValue {
//            printer_message_class.showErrorEpos(result, method:"start")
            let msg =   NSLocalizedString(printer_message_class.getEposErrorText(result),comment:"")
            printer_message_class.show(msg, false)
        }
        
        
    }
    func onDiscovery(_ deviceInfo: Epos2DeviceInfo!) {
        printerList.append(deviceInfo)
        printerView.reloadData()
        
        refreshControl.endRefreshing()
        loading.stopAnimating()
    }
    
 
    
    @objc func addPrinter() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "addPrinter") as! addPrinter
     
      
        navigationController?.pushViewController(vc, animated: true)
    }
    
   
    
    
}
