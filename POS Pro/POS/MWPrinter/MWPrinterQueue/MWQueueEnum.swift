//
//  MWQueueEnum.swift
//  pos
//
//  Created by M-Wageh on 12/06/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation
enum MWQueue_Status:Int{
    case NONE=0, START, WAITING, DONE, CANCEL, RETRY, FAIL,NEED_STOP,NEED_DISCOVERY,START_DISCOVERY,BACK_GROUND,FORE_GROUND
    func canRetry()->Bool{
        return self == .NONE || self == .FORE_GROUND
    }
}
enum QUEUE_PRIORITY:Int{
    case LOW = 0, MEDIUM, HIGH
}

