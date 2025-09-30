//
//  pos_order_class + extension.swift
//  pos
//
//  Created by M-Wageh on 28/09/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation
extension pos_order_class {
   
     static func setMenuStatus(with status:orderMenuStatus,for uid:String)
    {
        let sql = "update pos_order set order_menu_status = \(status.rawValue) where uid = '\(uid)'"
        let semaphore = DispatchSemaphore(value: 0)
        SharedManager.shared.database_db!.inDatabase { (db:FMDatabase) in
            let success  = db.executeUpdate(sql, withArgumentsIn: [])
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
extension pos_order_integration_class {
   
     static func setMenuStatus(with status:orderMenuStatus,for uid:String)
    {
        
        let write_date = Date().toString(dateFormat: baseClass.date_formate_database, UTC: false)
        let sql = "update pos_order_integration set order_status = \(status.rawValue), write_datetime = '\(write_date)' where order_uid = '\(uid)'"
        let semaphore = DispatchSemaphore(value: 0)
        SharedManager.shared.database_db!.inDatabase { (db:FMDatabase) in
            let success  = db.executeUpdate(sql, withArgumentsIn: [])
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
