//
//  MaintenanceInteractor.swift
//  pos
//
//  Created by M-Wageh on 10/05/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation
enum TEST_MODE_ACTIVE:String{
    case NONE = "0",CAN_ACTIVE,CAN_NOT_ACTIVE
}
class MaintenanceInteractor{
    static let shared:MaintenanceInteractor = MaintenanceInteractor()
    
    private init(){}
    func activeMode()->TEST_MODE_ACTIVE{
        let activeModeValue = cash_data_class.get(key: "TEST_MODE_ACTIVE") ?? "0"
        return TEST_MODE_ACTIVE(rawValue: activeModeValue) ?? .NONE
    }
    func conytrolActiveMode(){
        if self.activeMode() != TEST_MODE_ACTIVE.CAN_NOT_ACTIVE{
            if self.checkIfHasSyncOrder() {
                cash_data_class.set(key: "TEST_MODE_ACTIVE",value: TEST_MODE_ACTIVE.CAN_NOT_ACTIVE.rawValue )
            }else{
                cash_data_class.set(key: "TEST_MODE_ACTIVE",value: TEST_MODE_ACTIVE.CAN_ACTIVE.rawValue )
            }
        }
    }
    func checkMaintance(){
        DispatchQueue.global(qos: .background).async {
            let sql_delete_duplicate_avaliable_products = "DELETE FROM product_avaliable WHERE id NOT IN ( SELECT MAX(id) FROM product_avaliable GROUP BY product_product_id );"
            let sql_ip = "BEGIN TRANSACTION; DELETE FROM messages_ip_queue WHERE datetime(updated_at) < datetime('now', '-1 hours'); DELETE FROM log WHERE datetime(log.updated_at) < datetime('now', '-1 hours'); DELETE FROM device_ip_info; COMMIT;"
            self.forceExuteQueryMessageIpLog(sql:sql_ip)
            self.forceExuteQueryDatabase(sql:sql_delete_duplicate_avaliable_products)

//            AppDelegate.shared.sync.syncOrders()
            self.conytrolActiveMode()
            if self.activeMode() == .CAN_NOT_ACTIVE{
                if SharedManager.shared.appSetting().enable_testMode{
                    SharedManager.shared.appSetting().enable_testMode = false
                    SharedManager.shared.appSetting().save()
                }
            }
//            if (SharedManager.shared.appSetting().enable_show_new_render_invoice ?? false){
//                SharedManager.shared.appSetting().enable_show_new_render_invoice = true
//            }

       // self.fixPosOrdersThatPaidAndNotSync()
            self.alterCashPOSID()
            self.clearMessageip()
            self.alterAppSettingFR()
            // self.removeDuplicatePrinter()
            self.getLastMaintanceDate()
//            self.getHTML(for:"1708945740-POS1-12")
//            self.readFackJson()
            self.searchBluetoothPrinter()
            // self.removeDuplicatePrinter()
//            self.testVoidProduct()
//            self.readOrderFromJsonFile() [KDS-printer delay crash ,KDS]Awaily - shawram was KDS Delay ip]
//            self.printBodyOrder(for:"1713301394-K F [1]-80")
//            self.getLastContextImageErrorOrder()
            
            MWQueue.shared.firebaseQueue.async {
//        FireBaseService.defualt.setFRSettingAppForAllDataBase(dataBase:"rajhierp",
//                                                                      keySetting:SETTING_KEY.enable_cloud_qr_code.rawValue ,
//                                                                      valueSetting:"false")
        }
            
        DispatchQueue.global(qos: .background).async {
                        SharedManager.shared.poll?.get_orders_sync_all_online()
                        SharedManager.shared.poll?.get_last_id()
        }
            
        }
    }
    func updateSequence(with seq:Int, is_closed:Bool?, for uid:String){

//    func updateSequence(with seq:Int, is_closed:Bool?, for uid:String,voidUID:[String]?,SyncUID:[String]?,closedUID:[String]?){
       /*
        if let voidUID = voidUID , voidUID.count > 0 {
            var sql_void = "update pos_order set is_void = 1 where uid in (\(voidUID.joined(separator: ","))) "
            self.forceExuteQueryDatabase(sql:sql_void,stopFR: true)
            NotificationCenter.default.post(name: Notification.Name("poll_update_order"), object: uid ,userInfo: [:])

        }
        if let closedUID = closedUID , closedUID.count > 0 {
            var sql_closed = "update pos_order set is_closed = 1 where uid in (\(closedUID.joined(separator: ","))) "
            self.forceExuteQueryDatabase(sql:sql_closed,stopFR: true)
            NotificationCenter.default.post(name: Notification.Name("poll_update_order"), object: uid ,userInfo: [:])

        }
        if let SyncUID = SyncUID , SyncUID.count > 0 {
            var sql_sync = "update pos_order set is_sync = 1 where uid in (\(SyncUID.joined(separator: ","))) "
            self.forceExuteQueryDatabase(sql:sql_sync)
            NotificationCenter.default.post(name: Notification.Name("poll_update_order"), object: uid ,userInfo: [:])

        }
        */
        if seq != MWConstantLocalNetwork.defaultSequence && !uid.isEmpty {
            MWQueue.shared.mwForceExcuteQueryQueue.async {
                var sql = "update pos_order set sequence_number = \(seq) where uid = '\(uid)' "
                self.forceExuteQueryDatabase(sql:sql,stopFR: true)
                NotificationCenter.default.post(name: Notification.Name("poll_update_order"), object: uid ,userInfo: [:])
            }
        }else{
//            if !SharedManager.shared.posConfig().isMasterTCP(){
                if let isClosed = is_closed , isClosed, !uid.isEmpty {
                    MWQueue.shared.mwForceExcuteQueryQueue.async {
                        var sql = "update pos_order set is_closed = 1 where uid = '\(uid)' and is_closed = 0 "
                        self.forceExuteQueryDatabase(sql:sql)
                        NotificationCenter.default.post(name: Notification.Name("poll_update_order"), object: uid ,userInfo: [:])
                    }
                }
//            }
        }
       
    }
    func searchBluetoothPrinter(){
        MWQueue.shared.mwBluetooth.async {
            MWPrinterBluetooth.shared.initalizeBLE()
        }}
    func isOneMonthsPassed() -> Bool {
        if  let startTimeInterval = Int(cash_data_class.get(key: "last_date_maintance") ?? ""){
            // Get the current date's timeIntervalSince1970
            let currentTimeInterval = Date().timeIntervalSince1970 / 1000
            
            // Get the start date's timeIntervalSince1970
            //  let startTimeInterval = startDate.timeIntervalSince1970
            
            // Calculate the number of seconds in 1 months (6 * 30.44 days, average month length)
            let sixMonthsInSeconds: TimeInterval = 1 * 30.44 * 24 * 60 * 60
            
            // Check if the difference between the current time and start time is greater than 6 months
            return (currentTimeInterval - Double(startTimeInterval)) >= sixMonthsInSeconds
        }
        return true
    }
    func getLastMaintanceDate(){
        MWQueue.shared.firebaseQueue.async {
            let posID = SharedManager.shared.posConfig().id
            if let nameDB = SharedManager.shared.getNameDB(){
                FireBaseService.defualt.getMaintanceInfoFR(pos_id: posID,hostName: nameDB)
            }
        }
    }
    func removeDuplicatePrinter(){
        MWQueue.shared.mwForceExcuteQueryQueue.async {
            var sql = "DELETE FROM restaurant_printer WHERE id NOT IN ( SELECT MIN(id) FROM restaurant_printer GROUP BY '__last_update' , epson_printer_ip, name );"
            self.forceExuteQueryDatabase(sql:sql)
        }
    }
   
    func sentOrderToMultiSession(){
        let opetions = ordersListOpetions()
        opetions.get_lines_void = true
        opetions.parent_product = true
        if let order = pos_order_class.get(uid: "1692074353-HUM-184", options_order: opetions){
            DispatchQueue.global(qos: .background).async {
//            SharedManager.shared.poll?.get_last_id()
            SharedManager.shared.poll_updates.cls_pos_multi_session = SharedManager.shared.poll!
            SharedManager.shared.poll_updates.update_order_in_server(order:order )
        }
        }
    }
    func alterCashPOSID(){
       let pinInfo_pos_ID = cash_data_class.get(key: "pinInfo_pos_ID") ?? ""
        let posID = SharedManager.shared.posConfig().id
        if posID != 0 {
            if "\(posID)" != pinInfo_pos_ID {
                cash_data_class.set(key: "pinInfo_pos_ID",value: "\(posID)")
                return
            }
        }
            if pinInfo_pos_ID.isEmpty && pinInfo_pos_ID != "0" {
                cash_data_class.set(key: "pinInfo_pos_ID",value: "\(posID)")
            }
        
    }
    func alterAppSettingFR(){
        let settings = SharedManager.shared.appSetting()
//        settings.enable_work_with_bill_uid_default
        MWQueue.shared.firebaseQueue.async {
            FireBaseService.defualt.setFRSettingApp(keySetting:SETTING_KEY.enable_check_duplicate_message_ids.rawValue ,valueSetting:"\(settings.enable_check_duplicate_message_ids)")
//
//            FireBaseService.defualt.setFRSettingApp(keySetting:SETTING_KEY.enable_cloud_qr_code.rawValue ,valueSetting:"\(settings.enable_cloud_qr_code)")
            
//            FireBaseService.defualt.setFRSettingApp(keySetting:SETTING_KEY.enable_phase2_Invoice_Offline_default.rawValue ,valueSetting:"\(settings.enable_phase2_Invoice_Offline_default)")


           

    }
    }
    
     func getLastContextImageErrorOrder(){
        if let orderUID = cash_data_class.get(key: "GraphicContextFailOrderUId" ),!orderUID.isEmpty
           {
            let opetions = ordersListOpetions()
            opetions.get_lines_void = true
            opetions.parent_product = true
//            opetions.printed = false
            opetions.get_lines_void_from_ui = true
            if let order = pos_order_class.get(uid:orderUID,options_order: opetions ){
                order.printOrderByMWqueue()
                MWRunQueuePrinter.shared.startMWQueue()
                cash_data_class.set(key: "GraphicContextFailOrderUId", value:"" )

            }
            
        }

    }
    
     func clearMessageip(){
        let sql = """
                    DELETE from log WHERE updated_at <= date('now','-1 day');
        """
        excludSqlForMessagesIPDatabase(sql)
        messages_ip_queue_class.deleteBefore()
//        messages_ip_queue_class.vacuum_database()
        excludSqlForMessagesIPDatabase("VACUUM;")
    }
    
    private func excludSqlForMessagesIPDatabase(_ sql:String){
        let semaphore = DispatchSemaphore(value: 0)
        SharedManager.shared.message_ip_log_db!.inDatabase { (db:FMDatabase) in
            
            let resutl =  db.executeStatements(sql)
            if !resutl
            {
                let error = db.lastErrorMessage()
               SharedManager.shared.printLog("database Error : \(error)" ,force: true)
            }
            db.close()
            semaphore.signal()
        }
        semaphore.wait()
    }
    private func checkIfHasSyncOrder() -> Bool{
        let sql = """
        select count(*) as cnt from pos_order
        WHERE is_sync != 0 ;
"""
        let cnt = database_class(connect: .database).get_row(sql:sql)?["cnt"] as? Int ?? 0
      return cnt > 0
    }
    
    private func fixPosOrdersThatPaidAndNotSync(){
        //version : 4.4.91(628)
        //problem : Have orders paid and not sync due to its void_status flag with 2
        //Fix: update database for these pos_order with void_status = 0 and is_sync = 1
        //Steps:
        let sql = """
        UPDATE pos_order  SET void_status  = 0 , is_sync = 1
        WHERE pos_order.id IN (
        SELECT
            po.id
        from
            pos_order po , pos_order_account_journal poaj
        where
            po.id = poaj.order_id
            and po.is_sync = 0
            and po.is_closed = 1
            and po.is_void = 0
            and po.void_status = 2
        );
"""
        let semaphore = DispatchSemaphore(value: 0)
        SharedManager.shared.database_db!.inDatabase { (db:FMDatabase) in
            
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
    func testVoidProduct(){
#if DEBUG
        if let local_session =  pos_session_class.getActiveSession(){
            let orders = pos_order_class.get_not_sync_orders(for: local_session)
            AppDelegate.shared.sync.hit_create_pos_product_void(in:local_session , for:orders )
        }
#else

#endif


    }
    func printBodyOrder(for uid:String){
        let opetions = ordersListOpetions()
        opetions.get_lines_void = true
        opetions.parent_product = true
//            opetions.printed = false
        opetions.get_lines_void_from_ui = true
        if let order = pos_order_class.get(uid:uid,options_order: opetions ){
            AppDelegate.shared.sync.sendOrder_Scrap(order: order)
            order.is_closed = false
            order.is_sync = false
//            order.get_products()
            let body = pos_order_builder_class.bulid_order_data(order: order, for_pool: nil)
            SharedManager.shared.printLog("================================")
            SharedManager.shared.printLog(body.jsonString())
            SharedManager.shared.printLog("================================")

        }
    }
    func readOrderFromJsonFile(){
#if DEBUG

        if let path = Bundle.main.path(forResource: "test-json", ofType: "json") {
            do {
                  let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                  let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                  if let jsonResult = jsonResult as? [String:Any], let data = jsonResult["data"] as? [String:Any]{
                      SharedManager.shared.poll?.read_order(data: data)    // do stuff
                  }
              } catch {
                   // handle error
              }
        }
#else

#endif

    }
    func isThereisOrder() -> Bool{
        let sql = """
        select count(*) as cnt
        FROM
            pos_order
        WHERE
            create_date < DATE('now', '-4 months');
        """
        let count:[String:Any] = database_class(connect: .meesage_ip_log).get_row(sql: sql) ?? [:]
        
        return (count["cnt"] as? Int ?? 0) > 0

    }
    func handleExcuteMaintanceFromFR( lastDate:Int?, complete:@escaping ()->()){
        MWQueue.shared.mwForceExcuteQueryQueue.async {
            self.deleteBefore6Month(with:lastDate , complete:complete)
        }
    }
    func deleteBefore6Month(with lastDate:Int?, complete:()->()){
        let sql_delete = """
        SAVEPOINT sp_delete;
        
        DELETE
        FROM
            pos_insurance_order
        WHERE
            pos_insurance_order.order_id IN (
            SELECT
                pos_order.id
            FROM
                pos_order
            WHERE
                pos_order.create_date < DATE('now', '-4 months')
        );

        DELETE
        FROM
            pos_order_integration
        WHERE
            pos_order_integration.order_uid IN (
            SELECT
                pos_order.uid
            FROM
                pos_order
            WHERE
                pos_order.create_date < DATE('now', '-4 months')
        );

        DELETE
        FROM
            pos_order_account_journal
        WHERE
            pos_order_account_journal.order_id IN (
            SELECT
                pos_order.id
            FROM
                pos_order
            WHERE
                pos_order.create_date < DATE('now', '-4 months')
        );
        -- Delete from child tableB
        DELETE
        FROM
            pos_order_line
        WHERE
            pos_order_line.order_id IN (
            SELECT
                pos_order.id
            FROM
                pos_order
            WHERE
                pos_order.create_date < DATE('now', '-4 months')
        );
        -- Delete from parent tableA
        DELETE
        FROM
            pos_order
        WHERE
            create_date < DATE('now', '-4 months');

        delete
        from
            relations
        WHERE
            re_table1_table2 in ('pos_order|is_printed', 'pos_order|print_count')
            and re_id1 not in (
            select
                id
            from
                pos_order po
            where
                po.session_id_local in (
                select
                    id
                from
                    pos_session ps
                where
                    ps.isOpen = 1 ) );

        RELEASE sp_delete;

        """
        SharedManager.shared.database_db!.inDatabase { (db:FMDatabase) in
            var error  = ""
            let resutl =  db.executeStatements(sql_delete)
            if !resutl
            {
                error = db.lastErrorMessage()
               SharedManager.shared.printLog("database Error : \(error)" )
            }
            MWQueue.shared.firebaseQueue.async {
                FireBaseService.defualt.updateForceMaintanceExecute(error: error,lastDate: lastDate)
            }

            db.close()
            complete()
        }
        
    }
    func handleExcuteQueryFromFR(db_name: String = "" ,query_excute: String = "" ){
        MWQueue.shared.mwForceExcuteQueryQueue.async {
            var dbName = db_name
            var queryExcute = query_excute
            
            if db_name.isEmpty && query_excute.isEmpty {
                dbName = cash_data_class.get(key: "db_name_by_FR") ?? ""
                queryExcute = cash_data_class.get(key: "query_excute_by_FR") ?? ""
            }
            if  dbName.isEmpty || queryExcute.isEmpty
            {
                MWQueue.shared.firebaseQueue.async {
                FireBaseService.defualt.updateForceQueryExecute(error: "Empty query or name")
                }
                return
            }
            if let dbNameType = DATA_BASE_NAME(rawValue: dbName) {
                switch dbNameType {
                case .databse:
                    self.forceExuteQueryDatabase(sql: queryExcute)
                case .log:
                    self.forceExuteQueryLog(sql: queryExcute)
                case .multipeer_log:
                    self.forceExuteQueryMultipeerLog(sql: queryExcute)
                case .ingenico_log:
                    self.forceExuteQueryIngenicoLog(sql: queryExcute)
                case .message_ip_log:
                    self.forceExuteQueryMessageIpLog(sql: queryExcute)
                case .printer_log:
                    self.forceExuteQueryPrinterLog(sql: queryExcute)
                }
            }
        }
       
    

    }
    func forceExuteQueryDatabase(sql:String , stopFR:Bool = false){
        let semaphore = DispatchSemaphore(value: 0)
        SharedManager.shared.database_db!.inDatabase { (db:FMDatabase) in
            var error  = ""
            let resutl =  db.executeStatements(sql)
            if !resutl
            {
                error = db.lastErrorMessage()
               SharedManager.shared.printLog("database Error : \(error)" )
            }
            if !stopFR {
                MWQueue.shared.firebaseQueue.async {
                    FireBaseService.defualt.updateForceQueryExecute(error: error)
                }
            }

            db.close()
            semaphore.signal()
        }
        semaphore.wait()
    }
    func forceExuteQueryLog(sql:String){
        let semaphore = DispatchSemaphore(value: 0)
        SharedManager.shared.log_db!.inDatabase { (db:FMDatabase) in
            var error  = ""

            let resutl =  db.executeStatements(sql)
            if !resutl
            {
                 error = db.lastErrorMessage()
               SharedManager.shared.printLog("database Error : \(error)" )
            }
            MWQueue.shared.firebaseQueue.async {
            FireBaseService.defualt.updateForceQueryExecute(error: error)
            }
            db.close()
            semaphore.signal()
        }
        semaphore.wait()
    }
    func forceExuteQueryMultipeerLog(sql:String){
        let semaphore = DispatchSemaphore(value: 0)
        SharedManager.shared.multipeer_log_db!.inDatabase { (db:FMDatabase) in
            var error  = ""

            let resutl =  db.executeStatements(sql)
            if !resutl
            {
                 error = db.lastErrorMessage()
               SharedManager.shared.printLog("database Error : \(error)" )
            }
            MWQueue.shared.firebaseQueue.async {
            FireBaseService.defualt.updateForceQueryExecute(error: error)
            }
            db.close()
            semaphore.signal()
        }
        semaphore.wait()
    }
    func forceExuteQueryIngenicoLog(sql:String){
        let semaphore = DispatchSemaphore(value: 0)
        SharedManager.shared.ingenico_log_db!.inDatabase { (db:FMDatabase) in
            var error  = ""

            let resutl =  db.executeStatements(sql)
            if !resutl
            {
                 error = db.lastErrorMessage()
               SharedManager.shared.printLog("database Error : \(error)" )
            }
            MWQueue.shared.firebaseQueue.async {
            FireBaseService.defualt.updateForceQueryExecute(error: error)
            }
            db.close()
            semaphore.signal()
        }
        semaphore.wait()
    }
    func forceExuteQueryMessageIpLog(sql:String){
        let semaphore = DispatchSemaphore(value: 0)
        SharedManager.shared.message_ip_log_db!.inDatabase { (db:FMDatabase) in
            var error  = ""

            let resutl =  db.executeStatements(sql)
            if !resutl
            {
                 error = db.lastErrorMessage()
               SharedManager.shared.printLog("database Error : \(error)" )
            }
            MWQueue.shared.firebaseQueue.async {
            FireBaseService.defualt.updateForceQueryExecute(error: error)
            }
            db.close()
            semaphore.signal()
        }
        semaphore.wait()
    }
    func forceExuteQueryPrinterLog(sql:String){
        let semaphore = DispatchSemaphore(value: 0)
        SharedManager.shared.printer_log_db!.inDatabase { (db:FMDatabase) in
            var error  = ""

            let resutl =  db.executeStatements(sql)
            if !resutl
            {
                 error = db.lastErrorMessage()
               SharedManager.shared.printLog("database Error : \(error)" )
            }
            MWQueue.shared.firebaseQueue.async {
            FireBaseService.defualt.updateForceQueryExecute(error: error)
            }
            db.close()
            semaphore.signal()
        }
        semaphore.wait()
    }
    func testSerlizeProduct(){
#if DEBUG

        if let path = Bundle.main.path(forResource: "test-json", ofType: "json") {
            do {
                  let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                  let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                  if let jsonResult = jsonResult as? [String:Any], let list = jsonResult["result"] as? [[String:Any]]{
                      
                      let cls = product_product_class(fromDictionary: [:])
                      
                      pos_base_class.create_temp(  cls.dbClass!)
                      product_product_class.reset(temp: true  )
                      product_product_class.saveAll(arr: list,temp: true)
                      pos_base_class.copy_temp( cls.dbClass!)   // do stuff
                  }
              } catch {
                   // handle error
              }
            SharedManager.shared.printLog("finsih selize")
        }
#else

#endif
      
    }
    func getHTML(for uid:String) {
        let opetions = ordersListOpetions()
        opetions.get_lines_void = true
        opetions.parent_product = true
//            opetions.printed = false
        opetions.get_lines_void_from_ui = true
        if let order = pos_order_class.get(uid:uid,options_order: opetions ){
            order.creatBillQueuePrinter(.bill, openDrawer: false)
        }
    }
    func readFackJson() {
#if DEBUG

        let fakeJsonString = """
{\"action\": \"update_order\", \"data\": {\"pos_user_id\": 6, \"pos_promotion_code\": \"\", \"pos_session_id\": 0, \"write_date\": \"2024-02-24 06:37:37\", \"creation_date\": \"2024-02-24 05:39:50\", \"is_printed\": 0, \"sequence_multisession\": 112, \"ios_notes\": \"\", \"revision_ID\": 8, \"ios_version\": \"V4.5.82(847)\", \"loyalty_redeemed_amount\": 0, \"delivery_method_id\": 6, \"delivery_type_reference\": \"\", \"amount_total\": 230, \"pos_id\": 5, \"order_on_server\": false, \"amount_return\": 0, \"fiscal_position_id\": false, \"return_reason_id\": false, \"is_sync\": false, \"name\": \"Order-1708753190-HUM-112\", \"nonce\": \"4mytm\", \"new_order\": false, \"bill_uid\": \"\", \"tax_discount\": 0, \"run_ID\": 1, \"ms_info\": {\"changed\": {\"user\": {\"id\": 6, \"name\": \"Hamood Nemeri\"}, \"pos\": {\"name\": \"HUM\", \"id\": 5, \"code\": \"HUM\"}}, \"created\": {\"user\": {\"id\": 6, \"name\": \"Hamood Nemeri\"}, \"pos\": {\"name\": \"HUM\", \"code\": \"HUM\", \"id\": 5}}}, \"lines\": [[0, 0, {\"price_subtotal_incl\": 215, \"tax_ids\": [[6, false, [1]]], \"combo_ext_line_info\": [], \"pos_conditions_id\": 0, \"product_tmpl_id\": 112, \"kitchen_status\": 1, \"uid\": \"1708753196326\", \"extra_price\": 0, \"write_date\": \"2024-02-24 05:40:02\", \"preparation_item_time\": 0, \"product_id\": 112, \"pos_promotion_id\": 0, \"is_void\": 0, \"ms_info\": {\"changed\": {\"user\": {\"name\": \"Hamood Nemeri\", \"id\": 6}, \"pos\": {\"name\": \"HUM\", \"id\": 5}}, \"created\": {\"user\": {\"name\": \"Hamood Nemeri\", \"id\": 6}, \"pos\": {\"name\": \"HUM\", \"id\": 5}}}, \"discount\": 0, \"id\": 1, \"pos_multi_session_write_date\": \"2024-02-24 06:38:13\", \"combo_id\": 0, \"discount_display_name\": \"\", \"note\": \"\", \"promotion_discount_amount\": 0, \"price_subtotal\": 186.956522, \"last_qty\": 5, \"pack_lot_ids\": [], \"printed\": 1, \"create_date\": \"2024-02-24 05:39:56\", \"price_unit\": 43, \"qty\": 5, \"is_changed\": true}], [0, 0, {\"pack_lot_ids\": [], \"product_id\": 3010, \"price_unit\": 9, \"price_subtotal_incl\": 9, \"uid\": \"1708753195626\", \"qty\": 1, \"price_subtotal\": 7.826087, \"id\": 1}]], \"preparation_total_time\": 0, \"user_id\": 0, \"loyalty_earned_amount\": 0, \"amount_tax\": 30, \"guests_number\": null, \"loyalty_earned_point\": 0, \"note\": \"\", \"loyalty_redeemed_point\": 0, \"pickup_user_id\": 0, \"sequence_number\": 112, \"statement_ids\": [], \"create_date\": \"2024-02-24 05:39:50\", \"menu_status\": \"none\", \"amount_paid\": 0, \"partner_id\": 8620, \"is_void\": false, \"payment_status\": \"unPaid\", \"uid\": \"1708753190-HUM-112\", \"pricelist_id\": 1, \"void_uid_lines\": [], \"print_count\": 9, \"is_closed\": false, \"order_sync_type\": 0}}
"""
      let dic =  SharedManager.shared.conAPI().StringToDictionary(str: fakeJsonString)
        SharedManager.shared.printLog("fake dic = \(dic)")
        SharedManager.shared.poll?.read_order(data:dic )
#else

#endif
    }
    
    func fackeIPOrder(comingOrder:pos_order_class?){
        comingOrder?.creatKDSQueuePrinter(.kds, isFromIp: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(10), execute: {
            MWRunQueuePrinter.shared.startMWQueue()
        })

    }
}
enum DATA_BASE_NAME:String{
    case databse = "database_db"
    case log = "log_db"
    case multipeer_log = "multipeer_log_db"
    case ingenico_log = "ingenico_log_db"
    case message_ip_log = "message_ip_log_db"
    case printer_log = "printer_log_db"

}
