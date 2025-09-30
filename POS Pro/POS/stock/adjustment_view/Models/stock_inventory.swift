//
//  stock_inventory.swift
//  pos
//
//  Created by M-Wageh on 01/09/2021.
//  Copyright © 2021 khaled. All rights reserved.
//

import Foundation
struct StockInventoryModel : Codable {
    let id : Int?
    let name : String?
    let date : String?
    let line_ids : [Int]?
    let move_ids : [Int]?
    let state : String?
    let location_ids : [Int]?
    let product_ids : [Int]?
    let select_by : String?
    let category_ids : [Int]?
    let display_name : String?
    var create_uid : [String] = [String]()
    let create_date : String?
    var write_uid : [String] = [String]()
    let write_date : String?
    let __last_update : String?
    let sequence : String?

    enum CodingKeys: String, CodingKey {

        case id = "id"
        case name = "name"
        case date = "date"
        case line_ids = "line_ids"
        case move_ids = "move_ids"
        case state = "state"
        case location_ids = "location_ids"
        case product_ids = "product_ids"
        case select_by = "select_by"
        case category_ids = "category_ids"
        case display_name = "display_name"
        case create_uid = "create_uid"
        case create_date = "create_date"
        case write_uid = "write_uid"
        case write_date = "write_date"
        case __last_update = "__last_update"
        case sequence = "sequence"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        do { id = try values.decodeIfPresent(Int.self, forKey: .id)} catch { id = nil }
        do { name = try values.decodeIfPresent(String.self, forKey: .name)} catch { name = nil }
        do { date = try values.decodeIfPresent(String.self, forKey: .date)} catch { date = nil }
        do { line_ids = try values.decodeIfPresent([Int].self, forKey: .line_ids)} catch { line_ids = [] }
        do { move_ids = try values.decodeIfPresent([Int].self, forKey: .move_ids)} catch { move_ids = [] }
        do { state = try values.decodeIfPresent(String.self, forKey: .state)} catch { state = nil }
        do { location_ids = try values.decodeIfPresent([Int].self, forKey: .location_ids)} catch { location_ids = [] }
        do { product_ids = try values.decodeIfPresent([Int].self, forKey: .product_ids)} catch { product_ids = [] }
        do { select_by = try values.decodeIfPresent(String.self, forKey: .select_by)} catch { select_by = nil }
        do { category_ids = try values.decodeIfPresent([Int].self, forKey: .category_ids)} catch { category_ids = [] }
        do { display_name = try values.decodeIfPresent(String.self, forKey: .display_name)} catch { display_name = nil }
        do {
            var create_uid_array = try values.nestedUnkeyedContainer(forKey: .create_uid)
            while !create_uid_array.isAtEnd {
                do {
                    let string = try create_uid_array.decode(String.self)
                    create_uid.append(string)
                } catch {
                    let int = try create_uid_array.decode(Int.self)
                    create_uid.append(String(int))
                }
            }
        } catch {
            create_uid = []
            
        }
        do { create_date = try values.decodeIfPresent(String.self, forKey: .create_date)} catch { create_date = nil }
        do {
            var write_uid_array = try values.nestedUnkeyedContainer(forKey: .write_uid)
            while !write_uid_array.isAtEnd {
                do {
                    let string = try write_uid_array.decode(String.self)
                    write_uid.append(string)
                } catch {
                    let int = try write_uid_array.decode(Int.self)
                    write_uid.append(String(int))
                }
            }
            
        } catch {
            write_uid = []
            
        }
        do { write_date = try values.decodeIfPresent(String.self, forKey: .write_date)} catch { write_date = nil }
        do { __last_update = try values.decodeIfPresent(String.self, forKey: .__last_update)} catch { __last_update = nil }
        do { sequence = try values.decodeIfPresent(String.self, forKey: .sequence)} catch { sequence = nil }

    }

}
