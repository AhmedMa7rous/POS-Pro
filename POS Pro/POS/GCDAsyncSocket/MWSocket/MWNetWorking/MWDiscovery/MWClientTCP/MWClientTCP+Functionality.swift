//
//  MWTCP+HostFunctionality.swift
//  pos
//
//  Created by M-Wageh on 16/03/2023.
//  Copyright © 2023 khaled. All rights reserved.
//

import Foundation

//MARK: - MWTCP+HostFunctionality

extension MWClientTCP {
    func clientDisconnectDone(){
            let previousSuccess = self.getIsSuccess()
            self.addStateToLog("disconnectDone so start next ip-device in queue")
            self.saveMessageLog()
            self.selectService?.delegate = nil
            self.selectService?.stop()
            self.mwSocket?.disconnect()
            self.selectService = nil
            self.mwSocket = nil
            self.selectIpDevice?.nextQueue(previousSuccess:previousSuccess)
    }
    func mwSocketAccept(_ newSocket: GCDAsyncSocket){
        if let mwSocket = mwSocket , let currentMessage = self.selectIpDevice?.current_message?.getBodyMessage(){
            MWDataManger.shared.writeMessages(currentMessage, for: mwSocket)
        }
        hostSocket = newSocket
        newSocket.readData(to: GCDAsyncSocket.crlfData(), withTimeout: timeOutReadData, tag:  0)
    }
    func clientReadData(from sock: GCDAsyncSocket,  data: Data){
//        if let respons = MWDataManger.shared.serlizatioinResponse(data: data) as? ResponseMessageIpModel{
//            MaintenanceInteractor.shared.updateSequence(with:respons.seq,is_closed: respons.closedByMaster , for: respons.uid,voidUID:respons.res_void_pending_uid,SyncUID: respons.res_sync_pending_uid,closedUID: respons.res_closed_pending_uid)
            if let respons = MWDataManger.shared.serlizatioinResponse(data: data) as? ResponseMessageIpModel{
                MaintenanceInteractor.shared.updateSequence(with:respons.seq,is_closed: respons.closedByMaster,for: respons.uid )
            addStateToLog("joinReadData respons")
            MWComingOrderHelper.shared.handleResponse(with:respons)

            self.selectIpDevice?.setLogWith(response:respons)
            
            if let device_info_dic = respons.reciever as? [String:Any]{
                let recieveInfo = MessageIpInfoModel(dict:device_info_dic)
                let macAddress = recieveInfo.macAddress
                self.selectIpDevice?.socket_device.updateMacAddress(with:macAddress)
            }
            
            
            if let nextMessage = self.selectIpDevice?.nextMessage()?.getBodyMessage(),let mwSocket = mwSocket {
                MWDataManger.shared.writeMessages(nextMessage, for: mwSocket)
            }else{
                //if respons.code == .success {
                sock.readData(to: GCDAsyncSocket.crlfData(), withTimeout: timeOutStopReadData, tag: 0)
                setLogIsSucces(true)
                sock.disconnect()
                return
                // }
            }
            
            
        }else if let body = MWDataManger.shared.serlizatioinBody(data: data) as? BodyMessageIpModel {
            addStateToLog("joinReadData body")
            
            self.messages_ip_log?.body = body.toDict().jsonString()
            let sender_info =  MessageIpInfoModel(dict: body.sender)
            if !(sender_info.ipAddress?.isEmpty ?? true) {
                self.messages_ip_log?.to_ip = sender_info.ipAddress
            }
            
            MWComingOrderHelper.shared.handleIpServerMessage(with:body) { responseModel,responseOrderModel in
                self.addStateToLog("joinReadData write responseModel")

                if let responseModel = responseModel{
                MWDataManger.shared.writeMessages( responseModel, for: sock)
                }else{
                    let responseSuccess = ResponseMessageIpModel(message: "succes body recieve", code: .success, target: sender_info.deviceType,responeNewOrder: responseOrderModel)
                    setLogIsSucces(true)
                    MWDataManger.shared.writeMessages( responseSuccess, for: sock)
                    addStateToLog("joinReadData sock.readData")
                    sock.disconnect()
                    clientDisconnectDone()
//                    sock.readData(to: GCDAsyncSocket.crlfData(), withTimeout: timeOutStopReadData, tag: 0)

                    return

                }
            }

            
                    
            
            
        }else{
            let str = String(decoding: data, as: UTF8.self)
            let astr = "Join did read \(str) with host port: \(sock.connectedPort)"
            addStateToLog(astr)
            
        }
        addStateToLog("joinReadData sock.readData")
        
        sock.readData(to: GCDAsyncSocket.crlfData(), withTimeout: timeOutReadData, tag: 0)
    }
    
    func clientWriteData(to sock: GCDAsyncSocket){
        addStateToLog("Write Data to Socket \(sock.connectedHost ?? "--") \(sock.connectedPort)")
    }
    
    func clientConnect(to newSocket: GCDAsyncSocket){
       
        if let mwSocket = mwSocket{
            if let message = self.selectIpDevice?.current_message?.getBodyMessage() {
                MWDataManger.shared.writeMessages(message, for: mwSocket)
            }
        }
        
        mwSocket?.readData(to: GCDAsyncSocket.crlfData(), withTimeout: -1, tag:  0)
    }
    
    func clientDisConnect(_ sock: GCDAsyncSocket, withError err: String){
        addStateToLog("Unable Socket Did Disconnect with Error \(String(describing: err)) with User Info \(err).")
        if err.lowercased().contains("socket closed by remote peer"){
            addStateToLog("[Socket closed by remote peer] Socket did disconnect with ")
            
        }else{
            addStateToLog("Unable Socket Did Disconnect with Error \(String(describing: err)) with User Info \(err).")
        }
        // [Hashing as it makee refuse connection after call pedding orders]!MWLocalNetworking.sharedInstance.isJion 
        if !MWLocalNetworking.sharedInstance.isJion {
        sock.disconnect()
        }
    }
    
    func forceTimeOutDisConnectClient(){
        self.addStateToLog("Unable Socket Did Disconnect with Error Time out Task [Force time out]")
        self.hostSocket?.disconnect()
        self.hostSocket = nil
        setLogIsSucces(false)
        if let serviceTimeOut = self.selectService {
            //        MWLocalNetworking.sharedInstance.checkAndRemove(serviceTimeOut)
            //        startDiscovery()
            //        serviceTimeOut.stop()
            
        }
        self.clientDisconnectDone()
    }
    
}


