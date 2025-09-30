//
//  MWComingOrderHelper.swift
//  pos
//
//  Created by M-Wageh on 16/03/2023.
//  Copyright © 2023 khaled. All rights reserved.
//

import Foundation

class ResponeNewOrderModel{
    var seq:Int?
    var uid:String?
    var is_closed_by_master:Bool?
//    var res_void_pending_uid:[String]?
//    var res_closed_pending_uid:[String]?
//    var res_sync_pending_uid:[String]?
    init(seq: Int? = nil, uid: String? = nil,is_closed_by_master:Bool? = nil) {


//    init(seq: Int? = nil, uid: String? = nil,is_closed_by_master:Bool? = nil,res_void_pending_uid:[String]? = nil,res_closed_pending_uid:[String]? = nil,res_sync_pending_uid:[String]? = nil) {
        self.seq = seq
        self.uid = uid
        self.is_closed_by_master = is_closed_by_master
//        self.res_void_pending_uid = res_void_pending_uid
//        self.res_closed_pending_uid = res_closed_pending_uid
//        self.res_sync_pending_uid = res_sync_pending_uid


    }
}

class MWComingOrderHelper {
    static let shared = MWComingOrderHelper()
    private var differentCount:Int?
    private let ipOrderFactor = IPOrderFactor.shared
    private init(){
        
    }
    
    //MARK: - handleIpMessage
    func handleIpServerMessage(with body:BodyMessageIpModel, completion: ( (MWIPMessageProtocol?,ResponeNewOrderModel?) -> Void) ){
        let typeMessage =  body.ipMessageType
        if typeMessage == .PENDING_ORDERS {
            self.handdlePedingOrder(with :body, completion: completion)
        }else if typeMessage == .RE_SEND_PENDING {
            self.handdleReSendPedingOrder(with :body, completion: completion)
        }
                else if typeMessage == .REQUEST_SEQ {
                    self.handdleSequence(with :body, completion: completion)
                }
//        else if typeMessage == .DEVICE_INFO {
//            self.handdleDeviceInfo(with :body, completion: completion)
//        }
        else if typeMessage == .SEND_DEVICE_INFO {
        self.handdleComingDeviceInfo(with :body, completion: completion)
    }
        else{
            handleComingOrder(body,completion: completion)
        }
    }
    func handleResponse(with respons:ResponseMessageIpModel){
//        sequence_session_ip.shared.updateSequenceSession(from: respons.reciever )
        let recieve_info =  MessageIpInfoModel(dict: respons.reciever)
        if !(recieve_info.ipAddress?.isEmpty ?? true) {
            self.updateDeviceIfo(from:respons.reciever,targetIp:recieve_info.ipAddress ?? "" )
        }
        
    }
    private func handdleComingDeviceInfo(with body:BodyMessageIpModel, completion: ( (MWIPMessageProtocol?,ResponeNewOrderModel?) -> Void)){
        let data:[String:Any] = body.data.first ?? [:]
        let sender_info =  MessageIpInfoModel(dict: body.sender)
        let targetIp = sender_info.ipAddress ?? ""
      
        if let device_info = data[MWConstantLocalNetwork.MessageKeys.DEVICE_INFO] as? [String:Any]{
            if !SharedManager.shared.posConfig().isMasterTCP(){
             //   sequence_session_ip.shared.updateSequenceSession(from: body.sender )
            }
            self.updateDeviceIfo(from:device_info,targetIp:targetIp )
            
        }
        
        completion(nil,nil)
        
    }
    private func handdleSequence(with body:BodyMessageIpModel, completion: ( (MWIPMessageProtocol?,ResponeNewOrderModel?) -> Void)){
        let data:[String:Any] = body.data.first ?? [:]
        let sender_info =  MessageIpInfoModel(dict: body.sender)
        let targetIp = sender_info.ipAddress ?? ""
        
        if let info = data[MWConstantLocalNetwork.MessageKeys.REQUEST_SEQ] as? String,info.isEmpty{
            if sequence_session_ip.shared.isStartSequence(){
                self.handdleSequence(with :body, completion: completion)
                return
            }
            if targetIp != MWConstantLocalNetwork.MessageKeys.MASTER_DEVICE_NAME{
                sequence_session_ip.shared.shareIncreaseSequence()
//                sequence_session_ip.shared.updateSequenceSession(from: body.sender )

            }
            let requestBody = self.ipOrderFactor.getSequenceResponse(for: targetIp)
            self.updateDeviceIfo(from:body.sender,targetIp:targetIp )
            
            completion(requestBody,nil)
            return
            
        }
        if let device_info = data[MWConstantLocalNetwork.MessageKeys.REQUEST_SEQ] as? [String:Any]{
            sequence_session_ip.shared.updateSequenceSession(from: body.sender )
            self.updateDeviceIfo(from:device_info,targetIp:targetIp )
            
        }
        completion(nil,nil)
        
    }
    /*
    private func handdleDeviceInfo(with body:BodyMessageIpModel, completion: ( (MWIPMessageProtocol?,ResponeNewOrderModel?) -> Void)){
        let data:[String:Any] = body.data.first ?? [:]
        let sender_info =  MessageIpInfoModel(dict: body.sender)
        let targetIp = sender_info.ipAddress ?? ""
        
        if let info = data[MWConstantLocalNetwork.MessageKeys.DEVICE_INFO] as? String,info.isEmpty{
            if sequence_session_ip.shared.isStartSequence(){
                self.handdleDeviceInfo(with :body, completion: completion)
                return
            }
            if targetIp == MWConstantLocalNetwork.MessageKeys.MASTER_DEVICE_NAME{
                sequence_session_ip.shared.updateSequenceSession(from: body.sender )

            }
            let requestBody = self.ipOrderFactor.getDeviceInfoResponse(for: targetIp)
            self.updateDeviceIfo(from:body.sender,targetIp:targetIp )
            completion(requestBody)
            return
            
        }
        if let device_info = data[MWConstantLocalNetwork.MessageKeys.DEVICE_INFO] as? [String:Any]{
            sequence_session_ip.shared.updateSequenceSession(from: body.sender )
            self.updateDeviceIfo(from:device_info,targetIp:targetIp )
            
        }
        completion(nil)
        
    }
     */
    func updateDeviceIfo(from infoDic:[String:Any],targetIp:String ){
        MWQueue.shared.mwUpdateStatusDevice.async {
            /*
            var needCallPending = false
            if let order_sequces =  infoDic["order_sequces"] as? Int {
                if let socketID = socket_device_class.getDevice(by:targetIp )?.id{
                    let deviceIP = device_ip_info_class(fromDictionary: infoDic)
                    deviceIP.sockect_device_id = socketID
                    if !SharedManager.shared.posConfig().isMasterTCP(){
                        deviceIP.pos_name = MWConstantLocalNetwork.MessageKeys.MASTER_DEVICE_NAME
                    }
                    let resulrtUpdate = deviceIP.updateIfExist()
                    needCallPending  = (deviceIP.is_online ?? false) && !(resulrtUpdate.oldOnline)
                    if !resulrtUpdate.isExist{
                        deviceIP.save()
                    }
                    deviceIP.updateLastDate()
                }
            }else{
                let sender_info =  MessageIpInfoModel(dict: infoDic)
                let senderIp = sender_info.ipAddress ?? ""
                if let socketID = socket_device_class.getDevice(by:targetIp )?.id{
                    let deviceIP = device_ip_info_class(from: sender_info)
                    deviceIP.sockect_device_id = socketID
                    let resulrtUpdate = deviceIP.updateIfExist()
                    needCallPending  = (deviceIP.is_online ?? false) && !(resulrtUpdate.oldOnline)
                    if !resulrtUpdate.isExist{
                        deviceIP.save()
                    }
                    deviceIP.updateLastDate()
                }
                
            }
            if targetIp == MWConstantLocalNetwork.MessageKeys.MASTER_DEVICE_NAME {
                DispatchQueue.main.async {
                    if needCallPending{
                      //  MWTCPRequest.shared.requestPendingOrder()
                    }else{
                       // MWMasterIP.shared.checkMasterStatus()
                    }
                }
            }
             */
        }
        
    }
    private func handdleReSendPedingOrder(with body:BodyMessageIpModel, completion: ( (MWIPMessageProtocol?,ResponeNewOrderModel?) -> Void)){
        let sender_info =  MessageIpInfoModel(dict: body.sender)
        let targetIp = sender_info.ipAddress ?? ""
        
        self.updateDeviceIfo(from:body.sender,targetIp:targetIp )
        
       let result = savePendingOrders(from: body)
        var responeNewOrderModel:ResponeNewOrderModel? = nil
        if result.resVoidUID.count > 0 || result.resSyncUID.count > 0 || result.resClosedUID.count > 0{

//            responeNewOrderModel = ResponeNewOrderModel( res_void_pending_uid: result.resVoidUID, res_closed_pending_uid: result.resClosedUID, res_sync_pending_uid: result.resSyncUID)
        }
        if body.data.count == self.ipOrderFactor.limitPendingOrder {
            self.ipOrderFactor.increaseOffest()
            let requestBody = self.ipOrderFactor.getUIDPendingOrders().filter({$0.targetIp == targetIp}).first
            completion(requestBody,responeNewOrderModel)
            return
            
        }
        self.ipOrderFactor.resetOffest()

        completion(nil,responeNewOrderModel)
        
    }
    private func handdlePedingOrder(with body:BodyMessageIpModel, completion: ( (MWIPMessageProtocol?,ResponeNewOrderModel?) -> Void)){
        let orderDic = body.data.first ?? [:]
        let sender_info =  MessageIpInfoModel(dict: body.sender)
        let targetIp = sender_info.ipAddress ?? ""
        
        self.updateDeviceIfo(from:body.sender,targetIp:targetIp )
        
        if let excludeUid = orderDic[MWConstantLocalNetwork.MessageKeys.EXCLUD_UID] as? [String]{
            let offsetPending = orderDic[MWConstantLocalNetwork.MessageKeys.OFF_SET_PENDING] as? Int ?? 0
            if let messageIpBody = ipOrderFactor.getPendingOrders(for: targetIp, excludUID: excludeUid, offset: offsetPending), messageIpBody.data.count > 0{
                completion(messageIpBody,nil)
                return
            }
        }
        completion(nil,nil)
        
    }
    private func handleComingOrder(_ body:BodyMessageIpModel,completion: ( (MWIPMessageProtocol?,ResponeNewOrderModel?) -> Void)){
        differentCount = nil
        let sender_info =  MessageIpInfoModel(dict: body.sender)
        let targetIp = sender_info.ipAddress ?? ""
        self.updateDeviceIfo(from:body.sender,targetIp:targetIp )
        
        guard let comingOrder = getPosOrder(from: body) else {
            completion(nil,nil)
            return
        }
        if SharedManager.shared.posConfig().isMasterTCP(){
            if comingOrder.is_closed && body.ipMessageType != IP_MESSAGE_TYPES.SCRAP_ORDER {
                completion(nil,ResponeNewOrderModel(is_closed_by_master: true))
                return
            }
        }
        
        let options = ordersListOpetions()
        options.uid = comingOrder.uid
        options.get_lines_void = true
//        options.get_lines_void_from_ui = true
//        options.get_lines_promotion = false
        options.parent_product = true
        options.has_extra_product = true
        
        comingOrder.fillPosOrderLines(list: &comingOrder.pos_order_lines, with: options)
//        comingOrder.pos_order_lines =  comingOrder.getAllLines(with: true)
        comingOrder.save(write_info: false,re_calc: true)
        if SharedManager.shared.posConfig().isMasterTCP(){
            let ipMessage = body.ipMessageType
            let excludIP = body.sender[MWConstantLocalNetwork.MessageKeys.IP_ADDRESS_KEY] as? String ?? ""
            if ipMessage != .RETURNED_ORDER {
                let mwComingOrder = MWComingOrderQueu(comingOrderUID:comingOrder.uid ?? "coming-uid" , excludIP: excludIP, ipMessage: ipMessage)
                MWComingOrderStack.shared.append([mwComingOrder])
                //                comingOrder.sent_order_via_ip(with: ipMessage,excludeIp: excludIP)
            }else{
                let orderDic = body.data.first ?? [:]
                let posLinesReturn = (orderDic["pos_order_lines"] as? [[String:Any]] ?? []).map({pos_order_line_class(fromDictionary: $0,with: true)}).map({"\($0.uid)"})
                let mwComingOrder = MWComingOrderQueu(comingOrderUID:comingOrder.uid ?? "coming-uid" , excludIP: excludIP, ipMessage: ipMessage,return_lines_uids:posLinesReturn)
                MWComingOrderStack.shared.append([mwComingOrder])
                //                comingOrder.sent_returned_order_via_ip(returnedLines:posLinesReturn , excludeIp: excludIP)
            }
            //if (differentCount ?? 0) > 0{
                DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                    MWComingOrderStack.shared.startSend()
                })
           // }
        }
        self.postUpdateOrderNotification(order:comingOrder)
        completion(nil,ResponeNewOrderModel(seq: comingOrder.sequence_number, uid: comingOrder.uid))
    }
    private func savePendingOrders(from body:BodyMessageIpModel) -> (resVoidUID:[String],resClosedUID:[String],resSyncUID:[String]){
        if body.data.count <= 0 {
            return ([],[],[])
        }
        var resVoidUID:[String] = []
        var resClosedUID:[String] = []
        var resSyncUID:[String] = []

        pos_order_class.remove_pending_orders(isTCP: true)
        for (index, _ ) in body.data.enumerated() {
           let orderDone = self.getPosOrder(from:body,index: index )
            if (orderDone?.is_void ?? false) {
                resVoidUID.append(orderDone?.uid ?? "")
            }else{
                if (orderDone?.is_closed ?? false) {
                    resClosedUID.append(orderDone?.uid ?? "")
                }else{
                    if (orderDone?.is_sync ?? false) {
                        resSyncUID.append(orderDone?.uid ?? "")
                    }
                }
            }
           /* var orderDic = orderItem
            orderDic["id"] = 0
            orderDic["session_id_local"] = pos_session_class.getActiveSession()?.id
            var coming_order =  pos_order_class(fromDictionary: orderDic)
           if let existOrder = pos_order_class.get(uid: coming_order.uid ?? ""){
               if existOrder.is_closed || existOrder.is_sync || existOrder.is_void {
                   continue
               }
               coming_order.id = existOrder.id
            }
            coming_order.recieve_date = baseClass.get_date_now_formate_datebase()
            let lines_comming = (orderDic["pos_order_lines"] as? [[String:Any]] ?? []).map({pos_order_line_class(fromDictionary: $0,with: true)})
            coming_order.save(write_info: false, re_calc:false)
            let _ = CompareComingLines.shared.startCompare(ipMessageType: .NEW_ORDER, order_uid: coming_order.uid ?? "ip-uid", order_id: coming_order.id ?? 0, comingLines: Array(Set(lines_comming)), exsitsLines: [])
            
            self.updateOrder(coming_order,body.ipMessageType)
            */
        }
        self.postUpdateOrderNotification()
        return (resVoidUID,resClosedUID,resSyncUID)

        
    }
    
    private func getPosOrder(from body:BodyMessageIpModel,index:Int = 0) -> pos_order_class?{
        let deviceType = body.target
        let ipMessageType =  body.ipMessageType
        
        var orderDic = index == 0 ? (body.data.first ?? [:]) : (body.data[index] )
        orderDic["id"] = 0
        orderDic["session_id_local"] = pos_session_class.getActiveSession()?.id
        
//        guard let order_uid = orderDic["uid"] as? String else{return nil}
        var coming_order =  pos_order_class(fromDictionary: orderDic)
        coming_order.updateOrder(fromIp: orderDic)
        coming_order.recieve_date = baseClass.get_date_now_formate_datebase()
        let lines_comming = (orderDic["pos_order_lines"] as? [[String:Any]] ?? []).map({pos_order_line_class(fromDictionary: $0,with: true)})
        if lines_comming.count == 0 {
            SharedManager.shared.printLog("order coming is empty lines")
        }
        var lines_existing:[pos_order_line_class] = []
        
       
        if let exist_order = self.updateOrder(coming_order,body.ipMessageType) {
            if body.ipMessageType  == .RE_SEND_PENDING {
                if exist_order.is_void {
                    exist_order.sent_order_via_ip(with: IP_MESSAGE_TYPES.VOID_ORDER,withoutStart: true)
                    return nil
                }
            }
            let disCountLine = exist_order.get_discount_line()
            disCountLine?.is_void  = true
            disCountLine?.void_status  = .from_ip
            disCountLine?.save()
            let deliveryLine = exist_order.get_delivery_line()
            deliveryLine?.is_void  = true
            deliveryLine?.void_status  = .from_ip
            deliveryLine?.save()
            coming_order = exist_order
            lines_existing = exist_order.pos_order_lines
        }else{
            if coming_order.sequence_number == MWConstantLocalNetwork.defaultSequence {
                let activeSession = pos_session_class.getActiveSession()
                let invoiceID = coming_order.generateInviceID(session_id: activeSession!.id )
                coming_order.sequence_number = invoiceID
            }
            coming_order.save(write_info: false,write_date: false,re_calc: false)
        }
        differentCount = CompareComingLines.shared.startCompare(ipMessageType: ipMessageType, order_uid: coming_order.uid ?? "ip-uid", order_id: coming_order.id ?? 0, comingLines: Array(Set(lines_comming)), exsitsLines: lines_existing)
        
        return coming_order
        
    }
    private func postUpdateOrderNotification(order:pos_order_class? = nil){
        var userInfo:[String:Any] = [:]
        userInfo["need_calc"] = true
        userInfo["isPaid"] = order?.is_closed
        userInfo["play_sound"] = (differentCount ?? 0) > 0
        DispatchQueue.main.asyncAfter(deadline: .now() + .microseconds(200), execute: {
            NotificationCenter.default.post(name: Notification.Name("poll_update_order"), object: order?.uid ?? "",userInfo: userInfo)
        })
    }
  @discardableResult  private func updateOrder(_ coming_order:pos_order_class,_ ipMessageType: IP_MESSAGE_TYPES) -> pos_order_class?{
        let opetions = ordersListOpetions()
        opetions.uid = coming_order.uid ?? ""
        opetions.get_lines_void = true
        //        opetions.void = false
        opetions.parent_product = true
        opetions.orderDesc = false
      opetions.has_extra_product = true
        if let coming_order_db = pos_order_helper_class.getOrders_status_sorted(options: opetions).first {
            updateValues(for:coming_order_db, with:coming_order,for: ipMessageType)
            return coming_order_db
        }
        return nil
    }
    func updateValues(for coming_order_db:pos_order_class, with coming_order:pos_order_class,for ipMessageType:IP_MESSAGE_TYPES,
                      doSave:Bool = true){
        if coming_order_db.is_closed{
            return
        }
        coming_order_db.reward_bonat_code = coming_order.reward_bonat_code
        coming_order_db.guests_number = coming_order.guests_number
        coming_order_db.note = coming_order.note
        coming_order_db.session_id_local = pos_session_class.getActiveSession()?.id
        coming_order_db.partner_id = coming_order.partner_id
        coming_order_db.table_id = coming_order.table_id
        coming_order_db.table_name = coming_order.table_name
        coming_order_db.driver_id = coming_order.driver_id
        coming_order_db.write_date = coming_order.write_date
        coming_order_db.write_pos_code = coming_order.write_pos_code
        coming_order_db.write_pos_id = coming_order.write_pos_id
        coming_order_db.write_pos_name = coming_order.write_pos_name
        coming_order_db.write_user_id = coming_order.write_user_id
        coming_order_db.write_user_name = coming_order.write_user_name
        coming_order_db.table_control_by_user_id = coming_order.table_control_by_user_id
        coming_order_db.table_control_by_user_name = coming_order.table_control_by_user_name
        coming_order_db.delivery_type_id = coming_order.delivery_type_id
        coming_order_db.amount_tax = coming_order.amount_tax
        coming_order_db.amount_paid = coming_order.amount_paid
        coming_order_db.amount_total = coming_order.amount_total
        coming_order_db.amount_return = coming_order.amount_return
        coming_order_db.is_void = coming_order.is_void
        coming_order_db.void_status = coming_order.void_status
        if ipMessageType == .PAYIED_ORDER{
            coming_order_db.is_closed = true

        }else{
        coming_order_db.is_closed = coming_order.is_closed
        }
        coming_order_db.is_sync = coming_order.is_sync
        coming_order_db.promotion_code = coming_order.promotion_code
        coming_order_db.recieve_date = coming_order.recieve_date
        coming_order_db.order_sync_type = coming_order.order_sync_type

        
        
        
        if  doSave{
            coming_order_db.save(write_info: false,write_date: false,re_calc: false)
        }
        if !(coming_order_db.reward_bonat_code ?? "").isEmpty{
            BonatCodeInteractor.shared.checkRewardBonat(order:coming_order_db) { result in
                
            }
        }

    }

}

