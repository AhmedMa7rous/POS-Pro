//
//  AddOperationModel.swift
//  pos
//
//  Created by  Mahmoud Wageh on 5/30/21.
//  Copyright © 2021 khaled. All rights reserved.
//

import Foundation
class AddOperationModel {
    var picking_type_id : Int? = nil
    var location_id : Int? = nil
    var location_dest_id : Int? = nil
    var partner_id : Int? = nil
    var scheduled_date : String? = nil
    var move_lines : [[Any]] = []

    func toDictionary() -> [String:Any]?{
        guard let picking_type_id = picking_type_id,
              let location_id = location_id,
              let location_dest_id = location_dest_id,
              let partner_id = partner_id,
              let scheduled_date = scheduled_date
              else { return nil }
        return [
            "picking_type_id": picking_type_id,
            "location_id": location_id,
            "location_dest_id": location_dest_id,
            "partner_id": partner_id,
            "scheduled_date":scheduled_date,
            "move_lines":move_lines
        ]
    }
}
