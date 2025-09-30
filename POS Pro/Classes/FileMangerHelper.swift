//
//  FileMangerHelper.swift
//  pos
//
//  Created by  Mahmoud Wageh on 4/21/21.
//  Copyright © 2021 khaled. All rights reserved.
//

import Foundation

enum APP_FOLDERS{
    case root
    case printer_erro
    case images
    
    static let all_app_folders = [APP_FOLDERS.printer_erro,
                                  APP_FOLDERS.images]
    
    func getLeafFolder() -> [LEAF_FOLDERS]{
        
        switch self {
        case .printer_erro:
            return [.none]
        case .images:
            return [LEAF_FOLDERS.product_product, .pos_category,.res_users,.res_company,.res_brand,.pos_config]
        case .root:
            return [.none]

        }
    }
}
enum LEAF_FOLDERS{
    case none
    case product_product
    case pos_category
    case res_users
    case res_company
    case res_brand
    case pos_config
}
class FileMangerHelper{
   
    static var shared = FileMangerHelper()
    private init(){
        do{
            directory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL
        } catch let error{
            SharedManager.shared.printLog(error.localizedDescription)
        }
        createFolders()
    }
    private let lastSessionReportName = "lastSessionReport.png"
    private var directory: NSURL?
    private var companyLogoBase64: String?
    func checkSizeDoucment(){
            if let pathLogPrinter = directory?.appendingPathComponent("printer_log.db"){
                let sizeInMb =  Double(pathLogPrinter.fileSize) / Double(pow(1024.0, 2.0))
                if sizeInMb > 100 {
                    SharedManager.shared.clearLogsDB()
                }
            }
    }
    func saveLastSessionImage(image: UIImage) -> Bool {
        guard let data = image.jpegData(compressionQuality: 0.5) ?? image.pngData() else {
            return false
        }
        guard let directory = self.directory else {
            return false
        }
        do {
            try data.write(to: directory.appendingPathComponent(lastSessionReportName)!)
            return true
        } catch {
            SharedManager.shared.printLog(error.localizedDescription)
            return false
        }
    }
    
    func getLastSessionImageReport() -> UIImage? {
        if let dir = self.directory {
            return UIImage(contentsOfFile: URL(fileURLWithPath: dir.absoluteString ?? "").appendingPathComponent("lastSessionReport.png").path)
        }
        return nil
    }
    func createFolders(){
        APP_FOLDERS.all_app_folders.forEach { folder in
            folder.getLeafFolder().forEach { leaf in
                createFolder(folder:folder,leaf: leaf)
            }
        }
    }
    func createFolder(folder:APP_FOLDERS = APP_FOLDERS.printer_erro, leaf:LEAF_FOLDERS = .none){
        guard var dataPath = directory?.appendingPathComponent("\(folder)")else{return}
        if leaf != LEAF_FOLDERS.none{
            dataPath = dataPath.appendingPathComponent("\(leaf)")
        }
        if !FileManager.default.fileExists(atPath: dataPath.path) {
            do {
                try FileManager.default.createDirectory(atPath: dataPath.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                SharedManager.shared.printLog(error.localizedDescription)
            }
        }
    }
    func fileExists(to folder:APP_FOLDERS,in leaf:LEAF_FOLDERS = .none,with name:String) -> Bool{
        guard var path = self.directory else {
            return false
        }
        if folder != .root {
            path = path.appendingPathComponent("\(folder)")! as NSURL
        }
        if leaf != .none {
            path = path.appendingPathComponent("\(leaf)")! as NSURL
        }
        guard let dataPath = path.appendingPathComponent(name) else{return false}
        return FileManager.default.fileExists(atPath: dataPath.path)

    }
    func saveFile(image: UIImage,to folderName:APP_FOLDERS = .root, in leaf:LEAF_FOLDERS = .none  , with name:String) -> Bool {
        if fileExists(to:folderName,with:name){
            return true
        }
        guard let data = image.jpegData(compressionQuality: 0.5) ?? image.pngData() else {
            return false
        }
        guard var path = self.directory else {
            return false
        }
        if folderName != .root {
            path = path.appendingPathComponent("\(folderName)")! as NSURL
        }
        if leaf != .none {
            path = path.appendingPathComponent("\(leaf)")! as NSURL
        }
        do {
            try data.write(to: path.appendingPathComponent(name)!)
            return true
        } catch {
            SharedManager.shared.printLog(error.localizedDescription)
            return false
        }
    }
    func getPathForFile(from folder:APP_FOLDERS,in leaf:LEAF_FOLDERS = .none, with name:String) -> String? {
        if let path = getPath(from:folder,in :leaf, with:name) {
            return path.path
        }
        return nil
    }
    func getFile(from folder:APP_FOLDERS,in leaf:LEAF_FOLDERS = .none, with name:String) -> UIImage? {
        if let path = getPath(from:folder,in :leaf, with:name) {
            return UIImage(contentsOfFile: path.path)
        }
        return nil
    }
    func removeFile(from folder:APP_FOLDERS,in leaf:LEAF_FOLDERS = .none,with name:String = ""){
        if let dir = self.directory {
            
            var path = URL(fileURLWithPath: dir.absoluteString ?? "").appendingPathComponent("\(folder)")
            if leaf != LEAF_FOLDERS.none{
                path = path.appendingPathComponent("\(leaf)")
            }
        if !name.isEmpty {
            path = path.appendingPathComponent(name)
        }
            
            
            do {
//                try FileManager.default.trashItem(at: path, resultingItemURL: nil)

                try FileManager.default.removeItem(atPath: path.path )
            } catch {
               SharedManager.shared.printLog("delet item image file\(error.localizedDescription)")
            }
        }

    }
    func clearTrash(){
        if let dir = self.directory{
            let path = URL(fileURLWithPath: dir.absoluteString ?? "").appendingPathComponent(".Trash")
            do {
                if FileManager.default.fileExists(atPath: path.path) {
                    try FileManager.default.removeItem(atPath: path.path )
                }
            } catch {
               SharedManager.shared.printLog("delet item image file\(error.localizedDescription)")
            }
        }

    }
    func saveBase64AsImage(_ base64String:String , in leaf:LEAF_FOLDERS,with name:String){
        DispatchQueue.global(qos: .userInitiated).async {
            let  logoData :UIImage? = UIImage.ConvertBase64StringToImage(imageBase64String:base64String )
            if let imageData = logoData {
                if !(self.saveFile(image: imageData,to:.images, in:leaf , with:name)){
                   SharedManager.shared.printLog("cann't save image AS files")
                }
            }
        }
    }
    func getPath(from folder:APP_FOLDERS,in leaf:LEAF_FOLDERS = .none, with name:String) -> URL?{
        if let dir = self.directory {
            var path =  URL(fileURLWithPath: dir.absoluteString ?? "").appendingPathComponent("\(folder)")
            if leaf != .none {
                path =  path.appendingPathComponent("\(leaf)")
            }
            path = path.appendingPathComponent(name)
            return path
        }
        return self.directory as URL?
    }

 @discardableResult
    func secureCopyItem(at srcURL: URL, to dstURL: URL) -> Bool {
           do {
         
//               if FileManager.default.fileExists(atPath: dstURL.path) {
//                   try FileManager.default.removeItem(at: dstURL)
//               }
               try FileManager.default.copyItem(at: srcURL, to: dstURL)
           } catch (let error) {
              SharedManager.shared.printLog("Cannot copy item at \(srcURL) to \(dstURL): \(error)")
               return false
           }
           return true
       }
    func getLogoPath() -> String{
        let posLogo = SharedManager.shared.posConfig().logo
        if fileExists(to:.images,in:.pos_config,with:posLogo) && !posLogo.isEmpty{
            if let path = getPath(from:.images,in :.pos_config, with:posLogo) {
                return path.description
            }
        }
        
      
       
       if let brandLogo = SharedManager.shared.posConfig().brand, let nameLogo = brandLogo.logo,!nameLogo.isEmpty{
           if fileExists(to:.images,in:.res_brand,with:nameLogo){

           if let path = getPath(from:.images,in :.res_brand, with:nameLogo) {
               return path.description
           }
           }
       }

         
       let nameLogo = SharedManager.shared.posConfig().company.logo
        if fileExists(to:.images,in:.res_company,with:nameLogo){

        if let path = getPath(from:.images,in :.res_company, with:nameLogo) {
            return path.description
        }
        }
      
       return ""
   }
    func getLogoPathString() -> String{
        let posLogo = SharedManager.shared.posConfig().logo
        if fileExists(to:.images,in:.pos_config,with:posLogo) && !posLogo.isEmpty{
            if let path = getPathForFile(from:.images,in :.pos_config, with:posLogo) {
                return path
            }
        }
        
      
       
       if let brandLogo = SharedManager.shared.posConfig().brand, let nameLogo = brandLogo.logo,!nameLogo.isEmpty{
           if fileExists(to:.images,in:.res_brand,with:nameLogo){

           if let path = getPathForFile(from:.images,in :.res_brand, with:nameLogo) {
               return path
           }
           }
       }

         
       let nameLogo = SharedManager.shared.posConfig().company.logo
        if fileExists(to:.images,in:.res_company,with:nameLogo){

        if let path = getPathForFile(from:.images,in :.res_company, with:nameLogo) {
            return path
        }
        }
      
       return ""
   }
    func getLogoPathStrringKitchenCloud(for brandID:Int?) -> String{
        let posLogo = SharedManager.shared.posConfig().logo
        if let path = self.getPathForFile(from: .images, in: .pos_config, with: posLogo ), !posLogo.isEmpty{
            return path
        }
       
        if let brandID = brandID {
        let brandLogo = res_brand_class.get_brand(id: brandID)
            if let nameLogo = brandLogo.logo , !nameLogo.isEmpty{
            if let path = self.getPathForFile(from: .images, in: .res_brand, with: nameLogo ){
                return path
            }

        }
        }

         
       let nameLogo = SharedManager.shared.posConfig().company.logo
       if let path = self.getPathForFile(from: .images, in: .res_company, with: nameLogo ){
           return path

       }
      
        return ""
    }
    func getLogoPathKitchenCloud(for brandID:Int?) -> String{
        let posLogo = SharedManager.shared.posConfig().logo
        if let path = self.getFile(from: .images, in: .pos_config, with: posLogo ){
            return path.description
        }
       
        if let brandID = brandID {
        let brandLogo = res_brand_class.get_brand(id: brandID)
        if let nameLogo = brandLogo.logo{
            if let path = self.getFile(from: .images, in: .res_brand, with: nameLogo ){
                return path.description
            }

        }
        }

         
       let nameLogo = SharedManager.shared.posConfig().company.logo
       if let path = self.getFile(from: .images, in: .res_company, with: nameLogo ){
           return path.description

       }
      
        return ""
    }
    func getLogoBase64KitchenCloud(for brandID:Int?) -> String{
        let posLogo = SharedManager.shared.posConfig().logo
        if let image = self.getFile(from: .images, in: .pos_config, with: posLogo ){
            let base64 = image.toBase64() ?? ""
            self.companyLogoBase64 = base64
          
            if !base64.isEmpty
            {
                return base64

            }
        }
       
        if let brandID = brandID {
        let brandLogo = res_brand_class.get_brand(id: brandID)
        if let nameLogo = brandLogo.logo{
            if let image = self.getFile(from: .images, in: .res_brand, with: nameLogo ){
                let base64 = image.toBase64() ?? ""
                self.companyLogoBase64 = base64
                return base64
            }

        }
        }

         
       let nameLogo = SharedManager.shared.posConfig().company.logo
       if let image = self.getFile(from: .images, in: .res_company, with: nameLogo ){
           let base64 = image.toBase64() ?? ""
           self.companyLogoBase64 = base64
           return base64
       }
      
        return ""
    }
    func getLogoBase64() -> String{
       
        if let base64Logo = self.companyLogoBase64 {
            return base64Logo
        }
        
         
         let posLogo = SharedManager.shared.posConfig().logo
         if let image = self.getFile(from: .images, in: .pos_config, with: posLogo ){
             let base64 = image.toBase64() ?? ""
             self.companyLogoBase64 = base64
           
             if !base64.isEmpty
             {
                 return base64

             }
         }
        
        if let brandLogo = SharedManager.shared.posConfig().brand, let nameLogo = brandLogo.logo{
            if let image = self.getFile(from: .images, in: .res_brand, with: nameLogo ){
                let base64 = image.toBase64() ?? ""
                self.companyLogoBase64 = base64
                return base64
            }

        }

          
        let nameLogo = SharedManager.shared.posConfig().company.logo
        if let image = self.getFile(from: .images, in: .res_company, with: nameLogo ){
            let base64 = image.toBase64() ?? ""
            self.companyLogoBase64 = base64
            return base64
        }
        return ""
    }
     func getAllFilles(from folder:APP_FOLDERS,in leaf:LEAF_FOLDERS = .none, with extFile:String = ".png")->[URL]  {
        if let dir = self.directory {
            var path =  URL(fileURLWithPath: dir.absoluteString ?? "").appendingPathComponent("\(folder)")
            if leaf != .none {
                path =  path.appendingPathComponent("\(leaf)")
            }
           
            do {
                // Get the directory contents urls (including subfolders urls)
                let directoryContents = try FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: nil)
//                // if you want to filter the directory contents you can do like this:
//                let extFiles = directoryContents.filter{ $0.pathExtension == extFile }
                return directoryContents
//                SharedManager.shared.printLog(directoryContents)
//               SharedManager.shared.printLog("extFiles urls:",extFiles)
//                let extFilesNames = extFiles.map{ $0.deletingPathExtension().lastPathComponent }
//               SharedManager.shared.printLog("extFilesNames list:", extFilesNames)

            } catch {
                 SharedManager.shared.printLog(error)
                return []
            }
        }
        return []
    }
    func restInvoiceLogo(){
        self.companyLogoBase64 = nil
    }
    
   
    func getString(from fileName:String, with prefix:String = "html")->String?{
        guard let pathFile = Bundle.main.path(forResource: fileName, ofType:prefix) else {
            return nil
        }
        do {
            return try String(contentsOfFile: pathFile)
        } catch {
           SharedManager.shared.printLog("Unable to open html template")
            return nil
        }
    }
    func getPK12File(){
        if let pk12FilePath = self.getPath(from: .root, with: "PK12.p12"){
            
        }else{
            if let privateKey = SharedManager.shared.privateKeyBase64{
                self.createFolder()
            }
        }
    }
}
