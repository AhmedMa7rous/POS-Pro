//
//  MWDataManger.swift
//  pos
//
//  Created by M-Wageh on 24/07/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation
class MWDataManger {
    static let shared:MWDataManger = MWDataManger()
    private init(){}
    func writeMWSockectData(with str: String,for socket: GCDAsyncSocket,isHost:Bool) {
//        let size = UInt(MemoryLayout<UInt64>.size)
        var data = Data(str.utf8)
        data.append(GCDAsyncSocket.crlfData())
        socket.write(data, withTimeout: -1, tag: isHost ? 0 : 0)
//        socket.readData(toLength: size, withTimeout: -1, tag:  isHost ? 0 : 0)
//        socket.readData(to: GCDAsyncSocket.crlfData(), withTimeout: -1, tag: isHost ? 0 : 0)

    }
    func readMWSockectData(for socket: GCDAsyncSocket,isHost:Bool) {
        socket.readData(to: GCDAsyncSocket.crlfData(), withTimeout: -1, tag: isHost ? 0 : 0)
    }
    
    func writeMessages(_ message:MWIPMessageProtocol,for socket: GCDAsyncSocket){
        self.writhData(for:message, to : socket)
    }
    func serlizatioinResponse(data: Data) -> MWIPMessageProtocol? {
        let messageData = data.dropLast(2)

        var message: MWIPMessageProtocol? = nil
        do {
            message = try ResponseMessageIpModel(jsonData: messageData)
        } catch let error {
                SharedManager.shared.printLog("ERROR: serlizatioinResponse Message from data \(error.localizedDescription)")
        }
        return message
    }
    func serlizatioinBody(data: Data) -> MWIPMessageProtocol? {
        let messageData = data.dropLast(2)

        var message: MWIPMessageProtocol? = nil
        do {
            message = try BodyMessageIpModel(jsonData: messageData)
        }  catch let error {
                SharedManager.shared.printLog("ERROR: serlizatioinBody Message from data \(error.localizedDescription)")
            }
        return message
    }
    
   private func writhData(for message:MWIPMessageProtocol, to socket: GCDAsyncSocket){
        if let dataMessage = message.getIPData() {
            let tag = message.target.getIpConnectionTag()
            socket.write(dataMessage, withTimeout: -1, tag: 0 )
        }
    }
    
    
}
