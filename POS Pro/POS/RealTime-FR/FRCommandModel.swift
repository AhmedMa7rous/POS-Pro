//
//  FRCommandModel.swift
//  pos
//
//  Created by M-Wageh on 09/04/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation
struct FRMatainceExecuteModel: Codable, Hashable  {
    var receive_time: Int? = Int(Date().timeIntervalSince1970 * 1000)
    var force_excute_maintance: Bool? = false
    var error_excute_maintance: String = ""
    var last_time_date: Int? = 0

}
struct FRQueryExecuteModel: Codable, Hashable  {
    var receive_time: Int? = Int(Date().timeIntervalSince1970 * 1000)
    var force_excute: Bool? = false
    var db_name: String = ""
    var query_excute: String = ""
    var error_excute: String = ""

}
struct FRLicenseModel: Codable, Hashable  {
    var receive_time: Int? = Int(Date().timeIntervalSince1970 * 1000)
    var force_excute: Bool? = false
    var app_license: Int = 0
    var message_warring: String = ""
    var current_license: String = ""
}

struct FRCommandModel: Codable, Hashable  {
    var receive_time: Int? = Int(Date().timeIntervalSince1970 * 1000)
    var value: Bool? = false
}
struct FRSettingAppModel: Codable, Hashable  {
    var receive_time: Int = Int(Date().timeIntervalSince1970 * 1000)
    var key:String? = ""
    var value: String? = ""
    func castValue() -> Any?{
        if let boolValue =  boolValue(){
            return boolValue
        }
        if let intValue =  intValue(){
            return intValue
        }
        if let doubleValue =  doubleValue(){
            return doubleValue
        }
        return value
    }
    func doubleValue() -> Double? {
        return Double(value ?? "")
    }
    func intValue() -> Int? {
        return Int(value ?? "")
    }
    func boolValue() -> Bool? {
        let trueValues = ["true", "yes", "1"]
        let falseValues = ["false", "no", "0"]
        
        let lowerValue = (value ?? "").lowercased()
        
        if trueValues.contains(lowerValue) {
            return true
        } else if falseValues.contains(lowerValue) {
            return false
        } else {
            return nil
        }
    }
    
}
struct FRCommandNodeModel: Codable, Hashable  {
    var force_sync: FRCommandModel?
    var force_Upload_db:FRCommandModel?
    var force_long_polling:FRCommandModel?
    var force_query_execute:FRQueryExecuteModel?
    var force_maintance_execute:FRMatainceExecuteModel?
    var license:FRLicenseModel?
    var force_license: FRCommandModel?


}
enum APP_LICENSE_ACTION:Int{
    case SESSION,NEW_ORDER,HISTORY,REPORT
    func getAppLicenseLevel()->APP_LICENSE_LEVEL{
        switch self{
        case .SESSION:
            return .GRACE_PERIOD_1
        case .NEW_ORDER:
            return .GRACE_PERIOD_2
        case .HISTORY:
            return .LIMITED_ACCESS
        case .REPORT:
            return .LIMITED_ACCESS
        }
    }
}
enum APP_LICENSE_LEVEL:Int{
    /**
     1. grace period 1  (session message)
     2. grace period 2 ( order level)
     3. limited access  (only place order  )
     4. expired ( stop working)
     */
    case NONE = 0 ,GRACE_PERIOD_1,GRACE_PERIOD_2,LIMITED_ACCESS,EXPIRED
    func getDescription()->String{
        switch self{
        case .NONE:
            return "Full Access"
        case .GRACE_PERIOD_1:
            return "grace period 1  (session message)"
        case .GRACE_PERIOD_2:
            return "grace period 2 ( order level)"
        case .LIMITED_ACCESS:
            return "limited access  (only place order  )"
        case .EXPIRED:
            return "expired ( stop working)"
        }
    }
    static func compareTwo(){
        
    }
    
    
    
}
import BRYXBanner

class LicenseInteractor{
    static let shared:LicenseInteractor = LicenseInteractor()
    private init(){}
    private var licenseBanner: Banner?
    private var currentAppLicense:APP_LICENSE_LEVEL?
    private var currentWorking:Bool?
   private func initalLicenseBannerNotification()  {
        let textColor = #colorLiteral(red: 0.4941176471, green: 0.4549019608, blue: 0.2549019608, alpha: 1)
        let bkColor = UIColor(red: 246.0/255.0, green: 242.0/255.0, blue: 213.0/255.0, alpha:1.000)
       let imageWarning:UIImage? = #imageLiteral(resourceName: "MWwarning")
        var message_warring = cash_data_class.get(key: "message_warring_by_FR") ?? ""
       if message_warring.isEmpty {
           message_warring = "Thank you for using Dgtera, you should contact the administration".arabic("شكرا لاستخدامك ديجترا ، عليك التواصل مع الإدارة")
       }
       SharedManager.shared.banner?.dismiss()
       SharedManager.shared.banner = nil
       self.licenseBanner?.dismiss()
       self.licenseBanner = nil

        licenseBanner = Banner(title: "Attention!".arabic("تنبيه!"),
                           subtitle: message_warring,
                           image: imageWarning,
                           backgroundColor: bkColor )
        licenseBanner?.titleLabel.textColor = textColor
        licenseBanner?.detailLabel.textColor = textColor
    }
    func showNotFullAccessLicense(){
        if self.currentWorking ?? false {
            if self.currentAppLicense != .NONE{
                self.showNotification()
            }
        }
    }
   @discardableResult func licenseCanAccess(for actions:[APP_LICENSE_ACTION]) -> Bool{
       if self.currentWorking ?? false {
           if self.currentAppLicense != .NONE{
               let actionLicenseLevel = actions.map({$0.getAppLicenseLevel()})
               let isMatchLicense = actionLicenseLevel.filter({$0 == self.currentAppLicense }).count > 0
               if isMatchLicense{
                   if self.currentAppLicense == .GRACE_PERIOD_1 ||  self.currentAppLicense == .GRACE_PERIOD_2 {
                       self.showNotification()
                       return false
                   }
                   if self.currentAppLicense == .LIMITED_ACCESS || self.currentAppLicense == .EXPIRED {
                       return false
                   }
               }
               
           }
       }
        return true
    }
   @discardableResult func getLicenseModelFR() -> FRLicenseModel{
        let appLicense = Int(cash_data_class.get(key: "app_license_level_by_FR") ?? "0") ?? 0
        let app_license_excute_FR =  cash_data_class.get(key: "app_license_excute_FR") ?? "0"
        let message_warring = cash_data_class.get(key: "message_warring_by_FR") ?? ""
        self.currentWorking = app_license_excute_FR == "1"
        var licenseModel = FRLicenseModel()
        licenseModel.force_excute = app_license_excute_FR == "1"
        if let state_license = APP_LICENSE_LEVEL(rawValue: appLicense) {
            self.currentAppLicense = state_license
            licenseModel.current_license = state_license.getDescription()
        }
        licenseModel.app_license = appLicense
        licenseModel.message_warring = message_warring
        return licenseModel
    }
    func showNotification(){
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300), execute:  {
            self.initalLicenseBannerNotification()
            self.licenseBanner?.dismissesOnTap = true
            self.licenseBanner?.show(duration: nil)
    }
        )
    }
    func dismissNotification(){
        DispatchQueue.main.async {
            self.licenseBanner?.dismiss()
            self.licenseBanner = nil
        }
    }
    func updateAppLicense(){
        MWQueue.shared.firebaseQueue.async {
            FireBaseService.defualt.updateLicense(self.getLicenseModelFR())
        }
    }
    func saveAppLicense(from force_license: FRLicenseModel){
       let currentExculte = cash_data_class.get(key: "app_license_excute_FR" ) ?? "0"
        let currentLevel = Int( cash_data_class.get(key: "app_license_level_by_FR" ) ?? "0") ?? 0
        let currentMessage = cash_data_class.get(key: "message_warring_by_FR" ) ?? ""

        let comingExculte = (force_license.force_excute ?? false) ? "1" : "0"
        let appLicense = force_license.app_license
        let messageWarring = force_license.message_warring

        if currentExculte != comingExculte ||
            (messageWarring != currentMessage ) ||
            (appLicense != currentLevel){
            if force_license.force_excute == true {
                let appLicense = force_license.app_license
                let messageWarring = force_license.message_warring
                cash_data_class.set(key: "app_license_level_by_FR", value:"\(appLicense)" )
                cash_data_class.set(key: "message_warring_by_FR", value: messageWarring)
                cash_data_class.set(key: "app_license_excute_FR", value:"1" )
                self.updateAppLicense()
                self.showNotification()
            }else{
                let appLicense = force_license.app_license
                let messageWarring = force_license.message_warring
                cash_data_class.set(key: "app_license_level_by_FR", value:"\(appLicense)" )
                cash_data_class.set(key: "message_warring_by_FR", value: messageWarring)
                cash_data_class.set(key: "app_license_excute_FR", value:"0" )
                self.getLicenseModelFR()
                self.dismissNotification()
            }
        }
       
    }
    private func showLicenseAlert(with complete: (()->Void)?){
        var message_warring = cash_data_class.get(key: "message_warring_by_FR") ?? ""
       if message_warring.isEmpty {
           message_warring = "Thank you for using Dgtera, you should contact the administration".arabic("شكرا لاستخدامك ديجترا ، عليك التواصل مع الإدارة")
       }
        let alert = UIAlertController(title: "Attention!".arabic("تنبيه!"), message: message_warring,preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Continue...".arabic("استمرار..."), style: .default, handler: { (action) in
            complete?()
//            self.showNotification()
        }))
        AppDelegate.shared.window?.visibleViewController()?.present(alert, animated: true, completion: nil)
    }
    func handleShowAlertLicense(for actions:[APP_LICENSE_ACTION],complete: (()->Void)?){
        let canAccess = self.licenseCanAccess(for: actions)
        if canAccess {
            complete?()
        }else{
            self.showLicenseAlert(with:complete)
        }
    }
}
