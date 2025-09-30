//
//  InStockMoveModel.swift
//  pos
//
//  Created by  Mahmoud Wageh on 5/17/21.
//  Copyright © 2021 khaled. All rights reserved.
//

import Foundation
struct InStockMoveModel : Codable,JSONAble {
    let id : Int?
    let name : String?
    let scheduled_date : String?
    var picking_type_id : [String]  = [String]()
    let origin : String?
    var location_dest_id : [String] = [String]()
    var location_id : [String] = [String]()

    var partner_id : [String] = [String]()
    let move_lines : [Int]?
    let state : String?
    
    enum CodingKeys: String, CodingKey {
        
        case id = "id"
        case name = "name"
        case scheduled_date = "scheduled_date"
        case picking_type_id = "picking_type_id"
        case origin = "origin"
        case location_dest_id = "location_dest_id"
        case partner_id = "partner_id"
        case move_lines = "move_lines"
        case state = "state"
        case location_id = "location_id"

    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        do { id = try values.decodeIfPresent(Int.self, forKey: .id)} catch { id = nil }
        do { name = try values.decodeIfPresent(String.self, forKey: .name)} catch { name = nil }
        do { scheduled_date = try values.decodeIfPresent(String.self, forKey: .scheduled_date)} catch {scheduled_date = nil}
        do { origin = try values.decodeIfPresent(String.self, forKey: .origin) } catch { origin = nil}
        do { move_lines = try values.decodeIfPresent([Int].self, forKey: .move_lines)} catch {  move_lines = nil }
        do { state = try values.decodeIfPresent(String.self, forKey: .state)} catch {  state = nil }
        do {
            var partnerIdArray = try values.nestedUnkeyedContainer(forKey: .partner_id)
            while !partnerIdArray.isAtEnd {
                do {
                    let string = try partnerIdArray.decode(String.self)
                    partner_id.append(string)
                } catch {
                    let int = try partnerIdArray.decode(Int.self)
                    partner_id.append(String(int))
                }
            }
        } catch {
            partner_id = []
        }
        do {
            var locationDestArray = try values.nestedUnkeyedContainer(forKey: .location_dest_id)
            while !locationDestArray.isAtEnd {
                do {
                    let string = try locationDestArray.decode(String.self)
                    location_dest_id.append(string)
                } catch {
                    let int = try locationDestArray.decode(Int.self)
                    location_dest_id.append(String(int))
                }
            }} catch {
                location_dest_id = []
            }
        do {
            var locationArray = try values.nestedUnkeyedContainer(forKey: .location_id)
            while !locationArray.isAtEnd {
                do {
                    let string = try locationArray.decode(String.self)
                    location_id.append(string)
                } catch {
                    let int = try locationArray.decode(Int.self)
                    location_id.append(String(int))
                }
            }} catch {
                location_id = []
            }
        do {
            var pickingTypeArray = try values.nestedUnkeyedContainer(forKey: .picking_type_id)
            while !pickingTypeArray.isAtEnd {
                do {
                    let string = try pickingTypeArray.decode(String.self)
                    picking_type_id.append(string)
                } catch {
                    let int = try pickingTypeArray.decode(Int.self)
                    picking_type_id.append(String(int))
                }
            }
        } catch {
            picking_type_id = []
        }
    }
    init(from model:StockRequestOrderMoveModel){
        id  = model.id
        name = model.name
        scheduled_date = model.expected_date
         picking_type_id = []
         origin = nil
        location_dest_id = []
        location_id = model.location_id

         partner_id = []
        move_lines = model.stock_request_ids
        state = model.state
    }
   
    
}
