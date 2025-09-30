//
//  MemberShipSearchModel.swift
//  pos
//
//  Created by M-Wageh on 26/02/2023.
//  Copyright © 2023 khaled. All rights reserved.
//

import Foundation
struct MemberShipSearchModel : Codable,JSONAble {
    let id : Int?
    let name : String?
    let date_order : String?
    var partner_id : [String]  = [String]()
    var meal_type_id : [String] = [String]()
    var period_id : [String]  = [String]()
    var partnerObject : res_partner_class?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case date_order = "date_order"
        case partner_id = "partner_id"
        case meal_type_id = "meal_type_id"
        case period_id = "period_id"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        do { id = try values.decodeIfPresent(Int.self, forKey: .id)} catch { id = nil }

        do { name = try values.decodeIfPresent(String.self, forKey: .name)} catch { name = nil }
        do { date_order = try values.decodeIfPresent(String.self, forKey: .date_order)} catch {date_order = nil}
        do {
            var partnerArray = try values.nestedUnkeyedContainer(forKey: .partner_id)
            while !partnerArray.isAtEnd {
                do {
                    let string = try partnerArray.decode(String.self)
                    partner_id.append(string)
                } catch {
                    let int = try partnerArray.decode(Int.self)
                    partner_id.append(String(int))
                    partnerObject = res_partner_class.get(row_id: int)
                }
            }
        } catch {
            partner_id = []
        }
        do {
            var periodIdArray = try values.nestedUnkeyedContainer(forKey: .period_id)
            while !periodIdArray.isAtEnd {
                do {
                    let string = try periodIdArray.decode(String.self)
                    period_id.append(string)
                } catch {
                    let int = try periodIdArray.decode(Int.self)
                    period_id.append(String(int))
                }
            }
        } catch {
            period_id = []
        }
        do {
            var mealTypeIdArray = try values.nestedUnkeyedContainer(forKey: .meal_type_id)
            while !mealTypeIdArray.isAtEnd {
                do {
                    let string = try mealTypeIdArray.decode(String.self)
                    meal_type_id.append(string)
                } catch {
                    let int = try mealTypeIdArray.decode(Int.self)
                    meal_type_id.append(String(int))
                }
            }
        } catch {
            meal_type_id = []
        }
    }
   
    
}
