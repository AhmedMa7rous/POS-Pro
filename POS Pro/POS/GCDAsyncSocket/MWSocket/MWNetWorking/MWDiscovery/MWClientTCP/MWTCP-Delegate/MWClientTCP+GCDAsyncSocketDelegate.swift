//
//  MWTCP+GCDAsyncSocketDelegate.swift
//  pos
//
//  Created by M-Wageh on 16/03/2023.
//  Copyright © 2023 khaled. All rights reserved.
//

import Foundation
// MARK: -
// MARK: MWTCP+GCDAsyncSocketDelegate

extension MWClientTCP: GCDAsyncSocketDelegate {

    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        addStateToLog("Socket did connect to host \(host) on port \(port)")
        clientConnect(to:sock)
    }
    
    func socket(_ sock: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket) {
        initializeMessageLog("AcceptNewSocket Socket did accept new socket \(newSocket.connectedHost ?? "---") ")
//        addStateToLog("Socket did accept new socket \(newSocket.connectedHost) newSocket.localHost \(newSocket.localHost)")
        self.messages_ip_log?.to_ip  = newSocket.localHost
        mwSocketAccept(newSocket)
        // Wait for a message
        newSocket.readData(to: GCDAsyncSocket.crlfData(), withTimeout: timeOutReadData, tag: 0)
    }
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        addStateToLog("Socket did read data with tag \(tag)")
        clientReadData(from: sock, data:data)
    }
    
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        // If the client has passed the connect/accept method, then the connection has at least begun.
        if let error = err{
            addStateToLog("Unable Socket did disconnect with error \(error.localizedDescription )")
            setLogIsSucces(false)
            clientDisConnect(sock,withError:err?.localizedDescription ?? "Empty error")
            saveMessageLog()
        }else{
            setLogIsSucces(true)
        }
        self.clientDisconnectDone()
    }
    func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
        addStateToLog("Socket did write data with tag \(tag)")
        clientWriteData(to: sock)

    }
}
