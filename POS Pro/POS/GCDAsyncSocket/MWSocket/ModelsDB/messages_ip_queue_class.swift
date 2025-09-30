//
//  messages_ip_queue_class.swift
//  pos
//
//  Created by M-Wageh on 20/03/2023.
//  Copyright © 2023 khaled. All rights reserved.
//

import Foundation


class messages_ip_queue_class: NSObject {
    
    static var  date_formate_database:String = "yyyy-MM-dd HH:mm:ss"
    var id : Int = 0
    var queue_ip_type : QUEUE_IP_TYPES?
    var message:String? //BodyMessageIpModel
    
    var ipMessageType: IP_MESSAGE_TYPES?
    var target:DEVICES_TYPES_ENUM?
    var targetIp:String = ""
    var messageIdentifier:String = ""
    var noTries:Int = -1
    var messagesUIDS:String = ""
//    var logID:Int?

    var dbClass:database_class?
    
    override init() {
        dbClass = database_class(connect: .meesage_ip_log)
    }
    
    
    init(fromDictionary dictionary: [String:Any]){
        super.init()
        
        id = dictionary["id"] as? Int ?? 0
        queue_ip_type = QUEUE_IP_TYPES(rawValue:  dictionary["queue_ip_type"] as? Int ?? 1)
        message = dictionary["message"] as? String ?? ""
        
        if let ipMessageTypeInt = dictionary["ipMessageType"] as? Int  {
            ipMessageType = IP_MESSAGE_TYPES(rawValue:ipMessageTypeInt)
        }
        if let targetString  =  dictionary["target"] as? String {
            target = DEVICES_TYPES_ENUM(rawValue: targetString)
        }
        targetIp = dictionary["targetIp"] as? String ?? ""
        messageIdentifier = dictionary["messageIdentifier"] as? String ?? ""
        noTries = dictionary["noTries"] as? Int ?? -1
        messagesUIDS = dictionary["messagesUIDS"] as? String ?? ""
//        logID = dictionary["logID"] as? String ?? ""

        
        
        dbClass = database_class(table_name: "messages_ip_queue", dictionary: self.toDictionary(),id: id,id_key:"id",connect: .meesage_ip_log)
    }
    
    
    func toDictionary() -> [String:Any]
    {
        var dictionary:[String:Any] = [:]
        dictionary["queue_ip_type"] = queue_ip_type?.rawValue
        dictionary["message"] = message
        dictionary["ipMessageType"] = ipMessageType?.rawValue ?? ""
        dictionary["target"] = target?.rawValue ?? ""
        dictionary["targetIp"] = targetIp
        dictionary["messageIdentifier"] = messageIdentifier
        dictionary["noTries"] = noTries
        dictionary["messagesUIDS"] = messagesUIDS
//        dictionary["logID"] = logID

        return dictionary
    }
    
    
    func save()
    {
        dbClass?.dictionary = self.toDictionary()
        self.id =  dbClass!.save()
    }
    
    func getBodyMessage() -> BodyMessageIpModel?{
        var bodyMessage:BodyMessageIpModel? = nil
        if let message = self.message{
        let messageData = Data(message.utf8)
        do {
            bodyMessage = try BodyMessageIpModel(jsonData: messageData)
        } catch let error {
            SharedManager.shared.printLog("ERROR: Couldnt create Message from data \(error.localizedDescription)")
        }
        }
        return bodyMessage
    }
    static func getAll() ->  [[String:Any]] {
        
        let cls = messages_ip_queue_class(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(whereSql: "")
        return arr
        
    }
    static func getFailureMessages3Times() ->  [messages_ip_queue_class] {
        
        let cls = messages_ip_queue_class(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(whereSql: " WHERE noTries <= 3 and queue_ip_type in (\(QUEUE_IP_TYPES.FALIURE.rawValue)) limit 20")
        //TODO: - get Last body for order
        return arr.map({messages_ip_queue_class(fromDictionary: $0)})
        
    }
    static func setQueueType(with type:QUEUE_IP_TYPES, for ids:[Int]? = nil ){
//        SharedManager.shared.printLog("setQueueType == with \(type) ==== for \(ids)")
        MWQueue.shared.mwMessageSocketQueue.async {
            var incrementTriesQuery = ""
            var whereQuery = ""

        if type == .FALIURE {
            incrementTriesQuery = " , noTries = noTries + 1  "
        }
            if let ids = ids, ids.count > 0  {
                whereQuery = "WHERE id in ( \(ids.map({"\($0)"}).joined(separator: ", ")) )"
                
            }
        _ = database_class(connect: .meesage_ip_log).runSqlStatament(sql: " UPDATE messages_ip_queue SET queue_ip_type = \(type.rawValue)  \(incrementTriesQuery) \(whereQuery) ")
        }

    }
    static func updateQueueType(for types:[QUEUE_IP_TYPES], with type:QUEUE_IP_TYPES ){
        MWQueue.shared.mwMessageSocketQueue.async {
            var incrementTriesQuery = ""
        if type == .FALIURE {
            incrementTriesQuery = " , noTries = noTries + 1  "
        }
            let appMessagesQuery = " and ipMessageType not in (" +  IP_MESSAGE_TYPES.appMessages().map({"\($0.rawValue)"}).joined(separator: ",") + ")"
            let exsitTypes = "(" + types.map({"\($0.rawValue)"}).joined(separator: ",") + ")"
            let existTypeIds = "SELECT id from messages_ip_queue WHERE queue_ip_type in \(exsitTypes)"
        _ = database_class(connect: .meesage_ip_log).runSqlStatament(sql: " UPDATE messages_ip_queue SET queue_ip_type = \(type.rawValue)  \(incrementTriesQuery) WHERE id in ( \(existTypeIds) ) \(appMessagesQuery)")
        }

    }
    static func updateMessageAppQueueType(for types:[QUEUE_IP_TYPES], with type:QUEUE_IP_TYPES ){
        MWQueue.shared.mwMessageSocketQueue.async {
            var incrementTriesQuery = ""
        if type == .FALIURE {
            incrementTriesQuery = " , noTries = noTries + 1  "
        }
            let appMessagesQuery = " and ipMessageType in (" +  IP_MESSAGE_TYPES.appMessages().map({"\($0.rawValue)"}).joined(separator: ",") + ")"
            let exsitTypes = "(" + types.map({"\($0.rawValue)"}).joined(separator: ",") + ")"
            let existTypeIds = "SELECT id from messages_ip_queue WHERE queue_ip_type in \(exsitTypes)"
        _ = database_class(connect: .meesage_ip_log).runSqlStatament(sql: " UPDATE messages_ip_queue SET queue_ip_type = \(type.rawValue)  \(incrementTriesQuery) WHERE id in ( \(existTypeIds) ) \(appMessagesQuery)")
        }

    }
    static func delete(for ids:[Int])   {
//        SharedManager.shared.printLog("delete == \(ids)")
        MWMessageQueueRun.shared.isStarDeletMessages = true
//        MWQueue.shared.mwMessageSocketQueue.async {
            
        _ = database_class(connect: .meesage_ip_log).runSqlStatament(sql: "delete from messages_ip_queue WHERE id in ( \(ids.map({"\($0)"}).joined(separator: ", ")) ) ")
            MWMessageQueueRun.shared.isStarDeletMessages = false

//        }
    }
    
    
    
    static func deleteAll()   {
        _ = database_class(connect: .meesage_ip_log).runSqlStatament(sql: "delete from messages_ip_queue")
    }
    
    static func deleteBefore(hour:Int = 9){
        let sql = """
                    DELETE from messages_ip_queue WHERE updated_at <= date('now','-\(hour) hour');
        """
        _ = database_class(connect: .meesage_ip_log).runSqlStatament(sql: sql)

    }
    func get_date_now_formate_datebase() -> String {
        
        return Date().toString(dateFormat: messages_ip_queue_class.date_formate_database, UTC: true)
        
    }

    static func save(from bodyMessages:[BodyMessageIpModel]) -> [messages_ip_queue_class]
    {
        var ipQueueMessages:[messages_ip_queue_class] = []
        bodyMessages.forEach { messageObject in
            var dictionary: [String:Any] = [:]
            dictionary["message"] = messageObject.toDict().jsonString() ?? ""
//            dictionary["queue_ip_type"] = queue_ip_type?.rawValue
//            dictionary["message"] = message
            dictionary["ipMessageType"] = messageObject.ipMessageType.rawValue
            dictionary["target"] = messageObject.target.rawValue
            dictionary["targetIp"] = messageObject.targetIp
            dictionary["messageIdentifier"] = messageObject.getIdentifier()
//            dictionary["noTries"] = messageObject.noTries
            dictionary["messagesUIDS"] =  messageObject.getOrderUid()?.joined(separator: ",") ?? ""

            let ipQueue = messages_ip_queue_class(fromDictionary: dictionary)
            ipQueue.save()
            ipQueueMessages.append(ipQueue)
//            SharedManager.shared.printLog("ipQueue === \(ipQueue.id)")
        }
        return ipQueueMessages
    }
    static func getAll(for queueTypes:[QUEUE_IP_TYPES], ipMessage: [IP_MESSAGE_TYPES]? = nil) ->  [messages_ip_queue_class] {
        var ipMessageTypeQuery = ""
        if let ipMessage = ipMessage{
            ipMessageTypeQuery = " and ipMessageType in (\(ipMessage.map({"\($0.rawValue)"}).joined(separator:", ")))  "

        }
        let cls = messages_ip_queue_class(fromDictionary: [:])
        let arr  = cls.dbClass!.get_rows(whereSql: " WHERE queue_ip_type in (\(queueTypes.map({"\($0.rawValue)"}).joined(separator:", "))) \(ipMessageTypeQuery) limit 50")
        return arr.map({messages_ip_queue_class(fromDictionary: $0)})
        
    }
    static func getCount(for queueTypes:[QUEUE_IP_TYPES],
                         noTriesLimit:Int? = nil,
                         ipMessage: [IP_MESSAGE_TYPES]? = nil
    ) ->  Int {
        let cls = messages_ip_queue_class(fromDictionary: [:])
        var noTriesQuery = ""
        var queueTypesQuery = ""
        var ipMessageTypeQuery = ""
        if queueTypes.count > 0 {
            queueTypesQuery = "queue_ip_type in (\(queueTypes.map({"\($0.rawValue)"}).joined(separator:", ")))"
        }
        if let noTriesLimit = noTriesLimit {
            noTriesQuery = " and noTries <= \(noTriesLimit)  "
        }
        
        if let ipMessage = ipMessage{
            ipMessageTypeQuery = " and ipMessageType in (\(ipMessage.map({"\($0.rawValue)"}).joined(separator:", ")))  "

        }
        
        let count:[String:Any]  = database_class(connect: .meesage_ip_log).get_row(sql: "select count(*) as cnt from messages_ip_queue  WHERE  \(queueTypesQuery) \(noTriesQuery) \(ipMessageTypeQuery)") ?? [:]
        return (count["cnt"] as? Int ?? 0)

    }
    
    static func vacuum_database()
    {
        let sql = "vacuum"
        
        let semaphore = DispatchSemaphore(value: 0)
        SharedManager.shared.message_ip_log_db!.inDatabase { (db:FMDatabase) in
            
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
    static func getFailureMessages3Times(state:QUEUE_IP_TYPES = .FALIURE) ->  [messages_ip_queue_class] {
        let countTries:Int? = SharedManager.shared.appSetting().enable_resent_failure_ip_kds_order_automatic ? nil : 6

        let cls = messages_ip_queue_class(fromDictionary: [:])
        var numTriesQuery = ""
        if let countTries = countTries {
            numTriesQuery = "and noTries <= \(countTries)"
        }
        let sql = "WHERE  queue_ip_type in (\(state.rawValue))  \(numTriesQuery) order by noTries ASC  limit 6"
        let arr  = cls.dbClass!.get_rows(whereSql: sql )
        return arr.map({messages_ip_queue_class(fromDictionary: $0)})
        
    }
    
}
