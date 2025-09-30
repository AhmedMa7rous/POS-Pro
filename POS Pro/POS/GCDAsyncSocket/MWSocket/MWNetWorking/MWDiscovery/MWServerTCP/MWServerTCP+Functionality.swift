//
//  MWServerTCP+HostFunctionality.swift
//  pos
//
//  Created by M-Wageh on 18/03/2023.
//  Copyright © 2023 khaled. All rights reserved.
//

import Foundation
//MARK: - MWServerTCP+HostFunctionality

extension MWServerTCP {
    func serverDisconnectDone(){
            addStateToLog("disconnectDone start next in queue")
            saveMessageLog()
            mwServerTCPSocket?.disconnect()
        mwServerTCPSocket = nil
       
    }
    func mwSocketAccept(_ newSocket: GCDAsyncSocket){
        MWLocalNetworking.sharedInstance.addSocketConnected(newSocket)
        newSocket.readData(to: GCDAsyncSocket.crlfData(), withTimeout: timeOutReadData, tag:  0)
    }
    func serverReadData(from sock: GCDAsyncSocket,  data: Data){
        if let respons = MWDataManger.shared.serlizatioinResponse(data: data) as? ResponseMessageIpModel{
//            MaintenanceInteractor.shared.updateSequence(with:respons.seq,is_closed: respons.closedByMaster , for: respons.uid,voidUID:respons.res_void_pending_uid,SyncUID: respons.res_sync_pending_uid,closedUID: respons.res_closed_pending_uid )

            MaintenanceInteractor.shared.updateSequence(with:respons.seq,is_closed: respons.closedByMaster, for: respons.uid )
            addStateToLog("joinReadData respons")
            
            MWComingOrderHelper.shared.handleResponse(with:respons)

            self.messages_ip_log?.response = respons.toDict().jsonString()
                if respons.code == .success {
                    sock.readData(to: GCDAsyncSocket.crlfData(), withTimeout: timeOutStopReadData, tag: 0)
                    sock.disconnect()
//                    serverDisconnectDone()
                    return
                }
            
            
        }else if let body = MWDataManger.shared.serlizatioinBody(data: data) as? BodyMessageIpModel {
            let sender_info =  MessageIpInfoModel(dict: body.sender)
            let sender_ip = sender_info.ipAddress ?? ""
            SharedManager.shared.printLog("sender_ip \(sender_ip) == MWConstantLocalNetwork.posHostServiceName \(MWConstantLocalNetwork.posHostServiceName)")
            if sender_ip == MWConstantLocalNetwork.posHostServiceName{
//                self.writeSuccessResponse(to : sock,target:sender_info.deviceType)
                return
            }
            addStateToLog("joinReadData body")
            
            self.messages_ip_log?.body = body.toDict().jsonString()
            if !(sender_ip.isEmpty) {
                self.messages_ip_log?.to_ip = sender_info.ipAddress
            }
            
            MWComingOrderHelper.shared.handleIpServerMessage(with:body) { responseModel,responseOrderModel in
                self.addStateToLog("joinReadData write responseModel")
                DispatchQueue.main.async {                    
                    if let responseModel = responseModel{
                        MWDataManger.shared.writeMessages( responseModel, for: sock)
                    }else{
                        self.writeSuccessResponse(to : sock,target:sender_info.deviceType,responeNewOrder: responseOrderModel)
                        //                    sock.readData(to: GCDAsyncSocket.crlfData(), withTimeout: timeOutStopReadData, tag: 0)
                        //[BUG]Must return after sent success response to avoid stack cyle
                        //                    addStateToLog("return joinReadData sock.readData ")
                        //                    sock.readData(to: GCDAsyncSocket.crlfData(), withTimeout: timeOutStopReadData, tag: 0)
                        //                    sock.disconnect()
                        //                    return
                    }
                }
            }
                        
            
            
        }else{
            let str = String(decoding: data, as: UTF8.self)
            let astr = "Join did read \(str) " //with host port: \(sock.connectedPort)"
            addStateToLog(astr)
            
        }
        addStateToLog("joinReadData sock.readData")
        
        sock.readData(to: GCDAsyncSocket.crlfData(), withTimeout: timeOutReadData, tag: 0)
    }
    func writeSuccessResponse(to sock: GCDAsyncSocket,target:DEVICES_TYPES_ENUM,responeNewOrder:ResponeNewOrderModel?){
        let responseSuccess = ResponseMessageIpModel(message: "succes body recieve", code: .success, 
                                                     target: target,responeNewOrder:responeNewOrder)
        MWDataManger.shared.writeMessages( responseSuccess, for: sock)
        addStateToLog("joinReadData sock.readData")
    }
    
    func serverWriteData(to sock: GCDAsyncSocket){
        addStateToLog("Write Data to Socket \(sock.connectedHost ?? "--") \(sock.connectedPort)")
    }
    
    func serverConnect(to newSocket: GCDAsyncSocket){
               
        mwServerTCPSocket?.readData(to: GCDAsyncSocket.crlfData(), withTimeout: -1, tag:  0)
    }
    
    func serverDisConnect(_ sock: GCDAsyncSocket, withError err: String){
        addStateToLog("Unable Socket Did Disconnect with Error \(String(describing: err)) with User Info \(err).")
        if err.lowercased().contains("socket closed by remote peer"){
            addStateToLog("[Socket closed by remote peer] Socket did disconnect with ")
            
        }else{
            addStateToLog("Unable Socket Did Disconnect with Error \(String(describing: err)) with User Info \(err).")
        }
        MWLocalNetworking.sharedInstance.connectedSockets.removeAll()
    }
    
    
}

