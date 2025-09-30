//
//  uploadAWS3.swift
//  pos
//
//  Created by Khaled on 3/27/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import UIKit

class uploadAWS3: NSObject {
     
    
   static func saveLastUploadUrl(finalPath:String)
    {
        cash_data_class.set(key: "uploadAWS3_url", value: finalPath)
//        myuserdefaults.setitems("url", setValue: finalPath, prefix: "uploadAWS3")

    }
    
    static func getLastUploadUrl() -> String
    {
        return cash_data_class.get(key: "uploadAWS3_url") ?? ""
//    return myuserdefaults.getitem("url", prefix: "uploadAWS3") as? String ?? ""
    }
    
    
    static func getLastUploadUrlLastPath() -> String
    {
        let lastPath = getLastUploadUrl()
        if !lastPath.isEmpty
        {
            let split = lastPath.components(separatedBy: "/")
            return split.last ?? ""

        }
        
        
        return   ""
     }
    
    
    func uploadOtherFile(url:URL,prfix:String)
      {
         
            AWSS3Manager.shared.uploadOtherFile(fileUrl: url,fileName:getFileName(prfix: prfix), conentType: "Zip", progress: { (progress) in
                
        
                NotificationCenter.default.post(name: Notification.Name("upload_progress"), object: progress)

    //            self.delegate?.upload_progress(progress: progress)
                
            }) { (uploadedFileUrl, error) in
               let finalPath = uploadedFileUrl as? String
                            
                if finalPath != nil {
                    if (prfix.lowercased().contains("all")){
                       // SharedManager.shared.clearLogsDB()
                    }
                    uploadAWS3.saveLastUploadUrl(finalPath: finalPath!)
                    
                    cash_data_class.set(key: "need_to_upload_db", value: "0")
                    MWQueue.shared.firebaseQueue.async {
                    FireBaseService.defualt.updateforceUploadDB()
                    }
                    NotificationCenter.default.post(name: Notification.Name("upload_success"), object: finalPath)

                }
                else
                {
                     
                    NotificationCenter.default.post(name: Notification.Name("upload_failure"), object: error)
                }
 

            }
        }
    
    
    func getFileName(prfix:String) -> String
      {
          let pos = SharedManager.shared.posConfig()
        let time_now = Date().toString(dateFormat: "yyyy-MM-dd_hh:mm:ss_a", UTC: true) //ClassDate.getNow("yyyy-MM-dd_hh:mm:ss_a")
          var domain = api.getDomain().replacingOccurrences(of: "https://", with: "")
            domain = domain.replacingOccurrences(of: "http://", with: "")
           domain = domain.replacingOccurrences(of: "/", with: "_")
          var posName = !(pos.name?.isEmpty ?? true) ?  (pos.name ?? "") : "PinScreen"
              posName = posName + "_" + "\(pos.id)"
          
//        let url = domain.lowercased() + "/" +  String(format: "%@_%@_%@.zip", prfix  ,pos.name! , time_now)
        let url = domain.lowercased() + "/" +  posName  + "/"  +  String(format: "%@_%@.zip", prfix   , time_now)

          return url
      }
    
}

 
