//
//  CustomPermissionsVC.swift
//  pos
//
//  Created by M-Wageh on 17/05/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import UIKit

class CustomPermissionsVC: PAPermissionsViewController,PAPermissionsViewControllerDelegate {
    
    let bluetoothCheck = PABluetoothPermissionsCheck()
    let locationCheck = PALocationPermissionsCheck()
    let cameraCheck = PACameraPermissionsCheck()
    lazy var notificationsCheck : PAPermissionsCheck = {
        return PAUNNotificationPermissionsCheck()
    }()
    let localNetworkCheck = PALocalNetworkPermissionsCheck()
    var is_delegate:Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let permissions = [
            PAPermissionsItem.itemForType(.bluetooth, reason: "Dgtera POS requires permission for use bluetooth for scanbar code reader".arabic("يتطلب Dgtera POS إذنًا لاستخدام البلوتوث لقارئ الكود"))!,
            PAPermissionsItem.itemForType(.location, reason: "Dgtera requires user’s location for track the location of food trucks .".arabic("تتطلب Dgtera موقع المستخدم لتتبع موقع شاحنات الطعام."))!,
            PAPermissionsItem.itemForType(.notifications, reason: "Required to send you great updates".arabic("مطلوب لإرسال تحديثات رائعة إليك"))!,
            PAPermissionsItem.itemForType(.camera, reason: "Dgtera POS requires permission for use camera for scan barcode reader".arabic("يتطلب Dgtera POS إذنًا لاستخدام الكاميرا لمسح قارئ الباركود"))!,
            PAPermissionsItem.itemForType(.localNetwork, reason: "Dgtera POS needs to use your phone's data to discover devices nearby".arabic("يحتاج Dgtera POS  إلى استخدام بيانات هاتفك لاكتشاف الأجهزة القريبة"))!
        ]

        let handlers = [
            PAPermissionsType.bluetooth.rawValue: self.bluetoothCheck,
            PAPermissionsType.location.rawValue: self.locationCheck,
            PAPermissionsType.camera.rawValue: self.cameraCheck,
            PAPermissionsType.notifications.rawValue: self.notificationsCheck,
            PAPermissionsType.localNetwork.rawValue: self.localNetworkCheck
        ]

        self.setupData(permissions, handlers: handlers)
        
        self.tintColor = #colorLiteral(red: 0.3650116324, green: 0.1732142568, blue: 0.5585888624, alpha: 1)
        self.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        self.titleText = "Dgtera POS  Permissions".arabic("أذونات Dgtera POS")
        self.detailsText = "Allow Dgtera POS to access the following".arabic("السماح لـ Dgtera POS بالوصول إلى ما يلي")
        
        if is_delegate {
            repeatcheck()
            self.delegate = self
        }
    }
    func repeatcheck(){
        DispatchQueue.main.async {
            if self.bluetoothCheck.status != .checking && self.locationCheck.status != .checking &&
                self.notificationsCheck.status != .checking  && self.cameraCheck.status != .checking && self.localNetworkCheck.status != .checking {
                if self.checkIFAllPermissionIsDone() {
                    cash_data_class.set(key: "is_first_lanuch", value: "0")
                    AppDelegate.shared.loadLoading()
                }
            }else{
                self.repeatcheck()

            }
            
        }
       
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func checkIFAllPermissionIsDone() -> Bool{
//        return (bluetoothCheck.status == .enabled || bluetoothCheck.status == .unavailable) &&

         return (locationCheck.status == .enabled || locationCheck.status == .unavailable) &&
         (cameraCheck.status == .enabled || cameraCheck.status == .unavailable) &&
        (notificationsCheck.status == .enabled || notificationsCheck.status == .unavailable) &&
        (localNetworkCheck.status == .enabled || localNetworkCheck.status == .unavailable)
    }
    func permissionsViewControllerDidContinue(_ viewController: PAPermissionsViewController)
    {
       /*
        if bluetoothCheck.status != .enabled &&   bluetoothCheck.status != .unavailable{
            showFailToastMessage(message:"Need Bluetooth Access".arabic("بحاجة إلى الوصول إلى البلوتوث"))
         //   return
        }
        */
        if locationCheck.status != .enabled &&   locationCheck.status != .unavailable {
            showFailToastMessage(message:"Need Location Access".arabic("تحتاج إلى الوصول إلى الموقع"))
          //  return
            
        }
        if cameraCheck.status != .enabled &&   cameraCheck.status != .unavailable{
            showFailToastMessage(message:"Need Camera Access".arabic("بحاجة إلى الوصول إلى الكاميرا"))
          //  return
        }
        if notificationsCheck.status != .enabled && notificationsCheck.status != .unavailable {
            showFailToastMessage(message:"Need Notification Access".arabic("بحاجة إلى الوصول إلى الاشعارات"))
          //  return
            
        }
        if localNetworkCheck.status != .enabled && localNetworkCheck.status != .unavailable {
            showFailToastMessage(message:"Need Local Network Access".arabic("بحاجة إلى الوصول إلى الشبكة المحلية"))
          //  return
            
        }
        cash_data_class.set(key: "is_first_lanuch", value: "0")
        AppDelegate.shared.loadLoading()

    }
    func showFailToastMessage(message:String,isSucess:Bool = false,image:String = "icon_error"){
        DispatchQueue.main.async {
            SharedManager.shared.initalBannerNotification(title: "Fail!".arabic("فشل!") ,
                                                          message: message,
                                                          success: isSucess, icon_name: image)
            SharedManager.shared.banner?.dismissesOnTap = true
            SharedManager.shared.banner?.show(duration: 3.0)
        }
    }
}

class PremissionRouter {
    weak var viewController: CustomPermissionsVC?
    static func createModule(with delegate:Bool = true) -> CustomPermissionsVC {
        let vc:CustomPermissionsVC = CustomPermissionsVC()
        vc.is_delegate = delegate
        return vc
    }
}
