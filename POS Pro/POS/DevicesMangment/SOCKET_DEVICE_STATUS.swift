//
//  SOCKET_DEVICE_STATUS.swift
//  pos
//
//  Created by M-Wageh on 22/08/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation
enum SOCKET_DEVICE_STATUS:Int,CaseIterable {
    case NONE = 0 , ACTIVE, NOT_ACTIVE
    
    static func getAll() -> [SOCKET_DEVICE_STATUS]{
        SOCKET_DEVICE_STATUS.allCases
    }
    static func get(value:String) -> SOCKET_DEVICE_STATUS {
        if value == SOCKET_DEVICE_STATUS.NONE.getDescription() {
            return .NONE
        }
        if value == SOCKET_DEVICE_STATUS.ACTIVE.getDescription() {
            return .ACTIVE
        }
        if value == SOCKET_DEVICE_STATUS.NOT_ACTIVE.getDescription() {
            return .NOT_ACTIVE
        }
        
        return .NONE
    }
    static func getRawValue(value:String) -> Int {
        if value == SOCKET_DEVICE_STATUS.NONE.getDescription() {
            return SOCKET_DEVICE_STATUS.NONE.rawValue
        }
        if value == SOCKET_DEVICE_STATUS.ACTIVE.getDescription() {
            return SOCKET_DEVICE_STATUS.ACTIVE.rawValue
        }
        if value == SOCKET_DEVICE_STATUS.NOT_ACTIVE.getDescription() {
            return SOCKET_DEVICE_STATUS.NOT_ACTIVE.rawValue
        }
        
        return SOCKET_DEVICE_STATUS.NONE.rawValue
    }
    func getDescription() -> String {
        return "\(self.rawValue)"
    }
    func getStatuusName()->String{
        return "\(self)"
    }
}
