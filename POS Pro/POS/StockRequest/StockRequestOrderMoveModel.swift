//
//  StockRequestOrderMoveModel.swift
//  pos
//
//  Created by M-Wageh on 23/05/2022.
//  Copyright © 2022 khaled. All rights reserved.
//

import Foundation

struct StockRequestOrderMoveModel : Codable,JSONAble {
    let id : Int?
    let name : String?
    let expected_date : String?
    var warehouse_id : [String]  = [String]()
//    let origin : String?
//    var location_dest_id : [String] = [String]()
    var location_id : [String] = [String]()

//    var partner_id : [String] = [String]()
    let stock_request_ids : [Int]?
    let state : String?
    
    enum CodingKeys: String, CodingKey {
        
        case id = "id"
        case name = "name"
        case expected_date = "expected_date"
        case warehouse_id = "warehouse_id"
//        case origin = "origin"
//        case location_dest_id = "location_dest_id"
//        case partner_id = "partner_id"
        case stock_request_ids = "stock_request_ids"
        case state = "state"
        case location_id = "location_id"

    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        do { id = try values.decodeIfPresent(Int.self, forKey: .id)} catch { id = nil }
        do { name = try values.decodeIfPresent(String.self, forKey: .name)} catch { name = nil }
        do { expected_date = try values.decodeIfPresent(String.self, forKey: .expected_date)} catch {expected_date = nil}
//        do { origin = try values.decodeIfPresent(String.self, forKey: .origin) } catch { origin = nil}
        do { stock_request_ids = try values.decodeIfPresent([Int].self, forKey: .stock_request_ids)} catch {  stock_request_ids = nil }
        do { state = try values.decodeIfPresent(String.self, forKey: .state)} catch {  state = nil }
       /* do {
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
            }*/
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
            var pickingTypeArray = try values.nestedUnkeyedContainer(forKey: .warehouse_id)
            while !pickingTypeArray.isAtEnd {
                do {
                    let string = try pickingTypeArray.decode(String.self)
                    warehouse_id.append(string)
                } catch {
                    let int = try pickingTypeArray.decode(Int.self)
                    warehouse_id.append(String(int))
                }
            }
        } catch {
            warehouse_id = []
        }
    }
   
    
}
struct StockRequestOrderDetailsModel : Codable,JSONAble {
    /*
     "display_name","order_id","product_id","expected_date","picking_policy","product_uom_qty","qty_in_progress","qty_done"
     */
    let id : Int?
    let order_id : Int?
    let display_name : String?
    let expected_date : String?
    var product_id : [String]  = [String]()
    var product_uom_qty : Double?
    var product_uom_id : [String]  = [String]()
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case order_id = "order_id"
        case display_name = "display_name"
        case expected_date = "expected_date"
        case product_id = "product_id"
        case product_uom_qty = "product_uom_qty"
        case product_uom_id = "product_uom_id"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        do { id = try values.decodeIfPresent(Int.self, forKey: .id)} catch { id = nil }

        do { order_id = try values.decodeIfPresent(Int.self, forKey: .order_id)} catch { order_id = nil }
        do { display_name = try values.decodeIfPresent(String.self, forKey: .display_name)} catch { display_name = nil }
        do { expected_date = try values.decodeIfPresent(String.self, forKey: .expected_date)} catch {expected_date = nil}
        do { product_uom_qty = try values.decodeIfPresent(Double.self, forKey: .product_uom_qty)} catch {  product_uom_qty = nil }
        do {
            var pickingTypeArray = try values.nestedUnkeyedContainer(forKey: .product_id)
            while !pickingTypeArray.isAtEnd {
                do {
                    let string = try pickingTypeArray.decode(String.self)
                    product_id.append(string)
                } catch {
                    let int = try pickingTypeArray.decode(Int.self)
                    product_id.append(String(int))
                }
            }
        } catch {
            product_id = []
        }
        do {
            var pickingTypeArray = try values.nestedUnkeyedContainer(forKey: .product_uom_id)
            while !pickingTypeArray.isAtEnd {
                do {
                    let string = try pickingTypeArray.decode(String.self)
                    product_uom_id.append(string)
                } catch {
                    let int = try pickingTypeArray.decode(Int.self)
                    product_uom_id.append(String(int))
                }
            }
        } catch {
            product_uom_id = []
        }
    }
   
    
}
