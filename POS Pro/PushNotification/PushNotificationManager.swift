//
//  PushNotificationManager.swift
//  pos
//
//  Created by M-Wageh on 13/12/2021.
//  Copyright © 2021 khaled. All rights reserved.
//

import Foundation
import FirebaseCore
//import FirebaseInstanceID
import UserNotifications
import Firebase
import FirebaseAuth
import FirebaseMessaging

enum NOTIFICATION_TYPES:String{
    case NONE
    case uploadDataBase = "upload_dataBase"
    case needToSync = "need_to_sync"
}

extension AppDelegate : MessagingDelegate,UNUserNotificationCenterDelegate{
    func registerUnLocalNotification(_ application:UIApplication){
        Messaging.messaging().delegate = self
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        application.registerForRemoteNotifications()
       
    }
    func handleFor(_ type:NOTIFICATION_TYPES){
        switch type {
        case .uploadDataBase:
            let pos = SharedManager.shared.posConfig()
            if pos.name != "" && pos.id != 0 {
                AppDelegate.shared.auto_export.upload_all()
            }
        case .needToSync:
            cash_data_class.set(key: "need_to_sync", value: "1")
            NotificationCenter.default.post(name: Notification.Name("need_to_sync"), object: nil)
        default:
            return
        }
    }
    
    func updateFirestorePushTokenIfNeeded() {
        if let token = Messaging.messaging().fcmToken {
            cash_data_class.set(key: "fcmToken", value: token)
            hitUpdateFcmTokenAPI()

        }
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        updateFirestorePushTokenIfNeeded()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
           if let value = userInfo["type"] as? String {
                handleFor(NOTIFICATION_TYPES.init(rawValue: value) ?? NOTIFICATION_TYPES.NONE)
           }
           completionHandler(.newData)
        
    }
    
    @objc func pushVC(userInfo:NSDictionary) {
        guard (userInfo["action"] as? String) != nil else{return}
    }
    
   
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        if AppDelegate.shared.enable_debug_mode_code() == true
        {
           // Auth.auth().setAPNSToken(deviceToken, type: .prod)

        }else{
           // Auth.auth().setAPNSToken(deviceToken, type: .prod)

        }
        Messaging.messaging().apnsToken = deviceToken
        Messaging.messaging().token { token, error in
            if let error = error {
               SharedManager.shared.printLog("Error fetching remote Messaging ID: \(error)")
            } else if let token = token {
               SharedManager.shared.printLog("Remote Messaging ID token: \(token)")
                cash_data_class.set(key: "fcmToken", value: token)
                self.hitUpdateFcmTokenAPI()
            }
        }

    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        SharedManager.shared.printLog(error)
    }
    
    //MARK:- call update FCM API
     func hitUpdateFcmTokenAPI(){
        let pos = SharedManager.shared.posConfig()
        if pos.name != "" && pos.id != 0 {
        let currentFcmToken =  pos.fb_token
         let fcmToken =  cash_data_class.get(key:  "fcmToken") ?? ""
            if (fcmToken.isEmpty){
                return
            }
       if fcmToken == currentFcmToken {
           return
       }
            if AppDelegate.shared.enable_debug_mode_code() == true
            {
                return
            }
        api().writeFcmAPI(fcmToken,posId: pos.id) { (results) in
            if results.success
            {
                pos.fb_token = fcmToken
                pos.save()
                return
            }else{
                
            }
        };
        }
    }
  
    
}
extension api {
    func writeFcmAPI(_ fcmToken:String, posId:Int ,completion: @escaping (_ result: api_Results) -> Void)  {
        guard let url = URL(string:"\(domain)/web/dataset/call_kw") else { return }
        let param:[String:Any] = [
            "jsonrpc": "2.0",
            "method": "call",
            "id": 1,
            "params": [
                "model": "pos.config",
                "method": "write",
                "args":[[posId], [
                    "fb_token": fcmToken
            ]],
                "kwargs": [
                    "context": get_context()

                ]
            ]
        ]
        let header:[String:String] = [:]
        callApi(url: url,keyForCash: getCashKey(key: "write_fcm_api") ,header: header, param: param, completion: completion);
    }
}
@available(iOS 10, *)
extension AppDelegate {
  // Receive displayed notifications for iOS 10 devices.
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions)
                                -> Void) {
    let userInfo = notification.request.content.userInfo

    // With swizzling disabled you must let Messaging know about the message, for Analytics
    // Messaging.messaging().appDidReceiveMessage(userInfo)

    // ...

    // Print full message.
      SharedManager.shared.printLog(userInfo)

    // Change this to your preferred presentation option
    completionHandler([[.alert, .sound]])
  }

  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
    let userInfo = response.notification.request.content.userInfo

    // ...

    // With swizzling disabled you must let Messaging know about the message, for Analytics
    // Messaging.messaging().appDidReceiveMessage(userInfo)

    // Print full message.
      SharedManager.shared.printLog(userInfo)

    completionHandler()
  }
}
