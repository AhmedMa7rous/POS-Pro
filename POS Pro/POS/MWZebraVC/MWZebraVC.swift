//
//  MWZebraVC.swift
//  pos
//
//  Created by M-Wageh on 04/10/2024.
//  Copyright © 2024 khaled. All rights reserved.
//

import UIKit

class MWZebraVC: UIViewController {
    
    @IBOutlet weak var activeInd: UIActivityIndicatorView!
    @IBOutlet weak var infoLbl: UILabel!
    
    @IBOutlet weak var addRemoveBtn: UIButton!
    var selectScanner:ScannerInfo?
    var zebraBarCodeHelper:ZebraBarCodeHelper?

    override func viewDidLoad() {
        super.viewDidLoad()
        zebraBarCodeHelper = ZebraBarcodeDeviceInteractor.shared.zebraBarCodeHelper

        addRemoveBtn.layer.cornerRadius = 12
        handleTitles()
        
    }
            func handleTitles(){
                let cashInfoName = CashZebra.shared.getZebraDeviceName()
                let cashStatusConneted = CashZebra.shared.getZebraDeviceStatue()
                if !cashStatusConneted.connect {
                    addRemoveBtn.tag = 0
                    addRemoveBtn.setTitle("Connect".arabic("إتصال"), for: .normal)
                    addRemoveBtn.backgroundColor =  #colorLiteral(red: 0.3058823529, green: 0.2235294118, blue: 0.6862745098, alpha: 1)
                    if cashStatusConneted.stop{
                        self.infoLbl.text = "Before Connect again \n 1- Ensure that scanner remove from bluetooth setting\n 2-Scan two barcodes following \n 3-Close the app".arabic("قبل الاتصال مرة أخرى\n 1- تأكد من إزالة الماسح الضوئي من إعداد البلوتوث\n 2-قم بمسح اثنين من الرموز الشريطية التالية \n 3-أغلق التطبيق")
                    }


                }else{
                    addRemoveBtn.tag = 1
                    addRemoveBtn.setTitle("Stop".arabic("إيقاف"), for: .normal)
                    addRemoveBtn.backgroundColor =  #colorLiteral(red: 1, green: 0.358289957, blue: 0, alpha: 1)
                    self.infoLbl.text = cashInfoName.1
                }
                activeInd.stopAnimating()
        }


    @IBAction func tapOnAddRemoveBtn(_ sender: UIButton) {
//        activeInd.isHidden = false
//        activeInd.startAnimating()

        
        if sender.tag == 0 {
            //Add
            self.show_BLE_SSD_view()
           
        }else{
            if sender.tag == 1 {
                //Remove
               

                self.deletDevice()
                
            }
        }
        
    }
    static func createModule() -> MWZebraVC {
         let vc:MWZebraVC = MWZebraVC()
       
         return vc
     }
    func show_BLE_SSD_view() {
        
        let vc = SelectZebraScannerBleVC.createModule(self.addRemoveBtn, selectDataList: self.selectScanner)
        self.present(vc, animated: true, completion: nil)
        vc.completionBlock = { [weak self] scanInfo in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.estimateConnection(scanInfo)
            }
        }
    }
    func estimateConnection(_ scanInfo:ScannerInfo){
        self.saveDevice(scanInfo)

        let scannerID = scanInfo.scannerId
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(400), execute: {
            self.zebraBarCodeHelper?.sdkApiInstance?.sbtEstablishCommunicationSession(scannerID)
        })
//        sdkApiInstance?.sbtEstablishCommunicationSession(scanInfo.scannerId)
        /*
        let result: SBT_RESULT = self.zebraBarCodeHelper?.sdkApiInstance?.sbtEstablishCommunicationSession(scannerID) ?? SBT_RESULT_FAILURE
        if result == SBT_RESULT_FAILURE {
            self.deletDevice()
           // stateZebra = .Error("Try again, Error Connection")
                loadingClass.hide(view:self.view)
                SharedManager.shared.initalBannerNotification(title: "Connection!".arabic("الاتصال"), message: "Try again, Error Connection", success: false, icon_name: "icon_error")
                SharedManager.shared.banner?.dismissesOnTap = true
                                SharedManager.shared.banner?.show(duration: 3.0)
        }else{
            self.saveDevice(scanInfo)
        }
*/
    }
    func saveDevice(_ scanInfo:ScannerInfo){
        self.zebraBarCodeHelper?.saveDevice(for:scanInfo)

        let setting = SharedManager.shared.appSetting()
        setting.enable_zebra_scanner_barcode = true
        setting.save()
        self.handleTitles()

    }
    func deletDevice(){
        let setting = SharedManager.shared.appSetting()
        setting.enable_zebra_scanner_barcode = false
        self.zebraBarCodeHelper?.cashDevice(deviceName:"",deviceID:"",stop:"1")
        self.zebraBarCodeHelper?.deinitShared()
        setting.save()
        handleTitles()
    }
}
