//
//  InfoPosModel.swift
//  pos
//
//  Created by M-Wageh on 29/03/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation

struct InfoPosModel: Codable, Hashable  {
    var timeStamp: Int? = Int(Date().timeIntervalSince1970 * 1000)
    var pos_name: String? = ""
    var pending_orders: String? = ""
    var ios_version: String? = ""
    var last_sync: String? = ""
    var ip_address: String? = ""

    init(){
        pos_name = SharedManager.shared.getPosName() ?? ""
        ios_version = Bundle.main.fullVersion
        let count_pending = SharedManager.shared.get_count_pending_orders()
        pending_orders = "\(count_pending)"
        last_sync = cash_data_class.get(key: "lastupdate" +  "_"  + "api_loaded") ?? ""
        ip_address = MWConstantLocalNetwork.getIPV4Address()
    }
}
struct InfoTCPModel: Codable, Hashable  {
    var timeStamp: Int? = Int(Date().timeIntervalSince1970 * 1000)
    var ip_address: String? = nil
    var is_publish:Bool? = nil
    var is_master:Bool? = nil
    var is_master_online:Bool? = nil
    var is_master_open_session:Bool? = nil
    var is_message_queue_running:Bool? = nil
    var is_start_fetch_seq:Bool? = nil
    var source_update:String? = ""

    init(_ source_update:String?){
        self.source_update = source_update
        ip_address = MWConstantLocalNetwork.getIPV4Address()
        is_publish = MWLocalNetworking.sharedInstance.mwServerTCP.isPublished
        is_master = SharedManager.shared.posConfig().isMasterTCP()
        is_message_queue_running = MWMessageQueueRun.shared.messageQueueIsRunning()
        is_start_fetch_seq = sequence_session_ip.shared.isStartSequence()
        if let masterDevice = device_ip_info_class.getMasterStatus(){
            is_master_online = masterDevice.is_online
            is_master_open_session = masterDevice.is_open_session
        }
    }
}
