//
//  ForceUpdateAppVersion.swift
//  pos
//
//  Created by M-Wageh on 14/06/2021.
//  Copyright © 2021 khaled. All rights reserved.
//

import Foundation
import UIKit

enum CustomError: Error {
   case jsonReading
   case invalidIdentifires
   case invalidURL
   case invalidVersion
   case invalidAppName
}

class AppStoreUpdate: NSObject {
    
    static let shared = AppStoreUpdate()
    var isNeedToUpdate:Bool?
    var appURL:String?
    var message:String?
    var appStoreVersion:String?

    func initalAppStore(){
        checkVersionAppItunes { needUpdated, appURL, message, appStoreVersion in
            self.isNeedToUpdate = needUpdated
            self.appURL = appURL
            self.message = message
            self.appStoreVersion = appStoreVersion
        }
    }
    private func checkVersionAppItunes( completion: @escaping (_ needUpdated: Bool?, _ appURL:String?, _ message:String?,_ appStoreVersion:String?) -> Void) {
        
        do {
            //Get Bundle Identifire from Info.plist
            guard let bundleIdentifire = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String else {
               SharedManager.shared.printLog("No Bundle Info found.")
                throw CustomError.invalidIdentifires
            }
            
            // Build App Store URL
            guard let url = URL(string:"http://itunes.apple.com/lookup?bundleId=" + bundleIdentifire) else {
               SharedManager.shared.printLog("Isse with generating URL.")
                throw CustomError.invalidURL
            }
            
            let serviceTask = URLSession.shared.dataTask(with: url) { (responseData, response, error) in
                
                do {
                    // Check error
                    if let error = error { throw error }
                    //Parse response
                    guard let data = responseData else { throw CustomError.jsonReading }
                    let result = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    guard let resultDic =  result as? [String : Any] else {return}
                    let itunes = ItunesAppInfoItunes.init(fromDictionary: resultDic)
                    if let itunesResult = itunes.results.first {
                       SharedManager.shared.printLog("App Store Varsion: " + itunesResult.version)
                        //Get Bundle Version from Info.plist
                        guard let appShortVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
                           SharedManager.shared.printLog("No Short Version Info found.")
                            completion(false,nil,"No Short Version Info found.",itunesResult.version)
                            throw CustomError.invalidVersion
                        }
                        
                        if appShortVersion == itunesResult.version {
                            //App Store & Local App Have same Version.
                           SharedManager.shared.printLog("Same Version at both side")
                            completion(false,nil,"Same Version at both side",itunesResult.version)
                        } else {
                            //Show Update alert
                            let haseNewVersion = "has new version".arabic("نسخة جديدة")
                            let avaliableOnAppStore = "available on App Store.".arabic("متاح في متجر التطبيقات.")

                            var message = ""
                            //Get Bundle Version from Info.plist
                            if let appName = Bundle.main.infoDictionary?["CFBundleName"] as? String {
                                message = appName + " " + haseNewVersion + " (" + (itunesResult.version!) + ") " + avaliableOnAppStore
                            } else {
                                message = "Dgtera POS" + " " + haseNewVersion + " (" + (itunesResult.version!) + ") " + avaliableOnAppStore

                            }
                            completion(itunesResult.isPassedMoreThan3Day(),itunesResult.trackViewUrl,message,itunesResult.version)
                        }
                    }
                } catch {
                     SharedManager.shared.printLog(error)
                    completion(false,nil,error.localizedDescription,nil)
                }
            }
            serviceTask.resume()
        } catch {
             SharedManager.shared.printLog(error)
            completion(false,nil,error.localizedDescription,nil)

        }
    }

    func showAppStoreVersionUpdateAlert(isForceUpdate: Bool) {
        checkVersionAppItunes { needUpdated, appURL, message,appStoreVersion in
            self.isNeedToUpdate = needUpdated
            self.appURL = appURL
            self.message = message
            self.appStoreVersion = appStoreVersion

            if needUpdated == false {
                return
            }
            //Show Alert on main thread
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4), execute: {
                self.showUpdateAlert(message: message ?? "", appStoreURL: self.appURL ?? "", isForceUpdate: isForceUpdate)
            })
        }
    }
    
    func showUpdateAlert(message : String, appStoreURL: String, isForceUpdate: Bool) {
        let newVersion = "New Version".arabic("نسخة جديدة")
        let later = "Later".arabic("ليس الان")
        let update = "Upadate".arabic("تحديث")
        
        let controller = UIAlertController(title: newVersion, message: message, preferredStyle: .alert)
        
        //Optional Button
        if !isForceUpdate {
            controller.addAction(UIAlertAction(title:later, style: .cancel, handler: { (_) in }))
        }
        
        controller.addAction(UIAlertAction(title: update, style: .default, handler: { (_) in
            guard let url = URL(string: appStoreURL) else {
                return
            }
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
            
        }))
        
        let applicationDelegate = UIApplication.shared.delegate as? AppDelegate
        applicationDelegate?.window?.visibleViewController()?.present(controller, animated: true, completion: nil)
//        applicationDelegate?.window?.rootViewController?.present(controller, animated: true)
        
    }
    func openAppStore(){
        guard let url = URL(string: self.appURL ?? "") else {
            return
        }
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
}
