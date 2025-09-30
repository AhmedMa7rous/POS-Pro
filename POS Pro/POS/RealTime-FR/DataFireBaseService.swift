//
//  DataFireBaseService.swift
//  pos
//
//  Created by M-Wageh on 29/03/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation

import Foundation
import Firebase
import CodableFirebase
import FirebaseDatabase

enum ParentChildFireBaseTypes:String {
    case presence = "presence"
    case info = "info"
    case eInvoice = "e_invoice"
    case commands = "commands"
    case settingsApp = "settings_app"
    case tcp = "TCP"

}
enum ChildObserverFBTypes:String {
    case commands = "commands"
    case settingsApp = "settings_app"
    case forceSync = "commands/force_sync"
    case forceUploadDB = "commands/force_Upload_db"
    case forceLongPolling = "commands/force_long_polling"
    case forceLicense = "commands/force_license"

    case forceQueryExecute = "commands/force_query_execute"
    case forceMaintanceExecute = "commands/force_maintance_execute"
    case license = "commands/license"


}
class FireBaseService {
    let ref:DatabaseReference!
    private var companyID:String?{
        get{
            return  SharedManager.shared.pathFireBase()
        }
    }
    private init() {
        ref =  Database.database().reference()
    }
    static let defualt  = FireBaseService()
    //MARK:- observise Object
    func observeObject<T:Codable>(childObserver:ChildObserverFBTypes ,
                                  completion: @escaping(_ data: T?, _ error: Error?) -> Void){
        guard let companyID = companyID else {return}
        let pathReference = ref.child(companyID).child(childObserver.rawValue)
        pathReference.observe( .value, with: { (dataSnapshot) in
           SharedManager.shared.printLog("full pathReference\(pathReference)")
            if dataSnapshot.value == nil {
                return completion(nil , nil)
            }
            guard let value = dataSnapshot.value as? NSDictionary else { return completion(nil , nil) }
            do {
                let data = try FirebaseDecoder().decode(T.self, from: value)
                completion(data,nil)
            } catch {
                SharedManager.shared.printLog(error)
                completion(nil , error)
                return
            }
        }) { (error) in
            SharedManager.shared.printLog(error)
            completion(nil , error)
            return
        }
    }
    //MARK:- observise Array
    func observeArray<T:Codable>(childObserver:ChildObserverFBTypes ,
                                  completion: @escaping(_ data: [T]?, _ error: Error?) -> Void){
        guard let companyID = companyID else {return}
        let pathReference = ref.child(companyID).child(childObserver.rawValue)
        pathReference.observe( .value, with: { (dataSnapshot) in
           SharedManager.shared.printLog("full pathReference\(pathReference)")
            if dataSnapshot.value == nil {
                return completion(nil , nil)
            }
            guard let dicData = dataSnapshot.value as? NSDictionary else { return completion(nil , nil) }
            do {
                var dataArray:[T] = []
                for (_,value) in dicData {
                    let data = try FirebaseDecoder().decode(T.self, from: value)
                    dataArray.append(data)
                }
                completion(dataArray,nil)
            } catch {
                SharedManager.shared.printLog(error)
                completion(nil , error)
                return
            }
        }) { (error) in
            SharedManager.shared.printLog(error)
            completion(nil , error)
            return
        }
    }
    //MARK:- Update force_long_polling
   func updateForceLicense(){
       if AppDelegate.shared.disable_firebase_database(){
           return
       }
       guard let companyID = companyID else {return}
       var commandModel = FRCommandModel()
       commandModel.value = false
       let pathReference = ref.child(getValidNameNode(companyID)).child(ChildObserverFBTypes.forceLicense.rawValue)
//        pathReference.getData { error, snapshot in
//            if let dic = snapshot.value as? NSDictionary, let value = dic["value"] as? Bool , value != false{
//                        pathReference.updateChildValues(try! FirestoreEncoder().encode(commandModel),withCompletionBlock: { (error, databaseReference) in
//                            if error != nil{
//                                SharedManager.shared.printLog(error.debugDescription)
//                                return
//                            }
//                        })
//            }
//
//
//        }
       pathReference.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
           if var command = currentData.value as? [String: AnyObject] {
             var value = command["value"] as? Bool ?? false

               command["value"] = false as AnyObject

             // Set value and report transaction success
             currentData.value = command

             return TransactionResult.success(withValue: currentData)
           }
           return TransactionResult.success(withValue: currentData)
         }) { error, committed, snapshot in
           if let error = error {
               SharedManager.shared.printLog(error.localizedDescription)
           }
         }
      /*
       pathReference.updateChildValues(try! FirestoreEncoder().encode(commandModel),withCompletionBlock: { (error, databaseReference) in
           if error != nil{
               SharedManager.shared.printLog(error.debugDescription)
               return
           }
       })
       */

   }
     //MARK:- Update force_long_polling
    func updateForceLongPolling(){
        if AppDelegate.shared.disable_firebase_database(){
            return
        }
        guard let companyID = companyID else {return}
        var commandModel = FRCommandModel()
        commandModel.value = false
        let pathReference = ref.child(getValidNameNode(companyID)).child(ChildObserverFBTypes.forceLongPolling.rawValue)
//        pathReference.getData { error, snapshot in
//            if let dic = snapshot.value as? NSDictionary, let value = dic["value"] as? Bool , value != false{
//                        pathReference.updateChildValues(try! FirestoreEncoder().encode(commandModel),withCompletionBlock: { (error, databaseReference) in
//                            if error != nil{
//                                SharedManager.shared.printLog(error.debugDescription)
//                                return
//                            }
//                        })
//            }
//
//
//        }
        pathReference.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
            if var command = currentData.value as? [String: AnyObject] {
              var value = command["value"] as? Bool ?? false

                command["value"] = false as AnyObject

              // Set value and report transaction success
              currentData.value = command

              return TransactionResult.success(withValue: currentData)
            }
            return TransactionResult.success(withValue: currentData)
          }) { error, committed, snapshot in
            if let error = error {
                SharedManager.shared.printLog(error.localizedDescription)
            }
          }
       /*
        pathReference.updateChildValues(try! FirestoreEncoder().encode(commandModel),withCompletionBlock: { (error, databaseReference) in
            if error != nil{
                SharedManager.shared.printLog(error.debugDescription)
                return
            }
        })
        */

    }
    //MARK:- Update force_query_excute
    func updateForceQueryExecute(error:String){
        if AppDelegate.shared.disable_firebase_database(){
            return
        }
        guard let companyID = companyID else {return}
        var queryExecuteModel = FRQueryExecuteModel()
        queryExecuteModel.force_excute = false
        queryExecuteModel.error_excute = error
        if !error.isEmpty {
            queryExecuteModel.db_name = cash_data_class.get(key: "db_name_by_FR") ?? ""
            queryExecuteModel.query_excute = cash_data_class.get(key: "query_excute_by_FR") ?? ""
        }
        let pathReference = ref.child(getValidNameNode(companyID)).child(ChildObserverFBTypes.forceQueryExecute.rawValue)
        pathReference.updateChildValues(try! FirestoreEncoder().encode(queryExecuteModel),withCompletionBlock: { (error, databaseReference) in
            if error != nil{
                SharedManager.shared.printLog(error.debugDescription)
                return
            }
        })
    }
    //MARK: - Update force_maintance_excute
    func updateForceMaintanceExecute(error:String,lastDate:Int?){
        if AppDelegate.shared.disable_firebase_database(){
            return
        }
        guard let companyID = companyID else {return}
        var maintanceExecuteModel = FRMatainceExecuteModel()
        maintanceExecuteModel.force_excute_maintance = false
        maintanceExecuteModel.error_excute_maintance = error
        if let lastDate = lastDate {
            maintanceExecuteModel.last_time_date = lastDate

        }
        let pathReference = ref.child(getValidNameNode(companyID)).child(ChildObserverFBTypes.forceMaintanceExecute.rawValue)
        pathReference.updateChildValues(try! FirestoreEncoder().encode(maintanceExecuteModel),withCompletionBlock: { (error, databaseReference) in
            if let lastDate = lastDate {
                cash_data_class.set(key: "last_date_maintance", value: "\(lastDate)")
            }
            if error != nil{
                SharedManager.shared.printLog(error.debugDescription)
                return
            }
        })
    }
    //MARK:- Update license
    func updateLicense(_ licenseModel: FRLicenseModel){
        if AppDelegate.shared.disable_firebase_database(){
            return
        }
        guard let companyID = companyID else {return}
        let pathReference = ref.child(getValidNameNode(companyID)).child(ChildObserverFBTypes.license.rawValue)
        pathReference.updateChildValues(try! FirestoreEncoder().encode(licenseModel),withCompletionBlock: { (error, databaseReference) in
            if error != nil{
                SharedManager.shared.printLog(error.debugDescription)
                return
            }
        })
    }
    //MARK:- Update force_sync
    func updateForceSync(){
        if AppDelegate.shared.disable_firebase_database(){
            return
        }
        guard let companyID = companyID else {return}
        var commandModel = FRCommandModel()
        commandModel.value = false
        let pathReference = ref.child(getValidNameNode(companyID)).child(ChildObserverFBTypes.forceSync.rawValue)
        pathReference.updateChildValues(try! FirestoreEncoder().encode(commandModel),withCompletionBlock: { (error, databaseReference) in
            if error != nil{
                SharedManager.shared.printLog(error.debugDescription)
                return
            }
        })
    }
    //MARK:- Update force_Upload_db
    func updateforceUploadDB(){
        if AppDelegate.shared.disable_firebase_database(){
            return
        }
        guard let companyID = companyID else {return}
        var commandModel = FRCommandModel()
        commandModel.value = false
        let pathReference = ref.child(getValidNameNode(companyID)).child(ChildObserverFBTypes.forceUploadDB.rawValue)
        pathReference.updateChildValues(try! FirestoreEncoder().encode(commandModel),withCompletionBlock: { (error, databaseReference) in
            if error != nil{
                SharedManager.shared.printLog(error.debugDescription)
                return
            }
        })
        cash_data_class.set(key: "need_to_upload_db", value: "0")
    }
    //MARK:- Update presence offline-online 15-16 1 16 8 12
    private var isSentUpdatePresenceStatus:Bool = false
    func updatePresenceStatus(_ status:presenceStatus = .online){
        if isSentUpdatePresenceStatus {
            return
        }
        if AppDelegate.shared.disable_firebase_database(){
            return
        }
        guard let companyID = companyID else {return}
        isSentUpdatePresenceStatus = !isSentUpdatePresenceStatus
        var PresenceObjc = PresenceModel()
        PresenceObjc.status = status.rawValue
        PresenceObjc.name_pos = SharedManager.shared.getPosName()
        let pathReference = ref.child(getValidNameNode(companyID)).child(ParentChildFireBaseTypes.presence.rawValue)
        pathReference.setValue(try! FirestoreEncoder().encode(PresenceObjc),withCompletionBlock: { (error, databaseReference) in
            if error != nil{
                SharedManager.shared.printLog(error.debugDescription)
                return
            }
            self.isSentUpdatePresenceStatus = false
        })
        PresenceObjc.status = presenceStatus.offline.rawValue
        pathReference.onDisconnectSetValue(try! FirestoreEncoder().encode(PresenceObjc))
    }
    //MARK:- Update presence offline-online
    func updateInfoPOS(){
        if AppDelegate.shared.disable_firebase_database(){
            return
        }
        guard let companyID = companyID else {return}
        let infoPosModelObject = InfoPosModel()
        let pathReference = ref.child(getValidNameNode(companyID)).child(ParentChildFireBaseTypes.info.rawValue)
        pathReference.setValue(try! FirestoreEncoder().encode(infoPosModelObject),withCompletionBlock: { (error, databaseReference) in
            if error != nil{
                SharedManager.shared.printLog(error.debugDescription)
                return
            }
        })
    }
    //MARK:- Update presence offline-online
    func updateInfoTCP(_ source_update:String){
        if AppDelegate.shared.disable_firebase_database(){
            return
        }
        if !SharedManager.shared.mwIPnetwork {
            return
        }
        guard let companyID = companyID else {return}
        let infoTcpModelObject = InfoTCPModel(source_update)
        let pathReference = ref.child(getValidNameNode(companyID)).child(ParentChildFireBaseTypes.tcp.rawValue)
        pathReference.setValue(try! FirestoreEncoder().encode(infoTcpModelObject),withCompletionBlock: { (error, databaseReference) in
          if error != nil{
                SharedManager.shared.printLog(error.debugDescription)
                return
            }
        })
    }
    func setLastChainIndexFromFR(){
        if AppDelegate.shared.disable_firebase_database(){
            return
        }
        guard let companyID = companyID else {return}
        let pathReference = ref.child(getValidNameNode(companyID)).child(ParentChildFireBaseTypes.eInvoice.rawValue)
        pathReference.getData { error, snapshot in
            if let dic = snapshot?.value as? NSDictionary, let lastChainFr = dic["last_chain_index"] as? Int {
               let currentLastChain = Int(cash_data_class.get(key: "last_chain_index") ?? "-1") ?? -1
                if lastChainFr > currentLastChain {
                    cash_data_class.set(key: "last_chain_index",value:"\(lastChainFr)")
                }else{
                    pathReference.child("last_chain_index").setValue(currentLastChain)
                    
                }
            }
           
        }
    }
    /*
    func alterSupportInfoFR(){
        if AppDelegate.shared.disable_firebase_database(){
            return
        }
        guard let companyID = companyID else {return}
        let pathReference = ref.child(getValidNameNode(companyID)).child(ParentChildFireBaseTypes.info_support.rawValue)
        pathReference.getData { error, snapshot in
            if let dic_info = snapshot?.value as? NSDictionary {
               return
            }else{
                let infoSupport = InfoPosSuportModel()
                pathReference.setValue(try! FirestoreEncoder().encode(infoSupport),withCompletionBlock: { (error, databaseReference) in
                    if error != nil{
                        SharedManager.shared.printLog(error.debugDescription)
                        return
                    }
                })
            }
           
        }
    }
    */
    func getMaintanceInfoFR(pos_id:Int,hostName:String) {
        if AppDelegate.shared.disable_firebase_database(){
            return
        }
        guard let companyID = SharedManager.shared.pathFireBase(pos_id , hostName) else {
            return
        }
        let pathReference = ref.child(getValidNameNode(companyID)).child(ParentChildFireBaseTypes.commands.rawValue).child(ChildObserverFBTypes.forceMaintanceExecute.rawValue)
        pathReference.getData { error, snapshot in
            if let dic_info = snapshot?.value as? NSDictionary {
                do {
                let data = try JSONSerialization.data(withJSONObject: dic_info)
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                var obj: FRMatainceExecuteModel = try JSONDecoder().decode(FRMatainceExecuteModel.self, from: data )
                    cash_data_class.set(key: "last_date_maintance", value: "\(obj.last_time_date)" )

                } catch {
                }
            }
           
        }
    }
    /*
    func getSupportInfoFR(pos_id:Int,hostName:String, complete:((InfoPosSuportModel?)->Void)? = nil) {
        if AppDelegate.shared.disable_firebase_database(){
            complete?(nil)
            return
        }
        guard let companyID = SharedManager.shared.pathFireBase(pos_id , hostName) else {    
            complete?(nil)
            return
        }
        let pathReference = ref.child(getValidNameNode(companyID)).child(ParentChildFireBaseTypes.info_support.rawValue)
        pathReference.getData { error, snapshot in
            if let dic_info = snapshot?.value as? NSDictionary {
                do {
                let data = try JSONSerialization.data(withJSONObject: dic_info)
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                var obj: InfoPosSuportModel = try JSONDecoder().decode(InfoPosSuportModel.self, from: data )
                    if obj.support_pro_2 == nil {
                        obj = InfoPosSuportModel()
                        pathReference.setValue(try! FirestoreEncoder().encode(obj),withCompletionBlock: { (error, databaseReference) in
                            if error != nil{
                                SharedManager.shared.printLog(error.debugDescription)
                                return
                            }
                        })
                    }
                    cash_data_class.set(key: "support_pro_2",value: (obj.support_pro_2 ?? true) ? "1" : "0" )
                    complete?(obj)
                } catch {
                    complete?(nil)
                }
            }else{
                let infoSupport = InfoPosSuportModel()
                pathReference.setValue(try! FirestoreEncoder().encode(infoSupport),withCompletionBlock: { (error, databaseReference) in
                    if error != nil{
                        SharedManager.shared.printLog(error.debugDescription)
                        return
                    }
                    complete?(infoSupport)
                })
            }
           
        }
    }
    func setInfoSupport(pos_id:Int,hostName:String, complete:((InfoPosSuportModel?)->Void)? = nil){
        if AppDelegate.shared.disable_firebase_database(){
            complete?(nil)
            return
        }
        guard let companyID = SharedManager.shared.pathFireBase(pos_id , hostName) else {
            complete?(nil)
            return
        }
        let pathReference = ref.child(getValidNameNode(companyID)).child(ParentChildFireBaseTypes.info_support.rawValue)
        let infoSupport = InfoPosSuportModel()
        pathReference.setValue(try! FirestoreEncoder().encode(infoSupport),withCompletionBlock: { (error, databaseReference) in
            if error != nil{
                SharedManager.shared.printLog(error.debugDescription)
                return
            }
            complete?(infoSupport)
        })
    }
     */
    //MARK: - Update presence offline-online
    func updateEinvoiceFRModel(pih: String, order_uid: String){
        if AppDelegate.shared.disable_firebase_database(){
            return
        }
        if !(SharedManager.shared.phase2InvoiceOffline ?? false){
            return
        }
        cash_data_class.set(key: "e_invoice_pih", value: pih)
        cash_data_class.set(key: "e_order_uid", value: order_uid)
        guard let companyID = companyID else {return}
        let eInvoiceFRModel = EInvoiceFRModel(pih: pih, order_uid: order_uid)
        let pathReference = ref.child(getValidNameNode(companyID)).child(ParentChildFireBaseTypes.eInvoice.rawValue)
        
        pathReference.setValue(try! FirestoreEncoder().encode(eInvoiceFRModel),withCompletionBlock: { (error, databaseReference) in
            if error != nil{
                SharedManager.shared.printLog(error.debugDescription)
                return
            }
        })
    }
    //MARK:- Update SettingApp
    func updateSettingApp(){
        if AppDelegate.shared.enable_debug_mode_code(){
            //return
        }
        if AppDelegate.shared.disable_firebase_database(){
            return
        }
        let set_app_settings_in_firebase = cash_data_class.get(key:"set_app_settings_in_firebase") ?? ""
        if set_app_settings_in_firebase == "1" {
            return
        }
        let settingDic = settingClass.getSettingClass().toDictionary()
        for keySetting in SETTING_KEY.allCases {
//            if keySetting.rawValue == "clear_log_everyDays"{
            let value = "\(settingDic[keySetting.rawValue] ?? "")"
            self.setFRSettingApp(keySetting:keySetting.rawValue,valueSetting:value)
           // }
        }
        cash_data_class.set(key: "set_app_settings_in_firebase", value: "1")

    }
    func getFRSettingApp(complete: ( () -> ())? = nil){
//        if AppDelegate.shared.enable_debug_mode_code(){
//            return
//        }
        /**
         
         Firebase Database connection was forcefully killed by the server.  Will not attempt reconnect. Reason: The Firebase database 'rabeh-io' has reached its peak connections limit. If you are the Firebase owner, consider upgrading.
         */
        guard let companyID = companyID else {
            print(companyID)
            return
        }
        let pathReference = ref.child(getValidNameNode(companyID)).child(ParentChildFireBaseTypes.settingsApp.rawValue)
        pathReference.observeSingleEvent(of: .value) { dataSnapshot in
            SharedManager.shared.printLog("full pathReference\(pathReference)")
             if dataSnapshot.value == nil {
                 self.updateSettingApp()
                 complete?()
                 return
             }
             guard let dicData = dataSnapshot.value as? NSDictionary else {
                 complete?()
                 return  }
             do {
                 var dataArray:[FRSettingAppModel] = []
                 for (_,value) in dicData {
                     let data = try FirebaseDecoder().decode(FRSettingAppModel.self, from: value)
                     dataArray.append(data)
                 }
                 self.updateSetting(dataArray)
                 complete?()
             } catch {
                 SharedManager.shared.printLog(error)
                 complete?()
                 return
             }
        }
       // }
        
    }
    func setFRSettingApp(keySetting:String,valueSetting:String){
        if AppDelegate.shared.enable_debug_mode_code(){
            return
        }
        guard let companyID = companyID else {return}
        var settingAppModelObject = FRSettingAppModel()
        //if !valueSetting.isEmpty {
        settingAppModelObject.key = keySetting
        settingAppModelObject.value = valueSetting
        let pathReference = ref.child(getValidNameNode(companyID)).child(ParentChildFireBaseTypes.settingsApp.rawValue).child(keySetting)
        pathReference.setValue(try! FirestoreEncoder().encode(settingAppModelObject),withCompletionBlock: { (error, databaseReference) in
            if error != nil{
                SharedManager.shared.printLog(error.debugDescription)
                return
            }
        })
       // }
        
    }
    func setForChilde(companyID:String,childSnapshot:DataSnapshot,settingAppModelObject:FRSettingAppModel){
        let posID = childSnapshot.key
        SharedManager.shared.printLog("posID ==\(posID)")
        guard let keySetting = settingAppModelObject.key, let valueSetting = settingAppModelObject.value else { return  }
        let pathReference = self.ref.child(self.getValidNameNode(companyID)).child(posID).child(ParentChildFireBaseTypes.settingsApp.rawValue).child(keySetting)
        SharedManager.shared.printLog("pathReference ==\(pathReference.key)")
        
        
        pathReference.setValue(try! FirestoreEncoder().encode(settingAppModelObject),withCompletionBlock: { (error, databaseReference) in
            if error != nil{
                SharedManager.shared.printLog(error.debugDescription)
                return
            }
        })
    }
    func setFRSettingAppForAllDataBase(dataBase:String? = nil ,keySetting:String,valueSetting:String){
       
        guard let companyID = companyID else {return}
        var settingAppModelObject = FRSettingAppModel()
        //if !valueSetting.isEmpty {
        settingAppModelObject.key = keySetting
        settingAppModelObject.value = valueSetting
        if let dataBase = dataBase,!dataBase.isEmpty{
            let pathReferenceObserv = self.ref.child(self.getValidNameNode(dataBase))
            pathReferenceObserv.observeSingleEvent(of: .value) { child in
                for case let childSnapshot as DataSnapshot in child.children {
                    
                    var settingAppModelObject = FRSettingAppModel()
                    //if !valueSetting.isEmpty {
                    settingAppModelObject.key = keySetting
                    settingAppModelObject.value = valueSetting
                    
                    self.setForChilde(companyID:dataBase,childSnapshot:childSnapshot,settingAppModelObject:settingAppModelObject)
                    
                }
            }
        }else{
            ref.observeSingleEvent(of: .value) { snapshot in
                for case let child as DataSnapshot in snapshot.children {
                    //                SharedManager.shared.printLog("child= \(child)")
                    let companyID = child.key
                    SharedManager.shared.printLog("companyID ==\(companyID)")
                    
                    for case let childSnapshot as DataSnapshot in child.children {
                        //                    SharedManager.shared.printLog("childSnapshot= \(childSnapshot)")
                        var settingAppModelObject = FRSettingAppModel()
                        //if !valueSetting.isEmpty {
                        settingAppModelObject.key = keySetting
                        settingAppModelObject.value = valueSetting
                        
                        self.setForChilde(companyID:companyID,childSnapshot:childSnapshot,settingAppModelObject:settingAppModelObject)
                        
                        
                        
                    }
                    
                }
            }
        }
        /*
        ref.observeSingleEvent(of: .value) {[weak self] (snapshot)  in
            SharedManager.shared.printLog("snapshot= \(snapshot)")
            for child in snapshot.children {
                    SharedManager.shared.printLog("child= \(child)")
                    for childSnapshot in child.children {
                        SharedManager.shared.printLog("childSnapshot= \(childSnapshot)")

                    }
                    
                }
        }
        */
        /*
        let pathReference = ref.child(getValidNameNode(companyID)).child(ParentChildFireBaseTypes.settingsApp.rawValue).child(keySetting)
        pathReference.setValue(try! FirestoreEncoder().encode(settingAppModelObject),withCompletionBlock: { (error, databaseReference) in
            if error != nil{
                SharedManager.shared.printLog(error.debugDescription)
                return
            }
        })*/
       // }
        
    }
    func getValidNameNode(_ nameValid:String)->String{
        var name = nameValid
        for chara in [".", "#", "$", "[",  "]"]{
        if name.contains(chara){
            name = name.replacingOccurrences(of: chara, with: "_")
        }
            
        }
        return name
    }
    func removeObservalFR(_ child:ChildObserverFBTypes){
        guard let companyID = companyID else {return}
        let pathReference = ref.child(companyID).child(child.rawValue)
        pathReference.removeAllObservers()
    }
    func updateSetting(_ data: [FRSettingAppModel]){
        DispatchQueue.global(qos: .background).async {
            for settingApp in data {
                if let key = settingApp.key , let value = settingApp.castValue()  , !key.isEmpty{
                    SharedManager.shared.printLog("key ========= \(key) ====value======== \(value)")
                    if  key == "setting_name" {
                        cash_data_class.set(key: "setting_name", value: "\(value)")
                    }else
                    if key == "setting_ip" {
                        cash_data_class.set(key: "setting_ip", value: "\(value)")
                    }else{
                        var cash_setting = settingClass.getSettingClass().toDictionary()
                        cash_setting[key] = value
                        cash_data_class.set(key: "settingClass_setting", value: cash_setting.jsonString() ?? "")
                    }
                }
            }
            SharedManager.shared.setsAppSettings()
        }
    }
    
}
extension create_order{
    func removeObservalFR(){
        MWQueue.shared.firebaseQueue.async {
        FireBaseService.defualt.removeObservalFR(ChildObserverFBTypes.commands)
        FireBaseService.defualt.removeObservalFR(ChildObserverFBTypes.settingsApp)
        }
    }
    func addObserveFB(){
        addObserveFBIsNeedSync()
        addObserveFBSettingApp()
    }
    func removeNeedSyncObservalFR(){
        MWQueue.shared.firebaseQueue.async {

        FireBaseService.defualt.removeObservalFR(ChildObserverFBTypes.commands)
        }
    }
    func addObserveFBIsNeedSync(){
        FireBaseService.defualt.observeObject(childObserver:  ChildObserverFBTypes.commands) { [weak self] (data:FRCommandNodeModel?, error) in
            guard let self = self else {return}
            if let data = data, let force_license =  data.license {
                LicenseInteractor.shared.saveAppLicense(from:force_license)
            }
            if let data = data,
                let maintanceObject = data.force_maintance_execute,
                maintanceObject.force_excute_maintance == true {
                
                MaintenanceInteractor.shared.handleExcuteMaintanceFromFR(lastDate: Int(Date().timeIntervalSince1970 * 1000), complete: {
                    print("complete maintance")
                })
            }
            if let data = data, data.force_query_execute?.force_excute == true {
                let dbName = data.force_query_execute?.db_name ?? ""
                let queryExcute = data.force_query_execute?.query_excute ?? ""
                cash_data_class.set(key: "db_name_by_FR", value:dbName )
                cash_data_class.set(key: "query_excute_by_FR", value: queryExcute)
                MaintenanceInteractor.shared.handleExcuteQueryFromFR(db_name:dbName ,query_excute:queryExcute )
            }
            if let data = data, data.force_sync?.value == true {
                cash_data_class.set(key: "need_to_sync", value: "1")
                if self.isPassOneHourAfterLoaded_fail(){
                    NotificationCenter.default.post(name: Notification.Name("need_to_sync"), object: nil)
                }
            }
            if let data = data, data.force_long_polling?.value == true {
                if SharedManager.shared.appSetting().enable_force_longPolling_multisession {
                    MWQueue.shared.firebaseQueue.async {
//                    DispatchQueue.global(qos: .background).async {
                    FireBaseService.defualt.updateForceLongPolling()
                    }
                    AppDelegate.shared.run_poll_now()
                }
            }
            if let data = data, data.force_license?.value == true {
                if SharedManager.shared.mwIPnetwork {
                    MWQueue.shared.firebaseQueue.async {
//                    DispatchQueue.global(qos: .background).async {
                    FireBaseService.defualt.updateForceLicense()
                    }
                    DispatchQueue.main.async {
                        AppDelegate.shared.stopSockectIP()
                        AppDelegate.shared.startSockectIP()
                        MWMessageQueueRun.shared.setState(with: MWQueue_Status.FORE_GROUND)
                    }
                    
                }
            }
            if let data = data, let force_Upload_db =  data.force_Upload_db {
                if force_Upload_db.value ?? false{
                let need_to_upload_db = cash_data_class.get(key:"need_to_upload_db") ?? ""
                if need_to_upload_db.isEmpty || need_to_upload_db == "0" {
                    //upload database
                    MWQueue.shared.firebaseQueue.async {
                    AppDelegate.shared.auto_export.upload_all()
                    }
                }
                cash_data_class.set(key: "need_to_upload_db", value: "1")
                }
            }else{
                MWQueue.shared.firebaseQueue.async {
                FireBaseService.defualt.updateforceUploadDB()
                }
            }
        }
    }
    func isPassOneHourAfterLoaded_fail() -> Bool{
        guard let date = cash_data_class.get(key: "lastupdate" +  "_"  + "api_loaded_fail") else {return true}
        guard let date_int = Int64(date) else {return true}
        let date_interVal = TimeInterval(date_int)
        let time1 = Date(timeIntervalSince1970: date_interVal)
        let time2 = Date()
        let difference = Calendar.current.dateComponents([.hour], from: time1, to: time2)
        let duration = difference.hour ?? 0
        return duration >= 1
    }
    func addObserveFBSettingApp(){
        FireBaseService.defualt.observeArray(childObserver:  ChildObserverFBTypes.settingsApp) { (data:[FRSettingAppModel]?, error) in
            if let data = data,data.count > 0 {
                self.updateSetting(data)
            }
        }
    }
    func updateSetting(_ data: [FRSettingAppModel]){
        DispatchQueue.global(qos: .background).async {
            for settingApp in data {
                if let key = settingApp.key , let value = settingApp.castValue()  , !key.isEmpty{
                    SharedManager.shared.printLog("key ========= \(key) ====value======== \(value)")
                    if  key == "setting_name" {
                        cash_data_class.set(key: "setting_name", value: "\(value)")
                    }else
                    if key == "setting_ip" {
                        cash_data_class.set(key: "setting_ip", value: "\(value)")
                    }else{
                        var cash_setting = settingClass.getSettingClass().toDictionary()
                        cash_setting[key] = value
                        cash_data_class.set(key: "settingClass_setting", value: cash_setting.jsonString() ?? "")
                    }
                }
            }
            SharedManager.shared.setsAppSettings()
        }
    }
}
