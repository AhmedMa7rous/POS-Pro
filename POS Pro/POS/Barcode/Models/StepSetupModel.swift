//
//  StepSetupModel.swift
//  pos
//
//  Created by M-Wageh on 16/03/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation
enum STEP_TYPES{
    case image,table,none
}
class StepSetupModel {
    var title: String
    var subtitle: String
    var btntitle: String
    var icon: String
    var type:STEP_TYPES
    

    init(title: String, subtitle: String, icon: String, btntitle: String,type:STEP_TYPES) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.type = type
        self.btntitle = btntitle
    }
}
