//
//  FREnum.swift
//  pos
//
//  Created by M-Wageh on 29/03/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation
enum presenceStatus:String{
    case online = "online"
    case offline  = "offline"
    func desc()->String{
        switch self {
        case .online:
            return "online"
        case .offline:
return "offline"
        }
    }
}
