//
//  PresencePosModel.swift
//  pos
//
//  Created by M-Wageh on 29/03/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation
struct PresenceModel: Codable, Hashable  {
    var lastSeen: Int? = Int(Date().timeIntervalSince1970 * 1000)
    var status: String? = ""
    var name_pos:String? = ""
}
