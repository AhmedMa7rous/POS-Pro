//
//  MWServerTCP+GCDAsyncSocketDelegate.swift
//  pos
//
//  Created by M-Wageh on 18/03/2023.
//  Copyright © 2023 khaled. All rights reserved.
//

import Foundation
// MARK: -
// MARK: MWServerTCP+GCDAsyncSocketDelegate

extension MWServerTCP: GCDAsyncSocketDelegate {
    
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        addStateToLog("Socket did connect to host \(host) on port \(port)")
        serverConnect(to:sock)
    }
    
    func socket(_ sock: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket) {
        initializeMessageLog("AcceptNewSocket Socket did accept new socket \(newSocket.connectedHost ?? "---") ")
        self.messages_ip_log?.to_ip  = newSocket.localHost
        mwSocketAccept(newSocket)
        // Wait for a message
        newSocket.readData(to: GCDAsyncSocket.crlfData(), withTimeout: timeOutReadData, tag: 0)
    }
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        addStateToLog("Socket did read data with tag \(tag)")
        serverReadData(from: sock, data:data)
    }
    
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        if let error = err{
            serverDisConnect(sock,withError:error.localizedDescription ?? "Empty error")
            saveMessageLog()
        }
        
        
    }
    func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
        addStateToLog("Socket did write data with tag \(tag)")
        serverWriteData(to: sock)
        
    }
}
