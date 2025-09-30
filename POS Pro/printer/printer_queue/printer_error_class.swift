//
//  printer_error_model.swift
//  pos
//
//  Created by M-Wageh on 30/06/2021.
//  Copyright © 2021 khaled. All rights reserved.
//

import Foundation
enum PRINTER_ERROR_TYPE:String{
    case Order = "Order"
    case Report = "Report"
  
}
enum PRINTER_ERROR_STATUS:Int{
    case NONE = 0,PRINTING_BY_APP,PRINTING_BY_CASHIER
  
}
class printer_error_class: NSObject {
    
    var dbClass:database_class?
    var openDeawer:Bool = false
    var order_id:Int = 0
    var time:Int64 = 0

    var printer_id:Int = 0
    var IP:String?
    var printer_name:String?
    var id : Int = 0
    var error:String?
    var updated_at:String = ""
    var type_printer_error = ""
    var html:String?
    var log_id:Int?
    var no_tries : Int = -1
    var rePrinting_status : PRINTER_ERROR_STATUS = .NONE


    let folder = APP_FOLDERS.printer_erro
    static var currentReTryPrintCount = 0
    func getFileName() -> String {
        if (self.html ?? "").contains("FILE_NAME:"){
            if let file_name = self.html?.replacingOccurrences(of: "FILE_NAME:", with: "") {
                return file_name
            }
        }
        let id =  order_id
        return "\(id)-\(IP ?? "")-\(printer_name ?? "").png"
    }
    @discardableResult func saveFile(_ image: UIImage?,fileName:String = "" )->Bool{
        if let image = image {
            let _ = FileMangerHelper.shared.saveFile(image: image,to:folder,with: fileName.isEmpty ?  getFileName() : fileName)
            return true
        }
        return false
    }
    init(mwFileInQueue:MWFileInQueue,fileName:String,error:String,id_lg:Int){
        super.init()
        var image:UIImage?
        if let jobImage = mwFileInQueue.image {
            self.html = fileName
            image = UIImage(data: jobImage.jpegData(compressionQuality: 1)!)
            saveFile(image,fileName: fileName)
        }else{
            self.html = mwFileInQueue.html
            image = nil
        }
        self.error = error
        self.openDeawer = mwFileInQueue.openDrawer
        order_id = mwFileInQueue.order?.id ?? 0
        time = mwFileInQueue.time
        if mwFileInQueue.row_type == nil || mwFileInQueue.row_type == rowType.none {
            type_printer_error = "Report"
        }else{
            type_printer_error = mwFileInQueue.row_type?.rawValue ?? ""
        }
        printer_id = mwFileInQueue.restaurantPrinter?.id ?? 0
        IP =  mwFileInQueue.restaurantPrinter?.printer_ip
        printer_name =  mwFileInQueue.restaurantPrinter?.name ?? "default name"
        self.log_id = id_lg
        dbClass = database_class(table_name: "printer_error",
                                 dictionary: self.toDictionary(),
                                 id: id,
                                 id_key:"id",connect:.printer_log)
    }
    init(job:job_printer,epson_printer:epson_printer_class,id_lg:Int?)  {
        super.init()
        error = job.error
        openDeawer = job.openDeawer
        order_id = job.order_id
        time = job.time
        if job.row_type == nil || job.row_type == rowType.none {
            type_printer_error = "Report"

        }else{
            type_printer_error = job.row_type?.rawValue ?? ""
        }

//        if  job.order_id != 0 {
//            type_printer_error = PRINTER_ERROR_TYPE.Order.rawValue
//        }else{
//            type_printer_error = PRINTER_ERROR_TYPE.Report.rawValue
//
//        }
        printer_id = epson_printer.printer_id
        IP = epson_printer.IP
        printer_name = epson_printer.printer_name
        self.log_id = id_lg
        #if DEBUG
        var image:UIImage?
        if let jobImage = job.image {
                image = UIImage(data: jobImage.jpegData(compressionQuality: 1)!)
            }else{
                image =  runner_print_class.htmlToImage(html: job.html)
            }
        saveFile(image)
        #endif
        if self.log_id == nil || self.log_id == 0 {
        var image:UIImage?
        if job.row_type == .kds || job.row_type == .insurance {
            self.html = job.html
        }else{
        if let jobImage = job.image {
            image = UIImage(data: jobImage.jpegData(compressionQuality: 1)!)
        }else{
            image =  runner_print_class.htmlToImage(html: job.html)
        }
            saveFile(image)
        }
        }
        dbClass = database_class(table_name: "printer_error",
                                 dictionary: self.toDictionary(),
                                 id: id,
                                 id_key:"id",connect:.printer_log)
        
    }
    func toDictionary() -> [String:Any]
    {
        var dictionary:[String:Any] = [:]
        dictionary["openDeawer"] = openDeawer
        dictionary["order_id"] = order_id
        dictionary["printer_id"] = printer_id
        dictionary["IP"] = IP
        dictionary["printer_name"] = printer_name
        dictionary["error"] = error
        dictionary["time"] = time
        dictionary["type_printer_error"] = type_printer_error
        dictionary["log_id"] = log_id
        dictionary["html"] = html
        dictionary["no_tries"] = no_tries
        dictionary["rePrinting_status"] = rePrinting_status.rawValue

        return dictionary
    }
    init(fromDictionary dictionary: [String:Any]){
        super.init()
        openDeawer =  dictionary["openDeawer"] as? Bool ?? false
        order_id = dictionary["order_id"] as? Int ?? 0
        printer_id = dictionary["printer_id"]  as? Int ?? 0
        IP =  dictionary["IP"]  as? String ?? ""
        printer_name = dictionary["printer_name"]  as? String ?? ""
        updated_at = dictionary["updated_at"]  as? String ?? ""
        id =  dictionary["id"] as? Int ?? 0
        error =  dictionary["error"] as? String ?? ""
        time =  dictionary["time"] as? Int64 ?? 0
        type_printer_error =  dictionary["type_printer_error"] as? String ?? ""
        log_id =  dictionary["log_id"] as? Int ?? 0
        html =  dictionary["html"] as? String ?? ""
        no_tries =  dictionary["no_tries"] as? Int ?? -1
        rePrinting_status = PRINTER_ERROR_STATUS(rawValue: dictionary["rePrinting_status"] as? Int ?? 0 ) ?? .NONE
        dbClass = database_class(table_name: "printer_error",
                                 dictionary: self.toDictionary(),
                                 id:id,
                                 id_key:"id",connect:.printer_log)
        
    }
    func save()
    {
        var sql = "where printer_id = \(self.printer_id) "
        sql += "And IP = '\( self.IP ?? "" )' "
        sql += "And printer_name = '\(self.printer_name ?? "")' "
        sql += "And type_printer_error = '\(self.type_printer_error)' "
        sql += "And time = \(self.time) "
        sql += "And order_id = \(self.order_id) "
        if let html = self.html {
            sql += "And html = '\(html)' "
        }
        sql += "And log_id = \(self.log_id ?? 0) "

        let arr  = self.dbClass!.get_rows(whereSql: sql)
        if arr.count <= 0 {
            dbClass?.dictionary = self.toDictionary()
    //        dbClass?.id = self.id
            _ =  dbClass!.save()

        }
//        else{
//            if let dic = arr.first {
//                let cls = printer_error_class(fromDictionary:dic)
//
//            }
//        }
        
    }
    func getPrinterImage() -> (image:UIImage?,html:String?){
        if let id_lg = self.log_id {
            let arr_log = printer_log_class.getLog(by:id_lg)
            if arr_log.count > 0 {
                if let dic_log = arr_log.first {
                    let log_printer = printer_log_class(fromDictionary:dic_log)
                    if (log_printer.html ?? "").contains("FILE_NAME:"){
                        if let file_name = log_printer.html?.replacingOccurrences(of: "FILE_NAME:", with: "") {
                            return (image:FileMangerHelper.shared.getFile(from: APP_FOLDERS.printer_erro, with:file_name),html:log_printer.html)
                        }
                    }
                   let html_job = getReSendRetryHtml(for:log_printer.html ?? "")

                    return (image:runner_print_class.htmlToImage(html: html_job), html:html_job)
                }
            }
        }
        if var html_job = self.html ,  self.type_printer_error == "kds" , !(html_job.isEmpty) {
             html_job = getReSendRetryHtml(for:html_job)
            return (image:runner_print_class.htmlToImage(html: html_job),html:html_job)
        }
        return (image:FileMangerHelper.shared.getFile(from: APP_FOLDERS.printer_erro, with:getFileName()),html:self.html)
    }
    func getReSendRetryHtml(for job:String)->String{
        var html_job = job
        if   self.type_printer_error == "kds" , !(html_job.isEmpty) {
            if (html_job.contains("<!--resentBackIdHint-->") ){
                guard let imageBase64 = #imageLiteral(resourceName: "send-back.png").toBase64() else {
                    return ""
                }
                let resent_back_html = (CashHtmlFiles.shared.resend_try ?? "").replacingOccurrences(of:"#VALUE#",with: imageBase64)
                html_job = html_job.replacingOccurrences(of: "<!--resentBackIdHint-->", with:resent_back_html)
            }
        }
        return html_job
    }
    func tryToPrint(resturantPrinter:restaurant_printer_class? = nil){
        if let image = getPrinterImage().image {
//            self.clearErrorFromDB()
            var printer = SharedManager.shared.printers_pson_print[self.printer_id] ?? epson_printer_class(IP: IP,printer_name: printer_name ?? "",printer_id: self.printer_id )
            if let resturantPrinter = resturantPrinter {
                printer = SharedManager.shared.printers_pson_print[resturantPrinter.id] ?? epson_printer_class(IP: resturantPrinter.epson_printer_ip,printer_name: resturantPrinter.display_name,printer_id: self.printer_id  )
            }
           
            let job = job_printer()
            job.order_id = self.order_id
            job.type = .image
            job.image = image
            job.openDeawer = self.openDeawer
            job.time = self.time
            job.row_type = self.type_printer_error == "Report" ? rowType.none : rowType(rawValue: self.type_printer_error)
            printer.addToQueue(job: job)
            SharedManager.shared.printers_pson_print[self.printer_id] = printer
        }
        
    }
    func getResturantPrinter() -> restaurant_printer_class?{
        if let ip = self.IP {
           return restaurant_printer_class.get(ip: ip)
        }
        return nil
    }
    func addToErrorImageMWQueue(){
        let imagePrinter = getPrinterImage()
        if  let resturantPrinter = getResturantPrinter(){
            if !MWRunQueuePrinter.shared.checkExist(printer_error_id: self.id){
                SharedManager.shared.addToMWPrintersQueue(image:imagePrinter.image,html: imagePrinter.html ?? "", with: resturantPrinter,
                                                          fileType: .error, openDeawer: false,
                                                          queuePriority: .HIGH,printer_error_id: self.id,printer_error:self)
            }
        }
    }
  
     func deletImage()
    {
//        let cls = restaurant_table_class(fromDictionary: [:])
//        _ =  cls.dbClass?.runSqlStatament(sql: "delete from printer_error where order_id = " + "'"+orderID+"'")
        if let html_job = self.html ,  self.type_printer_error == "kds" , !(html_job.isEmpty) {
            return
        }
        FileMangerHelper.shared.removeFile(from: APP_FOLDERS.printer_erro,with: getFileName())
    }
    func clearErrorFromDB(){
        _ =  self.dbClass?.runSqlStatament(sql: "delete from printer_error where id = " + "'"+"\(self.id)"+"'")
//        let name = "\(self.order_id).png"
//        FileMangerHelper.shared.removeFile(from: APP_FOLDERS.printer_erro,with: name)
    }
    static func getAll() ->  [[String:Any]] {
        let cls = printer_error_class(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(whereSql: "")
        return arr
        
    }
    static func getAllObject( sql:String = " where rePrinting_status in (2) ") ->  [printer_error_class] {
        let cls = printer_error_class(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(whereSql: sql)
        let objectArray:[printer_error_class] = arr.map { (item) -> printer_error_class in
            return printer_error_class(fromDictionary:item)
        }
        return objectArray
        
    }
    static func getPrinterWith(orderID:String) ->  printer_error_class? {
        let cls = printer_error_class(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(whereSql: "where order_id = " + "'"+orderID+"'")
        if let setting = arr.first{
            return printer_error_class(fromDictionary:setting)

        }
        return nil
    }
    static func getPrinterWith(idError:Int) ->  printer_error_class? {
        let cls = printer_error_class(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(whereSql: "where id = \(idError)")
        if let setting = arr.first{
            return printer_error_class(fromDictionary:setting)

        }
        return nil
    }
    
    static func reset()
    {
        let cls = printer_error_class(fromDictionary: [:])
        _ =  cls.dbClass?.runSqlStatament(sql: "delete from printer_error")
        FileMangerHelper.shared.removeFile(from: APP_FOLDERS.printer_erro)
        FileMangerHelper.shared.createFolder(folder: APP_FOLDERS.printer_erro)
    }
    static func deletFile(orderID:String)
    {
        let name = "\(orderID).png"
        FileMangerHelper.shared.removeFile(from: APP_FOLDERS.printer_erro,with: name)
    }
    static func getCount() -> Int?{
        let cls = printer_error_class(fromDictionary: [:])
        let count = cls.dbClass?.get_rows_count(whereSql: "") ?? 0
        return   count  > 0 ? count : nil

    }
    static func reTryToPrintIsAvaliable(with condation:Bool = false) -> Bool{
        if SharedManager.shared.appSetting().mw_minuts_fail_report == 0 {
            return false
        }
        var sql = "where IP IS NOT NULL and IP != ' '"
        if condation {
            let minuts =  SharedManager.shared.appSetting().mw_minuts_fail_report
            sql += "And updated_at >= Datetime('now', '-\(minuts) minutes')"
        }
        let errorPrinterArray = getAllObject(sql: sql)
        if errorPrinterArray.count <= 0 {
            return false
        }
        let noTriesFromSetting =  SharedManager.shared.appSetting().tries_non_priinted_number
        if (currentReTryPrintCount >= noTriesFromSetting){
            errorPrinterArray.forEach { errorPrinter in
                errorPrinter.resetPrinter()
            }
            return false
        }
        currentReTryPrintCount += 1
        //MARK:- Create queue for error printer
        errorPrinterArray.forEach { errorPrinter in
            errorPrinter.tryToPrint()
        }
        return true
 
    }
    func resetPrinter(){
        SharedManager.shared.printers_pson_print[self.printer_id]?.reset()
        SharedManager.shared.printers_pson_print[self.printer_id] = nil
    }
    static func haveRecord(for id:Int) ->  Bool {
        let cls = printer_error_class(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(whereSql: "where printer_id = " + "'"+"\(id)"+"'")
        return arr.count > 0
    }
    static func countBefore(date:String?) -> Int   {
           if date != nil
           {
               let count:[String:Any] = database_class(connect: .printer_log).get_row(sql: "select count(*) as cnt from printer_error where updated_at  < '\(date!)' ") ?? [:]

            return count["cnt"] as? Int ?? 0
             
           }
        
        return 0
           
       }
    static func setStatus(with status:PRINTER_ERROR_STATUS, for id:Int){
        let sql = " UPDATE printer_error SET rePrinting_status = \(status.rawValue) WHERE id IN (\(id)) "
        let semaphore = DispatchSemaphore(value: 0)
        SharedManager.shared.printer_log_db!.inDatabase { (db:FMDatabase) in
            
            let resutl =  db.executeStatements(sql)
            if !resutl
            {
                let error = db.lastErrorMessage()
               SharedManager.shared.printLog("database Error : \(error)" )
            }
            db.close()
            semaphore.signal()
        }
        semaphore.wait()
    }
    static func vacuum_database()
         {
             let sql = "vacuum"
             
             let semaphore = DispatchSemaphore(value: 0)
             SharedManager.shared.printer_log_db!.inDatabase { (db:FMDatabase) in

                 let success = db.executeUpdate(sql  , withArgumentsIn: [] )
                 
                 if !success
                 {
                     let error = db.lastErrorMessage()
                    SharedManager.shared.printLog("database Error : \(error)" )
                 }
                 
                 db.close()
                 semaphore.signal()
             }
             
             
             semaphore.wait()
         }
}
