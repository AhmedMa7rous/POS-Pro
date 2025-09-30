//
//  import_Export.swift
//  pos
//
//  Created by Khaled on 1/4/20.
//  Copyright © 2020 khaled. All rights reserved.
//

import UIKit


class import_Export: UIViewController ,URLSessionDelegate , FileDownloaderDelegate {
    
    
    var defaultSession: URLSession!
    var downloadTask: URLSessionDownloadTask!
    
    @IBOutlet var lblProgress: KLabel!
    
    @IBOutlet var view_upload: UIView!
    var parent_vc:UIViewController?
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var indc: UIActivityIndicatorView!
    @IBOutlet weak var btnurl: UIButton!
    @IBOutlet weak var txt_url: UITextField!
    
    
    var downloader:FileDownloader = FileDownloader()
    var uploadurl_amazon  = ""
    
    var tempPath  = ""
    var documentsPath  = ""
    var documentsZipPath  = ""
    var ordersZipPath  = ""
    var zipSize  = ""

    var    documentDirectory_zip:URL!
    
    
//    var timer_auto_upload:Timer?

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        indc.stopAnimating()
        initPaths()
        view_upload.isHidden = true
        
        self.progressView.progress = 0
        
        self.uploadurl_amazon = uploadAWS3.getLastUploadUrl()
        if !self.uploadurl_amazon.isEmpty
        {
            self.btnurl.setTitle(String(format:"last Uploaded file url:%@",self.uploadurl_amazon), for: .normal)
        }
        
        
        //        progressView.translatesAutoresizingMaskIntoConstraints = false
        //        progressView.transform = progressView.transform.scaledBy(x: 1, y: 20)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.upload_progress_Notification),
            name: NSNotification.Name(rawValue: "upload_progress"),
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.upload_success_Notification),
            name: NSNotification.Name(rawValue: "upload_success"),
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.upload_failure_Notification),
            name: NSNotification.Name(rawValue: "upload_failure"),
            object: nil)
        
    }
    
    
    
    func initPaths()
    {
        let documentsUrl = FileManager.default.urls(for: .documentDirectory,
                                                    in: .userDomainMask).first!
        
        let tempUrl = FileManager.default.urls(for: .cachesDirectory,
                                               in: .userDomainMask).first!
        
        documentDirectory_zip = try? FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("documentDirectory").appendingPathExtension("zip")
        
        let orders_zip = try? FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("orders").appendingPathExtension("zip")
        
        documentsPath = documentsUrl.absoluteString.replacingOccurrences(of: "file://", with: "")
        documentsZipPath = documentDirectory_zip!.absoluteString.replacingOccurrences(of: "file://", with: "")
        ordersZipPath = orders_zip!.absoluteString.replacingOccurrences(of: "file://", with: "")
        tempPath = tempUrl.absoluteString.replacingOccurrences(of: "file://", with: "")
        
    }
    
    @IBAction func btnUrl(_ sender: Any) {
        if uploadurl_amazon != ""
        {
            self.shareFile(path: uploadurl_amazon)
            
        }
    }
    @IBAction func btnExportAll(_ sender: Any) {
        
        let alert = UIAlertController(title: "Export", message: "Choose Export option", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Upload" , style: .default, handler: { (action) in
            
            self.upload_export(prfix:"All",ZipPath: self.documentsZipPath, path: self.documentsPath, document_zip: self.documentDirectory_zip!,withFilesAtPaths: nil)
            
            alert.dismiss(animated: true, completion: nil)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Share" , style: .default, handler: { (action) in
            
            
            self.share_export(ZipPath: self.documentsZipPath, path: self.documentsPath,withFilesAtPaths: nil )
            
            alert.dismiss(animated: true, completion: nil)
            
        }))
        
        
        alert.addAction(UIAlertAction(title: "Cancel" , style: .cancel, handler: { (action) in
            
            alert.dismiss(animated: true, completion: nil)
            
        }))
        
        
        
        self .present(alert, animated: true, completion: nil)
        
        
    }
    
    func share_export(ZipPath:String,path:String?,withFilesAtPaths:[String]?)
    {
        self.indc?.startAnimating()
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            
            AppDelegate.shared.vacuum_database()
            
            
            if withFilesAtPaths != nil
            {
                SSZipArchive.createZipFile(atPath: ZipPath, withFilesAtPaths: withFilesAtPaths!)
            }
            else
            {
                SSZipArchive.createZipFile(atPath: ZipPath , withContentsOfDirectory: path!)
                
            }
            
            //        let new_documentDirectory_zip_path = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("documentDirectory").appendingPathExtension("zip")
            
            //         let new_documentDirectory_zip = new_documentDirectory_zip_path!.absoluteString.replacingOccurrences(of: "file://", with: "")
            
            //                self.uMoveFile(atPath: self.documentsZipPath, toPath: new_documentDirectory_zip)
            self.shareFile(path: ZipPath)
            
            //                   self.upload(url:  self.documentDirectory_zip!,prfix: "All")
            
            
            self.indc?.stopAnimating()
            
        }
    }
    
    func upload_export(prfix:String, ZipPath:String,path:String?,document_zip:URL,withFilesAtPaths:[String]?)
    {
        self.indc?.startAnimating()
        view_upload?.isHidden = false
        
        lblProgress?.text = "prepare for upload."
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            
            AppDelegate.shared.vacuum_database()
            
            if withFilesAtPaths != nil
            {
                SSZipArchive.createZipFile(atPath: ZipPath, withFilesAtPaths: withFilesAtPaths!)
            }
            else
            {
                SSZipArchive.createZipFile(atPath: ZipPath , withContentsOfDirectory: path!)
                
            }
            
            
            self.zipSize = document_zip.fileSizeString
            //        let new_documentDirectory_zip_path = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("documentDirectory").appendingPathExtension("zip")
            
            //         let new_documentDirectory_zip = new_documentDirectory_zip_path!.absoluteString.replacingOccurrences(of: "file://", with: "")
            
            //                self.uMoveFile(atPath: self.documentsZipPath, toPath: new_documentDirectory_zip)
            //                self.shareFile(path: self.documentsZipPath)
            
            self.upload(url:  document_zip,prfix:prfix)
            
            
            self.indc?.stopAnimating()
            
        }
    }
    
    
    
    @objc private func upload_progress_Notification(_ notification: Notification) {
        let progress = notification.object as? Double ?? 0
        upload_progress(progress:progress)
    }
    
    @objc private func upload_success_Notification(_ notification: Notification) {
        let url = notification.object as? String ?? ""
        upload_success(uploadedFileUrl:url)
        
        
    }
    
    @objc private func upload_failure_Notification(_ notification: Notification) {
        let error = notification.object as? Error ?? nil
        if error != nil
        {
            upload_failure(error:error!)
        }
        
    }
    
    func upload_progress(progress:Double)
    {
        DispatchQueue.main.async {
        self.indc?.startAnimating()
        self.progressView.progress = Float(progress)
        
        let pres = progress * 100
            self.lblProgress?.text = String(format: "%2.f%@ / %@", pres , "%" , self.zipSize)
            self.view_upload?.isHidden = false
        }
    }
    
    func upload_success(uploadedFileUrl:String)
    {
        self.uploadurl_amazon = uploadedFileUrl
        self.btnurl?.setTitle(String(format:"Uploaded file url:%@",self.uploadurl_amazon), for: .normal)
        
        self.progressView?.progress = 0
        lblProgress?.text = String(format: "%2.f%@", 0 , "%")
        
        self.indc?.stopAnimating()
        view_upload?.isHidden = true
        DispatchQueue.main.async {
            var log:logClass = logClass(fromDictionary: [:])
            log.prefix =  "uploadSuccess"
            log.key = "uploadSuccess"
            log.data = uploadedFileUrl
           log.save()
        }
        btnUrl(AnyClass.self)
    }
    
    func upload_failure(error:Error)
    {
        DispatchQueue.main.async {
       SharedManager.shared.printLog("\(String(describing: error.localizedDescription))")
        self.progressView?.progress = 0
            self.lblProgress?.text = String(format: "%2.f%@", 0 , "%")
        
        self.indc?.stopAnimating()
            self.view_upload?.isHidden = true
        var log:logClass = logClass(fromDictionary: [:])
        log.prefix =  "uploadFailure"
        log.key = "uploadFailure"
        log.data = error.localizedDescription
       log.save()
        }
    }
    
    
    
    
    
    func upload(url:URL,prfix:String)
    {
        //        loadingClass.show(view: self.view)
        
        self.progressView?.progress = 0
        
        AppDelegate.shared.upload.uploadOtherFile(url: url, prfix: prfix)
        
    }
    @IBAction func btnExportOrders(_ sender: Any) {
    

       
        
        let alert = UIAlertController(title: "Export", message: "Choose Export option", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Upload" , style: .default, handler: { (action) in
            
            self.export_orders(share: false)
            
            alert.dismiss(animated: true, completion: nil)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Share" , style: .default, handler: { (action) in
            
            self.export_orders(share: true)

            
            alert.dismiss(animated: true, completion: nil)
            
        }))
        
        
        alert.addAction(UIAlertAction(title: "Cancel" , style: .cancel, handler: { (action) in
            
            alert.dismiss(animated: true, completion: nil)
            
        }))
        
        
        
        self .present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func btnExportLog(_ sender: Any) {
       
     
        
        let alert = UIAlertController(title: "Export", message: "Choose Export option", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Upload" , style: .default, handler: { (action) in
            
            self.export_log(share: false)
            
            alert.dismiss(animated: true, completion: nil)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Share" , style: .default, handler: { (action) in
            
            self.export_log(share: true)

            
            alert.dismiss(animated: true, completion: nil)
            
        }))
        
        
        alert.addAction(UIAlertAction(title: "Cancel" , style: .cancel, handler: { (action) in
            
            alert.dismiss(animated: true, completion: nil)
            
        }))
        
        
        
        self .present(alert, animated: true, completion: nil)
    }
    
    @IBAction func btnExport_printer_Log(_ sender: Any) {
       
   
        
        
        let alert = UIAlertController(title: "Export", message: "Choose Export option", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Upload" , style: .default, handler: { (action) in
            
            self.export_printer_log(share: false)

            alert.dismiss(animated: true, completion: nil)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Share" , style: .default, handler: { (action) in
            
            self.export_printer_log(share: true)
            
            alert.dismiss(animated: true, completion: nil)
            
        }))
        
        
        alert.addAction(UIAlertAction(title: "Cancel" , style: .cancel, handler: { (action) in
            
            alert.dismiss(animated: true, completion: nil)
            
        }))
        
        
        
        self .present(alert, animated: true, completion: nil)
    }
     
    func unZip(path:String)
    {
        SSZipArchive.unzipFile(atPath: path, toDestination: documentsPath)
    }
    
    @IBAction func btnImport (_ sender: Any) {
        
        if txt_url.text == ""
        {
            printer_message_class.show("invalid url .")
        }
        else
        {
            let url_txt = NSURL(string: txt_url.text!)
            let url = url_txt! as URL
            
            loadingClass.show(view: self.view)
            downloader.delegate = self
            downloader.loadFileAsync2(url: url)
        }
        
        
    }
    
    func progress(value:Float)
    {
        progressView.progress = value
    }
    
    func downloadeComplete(path:String?,error:Error?)
    {
        self.progressView.progress = 0
        
        if error != nil
        {
            printer_message_class.show(error!.localizedDescription)
        }
        else
        {
            if path != nil
            {
               SharedManager.shared.printLog("File downloaded to : \(path!)")
                
               
                
                AppDelegate.shared.removeDatabases()
                self.unZip(path: path!)
                
                let setting =  SharedManager.shared.appSetting()
                 
                 setting.enable_testMode = true
                 setting.save()
                
                
                SharedManager.shared.domain_url = nil
                
                printer_message_class.show("Done")

            }
            
        }
        
        loadingClass.hide(view: self.view)
        

    }
     
    func uMoveFile(atPath: String, toPath: String) {
        //        if FileManager.default.fileExists(atPath: toPath) {
        //           SharedManager.shared.printLog("File is available")
        //        } else {
        do {
            try FileManager.default.moveItem(atPath: atPath, toPath: toPath)
        } catch {
             SharedManager.shared.printLog(error)
            //            }
        }
    }
    
    func shareFile(path:String)
    {
        DispatchQueue.main.async {

        //        let url = NSURL.fileURL(withPath: path)
        let url = NSURL(string: path)
        
        let activityViewController = UIActivityViewController(activityItems: [url!] , applicationActivities: nil)
        
        activityViewController.popoverPresentationController?.sourceView = self.view
        activityViewController.popoverPresentationController?.sourceRect =  self.view.bounds
        
        
            
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    
    func export_printer_log(share:Bool)
    {
        let data_db = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("printer_log").appendingPathExtension("db")
           
           let data_db_zip = try? FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("printer_log").appendingPathExtension("zip")
           
           let data_db_str = data_db!.absoluteString.replacingOccurrences(of: "file://", with: "")
           let data_db_zip_str = data_db_zip!.absoluteString.replacingOccurrences(of: "file://", with: "")
        
        if share == true
        {
            self.share_export(ZipPath: data_db_zip_str, path: nil ,withFilesAtPaths: [data_db_str])

        }
        else
        {
            self.upload_export(prfix:"printer_log",ZipPath: data_db_zip_str, path:nil, document_zip:  data_db_zip!,withFilesAtPaths: [data_db_str])

        }

    }
    
    func export_log(share:Bool)
    {
        let data_db = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("log").appendingPathExtension("db")
             
             let data_db_zip = try? FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("log").appendingPathExtension("zip")
             
             let data_db_str = data_db!.absoluteString.replacingOccurrences(of: "file://", with: "")
             let data_db_zip_str = data_db_zip!.absoluteString.replacingOccurrences(of: "file://", with: "")
        
         if share
         {
            self.share_export(ZipPath: data_db_zip_str, path: nil ,withFilesAtPaths: [data_db_str])

        }
        else
         {
            self.upload_export(prfix:"Log",ZipPath: data_db_zip_str, path:nil, document_zip:  data_db_zip!,withFilesAtPaths: [data_db_str])

        }
    }
    
    
    func export_all(share:Bool)
    {
     
        
        if share
        {
            self.share_export(ZipPath: self.documentsZipPath, path: self.documentsPath,withFilesAtPaths: nil )

        }
        else
        {
            self.upload_export(prfix:"All",ZipPath: self.documentsZipPath, path: self.documentsPath, document_zip: self.documentDirectory_zip!,withFilesAtPaths: nil)

        }
    }

    
    func export_orders(share:Bool)
    {
        let data_db = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("data").appendingPathExtension("db")
        
        let data_db_zip = try? FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("data").appendingPathExtension("zip")
        
        let data_db_str = data_db!.absoluteString.replacingOccurrences(of: "file://", with: "")
        let data_db_zip_str = data_db_zip!.absoluteString.replacingOccurrences(of: "file://", with: "")
        
        if share
        {
            self.share_export(ZipPath: data_db_zip_str, path: nil ,withFilesAtPaths: [data_db_str])

        }
        else
        {
            self.upload_export(prfix:"Orders",ZipPath: data_db_zip_str, path:nil, document_zip:  data_db_zip!,withFilesAtPaths: [data_db_str])

        }
    }
    
    func check_auto_upload()
    {
        /*
        if timer_auto_upload != nil
        {
                   timer_auto_upload!.invalidate()
               
         }

           timer_auto_upload = Timer.scheduledTimer(timeInterval:5, target: self, selector: #selector(is_time_to_upload), userInfo: nil, repeats: true)
           timer_auto_upload!.fire()
        */
    }
    
    @objc func is_time_to_upload()
    {
      
 
        
        let CashTime =   24 * 60 * 60
       let  localCash = cash_data_class( CashTime )
        localCash.enableCash = true
        
        let dt =  localCash.getTimelastupdate("auto_upload") ?? ""
        if dt.isEmpty
                        {
                            localCash.setTimelastupdate("auto_upload")

                            return
                        }
        
        let check =  localCash.isTimeTopdate("auto_upload")
        if  check == true
        {
      
            upload_all()
            
            localCash.setTimelastupdate("auto_upload")

        }
        
    }
    
    func upload_all()  {
        
//        export_orders(share: false)
//              export_log(share: false)
//              export_printer_log(share: false)
        
        if AppDelegate.shared.enable_debug_mode_code() == true
        {
//            #if DEBUG
             return
//            #endif
        }
 
        
        
            initPaths()
        export_all(share: false)
    }
    
    
}
